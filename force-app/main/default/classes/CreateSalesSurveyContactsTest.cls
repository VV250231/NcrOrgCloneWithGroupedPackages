@isTest
public class CreateSalesSurveyContactsTest {
    Public Static User getUser(){        
        User Usr = [Select Id from User Where Name = 'Soup User'];
        return Usr;
    }
    public static testmethod void testsaveContacts(){
        Account acct = new Account();
        acct.name = 'Test Account';
        System.runAs(getUser()){
            insert acct;
        }
        
        CPQ_Sales_Survey__c ss = new CPQ_Sales_Survey__c();
        ss.DeliverToSite1__c = acct.Id;
        //ss.Salesforce_Quote_Id__c = '';
        insert ss;
        
        List<Contact> conlist = new List<Contact>();
        Contact con1 = new Contact();
        con1.FirstName = 'FirstNametest1';
        con1.LastName = 'LastNametest1';
        con1.Phone = 'Phonetest1';
        conlist.add(con1);
        Contact con2 = new Contact();
        con2.FirstName = 'FirstNametest2';
        con2.LastName = 'LastNametest2';
        con2.Phone = 'Phonetest2';
        conlist.add(con2);
        
        CreateSalesSurveyContactsApexController.saveContacts(acct.id,ss.id,conlist);
        CreateSalesSurveyContactsApexController.getAllContact(acct.id);
        CreateSalesSurveyContactsApexController.getAllSalesSurveyContact(ss.id);
        
    }
    public static testmethod void testsaveCustomerGoal(){
        Account acct = new Account();
        acct.name = 'Test Account';
        System.runAs(getUser()){
            insert acct;
        }
        
        CPQ_Sales_Survey__c ss = new CPQ_Sales_Survey__c();
        ss.DeliverToSite1__c = acct.Id;
        //ss.Salesforce_Quote_Id__c = '';
        insert ss;
        
        List<SalesSurveyCustomerGoal__c> cglist = new List<SalesSurveyCustomerGoal__c>();
        SalesSurveyCustomerGoal__c cg1 = new SalesSurveyCustomerGoal__c();
        cg1.Name = 'Nametest1';
        cg1.Details__c = 'Detailstest1';
        cg1.Aligned_Solution__c = 'Aligned_Solutiontest1';
        cglist.add(cg1);
        SalesSurveyCustomerGoal__c cg2 = new SalesSurveyCustomerGoal__c();
        cg2.Name = 'Nametest2';
        cg2.Details__c = 'Detailstest2';
        cg2.Aligned_Solution__c = 'Aligned_Solutiontest2';
        cglist.add(cg2);
        
        createCustomerGoal.saveCustGoals(ss.id,cglist);
        createCustomerGoal.getAllSalesSurveyCustomerGoals(ss.id);
        List<String> my_list = new List<String>();
        my_list.add('test1');
        my_list.add('test2');
        RemoveHTMLTags.stripHtmlTags(my_list);
    }
    public static testmethod void testTechnicalReviewApprovalProcess(){
        Account acct = new Account();
        acct.name = 'Test Account';
        System.runAs(getUser()){
            insert acct;
        }
        
        CPQ_Sales_Survey__c ss = new CPQ_Sales_Survey__c();
        ss.DeliverToSite1__c = acct.Id;
        //ss.Salesforce_Quote_Id__c = '';
        insert ss;
        
        Technical_Review__c tr = new Technical_Review__c();
        //tr.CPQQuote__c =
        tr.Notes__c = 'test notes';
        tr.Sales_Survey__c = ss.Id;
        insert tr;
        list<Id> idslist = new list<Id>();
        idslist.add(tr.Id);
        TechnicalReviewApprovalProcess.SubmitForTechnicalReview(idslist);
    }
}