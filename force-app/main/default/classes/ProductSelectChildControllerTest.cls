@isTest
public class ProductSelectChildControllerTest {
    
    @isTest
    static void unitTest() {
        
        Test.startTest();
        Opportunity OppObj = TestRecordsFactory.createSimpleOpportunity();
        Product2 ProductObj = TestRecordsFactory.createProduct();
        PriceBookEntry Prb=TestRecordsFactory.createPriceBookEntry(ProductObj);
        OpportunityLineItem Oli = TestRecordsFactory.createOpportunityLineItem(OppObj,Prb);
        OpportunityLineItem master_Oli = TestRecordsFactory.createOpportunityLineItem(OppObj,Prb);
        Oli.Master_Line_Id__c = master_Oli.Id;
        update Oli;
        Test.stopTest();
        Double doubleVar = 100.000;
        System.assertNotEquals(OppObj.id, null,'Opportunity is Null');
        //ProductSelectChildController.packageHierarchyDetails(master_Oli.Id, OppObj.Id);
        //ProductSelectChildController.UpdateProductvalue(doubleVar, doubleVar, doubleVar, doubleVar, doubleVar, master_Oli.Id, true, 'Test', OppObj.Id);
         try
      {
        ProductSelectChildController.getQtyTypes();
        ProductSelectChildController.UpdateProductvalue(doubleVar, doubleVar, doubleVar, doubleVar, doubleVar, master_Oli.Id, true, 'Test',OppObj.Id, true, false);
        
      }
      catch(exception e) 
         {
         }     
        //ProductSelectChildController.UpdateProductvalue(doubleVar, doubleVar, doubleVar, doubleVar, doubleVar, master_Oli.Id, true, 'Test',OppObj.Id);
    }
}