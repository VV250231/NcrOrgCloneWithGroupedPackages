/****************************************************************************************************************
*   ClassName :   AutoJoinGSOCafeChatterGroup
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati          Removed hardcoded Collaboration Group Id
****************************************************************************************************************/
/*
written by : as250738
purpose : to have all the new users (who belong to certain profiles) added to GSO CAFE chatter group
also : when users profile chnages to one which is not supposed to be in this chatter group, users will need to be removed manually

NOTE : CHNAGE THE GROUP ID (at 2 places) WITH PRODUCTION AT THE TIME OF DEPLOYMENT, I AM NOT QUERYING THE ID WITH NAME AS THE CHATTER GROUP NAME MAY CHNAGE IN FUTURE
*/

/*
global class AutoJoinGSOCafeChatterGroup {
    public void executes() {
*/

global class AutoJoinGSOCafeChatterGroup implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        list <CollaborationGroupMember> cgm = new list <CollaborationGroupMember>();
        list <user> u = new list <user>();
        list <user> u2 = new list <user>();
        set <id> s = new set <id>();
        list <CollaborationGroupMember> userJoinedManully = new list <CollaborationGroupMember>();
        
        u =[select id from user where (profile.name= '01 GS Admin' OR profile.name= '03 PRM Admin' OR
        profile.name= '06 Sales Compensation Admin' OR profile.name= '07 HOSP Admin' OR 
        profile.name= '20 Channel/Hybrid Account Director' OR profile.name= '21 Channel/Distributor Account Manager' 
        OR profile.name= '23 PRM Services User' OR profile.name= '24 PRM Marketing User' OR
        profile.name= '26 Marketing Content Admin' OR profile.name= '27 Marketing Campaign Admin' OR
        profile.name= '30 GS Account Director' OR profile.name= '30 GS Account Director w/Office Connect' OR
        profile.name= '30 GS Specialist' OR profile.name= '31 GS Account Manager' OR profile.name= '32 Retail Inside Sales'  
        OR profile.name= '33 Inside Sales' OR profile.name= '34 Services Sales' OR profile.name= '35 IPS Account Director'  OR
        profile.name= '36 IPS Account Manager' OR profile.name= '37 IPS Inside Sales' OR profile.name= '40 Solution Manager' OR 
        profile.name= '41 Customer Temperature Admin' OR profile.name= '42 Customer Temperature Validation' OR
        profile.name= '50 Hospitality Account Director' OR profile.name= '51 Hospitality Account Manager' OR
        profile.name= '52 Hospitality Finance Manager' OR profile.name= '53 Hospitality Channel Account Manager') AND 
        isactive=true AND createdDate = LAST_WEEK];
        
        system.debug('>>>'+u.size());
        
        u2 = [SELECT Id, isactive FROM User WHERE Profile.name LIKE '%22 Channel/Hybrid Sales%' AND isactive=true AND createdDate = LAST_WEEK ];
        
        system.debug('>>>'+u2.size());
        u.addall(u2);
        system.debug(' u >>>'+u.size());
        
        for(user us : u)
        {
            s.add(us.id);
        }
        system.debug(' s >>>'+s.size());
        // U has all newly created users
        //search for members who manually joined the group
        //userJoinedManully = [select id, memberId from CollaborationGroupMember where memberid IN : u and CollaborationGroupId =: '0F970000000LNl6'];
        userJoinedManully = [select id, memberId from CollaborationGroupMember where memberid IN : u and CollaborationGroupId =: NSCCommonInfoUtil.getIdOf('Collaboration_Group_Id')]; //EBA_SF-1617 - Removed hardcoded Collaboration Group Id - Kapil Bhati
        system.debug('userJoinedManully>>>'+userJoinedManully.size());
        for(CollaborationGroupMember c : userJoinedManully)
        {
            if(s.contains(c.MemberId))
            {
                s.remove(c.MemberId);
            }
        }
        
        system.debug('after removal of manually joined users >>>'+s.size());
        
        for(id cc:s)
        {
            CollaborationGroupMember c = new CollaborationGroupMember();
            // c.CollaborationGroupId = '0F970000000LNl6';
            c.CollaborationGroupId = NSCCommonInfoUtil.getIdOf('Collaboration_Group_Id');  //EBA_SF-1617 - Removed hardcoded Collaboration Group Id - Kapil Bhati
            /* 
            in production 0F970000000LNl6 
            in aug14test 0F9S0000000ClF9
            */
            c.MemberId = cc;
            c.NotificationFrequency = 'P';
            cgm.add(c);
        }
        
        
        system.debug('cgm >>>'+ cgm.size());
        insert cgm;
        
    }
}