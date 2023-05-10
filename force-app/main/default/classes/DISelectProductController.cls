/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/


public with sharing class DISelectProductController {
    //public zqu.SelectProductComponentOptions theOptions { get; set; }
    public zqu.EditQuoteProductOptions editProductOptions{get;set;}
    public zqu__Quote__c quoteSobject {get;set;}
    public Map<String,List<ProductBundleWrapper>> bundles {get;set;}
    public List<String> bundleCategories {get;set;}
    public string  bilingId{get;set;}
    public string crmId{get;set;}
    public string flowID{get;set;}
    public string stepId{get;set;}
    public string oppId{get;set;}
    public DISelectProductController(){} 
    public DISelectProductController(ApexPages.StandardController stdController) 
    {
        system.debug('START constructor');

        Id quoteId = stdController.getId();
        if(quoteId <> null){
            quoteSobject = [select Id, zqu__StartDate__c, Renewal_Subscription_ID__c, zqu__Opportunity__r.Opportunity_Classification__c, 
                                RecordType.Name, zqu__Opportunity__r.Account.Subscription_Group__c, zqu__Account__r.Tier__c
                            from zqu__Quote__c where Id = :quoteId];
        }
        String quoteType = 'Subscription';
        if(quoteSobject.RecordType.Name == 'Amendment') quoteType = 'Amendment';

        editProductOptions = new zqu.EditQuoteProductOptions();
        editProductOptions.guidedSellingOptions= new zqu.ProductBundleGuidedSellingOptions();
        editProductOptions.guidedSellingOptions.quoteType = quoteType;
        editProductOptions.guidedSellingOptions.quoteId = ApexPages.currentPage().getParameters().get('Id');
        editProductOptions.productSelectorOptions = new zqu.SelectProductComponentOptions();
        editProductOptions.productSelectorOptions.quoteType = quoteType;
        editProductOptions.productSelectorOptions.quoteId = ApexPages.currentPage().getParameters().get('Id');
        bilingId =  ApexPages.currentPage().getParameters().get('billingAccountId');
        crmId = ApexPages.currentPage().getParameters().get('crmAccountId');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        flowID = ApexPages.currentPage().getParameters().get('flowId');
        stepId = ApexPages.currentPage().getParameters().get('stepId');
        if(quoteSobject.RecordType.Name == 'Default')
         editProductOptions.initialComponentMode   = zqu.EditQuoteProductOptions.GUIDED_SELLING_MODE;
        else{
          editProductOptions.initialComponentMode   = zqu.EditQuoteProductOptions.PRODUCT_SELECTOR_MODE;
        }


        if(!String.isBlank(quoteSobject.Renewal_Subscription_ID__c))
        {
            //This only overrides the save & close URL, not the save button
            //theOptions.saveUrl = URL.getSalesforceBaseUrl().toExternalForm() + Page.diSelectProducts.getUrl() +  '?id='+quoteId+'&x='+Math.random();
            ZuoraSubscription zuoraSubscription = ZuoraClient.getInstance().findZuoraSubscription(quoteSobject.Renewal_Subscription_ID__c);
            if(zuoraSubscription == null) {
                system.debug(LoggingLevel.ERROR, 'Zuora Subscription with ID ' + quoteSobject.Renewal_Subscription_ID__c + ' not found');
                throw new DISelectProductsException('Zuora Subscription with ID ' + quoteSobject.Renewal_Subscription_ID__c + ' not found');
            }
        }

        this.bundles = new Map<String,List<ProductBundleWrapper>>();

        if(DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r) && String.isBlank(quoteSobject.zqu__Account__r.Tier__c))
        {
            this.bundles.put('Error retrieving bundles. Please ensure a Tier is set on the Account and try again.', new List<ProductBundleWrapper>()); 
        }
        else
        {
            String soql = 'select Name, Active__c, Description__c, Category__c from Product_Bundle__c where Active__c = true ';

            if(DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r))
            {
                string strTier = quoteSobject.zqu__Account__r.Tier__c;
                //soql += 'and (Customer_Tier_Level__c = \'' + String.escapeSingleQuotes(quoteSobject.zqu__Account__r.Tier__c) + '\' or Customer_Tier_Level__c = NULL) ';
                 soql += 'and (Customer_Tier_Level__c = :strTier or Customer_Tier_Level__c = NULL) ';
            }
            else
            {
                soql += 'and Customer_Tier_Level__c = NULL ';
            }

            soql += 'order by Name asc';

            for(Product_Bundle__c pb : Database.query(String.escapeSingleQuotes(soql)))
            {
                String category = pb.Category__c;
                if(String.isBlank(category)) category = 'Additional Bundles';
                if(this.bundles.containsKey(category)) {
                    this.bundles.get(category).add(new ProductBundleWrapper(pb));
                }else{
                    this.bundles.put(category, new List<ProductBundleWrapper>{ new ProductBundleWrapper(pb) });
                }
            }
        }

        //sort the bundle categories:
        this.bundleCategories = new List<String>();
        Set<String> predefinedBundleCategories = new Set<String>{
            'Product Default Pricing', 'Conversion Sales', 'Additional Bundles'
        };
        for(String bundleCategory : predefinedBundleCategories) {
            if(this.bundles.containsKey(bundleCategory)) this.bundleCategories.add(bundleCategory);
        }

        for(String bundleCategory : this.bundles.keySet()) {
            if(!predefinedBundleCategories.contains(bundleCategory)) this.bundleCategories.add(bundleCategory);
        }

        system.debug('END constructor');
    }
    
    public Boolean hasAnyBundles {
        get {
            return !this.bundles.isEmpty();
        }
    }
    
    public PageReference initAction()
    {
        String quoteId = ApexPages.currentPage().getParameters().get('id');
        zqu__Quote__c qt = [select Id, zqu__Opportunity__r.Opportunity_Classification__c, /*zqu__Opportunity__r.Solution_Portfolio__c,*/ RecordType.Name, zqu__Account__r.Tier__c,zqu__Opportunity__r.Account.Subscription_Group__c from zqu__Quote__c where Id = :quoteId];
        /* SC2015_AGL-4411 -- Use diSelectProducts for all LOBs
        if(!DIQuoteUtil.isDigitalInsight(qt.zqu__Opportunity__r))
        {
            String url = Page.zqu__EditQuoteProducts.getUrl();
            url += '?id='+quoteId+'&stepNumber=3';
            return new PageReference(url);
        }else{
            */
            //For DI, force into the wizard flow
            String stepNumber = ApexPages.currentPage().getParameters().get('stepNumber');
            if(String.isBlank(stepNumber)) {
                String url = Page.diSelectProducts.getUrl();
                String quoteType = 'Subscription';
                if(qt.RecordType.Name == 'Amendment') quoteType = 'Amendment';
                url += '?id='+quoteId+'&stepNumber=3&quoteType='+quoteType;
                return new PageReference(url).setRedirect(true);
            }else{
                return addBundle();
            }
        //}
    }
    
    public PageReference addBundle()
    {
        system.debug('START addBundle');
        String bundleId = ApexPages.currentPage().getParameters().get('bundleId');
        if(!String.isBlank(bundleId))
        {
            //add the bundle to the quote
            Set<String> existingRatePlans = new Set<String>();
            zqu.zChargeGroup[] existingChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteSObject.Id);
            if(existingChargeGroups != null) { //Jan 19/2017 added null check for test coverage in pre-deployment staging
                for(zqu.zChargeGroup zcg : existingChargeGroups)
                {
                    system.debug('[DISP] zcg.productRateplanZuoraID='+zcg.productRateplanZuoraID);
                    existingRatePlans.add(zcg.productRateplanZuoraID);
                }
            }
            
            system.debug('[DISP] existingRatePlans:'+existingRatePlans);            

            Set<String> newPRPIds = new Set<String>();
            for(Product_Bundle_Rate_Plan__c brp : [select Product_Rate_Plan__c, Product_Rate_Plan__r.zqu__ZuoraId__c from Product_Bundle_Rate_Plan__c where Product_Bundle__c = :bundleId]){
                system.debug('[DISP] checking : '+brp.Product_Rate_Plan__r.zqu__ZuoraId__c);            
                if(!existingRatePlans.contains(brp.Product_Rate_Plan__r.zqu__ZuoraId__c)){
                    newPRPIds.add(brp.Product_Rate_Plan__c);
                }
            }
            if(newPRPIds.size() > 0)
            {
                List<zqu.zChargeGroup> zcgs = zqu.zQuoteUtil.getChargeGroups(quoteSobject.Id, new List<String>(newPRPIds));    
                if(!Test.isRunningTest()) zqu.zQuoteUtil.addChargeGroups(zcgs);
                
                String quoteType = 'Subscription';
                if(quoteSobject.RecordType.Name == 'Amendment') quoteType = 'Amendment';
        
                //DI-1768 - redirect to avoid error with component making callout after DML
                if(quoteType == 'Amendment') 
                    return new PageReference('/apex/diSelectProducts?editQuoteProductsMode=EditProducts&Id='+quoteId+'&quoteType='+quoteType+'&stepNumber=3').setRedirect(true);
            }
        }

        system.debug('END addBundle');
        return null;
    }

    public String quoteId {
        get {
            return quoteSobject.Id;
        }
    }

    public PageReference selectBundle(){
        return null;
    }

    public class ProductBundleWrapper 
    {
        public Product_Bundle__c productBundle {get;set;}

        public ProductBundleWrapper(Product_Bundle__c productBundle)
        {
            this.productBundle = productBundle;
        }
    }

    public class AddRemoveRatePlanPlugin implements zqu.SelectProductComponentOptions.IAddRemoveRatePlanPlugin
    {
        public void onAdd(String quoteId, List<String> addedRatePlanSFDCIds){
            system.debug('[DISP] onAdd '+quoteId+';'+addedRatePlanSFDCIds);
        }
        
        public void onRemove(String quoteId, List<String> removedRatePlanSFDCIds){
            system.debug('[DISP] onRemove '+quoteId+';'+removedRatePlanSFDCIds);
        }
    }
    
    public class SaveRatePlanPlugin implements zqu.SelectProductComponentOptions.ISaveRatePlanPlugin
    {
        public void onSave(List<zqu.zChargeGroup> addedChargeGroups, List<zqu.zChargeGroup> updatedChargeGroups, List<zqu.zChargeGroup> removedChargeGroups, List<zqu.zChargeGroup> persistedChargeGroups)
        {
            system.debug('[DISP] onSave: addedChargeGroups:'+addedChargeGroups+';updatedChargeGroups:'+updatedChargeGroups+';removedChargeGroups:'+removedChargeGroups+';persistedChargeGroups:'+persistedChargeGroups); 
        }
    }
    
    public class DISelectProductsException extends Exception {}
}