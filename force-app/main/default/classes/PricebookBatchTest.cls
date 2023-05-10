@isTest
private class PricebookBatchTest {
    
     public static testMethod void runTest(){
         Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
         
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
         
         
         Pricebook2 customPricebook = new Pricebook2(Name = 'Samsung Galaxy PriceBook', isActive = true);
         insert customPricebook;
         System.assertNotEquals(customPricebook.id, null,'customPricebook is Null');  
         
        Product2 prod = new Product2();
        prod.Name = 'Orderman';
        prod.Family = 'Hardware';
        prod.CanUseQuantitySchedule = true;
        prod.Service_Offer_Category__c='HW';
         prod.Product_Type__c ='Topline';
         prod.IsActive = true;
        insert prod;
       
         
        
         
            PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id, Product2Id = prod.Id, UnitPrice = 10000, CurrencyIsoCode = 'USD', IsActive = true);
        insert standardPrice;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPricebook.Id, Product2Id = prod.Id,
            UnitPrice = 12000, IsActive = true, CurrencyIsoCode = 'USD');
        insert customPrice;
        
       
         Test.startTest();
         	Database.executeBatch(new PriceBookBatch(), 1);
         Test.stopTest();
     }

}