/*
############################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Tania Sen                                                               
# Created Date..........: 18-04-2017                                                                               
# Last Modified by......: Tania Sen 
# Last Modified Date....: 18-05-2017 
# Description...........: This is a future class, it has been called from the trigger AutomateSendToZBilling 
#############################################################################################################
*/


global with sharing class FutureClassForQuotesZbilling
{
    public static final Integer MAX_BATCH_SIZE = 30;
   
//***********************************************************Method For Sending Quote To Zuora*****************************************************************
    @future(callout=true)
    public static void sendToZBilling(List<ID> quoteIds)
    {   
         //List<zqu__Quote__c> lstOfQuotesForUpdate = new List<zqu__Quote__c>(); // List of quotes for update 
         List<zqu__Quote__c> lstDuplicateQuotes = new List<zqu__Quote__c>(); // List of duplicate quotes
         List<zqu__Quote__c> lstEligibleQuotes = new List<zqu__Quote__c>(); // List of eligible quotes for Z Billing
         //List<string> lstSuccessfulZbillingQuotes = new List<string>(); // List of quotes which is sucessfull in z billimg process
        
         
         Map<string,zqu__Quote__c> mapIdandQuotesForUpdate = new Map<string,zqu__Quote__c>(); // Map of id and quotes for updating the quotes
         Map<String,zqu__Quote__c> mapQuoteNumberAndQuoteObj = new  Map<String,zqu__Quote__c>(); // Map of quotes number and quote object
         Map<String,zqu__Quote__c> mapIDAndQuoteObj = new  Map<String,zqu__Quote__c>(); // Map of quotes id and quotes object
         Map<String,String> mapQuoteNumAndSubsId = new  Map<String,String>(); // map of quote number and zuora subscription id
         Map<String,String> mapSubsTypeAndRecordTypeId = new Map<String,String>(); // Map of quotes subscription type and record type
         
         
         // fill the map with recordtype and subscription type
         mapSubsTypeAndRecordTypeId.put('New Subscription',Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('ReadOnly').getRecordTypeId());
         mapSubsTypeAndRecordTypeId.put('Amend Subscription', Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Amendment ReadOnly').getRecordTypeId());
         mapSubsTypeAndRecordTypeId.put('Renew Subscription',Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Renewal ReadOnly').getRecordTypeId());
         mapSubsTypeAndRecordTypeId.put('Cancel Subscription',Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('Cancellation ReadOnly').getRecordTypeId());
         system.debug('++++++++mapSubsTypeAndRecordTypeId'+mapSubsTypeAndRecordTypeId);   
         
        
        
         // sort out quote fulfillng the Z Billing criteria
         for(zqu__Quote__c objZQuotes : [SELECT id,zqu__Service_Activation_Date__c ,Provisioning_Status__c ,Provisioning_Not_Required__c,zqu__Number__c,Is_NCR_Quote__c,zqu__Status__c , RecordType.DeveloperName,zqu__SubscriptionType__c,Name,Error_Message_When_Z_Billing_Fail__c , zqu__Account__c, zqu__ZuoraAccountID__c FROM zqu__Quote__c WHERE Id IN :quoteIds FOR UPDATE])
         {
             //below code added for SC2015_AGL-5895
             boolean isAmndRemoval = false;
             isAmndRemoval = DIQuoteUtil.isRemovalamendments(objZQuotes.Id);
             //*********************check all required criteria and collect quote which are elible for sending to z-billing
            if(objZQuotes.zqu__Status__c == 'New' &&  String.isNotBlank(objZQuotes.zqu__ZuoraAccountID__c) && objZQuotes.Is_NCR_Quote__c == true && (objZQuotes.zqu__SubscriptionType__c == 'Cancel Subscription' || isAmndRemoval || 
                objZQuotes.zqu__Service_Activation_Date__c != null))
            {
                mapQuoteNumberAndQuoteObj.put(objZQuotes.zqu__Number__c,objZQuotes);
                mapIDAndQuoteObj.put(objZQuotes.id,objZQuotes);
                
            }
            
         }
          
             system.debug('+++++++++mapQuoteNumberAndQuoteObj'+mapQuoteNumberAndQuoteObj);  
             system.debug('+++++++++map of quote id and object ++'+mapIDAndQuoteObj.values().size()); 
             system.debug('+++++++++keyset() map of quote id and object ++'+mapIDAndQuoteObj.keyset()); 
          
            //**************** check if the subscription is already present or not based on quote number present in quote and subscription object in salesforce
            if (mapQuoteNumberAndQuoteObj != null && mapQuoteNumberAndQuoteObj.size() > 0)
            {
              
              // query subscription object base on quote number to see whether it is already there or not .
              for(Zuora__Subscription__c objSubs : [select id,Zuora__QuoteNumber__c,Zuora__Zuora_Id__c from Zuora__Subscription__c where Zuora__QuoteNumber__c in:mapQuoteNumberAndQuoteObj.keyset() FOR UPDATE])
              {
                     system.debug('++++ inside for loop of subs query'+objSubs.Zuora__QuoteNumber__c);
                     mapQuoteNumAndSubsId.put(objSubs.Zuora__QuoteNumber__c ,objSubs.Zuora__Zuora_Id__c);
              }
              system.debug('++++ outside for loop of subs query  mapQuoteNumAndSubsId'+mapQuoteNumAndSubsId);
              if(mapQuoteNumAndSubsId != null && mapQuoteNumAndSubsId.size() > 0)
              {
                  for(String strQuoteNum : mapQuoteNumberAndQuoteObj.keyset() )
                  {
                      
                      if(mapQuoteNumAndSubsId != null && mapQuoteNumAndSubsId.size() > 0 && mapQuoteNumAndSubsId.containsKey(strQuoteNum))
                      {
                          lstDuplicateQuotes.add(mapQuoteNumberAndQuoteObj.get(strQuoteNum)); // get all the duplicate list for procesiing
                      }
                      else
                      {
                          lstEligibleQuotes.add(mapQuoteNumberAndQuoteObj.get(strQuoteNum)); // get all the eligible quote for sending it to z billing
                      }
                  }
               }
               else
               {
                      lstEligibleQuotes = mapQuoteNumberAndQuoteObj.values();
                      system.debug('+++ lstEligibleQuotes = mapQuoteNumberAndQuoteObj.values()'+lstEligibleQuotes );  
               }
            }   
              system.debug('++++++  lstDuplicateQuotes '+lstDuplicateQuotes );
              
                if(lstEligibleQuotes != null && lstEligibleQuotes.size() > 0)
                {
                   List<zqu.zQuoteUtil.ZBillingQuoteCollection> lstQuotesReadyForZBilling = new List<zqu.zQuoteUtil.ZBillingQuoteCollection>();
                   
                   for(zqu__Quote__c  quoteObj :lstEligibleQuotes)
                   {
                            zqu.zQuoteUtil.ZBillingQuoteCollection objQuoteCollection = new zqu.zQuoteUtil.ZBillingQuoteCollection();
                            objQuoteCollection.sfdcAccountId = quoteObj.zqu__Account__c; // SFDC CRM Account ID
                            objQuoteCollection.zAccountId = quoteObj.zqu__ZuoraAccountID__c ; // Zuora Billing Account ID
                            objQuoteCollection.quoteRequests = new List<zqu.zQuoteUtil.ZBillingQuoteRequest>();
                            zqu.zQuoteUtil.ZBillingQuoteRequest reqZbillingQuote = new zqu.zQuoteUtil.ZBillingQuoteRequest();
                            reqZbillingQuote.sfdcQuoteId = quoteObj.id ; // SFDC Quote ID
                            objQuoteCollection.quoteRequests.add(reqZbillingQuote);
                    
                            lstQuotesReadyForZBilling.add(objQuoteCollection);
                    }       
                   
                   // call the z billing method i.e Zuora API 
                    system.debug('+++++++++list send for zbilling to method sendQuoteToZuora'+lstQuotesReadyForZBilling);
                    List<zqu.zQuoteUtil.zBillingResult> lstResultZBill = sendQuoteToZuora(lstQuotesReadyForZBilling); // see below the method defination sendQuoteToZuora()
                    system.debug('+++++++++Zbilling result lstResultZBill '+lstResultZBill);
                    
                    //*********** upading the fail record with error msg or updating the status and recordtype of sucess quote
                    if(lstResultZBill != null && lstResultZBill.size() > 0)
                    {  
                        String status = 'Sent to Z-Billing' ;
                        for(zqu.zQuoteUtil.zBillingResult objBillingResult : lstResultZBill)
                        {
                          
                          if(!objBillingResult.success && string.isNotBlank(objBillingResult.sfdcQuoteId))
                          {
                                 // *******************check if quote has been tried to send in z billing again and update the staus to 'sent to z billing' if yes
                               if(String.isNotBlank(objBillingResult.message) && objBillingResult.message.containsIgnoreCase('Read Only'))
                                {
                                    zqu__Quote__c objZquote = createQuote(objBillingResult.sfdcQuoteId,status,null,objBillingResult.zSubscriptionId,mapSubsTypeAndRecordTypeId,mapIDAndQuoteObj);
                                    mapIdandQuotesForUpdate.put(objBillingResult.sfdcQuoteId,objZquote);
                                }
                                else{
                                    zqu__Quote__c objZquote = createQuote(objBillingResult.sfdcQuoteId,null,objBillingResult.message,null,null,null);
                                    mapIdandQuotesForUpdate.put(objBillingResult.sfdcQuoteId,objZquote);}
                          }   
                          else if(objBillingResult.success && string.isNotBlank(objBillingResult.sfdcQuoteId))
                          {
                                   system.debug('++++++ subscription id'+objBillingResult.zSubscriptionId);
                                zqu__Quote__c objZquote = createQuote(objBillingResult.sfdcQuoteId,status,null,objBillingResult.zSubscriptionId,mapSubsTypeAndRecordTypeId,mapIDAndQuoteObj);
                                mapIdandQuotesForUpdate.put(objBillingResult.sfdcQuoteId,objZquote);
                                system.debug('++++++recordtype'+objZquote.RecordTypeId);
                          }
                          
                      }
                     
                      system.debug('++++++ values contain in the resultset '+mapIdandQuotesForUpdate.keyset());
                      system.debug('++++++ size return result after z billing mapIdandQuotesForUpdate'+mapIdandQuotesForUpdate.values().size());
                    }
                   
                }

                //***********if duplicate found call the update method
                if(lstDuplicateQuotes != null && lstDuplicateQuotes.size() > 0)
                {
                   String status = 'Sent to Z-Billing' ;
                   //String errorValue = 'The quote has been successfully sent to Zuora';
                   for(zqu__Quote__c obj : lstDuplicateQuotes)
                   { 
                     zqu__Quote__c objZquote = createQuote(obj.id,status,null,mapQuoteNumAndSubsId.get(obj.zqu__Number__c),mapSubsTypeAndRecordTypeId,mapIDAndQuoteObj);
                     mapIdandQuotesForUpdate.put(obj.id,objZquote);
                   }
                }
                
                     
                //*******************find out if an unknown error occurs in zuora end
                        
                if(mapIDAndQuoteObj != null && mapIDAndQuoteObj.size() > 0)
                {   String errorMsg = 'An unknown error has occur.Resend the quote to Zuora' ;
                    for(String quoteId : mapIDAndQuoteObj.keyset())
                    {  
                        if((mapIdandQuotesForUpdate != null && mapIdandQuotesForUpdate.size() > 0 && !mapIdandQuotesForUpdate.containsKey(quoteId)) || (mapIdandQuotesForUpdate == null && mapIdandQuotesForUpdate.size() == 0) || mapIdandQuotesForUpdate.values().isEmpty())
                        {
                            zqu__Quote__c objZquote = createQuote(quoteId,null,errorMsg,null,null,null);
                            mapIdandQuotesForUpdate.put(quoteId,objZquote);
                        }
                    }
                       
                      system.debug('++++++++++inside unknown error mapIdandQuotesForUpdate'+mapIdandQuotesForUpdate.values());
                      system.debug('++++++++++increase in size after inside unknown error '+mapIdandQuotesForUpdate.values().size());                
                }
                    
               
                if(mapIdandQuotesForUpdate != null && mapIdandQuotesForUpdate.size() > 0)
                {
                    try
                    {   
                        system.debug('+++++ fist before update----'+mapIdandQuotesForUpdate.values());
                        Database.SaveResult[] lstResultSet = Database.Update(mapIdandQuotesForUpdate.values(), false);
                        system.debug('+++++lstResultSet inside try of update quote'+lstResultSet );
                    }
                    catch(Exception e)
                    {
                        System.debug('+++ inside catch updating quote: ' + e.getMessage());
                    }
                }                   
    
    }    
      
    //************** Making the quote list chunks of 30 as after 30 quotes the call to z billing method become asynchronous
    public static zqu.zQuoteUtil.zBillingResult[] sendQuoteToZuora(List<zqu.zQuoteUtil.ZBillingQuoteCollection> lstQuotes)
    {
      system.debug('++++before try of sendQuoteToZuora');
        try 
        {
            if(lstQuotes == null) return null;
            List<zqu.zQuoteUtil.zBillingResult> fullResults = new List<zqu.zQuoteUtil.zBillingResult>();
            List<List<zqu.zQuoteUtil.ZBillingQuoteCollection>> batches = new List<List<zqu.zQuoteUtil.ZBillingQuoteCollection>>();
            if(lstQuotes.size() > MAX_BATCH_SIZE)
            {
                for(integer i=0; i<lstQuotes.size();i++) 
                {
                    if(Math.mod(i, MAX_BATCH_SIZE) == 0) 
                    {
                        batches.add(new List<zqu.zQuoteUtil.ZBillingQuoteCollection>{ lstQuotes[i] });
                    }else
                    {
                        batches.get(i/MAX_BATCH_SIZE).add(lstQuotes[i]);
                    }
                }
            }
            else
            {
                batches.add(lstQuotes);
            }
            system.debug('+++++++++batches i.e list inside list'+batches);
            for(List<zqu.zQuoteUtil.ZBillingQuoteCollection> batch : batches)
            {
                system.debug('+++++++++batch inside each for '+batch );
                List<zqu.zQuoteUtil.zBillingResult> results = zqu.zQuoteUtil.sendToZBilling(batch) ;//!Test.isRunningTest())? zqu.zQuoteUtil.sendToZBilling(batch):new List<zqu.zQuoteUtil.zBillingResult>();
                system.debug('+++++++++results '+results );
                fullResults.addAll(results);  
            }
            system.debug('+++++++++fullResults'+fullResults);
            return fullResults; 
        }
        catch(exception e)
        {
            system.debug('++++inside catch of sendToZuora method');
            System.debug('+++The following exception has occurred:Demo ' + e.getMessage());
            System.debug('++++Inside Catch print stack trace Demo'+e.getStackTraceString()) ;
        }  
        return null;
    }   
    
    
     //************** craete quote object function takin paramete, quote id,quote status,quote error message,zuora subscription id,map of subscrition type and recordtype id
     //******************and map of quote id and quote obeject
    public static zqu__Quote__c createQuote(String quoteId,String quoteStatus,String quoteErrorMessage,String zuoraSubsId,Map<String,String> mapSubTypeNRcrdTyp,Map<String,zqu__Quote__c> mapQuoteIdNQuoteObject )
    {
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.id = quoteId;
        if(quoteStatus != null && String.isNotBlank(quoteStatus))
        {
         objZquQuote.zqu__Status__c = quoteStatus;
        }
        if(zuoraSubsId != null && String.isNotBlank(zuoraSubsId) )
        {
         objZquQuote.zqu__ZuoraSubscriptionID__c = zuoraSubsId;
        }
         objZquQuote.Error_Message_When_Z_Billing_Fail__c = quoteErrorMessage;
        
        if(mapQuoteIdNQuoteObject != null && mapSubTypeNRcrdTyp != null && mapQuoteIdNQuoteObject.get(quoteId).zqu__SubscriptionType__c != null && mapSubTypeNRcrdTyp.containsKey(mapQuoteIdNQuoteObject.get(quoteId).zqu__SubscriptionType__c))
        {objZquQuote.RecordTypeId = mapSubTypeNRcrdTyp.get(mapQuoteIdNQuoteObject.get(quoteId).zqu__SubscriptionType__c);} 
        return objZquQuote ;
        
    }       
}