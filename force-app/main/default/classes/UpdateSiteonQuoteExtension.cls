public with sharing class  UpdateSiteonQuoteExtension implements schedulable{

        public void execute(schedulableContext sc)
        {
                List<Zqu__Quote__c> QuoteListToUpdate = new List<Zqu__Quote__c>();
                Map<id, Zqu__Quote__c> QuoteMap ;
                QuoteListToUpdate = [select id , Bill_To_Site_Number__c , Ship_To_Site_Number__c , IsSiteNoChanged__c , PendingSiteUpdate__c from Zqu__Quote__c where Bill_To_Site_Number__c LIKE '%Error%' OR Ship_To_Site_Number__c LIKE '%Error%'];
                                                
                for(Zqu__Quote__c Quote : QuoteListToUpdate)
                {
                                        if(Quote.Bill_To_Site_Number__c <> NULL)
                                        {if(Quote.Bill_To_Site_Number__c.contains('Error'))
                                        {                   
                                        Quote.Bill_To_Site_Number__c = Quote.Bill_To_Site_Number__c.remove('Error: No matching records for site# :').remove('Error: Bill-To Flag is false for site# :');
                                        Quote.IsSiteNoChanged__c = true ;
                                        Quote.PendingSiteUpdate__c = true ;
                                        }
                                        }
                                        
                                        if(Quote.Ship_To_Site_Number__c <> NULL)
                                        { 
                                        if(Quote.Ship_To_Site_Number__c.contains('Error'))
                                        {                   
                                        Quote.Ship_To_Site_Number__c = Quote.Ship_To_Site_Number__c.remove('Error: No matching records for site# :').remove('Error: Bill-To Flag is false for site# :');  
                                        Quote.IsSiteNoChanged__c = true ;
                                        Quote.PendingSiteUpdate__c = true ;
                                        }
                                        }                  
                }
                system.debug('>>>'+QuoteListToUpdate);
                update QuoteListToUpdate;
                }   
}