/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_TESTOpportunityTrigger_BFR
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 18-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 18-07-2016
# Description...........: This is test class for QuBy_OpportunityTrigger_BFR trigger.
# Status................: Active    
##################################################################################################*/
@isTest(SeeAllData=true)
private class QuBy_TESTOpportunityTrigger_BFR{
    
    static testMethod void runUnitTest() {
        
        //Inserting Dummy Opportunity
        Account SampleAcc=TestRecordsFactory.createAccount();
        Id ga =NSCCommonInfoUtil.getIdOf('GS_Admin');//00e700000013gAKAAY
        Id na =NSCCommonInfoUtil.getIdOf('NSC_Admin_04_UI_Profile');//00e70000000x3egAAA
        Id sa =NSCCommonInfoUtil.getIdOf('System_Administrator');//00e70000000sR8UAAU
        Set<id> s = new Set<id>{ga,na,sa};//Change by Saurav
        User u=[Select id from user where Profile.PermissionsLightningExperienceUser=true and profileid not in :s and isActive=true and userType='Standard' limit 1];
        Opportunity opp = new Opportunity();
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//Change By Saurav
        opp.name = 'abc';
        opp.AccountID = SampleAcc.id;
        
        opp.Name = 'OppQuote Linkage Test Opportunity';
        opp.type = 'Indirect Channel';
        opp.Solution_Portfolio__c = 'Financial Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp.INVOICE_TRIGGER__C = 'Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Closing';
        opp.recordTypeId = r1;
        opp.OwnerId=u.id;
        
        
        // assigning account
      //  SampleAcc.OwnerId=u.id;
      //  update SampleAcc;
        
        test.startTest();
        System.runAs(u) {
            try{
                insert opp;
            }catch( exception ex ){
                //System.Assert( ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION') );
                System.debug('Error '+ex.getMessage());
            }
        }
        if(opp.id==null)
        insert opp;
        system.assert(opp.id!=null);
        Opportunity opp2=[Select id, Opportunity_Number__c from Opportunity where id=:opp.id];
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        QD.Annuity_Quote_Status__c = 'ACKNOWLEDGED';
        Qd.Quote_Number__c='124';
        QD.MCN__c = 'TEST000012';
        QD.Country_Code__c='US';
        QD.Opportunity__c = opp2.id;
        QD.Opportunity_No__c=opp2.Opportunity_Number__c;
        insert QD;

        System.runAs(u) {
            //null scenario
            opp.stagename='Closed/Booked';
            try{
                update opp;
            }
            catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
            //no scenario
            opp.stagename='Closed/Booked';
            opp.IsQuoteCreatedInOtherSystem__c='NO';
            try{
                update opp;
            }
            catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
            
            opp.stagename = 'Closed/Booked';  
            opp.IsQuoteCreatedInOtherSystem__c='YES';
            opp.Key_Criteria__c='xyz';
            opp.Price_Variance__c='abc';
            opp.CLM_Sales_Acknowledgment__c=true;
            update opp;
            // moveback scenario
            opp.stagename='Analyzing';
            try{
                update opp;
            }
            catch(Exception e){
                System.debug('Error '+e.getMessage());
            }
            
        }
        
        delete opp2;
        test.stopTest();
        
    }
    
    
}