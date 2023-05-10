/*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_TESTDetailTriggerHandler
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 18-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 18-07-2016
# Description...........: This is test class for QuBy_DetailTriggerHandler Class.
# Status................: Active    
##################################################################################################*/
@isTest
private class QuBy_TESTDetailTriggerHandler{
    
    static testMethod void runUnitTest() {
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        String OpportunityNumber = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id = : opp.id ].Opportunity_Number__c;        
        Account acc = TestRecordsFactory.createAccount('00test11'); 
        Partner_Opportunity__c objtemp = new Partner_Opportunity__c();
        objtemp.Amount__c = 100;
        objtemp.CAM__c = userinfo.getUserId();
        objtemp.End_Customer__c = 'End Customer';
        objtemp.End_Customer_Primary_Contact__c = 'End customer primary contact';
        objtemp.Expected_Book_Date__c = system.today();
        objtemp.Opportunity_Name__c = 'Test Opportunity';
        objtemp.Partner_Account__c = acc.Id;
        objtemp.Partner_Sales_Person__c = 'partner sales person';
        insert objtemp;
        opp.Linked_Partner_Opportunity__c = objtemp.id;
        update opp;
        QuBy_Detail__c QD = new QuBy_Detail__c(); 
        QD.Opportunity__c = opp.id;
        QD.Quote_Number__c='350000999'  ;       
        QD.QuickLook_ID__c = 'ms250942';
        QD.Country_Code__c = 'US';
        QD.MCN__c = 'TESTMCN00001X';
        QD.CurrencyIsoCode = 'USD';
        QD.Annuity_Quote_Status__c = 'Submitted';
        QD.Rollout_Date__c = system.today();
        QD.Recipients_Email__c = 'test@test.com';
        QD.Solution_Quote_Amount__c=100000;
        QD.Cloud_Products__c = 1000;
        QD.Hardware_Products__c = 1000;
        QD.PS_Products__c = 1000;
        QD.Services_Products__c = 1000;
        QD.Software_Products__c = 1000;
        QD.Opportunity_No__c = OpportunityNumber;     
        QD.Description__c = 'TEST NAME'; 
        QD.Latest_Version__c='1'; 
        insert QD;
        
