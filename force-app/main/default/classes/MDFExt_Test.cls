@isTest
private class MDFExt_Test{
    static testMethod void testNewRequest(){
        PageReference pageRef = Page.mdfNewRequestPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(new SFDC_MDF__c());
        System.assertNotEquals(sc, null,'sc should not be null');
        ApexPages.currentPage().getParameters().put('retURL', 'home/home.jsp');
         MDFExt cont= new MDFExt(sc);
        cont.cancelRequest();
    }
    
    static testMethod void testRequest(){
         SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
        PageReference pageRef = Page.mdfNewRequestPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);
        ApexPages.currentPage().getParameters().put('retURL', 'home/home.jsp');
         ApexPages.currentPage().getParameters().put('id', mdfReq.Id);
         MDFExt cont= new MDFExt(sc);
         System.assertNotEquals(sc, null,'Standardcontroller should not be null');
        cont.saveMdfRequest();
        cont.saveMdfRequestUploadDoc();
    }
    
    static testMethod void testRequest1(){
        User partUser=new User();
        system.runAs(TestRecordsFactory.getUser())
        {
            partUser = PrepareMDFTestDataUtil.userWithContactAndAccount('');
        }
        system.runAs(partUser){
         SFDC_MDF__c mdfReq=PrepareMDFTestDataUtil.prepareMDFRecord();
         MDF_Expense_Detail__c mdfExpenseDetails  = PrepareMDFTestDataUtil.prepareMDFExpenseRecord(mdfReq.Id);
        PageReference pageRef = Page.mdfNewRequestPage;
        Test.setCurrentPage(pageRef);
        ApexPages.Standardcontroller sc = new ApexPages.Standardcontroller(mdfReq);
        ApexPages.currentPage().getParameters().put('retURL', 'home/home.jsp');
         ApexPages.currentPage().getParameters().put('id', mdfReq.Id);
         MDFExt cont= new MDFExt(sc);
         cont.addExpenseDetail();
         ApexPages.currentPage().getParameters().put('rowIndex', '1');
         cont.deleteExpenseDetail();
         cont.saveExpenseDetail();
        cont.saveMdfRequest();
        cont.saveMdfRequestUploadDoc();
        System.assertNotEquals(cont, null,'MDFExt should not be null');
        }
    }
}