/*
##################################################################################################
# Class Name............................:PSFR_RelatedList_Test.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
@isTest
public class PSFR_RelatedList_Test{
    static testMethod void testMethod1()
     {
         Account Acc=TestRecordsFactory.createAccount();
         Contact con=TestRecordsFactory.createContact(Acc);
         Opportunity opp=TestRecordsFactory.createSimpleOpportunity(Acc);
         Presales_Funding_Request__c PSFR_Obj=new Presales_Funding_Request__c();
         PSFR_Obj.PFR_Opportunity__c=opp.id;
         PSFR_Obj.PFR_Presales_Category__c ='1-Network Certification';
         PSFR_Obj.PFR_Is_this_Recoverable__c='Yes';
         PSFR_Obj.PFR_Expected_Date__c=system.today();
         PSFR_Obj.PFR_Justification__c='Test Justification';
         PSFR_Obj.PFR_Success_Criteria__c='Test Justification';
         insert PSFR_Obj;
          Test.startTest();
          PageReference myVfPage = Page.PSFRRelatedList;
          Test.setCurrentPage(myVfPage);
          System.currentPageReference().getParameters().put('id',PSFR_Obj.id);
          ApexPAges.StandardController sc = new ApexPages.StandardController(PSFR_Obj);
          PSFR_RelatedList testController = new PSFR_RelatedList(sc);
          system.assert(testController!=null);
         
          
          Test.StopTest();
     }   
}