        Qd.X48_hour_Notification__c=true;
        QD.Description__c = 'TEST NAME';
        update QD;
        Test.startTest();
        All_profie_list_config__c apc = new All_profie_list_config__c();
        apc.QuBy_LTNG_ProfileCheck__c = true;
        apc.Profile_id__c = [select id from profile limit 1].id;
        apc.Name='testingconfig';
        insert apc;
        QuBY_DetailTriggerHandler.opportunityAssociationToQuote( new List<QuBy_Detail__c> { QD } );
        QuBY_DetailTriggerHandler.NTQCreationCall( new List<QuBy_Detail__c>{ QD } );
        NSC_To_QuBy_Quote__c nqb = [SELECT id, Account_LOB__c, Account_Name__c, Account_Owner__c, Account_Team__c, Account_Team_Member__c, Linkage_Flag__c, Opportunity_Id__c, Opportunity_Name__c, Opportunity_Number__c, Opportunity_Owner_QLID__c, Quote_Number__c, Updated_Date_Timestamp__c FROM NSC_To_QuBy_Quote__c WHERE Quote_Number__c = : QD.Quote_Number__c];
        system.assertEquals(nqb.Updated_Date_Timestamp__c,system.now());
        QD.Latest_Version__c='-1';
        update QD;
        delete QD;
        undelete QD;
        System.assert(QD.id!=null);
        //QuBY_DetailTriggerHandler.testHack();
        //QuBY_DetailTriggerHandler.testHack_1();
        Test.stopTest(); 
        
    }
    @isTest
    public static void runTest1(){
        Account acc = Testrecordsfactory.createAccount('TESTMCN00001X');
         Opportunity opp = TestRecordsFactory.createSimpleOpportunity();
        opp.Currency_Conversion_Rate__c =0.5;
        update opp;
        Opportunity opp1 = TestRecordsFactory.createSimpleOpportunity(acc);
        String OpportunityNumber = [ SELECT Opportunity_Number__c FROM Opportunity WHERE id = : opp.id ].Opportunity_Number__c; 
        QuBy_Detail__c QD1 = new QuBy_Detail__c(); 
        QD1.Quote_Number__c='35';       
        QD1.QuickLook_ID__c = 'ms250942';
        QD1.Country_Code__c = 'US';
        QD1.MCN__c = acc.Master_Customer_Number__c;
        QD1.CurrencyIsoCode = 'USD';
        QD1.Annuity_Quote_Status__c = 'Submitted';
        QD1.Rollout_Date__c = system.today();
        QD1.Recipients_Email__c = 'test@test.com';
        QD1.Solution_Quote_Amount__c=100000;
        QD1.Cloud_Products__c = 1000;
        QD1.Hardware_Products__c = 1000;
        QD1.PS_Products__c = 1000;
        QD1.Services_Products__c = 1000;
        QD1.Software_Products__c = 1000;
        QD1.Opportunity_No__c = OpportunityNumber;     
        QD1.Description__c = 'TEST NAME'; 
        QD1.Latest_Version__c='1'; 
       	QD1.Opportunity__c = opp.id;
        insert QD1;
        QuBy_Detail__c QD2 = new QuBy_Detail__c(); 
        QD2.Quote_Number__c='20';       
        QD2.QuickLook_ID__c = 'ms250942';
        QD2.Country_Code__c = 'US';
        QD2.MCN__c = acc.Master_Customer_Number__c;
        QD2.CurrencyIsoCode = 'USD';
        QD2.Annuity_Quote_Status__c = 'Submitted';
        QD2.Rollout_Date__c = system.today();
        QD2.Recipients_Email__c = 'test@test.com';
        QD2.Solution_Quote_Amount__c=100000;
        QD2.Cloud_Products__c = 1000;
        QD2.Hardware_Products__c = 1000;
        QD2.PS_Products__c = 1000;
        QD2.Services_Products__c = 1000;
        QD2.Software_Products__c = 1000;
        QD2.Opportunity_No__c = OpportunityNumber;     
        QD2.Description__c = 'TEST NAME 2'; 
        QD2.Latest_Version__c='1'; 
       	QD2.Opportunity__c = opp.id;
        insert QD2;
        NSC_To_QuBy_Quote__c q = new NSC_To_QuBy_Quote__c();
        q.Quote_Number__c = '35';
        insert q;
        QuBy_Detail__c QD3 = new QuBy_Detail__c(); 
        QD3.Quote_Number__c='21';       
        QD3.QuickLook_ID__c = 'ms250942';
        QD3.Country_Code__c = 'US';
        QD3.MCN__c = acc.Master_Customer_Number__c;
        QD3.CurrencyIsoCode = 'USD';
        QD3.Annuity_Quote_Status__c = 'Submitted';
        QD3.Rollout_Date__c = system.today();
        QD3.Recipients_Email__c = 'test@test.com';
        QD3.Solution_Quote_Amount__c=100000;
        QD3.Cloud_Products__c = 1000;
        QD3.Hardware_Products__c = 1000;
        QD3.PS_Products__c = 1000;
        QD3.Services_Products__c = 1000;
        QD3.Software_Products__c = 1000;
        QD3.Opportunity_No__c = opp1.Opportunity_Number__c;     
        QD3.Description__c = 'TEST NAME 3'; 
        QD3.Latest_Version__c='1'; 
       	QD3.Opportunity__c = opp1.id;
        insert QD3;
        QuBy_Detail__c QD4 = new QuBy_Detail__c(); 
        QD4.Quote_Number__c='200';       
        QD4.QuickLook_ID__c = 'ms250942';
        QD4.Country_Code__c = 'US';
        QD4.MCN__c = acc.Master_Customer_Number__c;
        QD4.CurrencyIsoCode = 'USD';
        QD4.Annuity_Quote_Status__c = 'Submitted';
        QD4.Rollout_Date__c = system.today();
        QD4.Recipients_Email__c = 'test@test.com';
        QD4.Solution_Quote_Amount__c=100000;
        QD4.Cloud_Products__c = 1000;
        QD4.Hardware_Products__c = 1000;
        QD4.PS_Products__c = 1000;
        QD4.Services_Products__c = 1000;
        QD4.Software_Products__c = 1000;
        QD4.Opportunity_No__c = opp1.Opportunity_Number__c;     
        QD4.Description__c = 'TEST NAME 5'; 
        QD4.Latest_Version__c='2'; 
       	QD4.Opportunity__c = opp1.id;
        insert QD4;
        system.assert(QD4.Opportunity__c!=null);
        QuBY_DetailTriggerHandler.opportunityAssociationToQuote( new List<QuBy_Detail__c> { QD1,QD2,QD3,QD4 } );
         Test.startTest();
        QuBY_DetailTriggerHandler.NTQCreationCall( new List<QuBy_Detail__c>{ QD1 ,QD2,QD3,QD4} );
        Test.stopTest();
    }
}