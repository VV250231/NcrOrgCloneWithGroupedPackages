/*
##################################################################################################
# Project Name..........: Account Point Of Contact(APOC)
# File............................: APOCRolesController.cls                                                        
# Created by................: Varsha Pal                                                                   
# Created Date...........: 02/26/2020 (MM/DD/YYYY)                                                                             
# Last Modified by......:  Varsha Pal
# Last Modified Date..: 03/07/2020 (MM/DD/YYYY)
# Description...............: This class is used for fetching the data in APOC tab in community
# JIRA Story - #EBA_SF-1906(ETB: APOC users not able to use Community if their Account name has @) 
# test class -APOCRolesControllerTest
##################################################################################################
*/
public without sharing class APOCRolesController {
    @auraEnabled
    public static List<String> getAllRoleNames(){
        List<String> roles = new List<String>();
        for( Schema.PicklistEntry val : Schema.getGlobalDescribe().get('ASM_Role_Hierarchy__c').getDescribe().fields.getMap().get('Role_Name__c').getDescribe().getPicklistValues()){
            roles.add(val.getValue());
        }   
        return roles;
    }
    @AuraEnabled
    public static string editRecord( List<ASM_Role_Hierarchy__c> roleL){
        for(ASM_Role_Hierarchy__c obj : roleL){
            if(String.isBlank(obj.External_Id__c)){
            	obj.External_Id__c = obj.Role_Name__c +obj.Master__c+  obj.QuickLook_ID__c;
            }
        }
        try{
          	APOC_MassUpdateAllRolesHandler.isInsertFromUI = true;
        	upsert roleL External_Id__c;
            return null;
        }
        catch(Exception ex){
            String res;
            if(ex.getMessage().contains('PO')){
                res = 'Please assign PO/Billing Person as it is mandatory.';
            }else if(ex.getMessage().containsIgnoreCase('duplicate')){
                res = 'Same Role is assigned to Same user multiple times, Remove duplicate entries.';
            }
            else{
                res = ex.getMessage().split(',')[1];
            }
            return res;
        }       
    }
    
    @AuraEnabled
    public static void editRecordBulkData(List<ASM_Role_Hierarchy__c> rolestoDel, List<ASM_Role_Hierarchy__c> rolesToAdd){        
        deleteRecord(rolestoDel);
        APOC_MassUpdateAllRolesHandler.isInsertFromUI = true;
        Database.insert(rolesToAdd,false);
    }
     @AuraEnabled
    public static void deleteRecord(List<ASM_Role_Hierarchy__c> roles ){
        Database.delete(roles, false);
    }

    @AuraEnabled
    public static List<ListView> getListViews() {
        return [SELECT Id, Name FROM ListView WHERE SobjectType = 'ASM_Role_Hierarchy__c' and Name='All'];
    }
    @auraEnabled
    public static List<ResultWrapper> getAPOCRcrd(Id accId,boolean allrole){
        String qlid = [Select id,quicklook_id__c from user where id=:userinfo.getUserId()].quicklook_id__c;
        Set<String> accS = new Set<String>();
        Map<Id,ASM_Role_Hierarchy__c> accNameM = new Map<Id,ASM_Role_Hierarchy__c>();//#EBA_SF-1906 changes
        List<ASM_Role_Hierarchy__c> roles = new List<ASM_Role_Hierarchy__c>();
    	for(ASM_Role_Hierarchy__c ar:[select id,Account__c,Master_Number__c,account__r.Name,Role_User_Qlook_Id__c,user_name__c,Role_User_Name__c,Role_Name__c,External_Id__c,lastmodifieddate,NCR_Employee_Detail__c from ASM_Role_Hierarchy__c where Account__c =:accId]){
            if(allrole){
                if(ar.Account__c!=null){ 
                    //accNameM.put(ar.Account__c,ar.account__r.Name+'@'+ar.lastmodifieddate);
                    accNameM.put(ar.Account__c,ar);//#EBA_SF-1906 changes
                    accS.add(ar.Account__c+','+ar.Master_Number__c);
                    roles.add(ar);
                }
            }else{
                if(ar.Role_User_Qlook_Id__c== qlid){//changed by Varsha
                    //accNameM.put(ar.Account__c,ar.account__r.Name+'@'+ar.lastmodifieddate);
                    accNameM.put(ar.Account__c,ar);//#EBA_SF-1906 changes
                    accS.add(ar.Account__c+','+ar.Master_Number__c);
                }
                roles.add(ar);
            }
        }
        return createWrapper(roles,accS,accNameM);
    }
    @auraEnabled
    public static List<ResultWrapper> getAPOCList(String searchString){  
        String qlid = [Select id,quicklook_id__c from user where id=:userinfo.getUserId()].quicklook_id__c;
        Set<String> accS = new Set<String>();
        Map<Id,ASM_Role_Hierarchy__c> accNameM = new Map<Id,ASM_Role_Hierarchy__c>();//#EBA_SF-1906 changes
        List<ASM_Role_Hierarchy__c> roles = new List<ASM_Role_Hierarchy__c>();
        if(!String.isBlank(searchString) && searchString.length() > 0){
           for(ASM_Role_Hierarchy__c apocrole:[select id,Account__c,Master_Number__c,account__r.Name,
                                                Role_User_Qlook_Id__c,User_name__c,Role_User_Name__c,Role_Name__c,
                                                External_Id__c,lastmodifieddate,NCR_Employee_Detail__c from ASM_Role_Hierarchy__c where 
                                                Role_User_Qlook_Id__c=:qlid and 
                                                (Master_Number__c  LIKE :(searchString + '%') or account__r.Name LIKE :(searchString + '%')) limit 1000]){
                if(apocrole.Account__c!=null){ 
                    //accNameM.put(apocrole.Account__c,apocrole.account__r.Name+'@'+apocrole.LastModifiedDate);
                    accNameM.put(apocrole.Account__c,apocrole);//#EBA_SF-1906 changes
                    accS.add(apocrole.Account__c+','+apocrole.Master_Number__c);
                    roles.add(apocrole);
                }
            }  
        }   
        
        else{
            for(ASM_Role_Hierarchy__c apocrole:[select id,Account__c,Master_Number__c,account__r.Name,
                                                Role_User_Qlook_Id__c,User_name__c,Role_User_Name__c,Role_Name__c,
                                                External_Id__c,lastmodifieddate,NCR_Employee_Detail__c from ASM_Role_Hierarchy__c where 
                                                Role_User_Qlook_Id__c=:qlid limit 1000])
            {               
                if(apocrole.Account__c!=null){
                    //accNameM.put(apocrole.Account__c,apocrole.account__r.Name+'@'+apocrole.LastModifiedDate);
                     accNameM.put(apocrole.Account__c,apocrole);//#EBA_SF-1906 changes
                    accS.add(apocrole.Account__c+','+apocrole.Master_Number__c);
                    roles.add(apocrole);
                }
            }  
    	}
        
        for(ASM_Role_Hierarchy__c apocrole:[select id,Account__c,Account__r.Name,Master_Number__c,
                                            Role_User_Qlook_Id__c,User_name__c,Role_User_Name__c,
                                            Role_Name__c,External_Id__c,lastmodifieddate,NCR_Employee_Detail__c from ASM_Role_Hierarchy__c 
                                            where Account__c in:accNameM.keyset() 
                                            and NCR_Employee_Detail__c!=null and Role_User_Qlook_Id__c!=:qlid and id not in:roles limit 1000]){
            roles.add(apocrole);
        }  
        return createWrapper(roles,accS,accNameM);
    }
    private static List<ResultWrapper> createWrapper(List<ASM_Role_Hierarchy__c> roles,Set<String> accS,Map<Id,ASM_Role_Hierarchy__c> accNameM){
        Map<String,List<Role>> poMap = new Map<String,List<Role>>();
        Map<String,List<Role>> caMap = new Map<String,List<Role>>();
        Map<String,List<Role>> asmMap = new Map<String,List<Role>>();
        Map<String,List<Role>> otherMap = new Map<String,List<Role>>();
        for(ASM_Role_Hierarchy__c ar:roles){
            System.debug('roles---->'+roles);
    		Role rol = new Role();
            rol.UserName = ar.user_name__c;
            rol.role = ar.Role_Name__c;
            rol.UserId = ar.NCR_Employee_Detail__c;//Change for EBA_SF-1263 by Varsha
            rol.QuicklookID = ar.Role_User_Qlook_Id__c;
            rol.Id = ar.Id;
            rol.ExtId = ar.External_Id__c;
            switch on rol.role {
                when 'PO/Billing Person' {
                    if(!poMap.containskey(ar.Account__c+','+ar.Master_Number__c)){
                        poMap.put(ar.Account__c+','+ar.Master_Number__c,new List<Role>{rol});
                    }
                    else{
                        poMap.get(ar.Account__c+','+ar.Master_Number__c).add(rol);   
                    }
                }
                when 'Customer Advocate' {
                    if(!caMap.containskey(ar.Account__c+','+ar.Master_Number__c)){
                        caMap.put(ar.Account__c+','+ar.Master_Number__c,new List<Role>{rol});
                    }
                    else{
                        caMap.get(ar.Account__c+','+ar.Master_Number__c).add(rol);   
                    }
                }
                when 'Account Support Manager'{
                    if(!asmMap.containskey(ar.Account__c+','+ar.Master_Number__c)){
                        asmMap.put(ar.Account__c+','+ar.Master_Number__c,new List<Role>{rol});
                    }
                    else{
                        asmMap.get(ar.Account__c+','+ar.Master_Number__c).add(rol);   
                    }
                }
                when else {
                    if(!otherMap.containskey(ar.Account__c+','+ar.Master_Number__c)){
                        otherMap.put(ar.Account__c+','+ar.Master_Number__c,new List<Role>{rol});
                    }
                    else{
                        otherMap.get(ar.Account__c+','+ar.Master_Number__c).add(rol);   
                    }
                }
            }
        }
        List<ResultWrapper> rslt = new List<ResultWrapper>();
        for(String accR: accS){
            ResultWrapper wrap = new ResultWrapper();
            wrap.accountId = accR.split(',')[0];
            wrap.master = accR.split(',')[1];
            if(accNameM.get(accR.split(',')[0])!=null){
               // wrap.accountName = accNameM.get(accR.split(',')[0]).split('@')[0];
                //wrap.chngDate = DateTime.valueOf(accNameM.get(accR.split(',')[0]).split('@')[1]);
                wrap.accountName = accNameM.get(accR.split(',')[0]).Account__r.Name;//#EBA_SF-1906 changes
                wrap.chngDate = DateTime.valueOf(accNameM.get(accR.split(',')[0]).lastmodifieddate);
            }
            if(poMap.containskey(accR)){
                wrap.poroles = poMap.get(accR);
            }
            if(caMap.containskey(accR)){
                wrap.caroles = caMap.get(accR);
            }
            if(asmMap.containskey(accR)){
                wrap.asmroles = asmMap.get(accR);
            }
            if(otherMap.containskey(accR)){
                wrap.otherRoles = otherMap.get(accR);
            }
            wrap.isChecked = false;
            rslt.add(wrap);
        }
        return rslt;
   	}  
    @auraEnabled
    public static ASM_Role_Hierarchy__c getselRec(String master){
        try{
       	return [select id,Master__c from ASM_Role_Hierarchy__c where Master__c=:master limit 1];
        }catch(Exception e){
            return null;
        }
    }
    @auraEnabled
    public static string getUserData(String asmQID,String PoQID, String CAQID){
        List<User> userObj = new List<User>();
        List<WrapperUser> wrapUserList = new List<WrapperUser>();
        userObj =[select Id,Quicklook_ID__c,Phone,Email,Name from User where (Quicklook_ID__c=:asmQID or Quicklook_ID__c=:PoQID or Quicklook_ID__c=:CAQID) AND Quicklook_ID__c!=null];
        
        for(User s : userObj){
            WrapperUser obj = new WrapperUser();
            obj.objName = 'User';
            obj.text = s.Name;
            obj.ObjRecord = s;
            wrapUserList.add(obj);
        }
        
        return JSON.serialize(wrapUserList) ;
    }
    @auraEnabled
    public static List<ASM_Role_Hierarchy__c> fetchRolesWithMCN(String masterNumbers,String roleName){
    	Set<string> masterNumberSet = (Set<string>) JSON.deserialize(masterNumbers, Type.forName('Set<string>'));
        return [Select id,Role_User_Qlook_Id__c,External_Id__c,Master__c,Role_Name__c from ASM_Role_Hierarchy__c where Account__r.Master_Customer_Number__c in :masterNumberSet and Role_Name__c =: roleName] ;
    }
    
    public class WrapperUser{
        public String objName {get;set;}
        public String text{get;set;}
        public Object ObjRecord{get;set;}
    }
    
    public class ResultWrapper{
        @auraEnabled public Id accountId{get;set;}
        @auraEnabled public String accountName{get;set;}
        @auraEnabled public String master{get;set;}
        @auraEnabled public List<Role> asmroles{get;set;}
        @auraEnabled public List<Role> caroles{get;set;}
        @auraEnabled public List<Role> poroles{get;set;}
        @auraEnabled public List<Role> otherRoles{get;set;}
        @auraEnabled public DateTime chngDate{get;set;}
        @auraEnabled public Boolean isChecked{get;set;}
    }
    public class Role{
        @auraEnabled public String UserName{get;set;}
        @auraEnabled public String Role{get;set;}
        @auraEnabled public Id UserId{get;set;}
        @auraEnabled public String QuicklookID{get;set;}
        @auraEnabled public String Id{get;set;} 
        @auraEnabled public String ExtId{get;set;} 
    }
}