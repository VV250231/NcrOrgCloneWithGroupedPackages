/*
####################################################################################################################
# Project Name..........: NSC INNOVATIONS 2016                                                                                                                            
# File............................: OpportunityProductControllerTest.cls                                                            
# Created by................: Mudasir Rashid                                                    https://ncr--cert.my.salesforce.com/_ui/common/apex/debug/ApexCSIPage#                   
# Created Date...........: 19-09-2016                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 19-09-2016                                                                                 
# Description...............: This is the test class of OpportunityProductController class. 
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5
####################################################################################################################
*/
@isTest
Class OpportunityProductControllerTest{
public static testMethod void myTest(){
Account acc=new Account();
acc=TestRecordsFactory.createAccount();
Competitors__c comp=new Competitors__c ();
comp=TestRecordsFactory.createCompetitor();
Sales_Org__c  so=new Sales_Org__c();
so=TestRecordsFactory.createSalesOrg();
Opportunity opp = new Opportunity();
opp=TestRecordsFactory.createSimpleOpportunity(acc);
opp.stagename ='Offering';

Profile p = [SELECT Id FROM Profile WHERE Name='04 NSC UI Administrator'];

User u = new User(Alias = 'MudiTest', Email='standarduser@testorg.com',

EmailEncodingKey='UTF-8', LastName='MudiTest', LanguageLocaleKey='en_US',

LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles',

UserName='MudiTest@testorg.com', Quicklook_ID__c='TESTMUDI', FederationIdentifier='TESTMUDI');

insert u;


update opp;
system.assert(opp!=null);

OpportunityProductController.getOpportunity(opp.id);
OpportunityProductController.getUserLocalCurrenctCode();
    OpportunityProductController.getFieldsDetailMap();
}
}