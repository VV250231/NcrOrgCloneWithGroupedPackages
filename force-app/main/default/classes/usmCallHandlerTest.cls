@isTest
private class usmCallHandlerTest {

	private static testMethod void test() {
	    
	    List<USM__c> usmCustListSetting = new List<USM__c>() ;
	    USM__c customSetting1 = new USM__c(Name= 'Endpoint_Create' , Value__c = 'https://test.sb.ncr.com:443/int/Opportunity/Services/NSCOpportunitySyncPS') ;
	    USM__c customSetting2 = new USM__c(Name= 'Endpoint_linking' , Value__c = 'https://test.sb.ncr.com/int/Opportunity/Services/OpportunityLinkageSyncPS') ;
	    USM__c customSetting3 = new USM__c(Name= 'Endpoint_nscopportunityupdate' , Value__c = 'https://test.sb.ncr.com/int/NSC/Opportunity/NSCUpdOpportunityPS') ;
	    USM__c customSetting4 = new USM__c(Name= 'Endpoint_Product' , Value__c = 'https://test.sb.ncr.com:443/int/NSC/Product/NSCProductsPS') ;
	    USM__c customSetting5 = new USM__c(Name= 'Password' , Value__c = 'test') ;
	    USM__c customSetting6 = new USM__c(Name= 'turnoffusmSyncForSandbox' , Value__c = 'false') ;
	    USM__c customSetting7 = new USM__c(Name= 'username' , Value__c = 'TCCYY') ;
	    
	    usmCustListSetting.add( customSetting1) ;
	    usmCustListSetting.add( customSetting2) ;
	    usmCustListSetting.add( customSetting3) ;
	    usmCustListSetting.add( customSetting4) ;
	    usmCustListSetting.add( customSetting5) ;
	    usmCustListSetting.add( customSetting6) ;
	    usmCustListSetting.add( customSetting7) ;
	    
	    insert usmCustListSetting ;
	    
	    Opportunity oppNew1 = TestRecordsFactory.createOpportunityWithLineItem() ;
	    USM_Opportunity_Detail__c usmDet1 = new USM_Opportunity_Detail__c(Name='USM001') ;
	    insert usmDet1 ;
	    system.assertEquals(usmDet1.Name,'USM001');
	    Test.startTest() ;
	    Test.setMock(HttpCalloutMock.class, new USMCallHandlerMock()) ;
	    usmCallHandler.initVal()  ;
	    usmCallHandler.getInstance().synchUSM(oppNew1 ,usmDet1 , 'TC000X1' ) ;
	    usmCallHandler.synchUSMOnOppUpdate(new List<Id>{oppNew1.Id} ) ;
	    usmCallHandler.synchUSMOnOppLink(new List<Id>{oppNew1.Id}) ;
	    usmCallHandler.getInstance().linkUSM(oppNew1.Id, 'USM001') ;
	    //usmCallHandler.getInstance().synchUsmOppInfo_soup(usmDet1, oppNew1 ,'TC000X1' ) ;
	   
	    Test.stopTest() ;
	    
	}
	
	
	
	private static testMethod void test1() { 
	    List<USM__c> usmCustListSetting = new List<USM__c>() ;
	    USM__c customSetting1 = new USM__c(Name= 'Endpoint_Create' , Value__c = 'https://test.sb.ncr.com:443/int/Opportunity/Services/NSCOpportunitySyncPS') ;
	    USM__c customSetting2 = new USM__c(Name= 'Endpoint_linking' , Value__c = 'https://test.sb.ncr.com/int/Opportunity/Services/OpportunityLinkageSyncPS') ;
	    USM__c customSetting3 = new USM__c(Name= 'Endpoint_nscopportunityupdate' , Value__c = 'https://test.sb.ncr.com/int/NSC/Opportunity/NSCUpdOpportunityPS') ;
	    USM__c customSetting4 = new USM__c(Name= 'Endpoint_Product' , Value__c = 'https://test.sb.ncr.com:443/int/NSC/Product/NSCProductsPS') ;
	    USM__c customSetting5 = new USM__c(Name= 'Password' , Value__c = 'test') ;
	    USM__c customSetting6 = new USM__c(Name= 'turnoffusmSyncForSandbox' , Value__c = 'true') ;
	    USM__c customSetting7 = new USM__c(Name= 'username' , Value__c = 'TCCYY') ;
	    
	    usmCustListSetting.add( customSetting1) ;
	    usmCustListSetting.add( customSetting2) ;
	    usmCustListSetting.add( customSetting3) ;
	    usmCustListSetting.add( customSetting4) ;
	    usmCustListSetting.add( customSetting5) ;
	    usmCustListSetting.add( customSetting6) ; 
	    usmCustListSetting.add( customSetting7) ;
	    
	    insert usmCustListSetting ;
	    
	    Opportunity oppNew1 = TestRecordsFactory.createOpportunityWithLineItem() ;
	    USM_Opportunity_Detail__c usmDet1 = new USM_Opportunity_Detail__c(Name='USM001') ;
	    insert usmDet1 ;
	    system.assertEquals(usmDet1.Name,'USM001'); 
	    Test.startTest() ;
	    usmCallHandler.initVal()  ;
	    usmCallHandler.getInstance().synchUSM(oppNew1 ,usmDet1 , 'TC000X1' ) ;
	    usmCallHandler.synchUSMOnOppUpdate(new List<Id>{oppNew1.Id} ) ;
	    usmCallHandler.synchUSMOnOppLink(new List<Id>{oppNew1.Id}) ;
	    usmCallHandler.getInstance().linkUSM(oppNew1.Id, 'USM001') ;
	    
	    Test.stopTest() ;
	    
	}

}