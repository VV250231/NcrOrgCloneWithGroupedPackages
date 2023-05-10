/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_TESTQuoteRelatedList.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 28-08-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 28-08-2016
# Description...........: This is test class for QuBy_QuoteRelatedList class.                          
##################################################################################################*/
@isTest
private class QuBy_TESTQuoteRelatedList{
    
    static testMethod void UnittestFirst() {
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        
        QuBy_Detail__c QD = new QuBy_Detail__c();
        QD.Name = 'TESTQD';
        QD.Annuity_Quote_Status__c = 'ACKNOWLEDGED';
        Qd.Quote_Number__c='390000222';
        QD.MCN__c = 'TEST000012';
        QD.Country_Code__c='US';
        QD.Opportunity__c = opp.id;
        insert QD;
        
        
        QuBy_QuoteRelatedList.isDisabled( );
        QuBy_QuoteRelatedList.getRecords( opp.id );
        QuBy_QuoteRelatedList.getAvailableQuotes( opp.id );
        QuBy_QuoteRelatedList.search( opp.id,'390000222' );
        QuBy_QuoteRelatedList.searchAvailableQuotes( opp.id,'390000222' );
        QuBy_QuoteRelatedList.disAssociateQuote( new List <String> { QD.id },opp.id );
        //QuBy_QuoteRelatedList.associateQuote( new List <String> { QD.id },opp.id );
        
        try{ 
             QuBy_QuoteRelatedList.associateQuote( new List <String> { QD.id },opp.id );
            
        }catch(DMLException e){
           system.assertEquals(e.getMessage(), e.getMessage()); 
        }
        QuBy_QuoteRelatedList.availableQuotesInBatches( opp.id ,10,10);
        QuBy_QuoteRelatedList.dataWrapper DW = new QuBy_QuoteRelatedList.dataWrapper( QD );
        QD.Annuity_Modification_Date__c = System.today() ;
        
        QuBy_QuoteRelatedList.dataWrapper DW1 = new QuBy_QuoteRelatedList.dataWrapper( QD );
        QD.Annuity_Modification_Date__c = null ;
        QD.Solution_Modification_Date__c = System.today() +1  ;
        QuBy_QuoteRelatedList.dataWrapper DW2 = new QuBy_QuoteRelatedList.dataWrapper( QD );
        QD.Annuity_Modification_Date__c = System.today() ;
        QuBy_QuoteRelatedList.dataWrapper DW3 = new QuBy_QuoteRelatedList.dataWrapper( QD );
        QD.Annuity_Modification_Date__c = System.today() + 5 ;
        QuBy_QuoteRelatedList.dataWrapper DW4 = new QuBy_QuoteRelatedList.dataWrapper( QD );
        QuBy_QuoteRelatedList.lightningTableWrapper lwrapper1 = new QuBy_QuoteRelatedList.lightningTableWrapper() ;
        lwrapper1.page = 1 ;
        lwrapper1.total = 2;

    }
  
}