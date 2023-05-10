@isTest
public class MDFTriggerTests {
     public static boolean IsTest = false;
    
    /**
     * Unit test for Trigger - updateBudget_FundRequest
     */
    public static testMethod void testUpdateBudget_FundRequest() {
         MDFTriggerTests.IsTest = true;
        //create new account
        Account a = testrecordsfactory.createAccount('Test');
        a.Partner_Type__c ='Distributor';
        a.Account_Region__c='AMERICAS';
        a.IsPartner = true;
        System.runAs(TestRecordsFactory.getUser()){
        update a;
        }
        Account b = testrecordsfactory.createAccount('Tested');
        b.Partner_Type__c ='Distributor';
        b.Account_Region__c='AMERICAS';
        b.IsPartner = true;
        System.runAs(TestRecordsFactory.getUser()){
        update b;
        }
        //create new budget
        //SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        //insert budget;
        //SFDC_Budget__c budget1 = [Select name from SFDC_Budget__c limit 1];
        //budget1.name = 'test1';
        //budget1.Account__c = b.Id;
        //update budget1;
        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c();
        mdf.Name= 'test-MDF';
        mdf.Activity_Date__c= Date.today();
        mdf.End_Date__c= Date.today().addDays(1);
        mdf.Activity_Type__c= 'Event - Roadshow';
        mdf.Other_Vendors_Represented__c='Micros';
        mdf.Activity_Description__c='TestDescription';
        mdf.Number_of_Leads__c= 1000;       
        mdf.Status__c='Request Created'; 
        //mdf.budget__c = budget.Id;
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        mdf.Account__c = a.id;
        mdf.Request_Submission_Date__c = system.today();
        mdf.Total_NCR_Estimated_Participation__c = 1000;
        insert mdf;
        
        a = [Select id, Funds_Requested_YTD__c from account where id =: a.id limit 1];
        System.assertEquals(a.Funds_Requested_YTD__c, 1000);
        
        /*System.assertEquals(1000, [select Approved_Requests__c from SFDC_Budget__c where id = :budget.id].Approved_Requests__c);*/
                             
        
        mdf.amount__c = 2000;
        
        update mdf;
        /*System.assertEquals(2000, [select Approved_Requests__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Requests__c);*/
        
        delete mdf;
        /*System.assertEquals(0, [select Approved_Requests__c from SFDC_Budget__c 
                             where id = :budget.id].Approved_Requests__c);*/
    }
    

    /**
     * Unit test for Trigger - updateBudget_FundClaim
     * Unit test for Trigger/Classes -FundClaimTrigger,FundClaimHandler,FundRequestTrigger,FundRequestHandler 
     */
    public static testMethod void testUpdateBudget_FundClaim() {
        //create new account
        Test.startTest();
        Account a = testRecordsFactory.createAccount();
        //create new budget
        SFDC_MDF__c mdf = new SFDC_MDF__c();
        mdf.Name= 'test-MDF';
        mdf.Activity_Date__c= Date.today();
        mdf.End_Date__c= Date.today().addDays(1);
        mdf.Activity_Type__c= 'Event - Roadshow';
        mdf.Other_Vendors_Represented__c='Micros';
        mdf.Activity_Description__c='TestDescription';
        mdf.Number_of_Leads__c= 1000;       
        mdf.Status__c='Request Created'; 
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        insert mdf;
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test',Status__c='Created', Numbers_of_Leads__c=1000,
                 amount__c = 1000, approved__c = true,fund_request__c=mdf.id);
        insert mdfClaim;
        
        
       // System.assertEquals(1000, [select Approved_Claims__c from SFDC_Budget__c 
                             //where id = :budget.id].Approved_Claims__c);
        
        SFDC_MDF_Claim__c mdfClaim1 = [Select id,amount__c,Fund_Request__c,Released_Funds__c from SFDC_MDF_Claim__c where name ='test'];
        mdfClaim1.amount__c = 2000;
        SFDC_MDF__c mdf1 = PrepareMDFTestDataUtil.prepareMDFRecord();
        mdfClaim1.Fund_Request__c =mdf1.id;
        mdfClaim1.Released_Funds__c = 25;
        update mdfClaim1;
        Test.stopTest();
        
