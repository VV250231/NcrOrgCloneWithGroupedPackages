// ===========================================================================
// Object: ProductBundleImportScript
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Script to create product bundle records by reading from new custom
// object, Product_Bundle_Import__c, and upserting Product_Bundle__c and
// Product_Bundle_Rate_Plan__c records
// ===========================================================================
// Changes: 2017-02-03 Reid Beckett
//           Class created
// ===========================================================================
global class ProductBundleImportScript {
    public static Boolean IsStatusUpdate = false; //set to true to avoid double update
    private Map<String,ImportRecord> importRecords {get;set;}
    private Map<String, Bundle> bundlesByName {get;set;}

    global ProductBundleImportScript(List<ImportRecord> importRecordsList) {
        this.importRecords = new Map<String,ImportRecord>();
        for(ImportRecord ir : importRecordsList) {
            this.importRecords.put(ir.guid, ir);
        }
        this.bundlesByName = new Map<String,Bundle>();
    }

    //Queuable implementation, called by trigger
    global class ProductBundleImportQueueable implements Queueable
    {
        private List<ImportRecord> importRecords;
        
        public ProductBundleImportQueueable(List<Product_Bundle_Import__c> importRecordSobjs) {
            this.importRecords = new List<ImportRecord>();
            for(Product_Bundle_Import__c sobj : importRecordSobjs) {
                if(sobj.Status__c == 'New')
                    this.importRecords.add(new ImportRecord(sobj));
            }
        }        

        public void execute(QueueableContext context)
        {
            new ProductBundleImportScript(this.importRecords).import();
        }
    }

    global void import()
    {
        system.debug('ProductBundleImportScript2:import:START');
        system.debug(JSON.serializePretty(this.importRecords));
        Map<String, Map<String,zqu__ProductRatePlan__c>> ratePlansByName = new Map<String, Map<String,zqu__ProductRatePlan__c>>();
        Map<Id, zqu__ProductRatePlan__c> ratePlansById = new Map<Id, zqu__ProductRatePlan__c>();
        Set<String> bundleNames = new Set<String>();
                Set<String> ratePlanNames = new Set<String>();
        
        for(ImportRecord ir : importRecords.values()) {
            if(!String.isBlank(ir.bundleName)) bundleNames.add(ir.bundleName);
            if(!String.isBlank(ir.ratePlanName)) ratePlanNames.add(ir.ratePlanName);
        }

        //find existing bundles
        for(Product_Bundle__c existingBundle : [select Id, Name, Description__c, Customer_Tier_Level__c, Category__c,
            (select Id, Name, Product_Bundle__c, Product_Rate_Plan__c, Product_Rate_Plan__r.Name from Product_Bundle_Rate_Plans__r) from Product_Bundle__c where Name in :bundleNames]) {
            bundlesByName.put(existingBundle.Name, new Bundle(existingBundle));
        }

        //find rate plans
        for(zqu__ProductRatePlan__c prp : [select Id, Name, CustomerTierLevel__c from zqu__ProductRatePlan__c where zqu__Deleted__c = false and Name in :ratePlanNames]) {
            String customerTierLevel = prp.CustomerTierLevel__c;
            if(String.isBlank(customerTierLevel)) customerTierLevel = '0'; //0 to represent no tier/null value for the map
            if(ratePlansByName.containsKey(prp.Name)) {
                Map<String, zqu__ProductRatePlan__c> prpsByTier = ratePlansByName.get(prp.Name);
                prpsByTier.put(customerTierLevel, prp);
            }else{
                ratePlansByName.put(prp.Name, new Map<String, zqu__ProductRatePlan__c>{ customerTierLevel => prp });
            }
            ratePlansById.put(prp.Id, prp);
        }

        //create new bundles
        for(ImportRecord ir : importRecords.values()) {
            if(!String.isBlank(ir.bundleName)) {
                if(!bundlesByName.containsKey(ir.bundleName)) {
                    //new bundle
                    Bundle bun = new Bundle(ir);
                    bundlesByName.put(ir.bundleName, bun);

                    if(!String.isBlank(ir.ratePlanName)) {
                        //determine the ProductRatePlan ID
                        Map<String, zqu__ProductRatePlan__c> prpsByTier = ratePlansByName.get(ir.ratePlanName);
                        String mapKey = String.isBlank(ir.ratePlanTierLevel) ? '0' : ir.ratePlanTierLevel;
                        if(prpsByTier != null && prpsByTier.containsKey(mapKey)) {
                            BundleRatePlan brp = new BundleRatePlan(new Product_Bundle_Rate_Plan__c(Product_Rate_Plan__c = prpsByTier.get(mapKey).Id));
                            brp.importRecord = ir;
                            bun.bundleRatePlansByName.put(ir.ratePlanName, brp);
                        } else {
                            ir.productBundleImportSobj.Status__c = 'Error';
                            ir.productBundleImportSobj.Message__c = 'Could not find matching rate plan with name \'' + ir.ratePlanName + '\' and tier ' + ir.ratePlanTierLevel;
                        }
                    }
                }else{
                    //existing bundle
                    Bundle bun = bundlesByName.get(ir.bundleName);
                    if(bun.importRecord == null) {
                        bun.importRecord = ir;
                        bun.bundleSobj.Category__c = ir.productBundleImportSobj.Bundle_Category__c;
                        bun.bundleSobj.Description__c = ir.bundleDescription;
                        bun.bundleSobj.Customer_Tier_Level__c = ir.bundleTierLevel;
                        bun.bundleSobj.Active__c = true;
                    }

                    if(bun.bundleRatePlansByName.containsKey(ir.ratePlanName)) {
                        //existing bundle rate plan
                        //in this case, the tier may not match
                        BundleRatePlan brp = bun.bundleRatePlansByName.get(ir.ratePlanName);
                        if(bun.bundleSobj.Id == null) {
                            //Error - 2 of same rate plan in same bundle
                            ir.productBundleImportSobj.Status__c = 'Error';
                            ir.productBundleImportSobj.Message__c = 'Cannot have two rate plans of the same name in the same bundle';
                        }else{
                            brp.importRecord = ir;  
                        }                       
                    }else{
                        //new bundle rate plan
                        if(!String.isBlank(ir.ratePlanName)) {
                            //determine the ProductRatePlan ID
                            Map<String, zqu__ProductRatePlan__c> prpsByTier = ratePlansByName.get(ir.ratePlanName);
                            String mapKey = String.isBlank(ir.ratePlanTierLevel) ? '0' : ir.ratePlanTierLevel;
                            if(prpsByTier != null && prpsByTier.containsKey(mapKey)) {
                                BundleRatePlan brp = new BundleRatePlan(new Product_Bundle_Rate_Plan__c(Product_Rate_Plan__c = prpsByTier.get(mapKey).Id));
                                brp.importRecord = ir;
                                bun.bundleRatePlansByName.put(ir.ratePlanName, brp);
                            } else {
                                ir.productBundleImportSobj.Status__c = 'Error';
                                ir.productBundleImportSobj.Message__c = 'Could not find matching rate plan with name \'' + ir.ratePlanName + '\' and tier ' + ir.ratePlanTierLevel;
                            }
                        }
                    }
                }
            }
        }

        //upsert the bundles and update the import records
        List<Product_Bundle__c> productBundleUpserts = new List<Product_Bundle__c>();
        for(Bundle b : bundlesByName.values()) {
            if(b.importRecord.productBundleImportSobj.Status__c == 'New') productBundleUpserts.add(b.bundleSobj);
        }

        List<Product_Bundle_Rate_Plan__c> pbrpUpserts = new List<Product_Bundle_Rate_Plan__c>();
        Database.UpsertResult[] upResults = Database.upsert(productBundleUpserts, false);
        integer i = 0;

        Map<Id, Bundle> bundlesById = new Map<Id, Bundle>();

        for(Database.UpsertResult upResult : upResults) {
            String bundleName = productBundleUpserts.get(i).Name;
            Bundle bun = bundlesByName.get(bundleName);

            if(upResult.isSuccess()) {
                bundlesById.put(upResult.getId(), bun);

                if(bun.importRecord != null) {
                    bun.importRecord.productBundleImportSobj.Product_Bundle__c = upResult.getId();
                    bun.importRecord.productBundleImportSobj.Status__c = 'Processed';
                    bun.importRecord.productBundleImportSobj.Message__c = null;
                }

                //Process the bundle rate plans
                for(BundleRatePlan brp : bun.bundleRatePlansByName.values()) {
                    if(brp.importRecord != null) {
                        if(brp.pbrpSobj.Product_Bundle__c == null) brp.pbrpSobj.Product_Bundle__c = upResult.getId();
                        system.debug('Upserting ' + brp.pbrpSobj);
                        pbrpUpserts.add(brp.pbrpSobj);
                    }
                }
            }else{
                if(bun.importRecord != null) {
                    bun.importRecord.productBundleImportSobj.Status__c = 'Error';
                    List<String> errorMessages = new List<String>();
                    for(Database.Error e : upResult.getErrors()) {
                        errorMessages.add(e.getMessage());
                    }
                    bun.importRecord.productBundleImportSobj.Message__c = String.join(errorMessages,';');
                }
            }
            i++;
        }

        //upsert the bundle rate plans
        i = 0;
        Database.UpsertResult[] upResults2 = Database.upsert(pbrpUpserts, false);
        for(Database.UpsertResult upResult : upResults2) {
            Id productBundleId = pbrpUpserts.get(i).Product_Bundle__c;
            Id productRatePlanId = pbrpUpserts.get(i).Product_Rate_Plan__c;

            Bundle bun = bundlesById.get(productBundleId);

            if(upResult.isSuccess()) {
                //Process the bundle rate plans
                for(BundleRatePlan brp : bun.bundleRatePlansByName.values()) {
                    if(brp.importRecord != null) {
                        brp.importRecord.productBundleImportSobj.Product_Bundle_Rate_Plan__c = upResult.getId();
                        brp.importRecord.productBundleImportSobj.Status__c = 'Processed';
                    }
                }
            }else{
                //Process the bundle rate plans
                for(BundleRatePlan brp : bun.bundleRatePlansByName.values()) {
                    if(brp.importRecord != null) {
                        brp.importRecord.productBundleImportSobj.Status__c = 'Error';
                        List<String> errorMessages = new List<String>();
                        for(Database.Error e : upResult.getErrors()) {
                            system.debug(e.getMessage());
                            errorMessages.add(e.getMessage());
                        }
                        brp.importRecord.productBundleImportSobj.Message__c = String.join(errorMessages,';');
                    }
                }
            }
            i++;
        }

        //update the import records
        List<Product_Bundle_Import__c> importRecordSobjUpserts = new List<Product_Bundle_Import__c>();
        for(ImportRecord ir : importRecords.values()) {
            importRecordSobjUpserts.add(ir.productBundleImportSobj);
        }

        ProductBundleImportScript.IsStatusUpdate = true;
        update importRecordSobjUpserts;
        system.debug('ProductBundleImportScript2:import:END');
    }

    global class Bundle {
        public ImportRecord importRecord {get;set;}
        public Product_Bundle__c bundleSobj {get;set;}
        public Map<String,BundleRatePlan> bundleRatePlansByName {get;set;}

        public Bundle(ImportRecord ir) {
            this.bundleRatePlansByName = new Map<String,BundleRatePlan>();
            this.importRecord = ir;
            this.bundleSobj = new Product_Bundle__c(Name = ir.bundleName, Description__c = ir.bundleDescription, Customer_Tier_Level__c = ir.bundleTierLevel, Category__c = ir.bundleCategory, Active__c = true);
        }

        public Bundle(Product_Bundle__c bundleSobj) {
            this.bundleRatePlansByName = new Map<String,BundleRatePlan>();
            this.bundleSobj = bundleSobj;
            for(Product_Bundle_Rate_Plan__c pbrp : bundleSobj.Product_Bundle_Rate_Plans__r) {
                bundleRatePlansByName.put(pbrp.Product_Rate_Plan__r.Name, new BundleRatePlan(pbrp));
            }
        }
    }

    global class BundleRatePlan {
        public ImportRecord importRecord {get;set;}
        public Product_Bundle_Rate_Plan__c pbrpSobj {get;set;}

        public BundleRatePlan(Product_Bundle_Rate_Plan__c pbrpSobj) {
            this.pbrpSobj = pbrpSobj;
        }
    }

    global class ImportRecord {
        public String guid {get;set;}
        public String bundleName {get;set;}
        public String bundleDescription {get;set;}
        public String bundleCategory {get;set;}
        public String bundleTierLevel {get;set;}
        public String ratePlanName {get;set;}
        public String ratePlanTierLevel {get;set;}

        public Product_Bundle_Import__c productBundleImportSobj {get;set;}
        public String message {get;set;}

        public ImportRecord(Product_Bundle_Import__c sobj) {
            this.guid = sobj.Id;
            this.productBundleImportSobj = new Product_Bundle_Import__c(Id = sobj.Id, Bundle_Name__c = sobj.Bundle_Name__c, 
                Bundle_Description__c = sobj.Bundle_Description__c, Customer_Tier_Level__c = sobj.Customer_Tier_Level__c,
                Product_Rate_Plan_Name__c = sobj.Product_Rate_Plan_Name__c, Status__c = sobj.Status__c,
                Product_Rate_Plan_Tier_Level__c = sobj.Product_Rate_Plan_Tier_Level__c, Bundle_Category__c = sobj.Bundle_Category__c);
            this.bundleName = this.productBundleImportSobj.Bundle_Name__c;
            this.bundleDescription = this.productBundleImportSobj.Bundle_Description__c;
            this.bundleTierLevel = this.productBundleImportSobj.Customer_Tier_Level__c;
            this.bundleCategory = this.productBundleImportSobj.Bundle_Category__c;
            this.ratePlanName = this.productBundleImportSobj.Product_Rate_Plan_Name__c;
            this.ratePlanTierLevel = this.productBundleImportSobj.Product_Rate_Plan_Tier_Level__c;
        }
    }
}