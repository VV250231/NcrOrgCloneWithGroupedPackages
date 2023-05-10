/****************************************************************************************************************
*   ClassName :   TestUtitlity
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1788     02 Feb 2021     Kapil Bhati          Removed hardcoded Record type id from createOppRecord method
****************************************************************************************************************/
@isTest
public class TestUtitlity {
    
    public static Product2 createAnnuityProduct(){
        Product2 CSProduct = new Product2( Name='Entertainment Product', CurrencyIsoCode='USD', Product_Category__c ='CS', 
                                            Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/ 
                                            isactive=true, Annuity_product__c = true, CanUseQuantitySchedule = true);
        
        insert CSProduct;
        return CSProduct;                                  
    }
    
    public static Product2 createNonAnnuityProduct(){
         Product2 HWProduct = new Product2( Name='Entertainment Product', CurrencyIsoCode='USD', Product_Category__c ='HW', 
                                            Solution_Portfolio__c='Entertainment Self Service',/*Product_Line_Name__c='Other',*/
                                            isactive=true, Annuity_product__c = false, CanUseQuantitySchedule = true);
        
         insert HWProduct ;
         return HWProduct ;                                  
    }
    
    
    public static PricebookEntry createPriceBookEntryRecord(String entProductId){
         PriceBook2 stdPriceBook = [SELECT Id FROM PriceBook2 WHERE IsStandard = true LIMIT 1];
         PricebookEntry EntStandardPricebook = new PricebookEntry(CurrencyIsoCode='USD', Product2Id=entProductId, PriceBook2Id=stdPriceBook.Id, UnitPrice=0.00, UseStandardPrice=false, isactive = true);
         insert EntStandardPricebook;
         return EntStandardPricebook; 
    }
    
    public static OpportunityLineItem createOppLineItem(String oppId, String pbeId){
        OpportunityLineItem Oli = new OpportunityLineItem();
        Oli.OpportunityId = oppId;
        oli.UnitPrice=10;
        oli.Quantity=100;
        oli.PricebookEntryId = pbeId;
        oli.Quantity=100;
        oli.UnitPrice=10;
        
        insert oli;
        return oli;
    }
    
    
    public static Opportunity createOppRecord() {
        
        
     /*   // check if WOT SPOT custom setting is availble, if not create WOT SPOT custom setting record
        WOT_SPOT_Validation__c orderValidation = WOT_SPOT_Validation__c.getValues('WOT_SPOT Required Validation');
        if(orderValidation  == null){
            WOT_SPOT_Validation__c  settingObj = new WOT_SPOT_Validation__c(Name = 'WOT_SPOT Required Validation', Active__c = true);  
            insert settingObj; 
        }*/
          // create new account object
        Account a = new Account (name = 'testing task Deletion of Closed Opp', 
                                 LOB__c='FINANCIAL',
                                 Master_Customer_Number__c = 'TEST000012', 
                                  Account_Country_Code__c = 'US', CurrencyIsoCode = 'USD', 
                                       Active_Account__c = true);
        system.runAs(TestRecordsFactory.getUser()){
        insert a;
    }
        // create new sales org object 
        Sales_Org__c s = new Sales_Org__c (name = 'testing task Deletion of Closed Opp',
                                              Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor object 
        Competitors__c c = new Competitors__c (name = 'testing task Deletion of Closed Opp');
        insert c;
        
        String excludedRecordType = 'Include in Funnel';
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity;
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id recordTypeId = RecordTypeInfo.get(excludedRecordType).getRecordTypeId();
         Id includeInFnnlRtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        // create new Opportunity object 
        Opportunity opp = new Opportunity();   
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'Test Opportunity';
        opp.type = 'Indirect Channel';
        //opp.Solution_Portfolio__c = 'Entertainment Self Service'; - P360 Initial Change - Ahad
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
       // opp.recordTypeId = '012700000001PoZ';
         opp.recordTypeId = includeInFnnlRtId;  //EBA_SF-1788 Removed hardcoded RecordType id - Change done by - Kapil Bhati
        insert opp;
        
        return opp;
    }
    
    /*public static Order_Country__c createOrderCountryRecord(){
        testHack_1();
        Order_Country__c  oc = new Order_Country__c (Country_Code__c = 'US', Country_Name__c = 'United States', 
                                                        Currency_Code__c = 'USD', SPOT_Status__c = true, 
                                                        WOT_Status__c = true, ERP_Status__c =true);
                                                        
        insert oc;
        return oc;
    }*/
    
   
    
    
  
}