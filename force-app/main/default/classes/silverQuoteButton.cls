public class silverQuoteButton {
    
    @AuraEnabled
    public static boolean addProduct(string oppId){
        String cpqPriceBookId = System.Label.CPQ_PriceBook_Id;
        String silverProductId = System.Label.Silver_Product_Id;
        Boolean ProductAdded= false;
        String PBEntryId='';
        Decimal UPrice=0;
        List<OpportunityLineItem> opplines = new List<OpportunityLineItem>();
        List<Product2> PrdName= new List<Product2>();
        List<opportunitylineitem> silverProductOppLineItem =[Select id,name,Product2.Name,Product2Id from opportunitylineitem where 
                                   OpportunityId=:oppId and Product2Id=: silverProductId];
        Pricebook2 CPQPriceBook = [SELECT Id FROM Pricebook2 WHERE id=: cpqPriceBookId];
        List<PricebookEntry> entry = [SELECT Id,Name,Pricebook2Id,Product2Id,UnitPrice FROM PricebookEntry 
                                WHERE Product2Id=:silverProductId and Pricebook2Id=:CPQPriceBook.id Limit 1];
        
        for(PricebookEntry pe: entry){
          PBEntryId=pe.Id;
          UPrice=pe.UnitPrice;
        }
        
        if(entry !=null && entry.size() > 0)
            opplines.add(new OpportunityLineItem(PricebookEntryId=PBEntryId, OpportunityId=oppId, UnitPrice=UPrice, Quantity=1));
        
        if(opplines.size() > 0 && silverProductOppLineItem.size() < 1 ){
            //silver flag true   
            Savepoint sp = Database.setSavepoint();
            try {
                opportunity op= new opportunity();
                op.id=oppId;
                op.Silver_Opportunity_flag__c=true;
                if(op !=null)
                    update op;
                
                insert opplines;
                ProductAdded=true;
            } catch(Exception e) { Database.rollback(sp); throw new AuraHandledException(e.getMessage());
            }
        }
        
        return ProductAdded;
    }
    @AuraEnabled
    public static Opportunity redirectToSilver(Id oppId) {
        return [Select contacts__r.Account.Name,contacts__r.CurrencyIsoCode,contacts__r.FirstName,contacts__r.LastName,contacts__r.Phone,contacts__r.Email,
                           contacts__r.Partner_Primary_Contact__c,contacts__r.Active_Contact__c,contacts__r.MailingStreet,contacts__r.MailingCity,contacts__r.MailingState,
                           Contacts__r.MailingPostalCode,Contacts__r.MailingCountry,Owner.Name,Name,Account.Name,CloseDate,CurrencyIsoCode,contacts__r.Name,
                           Account.Master_Customer_Number__c,Account.BillingCity,Account.BillingCountry,Account.BillingPostalCode,Account.BillingState,
                           Account.BillingStreet, Account.BillingLatitude, Account.BillingLongitude,Account.ShippingStreet, Account.ShippingCity, Account.ShippingState,
                           Account.ShippingPostalCode, Account.ShippingCountry,Account.ShippingLatitude, Account.ShippingLongitude, Account.LOB__c, Account.Industry
                from Opportunity where id =:oppId];
     }
}