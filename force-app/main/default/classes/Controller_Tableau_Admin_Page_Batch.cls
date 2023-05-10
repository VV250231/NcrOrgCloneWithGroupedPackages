/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This is apex controller class for Tableau Admin Page, created only for Sales Ops Team.
*/

public class Controller_Tableau_Admin_Page_Batch {
    
    @AuraEnabled
    public static batchstatuswrapper roleidset_updateroleidset() {  
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        List<STRING> subrlsid = new List<STRING>(); List<STRING> rlsid = new List<STRING>();
        for(TableauSubRoleIDs__c t : [Select id,RoleID__c from TableauSubRoleIDs__c limit 49000]){
            subrlsid.add(t.RoleID__c); 
        }
        for(Tableau__c t : [Select id,RoleID__c from Tableau__c limit 49000]){
            rlsid.add(t.RoleID__c); 
        }
        
        MAP<ID, UserRole> rolelist1 = new MAP<ID, UserRole>([Select id from UserRole where id NOT IN: subrlsid]);
        MAP<ID, UserRole> rolelist2 = new MAP<ID, UserRole>([Select id from UserRole where id NOT IN: rlsid]);
        retrunresult.allvalue1 = rolelist1.size();
        retrunresult.allvalue2 = rolelist2.size();
        retrunresult.currentuserlist1 = rolelist1.keyset();
        retrunresult.currentuserlist2 = rolelist2.keyset();
        return retrunresult;
        
    } 
    @AuraEnabled
    public static batchstatuswrapper update_sub_role_id(List<STRING> subroleid) {  
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        List<TableauSubRoleIDs__c> sublist = new List<TableauSubRoleIDs__c>();
        for(STRING s : subroleid){
            TableauSubRoleIDs__c sub = new TableauSubRoleIDs__c();
            sub.RoleID__c = s;
            sublist.add(sub);
            
        }
        if(sublist.size()>0){
            try {
                Database.insert(sublist,false) ;
                retrunresult.allvalue1 = 1 ;
            } catch(Exception e) {
                System.debug(e);
                retrunresult.allvalue1 = 0 ;
                retrunresult.errors = e+'' ;
            }
            
        }
        retrunresult.receivedlist1 = subroleid;
        return retrunresult;
        
    } 
    @AuraEnabled
    public static batchstatuswrapper update_role_id(List<STRING> subroleid) {  
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        List<Tableau__c> sublist = new List<Tableau__c>();
        for(STRING s : subroleid){
            Tableau__c sub = new Tableau__c();
            sub.RoleID__c = s;
            sublist.add(sub);
            
        }
        if(sublist.size()>0){
            try {
                Database.insert(sublist,false) ;
                retrunresult.allvalue1 = 1 ;
            } catch(Exception e) {
                System.debug(e);
                retrunresult.allvalue1 = 0 ;
                retrunresult.errors = e+'' ;
            }
            
        }
        retrunresult.receivedlist1 = subroleid;
        return retrunresult;
        
    } 
    @AuraEnabled
    public static batchstatuswrapper returnsize(List<STRING> subroleid) {
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        retrunresult.allvalue1 = [Select count() from TableauSubRoleIDs__c limit 49000 ] ;
        retrunresult.allvalue2 = [Select count() from Tableau__c limit 49000 ] ;
        
        return retrunresult;
        
    } 
    @AuraEnabled
    public static batchstatuswrapper updateallsubrole(List<STRING> subroleid) {  
        system.debug(' #### updateallsubrole ###'+ subroleid.size());
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        List<String> sentrolids = new List<String>() ;
        List<TableauSubRoleIDs__c> sublist = new List<TableauSubRoleIDs__c>([Select id, Roleid__c from TableauSubRoleIDs__c where Roleid__c  NOT IN: subroleid order by name LIMIT 100]);
        for(TableauSubRoleIDs__c tb : sublist){
            sentrolids.add(tb.Roleid__c);
        }
        
        if(sublist.size()>0){
            try {
                Database.update([Select id, Roleid__c from TableauSubRoleIDs__c where Roleid__c  NOT IN: subroleid LIMIT 100],false) ;
                retrunresult.allvalue1 = 1 ;
            } catch(Exception e) {
                System.debug(e);
                retrunresult.allvalue1 = 0 ;
                retrunresult.errors = e+'' ;
            }
            
        }
        retrunresult.allvalue2 = [Select count() from TableauSubRoleIDs__c limit 49000 ] ;
        subroleid.addall(sentrolids);
        retrunresult.receivedlist1 = subroleid;
        return retrunresult;
        
    } 
    @AuraEnabled
    public static batchstatuswrapper updateallrole(List<STRING> subroleid) {  
        system.debug(' #### updateallsubrole ###'+ subroleid.size());
        batchstatuswrapper retrunresult = new batchstatuswrapper();
        List<String> sentrolids = new List<String>() ;
        List<Tableau__c> sublist = new List<Tableau__c>([Select id, Roleid__c from Tableau__c where Roleid__c  NOT IN: subroleid order by name LIMIT 100]);
        // system.debug(sublist);
        for(Tableau__c tb : sublist){
            sentrolids.add(tb.Roleid__c);
        }
        
        if(sublist.size()>0){
            try {
                Database.update([Select id, Roleid__c from Tableau__c where Roleid__c  NOT IN: subroleid LIMIT 100],false) ;
                retrunresult.allvalue1 = 1 ;
            } catch(Exception e) {
                System.debug(e);
                retrunresult.allvalue1 = 0 ;
                retrunresult.errors = e+'' ;
            }
            
        }
        retrunresult.allvalue2 = [Select count() from Tableau__c limit 49000 ] ;
        subroleid.addall(sentrolids);
        retrunresult.receivedlist2 = subroleid;
        return retrunresult;
        
    } 
    public class batchstatuswrapper{
        @AuraEnabled
        public Integer allvalue1 {get; set;}
        @AuraEnabled
        public Integer allvalue2 {get; set;}
        @AuraEnabled
        public SET<ID> currentuserlist1{get;set;}
        @AuraEnabled
        public SET<ID> currentuserlist2{get;set;}
        @AuraEnabled
        public List<String> receivedlist1{get;set;}
        @AuraEnabled
        public List<String> receivedlist2{get;set;}
        @AuraEnabled
        public String errors{get;set;}
    }
    
}