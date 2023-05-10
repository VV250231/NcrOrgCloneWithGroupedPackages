public with sharing class PRM_PartnerClaimsList {
    /* Created By : Ritesh Kumar
    /* -Method Name : getPartnerClaimList.
    *  -Method parameters : There is no parameter are required to call this method.
    *  -Method Return Type : Method return type is List where status of fund calim and fund request is Approves. (List< SFDC_MDF_Claim__c>). 
    *  -Method Description : This method is called By wire service(LWC) and used to dilplay approved Fund Claims.  
    */    
    @AuraEnabled 
    public static List<SFDC_MDF_Claim__c> getPartnerClaimList(){  
      
       return [ SELECT Id, Name, Status__c, Fund_Request__c, Fund_Request__r.Name,Fund_Request__r.Request_ID__c, Fund_Request__r.Status__c ,CreatedDate 
                FROM SFDC_MDF_Claim__c 
                WHERE Status__c = 'Approved' AND Fund_Request__r.Status__c ='Approved' 
                ORDER BY CreatedDate 
                DESC];

    }
}