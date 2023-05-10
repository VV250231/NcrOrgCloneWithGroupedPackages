// ===========================================================================
// Author: Akshun Singh
// Purpose: Class which will handle the default value of Bundle Name on
//Quote Object in case of Amendment.
// ===========================================================================
// Changes: 2016-09-27 Akshun Singh
//           Class created
// ===========================================================================
// Changes: 2017-11-20 Sakshi Gandhi
// Added code to default intialTermPeriodType and renewalTermPeriodType as Month on creating new Quote 
// ===========================================================================
global class HSGDefaultValues extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin implements INCRDefaultValuePlugin{  
   
       global override void populateDefaultFieldValue(SObject record, zqu.PropertyComponentController.ParentController pcc)
    {
        populateDefaultFieldValue(record, pcc);
    }
   
   
   global void populateDefaultFieldValue(Opportunity opp, zqu__Quote__c record, zqu.PropertyComponentController.ParentController parentController)
   {
      //Defaulting the Subscription Group field on Quote 2nd page as per US #5187
      String ZuoraBillAccId = (String) apexpages.currentpage().getparameters().get('billingAccountId');
      if(ZuoraBillAccId != null && !String.isEmpty(ZuoraBillAccId)){
        Zuora__CustomerAccount__c var   = [SELECT Id,Subscription_Group__c,Zuora__Batch__c,Zuora__External_Id__c FROM Zuora__CustomerAccount__c where Zuora__External_Id__c = :ZuoraBillAccId limit 1];
        if(var != null){
            record.put(zqu__Quote__c.fields.Subscription_Group__c.getDescribe().getName(),var.Subscription_Group__c);
        }
      }
      //Default values in case of new Subscription
       if(apexpages.currentpage().getparameters().get('quoteType') == 'Subscription'){
       
         record.put(zqu__Quote__c.fields.zqu__InitialTermPeriodType__c.getDescribe().getName(),'Month');
         record.put(zqu__Quote__c.fields.zqu__RenewalTermPeriodType__c.getDescribe().getName(),'Month');
        }
        system.debug('inside the overide method'+apexpages.currentpage().getparameters().get('quoteType'));
        if(apexpages.currentpage().getparameters().get('quoteType') == 'Amendment'){
            String ExistingSubId = (String) apexpages.currentpage().getparameters().get('subscriptionId');
            system.debug('inside the overide method 1');
            if(!String.isBlank(ExistingSubId)){
                system.debug('inside the overide method 2');
                Zuora__Subscription__c subObj = [Select Id, InvoiceGrouping__c,OverridePaymentTerm__c, Name, ReportingOnly__c from Zuora__Subscription__c where Zuora__Zuora_Id__c = :ExistingSubId limit 1];
                if(subObj != null && subObj.ReportingOnly__c != null){
                    record.put('ReportingOnly__c',subObj.ReportingOnly__c); //ReportingOnly__c 
                }
                if(subObj != null && subObj.InvoiceGrouping__c != null){
                    record.put('InvoiceGrouping__c',subObj.InvoiceGrouping__c);
                }
                if(subObj != null && subObj.OverridePaymentTerm__c!= null){ //To default override payment term plan
                    record.put('OverridePaymentTerm__c',subObj.OverridePaymentTerm__c);
                }
                
                list <Zuora__SubscriptionProductCharge__c> bundleName = [Select BundleName__c,Zuora__Type__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__Zuora_Id__c = :ExistingSubId and BundleName__c != null];
                
                
                String defualtValue;
                if(bundleName != null && bundleName.size() > 0){
                    defualtValue = bundleName[0].BundleName__c;
                }
                else{
                    system.debug('Do Nothing and simply populate the existing functionality');
                }
                /**if(bundleName != null && bundleName.size() > 0 && bundleName[0].Zuora__Type__c == 'One-Time'){
                    defualtValue = bundleName[0].BundleName__c.removeEnd(' One-Time');
                }
                else if(bundleName != null && bundleName.size() > 0 && bundleName[0].Zuora__Type__c == 'Recurring'){
                    defualtValue = bundleName[0].BundleName__c.removeEnd(' Recurring');
                }
                else if(bundleName != null && bundleName.size() > 0 && bundleName[0].Zuora__Type__c == 'Usage'){
                    defualtValue = bundleName[0].BundleName__c.removeEnd(' Usage fee');
                }**/
                
                //super.populateDefaultFieldValue(record, pcc);  
              
              //Populate default values in the bundle Name Field
                if(!String.isBlank(defualtValue)){
                    record.put('BundleNameNew__c',defualtValue);
                }
            
            }
        }
        else{
            system.debug('this will on the double check');
            //super.populateDefaultFieldValue(record, pcc);
        }
   }

}