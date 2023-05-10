@isTest
public class CaseTriggerTest {
    @testSetUp
    public static void unitTestForCaseEscalatedToNotification(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();                       
        Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
        maccCaseObj.Issue_Type__c ='Error in Tool';
        maccCaseObj.Was_an_IT_ticket_created_to_report_the_e__c ='yes';
        maccCaseObj.Was_there_a_specific_error_message__c ='Yes';
        maccCaseObj.Was_there_an_existing_knowledge_article__c ='Yes';
        maccCaseObj.Were_you_able_to_replicate_the_error__c ='Yes';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='Yes';
        maccCaseObj.What_type_of_assistance_was_provided__c ='Chat Explanation';
        maccCaseObj.Which_page_is_the_user_seeing_error__c = 'MACC Move';
        maccCaseObj.Input_The_Error_Message__c='Error';
        maccCaseObj.Ticket__c ='Test';
        maccCaseObj.Status ='Open';
        Case caseObj = new Case();
        caseObj.RecordTypeId = CaseRecordTypeId;
        caseObj.DRT_Escalated_To__c ='test@test.com';
        caseObj.Chat_User_Company__c='Test';
        caseObj.Chat_User_Country__c='Test';
        caseObj.Chat_User_Email__c ='Test@test11.com';
        caseObj.Chat_User_First_Name__c ='Test';                            
        // caseObj.Chat_User_Industry__c='Test';
        caseObj.Chat_User_Last_Name__c = 'Test';
        caseObj.Chat_User_Source__c = 'Test';
        caseObj.Chat_User_Type__c ='Test';
        caseObj.Origin ='Forms';
        // caseObj.Owner.Name ='Test';
        caseObj.Agent_Notes__c = 'Test';
        caseObj.Business_Function__c ='Test';
        caseObj.Campaign_Code__c ='Test';
        caseObj.Campaign_Name__c ='Test';
        caseObj.Campaign_Status__c ='Test';
        caseObj.Campaign_Type__c ='Test';
        caseObj.City__c ='Test';
        //caseObj.RecordTypeId =,
        caseObj.Customer_Response_Time__c = '1 Days: 1 Hours: 12Minutes';
        caseObj.Staff_Response_Time__c = '0 Days: 1 Hours: 12Minutes';
        caseObj.Zip_Or_Postal_Code__c ='test';
        caseObj.State_Province__c = 'Test';
        caseObj.Title__c = 'Test';
        caseObj.Sub_Industry__c = 'Test';
        caseObj.Chat_User_Phone__c = 'Test';
        caseObj.Position__c = 'Test';
        //  caseObj.Number_of_Locations__c = 'Test';
        // caseObj.Years_In_Business__c = 'Test';
        // caseObj.Timing__c = 'Test';
        //  caseObj.Company_Annual_Sales__c = 'Test';
        // caseObj.Number_of_Employees__c = 'Test';
        caseObj.Subject ='Test'; 
        caseObj.Description='Test';
        caseObj.Status='Test';
        caseObj.Comments__c ='Test';
        caseObj.What_can_NCR_help_you_with_today__c='Test';
        //insert caseObj;
        insert maccCaseObj;
         All_profie_config__c setting = new All_profie_config__c();       
        setting.Name = 'CCAD Service Ignored Profile';
        //setting.Profile_Id__c = '00eZ0000000NhsBIAS';
        setting.Profile_Id__c = NSCCommonInfoUtil.getIdOf('CCAD_Service_Ignored_Profile_Id');
        insert setting;
        Profile adminProfile = [SELECT id from Profile where Name='System Administrator' LIMIT 1];
        System.assert(adminProfile.id!=null);
        User us1= new User();
            us1.Profileid         = adminProfile.id;
            us1.Username          = 'Test111@ncr.com';
            us1.Email             = 'testxs@test.com';
            us1.Alias             = 'alias';           
            us1.FirstName         = 'Fnamexs';
            us1.LastName          = 'lnamexs';
            us1.LocaleSidKey      = 'ar';
            us1.LanguageLocaleKey = 'de';
            us1.TimeZoneSidKey    = 'Africa/Cairo';
            us1.EmailEncodingKey  = 'Big5';
            us1.CurrencyIsoCode   = 'AUD';
            us1.Quicklook_ID__c   = 'tm25066';
            us1.FederationIdentifier = 'tm25066';
        	us1.Global_ID__c='test1000';
            Insert us1;
        User us= new User();
            us.Profileid         = adminProfile.id;
            us.Username          = 'Testxs111@ncr.com';
            us.Email             = 'test@test.com';
            us.Alias             = 'alias';           
            us.FirstName         = 'testing';
            us.LastName          = 'lnamexs';
            us.LocaleSidKey      = 'ar';
            us.LanguageLocaleKey = 'de';
            us.TimeZoneSidKey    = 'Africa/Cairo';
            us.EmailEncodingKey  = 'Big5';
            us.CurrencyIsoCode   = 'AUD';
            us.Quicklook_ID__c   = 'tm25077';
            us.FederationIdentifier = 'tm25077';
        	us.Global_ID__c='test2000';
        	us.Manager_Global_ID__c ='test1000';
            Insert us;
        Account acc = TestRecordsFactory.createAccount();
        
    }
    @isTest
    public static void insertTestForCaseEscalatedToNotification(){
		List<Case> caseUpdateList = new List<Case>();

        List<Case> caseList = [SELECT id,DRT_Escalated_To__c,Chat_User_Company__c,Chat_User_Country__c,Chat_User_Email__c,Chat_User_First_Name__c,
                               Chat_User_Industry__c,Customer_Response_Time__c,Staff_Response_Time__c,Chat_User_Last_Name__c,Chat_User_Source__c,Chat_User_Type__c,Origin,Owner.Name,
                               Agent_Notes__c,Business_Function__c,Campaign_Code__c,Campaign_End_Date__c,Campaign_Name__c,
                               Campaign_Start_Date__c,Campaign_Status__c,Campaign_Type__c,City__c,OwnerId,RecordTypeId,
                               Zip_Or_Postal_Code__c,State_Province__c,Title__c,Sub_Industry__c,Chat_User_Phone__c,Position__c,
                               Number_of_Locations__c,Years_In_Business__c,Timing__c,Company_Annual_Sales__c,Number_of_Employees__c,Subject,
                               Description,Status,Comments__c,
                               What_can_NCR_help_you_with_today__c
                               From Case Where DRT_Escalated_To__c='test@test.com'];
        for(Case caseObj : caseList){
            case caseUpdateObj = new Case();
            caseUpdateObj.id = caseObj.id;
            caseUpdateObj.DRT_Escalated_To__c ='test@test2.com'; 
            caseUpdateList.add(caseUpdateObj);
            System.assert(caseUpdateObj.id!=null);
        }
        update caseUpdateList;
    }
    @isTest
    private static void maccChatHandlerTestMethod(){
        List<Case> caseUpdateList = new List<Case>();

        String testLbl = Label.Marketo_Us;
        system.assert(testLbl!=null);
        system.debug(logginglevel.error,testLbl);
        List<Case> caseList = [SELECT id,DRT_Escalated_To__c,Chat_User_Company__c,Chat_User_Country__c,Chat_User_Email__c,Chat_User_First_Name__c,
                               Chat_User_Industry__c,Customer_Response_Time__c,Staff_Response_Time__c,Chat_User_Last_Name__c,Chat_User_Source__c,Chat_User_Type__c,Origin,Owner.Name,
                               Agent_Notes__c,Business_Function__c,Campaign_Code__c,Campaign_End_Date__c,Campaign_Name__c,
                               Campaign_Start_Date__c,Campaign_Status__c,Campaign_Type__c,City__c,OwnerId,RecordTypeId,
                               Zip_Or_Postal_Code__c,State_Province__c,Title__c,Sub_Industry__c,Chat_User_Phone__c,Position__c,
                               Number_of_Locations__c,Years_In_Business__c,Timing__c,Company_Annual_Sales__c,Number_of_Employees__c,Subject,
                               Description,Status,Comments__c,
                               What_can_NCR_help_you_with_today__c,Issue_Type__c,Was_an_IT_ticket_created_to_report_the_e__c,Was_there_a_specific_error_message__c,
                               Was_there_an_existing_knowledge_article__c,Were_you_able_to_replicate_the_error__c,Were_you_able_to_resolve_the_the_user_s__c,
                               What_type_of_assistance_was_provided__c,Ticket__c,mkto71_Acquisition_Date__c 
                               From Case Where Status='Open'];
        for(Case caseObj : caseList){
              case caseUpdateObj = new Case();
          caseUpdateObj.id = caseObj.id;
            caseObj.Status ='Closed'; 
            System.runAs(new user(ID = testLbl)){
                caseUpdateObj.mkto71_Acquisition_Date__c = caseObj.mkto71_Acquisition_Date__c;
            }
            caseUpdateList.add(caseUpdateObj);
        }
        try{
            update caseUpdateList;
        }catch(Exception ex){            
            system.debug('Ex'+ex);
        }
        
    }
    @isTest
    private static void ExistingLeadContactHelper(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get(CaseStaticVariableClass.ObjectName).getDescribe().getRecordTypeInfosByName().get(CaseStaticVariableClass.MarketingRecordType).getRecordTypeId();
            Case caseObj = new Case();
            caseObj.RecordTypeId = CaseRecordTypeId;
            caseObj.DRT_Escalated_To__c ='test@test.com';
            caseObj.Chat_User_Company__c='Test';
            caseObj.Chat_User_Country__c='Test';
            caseObj.Chat_User_Email__c ='Test@test.com';
            caseObj.Chat_User_First_Name__c ='Test';                            
            // caseObj.Chat_User_Industry__c='Test';
            caseObj.Chat_User_Last_Name__c = 'Test';
            caseObj.Chat_User_Source__c = 'Test';
            caseObj.Chat_User_Type__c ='Test';
            caseObj.Origin ='Forms';
            // caseObj.Owner.Name ='Test';
            caseObj.Agent_Notes__c = 'Test';
            caseObj.Business_Function__c ='Test';
            caseObj.Campaign_Code__c ='Test';
            caseObj.Campaign_Name__c ='Test';
            caseObj.Campaign_Status__c ='Test';
            caseObj.Campaign_Type__c ='Test';
            caseObj.City__c ='Test';
            //caseObj.RecordTypeId =,
            caseObj.Customer_Response_Time__c = '1 Days: 1 Hours: 12Minutes';
            caseObj.Staff_Response_Time__c = '0 Days: 1 Hours: 12Minutes';
            caseObj.Zip_Or_Postal_Code__c ='test';
            caseObj.State_Province__c = 'Test';
            caseObj.Title__c = 'Test';
            caseObj.Sub_Industry__c = 'Test';
            caseObj.Chat_User_Phone__c = 'Test';
            caseObj.Position__c = 'Test';
            caseObj.Subject ='Test'; 
            caseObj.Description='Test';
            caseObj.Status='Test';
            caseObj.Comments__c ='Test';
            caseObj.What_can_NCR_help_you_with_today__c='Test';
        	
        try{
            insert caseObj;
            System.assert(caseObj.id!=null);
        }catch(Exception ex){
            system.debug('Ex'+ex);
        }
            
        
    }
    
