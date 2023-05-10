@isTest
private class USMDetailControllerTest {

	private static testMethod void tescheckUSMOpportunityt() {
	    Opportunity oppNew1 = TestRecordsFactory.createOpportunityWithLineItem() ;
	    USM_Opportunity_Detail__c usmDet1 = new USM_Opportunity_Detail__c(Name='USM001') ;
	    insert usmDet1 ;
	    Test.startTest() ;
	    
	    USMDetailController.checkUSMOpportunity(String.valueOf( oppNew1.Id ) ) ; 
	    USMDetailController.checkClosedOpportunity(oppNew1.Id ) ;
        system.assertEquals(USMDetailController.checkClosedOpportunity(oppNew1.Id ),false);
	    USMDetailController.checkEngagedService(oppNew1.Id) ;
	    USMDetailController.getOpportunity(oppNew1.Id) ;
	    USMDetailController.getUserDetail() ; 
         USMDetailController.saveUSMOpportunity(usmDet1);
	    USMDetailController.setServiceSales(oppNew1) ;
	    USMDetailController.callUSMService(oppNew1, usmDet1 , 'TestQL01')  ;
	    USMDetailController.callUSM_LinkService(oppNew1.Id, 'USM001') ;
	    Test.stopTest() ;

	}

}