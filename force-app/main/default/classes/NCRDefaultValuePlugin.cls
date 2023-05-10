// ===========================================================================
// Object: NCRDefaultValuePlugin
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: The controller implementation of zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin, set in Component Registration of Z-Quotes config
//    This default implementation will delegate to division-specific implementation of INCRDefaultValuePlugin
// ===========================================================================
// Changes: 2016-03-17 Reid Beckett
//           Class created
// ===========================================================================
global class NCRDefaultValuePlugin extends zqu.CreateQuoteController.PopulateDefaultFieldValuePlugin implements zqu.PropertyComponentController.IPopulateValuePlugin
{
  global override void populateDefaultFieldValue(SObject record, zqu.PropertyComponentController.ParentController pcc)
  {   
    if(!Test.isRunningTest()){
        super.populateDefaultFieldValue(record,pcc);
        system.debug('NCRDefaultValuePlugin called');
    }

    Opportunity[] opps;
    Id oppId = ApexPages.currentPage().getParameters().get('oppId');
    if(!String.isBlank(oppId))
    {
      opps = [select Id, AccountId, Opportunity_Classification__c,Account.Subscription_Group__c /*Solution_Portfolio__c*/ from Opportunity where Id = :oppId];
    }else{
      oppId = (Id)record.get(zqu__Quote__c.fields.zqu__Opportunity__c.getDescribe().getName());
      if(!String.isBlank(oppId)) opps = [select Id, AccountId, Opportunity_Classification__c,Account.Subscription_Group__c /*Solution_Portfolio__c*/ from Opportunity where Id = :oppId];
    }

    if(opps != null && !opps.isEmpty())
    {
      //get the default value plugin from the /*Solution_Portfolio__c*/ Account's subscription group  value
      INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin',/*opps[0].Solution_Portfolio__c*/ opps[0].Account.Subscription_Group__c);
      if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opps[0], (zqu__Quote__c)record, pcc);
    }
    /* Modified By [29-Sept-2016] : AS251035 - Regarding User Stroy no. 1499 of SCA
       Set the Logic in else if part becuase there are some case where Sales person can
       create the Quote from the Account directly and set the Defaulted value of
       Solution Portfolio to CRM Account.
    */
    if (String.isBlank(oppId)){
        INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', 'CRM Account');
        if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(null, (zqu__Quote__c)record, pcc);
    }
  }
}