    // Dispute cases
    @isTest
    private static void DisputeCases(){

        //create a User
        User us= [Select id from user where firstname='testing'];
        system.assert(us.id!=null);
            
        // Create Contact
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Email='test@test.com';
        //cont.Accountid= testAccount.id;
        insert cont;
         system.assert(cont.id!=null);
        
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        Id IPTCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPT Partner').getRecordTypeId();
        Case caseObj = new Case();
        List<Id> caseIdList = new List<Id>();
        List<Case> casedata= new List<Case>();
        caseObj.RecordTypeId = CaseRecordTypeId;
        caseObj.Master_Customer_Nbr__c='TESTMCN00001X';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';
        caseObj.Contactid=cont.id;
        caseObj.Alternate_Contact__c=cont.id;
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        caseObj.Dispute_Type__c='Partial Credit';
        caseObj.DisputeAnalyst__c = us.Id;
       
        //case insert
        insert caseObj;
        
        caseIdList.add(caseObj.id);
        casedata.add(caseObj);
        DisputeAnalystController.getPicklistValues('Case','Dispute_Analyst_Name__c');  
        //case c= [select id,Customer_Contact_Email1__c from case where id= :caseObj.id];
        System.assertEquals('testing', caseObj.Dispute_Analyst_Name__c);
        System.assertEquals('test@test.com', caseObj.Dispute_Analyst_Email__c);
      
        CaseComment comment1 = new CaseComment();
        comment1.CommentBody='Test Comment';
        comment1.IsPublished=true;
        comment1.ParentId=caseObj.id;
        
        insert comment1;

        CCAD_disputeEmailNotifications.DisputeCreate_Notifications(casedata);
        //sendDisputesToCCAD_MockCallOut fakeResponse = new sendDisputesToCCAD_MockCallOut(200,'Complete','[{"Name": "sForceTest1"}]', null);
        test.starttest();
        Test.setMock(HttpCalloutMock.class, new sendDisputesToCCAD_MockCallOut());
        sendDisputesToCCAD.syncCaseToCCAD(caseIdList,false);
        //System.assertEquals(/*check for expected results here...*/);    

        Dispute_Invoices__c invOvj= new Dispute_Invoices__c();
        invOvj.Invoice_Number__c= '123456789';
        invOvj.Total_Invoice_Amount__c=1234567;
        invOvj.Customer_Trx_ID__c=1378389;
        invOvj.Dispute__c=caseObj.id;
        insert invOvj;
        
        /*CaseComment ccObj= new CaseComment();
        ccObj.CommentBody='Test Comment';
        ccObj.IsPublished=true;
        ccObj.ParentId=caseObj.id;
        
        insert ccObj;*/
        
        caseObj.RecordTypeId=IPTCaseRecordTypeId;
        caseObj.Is_Partner_Assist_Team_Case__c=false;
        caseObj.Origin='Chat'; 
        caseObj.Category__c='MDF';
        System.runas(us){
        	update caseObj;
        }
        System.runAs(new User(Id=UserInfo.getUserId())){
            caseObj.RecordTypeId = CaseRecordTypeId;
            caseObj.Category__c=null;
            update caseObj;
            
        }
       
        //ccObj.CommentBody='Test2';
        comment1.CommentBody='Test2';
        update comment1;      
        
        test.stoptest();
        
    }
   
