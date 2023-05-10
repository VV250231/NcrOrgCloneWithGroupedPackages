/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This trigger helper class updates the Sales Org Sharing Model depending on Sharing Rules defined in Salesforce on Sales Org Object.
*/
public with sharing class Tableau_getsalesorg_helperclass{
    
    /* ########################################################################################################## */
    public static void updatefields(List<Tableau_SalesOrg__c> triggernew){
        system.debug(' $############### updatefields ######### '+triggernew);
        SET<ID> RoleIDs = new SET<ID>();
        For(Tableau_SalesOrg__c  Tobject:triggernew){ 
            RoleIDs.add(Tobject.SalesOrgID__c);
        } 
        
        Map<ID, Sales_Org__c> salesorgmap =new Map<Id,Sales_Org__c>([select Id,Name,Hierarchy_6__c,Hierarchy_2__c,Hierarchy_1__c from Sales_Org__c where id IN :roleIds]);
        
         For(Tableau_SalesOrg__c  Tobject:triggernew){ 
             Tobject.SalesOrg6__c = salesorgmap.get(Tobject.SalesOrgID__c).Hierarchy_6__c;
             Tobject.SalesOrg2__c = salesorgmap.get(Tobject.SalesOrgID__c).Hierarchy_2__c;
             Tobject.SalesOrg1__c = salesorgmap.get(Tobject.SalesOrgID__c).Hierarchy_1__c;
        } 
       system.debug(' $############### updatefields ######### '+triggernew); 
    }
    /* ########################################################################################################## */
    public static void updatescript(List<Tableau_SalesOrg__c> triggernew){
        
        List<TableauUser__c> tabuser = new List<TableauUser__c>([Select id,User18digitID__c from TableauUser__c where User18digitID__c != null]);
        SET<ID> userid = new SET<ID>(); 
        
        if(tabuser.size() > 0){
            for(TableauUser__c t : tabuser){ userid.add(t.user18digitID__c);}
        }
        if(userid.size() > 0){
            getsalesorgmap(userid,tabuser,triggernew);
        }
        
    }
    /* ########################################################################################################## */
    
    public static void getsalesorgmap(SET<ID> userid,List<TableauUser__c> tabuser,List<Tableau_SalesOrg__c> triggernew){
        
        Set<ID> reccuserids =new Set<ID>();
        MAP<ID,SET<ID>> result = new MAP<ID,SET<ID>>();
        List<User> userlist = new List<User>([Select Id,Quicklook_ID__c, Profile.UserLicense.LicenseDefinitionKey From User Where Profile.UserLicense.LicenseDefinitionKey = 'SFDC' AND IsActive=: true]);
        for( user u : userlist){
            reccuserids.add(u.id);
        }
        
        List<Sales_Org__share> salesorgshare = new List<Sales_Org__share>([Select UserOrGroupId, AccessLevel,ParentId  from Sales_Org__share where UserOrGroupId IN: userid]);
        
        for(Tableau_SalesOrg__c t : triggernew){
            result.put(t.SalesOrgID__c,new SET<ID>{});
        }
        for(Sales_Org__Share s : salesorgshare){  
            // system.debug(' ################## ##################### '+s.ParentId);
            if(result.keyset().contains(s.ParentId)){
                Set<id> addParent = result.get(s.ParentId);
                addParent.add(s.UserOrGroupId);
                result.put(s.ParentId,addParent);
            }
        }
        system.debug(' ################## ##################### '+result);
        
        if(result.size() > 0 ){
            getuserset(result,userlist,triggernew);
        }
        
    }
    
    /* ########################################################################################################## */
    
    public static void getuserset(MAP<ID,SET<ID>> mapr, List<User> uss,List<Tableau_SalesOrg__c> triggernew){
        MAP<ID,SET<STRING>> USERSET1 = new MAP<ID,SET<STRING>>();
        
        for(Id i : mapr.keyset()){
            USERSET1.put(i,new SET<STRING>{'sk250817'}); 
        }
        for(ID idt : mapr.keyset() ){
            for(User u : uss){ 
                if(USERSET1.keyset().contains(idt) && mapr.get(idt).contains(u.id)){
                    SET<STRING> t = new SET<STRING>();
                    t.addall(USERSET1.get(idt));
                    t.add(u.Quicklook_ID__c);
                    USERSET1.put(idt,t);
                }
            }
        }
        
        if(USERSET1.size() >0){
            assignuserset(USERSET1,triggernew);
        }
        system.debug(' $############### getuserset ######### '+USERSET1);
    }
    /* ########################################################################################################## */
    public static void assignuserset(MAP<ID,SET<STRING>> USERSET1,List<Tableau_SalesOrg__c> triggernew){
        
        For(Tableau_SalesOrg__c Tobject : triggernew){
            
            STRING value = 'sk250817';
            for(STRING s : USERSET1.get(tobject.SalesOrgID__c)) {
                value = value + ','+s;
            }
            Tobject.SalesOrgName__c= USERSET1.get(tobject.SalesOrgID__c).size()+'';
            Tobject.UsersList__c  = value;
            
        }
        
    }
    /* ########################################################################################################## */
}