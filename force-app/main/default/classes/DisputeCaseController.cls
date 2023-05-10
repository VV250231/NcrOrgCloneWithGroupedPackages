/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/

public with sharing class DisputeCaseController {
        @AuraEnabled(cacheable=true)
        public static List<Case> getAccountDisputeCases(String recId, String orderBy, String order) {
            System.debug(recId);
            List<Case> disputeCases;
            List<Credit_Detail__c> arDetails = [SELECT Id, Account__c FROM Credit_Detail__c WHERE Id =: recId];
            if(arDetails.size()>0 && arDetails[0].Account__c != null) {
                String actId = arDetails[0].Account__c;
                Id disputeRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId();
                String query = 'SELECT Id,AccountId, CaseNumber,Contact.Name, Subject, Priority, CreatedDate, Status, Owner.Name FROM Case WHERE AccountId =: actId AND RecordTypeId =: disputeRecTypeId ORDER BY '+orderBy+' '+order;
                
                disputeCases = (List<Case>) Database.query(String.escapeSingleQuotes(query));
            }
            system.debug(disputeCases);
            return disputeCases;
        }   
}