@istest
public class CreateMDFClaimCmpControllerTest 
{
    public static testmethod void testCreateMDFClaimCmpController() 
    {
        SFDC_MDF__c mdfReq= new SFDC_MDF__c();
        mdfReq.Name= 'Test Activity';
        mdfReq.Activity_Date__c= Date.today()+ 60;
        mdfReq.End_Date__c= mdfReq.Activity_Date__c.addDays(1);
        mdfReq.Activity_Type__c= 'Event – Webinar';
        mdfReq.Other_Vendors_Represented__c='Micros';
        mdfReq.Activity_Description__c='TestDescription';
        mdfReq.Number_of_Leads__c= 1000;
        mdfReq.Status__c='Request Created'; 
        insert mdfReq;
        CreateMDFClaimCmpController obj = new CreateMDFClaimCmpController();
        CreateMDFClaimCmpController.getClaimDetails(mdfReq.Id);
        
        List<MDF_Expense_Detail__c> lstExpense = new List<MDF_Expense_Detail__c>();
        lstExpense.add(new MDF_Expense_Detail__c(Actvity__c = 'test'));
        insert lstExpense;
        SFDC_MDF__c mdfReq1= new SFDC_MDF__c();
        
        SFDC_MDF_Claim__c mdfClaim = new SFDC_MDF_Claim__c();
        mdfReq1.id =CreateMDFClaimCmpController.createMDFClaim(mdfReq, mdfClaim, lstExpense);
        System.assertNotEquals(mdfReq1.id, null);
    }
}