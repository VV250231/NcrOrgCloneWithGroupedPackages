// ==================================================================================
// Object:  DIProductRelationship
// Company: NCR, Inc.
// Author:  Brick 
// Purpose: Provide a list of validation messages for a given Quote Id based
//          on the Product_Relationship__c custom object. This is done
//          via the "findValidationMessagesForQuote" method. Other methods
//          have been exposed to allow for different types of lookups
//          (eg: getProductsOnQuote, findMissingProducts, findRatePlansForProducts)
// ==================================================================================
// Changes: 2016-04-08 Brick
//           Began integration testing
//         2017-08-09 Brick
//           Removed recursion, per SC2015_AGL-4239
//         2018-01-19 Brick
//           Fixed SC2015_AGL-4512
// ==================================================================================

public with sharing class DIProductRelationship {
    
    
    
    // Given a quote, this will return all of the validation messages that apply. This could include
    // missing products, and products that were included but shouldn't because of a) other products
    // on the same quote or b) products that the customer already has.
    public static Set<string> findValidationMessagesForQuote(string quoteId)
    {
        
        // Find all the related product rules
        List<Product_Relationship__c> missedProducts = findMissingRelationshipsForQuote(quoteId);      
        // Then run them through the ownership violation list and get a full list of messages back
        Set<string> messages = findProductOwnershipViolations(quoteId, missedProducts);  

        return messages;
    }
    
    
    
    // Finds a list of relationship objects for a given quote id. The bulk of the logic here is
    // actually in findMissingRelationships. This just looks up enough quote data to call that 
    // function.
    public static List<Product_Relationship__c> findMissingRelationshipsForQuote(string quoteId)
    {

        // Determine the products ids on the given quote
        Set<id> productIds = getProductsOnQuote(quoteId); 

        // Look up the actual products to pass to findMissingRelationships
        List<zqu__ZProduct__c> included = [select Id, Name from zqu__ZProduct__c where Id in :productIds];

        system.debug('***Finding relationships for the following products on the quote:');
        system.debug(included);
        // Perform the recursive lookup for the relationships
        List<Product_Relationship__c> missed = findMissingRelationships(included, new List<zqu__ZProduct__c>(), new List<Product_Relationship__c>(), 'Include');
        return cleanRelationshipList(included, missed);  
    }
    
    
    
    
    public static List<Product_Relationship__c> findMissingRelationships(List<zqu__ZProduct__c> includedProducts,
                                                                List<zqu__ZProduct__c> requiredProducts, 
                                                                List<Product_Relationship__c> relationshipsMissed,
                                                                string type) 
    { 

        // Base case... but we're no longer recursive anyway
        if (includedProducts.size() == 0) 
        {
            if(relationshipsMissed.size() == 0)
                system.debug('***No products found on the quote. Exiting!');
            return relationshipsMissed;
        }
        
        // Find the required products for the given includedProducts
        List<string> idList = buildIdList(includedProducts);
        
        
        // Find the Relationships (we need the message from those records)
        List<Product_Relationship__c> missed = [select Current_ZProduct__c
                                                    , Related_ZProduct__c
                                                    , Related_Product_SKU__c
                                                    , Message__c
                                                    , Type__c
                                                    , Required__c
                                                from Product_Relationship__c 
                                                where Current_ZProduct__c in :idList 
                                                and ((Related_ZProduct__c not in :idList and Type__c = 'Include') or 
                                                    (Related_ZProduct__c in :idList and Type__c = 'Exclude'))];
                                                //and Type__c = :type];

        system.debug('*** Found these applicable Product Relationships: ');
        system.debug(missed);

        List<string> relatedIdList = new List<string>(); 
        // De-dupe and add any missing products
        if(missed != null && missed.size() > 0) 
        {
            for(Integer i = 0; i < missed.size(); i ++) 
            { 
                system.debug('Checking for dupes for ' + missed[i]);
                for(zqu__ZProduct__c p : requiredProducts) 
                { 
                    if(p.Id == missed[i].Related_ZProduct__c) 
                    {
                        system.debug('\tFOUND DUPE. Removing extra warning: ' + missed[i].Message__c);
                        missed.remove(i); 
                        break;
                    }   
                }
            }
            
            // Add the valid missing products to the list
            relationshipsMissed.addAll(missed);
        }

/* *** REMOVING RECURSION per SC2015_AGL-4239 ***

        // Build a new idList for the next query based on the de-duped list
        for(Product_Relationship__c r : missed) { relatedIdList.add(r.Related_ZProduct__c); }

        // Use this to power the recur call
        List<zqu__ZProduct__c> newRequiredProducts = [select Id, Name, LegacySKU__c
                                                      from zqu__ZProduct__c 
                                                        where id in :relatedIdList];
                                                                      
        system.debug('Found ' + newRequiredProducts.size() + ' required products');
        system.debug('Total relationships missed: ' + relationshipsMissed.size());
        
        // Add the new required products
        requiredProducts.addAll(newRequiredProducts);
        // Recur with the de-duped query results as the new "initial" list
        //return findMissingRelationships(newRequiredProducts, requiredProducts, relationshipsMissed, type); 
*/
        
        return relationshipsMissed; 
    }
    
    
    
    
    // Determine if products are already owned and return a message if they are and the 
    // relationship dictates that only one product should be owned. 
    public static Set<string> findProductOwnershipViolations(string quoteId, List<Product_Relationship__c> missedProducts)
    {
        
        // Our return list
        Set<string> messages = new Set<string>(); 
        
        // Get the Account from the quote
        zqu__Quote__c quote = [Select zqu__Account__c from zqu__Quote__c where Id = :quoteId]; 

        system.debug('***Checking to see if ' + missedProducts.size() + ' missed product are already owned by customer: ' + quote.zqu__Account__c);

        // Get the subscriptions customer already owns via the Account Id
        List<Zuora__Subscription__c> subs = [select Id, Name from Zuora__Subscription__c 
                                                        where Zuora__Account__c = :quote.zqu__Account__c
                                                        and (Zuora__SubscriptionEndDate__c > today or Zuora__SubscriptionEndDate__c = null)];
                                                        

        // Grab just the ids
        Set<Id> subIds = new Set<id>(); 
        for(Zuora__Subscription__c s : subs) { 
            subIds.add(s.Id); 
        }

        // Find the skus for those products *and* charges
        List<Zuora__SubscriptionProductCharge__c> ownedProductSKUs = [select Zuora__ProductSKU_Product__c, Zuora__ProductDescription__c
                                                            from Zuora__SubscriptionProductCharge__c 
                                                            where Zuora__Subscription__c in :subIds];
                                                            // Checked at the Subscription level now, per https://star.ncr.com/browse/SC2015_AGL-4512 
                                                            //and (zuora__chargedthroughdate__c > today or zuora__chargedthroughdate__c = null)]; // (05/18/17) Allow null
        
        system.debug('Listing Products/Charges that the customer already owns:');
        for(Zuora__SubscriptionProductCharge__c sku : ownedProductSKUs) { 
            system.debug('\t' + sku);
        }
        system.debug('DONE'); 
                                                                        
        // If the product doesn't exist on the quote, but it does exist on the customer
        // we'll have an error for it. This error should be removed when the product is required
        // only one time per customer, otherwise we'll say "Hey, add this missing product!" and
        // then we'll follow that up with a "Hey, get rid of this product, the customer already has it!" 
        // and over and over until someone pulls their hair out (or submits a bug).
        List<Product_Relationship__c> removedMessages = new List<Product_Relationship__c>(); 
        Integer initialSize = missedProducts.size();
        for(integer i = 0; i < initialSize; i++) { 
            system.debug('Checking for already-existing SKU: ' + missedProducts[i].Related_Product_SKU__c);
            for(Zuora__SubscriptionProductCharge__c owned : ownedProductSKUs) { 
                if(missedProducts[i].Related_Product_SKU__c == owned.Zuora__ProductSKU_Product__c && missedProducts[i].Required__c == 'Only One') { 
                    removedMessages.add(missedProducts[i]); // Just collect them now, remove them later.
                    continue;
                }
            }
        }

        // Now remove all the invalid products based on Id lookups
        for(Product_Relationship__c removedRel : removedMessages)
        {
            for(integer i = 0; i < missedProducts.size(); i++)
            {
                if(removedRel.Id == missedProducts[i].Id)
                {
                    missedProducts.remove(i); 
                }
            }
        }

        if (removedMessages.size() > 0) system.debug('Removed messages for already-owned products: ' + removedMessages);
        
        // If we remove a related product we want to make sure that any primary 
        // mentions are removed too. Otherwise you get "A quote with [Product 2] requires
        // [Product 3]..." even though Product 2 isn't on the quote *and* isn't listed 
        // as a required product in the warning messages. This is mainly because we're
        // trying to be fancy and display all of the missed products in the validation, 
        // not just the validations that are one level down. It's also because we're working
        // with bad data at this phase. With luck we'll never actually have to go through this block. 
        List<Product_Relationship__c> removedMessages2 = new List<Product_Relationship__c>(); 
        for(Product_Relationship__c removed : removedMessages) { 
            for(integer i = 0; i < missedProducts.size(); i++) { 
                if(removed.Related_ZProduct__c == missedProducts[i].Current_ZProduct__c) { 
                    removedMessages2.add(missedProducts[i]); 
                    missedProducts.Remove(i); 
                    continue;
                }
            }
        }

        if (removedMessages2.size() > 0) system.debug('Removed messages that no longer have a product on the quote: ' + removedMessages);
        

        // Determine which products are selected on the current Quote
        Set<id> quoteProductIds = getProductsOnQuote(quoteId);
        
                                                                        
        // Find which products on the quote should be on the account "Only One" time
        List<Product_Relationship__c> relationships = [select Current_ZProduct__c, Related_ZProduct__c, Message__c, Related_Product_SKU__c
                                                        from Product_Relationship__c 
                                                        where Related_ZProduct__c in :quoteProductIds
                                                        and Required__c = 'Only One'];
                                                        
        // Loop through and determine if those products exist on the Account and add a message if they do
        for(Product_Relationship__c newAddition : relationships) { 
            for(Zuora__SubscriptionProductCharge__c existingProduct : ownedProductSKUs) { 
                if (newAddition.Related_Product_SKU__c == existingProduct.Zuora__ProductSKU_Product__c) { 
                    messages.Add('Product [' + existingProduct.Zuora__ProductDescription__c + '] should not be included on the Quote since the customer ' + 
                                 'already purchased it at an earlier time.');
                }
            }
        }
        
        // Add the messages for the missed products, too
        for(Product_Relationship__c missed : missedProducts) { 
            messages.Add(missed.Message__c); 
        }
                                                        
        return messages;

    }
    
    
    
    // DEPRECATED -- Use findMissingRelationships instead. This will work, but only products will be returned, not messages.
    // includedProducts -- The list of products that exist on the quote
    public static List<zqu__ZProduct__c> findMissingProducts(List<zqu__ZProduct__c> includedProducts)
    {
        List<zqu__ZProduct__c> totalMissing = findMissingProducts(includedProducts, new List<zqu__ZProduct__c>(), 'Include'); 
        return cleanProductList(includedProducts, totalMissing); 
    }
    
    
    
    
    // DEPRECATED -- Use findMissingRelationships instead. This will work, but only products will be returned, not messages.
    // includedProducts -- The list of products to find relationships for
    // requiredProducts -- The additional products required by products in the includedProducts list
    private static List<zqu__ZProduct__c> findMissingProducts(List<zqu__ZProduct__c> includedProducts,
                                                                List<zqu__ZProduct__c> requiredProducts, 
                                                                string type) 
    { 
        if (includedProducts.size() == 0) // Base Case, or case where infinite loop was prevented an no products are left
        {
            return requiredProducts;
        }

        // Find the required products for the given includedProducts
        List<string> idList = buildIdList(includedProducts);

        List<zqu__ZProduct__c> newRequiredProducts = [select Id
                                                        , Name
                                                        //, LegacySKU__c
                                                      from zqu__ZProduct__c 
                                                        where id in (select Related_ZProduct__c
                                                                      from Product_Relationship__c 
                                                                      where Current_ZProduct__c in :idList
                                                                      and Type__c = :type)];

        // See if any of the new products exists in the list already and remove them if they does 
        for(Integer i = 0; i < newRequiredProducts.size(); i++) 
        { 
            system.debug('Looking for dupes for ' + newRequiredProducts[i].Name);
            for(zqu__ZProduct__c p : requiredProducts) 
            { 
                if (p.Id == newRequiredProducts[i].Id) 
                {
                    system.debug('\tFOUND DUPE: ' + p.name + ' removing at index ' + i); 
                    newRequiredProducts.remove(i);
                    break;
                }
            }
        }

        system.debug('Found ' + newRequiredProducts.size() + ' required products ' + newRequiredProducts);

        // Add the new required products
        requiredProducts.addAll(newRequiredProducts);
        
        // Recur with the de-duped query results as the new "initial" list
        return findMissingProducts(newRequiredProducts, requiredProducts, type); 
    }
    
    
    
       /********************** UTILITY METHODS ***************************/ 
    
    
    
    
    // This will return all rate plans associated with the products, for better or for worse
    public static List<zqu__ProductRatePlan__c> findRatePlansForProducts(List<zqu__ZProduct__c> products)
    {       
        Set<string> productIds = new Set<string>(); 
        for(zqu__ZProduct__c product : products) {
            productIds.add(product.Id); 
        }

        List<zqu__ProductRatePlan__c> plans = [select Id, Name, zqu__ZuoraId__c 
                                                from zqu__ProductRatePlan__c
                                                where zqu__Product__c in :productIds];

        return plans; 
    }

    
    
    
    public static List<string> buildIdList(List<zqu__ZProduct__c> products) { 
        List<string> ids = new List<string>(); 
        for (zqu__ZProduct__c product : products) { 
            ids.add(product.id); 
        }
        return ids; 
    }
    
    
    
    
    // If a circular dependency occurs, it's possible a product in the very first list could be added to the dependencies. 
    // To avoid this we perform this cleaning step at the very end so that no items in the initial list show up in the returned dependencies.
    public static List<zqu__ZProduct__c> cleanProductList(List<zqu__ZProduct__c> initialList, List<zqu__ZProduct__c> dependencies)
    {
        // Let's make sure we're not calling a product already on the quote a "missed" product because of a circular dependcy
        for(Integer i = 0; i < dependencies.size(); i++) { 
            for(zqu__ZProduct__c p : initialList) { 
                if (dependencies[i].Id == p.Id) { 
                    dependencies.remove(i); 
                    break;
                }
            }
        }
        return dependencies; 
    }
    
    
    
    
    // Same as above -- handle the removal of circular dependencies and invalid exclusion messages
    public static List<Product_Relationship__c> cleanRelationshipList(List<zqu__ZProduct__c> initialList, List<Product_Relationship__c> dependencies)
    {
        for(integer i = 0; i < dependencies.size(); i++){
            if(dependencies[i].Type__c == 'Exclude' && removeExclusion(dependencies[i], initialList))
            {
                // Remove Exclusion messages that do not apply because the
                // Related_Product_Id doesn't exist on the current quote
                system.debug('Removing invalid exclusion message: ' + dependencies[i].Message__c);
                dependencies.remove(i); 
                continue;
            }
        }

        for(Integer i = 0; i < dependencies.size(); i++) { 
            for(zqu__ZProduct__c p : initialList) { 
                if (dependencies[i].Related_ZProduct__c == p.Id && dependencies[i].Type__c != 'Exclude') { 
                    system.debug('Removing circular dependency: ' + dependencies[i]);
                    dependencies.remove(i); 
                    break; 
                }
            }
        }
        return dependencies;
    }




    // For exclusion messages we need to check the existing product list to see if the Current Product and 
    // the Related Product are both on the quote. Exclusions are only valid in this case. 
    public static boolean removeExclusion(Product_Relationship__c rule, List<zqu__ZProduct__c> quote_products) { 
        boolean remove = true; 
        for(zqu__ZProduct__c quote_product : quote_products) { 
            if(quote_product.Id == rule.Related_ZProduct__c) { 
                remove = false; // If we have a match in the existing list, the exclusion warning should not be removed
            }
        }
        return remove; 
    }
    
    
    
    
    // Uses a Zuora class to determine products on a given quote
    /* DEPRECATED -- We want to look at Quote_Product__c because it has the Amendment_Type__c field that
                        allows us to only look at *Added* products. 
    public static Set<id> getProductsOnQuote(string quoteId)
    {
        zqu.zChargeGroup[] chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
        
        Set<id> productIds = new Set<id>(); 
        for(zqu.zChargeGroup charge : chargeGroups) { 
            zqu__ProductRatePlan__c prp = [select Id, zqu__ZProduct__c from zqu__ProductRatePlan__c 
                                            where zqu__ZuoraId__c = :charge.productRatePlanZuoraID];
            productIds.add(prp.zqu__ZProduct__c);
        }
        
        return productIds;
    }
    */
    
    public static Set<id> getProductsOnQuote(string quoteId)
    {
        //RecordType renewalType = [Select Id, IsActive from RecordType where Name = 'New Renewal' and IsActive = true and SobjectType = 'zqu__Quote__c' limit 1];

        List<Quote_Product__c> products = [select ZProduct__c from Quote_Product__c where Quote__c = :quoteId 
                                                and (Action__c = 'Activate'/*'Add' or Action__c = 'Renew Add'*/)];
                                                //and Quote__r.RecordTypeId != :renewalType.Id];
        Set<id> productIds = new Set<id>(); 
        for(Quote_Product__c product : products) { 
            productIds.add(product.ZProduct__c);
        }
        
        return productIds;
    }
    
    
    
    // Utility method that pulls all Message__c values from a Product_Relationship object
    public static List<string> findMessagesForRelationships(List<Product_Relationship__c> relationships)
    {
        List<string> messages = new List<string>(); 
        for(Product_Relationship__c rel : relationships) {
            messages.add(rel.message__c); 
        }
        return messages;
    }
}