/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class updates the Role Sets depending on Role level Hiererchy in Salesforce.
*/
public class Tableau_getsubroleid_helperclass{
    /* ########################################################################################################## */ 
    
    public static void updatefields(List<TableauSubRoleIDs__c> triggernew){
        SET<ID> RoleIDs = new SET<ID>();
        For(TableauSubRoleIDs__c Tobject:triggernew){ 
            RoleIDs.add(Tobject.RoleID__c);
        } 
        
        Map<ID, UserRole> UserRoleobjectMAP =new Map<Id,UserRole>([select Id,DeveloperName,Name from UserRole where id IN :roleIds]);
        
        For(TableauSubRoleIDs__c Tobject:triggernew){ 
            if(UserRoleobjectMAP.containskey(Tobject.RoleID__c) && !UserRoleobjectMAP.isEmpty() ){
                Tobject.TextName__c = UserRoleobjectMAP.get(Tobject.RoleID__c).Name ;
                Tobject.DeveloperName__c = UserRoleobjectMAP.get(Tobject.RoleID__c).DeveloperName ;
            }
        }        
    }
    
    /* ########################################################################################################## */ 
    
    public static void updatescript(List<TableauSubRoleIDs__c> triggernew){
        
        SET<ID> RoleIDs = new SET<ID>();
        SET<STRING> tableauserqlookid = new SET<STRING>();
        MAP<ID,SET<ID>> currentRoleIds = new MAP<ID,SET<ID>>();
        Map<id,STRING> subrolemap = new Map<id,STRING>();
        
        system.debug('##########START############START############START###########START##################################### ');
        
        
        For(TableauSubRoleIDs__c tobject:triggernew){ 
            RoleIDs.add(tobject.RoleID__c);
        }
        
        For(TableauUser__c r : [Select id, UserQlookID__c  from TableauUser__c] ){
            tableauserqlookid.add(r.UserQlookID__c);
        }
        
        currentRoleIds = getAllSubRoleIds(RoleIDs, new Map<id,SET<ID>>());
        //system.debug('##################### Map process size is :: ' + currentRoleIds.size());
        
        For(TableauSubRoleIDs__c tobject : triggernew){ 
            if(!currentRoleIds.isEmpty() && !String.isBlank(tobject.RoleID__c) && currentRoleIds.containskey(tobject.RoleID__c)){
                tobject.TotalReportingRoles__c = currentRoleIds.get(tobject.RoleID__c).size();
                //Changes done by Yogesh - related to Story EBA_SF-1919
                //STRING value = '00E70000000zoanEAA';
                STRING value = NSCCommonInfoUtil.getIdOf('Tableau_Id');
                //End Changes done by Yogesh
                for(STRING s : currentRoleIds.get(tobject.RoleID__c)) {
                    
                    value = value + ','+s;
                }
                Tobject.SubRoleID__c = value;
            }
        } 
        
        system.debug('#########END###############END##############END##########END#########END###################### ');
        
        
        
    }
    
    /* ############################################################################### */ 
    private static MAP<ID,SET<ID>> getAllSubRoleIds(Set<ID> reccCurrentRoleIds, MAP<ID,SET<ID>> currentRoleIds) {
        Set<ID> reccCurrentRoleIdsTemp=new Set<ID>();
        if(currentRoleIds.keyset().isEmpty()){
            for(Id id:reccCurrentRoleIds){
                currentRoleIds.put(id, new Set<Id>{id}); 
            }
        }
        for(UserRole usrRole :[Select Id,ParentRoleID from UserRole where Id IN :reccCurrentRoleIds AND ParentRoleID != null]){
            for(Id ids: currentRoleIds.keySet()){
                if(currentRoleIds.get(ids).contains(usrRole.id)){
                    Set<id> addParent=currentRoleIds.get(ids);
                    addParent.add(usrRole.ParentRoleID);
                    currentRoleIds.put(ids,addParent);
                    reccCurrentRoleIdsTemp.add(usrRole.ParentRoleID);
                }
            }
            
        }
        if(reccCurrentRoleIdsTemp.size() > 0){
            currentRoleIds.putAll(getAllSubRoleIds(reccCurrentRoleIdsTemp,currentRoleIds));
        }
        
        
        return currentRoleIds;
        
    }   
    /* ############################################################################### */  
    /* ############################################################################### 
    private static MAP<ID,STRING> getallusers(Set<STRING> qlookids, MAP<ID,SET<ID>> allroleids,SET<ID> tempvalue) {
        
        MAP<ID,STRING> roleids = new MAP<ID,STRING>();
        SET<ID> roleidd = new SET<ID>();
        List<USER> userlist = new List<USER>([Select id,userrole.id,Quicklook_ID__c from User Quicklook_ID__c WHERE Quicklook_ID__c IN: qlookids]);
        STRING addParent = 'sk250817';
        STRING t ;
        roleidd = allroleids.keyset();
        SET<ID> tempvalue1 = new SET<ID>();
        if(tempvalue.isEmpty()){
            for(Id id : roleidd){
                roleids.put(id, t); 
            }
        }
        
        For(User u : userlist){
            for(Id ids: roleidd){
                addParent = addParent + ',' + u.Quicklook_ID__c;
                //addParent.add(u.Quicklook_ID__c);
                roleids.put(ids,addParent);
                tempvalue1.add(u.userrole.id);
                system.debug('##################### I am here with list of receiveuserresultstest Role... size is :: ' + addParent);
            }
        }
        if(tempvalue.size()>0){ 
            roleids.putAll(getallusers(qlookids,allroleids,tempvalue1));
        }
        
        return roleids;
    }
*/
    
}