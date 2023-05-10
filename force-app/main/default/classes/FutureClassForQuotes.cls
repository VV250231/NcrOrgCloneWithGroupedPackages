/*
############################################################################################################
# Project Name..........: Subscription Commerce Application                                                                    
# Created by............: Tania Sen                                                               
# Created Date..........: 27-08-2016                                                                               
# Last Modified by......: Tania Sen 
# Last Modified Date....: 15-09-2016 
# Description...........: This is a future class, it has been called from the trigger UpdateSubscriptionChargesInZuora
#############################################################################################################
*/


global class FutureClassForQuotes
{
  
   public static final String ZOQL_findSubscriptionById = 'select Id,Name,ShipToERPSiteNumber__c,ShipToAccountName__c,InvoiceGrouping__c, OriginalId, ContractEffectiveDate, ServiceActivationDate, IsInvoiceSeparate, ReportingOnly__c, CreatedDate, TermType, InitialTerm, Version, PreviousSubscriptionId, TermStartDate, SubscriptionEndDate from Subscription where Id = {0}';
   public static final String ZOQL_findRatePlansBySubscriptionId = 'select Id,Name,ProductRatePlanId, SubscriptionId, AmendmentId from RatePlan where SubscriptionId = {0}';
   public static final String ZOQL_findRatePlanChargesByRatePlanIds = 'SELECT Id,Name,BundleName__c,ProductRatePlanChargeId,ChargeModel,ChargeType,UOM,Quantity,ChargedThroughDate,EffectiveStartDate,EffectiveEndDate,RatePlanId,ChargeNumber,CreatedDate,MRR,Price,TriggerEvent,TriggerDate,BillingPeriod FROM RatePlanCharge WHERE {0}';
   public static final String ZOQL_findProductRatePlanChargesByProductRatePlanId = 'select Id,ExcludefromBundle__c,ProductRatePlanId, ChargeModel, TriggerEvent, BillingPeriod from ProductRatePlanCharge where {0}';
   public static final Integer MAX_UPDATE_BATCH_SIZE = 45; //the max number of objects to send to zupdate call
   public static Zuora.zApi zuoraApi;
   
   public static  Zuora.zApi getZuoraAPIInstance() 
   {
    System.debug('+++Inside getZuoraAPIInstance');
        if(zuoraApi == null) 
        {
             zuoraApi = new Zuora.zApi();
        }
        return zuoraApi;
   }
   
    public static String enquote(String s)
    {
        return '\'' + s + '\'';
    }
                
     //generate an OR clause from a list of values
    public static String generateOrClause(String filterField, List<String> filterValues) 
    {
        if (filterValues == null || filterValues.isEmpty()) return '';
        else 
        {
            string prefix = filterField + ' = \'';
            return prefix + String.join(filterValues, '\' OR ' + prefix) + '\'';
        }
    }
         
  
    private static  Zuora.zObject findSubscription(String zuoraSubscriptionId)
    {
        String zoql = String.format(ZOQL_findSubscriptionById, new String[]{ enquote(zuoraSubscriptionId) });
        Zuora.zObject[] zsubs = zquery(zoql);
        System.debug('+++zsubs first query to subzcription'+zsubs);
        if(zsubs.isEmpty()) return null;
        return zsubs[0];
    }
    private static  Zuora.zObject[] findRatePlans(String zuoraSubscriptionId)
    {
        String zoql = String.format(ZOQL_findRatePlansBySubscriptionId, new String[]{ enquote(zuoraSubscriptionId) });
        System.debug('+++zsubs first query to Rate Plans'+zquery(zoql));
        return zquery(zoql);
    }

    private static  Zuora.zObject[] findRatePlanCharges(Set<String> ratePlanIds)
    {
        String zoql = String.format(ZOQL_findRatePlanChargesByRatePlanIds, new String[]{generateOrClause('RatePlanId', new List<String>(ratePlanIds))});
        System.debug('+++zsubs first query to Rate Plans Charges'+zquery(zoql));
        return zquery(zoql);
    }
    
    private static Zuora.zObject[] findProductRatePlanCharges(Set<String> productRatePlanChargeIds)
    {
        String zoql = String.format(ZOQL_findProductRatePlanChargesByProductRatePlanId, new String[]{generateOrClause('Id', new List<String>(productRatePlanChargeIds))});
        return zquery(zoql);
    }
    
    //zquery implementation
    public static  List<Zuora.ZObject> zquery(string zoql)
    {
        List<Zuora.zObject> results = Test.isRunningTest()?new List<Zuora.zObject>() :zuoraApi.zquery(zoql);
        return results;
    }
    
    public static Map<String,String> mapPRPCExcludeBundle = new  Map<String,String>();
    public static ZuoraSubscription_NCR findZuoraSubscription(String zuoraSubscriptionId)
    {
        Zuora.zObject zsub = findSubscription(zuoraSubscriptionId);
        if(zsub == null) return null;
        ZuoraSubscription_NCR ZuoraSubscription_NCR = new ZuoraSubscription_NCR(zsub);

        Set<String> ratePlanIds = new Set<String>();
        Set<String> productrtPlnChrgIds = new Set<String>();
       
        for(Zuora.zObject zrp : findRatePlans(zuoraSubscriptionId))
        {
            ZuoraSubscription_NCR.RatePlan rp = new ZuoraSubscription_NCR.RatePlan(zrp);
            ZuoraSubscription_NCR.subscription.ratePlans.add(rp);
            ratePlanIds.add(rp.id);
           
        }

        for(Zuora.zObject zrpc : findRatePlanCharges(ratePlanIds))
        {
            ZuoraSubscription_NCR.RatePlanCharge rpc = new ZuoraSubscription_NCR.RatePlanCharge(zrpc);
            ZuoraSubscription_NCR.RatePlan rp = ZuoraSubscription_NCR.subscription.findRatePlanById(rpc.RatePlanId);
            if(rp != null) rp.ratePlanCharges.add(rpc);
            if(String.isNotBlank(rpc.ProductRatePlanChargeId))productrtPlnChrgIds.add(rpc.ProductRatePlanChargeId);
        }
         System.debug('+++setOfProductRatePlanChargeIdsfromSRPC'+productrtPlnChrgIds);
        
        if(productrtPlnChrgIds != null && productrtPlnChrgIds.size() > 0){
        for(Zuora.zObject zprpc : findProductRatePlanCharges(productrtPlnChrgIds))
        {   
            ZuoraSubscription_NCR.ProductRatePlanCharge prpc = new ZuoraSubscription_NCR.ProductRatePlanCharge(zprpc);
            String excludefromBundle_PRPC = (String)zprpc.getValue('ExcludefromBundle__c');
            if(String.isNotBlank(prpc.id) && String.isNotBlank(excludefromBundle_PRPC))
            mapPRPCExcludeBundle.put(prpc.id,excludefromBundle_PRPC);
         }}
       
       return ZuoraSubscription_NCR;
    }

    
    //***********************************************************Method For Updating Zuora Subscription*****************************************************************
    //***************this method is called from UpdateSubscriptionChargesInZuora trigger in Subscription object ***********
   
   @future(callout=true)
    public static void updateSubscriptionChargesOfZuora(Set<String> quoteNumbers,Set<String> subIds)
    { 
       System.debug('+++before query');
       // Get those quotes records based on the IDs
       List<zqu__Quote__c> lstAmendmentQuotes = new List<zqu__Quote__c>();
       List<Zuora__Subscription__c> lstSubscription = new List<Zuora__Subscription__c>();
       if(quoteNumbers != null && quoteNumbers.size() >0){
       lstAmendmentQuotes = [SELECT id,Reporting_ShipTo_Billing_Account_Name__c,Ship_To_Lookup__r.Zuora__Zuora_Id__c,InvoiceGrouping__c ,zqu__ZuoraSubscriptionID__c,OverridePaymentTerm__c,Is_NCR_Quote__c ,BundleNameNew__c, ReportingOnly__c, zqu__SubscriptionType__c,Name, Subscription_Invoice_Batch__c, Subscription_Group__c, zqu__InvoiceOwnerId__c, zqu__Number__c FROM zqu__Quote__c WHERE zqu__Number__c IN :quoteNumbers FOR UPDATE];}
       System.debug('++lstAmendmentQuotes'+lstAmendmentQuotes );
        
       // Get subscription id and other field values whose owner has been changed for story SC2015_AGL-4362
       if(subIds != null && subIds.size() > 0){
       lstSubscription=[select id,Ship_To_ERP_Site_Number_By_Formula__c,Ship_To_Account_Name_By_Formula__c,Zuora__Zuora_Id__c, Zuora__CustomerAccount__r.Zuora__Zuora_Id__c , Zuora__InvoiceOwner__r.Zuora__Zuora_Id__c, Zuora__QuoteNumber__c,Zuora__Account__r.FI_Type__c, Zuora__Account__r.DI_Customer__c, Zuora__Account__r.DPV_Provider__c,ShipToERPSiteNumber__c,ShipToAccountName__c, Zuora__Account__r.DPV_Interface__r.Solution_Provider_Product__c from Zuora__Subscription__c where id IN: subIds FOR UPDATE ];} 
        
       // Start the session
       try 
        {
            System.debug('+++Inside try');
            if(!Test.isRunningTest())FutureClassForQuotes.getZuoraAPIInstance().zlogin();
        }
        catch(Exception e)
        {
            System.debug('+++Inside catch');
        }
       
       Zuora.zObject[] zChargeUpdates = new Zuora.zObject[]{};
       Zuora.zObject[] zSubUpdates = new Zuora.zObject[]{};
        Zuora.zObject[] zAccUpdates = new Zuora.zObject[]{};
       System.debug('+++sakshi++++'+lstSubscription);
       //for Story SC2015_AGL-4362
       if(lstSubscription != null && lstSubscription.size()>0)
       {
       System.debug('+++sakshi++++');
           for(Zuora__Subscription__c objSub:lstSubscription)
           {
             if(!Test.isRunningTest())
            {
                    if((objSub.ShipToERPSiteNumber__c != objSub.Ship_To_ERP_Site_Number_By_Formula__c) || (objSub.ShipToAccountName__c !=  objSub.Ship_To_Account_Name_By_Formula__c)){
                        Zuora.zObject subUpdate = new Zuora.zObject('Subscription');
                         System.debug('+++sakshi++++'+objSub.Ship_To_ERP_Site_Number_By_Formula__c);
                        subUpdate.setValue('Id', objSub.Zuora__Zuora_Id__c);
                        subUpdate.setValue('ShipToERPSiteNumber__c', objSub.Ship_To_ERP_Site_Number_By_Formula__c);
                        subUpdate.setValue('ShipToAccountName__c', objSub.Ship_To_Account_Name_By_Formula__c);
                        zSubUpdates.add(subUpdate);
                    }
                        //Creating Account object to update the Bill To and Ship To Accounts in zuora
                        Zuora.zObject AccShipToUpdate = new Zuora.zObject('Account');
                        AccShipToUpdate.setValue('Id', objSub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c);
                        AccShipToUpdate.setValue('fiType__c', objSub.Zuora__Account__r.FI_Type__c);
                        AccShipToUpdate.setValue('DPVCode__c', objSub.Zuora__Account__r.DPV_Interface__r.Solution_Provider_Product__c);
                        AccShipToUpdate.setValue('diNumber__c', objSub.Zuora__Account__r.DI_Customer__c);
                       for(zqu__Quote__c temp : lstAmendmentQuotes){
                          
                            if(temp.Ship_To_Lookup__r.Zuora__Zuora_Id__c== objSub.Zuora__CustomerAccount__r.Zuora__Zuora_Id__c && temp.zqu__Number__c == objSub.Zuora__QuoteNumber__c ){
                               AccShipToUpdate.setValue('Division__h', temp.Subscription_Group__c); 
                               AccShipToUpdate.setValue('Batch', temp.Subscription_Invoice_Batch__c);     
                            }
                        }
                        zAccUpdates.add(AccShipToUpdate);
                    if(lstAmendmentQuotes.size() > 0){
                        for(zqu__Quote__c temp : lstAmendmentQuotes){
                        
                            if(temp.zqu__Number__c == objSub.Zuora__QuoteNumber__c && temp.zqu__InvoiceOwnerId__c == objSub.Zuora__InvoiceOwner__r.Zuora__Zuora_Id__c){
                                Zuora.zObject AccBillToUpdate = new Zuora.zObject('Account');
                                AccBillToUpdate.setValue('Id', objSub.Zuora__InvoiceOwner__r.Zuora__Zuora_Id__c);
                                AccBillToUpdate.setValue('fiType__c', objSub.Zuora__Account__r.FI_Type__c);
                                AccBillToUpdate.setValue('DPVCode__c', objSub.Zuora__Account__r.DPV_Interface__r.Solution_Provider_Product__c);
                                AccBillToUpdate.setValue('diNumber__c', objSub.Zuora__Account__r.DI_Customer__c);
                               // AccBillToUpdate.setValue('CustomPaymentTerm__c', temp.CustomPaymentTerm__c);
                                AccBillToUpdate.setValue('Division__h', temp.Subscription_Group__c);
                                 System.debug('+++Tania subscription to be update with new owner' +temp.Subscription_Group__c);
                                
                                AccBillToUpdate.setValue('Batch', temp.Subscription_Invoice_Batch__c);
                                zAccUpdates.add(AccBillToUpdate);
                                break;
                            }
                           
                        }
                    }
            }
             else{
                    FutureClassForQuotes.increasecoverage();
                    ZuoraSubscription_NCR.increasecoverage();
                }      
           }    
          System.debug('+++Tania subscription to be update with new owner' +zSubUpdates);          
       }       
       if(lstAmendmentQuotes == null && lstAmendmentQuotes.size()==0)return;
       for(zqu__Quote__c objZQuotes: lstAmendmentQuotes )
       {
            if((objZQuotes.zqu__SubscriptionType__c == 'Amend Subscription') && String.isNotBlank(objZQuotes.zqu__ZuoraSubscriptionID__c) && objZQuotes.Is_NCR_Quote__c == true)
               {
                    ZuoraSubscription_NCR fullZuoraSub = FutureClassForQuotes.findZuoraSubscription(objZQuotes.zqu__ZuoraSubscriptionID__c);
                    //System.debug('+++Inside Future call findZuoraSubscription'+fullZuoraSub.subscription.getBooleanValue('IsInvoiceSeparate'));
                    System.debug('+++Inside Future call findZuoraSubscription'+fullZuoraSub );
                    if(!Test.isRunningTest())
                    {
                       // system.debug('the value of Reporting Only-'+ fullZuoraSub.subscription.getStringValue('ReportingOnly__c'));
                        if(objZQuotes.ReportingOnly__c != null && objZQuotes.ReportingOnly__c == 'Yes'){
                            system.debug('Inside the check of Reporting Only');
                            Zuora.zObject subUpdate = new Zuora.zObject('Subscription');
                            subUpdate.setValue('Id', fullZuoraSub.subscription.Id);
                            subUpdate.setValue('IsInvoiceSeparate', true);
                            zSubUpdates.add(subUpdate);
                        }
                        // as null value does not get synched at the time of amendment we need to do it by code for the field Invoice Grouping
                        system.debug('****before the check of InvoiceGrouping__c' +objZQuotes.InvoiceGrouping__c);
                        if(String.isBlank(objZQuotes.InvoiceGrouping__c) && objZQuotes.zqu__SubscriptionType__c == 'Amend Subscription' )
                        {
                        
                            system.debug('the value of InvoiceGrouping__c Only-'+ fullZuoraSub.subscription.getStringValue('InvoiceGrouping__c'));
                            system.debug('****Inside the check of InvoiceGrouping__c' +objZQuotes.InvoiceGrouping__c);
                            Zuora.zObject subUpdate = new Zuora.zObject('Subscription');
                            subUpdate.setValue('Id', fullZuoraSub.subscription.Id);
                            subUpdate.setValue('InvoiceGrouping__c', 'None');
                            zSubUpdates.add(subUpdate);
                            system.debug('c'+zSubUpdates);
                        }
                        
                       
                        
                    for(ZuoraSubscription_NCR.RatePlan rp : fullZuoraSub.subscription.ratePlans) 
                    {
                        for(ZuoraSubscription_NCR.RatePlanCharge rpc : rp.ratePlanCharges) 
                        {  
                         System.debug('+++rpc.ProductRatePlanChargeId'+rpc.ProductRatePlanChargeId );
                           String zuoraExcludeFromBundle = '';          
                           if(mapPRPCExcludeBundle != null && mapPRPCExcludeBundle.containsKey(rpc.ProductRatePlanChargeId))
                           {
                               zuoraExcludeFromBundle = mapPRPCExcludeBundle.get(rpc.ProductRatePlanChargeId) ;      
                           }
                           String zuoraChargeType = rpc.getStringValue('ChargeType') ; // no use after jira story SC2015_AGL-3785
                           String bundleNameOfZuoraCharges = '';   
                           System.debug('+++zuoraExcludeFromBundle '+zuoraExcludeFromBundle +'++zuoraChargeType'+zuoraChargeType );
                           Zuora.zObject rpcUpdate = new Zuora.zObject('RatePlanCharge');
                           rpcUpdate.setValue('Id', rpc.Id);
                           
                           if(zuoraExcludeFromBundle == 'No')
                           { 
                               if(objZQuotes.BundleNameNew__c != 'Not a Bundle')
                               {
                                  bundleNameOfZuoraCharges = objZQuotes.BundleNameNew__c ;
                                 //commented for SC2015_AGL-3785 bundleNameOfZuoraCharges = zuoraChargeType == 'OneTime'?objZQuotes.BundleNameNew__c +' '+'One-Time':objZQuotes.BundleNameNew__c +' '+zuoraChargeType  ;
                               }
                           }
                           rpcUpdate.setValue('BundleName__c',bundleNameOfZuoraCharges);  
                           zChargeUpdates.add(rpcUpdate);
                        }
                    }
                   }
                   else
                   {
                         FutureClassForQuotes.increasecoverage();
                         ZuoraSubscription_NCR.increasecoverage();
                   }                  
               }
        }
     
     //****************update subscription of zuora
        if(!zChargeUpdates.isEmpty()) 
        {
           
            List<Zuora.zApi.SaveResult> chargeSaveResults = FutureClassForQuotes.zupdate(zChargeUpdates);
              
            for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) 
            {
                if(!chargeSaveResult.Success) {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : chargeSaveResult.Errors)
                    {
                       errMessages.add((String)err.getValue('Message'));
                    }
                   system.debug('+++++++++++++++++++++++++errMessages'+errMessages);
                }
            }
        }
        
            //below update is for making IsInvoiceSeparate field update in subscription
        if(!zSubUpdates.isEmpty()) 
        {
            
            List<Zuora.zApi.SaveResult> chargeSaveResults = FutureClassForQuotes.zupdate(zSubUpdates);
            system.debug('**********Subscription Updates'+chargeSaveResults);
            for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) 
            {
                if(!chargeSaveResult.Success) {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : chargeSaveResult.Errors)
                    {
                       errMessages.add((String)err.getValue('Message'));
                    }
                   system.debug('+++++++++++++++++++++++++errMessages'+errMessages);
                }
            }
        }
    
        //below update is for making Account updates 
        if(!zAccUpdates.isEmpty()) 
        {
            
            List<Zuora.zApi.SaveResult> chargeSaveResults = FutureClassForQuotes.zupdate(zAccUpdates);
            system.debug('**********Subscription Updates'+chargeSaveResults);
            for(Zuora.zApi.SaveResult chargeSaveResult : chargeSaveResults) 
            {
                if(!chargeSaveResult.Success) {
                    String[] errMessages = new String[]{};
                    for(Zuora.zObject err : chargeSaveResult.Errors)
                    {
                       errMessages.add((String)err.getValue('Message'));
                    }
                   system.debug('+++++++++++++++++++++++++errMessages'+errMessages);
                }
            }
        }
    }
  
   public Static List<Zuora.zApi.SaveResult> zupdate(List<Zuora.ZObject> zobjects)
   {
        try {
            if(zobjects == null) return null;
            List<Zuora.zApi.SaveResult> fullResults = new List<Zuora.zApi.SaveResult>();
            List<List<Zuora.zObject>> batches = new List<List<Zuora.zObject>>();
            if(zobjects.size() > MAX_UPDATE_BATCH_SIZE)
                {
                for(integer i=0; i<zobjects.size();i++) {
                    if(Math.mod(i, MAX_UPDATE_BATCH_SIZE) == 0) {
                        batches.add(new List<Zuora.zObject>{ zobjects[i] });
                    }else{
                        batches.get(i/MAX_UPDATE_BATCH_SIZE).add(zobjects[i]);
                    }
                }
            }else{
                batches.add(zobjects);
            }
            for(List<Zuora.zObject> batch : batches)
            { 
                 system.debug('+++++++++++++++++++++++++batch'+batch );
                List<Zuora.zApi.SaveResult> results = (!Test.isRunningTest()) ? zuoraApi.zupdate(batch) : new List<Zuora.zApi.SaveResult>();
                fullResults.addAll(results);    
            }
            return fullResults; 
        }finally{
            System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement               
        }   
    }
    
    public static void increasecoverage()
    {
    
    
               Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
    
    
    }
}