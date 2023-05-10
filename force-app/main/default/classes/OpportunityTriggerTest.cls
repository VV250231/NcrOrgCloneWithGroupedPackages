/*
Purpose of this class is to test OpportunityTrigger functions for :
a.   beforeInsert Opportunity trigger - Project Ocr - Populate OCR Book Date Fields
b.   - 

REVISION HISTORY
================
Version     Author        Date               CR#                Description
-------     ------        ----            --------              -----------
1.0         Nagendra     10th June 2018                         

*/

@isTest
public class OpportunityTriggerTest {
    @testsetup
    public static void test(){
        Payment_Fees_Management__c pay = new Payment_Fees_Management__c();
        insert pay;
    }
    public static testMethod void Test_PopulateOCRBookDateFields(){
        // List<User> newUser = TestRecordsFactory.createUsers('00e70000000x3eg', 'AdminChamp', 1);
        Opportunity opp = new Opportunity();
        opp=createSimpleOpportunity();
        opp.stagename = 'Closed/Booked';
        opp.Book_Quarter__c = '2016 Q1';
        opp.Book_Month__c = '2016 Oct';
        opp.Book_Quarter_Week__c = '2016 Q1 01';
        opp.Book_Month_Week__c = 1;
        opp.IsQuoteCreatedInOtherSystem__c='YES';
        opp.Key_Criteria__c = 'Test';
        opp.Price_Variance__c  = 'Test';
        opp.Use_SF_Probability__c ='NO';
        opp.Reasons_for_no_Payment_Processing__c='Existing Contract (Other)';
        opp.Payments_Contract_End_Date__c=System.today();
        //Account_Global_Sales_Org_Code__c
        //opp.OwnerId = newUser[0].id;
        opp.Closed_Booked_Comments__c = 'TEstin comments' ;
        opp.CLM_Sales_Acknowledgment__c = true;
        testCustomSetting();
        
        
        Account acc=new Account();
        acc=TestRecordsFactory.createAccount();
        
        Competitors__c comp=new Competitors__c ();
        //comp=TestRecordsFactory.createCompetitor();
        
        Sales_Org__c  so=new Sales_Org__c();
        // so=TestRecordsFactory.createSalesOrg();
        
        OCR_Calender__c oc = new OCR_Calender__c();
        oc.Date__c=date.today();
        oc.Year__c=2016;
        oc.Quarter__c='1';
        oc.Quarter_Week_Number__c=1;
        oc.Month__c='October';
        oc.Month_Week_Number__c =1;
        insert oc;
        DI_Demo_Request__c demoObj = new DI_Demo_Request__c();
        // demoObj. ='test';
        User us = TestRecordsFactory.getUser();  
        User Usr = [Select Id from User Where profile.name ='04 NSC UI Administrator' and isactive = true limit 1];
        Id r = Schema.SObjectType.DI_Demo_Request__c.getRecordTypeInfosByName().get('DI Demo Request').getRecordTypeId();
        demoObj.RecordTypeId = r;
        demoObj.Opportunity__c = opp.id;
        demoObj.Requestor__c = us.id;
        demoObj.SE_Assigned__c = Usr.id;
        demoObj.Alt_SE__c = us.id;
        demoObj.Status__c = 'Completed';
        demoObj.Confirmed_Date_Time__c = system.now();
        demoObj.Confirmed_Duration__c = 3;
        demoObj.What_did_not_resonate_with_the_FI__c = 'test';
        demoObj.What_resonated_with_the_FI__c ='test';
        system.runAs(Usr){
            insert demoObj;
        }
        
        test.startTest();
        update opp;
        OpportunityTriggerHandler oppObj = new OpportunityTriggerHandler();
        //   oppObj.prvntClosingofOpp(new List<Opportunity>{opp});
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        oppMap.put(opp.id, opp);
        oppObj.validateOportunityAmount(new List<Opportunity>{opp},oppMap);
        //System.assertNotEquals([Select Use_SF_Probability__c from Opportunity where Id=:opp.id].Use_SF_Probability__c, opp.Use_SF_Probability__c);
        test.stopTest();  
        
        
    }
    public static testMethod void Test_PopulateOCRBookDateFieldsSecondMethod(){
        // List<User> newUser = TestRecordsFactory.createUsers('00e70000000x3eg', 'AdminChamp', 1);
        Opportunity opp = new Opportunity();
        opp=createSimpleOpportunity();
        opp.stagename = 'Closed/Booked';
        opp.Book_Quarter__c = '2016 Q1';
        opp.Book_Month__c = '2016 Oct';
        opp.Book_Quarter_Week__c = '2016 Q1 01';
        opp.Book_Month_Week__c = 1;
        opp.IsQuoteCreatedInOtherSystem__c='YES';
        opp.Key_Criteria__c = 'Test';
        opp.Price_Variance__c  = 'Test';
        opp.Use_SF_Probability__c ='NO';
        //opp.CloseDate= date.today();
        opp.Reasons_for_no_Payment_Processing__c='Existing Contract (Other)';
        opp.Payments_Contract_End_Date__c=System.today();
        //Account_Global_Sales_Org_Code__c
        //opp.OwnerId = newUser[0].id;
        opp.Closed_Booked_Comments__c = 'TEstin comments' ;
        opp.CLM_Sales_Acknowledgment__c = true;
        testCustomSetting();
        
        
        Account acc=new Account();
        acc=TestRecordsFactory.createAccount();
        
        Competitors__c comp=new Competitors__c ();
        //comp=TestRecordsFactory.createCompetitor();
        
        Sales_Org__c  so=new Sales_Org__c();
        // so=TestRecordsFactory.createSalesOrg();
        
        OCR_Calender__c oc = new OCR_Calender__c();
        oc.Date__c=date.today();
        oc.Year__c=2016;
        oc.Quarter__c='1';
        oc.Quarter_Week_Number__c=1;
        oc.Month__c='October';
        oc.Month_Week_Number__c =1;
        insert oc;
        
        
        
        
        test.startTest();
        //  opp.CloseDate =date.today();
        opp.Actual_Close_Date__c =date.today();
        update opp;
        //System.assertNotEquals([Select Use_SF_Probability__c from Opportunity where Id=:opp.id].Use_SF_Probability__c, opp.Use_SF_Probability__c);
        test.stopTest();  
        
        
    }
    
    
    public static testMethod void Test_DeleteTask(){
        
        testCustomSetting();
        
        List<Opportunity> Opportunities = TestRecordsFactory.returnOpportunities(3);
        List <Opportunity> oppL=new List<Opportunity>();
        
        
        Opportunity opp = new Opportunity();
        Opportunity opp0 = new Opportunity();
        Opportunity opp1 = new Opportunity();
        opp= Opportunities[0];
        opp.Expected_Delivery_Date__c = System.TODAY()-2;
        opp.closeDate = System.TODAY()-8;
        oppL.add(opp);
        
        opp0= Opportunities[1];
        opp0.Expected_Delivery_Date__c = System.TODAY()-2;
        opp0.closeDate = System.TODAY()-8;
        oppL.add(opp0);
        
        opp1= Opportunities[2];
        opp1.Expected_Delivery_Date__c = System.TODAY()-2;
        opp1.closeDate = System.TODAY()-8;
        opp.StageName = 'Closed/Booked';
        opp.IsQuoteCreatedInOtherSystem__c='YES';
        oppL.add(opp1);
        
        test.startTest();
        insert oppL;
        
        Task pipelineTask = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp.Id, SUBJECT = 'Action Required: Pipeline Opportunity Expected Delivery', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pipelineTask2 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp.Id, SUBJECT = 'Action Required: Pipeline Opportunity Expected Delivery', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pastdue1 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp.Id, SUBJECT = 'Action Required: Past Due Opportunity', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pastdue2 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp.Id, SUBJECT = 'Action Required: Past Due Opportunity', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pipelineTask3 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp1.Id, SUBJECT = 'Action Required: Pipeline Opportunity Expected Delivery', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pipelineTask4 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp1.Id, SUBJECT = 'Action Required: Pipeline Opportunity Expected Delivery', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pipelineTask5 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp0.Id, SUBJECT = 'Action Required: Pipeline Opportunity Expected Delivery', ACTIVITYDATE = System.TODAY()+1, STATUS = 'Not Started', OwnerId = userinfo.getuserid());
        Task pastdue3 = new Task(RECORDTYPEID = NSCCommonInfoUtil.getInstance().getRecordTypeId('Task','General Task'),WHATID = opp0.Id, SUBJECT = 'Action Required: Past Due Opportunity', STATUS = 'Not Started', OwnerId = userinfo.getuserid(), ActivityDate = System.today()-2);
        
