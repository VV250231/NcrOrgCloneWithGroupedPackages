/*************************************************************************************************
*   ClassName :   autoCXCaseCreationClass
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
*************************************************************************************************/
public with sharing class autoCXCaseCreationClass {
    
    @AuraEnabled
    public static Case CreateCxCase(String detractorcaseDetails)                              
    {
        system.debug('detractorcaseDetails:'+detractorcaseDetails);
        
        // 1. Deserialize the data received from Controller.
        Case dcase = (Case) JSON.deserialize(detractorcaseDetails, Case.class);
        system.debug('dcase:'+dcase);
        
        // 2. Find the RecordTypeId for existing Detractor and newly created case with Record tyoe CX Case.
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        Id newCaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('CX Case').getRecordTypeId();
        
        // 3. Create new case with all required data fields.
        case c= new case();
        queuesobject caseQueue =[Select Queue.Id,Id,Queue.DeveloperName From QueueSObject where Queue.DeveloperName = 'CX_Case_Owner' limit 1];
        if(dcase.get('RecordTypeId')==CaseRecordTypeId) {
            c.OwnerId=caseQueue.Queue.Id;
            c.Origin=(dcase.get('Origin'))== null ? '' :'Detractor';
            c.RecordTypeId=newCaseRecordTypeId;
            c.Case_Creation_Source__c='CX case';
            c.contactid=(dcase.get('ContactId'))== null ? null : dcase.get('ContactId').toString();
            c.CC__c=(dcase.get('CC__c'))== null ? null : dcase.get('CC__c').toString();
            c.Area_of_Concern__c=(dcase.get('Area_of_Concern__c'))== null ? null : dcase.get('Area_of_Concern__c').toString();
            c.Area_of_Concern_Other__c=(dcase.get('Area_of_Concern_Other__c'))== null ? '' : dcase.get('Area_of_Concern_Other__c').toString();
            c.Reason_for_Recommend_Rating__c=(dcase.get('Reason_for_Recommend_Rating__c'))== null ? '' : dcase.get('Reason_for_Recommend_Rating__c').toString();
            c.Description=(dcase.get('Description'))== null ? '' : dcase.get('Description').toString();
            c.Subject='CX Case from Detractor';
            c.ParentId=dcase.id;
            c.First_Contact_Date__c=(dcase.get('First_Contact_Date__c'))== null ? null : date.valueOf(dcase.get('First_Contact_Date__c'));
            c.Detractor_Case_Number__c= dcase.CaseNumber;
        }
        
        // 4. if new case is valid, then make INSERT() call.
        if(c != null){
            insert c;
        }
         
        // populate new CX case values on detractor case
        case nc= new case();
        nc=[select id,casenumber from case where id= :c.id];
      
       // dcase.CX_Case_URL__c='https://ncr--cert.lightning.force.com/'+nc.id;
        dcase.CX_Case_Number__c=nc.CaseNumber;
        update dcase;
        
        
        return c;
    }
    
}