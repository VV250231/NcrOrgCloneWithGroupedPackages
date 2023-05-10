@isTest(SeeAllData=true)
public class silverQuoteButton_Test {
    
    static testmethod void silverQuoteButton(){
        
        Id priceBookID = Test.getStandardPricebookId();
        //Id CPQPriceBookId='01s4u000000mR4JAAU';
        Id CPQPriceBookId=NSCCommonInfoUtil.getIdOf('CPQ_Price_Book_Id');
        
        Opportunity oppObj = TestRecordsFactory.createSimpleOpportunity();
        oppObj.pricebook2Id = CPQPriceBookId ;
        Update oppObj;
        
        Product2 testPrd = new Product2(IsActive=true,Name='Silver Product',Description='Description for test Product');
        insert testPrd;
        
        PricebookEntry pbe = new PricebookEntry(IsActive=true,Pricebook2Id=priceBookID,Product2Id=testPrd.Id,UnitPrice=10.00);  
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry(IsActive=true,Pricebook2Id=CPQPriceBookId,Product2Id=testPrd.Id,UnitPrice=00.00);  
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppObj.Id, PricebookEntryId = pbe2.Id, Quantity = 1, ServiceDate = Date.newInstance(2015, 06, 24),TotalPrice=0);
        insert oli;
        
        boolean b = silverQuoteButton.addProduct(oppObj.Id);
        system.assert(b);
        silverQuoteButton.redirectToSilver(oppObj.Id);
        
    }
}