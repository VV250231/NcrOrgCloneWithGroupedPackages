/*
* Created By : Saagar Kinja
* BA         : Haley Logan / Jenni Cosler
* This is apex controller class for Tableau Admin Page, created only for Sales Ops Team.
*/

public class Controller_Tableau_Admin_Page {
    
    @AuraEnabled
    public static List<STRING> checkaccess(){  
        system.debug('inside checkaccess component');
        List<STRING> returnlist = new List<STRING>();
        User currentuser = [Select id, Quicklook_ID__c from User where id =: UserInfo.getUserId() limit 1];
        
        List<ID> userids = new List<ID>();
        List<GroupMember> groupMembers=[Select Id, group.type,group.DeveloperName, UserOrGroupId From GroupMember where group.DeveloperName =:'TableauAdmins' ];
        for(GroupMember gm : groupMembers)
        {
            userids.add(gm.UserOrGroupId);
        }
        system.debug('$$$$$$$$$ userids.contains(currentuser.id) ++ '+userids);
        
        if(userids.contains(currentuser.id)){
            returnlist.add('TRUE');           
        }
        return returnlist ;
    }
    
    
    @AuraEnabled
    public static List<TableauUser__c> cgetusertable(){  
        return [Select id,TRole1UserName__c,TRole1__c, TRole2__c,TRole2UserName__c,TRole3__c,TRole3UserName__c,Name,IfSFDCUser__c,InteractorPublisher__c,IsActive__c,OwnershipAccess__c,RoleDeveloperName__c,RoleID__c,RoleLevelAccess__c,RoleName__c,SalesOrgAccess__c,TableauRLSQuery__c,UserName__c,UserQlookID__c from TableauUser__c limit 5] ;
    }
    
    @AuraEnabled
    public static List<Tableau__c> cgetroletable(){  
        return [Select Id,RoleName__c,RoleDeveloperName__c from Tableau__c limit 5]  ;
    }
    @AuraEnabled
    public static List<Tableau_SalesOrg__c> cgetsaleorgtable(){  
        return [Select Id,SalesOrg1__c,SalesOrg2__c,SalesOrg6__c from Tableau_SalesOrg__c where SalesOrg1__c !=null order by SalesOrg1__c limit 5]  ;
    }
    @AuraEnabled
    public static List<Tableau_SalesOrg__c> searchsalesorgg(String searchkey)
    {  
        system.debug('############# searchsalesorg :: '+searchkey);
        List<Tableau_SalesOrg__c> uselist = new List<Tableau_SalesOrg__c>();
        String srchKey=String.escapeSingleQuotes(searchkey);
        system.debug('srchKey### :'+srchKey);
        String newkey = '*'+srchKey+'*';
        string query ;
        system.debug('search with only key');
        query = 'Select Id,SalesOrg1__c,SalesOrg2__c,SalesOrg6__c from Tableau_SalesOrg__c  where SalesOrg1__c like \'%'+srchKey+'%\' order by Name ';
        uselist = Database.query(query);                 
        return uselist ;
        
    }
    @AuraEnabled
    public static TableauUser__c ctableauuserreadonly(){ 
        User currentuser = [Select id, Quicklook_ID__c from User where id =: UserInfo.getUserId() limit 1];
        TableauUser__c c =  [Select id,Name,IfSFDCUser__c,TRole1UserName__c,TRole1__c, TRole2__c,TRole2UserName__c,TRole3__c,TRole3UserName__c,InteractorPublisher__c,IsActive__c,OwnershipAccess__c,RoleDeveloperName__c,RoleID__c,RoleLevelAccess__c,RoleName__c,SalesOrgAccess__c,TableauRLSQuery__c,UserName__c,UserQlookID__c from TableauUser__c where UserQlookID__c =: currentuser.Quicklook_ID__c limit 1];
        system.debug('Inside contoller ctableauuserreadonly and returning this recsult :  :'+ c);
        return c ;
    }
    
