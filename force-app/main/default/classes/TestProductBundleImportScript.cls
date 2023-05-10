// ===========================================================================
// Object: TestProductBundleImportScript
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Test coverage for ProductBundleImportScript
// ===========================================================================
// Changes: 2017-02-03 Reid Beckett
//           Class created
// ===========================================================================
@isTest
public class TestProductBundleImportScript 
{

    @isTest
    public static void test_all_sobjects()
    {
        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), 
                         Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999999', ProductCode = 'SKU-999999', IsActive = true)
        };
        insert sfProducts;
        
        zqu__ZProduct__c[] zproducts = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999999',
                zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert zproducts;
        zqu__ProductRatePlan__c prp1 = createProductRatePlan(zproducts[0], 'Test PRP 1',null);
        zqu__ProductRatePlan__c prp2 = createProductRatePlan(zproducts[0], 'Test PRP 2',null);

        Product_Bundle__c pb = new Product_Bundle__c(Name = 'Test Bundle 1', Description__c = 'Test bundle 1 description');
        insert pb;
        
        Product_Bundle_Rate_Plan__c pbrp = new Product_Bundle_Rate_Plan__c(Product_Bundle__c = pb.Id, Product_Rate_Plan__c = prp1.Id);
        insert pbrp;

        String bundleNameTooLong = '';
        for(integer i=0; i<=81; i++) { 
            bundleNameTooLong += String.valueOf(i); 
        }
        List<Product_Bundle_Import__c> importRecords = new List<Product_Bundle_Import__c>{
            //createImportRecordSobject('', '', null),
            createImportRecordSobject('Test Bundle 1', 'Test bundle 1 description', null, null),
            createImportRecordSobject('Test Bundle 2', 'Test bundle 2 description', null, null),
            createImportRecordSobject('Test Bundle 3', 'Test bundle 3 description', 'bad rate plan name', null),
            createImportRecordSobject('Test Bundle 1', 'Test bundle 2 description', prp1.Name, null),
            createImportRecordSobject('Test Bundle 2', 'Test bundle 2 description', prp2.Name, null)
        };

        Test.startTest();
        insert importRecords;
        system.assert(importRecords.size()>0);
        Test.stopTest();

       /*      
        system.assertEquals('Error', s.importRecords[0].status);
        system.assertEquals('Processed', s.importRecords[1].status);
        system.assertEquals(pb.Id, s.importRecords[1].productBundleId);
        system.assertEquals('Processed', s.importRecords[2].status);
        system.assertNotEquals(null, s.importRecords[2].productBundleId);
        system.assertEquals('Error', s.importRecords[3].status);
        system.assertEquals(null, s.importRecords[3].productBundleId);
        system.assertEquals('Processed', s.importRecords[4].status);
        system.assertEquals(pbrp.Id, s.importRecords[4].productBundleRatePlanId);
        system.assertEquals('Processed', s.importRecords[5].status);
        system.assertNotEquals(null, s.importRecords[5].productBundleRatePlanId);
        system.assertEquals('Error', s.importRecords[6].status);
       */ 
    }    
    
    @isTest
    public static void test_all_sobjects_with_tiers()
    {
        Product2[] sfProducts = new Product2[]{
            new Product2(zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), 
                         Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999999', ProductCode = 'SKU-999999', IsActive = true)
        };
        insert sfProducts;
        
        zqu__ZProduct__c[] zproducts = new zqu__ZProduct__c[]{
            new zqu__ZProduct__c(
                zqu__ZuoraId__c = ZuoraTestUtil.generateGUID(), Name = 'Test ZProduct 1', zqu__SKU__c = 'SKU-999999',
                zqu__Product__c = sfProducts[0].Id,
                zqu__EffectiveStartDate__c = Date.today().addYears(-1), zqu__EffectiveEndDate__c = Date.today().addYears(25)
            )
        };
        insert zproducts;
        zqu__ProductRatePlan__c prp1 = createProductRatePlan(zproducts[0], 'Test PRP 1','1');
        zqu__ProductRatePlan__c prp2 = createProductRatePlan(zproducts[0], 'Test PRP 1','2');
        zqu__ProductRatePlan__c prp3 = createProductRatePlan(zproducts[0], 'Test PRP 2',null);

        Product_Bundle__c pb = new Product_Bundle__c(Name = 'Test Bundle 1', Description__c = 'Test bundle 1 description', Customer_Tier_Level__c = '1');
        insert pb;
        
        Product_Bundle__c pb2 = new Product_Bundle__c(Name = 'Test Bundle 2', Description__c = 'Test bundle 1 description', Customer_Tier_Level__c = '2');
        insert pb2;

        List<Product_Bundle_Import__c> importRecords = new List<Product_Bundle_Import__c>{
            createImportRecordSobject('Test Bundle 1', 'Test bundle 1 description', prp1.Name,'1'),
            createImportRecordSobject('Test Bundle 2', 'Test bundle 2 description', prp2.Name,'2'),
            createImportRecordSobject('Test Bundle 3', 'Test bundle 3 description', prp1.Name,'1'),
            createImportRecordSobject('Test Bundle 3', 'Test bundle 3 description', prp1.Name,'1'),
            createImportRecordSobject('Test Bundle 4', 'Test bundle 4 description', prp1.Name,'1'),
            createImportRecordSobject('Test Bundle 4', 'Test bundle 4 description', prp3.Name,'3')
        };

        Test.startTest();
        insert importRecords;
        Test.stopTest();

        Product_Bundle_Import__c[] importResults = [select Status__c, Message__c from Product_Bundle_Import__c];
        system.assertEquals(6, importResults.size());
        Product_Bundle_Import__c b1 = [select Status__c, Message__c from Product_Bundle_Import__c where id = :importRecords[0].id];
        system.assertEquals('Processed', b1.Status__c);
        Product_Bundle_Import__c b2 = [select Status__c, Message__c from Product_Bundle_Import__c where id = :importRecords[1].id];
        system.assertEquals('Processed', b2.Status__c);
        Product_Bundle_Import__c[] b3 = [select Status__c, Message__c from Product_Bundle_Import__c where Bundle_Name__c='Test Bundle 3'];
        system.assertEquals('Processed', b3[0].Status__c);
        system.assertEquals('Error', b3[1].Status__c);
        system.assertEquals('Cannot have two rate plans of the same name in the same bundle', b3[1].Message__c);
        Product_Bundle_Import__c b4 = [select Status__c, Message__c from Product_Bundle_Import__c where Bundle_Name__c='Test Bundle 4' and Product_Rate_Plan_Tier_Level__c='1'];
        system.assertEquals('Processed', b4.Status__c);
        Product_Bundle_Import__c b4e = [select Status__c, Message__c from Product_Bundle_Import__c where Bundle_Name__c='Test Bundle 4' and Product_Rate_Plan_Tier_Level__c='3'];
        system.assertEquals('Error', b4e.Status__c);
        system.assertEquals('Could not find matching rate plan with name \'Test PRP 2\' and tier 3', b4e.Message__c);
    }    
    
    private static Product_Bundle_Import__c createImportRecordSobject(String bundleName, String bundleDescription, String ratePlanName, String ratePlanTierLevel){
        Product_Bundle_Import__c i = new Product_Bundle_Import__c();
        i.Status__c = 'New';
        i.Bundle_Name__c = bundleName;
        i.Bundle_Description__c = bundleDescription;
        i.Product_Rate_Plan_Name__c = ratePlanName;
        i.Product_Rate_Plan_Tier_Level__c = ratePlanTierLevel;
        return i;
    }

    private static zqu__ProductRatePlan__c createProductRatePlan(zqu__ZProduct__c zprod, String productRatePlanName, String customerTierLevel)
    {
        zqu__ProductRatePlan__c prp = ZuoraTestUtil.createProductRatePlan(zprod);
        prp.Name = productRatePlanName;
        prp.CustomerTierLevel__c = customerTierLevel;
        insert prp;
        return prp;
    }
}