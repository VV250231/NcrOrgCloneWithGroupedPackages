public class MissingAutoPaySetupDashBoardController{

    
    @AuraEnabled
    public static List<SBQQ__Quote__c> instantiate(){  
        Id CurrUserId = Userinfo.getuserId();
     
        List<SBQQ__Quote__c> docList = [SELECT id,Name,SBQQ__Account__r.Name,qtc_Bill_To_Site__r.Name, qtc_Bill_To_Site__r.Site_Number__c, SBQQ__Account__r.Master_Customer_Number__c,SBQQ__SalesRep__c,qtc_Legal_Document_Status__c, 
                                        SBQQ__SalesRep__r.email,SBQQ__SalesRep__r.ManagerId,
                                       (SELECT id,Customer_Signature_Date__c FROM Customer_Documents__r wHERE Document_Status__c = 'Completed' AND
                                        (Document_Type__c ='AE Order Form' OR Document_Type__c = 'AE Amendment') order by Customer_Signature_Date__c DESC limit 1)
                                       FROM SBQQ__Quote__c wHERE AutoPay_Setup__c not in ('True', 'Manual') AND qtc_Legal_Document_Status__c = 'Completed' AND
                                      SBQQ__SalesRep__c =: CurrUserId AND qtc_Payments_Only_Quote__c = 'No' AND SBQQ__Ordered__c = false];
        return docList;
    }
}