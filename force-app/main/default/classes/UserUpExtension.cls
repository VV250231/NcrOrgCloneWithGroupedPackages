/*
##################################################################################################
# Project Name..........: Account Point Of Contact(APOC)
# File............................: UserUpExtension.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 03/02/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 03/02/2020 (MM/DD/YYYY)
# Description...............: This class is used from visualforce page associated to a custom link on user record if we want to upgrade
an employee(who is a partner user) to the salesforce license 
# Test Class - UserUpDownTest
# JIRA Story - #EBA_SF-1092(P1: APOC: APOC record re-assignment automation) 

# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-2275		9-9-2022		Monika	   AR community: Receiving duplicate nickname issue when upgrading AR Collector community user 
##################################################################################################
*/
public class UserUpExtension{
    public Id uId {get;set;}
    Public string slctdPrf{get;set;}
    public String errormsg{get;set;}
    public String slctdRole{get; set;}
    public String lname,uname,qlid,nkname;
    public boolean showerr{get;set;}
    public User usr;
    public UserUpExtension(ApexPages.standardController con){
        uId = con.getId();
        showerr=false;
    }
    public pagereference upgrade(){
        usr =[Select id,usertype,isactive,username,firstname,lastname,Quicklook_Id__c,Email,User_Profile__c,CommunityNickname from user where id =:uid];
        if(UpDownGrade__c.getValues('UpProfiles').value__c.split(',').contains(usr.User_Profile__c)){
            if(usr.Quicklook_ID__c.length()>8){ //check records in prod for qlid
                errormsg= UpDownGrade__c.getValues('UpErrMsg').value__c;//This user is already upgraded.
                showerr=true;
            }
            lname = usr.lastname;
            uname = usr.Username;
            qlid = usr.Quicklook_ID__c;   
            nkname = usr.CommunityNickname;
        }else{
            errormsg=UpDownGrade__c.getValues('UpErrMsgStd').value__c;//you cannot upgrade this user.
            showerr=true;
        }
        return null;
            
    }
    //Fetches all standard SF license profiles
    Public List<Selectoption> getStndrdPrfl(){//change the name of function - getStndrdPrfl
        List<Selectoption> lstnamesel = new List<selectoption>();
        //lstnamesel.add(new selectOption('', '- None -'));
        for(Profile pf :[Select id,name from profile where usertype='standard']){
            lstnamesel.add(new selectoption(pf.id,pf.name));
        }
        return lstnamesel; 
    }
    //Fetches all the standard roles
    Public List<Selectoption> getselectedrole(){
        List<Selectoption> roles = new List<selectoption>();
        //roles.add(new selectOption('', '- None -'));
        for(UserRole ur :[Select id,name from UserRole  where PortalType='None']){
            roles.add(new selectoption(ur.id,ur.name));
        }
        return roles; 
    }
    public void save(){
        String ms = '-'+string.valueof(Math.abs(Crypto.getRandomLong())).substring(0,2);
        System.debug('ms'+ms);
        User u = new user(id=usr.id,lastname = lname+'-INACTIVE',Username = uname+ms,Quicklook_ID__c = qlid+ms,CommunityNickname =nkname+ms, IsActive =false);
        UserDeactivateNotification.manUpdt = false;
        try{
            update u;
        }catch(Exception e){
            errormsg=e.getMessage();
            showerr=true;
        }   
    }
    public pageReference createUsr(){
        if(!showErr){
            String ud;
            String qlidlike = '%'+qlid+'%';
          // List<PermissionSetAssignment> pList  = [SELECT AssigneeId from PermissionSetAssignment where AssigneeId =:  usr.id];
            List<User> usrs = [Select id,isactive,username,quicklook_Id__c,lastname,profileId,UserType from User where quicklook_Id__c like :qlidlike and (usertype='Standard' or usertype ='csnOnly')];
            PermissionSet pset = [SELECT Id from PermissionSet where name ='BPM_Community'];
            if(usrs.size()>=1){
                User u = new User(Id= usrs[0].id,lastname = lname,Username = uname,Quicklook_ID__c = qlid,isactive = true,profileId= slctdPrf);
                try{
                    update u;
                    u.UserRoleId  = slctdRole;
                    update u;
                    ud= u.id;
                    if([SELECT AssigneeId from PermissionSetAssignment where PermissionSetId =: pset.ID AND AssigneeId =:  usrs[0].id].size() < 1){
                        insert new PermissionSetAssignment(PermissionSetId = pset.Id, AssigneeId = usrs[0].id);    
                    }
                }catch(Exception e){
                    errormsg=e.getMessage();
                    showerr=true;
                }   
            }else{
                User u1 = new User( Firstname=usr.firstname,Email=usr.Email, quicklook_Id__c = qlid,
                                   EmailEncodingKey='UTF-8', LastName=lname, LanguageLocaleKey='en_US', 
                                   LocaleSidKey='en_US', ProfileId = slctdPrf, 
                                   TimeZoneSidKey='America/Los_Angeles', UserName=uname,UserRoleId  = slctdRole,License_Entitlement__c='Partner Portal-Full',LOB__c='CROSS LOB',Area__c='Global');
                try{
                    insert u1;
                    if([SELECT AssigneeId from PermissionSetAssignment where PermissionSetId =: pset.ID AND AssigneeId =:  u1.id].size() < 1){
                        insert new PermissionSetAssignment(PermissionSetId = pset.Id, AssigneeId = u1.id);    
                    }
                    ud= u1.id;
                }catch(Exception e){
                    errormsg=e.getMessage();
                    showerr=true;
                }
            }
            Database.executeBatch(new APOCReassignmentBatch(uId));
            if(ud!=null){
                copyPermSet(usr.id,ud);
                PageReference pg = new PageReference(String.format(UpDownGrade__c.getValues('UserLink').value__c,new List<String>{URL.getSalesforceBaseUrl().getHost(),ud}));
                pg.setRedirect(true);
                return pg;
            }else{
                return null;
            }
        }else{
            return null;
        }
    }
    @future 
    public static void copyPermSet(Id u1, Id u2){
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        for (PermissionSetAssignment p : [Select Id,PermissionSetId FROM PermissionSetAssignment Where AssigneeId = : u1]){ 
            PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = p.PermissionSetId, AssigneeId = u2);
            permissionSetList.add(psa);
        }
        try{
        	upsert permissionSetList;
        }catch(Exception e){
            System.debug(e.getMessage());
        }
    }
    public pagereference cancel(){
        return new PageReference(String.format(UpDownGrade__c.getValues('UserLink').value__c,new List<String>{URL.getSalesforceBaseUrl().getHost(),usr.id}));
    }
}