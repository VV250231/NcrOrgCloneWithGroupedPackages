/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_TESTDetailTrigger
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 18-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 18-07-2016
# Description...........: This is test class for QuBy_DetailTrigger Trigger.
# Status................: Active    
##################################################################################################*/
@isTest( seeAllData = true )
private class QuBy_TESTDetailTrigger{
    
    static testMethod void runUnitTest() {
        Opportunity opp=TestRecordsFactory.createSimpleOpportunity();
        test.startTest();
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TEST Quote';
        QD.Quote_Number__c = '125';
        QD.Country_Code__c = 'US';
        QD.MCN__C = '25721';
        QD.Quicklook_ID__c = 'ms250942';
        QD.Solution_Quote_Amount__c=11000;
        QD.CurrencyIsoCode='USD';
        QD.Solution_Quote_Status__c='Acknowledged';
        QD.Description__c = 'TEST NAME';
        insert QD;
        
        Delete QD;
        Undelete QD;
        
        QD.Country_Code__c = 'US';
        QD.X24_hour_Notification__c=true;        
        QD.Description__c = 'TEST NAME';
        update QD;
        
        QD.Opportunity__c=opp.id;
        QD.Description__c = 'TEST NAME';
        update QD;
        
        // delete
        Delete QD;
        Undelete QD;
        System.assert(QD.Description__c=='TEST NAME');
        
        test.stopTest();
    }

}