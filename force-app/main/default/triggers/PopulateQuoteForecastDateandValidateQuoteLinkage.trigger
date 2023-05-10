/*
##################################################################################################
# Project Name..........: Subscription Commerce
# File............................: PopulateQuoteForecastDateandValidateQuoteLinkage.trigger
# Version.....................: 34.0
# Created by................: NSC IDC
# Created Date...........: 10-07-2015 
# Last Modified by......: NSC IDC
# Last Modified Date..: 10-07-2015 
# Description...............: This trigger is used to populate forecast date on Quote from related Customer Product Setup record forecast date.
################################################################################################
*/
trigger PopulateQuoteForecastDateandValidateQuoteLinkage on Customer_Product_Setup__c (before insert, before update, after insert, after update) {
    
    if (Trigger.isBefore) {
        Map<ID, Integer> quoteIdDetailMap = new Map<ID, Integer>();

        if (Trigger.isInsert) {
            for (Customer_Product_Setup__c prd : Trigger.new) {
                if(prd.Related_Quote__c != NULL) {
                    quoteIdDetailMap.put(prd.Related_Quote__c, 0);    
                }    
            }
        }      
        
        if (Trigger.isUpdate) {
            for (Customer_Product_Setup__c prd : Trigger.new) {
                if(prd.Related_Quote__c != NULL && Trigger.oldMap.get(prd.Id).Related_Quote__c != prd.Related_Quote__c) {
                    quoteIdDetailMap.put(prd.Related_Quote__c, 0);    
                }    
            }
        }
              
         if(!quoteIdDetailMap.isEmpty()) {
              List<zqu__Quote__c> quoteList = [SELECT Id, (SELECT Id FROM Customer_Product_Setup__r LIMIT 1) 
                                                  FROM zqu__Quote__c WHERE Id IN :quoteIdDetailMap.keySet()];
              
              for(zqu__Quote__c zquote :quoteList) {
                  quoteIdDetailMap.put(zquote.Id, zquote.Customer_Product_Setup__r.size());
              } 
              
              for (Customer_Product_Setup__c prd : Trigger.new) {
                  if(prd.Related_Quote__c != NULL && quoteIdDetailMap.get(prd.Related_Quote__c) > 0) {
                      prd.addError(System.Label.ValidateQuoteLinkage);
                  }    
              }                                 
         }
         
    }
    
   /* if (Trigger.isAfter) {
        Map<ID, Customer_Product_Setup__c> quoteForeCastDateMap = new Map<ID, Customer_Product_Setup__c>();
        
        if (Trigger.isInsert) {
            for (Customer_Product_Setup__c prd : Trigger.new) {
                if(prd.Related_Quote__c != NULL && prd.ForecastLiveDate__c!= NULL) {
                    quoteForeCastDateMap.put(prd.Related_Quote__c, prd);        
                }    
            }
        }
        
        if (Trigger.isUpdate) {
            for (Customer_Product_Setup__c prd : Trigger.new) {
                if(prd.Related_Quote__c != NULL && prd.ForecastLiveDate__c!= NULL
                    && (Trigger.oldMap.get(prd.Id).ForecastLiveDate__c!= prd.ForecastLiveDate__c)) {
                    quoteForeCastDateMap.put(prd.Related_Quote__c, prd);        
                }    
            }
        }
        
        if(!quoteForeCastDateMap.isEmpty()) {
            List<zqu__Quote__c> quoteList = [SELECT Id, Forecasted_Live_Date__c FROM zqu__Quote__c WHERE Id IN :quoteForeCastDateMap.keySet()];
            
            for(zqu__Quote__c zQuote : quoteList) {
                zQuote.Forecasted_Live_Date__c = quoteForeCastDateMap.get(zQuote.Id).ForecastLiveDate__c;   
            }
            
            Database.SaveResult[] results = Database.update(quoteList, false);
            Integer i=0;
    
            for(Database.SaveResult sr : results){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    quoteForeCastDateMap.get(quoteList[i].Id).addError('Error:' + err.getMessage());   
                }
                i++;
            }
        }
    }*/
    
}