    @AuraEnabled
    public static List<String> cgetroledetails(){  
        system.debug('inside apex controller cgetroledetails ######### ');
        List<String> retrunstring = new List<String>();
        User currentuser = [Select id, Quicklook_ID__c from User where id =: UserInfo.getUserId() limit 1];
        TableauUser__c c =  [Select id,TRole1UserName__c,TRole1__c, TRole2__c,TRole2UserName__c,TRole3__c,TRole3UserName__c from TableauUser__c where UserQlookID__c =: currentuser.Quicklook_ID__c limit 1];
        if(c.TRole1UserName__c != null){ retrunstring.add(c.TRole1UserName__c);}
        if(c.TRole2UserName__c != null){retrunstring.add(c.TRole2UserName__c);}
        if(c.TRole3UserName__c != null){retrunstring.add(c.TRole3UserName__c);}
        system.debug('returning the result as :#########: : '+retrunstring);
        return retrunstring ;
    }
    
    @AuraEnabled
    public static List<TableauUser__c> gettabuser(String searchkey)
    {  
        system.debug('inside load gettabuser component AND Searchkey is :: '+searchkey);
        List<TableauUser__c> uselist = new List<TableauUser__c>();
        String srchKey=String.escapeSingleQuotes(searchkey);
        system.debug('srchKey### :'+srchKey);
        String newkey = '*'+srchKey+'*';
        string query ;
        system.debug('search with only key');
        query = 'Select id,Name,IfSFDCUser__c,TRole1UserName__c,TRole1__c, TRole2__c,TRole2UserName__c,TRole3__c,TRole3UserName__c,InteractorPublisher__c,IsActive__c,OwnershipAccess__c,RoleDeveloperName__c,RoleID__c,RoleLevelAccess__c,RoleName__c,SalesOrgAccess__c,TableauRLSQuery__c,UserName__c,UserQlookID__c from TableauUser__c where UserQlookID__c like \'%'+srchKey+'%\' order by Name ';
        uselist = Database.query(query);                 
        return uselist ;
        
    }
    