         mdf = [Select id,No_of_Submitted_Claims__c from SFDC_MDF__c where id =: mdf.id limit 1];
        system.assertEquals(mdf.No_of_Submitted_Claims__c, 0);
        //System.assertEquals(2000, [select Approved_Claims__c from SFDC_Budget__c 
                                //where id = :budget.id].Approved_Claims__c);
        
        //delete mdfClaim;
        //System.assertEquals(0, [select Approved_Claims__c from SFDC_Budget__c 
                             //where id = :budget.id].Approved_Claims__c);
    }    

    /**
     * Unit test for Triggers - updateFundClaimWithBudget
     */
    public static testMethod void testUpdateFundClaimWithBudget() {
    
        //create new account
        Account a = testRecordsFactory.createAccount();

        //create new budget
        /*SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        budget.Approved_Requests__c = Decimal.valueOf('1000');
        insert budget;*/

        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c();
        mdf.Name= 'test-MDF';
        mdf.Activity_Date__c= Date.today();
        mdf.End_Date__c= Date.today().addDays(1);
        mdf.Activity_Type__c= 'Event - Roadshow';
        mdf.Other_Vendors_Represented__c='Micros';
        mdf.Activity_Description__c='TestDescription';
        mdf.Number_of_Leads__c= 1000;       
        mdf.Status__c='Request Created'; 
        //mdf.budget__c = budget.Id;
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        insert mdf;
        
        
        //create new fund claim
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test', Fund_Request__c = mdf.id);
        insert mdfClaim;

        //System.assertEquals(budget.id, [select Budget__c from SFDC_MDF_Claim__c 
                             //where id = :mdfClaim.id].Budget__c);
        System.assertNotEquals(mdf.id, null);
        
    }
    
   /*
    * unit test method for RecalculateBudget class
    */  
    public static testMethod void testCalculate() {
        //create new account
        Account a = testRecordsFactory.createAccount();

        //create new budget
        /*SFDC_Budget__c budget = new SFDC_Budget__c(name = 'test', Account__c = a.Id);
        insert budget;*/

        //create new fund request
        SFDC_MDF__c mdf = new SFDC_MDF__c();
        mdf.Name= 'test-MDF';
        mdf.Activity_Date__c= Date.today();
        mdf.End_Date__c= Date.today().addDays(1);
        mdf.Activity_Type__c= 'Event - Roadshow';
        mdf.Other_Vendors_Represented__c='Micros';
        mdf.Activity_Description__c='TestDescription';
        mdf.Number_of_Leads__c= 1000;       
        mdf.Status__c='Request Created'; 
        //mdf.budget__c = NULL;
        mdf.amount__c = Decimal.valueOf('1000'); 
        mdf.Approved__c = true;
        mdf.Account__c = a.id;
        mdf.Request_Submission_Date__c = system.today();
        mdf.Total_NCR_Estimated_Participation__c = 1000;
        insert mdf;
        
          a = [Select id, Funds_Requested_YTD__c from account where id =: a.id limit 1];
        System.assertEquals(a.Funds_Requested_YTD__c, 1000);
        system.debug('a.Funds_Requested_YTD__c'+a.Funds_Requested_YTD__c);
        
        
        
        
        //create new fund claim
        //SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c(name = 'test', 
               // budget__c = budget.Id, amount__c = 1000, approved__c = true,fund_request__c=mdf.id);
        //insert mdfClaim;
        //assert that the budget has the right fund claim amount
        //budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                             //where id = :budget.id];
        //System.assertEquals(1000, budget.Approved_Requests__c);
        //System.assertEquals(1000, budget.Approved_Claims__c);
        

        //now change the amounts on the budget
        //budget.Approved_Requests__c = 2000;
        //budget.Approved_Claims__c = 2000;
        //update budget;
        //assert that the budgets now has the wrong fund request and claim amounts
        //budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                            // where id = :budget.id];
        //System.assertNotEquals(1000, budget.Approved_Requests__c);
        //System.assertNotEquals(1000, budget.Approved_Claims__c);
        
        //now call calculate() to recalculate the amounts
        //RecalculateBudget.calculate(budget.Id);
        //assert that the budget has the right fund claim amount
        //budget = [select Approved_Requests__c, Approved_Claims__c from SFDC_Budget__c 
                             //where id = :budget.id];
        //System.assertEquals(1000, budget.Approved_Requests__c);
        //System.assertEquals(1000, budget.Approved_Claims__c);

    }
    
    /**
     * Unit test for SelectBudgetController
     */
    /*public static testMethod void testSelectBudgetController() {
        SelectBudgetController c = new SelectBudgetController();    
        c.init(true);
        c.init(false);
        Account a = testRecordsFactory.createAccount();
        SFDC_Budget__c budget = new SFDC_Budget__c(Account__c = a.Id);
        insert budget;
        //create new fund request
        SFDC_MDF__c fundRequest= new SFDC_MDF__c();
        fundRequest.Name= 'test-MDF';
        fundRequest.Activity_Date__c= Date.today();
        fundRequest.End_Date__c= Date.today().addDays(1);
        fundRequest.Activity_Type__c= 'Event - Roadshow';
        fundRequest.Other_Vendors_Represented__c='Micros';
        fundRequest.Activity_Description__c='TestDescription';
        fundRequest.Number_of_Leads__c= 1000;       
        fundRequest.Status__c='Request Created'; 
        fundRequest.budget__c = budget.Id;
        fundRequest.amount__c = Decimal.valueOf('1000'); 
        fundRequest.Approved__c = true;
        fundRequest.Account__c = a.Id;
        insert fundRequest;
        
        //PageReference pageRef = Page.selectBudget;
        //Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('fr', fundRequest.Id);
        ApexPages.currentPage().getParameters().put('mac', '1');
        ApexPages.currentPage().getParameters().put('budgetId',budget.Id);
        SelectBudgetController controller = new SelectBudgetController(); 
        controller.init(false);
        controller.getBudgetList();
        controller.getError();
        controller.assignBudget();
        controller.cancel();
        controller.confirmAssignment();


    }/*
     /**
     * Unit test for SelectBudgetController
     */
    /*public static testMethod void testSelectBudgetController1() {
        SelectBudgetController c = new SelectBudgetController();    
        c.init(true);
        c.init(false);
        Account a = testRecordsFactory.createAccount();
        SFDC_Budget__c budget = new SFDC_Budget__c(Account__c = a.Id);
        insert budget;
        //create new fund request
        SFDC_MDF__c fundRequest= new SFDC_MDF__c();
        fundRequest.Name= 'test-MDF';
        fundRequest.Activity_Date__c= Date.today();
        fundRequest.End_Date__c= Date.today().addDays(1);
        fundRequest.Activity_Type__c= 'Event - Roadshow';
        fundRequest.Other_Vendors_Represented__c='Micros';
        fundRequest.Activity_Description__c='TestDescription';
        fundRequest.Number_of_Leads__c= 1000;       
        fundRequest.Status__c='Request Created'; 
        fundRequest.budget__c = budget.Id;
        fundRequest.amount__c = Decimal.valueOf('1000'); 
        fundRequest.Approved__c = true;
        insert fundRequest;
        
        //PageReference pageRef = Page.selectBudget;
        //Test.setCurrentPage(pageRef);
        // Add parameters to page URL
        ApexPages.currentPage().getParameters().put('fr', fundRequest.Id);
        ApexPages.currentPage().getParameters().put('mac', '1');
        SelectBudgetController controller = new SelectBudgetController(); 
        controller.init(false);
        controller.getBudgetList();
        controller.getError();
        controller.assignBudget();
        controller.cancel();
        controller.confirmAssignment();


    }*/
}