        List <Task> tL=new List<Task>();
        tL.add(pipelineTask);
        tL.add(pipelineTask2);
        tL.add(pastdue1);
        tL.add(pastdue2);
        tL.add(pipelineTask3);
        tL.add(pastdue3);
        tL.add(pipelineTask4); 
        tL.add(pipelineTask5); 
        
        insert tL;
        // test.startTest();
        opp.stagename = 'Closed/Lost';
        opp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        opp.Key_Criteria__c = 'test';
        opp.Price_Variance__c = 'test';
        
        opp0.CloseDate = System.today()-2;
        opp0.ForecastCategoryName = 'Upside';
        opp0.Are_we_the_Incumbent__c = 'No' ;
        
        List <Opportunity> oppL1=new List<Opportunity>();
        oppL1.add(opp0);
        // oppL1.add(opp1);
        //oppL1.add(opp);
        
        update oppL1;
        //System.assertEquals(6, [Select count() From Task Where IsClosed = false And Subject LIKE 'Action Required:%' ]);
        test.stopTest(); 
        
    }
    /*private static testMethod void SendEmailtoOppOwnerManagerTest(){

Profile p = [SELECT Id FROM Profile WHERE Name='04 NSC UI Administrator'];
UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'FIN-IMEA-GULF/KSA-TEAM2');
insert r;

User u = new User(Alias = 'MudiTest', Email='standarduser@testorg.com',
EmailEncodingKey='UTF-8', LastName='MudiTest', LanguageLocaleKey='en_US',
LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
UserName='MudiTest@testorg.com', Quicklook_ID__c='TESTMUDI', FederationIdentifier='TESTMUDI',UserRoleId=r.id);

insert u;

System.RunAs(u){
Account acc=new Account();
acc=TestRecordsFactory.createAccount();

Competitors__c comp=new Competitors__c ();
comp=TestRecordsFactory.createCompetitor();

Opportunity opp = new Opportunity();
opp=TestRecordsFactory.createSimpleOpportunity(acc);

CheckRecursive.sendOppOwnerNotification = true;
opp.StageName='validating';
opp.Amount=100;
opp.closeDate=System.TODAY().addDays(10);
update opp;
}
}*/
    /*
    public static testMethod void ClearFieldsOnOppCloneTest(){
        
        testCustomSetting();
        
        List<Opportunity> Opportunities ;
        
        Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        opp.IsClone__c=opp.Id;
        opp.isCloneWithProduct__c=true;
        insert opp;
        
        OpportunityLineItem oli = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
        Opportunity oppWithLineItem_StandrdPriceBook = opp;
        //Opportunity oppWithLineItem_StandrdPriceBook = TestRecordsFactory.createOppWithOLIwithStdPriceBookEntry(opp);
        
        test.startTest();
        Opportunity oppty = Opportunities[1];   
        oppty.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        oppty.closeDate = System.TODAY();
        oppty.stagename = 'Analyzing';
        oppty.IsClone__c=oppWithLineItem_StandrdPriceBook.Id;
        oppty.isCloneWithProduct__c=true;
        insert oppty;
        
        System.assertEquals(1,[select count() from OpportunityLineItem where OpportunityId=:oppWithLineItem_StandrdPriceBook.id]);
        
        Opportunity oppty2 = Opportunities[2];   
        oppty2.IsClone__c=oppty.Id;
        oppty2.isCloneWithProduct__c=false; 
        insert oppty2;
        System.assertEquals([select count() from OpportunityLineItem where OpportunityId =:oppty2.id], 0);
        
        test.stopTest();
    } */
    
    private static testmethod void  CurrencyIsoConversionTest(){
        testCustomSetting();
        Test.startTest();
        Opportunity OppObj=TestRecordsFactory.createSimpleOpportunity();
        OppObj.CurrencyIsoCode='TWD';
        update OppObj;
        Opportunity opp = [select Currency_Conversion_Rate__c from Opportunity where id =: OppObj.id limit 1];
        Test.stopTest();
    }
    public static testMethod void UpdateOpportunityTeamMemberTest(){
        
        testCustomSetting();
        
        Test.startTest();
        List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Exclude from Funnel');
        insert opp;
        update opp;
        opp.ForecastCategoryName ='Pipeline';
        opp.Forecast_Category__c = 'Pipeline';
        opp.RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        update opp;
        
        Test.stopTest();  
    }
    public static testmethod void UpdateCampaignActivityTest(){
        
        testCustomSetting();
        
        test.startTest();
        
        Campaign_Activity__c campAct = new Campaign_Activity__c();
        campAct.Status__c = 'Open';
        insert campAct ;
        CheckRecursive.run = true ;
        
        List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity opp = Opportunities[0];
        opp.type = 'Indirect Channel';
        opp.RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Exclude from Funnel');
        //opp.Campaign_Activity_System__c = campAct.Id ;
        insert opp;
        
        campAct.Status__c = 'Qualified';
        update campAct;
        
        //opp.Campaign_Activity_System__c = campAct.Id ;
        update opp;
        
        System.assertEquals('Qualified', [select Status__c from Campaign_Activity__c where id=:campAct.Id ][0].Status__c);
        test.stopTest();
    }
    public static testmethod void PopulateOppASolutionTest(){
        
        testCustomSetting();
        
        List<Product2> products = new List<Product2>();
        Product2 HWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'HW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 SWProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                           Service_Offer_Category__c = 'SW',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 HWMProduct1 = new Product2( Name='Orderman', CurrencyIsoCode='USD', 
                                            Service_Offer_Category__c = 'HWM',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        Product2 PaymentProcessingProduct = new Product2( Name='Aloha POS', CurrencyIsoCode='USD', 
                                                         Service_Offer_Category__c = 'Payments Processing',Product_Category__c ='CS',isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        
        products.add(HWProduct1);
        products.add(SWProduct1);
        products.add(HWMProduct1);
        products.add(PaymentProcessingProduct);
        
        test.startTest();
        insert products;
        
        try{
            List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(3);
            Opportunity opp = Opportunities[0];
            //opp.You_have_not_selected_any_TS_HWM_or_SW__c = 'Other';
            insert opp;
            List<OpportunityLineItem> lstOLI = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(products));
            
            HWMProduct1.Service_Offer_Category__c = 'SW';
            products.clear();
            products.add(HWProduct1);
            products.add(SWProduct1);
            products.add(HWMProduct1);
            products.add(PaymentProcessingProduct);
            update products;
            
            opp.You_have_not_selected_any_TS_HWM_or_SW__c =null;
            opp.Reasons_for_no_Payment_Processing__c='Existing Contract (Other)';
            opp.StageName = 'Closed/Booked';
            opp.IsQuoteCreatedInOtherSystem__c = 'YES';
            opp.Price_Variance__c = 'NCR above 5%';
            opp.Key_Criteria__c = 'Lead Time';
            List<OpportunityLineItem> lstOLI1 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(products));
            
            update opp;
            
        }
        catch(Exception e){
            
            Boolean expectedExceptionThrown =  e.getMessage().contains('You have not selected any HWM, SWM or TS. Please Provide Reasons') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        
        test.stopTest();
    }
    private static testmethod void UpdateEDDToEBD(){
        EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
        ebdedd.Name = 'EDSD_Calc';
        ebdedd.isActive__c = true;
        insert ebdedd;
        
        //User SystemUser = TestRecordsFactory.createUsers('00e70000000x3eg','TestClassChamp',1)[0];
        //System.runAs(SystemUser){
        
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        
        OpportunityLineItem oli = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
        OpportunityLineItem oli2 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
        OpportunityLineItemSchedule olis1 = TestRecordsFactory.createOpportunityLineitemSchedule(oli);
        OpportunityLineItemSchedule olis2 = TestRecordsFactory.createOpportunityLineitemSchedule(oli2);
        test.startTest();
        try{
            opp.closedate = System.today() + 60;
            update opp;
            opp.closedate = System.today() + 450;
            update opp;
        }
        catch(Exception e)
        {
            String message = e.getMessage(); //
            system.assert(message.contains('You have not selected any HWM, SWM or TS. Please Provide Reasons'), 'message=' + message);
            
        }           
        test.stopTest();
        //}
        
    } 
    public static testMethod void PopulateOcrTeamAndContactRoleTest() {
        
        //testCustomSetting();
        //--------------------------OCR_TEAM__c Object Deletion EBA_SF-1720---------------------------------------
        
        /*  List <OCR_TEAM__c> ocrtlist=new List<OCR_TEAM__c>();

OCR_TEAM__c ocr=new OCR_TEAM__c(Sales_Org__c='45678',Ocr_Team__c='TEST');
OCR_TEAM__c ocr1=new OCR_TEAM__c(Sales_Org__c='ALL',Ocr_Team__c='TEST1');  
OCR_TEAM__c ocr2=new OCR_TEAM__c(Sales_Org__c='126232',Ocr_Team__c='TEST2');
ocrtlist.add(ocr); 
ocrtlist.add(ocr1); 
ocrtlist.add(ocr2); 
insert ocrtlist;
*/
        TestRecordsFactory.createSalesOrg();
        TestRecordsFactory.createCompetitor();
        Account acc = TestRecordsFactory.createAccount();
        Contact con1 = TestRecordsFactory.createContact(acc);
        Contact con2 = TestRecordsFactory.createContact(acc);
        Contact con3 = TestRecordsFactory.createContact(acc);
        test.startTest(); 
        Opportunity opp = TestRecordsFactory.createSimpleOpportunityWithContact(con1);
        OpportunityContactRole oppConRole = TestRecordsFactory.createOppContactRole(opp, con2);
        
        opp.Contacts__c = con2.Id;
        update opp;
        
        opp.Contacts__c = con3.Id;
        update opp;
        System.assertEquals(opp.Contacts__c != oppConRole.ContactId, true);
        test.stopTest();
    }
    public static testMethod void HelperOpportunity_insertContactRoleDecisionMaker() {
        
        //testCustomSetting();
        
        //   Profile p = [SELECT Id FROM Profile WHERE Name='02 NSC Administrator'];
        Profile p = [SELECT Id FROM Profile WHERE Name='50 Hospitality Account Director'];
        
        //Profile p=[SELECT Id FROM Profile where Id in :NSCCommonInfoUtil.getIdSetOf('HOSPAndRetail_PROFILE')][0];
        
        User u = new User(Alias = 'Mudi', Email='standarduser12@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='MudiTest12', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',
                          UserName='Test@testorg12.com', Quicklook_ID__c='at654324', FederationIdentifier='at654324');
        insert u;
        test.startTest();
        Account acc11 = TestRecordsFactory.createAccount();
        Account acc =  new Account(Id=acc11.Id) ;
        acc.ownerid=u.id;
        acc.Active_Account__c = true ;
        //update acc;
        User Usr = [Select Id from User Where profile.name ='04 NSC UI Administrator' and isactive = true and Id NOT IN (  
        SELECT AssigneeId FROM PermissionSetAssignment 
        WHERE PermissionSet.name='CATM_Ownership_Transfer') limit 1 ]; 
        
       system.runAs(Usr){ 
            update acc;
        }
        Contact c = new Contact();
        c.Accountid = acc.id;
        c.LastName = 'test1';
        c.Email = 'test1@test.com';
        c.Decision_Maker__c='Decision Maker';
        c.Business_Function__c = 'Marketing';
        insert c;
        Contact c1 = new Contact();
        c1.Accountid = acc.id;
        c1.LastName = 'test1';
        c1.Email = 'test1@test.com';
        c1.Decision_Maker__c='Decision Maker';
        c1.Business_Function__c = 'Marketing';
        insert c1;
        
        
        Contact con1 = TestRecordsFactory.createContact(acc);
        
        Opportunity opp_test1=TestRecordsFactory.createSimpleOpportunityWithContact(con1);
        List<Opportunity> test_list=new list<opportunity>();
        test_list.add(opp_test1);
        HelperOpportunity.insertContactRoleDecisionMaker(test_list);
        HelperOpportunity.updateContactRoleFromOpportunity(test_list);
        
        system.runAs(u){          
          //  Opportunity opp = TestRecordsFactory.createOpportunityWithContact(con1,acc);
        }
        test.stopTest();    
        
    }
    
    /*   private static testMethod void PS_ChangeScheduleTest() {  
EBDEDDSetting__c ebdedd = new EBDEDDSetting__c();
ebdedd.Name = 'EDSD_Calc';
ebdedd.isActive__c = true;
insert ebdedd; 

User SystemUser = TestRecordsFactory.createUsers('00e70000000x3eg','TestClassChamp',1)[0];

System.runAs(SystemUser){
test.startTest();
Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
OpportunityLineItem oli = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
OpportunityLineItem oli2 = TestRecordsFactory.createOpportunityLineItem(opp, TestRecordsFactory.createPriceBookEntry(TestRecordsFactory.createProduct()));
OpportunityLineItemSchedule olis1= TestRecordsFactory.createOpportunityLineitemSchedule(oli);
system.debug('opp.CloseDate before update 1'+opp.CloseDate);
system.debug('opp.CloseDate before update 1'+opp.id);
//Recursionblocker.flag = true;
opp.closedate = System.today() + 450;

//update opp;
//system.debug('All OLIs'+ [ SELECT id,ScheduleDate, Quantity, OpportunityLineItem.Opportunity.Id,OpportunityLineItem.Opportunity.CloseDate from OpportunityLineItemSchedule where OpportunityLineItem.Opportunity.Id =:opp.id AND  ScheduleDate < :GlobalVariable.unhandledQtyDate ORDER BY ScheduleDate ASC ] );

//Recursionblocker.flag = false;
//system.debug('opp.CloseDate after  update 2'+opp.CloseDate);
test.stopTest();
}
}*/
    private static testmethod void QuoteValidations(){
        
        // testCustomSetting();
        
        //Inserting Dummy Opportunity
        //Account SampleAcc=TestRecordsFactory.createAccount();
        string pf = NSCCommonInfoUtil.getIdOf('Profile_31_GS_Account_Manager');
        User u= TestRecordsFactory.createUsers(pf,'31_GS_Account_Manager_TestUser',1)[0];
        //[Select id from user where Profile.PermissionsLightningExperienceUser=true and profileid not in ('00e70000000x3egAAA','00e70000000sR8UAAU','00e700000013gAKAAY') and isActive=true and userType='Standard' limit 1];
        List<Opportunity> listOpportunity = new List<Opportunity>();
        
        List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(3);
        Opportunity InsertClosedOpp = Opportunities[0];
        InsertClosedOpp.stagename='Closed/Booked';
        InsertClosedOpp.Price_Variance__c = 'NCR above 5%';
        InsertClosedOpp.Key_Criteria__c = 'Lead Time';
        InsertClosedOpp.OwnerId=u.id;
        listOpportunity.add(InsertClosedOpp);
        
        Account SampleAcc = new Account(id = InsertClosedOpp.AccountId);
        // assigning account
        SampleAcc.OwnerId=u.id;
        //update SampleAcc;
        User Usr = [Select Id from User Where profile.name ='04 NSC UI Administrator' and isactive = true  and Id NOT IN (  
        SELECT AssigneeId FROM PermissionSetAssignment 
        WHERE PermissionSet.name='CATM_Ownership_Transfer') limit 1 ];
        
        system.runAs(Usr){ 
            update SampleAcc;
        }
        
        Opportunity opp = new Opportunity();
        opp =Opportunities[1];
        opp.name = 'abc';
        opp.AccountID = SampleAcc.id;
        
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        
        
        opp.stagename = 'Closing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        opp.OwnerId=u.id;
        listOpportunity.add(opp);
        
        
        
        
        
        
        
        test.startTest();
        /*
System.runAs(u) {
TriggerHandlerBase.bypass('AccountTriggerHandler');

//insert closed opp and opp with no quote associated to it.
try{
insert listOpportunity;  


}catch( exception ex ){
System.debug('exception message'+ex.getMessage());
System.assertEquals( ex.getMessage().contains('Please confirm if you have created a quote in a system other than QuoteBuilder'),true );
}
//reopen closed opp


}
try{
InsertClosedOpp.IsQuoteCreatedInOtherSystem__c ='Yes';
insert InsertClosedOpp;  
Opportunity ReopenOpp =InsertClosedOpp;
ReopenOpp.StageName= 'Offering';
update ReopenOpp;
}catch( exception ex ){
System.debug('exception message'+ex.getMessage());
// System.assertEquals( ex.getMessage().contains('Can’t change or go back on the opportunity stage once it is in "Closing" or "Closed/Booked"'),true );
}
Opportunity QuoteValidations;
try{
QuoteValidations =listOpportunity[1];
insert QuoteValidations; 
QuoteValidations.IsQuoteCreatedInOtherSystem__c ='No';
update QuoteValidations; 
}catch(exception ex){
System.debug('Error msg'+ex.getMessage());
} */
        if(opp.id==null)
            insert opp;
        Opportunity opp2=[Select id, Opportunity_Number__c from Opportunity where id=:opp.id];
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        QD.Annuity_Quote_Status__c = 'ACKNOWLEDGED';
        Qd.Quote_Number__c='123';
        QD.MCN__c = 'TEST000012';
        QD.Country_Code__c='US';
        QD.Opportunity__c = opp2.id;
        QD.Opportunity_No__c=opp2.Opportunity_Number__c;
        insert QD;
        
        System.runAs(u) {
            //null scenario
            opp.stagename='Closed/Booked';
            opp.Price_Variance__c = 'NCR above 5%';
            opp.Key_Criteria__c = 'Lead Time';
            try{
                update opp;
            }
            catch(Exception e){
                System.debug('Exception Caught'+e.getMessage());
            }
            
        }
        try{
            delete opp2;  
        } catch(Exception e) {
            System.debug('Exception Caught'+e.getMessage());
        }
        test.stopTest();
        
    }
    private static testmethod void PopulateForecastCategoryTest(){
        // testCustomSetting();
        user userNonLightning = new user();
        userNonLightning= TestRecordsFactory.createUsers(NSCCommonInfoUtil.getIdOf('zuora_admin'),'zouraAdmin',1)[0];
        // User userNonLightning= TestRecordsFactory.createUsers('00e70000000xUZS','02 NSC Administrator',1)[0];
        Id excludeRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exclude from Funnel').getRecordTypeId();
        List<Opportunity> listOpportunity = new List<Opportunity>();
        List<Opportunity> listOpportunityClassic = new List<Opportunity>();
        
        List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(15);
        for(Opportunity opp : Opportunities){
            opp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        } 
        Opportunity InsertClosedOpp = Opportunities[0];
        InsertClosedOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedOpp.RecordTypeId = excludeRecdTypeId ;
        InsertClosedOpp.Forecast_Category__c='Exclude Pipeline';
        InsertClosedOpp.stagename='Analyzing';
        InsertClosedOpp.Price_Variance__c = 'NCR above 5%'; 
        InsertClosedOpp.Key_Criteria__c = 'Lead Time';
        InsertClosedOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedOpp.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedOpp);
        
        Opportunity InsertClosedLostOpp = Opportunities[1];
        InsertClosedLostOpp.RecordTypeId = excludeRecdTypeId ;
        InsertClosedLostOpp.Forecast_Category__c='Closed';
        InsertClosedOpp.stagename='Closed';
        InsertClosedLostOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedLostOpp.Price_Variance__c = 'NCR above 5%';
        InsertClosedLostOpp.Key_Criteria__c = 'Lead Time';
        InsertClosedLostOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedLostOpp.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedLostOpp);
        
        Opportunity InsertClosedDiscontOpp = Opportunities[2];
        InsertClosedDiscontOpp.stagename='Analyzing';
        InsertClosedDiscontOpp.RecordTypeId = excludeRecdTypeId ;
        InsertClosedDiscontOpp.Forecast_Category__c='Exclude Upside';
        InsertClosedLostOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedDiscontOpp.Price_Variance__c = 'NCR above 5%';
        InsertClosedDiscontOpp.Key_Criteria__c = 'Lead Time';
        InsertClosedDiscontOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedDiscontOpp.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedDiscontOpp);
        
        Opportunity InsertClosedDiscontOpp1 = Opportunities[13];
        InsertClosedDiscontOpp1.stagename='Analyzing';
        InsertClosedDiscontOpp1.RecordTypeId = excludeRecdTypeId ;
        InsertClosedDiscontOpp1.ForecastCategoryName='Upside';
        InsertClosedDiscontOpp1.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedDiscontOpp1.Price_Variance__c = 'NCR above 5%';
        InsertClosedDiscontOpp1.Key_Criteria__c = 'Lead Time';
        InsertClosedDiscontOpp1.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedDiscontOpp1.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedDiscontOpp1);
        
        Opportunity InsertClosedDiscontOpp2 = Opportunities[11];
        InsertClosedDiscontOpp2.stagename='Analyzing';
        InsertClosedDiscontOpp2.RecordTypeId = excludeRecdTypeId ;
        InsertClosedDiscontOpp2.ForecastCategoryName='Pipeline';
        InsertClosedDiscontOpp2.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedDiscontOpp2.Price_Variance__c = 'NCR above 5%';
        InsertClosedDiscontOpp2.Key_Criteria__c = 'Lead Time';
        InsertClosedDiscontOpp2.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedDiscontOpp2.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedDiscontOpp2);
        
        Opportunity InsertClosedDiscontOpp3 = Opportunities[12];
        InsertClosedDiscontOpp3.stagename='Closed';
        InsertClosedDiscontOpp3.RecordTypeId = excludeRecdTypeId ;
        InsertClosedDiscontOpp3.ForecastCategoryName='closed';
        InsertClosedDiscontOpp3.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        InsertClosedDiscontOpp3.Price_Variance__c = 'NCR above 5%';
        InsertClosedDiscontOpp3.Key_Criteria__c = 'Lead Time';
        InsertClosedDiscontOpp3.IsQuoteCreatedInOtherSystem__c = 'YES';
        InsertClosedDiscontOpp3.Are_we_the_Incumbent__c = 'No' ;
        listOpportunity.add(InsertClosedDiscontOpp3);
        test.startTest();
        insert listOpportunity;
        List<Opportunity> updateOppList = new List<Opportunity>() ;
        Opportunity updateOpp1 = new Opportunity(Id =listOpportunity[0].Id,Forecast_Category__c = 'Exclude Commit',CPQ__c=true) ;
        Opportunity updateOpp2 = new Opportunity(Id =listOpportunity[1].Id,Forecast_Category__c = 'Exclude Upside' ) ;
        Opportunity updateOpp3 = new Opportunity(Id =listOpportunity[2].Id,Forecast_Category__c = 'Exclude Pipeline' ) ;
        Opportunity updateOpp4 = new Opportunity(Id =listOpportunity[3].Id,ForecastCategoryName = 'Commit', Forecast_Category__c= 'Pipeline' ) ;
        Opportunity updateOpp5 = new Opportunity(Id =listOpportunity[4].Id,ForecastCategoryName = 'Upside', Forecast_Category__c= 'Upside' ) ;
        Opportunity updateOpp6 = new Opportunity(Id =listOpportunity[5].Id,ForecastCategoryName = 'Pipeline', Forecast_Category__c= 'Commit' ) ;         
        updateOppList.add(updateOpp1) ;
        updateOppList.add(updateOpp2) ;
        updateOppList.add(updateOpp3) ;
        updateOppList.add(updateOpp4) ;
        updateOppList.add(updateOpp5) ;
        updateOppList.add(updateOpp6) ;
        update updateOppList ;
        OpportunityTriggerHandler objOpp = new OpportunityTriggerHandler();
        //  objOpp.onBoardOppPymntSites(updateOppList[0]);            
        // test.startTest();
        //////////////////////
        
        /*Opportunity InsertClosedOpenClassicOpp = Opportunities[6];
InsertClosedOpenClassicOpp.stagename='Proposing';
try{
insert InsertClosedOpenClassicOpp;
} catch(Exception e) {

}*/
        
        /*Opportunity OppRecd = new Opportunity(Id=InsertClosedOpenClassicOpp.Id) ;

OppRecd.IsQuoteCreatedInOtherSystem__c = 'YES';
OppRecd.stagename='Closed/Lost';
OppRecd.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
OppRecd.Key_Criteria__c = 'Lead Time';
OppRecd.Price_Variance__c = 'NCR above 5%';
try{
update OppRecd; 
}
catch(Exception e) {

}*/
        
        
        
        
        
        test.stopTest(); 
        
        
    }
    @isTest
    public static void PopulateForecastCategoryTest_2(){
        List<Opportunity> listOpportunity = new List<Opportunity>();
        List<Opportunity> listOpportunityClassic = new List<Opportunity>();
        Id excludeRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exclude from Funnel').getRecordTypeId();
        User userNonLightning= TestRecordsFactory.createUsers(NSCCommonInfoUtil.getIdOf('zuora_admin'),'zouraAdmin',1)[0];
        List<Opportunity>  Opportunities = TestRecordsFactory.returnOpportunities(15);
        for(Opportunity opp : Opportunities){
            opp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
        } 
        
        System.runAs(userNonLightning){
            Account acc = [SELECT Id, Active_Account__c FROM Account where Id = :Opportunities[3].AccountId];
            
            acc.Active_Account__c = true ;
            update acc ;
            
            /*Opportunity InsertClosedBookOpp = Opportunities[3];
InsertClosedBookOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
InsertClosedBookOpp.stagename='Closed/Booked';
InsertClosedBookOpp.Price_Variance__c = 'NCR above 5%';
InsertClosedBookOpp.Key_Criteria__c = 'Lead Time';
InsertClosedBookOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
listOpportunityClassic.add(InsertClosedBookOpp);

Opportunity InsertClosedLostClassicOpp = Opportunities[4];
InsertClosedLostClassicOpp.stagename='Closed/Lost';
InsertClosedLostClassicOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
InsertClosedLostClassicOpp.Price_Variance__c = 'NCR above 5%';
InsertClosedLostClassicOpp.Key_Criteria__c = 'Lead Time';
InsertClosedLostClassicOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
listOpportunityClassic.add(InsertClosedLostClassicOpp);

Opportunity InsertClosedDiscontClassicOpp = Opportunities[5];
InsertClosedDiscontClassicOpp.stagename='Closed/Discontinued';
InsertClosedDiscontClassicOpp.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
InsertClosedDiscontClassicOpp.Price_Variance__c = 'NCR above 5%';
InsertClosedDiscontClassicOpp.Key_Criteria__c = 'Lead Time';
InsertClosedDiscontClassicOpp.IsQuoteCreatedInOtherSystem__c = 'YES';
listOpportunityClassic.add(InsertClosedDiscontClassicOpp);*/
            
            
            Opportunity InsertOpp1 = Opportunities[5];
            InsertOpp1.RecordtypeId = excludeRecdTypeId ;
            InsertOpp1.stagename='Analyzing - NonFunnel';
            InsertOpp1.Forecast_Category__c = 'Exclude Pipeline' ;
            InsertOpp1.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp1.Price_Variance__c = 'NCR above 5%';
            InsertOpp1.Key_Criteria__c = 'Lead Time';
            InsertOpp1.IsQuoteCreatedInOtherSystem__c = 'YES';
            listOpportunityClassic.add(InsertOpp1);
            
            Opportunity InsertOpp2 = Opportunities[6];
            InsertOpp2.RecordtypeId = excludeRecdTypeId ;
            InsertOpp2.stagename='Analyzing - NonFunnel';
            InsertOpp2.Forecast_Category__c = 'Exclude Upside' ;
            InsertOpp2.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp2.Price_Variance__c = 'NCR above 5%';
            InsertOpp2.Key_Criteria__c = 'Lead Time';
            InsertOpp2.IsQuoteCreatedInOtherSystem__c = 'YES';
            listOpportunityClassic.add(InsertOpp2);
            
            Opportunity InsertOpp3 = Opportunities[7];
            InsertOpp3.RecordtypeId = excludeRecdTypeId ;
            InsertOpp3.stagename='Closing - NonFunnel';
            InsertOpp3.Forecast_Category__c = 'Exclude Commit' ;
            InsertOpp3.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp3.Price_Variance__c = 'NCR above 5%';
            InsertOpp3.Key_Criteria__c = 'Lead Time';
            InsertOpp3.IsQuoteCreatedInOtherSystem__c = 'YES';
            listOpportunityClassic.add(InsertOpp3);
            
            Opportunity InsertOpp4 = Opportunities[8];
            InsertOpp4.RecordtypeId = excludeRecdTypeId ;
            InsertOpp4.stagename='Analyzing - NonFunnel';
            InsertOpp4.ForecastCategoryName = 'Pipeline' ;
            InsertOpp4.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp4.Price_Variance__c = 'NCR above 5%';
            //InsertOpp4.Key_Criteria__c = 'Lead Time';
            InsertOpp4.IsQuoteCreatedInOtherSystem__c = 'YES';
            listOpportunityClassic.add(InsertOpp4);
            
            Opportunity InsertOpp5 = Opportunities[9];
            InsertOpp5.RecordtypeId = excludeRecdTypeId ;
            InsertOpp5.stagename='Analyzing - NonFunnel';
            InsertOpp5.ForecastCategoryName = 'Upside' ;
            InsertOpp5.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp5.Price_Variance__c = 'NCR above 5%';
            InsertOpp5.Key_Criteria__c = 'Lead Time';
            //InsertOpp5.IsQuoteCreatedInOtherSystem__c = 'YES';
            listOpportunityClassic.add(InsertOpp5);
            
            Opportunity InsertOpp6 = Opportunities[10];
            InsertOpp6.RecordtypeId = excludeRecdTypeId ;
            InsertOpp6.stagename='Closing - NonFunnel';
            InsertOpp6.ForecastCategoryName = 'Commit' ;
            InsertOpp6.DISCONTINUED_REASONS__C = 'Qualified Out by NCR';
            InsertOpp6.Price_Variance__c = 'NCR above 5%';
            InsertOpp6.Key_Criteria__c = 'Lead Time';
            InsertOpp6.IsQuoteCreatedInOtherSystem__c = 'NO';
            listOpportunityClassic.add(InsertOpp6); 
            
            insert listOpportunityClassic; 
            
            List<Opportunity> updateOppList1 = new List<Opportunity>() ;
            Opportunity updateOpps1 = new Opportunity(Id =listOpportunityClassic[0].Id,Forecast_Category__c = 'Exclude Upside' ) ;
            Opportunity updateOpps2 = new Opportunity(Id =listOpportunityClassic[1].Id,Forecast_Category__c = 'Exclude Commit' , stagename='Closed' ) ;
            Opportunity updateOpps3 = new Opportunity(Id =listOpportunityClassic[2].Id,Forecast_Category__c = 'Exclude Pipeline', Stagename='Analyzing' ) ;
            Opportunity updateOpps4 = new Opportunity(Id =listOpportunityClassic[3].Id,ForecastCategoryName = 'Commit', Forecast_Category__c= 'Upside' , stagename='Closed') ;
            Opportunity updateOpps5 = new Opportunity(Id =listOpportunityClassic[4].Id,ForecastCategoryName = 'Pipeline', Forecast_Category__c= 'Pipeline' ) ;
            Opportunity updateOpps6 = new Opportunity(Id =listOpportunityClassic[5].Id,ForecastCategoryName = 'Upside', Forecast_Category__c= 'Commit' , stagename='Analyzing') ;         
            updateOppList1.add(updateOpps1) ;
            updateOppList1.add(updateOpps2) ;
            updateOppList1.add(updateOpps3) ;
            updateOppList1.add(updateOpps4) ;
            updateOppList1.add(updateOpps5) ;
            updateOppList1.add(updateOpps6) ;
            update updateOppList1 ;
            
            
            
            
        }
        
        Account acc1 = [SELECT Id, Active_Account__c FROM Account where Id = :Opportunities[6].AccountId];
        
        acc1.Active_Account__c = true ;
        update acc1 ;
        
    }
    
    
    private static testMethod void Test_LeadConversion() {
        
        // testCustomSetting();
        
        CheckRecursive.checkLeadConversionRun();
        Test.startTest(); 
        Account acc =TestRecordsFactory.createAccount(); 
        RecordType PartnerRecType = [SELECT Id, SobjectType, Name, DeveloperName
                                     FROM RecordType
                                     WHERE SobjectType='Account'
                                     and DeveloperName='Partner'
                                     LIMIT 1];
        acc.RecordTypeId = PartnerRecType.Id;
        System.runAs(TestRecordsFactory.getUser()){
            update acc;
        }
        
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        
        RecordType DistibuRecType = [SELECT Id, SobjectType, Name, DeveloperName
                                     FROM RecordType
                                     WHERE SobjectType='Opportunity'
                                     and DeveloperName='Indirect_Include_in_Funnel_Distributor'
                                     LIMIT 1];
        System.debug('Account.RecordType.Name !!@@'+opp.Account.RecordType.Name);      
        opp.RecordTypeId = DistibuRecType.Id;
        update opp;
        Test.stopTest();
    }
    
    public static testMethod void Test_UpdateForecastCategory() {
        
        // testCustomSetting();
        
        Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        opp.RecordTypeId = includeInFunnelRecTypeId;
        Test.startTest();
        
        Value_Prompter__c  obj = new Value_Prompter__c (Opportunity__c = opp.Id);
        insert obj;
        
        opp.Forecast_Category__c = 'Pipeline';
        update opp;
        Try{
            opp.Industry__c = 'Retail';
            opp.ForecastCategoryName ='Commit';
            opp.Forecast_Category__c = 'Commit';
            update opp;
        }
        catch(Exception e)
        {
            String message = e.getMessage(); //
            system.assert(message.contains('You cannot commit this opportunity unless at least one question on the ValuePrompter tab is equal to yes'), 'message=' + message);
            
        }
        Test.stopTest();
    }
    
    public static testMethod void testSalesOrgUpdate() {
        
        // testCustomSetting();
        User Usr = [Select Id, profileId from User Where Name = 'Soup User'];
        system.assertNotEquals(Usr.Id,null);
        
        DisableCDMNSCSupportNotifications__c cdmNotificatin = new DisableCDMNSCSupportNotifications__c(Name='test', TurnMailOn__c = 'ON');
        insert cdmNotificatin;
        
        NSC_Support_Error_Notification__c nscNotification = new NSC_Support_Error_Notification__c (name='NSC Job Failure', ToEmailAddresses__c= 'test@ncr.com');
        insert nscNotification; 
        
        Sales_Org__c org1 = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232', ownerId=NSCCommonInfoUtil.getIdOf('Sales_ownerId'));
        Sales_Org__c org2 = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='12345', ownerId=NSCCommonInfoUtil.getIdOf('Sales_ownerId'));
        List<Sales_Org__c> soLIst = new List<Sales_Org__c>{org1, org2};
            insert soLIst;
        
        Account a;
        
        System.runAs(Usr) {
            a = new Account(name='Account-1');
            a.MDM_Data_Source_Code__c = 'CDM';
            a.Global_Sales_Org_Code__c = org1.Sales_Org_Code__c;
            insert a;
            
            Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
            Opportunity opp = TestRecordsFactory.createSimpleOpportunity(a);
            
            a.Global_Sales_Org_Code__c = org2.Sales_Org_Code__c;
            update a;             
        }
    }
    
    public static testMethod void testChannelLocalOffice() {
        User Usr = [Select Id, profileId from User Where Name = 'Soup User']; 
        Account account, channelAccount;
        
        System.runAs(Usr) {
            account = new Account(name = 'Test Acc',
                                  LOB__c='HOSPITALITY',
                                  Master_Customer_Number__c = 'TESTMCN00001X',
                                  Account_Country_Code__c = 'US',
                                  CurrencyIsoCode = 'USD',
                                  CDM_Account_Status__c = 'Active',
                                  Active_Account__c = true);
            insert account;
            
            channelAccount = new Account(
                Name='Test Company Name123',
                Account_Country_Code__c = 'US',
                LOB__c='HOSPITALITY',
                Active_Account__c = true,
                CDM_Account_Type__c='LOCAL OFFICE',
                CDM_Account_Status__c = 'Active',
                //CDM_Sub_Account_Type__c = 'LOCAL OFFICE',
                industry = 'HOSPITALITY:QSR',
                Project_Coordinator_Email__c = 'abc@test.com');
            insert channelAccount;
            
            cdm_Account_Relationship__c cdmAccRel = new cdm_Account_Relationship__c();
            cdmAccRel.Account__c=account.Id;
            cdmAccRel.Related_Account__c = channelAccount.Id;
            cdmAccRel.Relationship_Type__c='Local Office - End Customer';
            cdmAccRel.Name ='Local Office';
            //  cdmAccRel.Account_Number__c = 'TESTMCN00001X';
            cdmAccRel.Relationship_Code__c = 'End Customer Of';
            insert cdmAccRel;
        }   
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        opp.AccountID = account.id;
        opp.Channel_Office__c= channelAccount.id;
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.CPQ__c = TRUE;
        insert opp;
        SBQQ__Quote__c quote = TestRecordsFactory.createQuote(account.id, opp.Id, null, false); 
        
        NCR_Payments_Site__c paySite= new NCR_Payments_Site__c();
        paySite.InfiniceptApplicationId__c='123';
        paySite.Merchant_Application_Id__c = '123';
        paySite.Opportunity__c = opp.Id;
        paySite.Quote__c = quote.id;
        paySite.NCR_Payments_Application_Status__c = 'Approved'; 
        insert paySite;
        
        opp.payments_rep__c = userInfo.getUserId();
        opp.SBQQ__PrimaryQuote__c = quote.Id;
    opp.stagename = 'Closed/Booked';
    update opp;        
    }
    
    private Static void testCustomSetting(){
        /*No_Attach_Code_Profiles__c noAttache = new No_Attach_Code_Profiles__c();
noAttache.Name = 'Record1';
// noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
noAttache.Included_Payments_Profile__c = 'HOSP SMB Sales,04 NSC UI Administrator';
insert noAttache;*/
        
        All_profie_config__c noAttache = new All_profie_config__c();
        noAttache.Name = 'No Attach Codes Profiles';
        // noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        noAttache.Profile_Name__c  = 'HOSP SMB Sales,04 NSC UI Administrator';
        insert noAttache;
        
        Prod_Reason_Required__c  rsnReq = new Prod_Reason_Required__c();
        rsnReq.Name='Payments Related';
        rsnReq.On__c=true;
        rsnReq.Prod_Included__c='Aloha POS, Mobile Pay';
        insert rsnReq;
        
        //ProfileExcludeFromValidation__c prExc = new ProfileExcludeFromValidation__c();
        All_profie_list_config__c prExc = new All_profie_list_config__c();
        prExc.Name='01 GS Admin';
        insert prExc; 
        
    }
    
    public static testMethod void updateAmnt(){
        CheckRecursive.runOppRelatedObj = True;
        CheckRecursive.runOppRelatedObject();
        
        Ticket_Request_Event__c tre =new Ticket_Request_Event__c();
        tre.Event_Type__c = 'Falcons';
        tre.Event_Name_Date__c='vs. Miami Dolphins on 10/15/2017';
        tre.No_Of_Tickets_Available__c = '100';
        tre.Notes__c = 'Suite Tickets';
        tre.Event_Date__c = Date.today().addDays(2);
        //tre.Suite_Tickets_Available__c = '50';
        tre.Number_of_Parking_Passes_Available__c  = 200;
        tre.Lower_Level_Tickets_Available__c = '30';
        tre.Suite_Tickets_Available__c = '20';
        tre.VVIP_Tickets_Available__c = '50' ;
        insert tre;
        
        string pf = NSCCommonInfoUtil.getIdOf('Profile_31_GS_Account_Manager');
        User user= TestRecordsFactory.createUsers(pf,'31_GS_Account_Manager_TestUser',1)[0];
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
        
        Ticket_Request__c tr = new Ticket_Request__c();
        
        
        //tr.Name = 'Atlanta United - vs. LA Galaxy on 9/20/2017';
        tr.Employee_Name__c = user.id;
        tr.Phone_Number__c = '9876543210';
        tr.Other_Employee_Reps_Attending__c = 'Test User';
        tr.Contact_Name__c = con.id;
        tr.Contacts_Guest__c = 'Test123'; 
        tr.Opportunity__c = opp.id;
        //tr.No_of_Tickets_Requested__c = '16';
        tr.Event_Type__c = 'Falcons';
        tr.Event_Name_Date__c = 'vs. Miami Dolphins on 10/15/2017';
        tr.Number_of_Parking_Passes_Available__c  = 10;
        tr.No_of_Tickets_Requested__c = '2';
        tr.Approval_Status__c = 'Approved';
        insert tr;
        
        Junction_Ticket_Opportunity__c junObj = new Junction_Ticket_Opportunity__c();
        junObj.Related_Opprtunity_to_Request__c = opp.id;
        junObj.Related_TicketRequest__c = tr.id;
        insert junObj;
        
        Deal_Registration__c dealRegistrationRecord = PRM_TestRecordsFactory.createDealRegistration('Test Deal Dev', 'Created');
        dealRegistrationRecord.Is_Workflow_Scheduled_for_Sales_Leader__c = FALSE;
        
        Database.SaveResult rslt =  Database.Insert(dealRegistrationRecord);
        // opp.Linked_Special_Bid_Registration__c = dealRegistrationRecord.id;
        
        opp.Amount = 20000;
        //CheckRecursive.runOppRelatedObject();
        opp.Linked_Special_Bid_Registration__c = null;         
        test.startTest();
        update opp;
        
        //insert altify objects
        ALTF__Solution__c solObj = new ALTF__Solution__c();
        solObj.Name ='Products Unassigned';
        insert solObj;
        
        ALTF__Account_Plan_Type__c obj1 = new ALTF__Account_Plan_Type__c();
        obj1.name ='Test Type';
        insert obj1;
        
        altf__account_plan__c obj = new altf__account_plan__c();
        obj.Name ='Test AccountPlan';
        obj.ALTF__Account_Plan_Type__c =obj1.id;
        insert obj;
        
        ALTF__Account_Plan_Revenue_Target__c revObj = new ALTF__Account_Plan_Revenue_Target__c();
        revObj.Name ='Test Revenue';        
        revObj.ALTF__Start_Date__c =Date.parse('8/29/2021');
        revObj.ALTF__End_Date__c =Date.parse('8/31/2021');
        revObj.ALTF__Revenue_Target__c = 100;
        revObj.ALTF__Account_Plan__c = obj.id;
        insert revObj;
        
        ALTF__Account_Plan_Row__c objRecd = new ALTF__Account_Plan_Row__c();
        objRecd.ALTF__Account__c = opp.AccountId;
        objRecd.ALTF__Type__c ='Division';
        objRecd.ALTF__Account_Plan__c = obj.id;
        insert objRecd;
        
        Map<Id,Id> delAltOppMap = new Map<Id,Id>();
        delAltOppMap.put(opp.id, opp.AccountId);
        OpportunityTriggerHandler.updateRelatedObject(new Set<ID>{opp.id},new Set<ID>{dealRegistrationRecord.id},new Set<ID>{opp.id}, delAltOppMap);
        OpportunityTriggerHandler.FutureUpdateRelatedObj(new Set<ID>{opp.id},new Set<ID>{dealRegistrationRecord.id}, new Set<ID>{opp.id}, delAltOppMap);
        OpportunityTriggerHandler.Sendfailmsg(new List<Database.SaveResult>{rslt}, new List<sObject>{dealRegistrationRecord});
        test.stopTest();
        OpportunityTriggerHandler mopp = new OpportunityTriggerHandler();
        mopp.autoPopPaymntRep(new List<opportunity>{opp},new Set<id>{opp.id});
        
        
    }
    
    
    public static testMethod void testValOppForMxdServ() {
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp1 = TestRecordsFactory.createSimpleOpportunity(acc);
        Renewable_Products__c renewPrds = new Renewable_Products__c(name='Record1', Product_Revenue_Types__c='HWM,SWM,Managed Service');
    insert renewPrds;

        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
      
        Product2 p = new Product2(); 
        p.Name = 'Test Product';
        p.Product_Category__c ='Software';
        p.Family ='Solution';
        p.service_offer_category__c='SWM';
        p.CanUseQuantitySchedule=true;
        insert p;
        
        PricebookEntry pe = new PricebookEntry();
        pe = TestRecordsFactory.createPriceBookEntry(p);
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.opportunityId =opp1.Id;
        oli.PriceBookEntryId= pe.Id;
        oli.Quantity=10;
        oli.TotalPrice=1000;
        oli.Product_Category__c=p.Product_Category__c ;
        oli.SW_Unattached_Code__c='Attached';
        oli.Opportunity_Line_Item_Type__c = 'New';
        oliList.add(oli);
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.opportunityId =opp1.Id;
        oli1.PriceBookEntryId= pe.Id;
        oli1.Quantity=10;
        oli1.TotalPrice=1000;
        oli1.Product_Category__c=p.Product_Category__c ;
        oli1.SW_Unattached_Code__c='Attached';
        oli1.Opportunity_Line_Item_Type__c = 'Renewal';
        oliList.add(oli1);
       
        try{
            insert oliList;
        }
        catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }
    }
    
    public static Opportunity createSimpleOpportunity() {
        // create new Opportunity object 
        Sales_Org__c s = new Sales_Org__c(name = 'test org', Is_Active_in_RoR__c = true, Sales_Org_Code__c='126232',IsPrimary__c = true);
        Competitors__c c = new Competitors__c(name = 'testing competitor');
        
        Opportunity opp = new Opportunity();
        opp.name = 'abc';
        //opp.AccountID = createAccount().id;
        opp.AccountID = TestRecordsFactory.createAccount('TEST000012').id;
        opp.Name = 'OppQuote Linkage Opportunity';
        opp.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp.CURRENCYISOCODE = 'USD';
        //opp.Reasons_for_no_Payment_Processing__c='Existing Contract (Other)';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Opportunity','Include in Funnel');
        opp.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp.EndCustomerUnknown__c = true;
        insert s;
        insert opp;
        return opp;
    }
    public static void createSimpleOpportunityTest() {
        // create new Opportunity object 
        User u= TestRecordsFactory.createUsers(NSCCommonInfoUtil.getIdOf('Banking_Account_Manager'),'31_GS_Account_Manager_TestUser',1)[0];
        
        Opportunity opp = createSimpleOpportunity();
        Opportunity opp1 = createSimpleOpportunity();
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        QD.Annuity_Quote_Status__c = 'Test';
        Qd.Quote_Number__c='123';
        QD.MCN__c = 'TEST000012';
        QD.Country_Code__c='US';
        QD.Opportunity__c = opp1.id;
        QD.Opportunity_No__c=opp1.Opportunity_Number__c;
        insert QD;
        System.runAs(u) {
            //null scenario
            opp.stagename='Closed/Booked';
            opp.Price_Variance__c = 'NCR above 5%';
            opp.Key_Criteria__c = 'Lead Time';
            try{
                update opp;
            }
            catch(Exception e){
                System.debug('Exception Caught'+e.getMessage());
            }
            
        }
    }
    public static Account createAccount(){
        Account a = new Account(name = 'Test Acc1',
                                LOB__c = 'FINANCIAL',
                                MDM_Data_Source_Code__c='CDM',
                                Global_Sales_Org_Code__c='126232',
                                Master_Customer_Number__c = 'TESTMCN00001Y',
                                Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD',
                                Active_Account__c = true);
        System.runAs(TestRecordsFactory.getUser()){
            insert a;
            
        }
        return a;
    }
    public static testMethod void oppTriggerMain(){
        CPQTriggerControl.cpqSpclHdlgNew=true;
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        update opp;
    }
    
    @isTest
    private static void testUpdateCATMProductRollup() {
        Profile prof = [SELECT Id FROM Profile WHERE Name='Data Backup and Recovery Admin']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorvjkhbvjhgejghwefg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = prof.Id, 
                          Quicklook_ID__c = '293105',FederationIdentifier ='stringtest',
                          TimeZoneSidKey='America/New_York', UserName='standarduser@testorvjvhfvgvkhbvjhgejghwefg.com');
        insert u;
        
        System.runAs(u) {
            Account a = new Account();
            a.Name = 'test';
            a.type = 'Customer';
            a.Active_Account__c = TRUE;
            a.Master_Customer_Number__c='S123';
            insert a;
            
            List<Opportunity> opList = new List<Opportunity>();
            for(Integer i=0;i<10;i++) {
                Opportunity op = new Opportunity();
                op.Name = 'test'+i;
                op.CATM_Record__c = TRUE;
                op.AccountId = a.Id;
                //op.Expected_Service_Start_Date__c = date.today();
                op.Contract_Term_Mths__c = 1;
                op.Pricebook2Id= GlobalVariable.pricebookId;
                op.type = 'Indirect Channel';
                op.CURRENCYISOCODE = 'USD';
                op.INVOICE_TRIGGER__C = 'Shipment';
                op.closeDate = System.TODAY();
                op.stagename = 'Analyzing';
                op.ForecastCategoryName = 'Pipeline';
                op.Forecast_Category__c = 'Pipeline';
                op.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
                op.EndCustomerUnknown__c = true;
                op.CPQ__c = FALSE;
                opList.add(op);
            }

            insert opList;
            
            List<Product2> prodList = new List<Product2>();
            for(Integer i=0;i<12;i++) {
                Product2 p = new Product2();
                p.Name = 'Test Product Test Product'+i;
                p.pmdm_product_family__c ='Hardware like a GPU' +i;
                prodList.add(p);
            }
            insert prodList;
            
            List<PricebookEntry> peList = new List<PricebookEntry>();
            for(Product2 pr: prodList) {
                PricebookEntry pe = new PricebookEntry();
                pe = TestRecordsFactory.createPriceBookEntry(pr);
                peList.add(pe);
            }
            
            List<OpportunityLineItem> oliList1 = new List<OpportunityLineItem>();
            for(PricebookEntry pe: [select id, product2.product_category__c from PricebookEntry where pricebook2Id =: GlobalVariable.pricebookId]) {
                for(Opportunity o: opList){
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli.opportunityId =o.Id;
                    oli.PriceBookEntryId= pe.Id;
                    oli.Quantity=10;
                    oli.TotalPrice=1000;
                    oli.SW_Unattached_Code__c='Attached';
                    oli.Number_of_Terms__c=12;
                    oliList1.add(oli);                  
                }
            }
            
            Test.startTest();
            insert oliList1;
            Test.stopTest();
            Opportunity opp = [select id, products__c, product_category__c from opportunity limit 1];
            System.debug('Opportunity Products: ' + opp.products__c);
            System.assert(opp.products__c.length() != 0);
            System.debug('Opportunity Product Category: ' + opp.product_category__c);
            System.assert(opp.Product_Category__c.length() != 0);
        }
    }
}