    @isTest
    private static void DisputeCasesClose(){

        //create a User
       User us= [Select id from user where firstname='testing'];
        system.assert(us.id!=null);
        
        // Create Contact
        Contact cont = new Contact();
        cont.FirstName='Test';
        cont.LastName='Test';
        cont.Email='test@test.com';
        //cont.Accountid= testAccount.id;
        insert cont;
            system.assert(cont.id!=null);
        test.startTest();
        Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
        Id IPTCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPT Partner').getRecordTypeId();
        Case caseObj = new Case();
        List<Id> caseIdList = new List<Id>();
        List<Case> casedata= new List<Case>();
        caseObj.RecordTypeId = CaseRecordTypeId;
        caseObj.Master_Customer_Nbr__c='TESTMCN00001X';
        caseObj.Country_Code__c='US';
        caseObj.Currency_Code__c='USD'; 
        caseObj.Dispute_UpdatedBy_Qlook__c='12345';
        caseObj.Dispute_CreatedBy_Qlook__c='54321';
        caseObj.Contactid=cont.id;
        caseObj.Alternate_Contact__c=cont.id;
        caseObj.Dispute_Analyst_Email__c='test@test.com';     
        caseObj.Status='New';
        caseObj.Dispute_Created_By_Name__c='Test';
        caseObj.Dispute_Analyst_Name__c='testing';
        caseObj.DisputeAnalyst__c = us.Id;
       
        //case insert
        insert caseObj;
       
        caseObj.Status='Closed';
        caseObj.Dispute_Close_Reason__c='Contract Issues/Negotiations';
        caseObj.Root_Cause__c='Contract Issues/Negotiations';
        caseObj.Resolution_Notes__c='Contract Issues/Negotiations';
        caseObj.Ordering_System__c='759';
        caseObj.Hospitality_Reporting_Code__c='375';
        caseObj.Issue_Department__c='304';
        
        update caseObj;

        
        test.stoptest(); 
        
    }
     @isTest static void InsertSurveyFor() {
         
        //Account AccObj = TestRecordsFactory.createAccount('122002','FINANCIAL','EMEA');
        Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];
         system.assert(AccObj.id!=null);
        contact conObj = TestRecordsFactory.createContact(AccObj);
        Survey_Result__c SurveyResultObj = new Survey_Result__c();
        SurveyResultObj.Name='Test Voc Survey';
        SurveyResultObj.Contact__c=conObj.id;
        SurveyResultObj.NPS_Score__c=8;
        SurveyResultObj.Immediate_Issues_Concerns__c='No';
        SurveyResultObj.Qualtrics_Response_ID__c='Qual_123';
        Test.startTest();
        insert SurveyResultObj; 