    @AuraEnabled
    public static Boolean validateifuserexist(String searchkey)
    {  
        system.debug(' ############### inside load validateifuserexist component AND Searchkey is :: '+searchkey);
        List<TableauUser__c> uselist = new List<TableauUser__c>();
        String srchKey=String.escapeSingleQuotes(searchkey);
        system.debug('srchKey### :'+srchKey);
        String newkey = '*'+srchKey+'*';
        string query ;
        system.debug('search with only key');
        query = 'Select id,UserName__c,UserQlookID__c from TableauUser__c where UserQlookID__c like \'%'+srchKey+'%\' order by Name ';
        uselist = Database.query(query);  
        
        if(uselist.size() == 0){
            return true ;
        }
        else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static Boolean checkifuserisfdc(String searchkey)
    {  
        system.debug('########### checkifuserisfdc #######');
        List<User> usersWithSfdcLicense = [Select Id, Profile.UserLicense.LicenseDefinitionKey From User Where Profile.UserLicense.LicenseDefinitionKey = 'SFDC' AND Quicklook_ID__c =: searchkey AND IsActive=: true];
        system.debug('########### #######'+usersWithSfdcLicense);
        if(usersWithSfdcLicense != null){
            return true ;
        }
        else {
            return false;
        }
        
    }
    
    @AuraEnabled
    public static List<Tableau__c> getrolename(String searchkey)
    {  
        system.debug('inside load gettabuser component AND Searchkey is :: '+searchkey);
        List<Tableau__c> uselist = new List<Tableau__c>();
        String srchKey=String.escapeSingleQuotes(searchkey);
        system.debug('srchKey### :'+srchKey);
        String newkey = '*'+srchKey+'*';
        string query ;
        system.debug('search with only key');
        query = 'Select Id,RoleName__c,RoleDeveloperName__c from Tableau__c  where RoleName__c like \'%'+srchKey+'%\' order by RoleName__c ';
        uselist = Database.query(query);                 
        return uselist ;
        
    }
    
    @AuraEnabled
    public static TableauUser__c gettuserrecord(Id IDD)
    {  
        TableauUser__c t = [Select id,TRole1UserName__c,TRole1__c, TRole2__c,TRole2UserName__c,TRole3__c,TRole3UserName__c,Name,IfSFDCUser__c,InteractorPublisher__c,IsActive__c,OwnershipAccess__c,RoleDeveloperName__c,RoleID__c,RoleLevelAccess__c,RoleName__c,SalesOrgAccess__c,TableauRLSQuery__c,UserName__c,UserQlookID__c from TableauUser__c where id =: IDD ] ;
        system.debug('In Controller gettuserrecord here :: '+t);
        return t;
    }
    
    @AuraEnabled
    public static Boolean udpdatetabrecord(TableauUser__c tabrecord)
    {  
        system.debug('In Controller udpdatetabrecord here :: '+tabrecord);
        update tabrecord ;
        return true;
    }
    
    @AuraEnabled
    public static Boolean createtabrecord(TableauUser__c tabrecord)
    {  
        system.debug('In Controller createtabrecord with received Tableau Object :: '+tabrecord);
        TableauUser__c t= new TableauUser__c();
        t.UserName__c = tabrecord.UserName__c;
        t.UserQlookID__c = tabrecord.UserQlookID__c;
        t.IfSFDCUser__c = tabrecord.IfSFDCUser__c;
        t.IsActive__c = tabrecord.IsActive__c;
        t.OwnershipAccess__c = tabrecord.OwnershipAccess__c;
        t.RoleLevelAccess__c = tabrecord.RoleLevelAccess__c;
        t.SalesOrgAccess__c = tabrecord.SalesOrgAccess__c;
        t.InteractorPublisher__c = tabrecord.InteractorPublisher__c;
        t.TRole1__c = tabrecord.TRole1__c;
        t.TRole2__c = tabrecord.TRole2__c;
        t.TRole3__c = tabrecord.TRole3__c;
        insert t;
        return true;
    }
    
    @AuraEnabled
    public static Boolean createtabrecordd(String UserName,String UserQlookID,Boolean IfSFDCUser,Boolean IsActive,Boolean OwnershipAccess, Boolean RoleLevelAccess,Boolean SalesOrgAccess,String InteractorPublisher,Id TRole1, Id TRole2, Id TRole3)
    {  
        
        system.debug('inside controller : createtabrecordd ##');
        TableauUser__c t= new TableauUser__c();
        t.UserName__c = UserName;
        t.UserQlookID__c = UserQlookID;
        t.IfSFDCUser__c = IfSFDCUser;
        t.IsActive__c = IsActive;
        t.OwnershipAccess__c = OwnershipAccess;
        t.RoleLevelAccess__c = RoleLevelAccess;
        t.SalesOrgAccess__c = SalesOrgAccess;
        t.InteractorPublisher__c = InteractorPublisher;
        t.TRole1__c = TRole1;
        t.TRole2__c = TRole2;
        t.TRole3__c = TRole3;
        
        insert t;
        
        return true;
    }
    
    @AuraEnabled
    public static Boolean scriptgetnewroles(){  
        
        SET<ID> newroleids = new SET<ID>();
        for(TableauSubRoleIDs__c t : [Select id, RoleID__c from TableauSubRoleIDs__c] ){
            newroleids.add(t.RoleID__C);
        }
        List<TableauSubRoleIDs__c> subrolescript = new List<TableauSubRoleIDs__c>();
        List<UserRole> RoleList = new List<UserRole>([Select id from UserRole where id NOT IN: newroleids ]);
        
        for(UserRole t : RoleList ){
            TableauSubRoleIDs__c to = new TableauSubRoleIDs__c();
            to.RoleID__c = t.id ;
            subrolescript.add(to);
        }
        
        try {
            Database.insert(subrolescript,false) ;
            
        } catch(Exception e) {
            System.debug(e);
        }
        
        return true;
    }
    
    @AuraEnabled
    public static Boolean scriptupdatenewroles() {  
        SET<ID> newsubroleids = new SET<ID>();
        for(Tableau__c t : [Select id, RoleID__c from Tableau__c] ){ newsubroleids.add(t.RoleID__C);}
        List<Tableau__c> tqinsert = new List<Tableau__c>();
        List<TableauSubRoleIDs__c> subrolelist = new List<TableauSubRoleIDs__c>([Select id,RoleID__c from TableauSubRoleIDs__c where RoleID__c NOT IN: newsubroleids ]); 
        for(TableauSubRoleIDs__c t : subrolelist ){  Tableau__c to = new Tableau__c(); to.RoleID__c = t.RoleID__c ; tqinsert.add(to);  }
        try { Database.insert(tqinsert,false) ;} catch(Exception e) {System.debug(e);}
        return true;
    }
    
    @AuraEnabled
    public static Boolean scriptcreaterolelevelscript(){  
       Integer totalrecords =  [Select COUNT() from Tableau__c];
        List<Tableau__c> tableauuset = new List<Tableau__c>();
        try {Database.update([Select id from Tableau__c]) ;} catch(Exception e) {System.debug(e);}
       return true;
    }
    
    
    
}