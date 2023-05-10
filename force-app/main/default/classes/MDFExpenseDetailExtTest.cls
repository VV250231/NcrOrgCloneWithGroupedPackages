@isTest
public class MDFExpenseDetailExtTest {

    static testMethod void testMDFExpenseDetailExt() {   
        SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
        MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
        MDF_Expense_Detail__c mdfExpenseDetails1  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
        MDF_Expense_Detail__c mdfExpenseDetails2  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
        MDF_Expense_Detail__c mdfExpenseDetails3  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
        
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);
     	MDFExpenseDetailExt cont = new MDFExpenseDetailExt(sc);
        
        cont.getMdfRequest();
        cont.editMode();
        cont.cancelEditing();
        cont.saveExpenseDetail();
       
        ApexPages.currentPage().getParameters().put('rowIndex','0');
        cont.deleteExpenseDetail();
        Boolean isValid = cont.isOpsTeamMember;
        system.assertEquals(isValid,false);
    }
}