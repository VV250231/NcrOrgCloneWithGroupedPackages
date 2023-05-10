/****************************************************************************************************************
*   
*   Description : JP Merchant On Boarding class for Payment Processing  
*   Version     :   47
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1708		4-Feb-2022			Saurav				Added	ProvisioningStatus,ProvisioningMessage,GatewayCompanyNumber,GatewayStoreNumberInStor,
GatewayStoreNumbereCommerce fields
EBA_SF-1709		4-Feb-2022			Yogesh				Modified Tid format.
EBA_SF-1893     23-Feb-2022			Yogesh 				Accept Both format old and New for Tids
****************************************************************************************************************/


@RestResource(urlMapping = '/JP_MerchantOnBoarding/*')
global class JP_MerchantOnBoardingStatusService {
    
    @HttpPut
    global static String upsertCase(String ExternalApplicationId, String MerchantIdentifier,
                                    String MerchantApplicationId, String InfiniceptApplicationId, String Status, String StatusValue, String Created, 
                                    String LastUpdated, String Mid, String[] tid, JP_MerchantOnBoardingStatusService.Tids tids,
                                    String Message, String ExternalMerchantId, String ExternalStoreId, String ProvisioningStatus,
                                    String ProvisioningMessage, String GatewayCompanyNumber,String GatewayStoreNumberInStore, String GatewayStoreNumbereCommerce) {
                                        String req = 'ExternalApplicationId:' + ExternalApplicationId + '| MerchantIdentifier:' + MerchantIdentifier + '| MerchantApplicationId:' + MerchantApplicationId + '| InfiniceptApplicationId:' + InfiniceptApplicationId + '| Status:' + Status + '| StatusValue:' + StatusValue + '| Created:' + Created + '| LastUpdated:' + LastUpdated + '| Mid:' + Mid + '| tid:' + tid + '| Message:' + Message + '| ExternalMerchantId:' + ExternalMerchantId + '| ExternalStoreId:' + ExternalStoreId +'| ProvisioningStatus' + ProvisioningStatus +'| ProvisioningMessage' + ProvisioningMessage + ' |GatewayCompanyNumber' + GatewayCompanyNumber + '| GatewayStoreNumberInStore' + GatewayStoreNumberInStore + '| GatewayStoreNumbereCommerce' + GatewayStoreNumbereCommerce;
                                        try {
                                            System.debug('@@@'+tid);
                                            System.debug('@@@'+tids);
                                            system.debug('@@' + InfiniceptApplicationId + '@@' + Status + '@@' + tid);
                                            List < NCR_Payments_Site__c > nps = [Select id, Opportunity__c, eCommerce_TID__c,In_Store_TID__c,Opportunity__r.Opportunity_Number__c from NCR_Payments_Site__c where InfiniceptApplicationId__c =: InfiniceptApplicationId];
                                            if (nps.size() != 1) {
                                                //Logging Inbound Call
                                                JPLogs__c jplogs = new JPLogs__c();
                                                jplogs.Type__c = 'InBound';
                                                jplogs.Request__c = req;
                                                jplogs.status__c = 'Failure-Error :' + 'Infinicept Application Id does not exist.';
                                                jplogs.Response__c = 'Failure-Error :' + 'Infinicept Application Id does not exist.';
                                                insert jplogs;
                                                return 'Error updating status';
                                            } else {
                                                nps[0].NCR_Payments_Application_Status__c = Status;
                                                if (!String.isEmpty(Mid)) {
                                                    nps[0].MID__c = Mid;
                                                }
                                                if (tid != null && tid.size() > 0) {
                                                    String TidString = '';
                                                    String alpHaNumeric;
                                                    String nuMeric;
                                                    Integer i = 0;
                                                    for (String s: tid) {
                                                        if (i > 0) {
                                                            TidString = TidString + '||';
                                                        }
                                                        TidString = TidString + s;
                                                        i++;
                                                    }
                                                    nps[0].TID__c = TidString;
                                                     // EBA_SF-1893 - Accept new format and Old format as well for Tid
                                                    if(nps[0].eCommerce_TID__c == null || nps[0].In_Store_TID__c==null){
                                                        alpHaNumeric =  nps[0].TID__c.substringBefore('||');
                                                        nuMeric = nps[0].TID__c.substringAfter('||');
                                                        if(!alpHaNumeric.isNumeric()){
                                                            nps[0].eCommerce_TID__c = alpHaNumeric;
                                                        } else{
                                                            nps[0].In_Store_TID__c =alpHaNumeric;
                                                        }
                                                        if(!nuMeric.isNumeric()){
                                                            nps[0].eCommerce_TID__c=nuMeric; 
                                                        }else{
                                                            nps[0].In_Store_TID__c = nuMeric;
                                                        }
                                                    }
                                                    
                                                }
                                                // EBA_SF-1893 - Accept new format for Tids
                                                if(tids!=null){
                                                    if(!tids.eCommerce.isEmpty()){
                                                        nps[0].eCommerce_TID__c = tids.eCommerce[0];
                                                    }
                                                    if(!tids.InStore.isEmpty()){
                                                        nps[0].In_Store_TID__c = tids.InStore[0];
                                                    }
                                                }
                                                if (StatusValue != null) {
                                                    nps[0].Status_Code__c = StatusValue;
                                                }
                                                if(ProvisioningStatus!=null){
                                                    nps[0].Gateway_Provisioning_Status__c = ProvisioningStatus;
                                                }
                                                if(ProvisioningMessage!=null){
                                                    nps[0].Gateway_Provisioning_Status_Message__c = ProvisioningStatus;
                                                }
                                                if(GatewayCompanyNumber!=null){
                                                    nps[0].Gateway_Company_Number__c = GatewayCompanyNumber;
                                                }                                               
                                                if(GatewayStoreNumberInStore!=null){
                                                    nps[0].Gateway_Store_Number_in_store__c = GatewayStoreNumberInStore;
                                                }                                                
                                                if(GatewayStoreNumbereCommerce!=null){
                                                    nps[0].Gateway_Store_Number_eCommerce__c = GatewayStoreNumbereCommerce;
                                                }
                                                if (Message != null) {
                                                    nps[0].Status_Reason__c = Message;
                                                }
                                                update nps[0];
                                                //Logging Inbound Call
                                                JPLogs__c jplogs = new JPLogs__c();
                                                jplogs.Name='Inbound - '+nps[0].Opportunity__r.Opportunity_Number__c;
                                                jplogs.Type__c = 'InBound';
                                                jplogs.Opportunity_Id__c = nps[0].Opportunity__r.Opportunity_Number__c;
                                                jplogs.Request__c = req;
                                                jplogs.status__c = 'Success :Status updated successfully.';
                                                jplogs.Response__c = 'Success :Status updated successfully.';
                                                insert jplogs;
                                                return 'Successfully received message';
                                                //Create Log
                                                
                                            }
                                        } catch (Exception e) {
                                            // create Log
                                            JPLogs__c jplogs = new JPLogs__c();
                                            jplogs.Type__c = 'InBound';
                                            jplogs.Request__c = req;
                                            jplogs.status__c = ('Exception :'+e).left(250);
                                            jplogs.Response__c = 'Exception :'+e;
                                            insert jplogs;
                                            return 'Exception Occured: ' + e;
                                            
                                            
                                        }
                                    }
    global class Tids{
        global List<String> eCommerce;
        global List<String> InStore;
    }
    
}