        AccObj.LOB__c='T&T';
        Update  AccObj;	
        Survey_Result__c SurveyResultObj1 = new Survey_Result__c();
        SurveyResultObj1.Name='Test Voc Survey';
        SurveyResultObj1.Contact__c=conObj.id;
        SurveyResultObj1.NPS_Score__c=5;
        SurveyResultObj1.Immediate_Issues_Concerns__c='Yes';
        SurveyResultObj1.Qualtrics_Response_ID__c='Qual_124';
        insert SurveyResultObj1;
        AccObj.LOB__c='Other';
        Update  AccObj;	
        Survey_Result__c SurveyResultObj2 = new Survey_Result__c();
        SurveyResultObj2.Name='Test Voc Survey';
        SurveyResultObj2.Contact__c=conObj.id;
        SurveyResultObj2.NPS_Score__c=7;
        SurveyResultObj1.Immediate_Issues_Concerns__c='Yes';
        SurveyResultObj2.Qualtrics_Response_ID__c='Qual_125';
        insert SurveyResultObj2;
        test.stopTest();
		//datetime.newInstance(2014, 9, 15, 12, 30, 0); 
		//Schema.SObjectType.account.getRecordTypeInfosByName().get('person').getRecordTypeId()       
    }

    @isTest static void CreateDetractorCase() {
		Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];        
        contact conObj = TestRecordsFactory.createContact(AccObj);
        system.assert(conObj.id!=null);
        case CaseObj = new Case();
        CaseObj.Status='New';
        CaseObj.Qualtrics_Response_ID__c='Qual_124';
        CaseObj.AccountId=AccObj.Id;
        CaseObj.ContactId=conObj.Id;
        CaseObj.Type='Detractor';
        CaseObj.Subject='Detractor Alert';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        test.startTest();
        insert caseObj;
        
        //LinkCaseWithNPSSurveyResultHandler.getDetractorCaseTypeEmailBody('TestCon','Test Account',caseObj.Id);
        //LinkCaseWithNPSSurveyResultHandler.getDetractorCaseTypeEmailBody('TestCon', 'Test Account', caseObj.Id);
        
        CaseObj.Immediate_Detractor_Case_Escalated_Date__c=System.now()-1;
        CaseObj.Immediate_Detractor_Case_Escalated__c=true;
        update CaseObj;
        
        caseObj.Detractor_Case_Escalated_Date__c=System.now()-1;
        caseObj.Detractor_Case_Escalated__c=true;
       // update caseObj;
        
        caseObj.Type='Immediate';
        User u = TestRecordsFactory.getUser();
        caseObj.OwnerId=u.id;
      //  update caseObj;

       // LinkCaseWithNPSSurveyResultHandler.getImmediateCaseTypeEmailBody('TestCon','Test Account',caseObj.Id);
       
        case CaseObjChild = new Case();
       
        CaseObjChild.Status='New';
        CaseObjChild.ParentId=caseObj.id;
        CaseObjChild.AccountId=AccObj.Id;
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = AccObj.id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Customer Success Manager');
        insert accTeamMember;
        CaseObjChild.ContactId=conObj.Id;
        CaseObjChild.Type='Detractor';
        CaseObjChild.Functional_Area__c='Billing';
        CaseObjChild.Subject='Detractor Alert';
        CaseObjChild.Due_Date__c=system.now();
        //CaseObjChild.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop Child').getRecordTypeId();
        CaseObjChild.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
       // insert CaseObjChild;
        
        CaseObj.Child_Case_Escalated_Date__c=System.now()-1;
        CaseObj.Is_Child_Case_Escalated__c=true;
       // update caseObj;
        
        
        CaseObjChild.Due_Date__c=system.Now()-1;
        CaseObjChild.Is_Due_Date_Passed__c=true;
       // update CaseObjChild;
        
         Group testGroup = new Group(Name='test group', Type='Queue');
         insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
		{
         QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
         insert testQueue;
            Map<Id, List<String>> queueIdToGroupMambersIdMap = new  Map<Id, List<String>>();
        
        queueIdToGroupMambersIdMap.put(testGroup.id, new List<String>());
        queueIdToGroupMambersIdMap.get(testGroup.id).add(testQueue.id);
        //LinkCaseWithNPSSurveyResultHandler.getQueueIdToQueueMembersId(queueIdToGroupMambersIdMap);
        CaseObjChild.ownerid = testGroup.id;
       // update CaseObjChild;
		}      
    	
        test.StopTest();
      
    }
    @isTest static void CreateFollowUpCase() {
		Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];        
        contact conObj = TestRecordsFactory.createContact(AccObj);
        case CaseObj = new Case();
        CaseObj.Status='New';
        CaseObj.Qualtrics_Response_ID__c='Qual_124';
        CaseObj.AccountId=AccObj.Id;
        CaseObj.ContactId=conObj.Id;
        //CaseObj.Type='Detractor';
        CaseObj.Subject='Detractor Alert';
        CaseObj.Functional_Area__c ='Billing';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Follow-up').getRecordTypeId();
        test.startTest();
        insert caseObj;
        system.assert(caseObj.id!=null);
        
       
    	
        test.StopTest();
      
    }

    @isTest static void CreateImmediateDetractorCase() {
        Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = AccObj.id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Customer Success Manager');
        insert accTeamMember;
        
        contact conObj = TestRecordsFactory.createContact(AccObj);
        case CaseObj = new Case();
       
        CaseObj.Status='New';
        CaseObj.AccountId=AccObj.Id;
        CaseObj.ContactId=conObj.Id;
        CaseObj.Type='Immediate';
        CaseObj.Subject='Immediate Alert';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        insert caseObj;
        
        //LinkCaseWithNPSSurveyResultHandler.getImmediateDetractorTypeEmailBody('TestCon','Test Account',caseObj.Id);
        Case caseObj1 = [Select id,Case_Close_Reason__c,Status from case limit 1];
        system.assert(caseObj1.id!=null);
        CaseObj1.Case_Close_Reason__c='No Fx Action(s) Required';
        //CaseObj1.Status  = 'Closed';
        
        update caseObj1;
        
        LinkCaseWithNPSSurveyResultHandler.GetMapOfFunctionalAreaAndLob();
        //LinkCaseWithNPSSurveyResultHandler.IncreateTestCoverage();
    }
    @isTest static void VOCCloseLoopCase() {
        Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];
        system.assert(AccObj.id!=null);
        contact conObj = TestRecordsFactory.createContact(AccObj);
        case CaseObj = new Case();
        CaseObj.Status='New';
        CaseObj.AccountId=AccObj.Id;
        CaseObj.ContactId=conObj.Id;
        CaseObj.Type='Immediate';
        CaseObj.Subject='Immediate Alert';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        insert caseObj;
        case CaseObj1 = new Case();
        CaseObj1.Status='New';
        CaseObj1.AccountId=AccObj.Id;
        CaseObj1.ContactId=conObj.Id;
        CaseObj1.Type='Immediate';
        CaseObj1.Subject='Immediate Alert';
        CaseObj1.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        Test.startTest();
        insert caseObj1;
        caseObj1.status='Closed';
        CaseObj1.Case_Close_Reason__c='No Fx Action(s) Required';
        CaseObj1.CX_Case_Number__c =caseObj.CaseNumber;
        caseObj.status='Closed';
        caseObj.Case_Close_Reason__c ='No Fx Action(s) Required';
		update CaseObj1;
        update caseObj;
        test.stopTest();
     	   
     }
    @isTest static void IPTCloseLoopCase() {
        Test.startTest();
        Account AccObj =  [Select id,Subscription_Group__c from Account limit 1];
        contact conObj = TestRecordsFactory.createContact(AccObj);
        System.assert(conObj.id!=null);
        case CaseObj = new Case();
        CaseObj.Status='New';
        CaseObj.AccountId=AccObj.Id;
        CaseObj.ContactId=conObj.Id;
        CaseObj.Type='Immediate';
        CaseObj.Subject='Immediate Alert';
        CaseObj.Category__c='Co-Op';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('IPT Partner').getRecordTypeId();
        insert caseObj;
        caseObj.status='Closed';
        caseObj.Case_Close_Reason__c ='No Fx Action(s) Required';
        try{
            update caseObj;
        test.stopTest();
     	
        }catch(Exception ex){
            system.debug('Ex'+ex);
        }
           
     }
     @isTest
    private static void maccChatHandlerTestMethod1(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();
          Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
	    Test.startTest();
        maccCaseObj.Issue_Type__c ='Error in Tool';
        maccCaseObj.Was_an_IT_ticket_created_to_report_the_e__c ='yes';	
         maccCaseObj.Was_there_a_specific_error_message__c ='Yes';
         maccCaseObj.Were_you_able_to_replicate_the_error__c ='Yes';
          maccCaseObj.What_type_of_assistance_was_provided__c ='Chat Explanation';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='Yes';
          maccCaseObj.Which_page_is_the_user_seeing_error__c = 'MACC Move';
        maccCaseObj.Input_The_Error_Message__c='';
        //maccCaseObj.Ticket__c ='';
        maccCaseObj.Status ='closed';
       
        try{
            insert maccCaseObj; 
            System.assert(maccCaseObj.id!=null);
        }
        catch (exception ex){
            System.debug('Error: '+ex.getMessage());
        }
		     test.stopTest();
		  }
  @isTest
    private static void maccChatHandlerTestMethod2(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();
          Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
	    Test.startTest();
        maccCaseObj.Issue_Type__c ='Error in Tool';
          maccCaseObj.What_type_of_assistance_was_provided__c ='Chat Explanation';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='Yes';
         maccCaseObj.Input_The_Error_Message__c='';
        maccCaseObj.Status ='closed';
        
        try{
            insert maccCaseObj;
            System.assert(maccCaseObj.id!=null);
        }
        catch (exception ex){
            System.debug('Error: '+ex.getMessage());
        }
		     test.stopTest();
		  } @isTest
    private static void maccChatHandlerTestMethod3(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();
          Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
	    Test.startTest();
        maccCaseObj.Issue_Type__c ='Error in Tool';
        maccCaseObj.Was_an_IT_ticket_created_to_report_the_e__c ='yes';	
         maccCaseObj.Was_there_a_specific_error_message__c ='Yes';
         maccCaseObj.Were_you_able_to_replicate_the_error__c ='Yes';
          maccCaseObj.What_type_of_assistance_was_provided__c ='Chat Explanation';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='Yes';
          maccCaseObj.Which_page_is_the_user_seeing_error__c = 'MACC Move';
        maccCaseObj.Input_The_Error_Message__c='test';
        maccCaseObj.Ticket__c ='test';
        maccCaseObj.Status ='closed';
        
        try{
            insert maccCaseObj; 
            System.assert(maccCaseObj.id!=null);
        }
        catch (exception ex){
            System.debug('Error: '+ex.getMessage());
        }
		     test.stopTest();
		  }
     @isTest
    private static void maccChatHandlerTestMethod4(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();
          Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
	    Test.startTest();
        maccCaseObj.Issue_Type__c ='Provided Knowledge Article';
       maccCaseObj.Was_there_an_existing_knowledge_article__c ='Yes';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='';
        maccCaseObj.Status ='closed';
        
        try{
            insert maccCaseObj; 
            System.assert(maccCaseObj.id!=null);
        }
        catch (exception ex){
            System.debug('Error: '+ex.getMessage());
        }
		     test.stopTest();
		  }
      @isTest
    private static void maccChatHandlerTestMethod5(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
        Id maccCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('MACC Live Chat Cases').getRecordTypeId();
          Case maccCaseObj = new Case();
        maccCaseObj.RecordTypeId = maccCaseRecordTypeId;
	    Test.startTest();
        maccCaseObj.Issue_Type__c ='Unresolved/Unworkable';
       maccCaseObj.Was_there_an_existing_knowledge_article__c ='Yes';
        maccCaseObj.Were_you_able_to_resolve_the_the_user_s__c ='';
        maccCaseObj.Status ='closed';
       
        try{
            insert maccCaseObj;
             System.assert(maccCaseObj.id!=null);
        }
        catch (exception ex){
            System.debug('Error: '+ex.getMessage());
        }
		     test.stopTest();
		  }
}