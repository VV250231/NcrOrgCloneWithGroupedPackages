@isTest
private class MDFExpenseDetailExtClaim_Test{
    static testMethod void testCorrectMDFRequest() {   
    SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
    SFDC_MDF_Claim__c mdfCliam = PrepareMDFTestDataUtil.prepareMDFClaimRecord(mdfReq.Id);
    MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
    mdfExpenseDetails.Fund_Claim__c = mdfCliam.id;
    update mdfExpenseDetails;
    PageReference pageRef = Page.MDFExpenseDetailClaim;
     Test.setCurrentPage(pageRef);
     ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfCliam);
     MDFExpenseDetailExtClaim cont = new MDFExpenseDetailExtClaim(sc);
     cont.getMdfClaim();
     cont.editMode();
     cont.cancelEditing();
     cont.saveExpenseDetail();
      ApexPages.currentPage().getParameters().put('rowIndex','0');
      cont.deleteExpenseDetail();
      system.assertEquals(cont.pageMode,'view');
      
      
    }
}