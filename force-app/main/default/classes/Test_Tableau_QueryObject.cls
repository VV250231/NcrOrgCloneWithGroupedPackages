@isTest(SeeAllData=false)
public class Test_Tableau_QueryObject{
    
    /* ########################################################################################################## */ 
    public static String CRON_EXP = '0 0 0 15 8 ? 2023';
    
    @testSetup 
    static void create_tableau_Records(){
        
        Test.startTest();
        ID currentuserroleid =  UserInfo.getUserRoleId() ;
        
        //create tableau sub-roleid object object
        TableauSubRoleIDs__c tsrls = new TableauSubRoleIDs__c() ;
        tsrls.RoleID__c = currentuserroleid ;
        insert tsrls ;
        
        //create tableau rls query object
        Tableau__c trls = new Tableau__c() ;
        trls.RoleID__c = currentuserroleid ;
        insert trls ;
        //create tableau user object object
        TableauUser__c tableauuserobject = new TableauUser__c() ;
        tableauuserobject.UserQlookID__c = 'sk250817' ;
        tableauuserobject.InteractorPublisher__c = 'Interactor' ; 
        tableauuserobject.IfSFDCUser__c= True ;
        tableauuserobject.IsActive__c= True ;   
        tableauuserobject.TRole1__c = trls.id ;
        tableauuserobject.TRole2__c = trls.id ;
        tableauuserobject.TRole3__c = trls.id ;
        tableauuserobject.OwnershipAccess__c = true ;
        tableauuserobject.RoleLevelAccess__c = true ;
        tableauuserobject.SalesOrgAccess__c = true ;
        tableauuserobject.User18digitID__c = userInfo.getUserId() ;
        insert tableauuserobject ;
        
        //create tableau sub role id object
        Sales_Org__c salesorg = new Sales_Org__c(name = 'sk250817', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232');
        insert salesorg;
        Tableau_SalesOrg__c tsorls = new Tableau_SalesOrg__c();
        tsorls.SalesOrgID__c = salesorg.id ;
        insert tsorls;
    }
    @isTest 
    static void update_tableauRecords(){
        ID currentuserroleid =  UserInfo.getUserRoleId() ;
        ID SalesOrgId = [select id from Sales_Org__c where name=:'sk250817'].id ;
        TableauSubRoleIDs__c tsrls = [select id,RoleID__c from TableauSubRoleIDs__c where RoleID__c =: currentuserroleid];
        Tableau__c trls = [select id,RoleID__c from Tableau__c where RoleID__c =: currentuserroleid];
        TableauUser__c tableauuserobject = [select id,SalesOrgAccess__c from TableauUser__c  ];
        System.assertEquals(tableauuserobject.id!=null, true);
        Tableau_SalesOrg__c tsorls = [select id,SalesOrgID__c from Tableau_SalesOrg__c where SalesOrgID__c=: SalesOrgId];
        
        // update above objects statements
        tableauuserobject.SalesOrgAccess__c = false; 
        update tableauuserobject;
        update tsrls ;
        update trls ;
        update tsorls;

    }
    @isTest
    static void test_pageControllers(){
        
        ID currentuserroleid =  UserInfo.getUserRoleId() ;
        
        TableauSubRoleIDs__c tsrls = [select id from TableauSubRoleIDs__c where RoleID__c =: currentuserroleid];
        System.assertEquals(tsrls.id!=null, true);
        Tableau__c trls = [select id from Tableau__c where RoleID__c =: currentuserroleid];
        TableauUser__c tableauuserobject = [select id,SalesOrgAccess__c from TableauUser__c  ];
        // Tableau_SalesOrg__c tsorls = [select id,SalesOrgID__c from Tableau_SalesOrg__c where salesorg.id];
        
        
        Test.startTest();
        //test case for tableau admin screen
        Controller_Tableau_Admin_Page.checkaccess(); 
        Controller_Tableau_Admin_Page.cgetusertable(); 
        Controller_Tableau_Admin_Page.cgetroletable(); 
        Controller_Tableau_Admin_Page.cgetsaleorgtable(); 
        //Controller_Tableau_Admin_Page.ctableauuserreadonly();
        //Controller_Tableau_Admin_Page.cgetroledetails();
        Controller_Tableau_Admin_Page.searchsalesorgg('sk250817');
        Controller_Tableau_Admin_Page.gettabuser('sk250817'); 
        Controller_Tableau_Admin_Page.validateifuserexist('sk250817');
        Controller_Tableau_Admin_Page.validateifuserexist('sk250820');
        Controller_Tableau_Admin_Page.checkifuserisfdc('sk250817'); 
        Controller_Tableau_Admin_Page.checkifuserisfdc('sk250820'); 
        Controller_Tableau_Admin_Page.getrolename(''); 
        Controller_Tableau_Admin_Page.gettuserrecord(tableauuserobject.id); 
        Controller_Tableau_Admin_Page.udpdatetabrecord(tableauuserobject);
        Controller_Tableau_Admin_Page.createtabrecord(new TableauUser__c(UserQlookID__c = 'sk250819',InteractorPublisher__c = 'Interactor',IfSFDCUser__c= True,IsActive__c= True,RoleLevelAccess__c = true));
        Controller_Tableau_Admin_Page.createtabrecordd('sk250818','sk250818',false,false,true,true,true,'interactor',trls.id,trls.id,trls.id);
        
        List<STRING> st = new LIST<STRING>();st.add('sk250818');
        Controller_Tableau_Admin_Page_Batch.roleidset_updateroleidset();
        Controller_Tableau_Admin_Page_Batch.update_sub_role_id(st);
        //Controller_Tableau_Admin_Page_Batch.update_role_id(st);
        Controller_Tableau_Admin_Page_Batch.returnsize(st);
        Controller_Tableau_Admin_Page_Batch.updateallsubrole(st);
        Controller_Tableau_Admin_Page_Batch.updateallrole(st);
        
         //test method for executing the batch classes
        Tableau_Batch_GenScript oSCR = new Tableau_Batch_GenScript();
        Database.executeBatch(oSCR);
        
        
        Test.StopTest();
        
        
    }
    /* ########################################################################################################## */ 
    @isTest
    static void test_batches(){
        
        ID currentuserroleid =  UserInfo.getUserRoleId() ;
        
        TableauSubRoleIDs__c tsrls = [select id from TableauSubRoleIDs__c where RoleID__c =: currentuserroleid];
        Tableau__c trls = [select id from Tableau__c where RoleID__c =: currentuserroleid];
        
        TableauUser__c tableauuserobject = [select id,SalesOrgAccess__c from TableauUser__c];
        
     
        Test.startTest(); 
        String jobId = System.schedule('ScheduledApexTest',
                                       CRON_EXP, new Tableau_Scheduler()); 
     
        // test method for executing the batch classes
        Tableau_Batch_getNewRole nSCR = new Tableau_Batch_getNewRole();
        Database.executeBatch(nSCR,1);
       
        Test.StopTest();
        
        
        
    }
    /* ########################################################################################################## */   
    static testMethod void test_controller_tableau_uipage(){
        TableauWorkbookURL__c testobj =new TableauWorkbookURL__c ();
        
        testobj.TableauServerAddress__c = '';
        testobj.VisualforcePageURL__c = '';
        testobj.Workbook1Name__c = '';
        testobj.Workbook2Name__c = '';
        testobj.Workbook3Name__c = '';
        testobj.Workbook4Name__c = '';
        testobj.Workbook5Name__c = '';
        
        testobj.Workbook1URL__c = '';
        testobj.Workbook2URL__c = '';
        testobj.Workbook3URL__c = '';
        testobj.Workbook4URL__c = '';
        testobj.Workbook5URL__c = '';
       
        
        insert testobj;
        
        Test.startTest();
        
        PageReference myVfPage = Page.Tableau_Workbooks_HomePage;
         System.assertEquals(myVfPage!=Null, True);
        Test.setCurrentPage(myVfPage);
        System.currentPageReference().getParameters().put('id',testobj.id);
        Tableaupagecontroller testController = new Tableaupagecontroller();
        
        // test method for executing the batch classes
        Tableau_Batch_GenRoleId uSCR = new Tableau_Batch_GenRoleId();
        Database.executeBatch(uSCR);
        
        Test.StopTest();
        /* ########################################################################################################## */ 
    }
}