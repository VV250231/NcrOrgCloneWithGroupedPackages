public class CaseController {
    @AuraEnabled
    public static case getCaseRecord(String recordId){
          case caserecord = new case();
          caserecord = [select id,isClosed,RecordTypeId,Area__c,ParentId,First_Contact_Date__c,Region__c,Functional_Area__c,LOB__c,Type,Reason_for_Recommend_Rating__c,AccountId,Customer_Call_Completed__c,ContactId from case where id =:recordId limit 1];
          System.debug(caserecord);
          return  caserecord;
        
    }
}