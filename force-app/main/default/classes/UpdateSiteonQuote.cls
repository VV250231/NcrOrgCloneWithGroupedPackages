public class UpdateSiteonQuote implements schedulable{
    
    public void execute(schedulableContext sc)
    {
        List<Zqu__Quote__c> QuoteListToUpdate = new List<Zqu__Quote__c>();
        //List<Zqu__Quote__c> QuoteListToUpdateForShipToSite = new List<Zqu__Quote__c>();
        Map<id, Zqu__Quote__c> QuoteMap ;
        if(!Test.isRunningTest())
        {
            QuoteMap = new Map<id, Zqu__Quote__c>([select id , name , Zqu__Number__c , Bill_To_Site_Number__c , Ship_To_Site_Number__c , Zqu__InvoiceOwnerId__c , Zqu__ZuoraAccountID__c ,  IsSiteNoChanged__c , zqu__Account__c , PendingSiteUpdate__c from Zqu__Quote__c where IsSiteNoChanged__c = True]);
        }
        else
        {
            QuoteMap = new Map<id, Zqu__Quote__c>([select id , name , Zqu__Number__c , Bill_To_Site_Number__c , Ship_To_Site_Number__c , Zqu__InvoiceOwnerId__c , Zqu__ZuoraAccountID__c , zqu__Account__c  from Zqu__Quote__c where LastModifiedDate = LAST_N_DAYS:10 and name like '%test%' limit 1000]);
        }
        List <Zuora__CustomerAccount__c> BillingAccountList = new List  <Zuora__CustomerAccount__c>();
        List <Zuora__CustomerAccount__c> BillingAccountListToUpdate = new List  <Zuora__CustomerAccount__c>();
        List <Zuora__CustomerAccount__c> BillingAccountSetToUpdate = new List  <Zuora__CustomerAccount__c>();
        List <Customer_Product_Setup__c> ProductDetails = new List  <Customer_Product_Setup__c>();
        Map <String, Zuora__CustomerAccount__c> BillingAccountMap = new Map <String, Zuora__CustomerAccount__c> ();
        List <String> SiteId = new List<String>();
        Set <Id> QuoteIdSet = new Set<Id>();
        
        //QuoteMap = ;
        
        for(Zqu__Quote__c Quote : QuoteMap.values())
        {
            if(Quote.Bill_To_Site_Number__c!=null)
            {                   
                SiteId.add(Quote.Bill_To_Site_Number__c);
                QuoteIdSet.add(Quote.Id);
            }
            
            if(Quote.Ship_To_Site_Number__c!=null)
            {                   
                SiteId.add(Quote.Ship_To_Site_Number__c);  
                QuoteIdSet.add(Quote.Id);                 
            }                   
        }
        
        system.debug('>>>SiteId'+ SiteId );
        system.debug('>>>QuoteIdSet'+ QuoteIdSet );                       
        
        BillingAccountList = [select id , name , Aloha_Key__c , Enterprise_ID__c , ERPSiteNumber__c , Zuora__Account__c , Zuora__External_ID__c , Zuora__Zuora_ID__c , BillToFlag__c from Zuora__CustomerAccount__c where ERPSiteNumber__c in : SiteId AND SourceSystem__c =: 'Oracle ERP'];
        ProductDetails = [select id , name , Related_Quote__c , Add_to_Existing_ENT_ID__c , Software_Key_Number__c from Customer_Product_Setup__c where Related_Quote__c IN: QuoteIdSet];
        system.debug('>>>BillingAccountList after first Query'+ BillingAccountList ); 
        system.debug('>>>ProductDetails after first Query'+ ProductDetails );                 
        
        for(Zuora__CustomerAccount__c BillingAccount : BillingAccountList)
        {
            BillingAccountMap.put(BillingAccount.ERPSiteNumber__c , BillingAccount);
        }
        
        system.debug('>>>BillingAccountMap after conveerting from list to map'+ BillingAccountMap );
        
        for(ID QuoteId : QuoteMap.keySet())
        {
            
            if (QuoteMap.get(QuoteId).Bill_To_Site_Number__c != null)
            {
                
                if(BillingAccountMap.get(QuoteMap.get(QuoteId).Bill_To_Site_Number__c) == null)
                {
                    QuoteMap.get(QuoteId).Bill_To_Site_Number__c = 'Error: No matching records for site# :' + QuoteMap.get(QuoteId).Bill_To_Site_Number__c.remove('Error: No matching records for site# :').remove('Error: Bill-To Flag is false for site# :') ;
                }
                else if(BillingAccountMap.get(QuoteMap.get(QuoteId).Bill_To_Site_Number__c).BillToFlag__c == 'No')
                {
                    QuoteMap.get(QuoteId).Bill_To_Site_Number__c = 'Error: Bill-To Flag is false for site# :' + QuoteMap.get(QuoteId).Bill_To_Site_Number__c.remove('Error: No matching records for site# :').remove('Error: Bill-To Flag is false for site# :') ;
                }
                else if(BillingAccountMap.get(QuoteMap.get(QuoteId).Bill_To_Site_Number__c).BillToFlag__c == 'Yes')
                {
                    QuoteMap.get(QuoteId).Zqu__InvoiceOwnerId__c = BillingAccountMap.get(QuoteMap.get(QuoteId).Bill_To_Site_Number__c).Zuora__External_ID__c ;
                    //QuoteMap.get(QuoteId).zqu__InvoiceOwnerName__c = BillingAccountMap.get(QuoteMap.get(QuoteId).Bill_To_Site_Number__c).name ;
                }
            }
            
            system.debug('>>>QuoteMap after processing and generating error or changing Zqu__InvoiceOwnerId__c for bill to'+ QuoteMap );                                    
            
            if (QuoteMap.get(QuoteId).Ship_To_Site_Number__c != null)
            {
                
                if(BillingAccountMap.get(QuoteMap.get(QuoteId).Ship_To_Site_Number__c) == null)
                {
                    QuoteMap.get(QuoteId).Ship_To_Site_Number__c = 'Error: No matching records for site# :' + QuoteMap.get(QuoteId).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :') ;
                }
                
                /*else if(BillingAccountMap.get(QuoteMap.get(QuoteId).Ship_To_Site_Number__c).BillToFlag__c == 'Yes')
                    {
                    QuoteMap.get(QuoteId).Ship_To_Site_Number__c = 'Error: Bill-To Flag is True for site# :' + QuoteMap.get(QuoteId).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :') ;
                }*/
                else if(BillingAccountMap.get(QuoteMap.get(QuoteId).Ship_To_Site_Number__c).Zuora__External_ID__c != null)
                {
                    QuoteMap.get(QuoteId).Zqu__ZuoraAccountID__c = BillingAccountMap.get(QuoteMap.get(QuoteId).Ship_To_Site_Number__c).Zuora__External_ID__c ;
                    QuoteMap.get(QuoteId).zqu__Account__c = BillingAccountMap.get(QuoteMap.get(QuoteId).Ship_To_Site_Number__c).Zuora__Account__c ;
                }
            }
            
            system.debug('>>>QuoteMap after processing and generating error or changing Zqu__InvoiceOwnerId__c for ship to'+ QuoteMap ); 
            
            QuoteListToUpdate.add(QuoteMap.get(QuoteId));
            
        }
        
        for(Customer_Product_Setup__c ProductDetail : ProductDetails)
        {
            
            //system.debug('ProductDetail.Related_Quote__c'+ProductDetail.Related_Quote__c);
            //system.debug('QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c'+QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c);
            //system.debug('QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove(Error: Bill-To Flag is True for site# :).remove(Error: No matching records for site# :)'+QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :'));
            //system.debug('BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c)'+BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c));
            //system.debug('BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove)'+BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')));
            if (QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c != null &&QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :') != null )
            {
                
                if(BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')) != null)
                {
                    
                    if(ProductDetail.Add_to_Existing_ENT_ID__c != null)
                    {
                        
                        if(BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')).Enterprise_ID__c == null)
                        {
                            BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')).Enterprise_ID__c = ProductDetail.Add_to_Existing_ENT_ID__c;
                            //BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')).Enterprise_ID__c = '99999';
                        }
                    }
                    
                    if(ProductDetail.Software_Key_Number__c != null)
                    {
                        
                        if(BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')).Aloha_Key__c == null)
                        {
                            BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c.remove('Error: Bill-To Flag is True for site# :').remove('Error: No matching records for site# :')).Aloha_Key__c = ProductDetail.Software_Key_Number__c;
                        }
                    }
                    BillingAccountListToUpdate.add(BillingAccountMap.get(QuoteMap.get(ProductDetail.Related_Quote__c).Ship_To_Site_Number__c));
                    BillingAccountSetToUpdate.addAll(BillingAccountListToUpdate);
                }
            }
        }
        
        for (zqu__Quote__c Quote : QuoteListToUpdate)
        {
            
            Quote.IsSiteNoChanged__c = false ;
            Quote.PendingSiteUpdate__c = false ;
        }system.debug('>>>'+QuoteMap);   
        system.debug('>>>'+QuoteListToUpdate);
        update QuoteListToUpdate;
        system.debug('>>>'+BillingAccountMap);
        system.debug('>>>'+BillingAccountMap.values().size());
        system.debug('>>>'+BillingAccountListToUpdate);
        system.debug('>>>'+BillingAccountListToUpdate.size());
        system.debug('>>>'+BillingAccountSetToUpdate);
        system.debug('>>>'+BillingAccountSetToUpdate.size());
        //update BillingAccountListToUpdate;                            
        //update BillingAccountSetToUpdate;                            
        update BillingAccountMap.values();
    }   
}