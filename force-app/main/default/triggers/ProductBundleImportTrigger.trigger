// ===========================================================================
// Object: ProductBundleImportTrigger
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Trigger to create product bundle records by reading from new custom
// object, Product_Bundle_Import__c, and upserting Product_Bundle__c and
// Product_Bundle_Rate_Plan__c records
// ===========================================================================
// Changes: 2017-02-28 Reid Beckett
//           Class created
// ===========================================================================
trigger ProductBundleImportTrigger on Product_Bundle_Import__c (after insert, after update) 
{
    if(Trigger.isAfter && !ProductBundleImportScript.IsStatusUpdate)
    {
        System.enqueueJob(new ProductBundleImportScript.ProductBundleImportQueueable(Trigger.new));
    }
}