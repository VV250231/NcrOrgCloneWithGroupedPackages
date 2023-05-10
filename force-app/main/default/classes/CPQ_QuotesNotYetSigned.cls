public class CPQ_QuotesNotYetSigned {
    @AuraEnabled 
    public static SBQQ__Quote__c getQuote(String quoteId){
        SBQQ__Quote__c quote = [Select id,Name,qtc_Multi_Site__c,qtc_Multi_Site_Relationship__c, SBQQ__OriginalQuote__c
                                From SBQQ__Quote__c 
                                where id =:quoteId];
        
        return quote;
			
    }
        
    
	@AuraEnabled 
     public static String getNotSignedQuotes(String quoteId){
         System.debug(quoteId);
        SBQQ__Quote__c multisiteParent = [Select SBQQ__OriginalQuote__c  
                                          From SBQQ__Quote__c 
                                          Where id =: quoteId  ];
        List<SBQQ__Quote__c> originalQuoteChildren = [Select id,Name,qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.Site_Number__c, qtc_Bill_To_Site__r.Name, qtc_Multi_Site_Relationship__c, qtc_Bill_To_Site__r.AutoPay_Setup__c 
                                      				   From SBQQ__Quote__c
                                                       Where  qtc_Multi_Site_Parent_Quote__c =: multisiteParent.SBQQ__OriginalQuote__c 
                                                     AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed' AND qtc_Cancelled__c=false]; 
         
        List<SBQQ__Quote__c> qtobj = [Select id,Name,qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.Site_Number__c, qtc_Bill_To_Site__r.Name, qtc_Multi_Site_Relationship__c, qtc_Bill_To_Site__r.AutoPay_Setup__c 
                                      From SBQQ__Quote__c
                                      Where  ((id=:quoteId AND qtc_Multi_Site__c = true AND qtc_Multi_Site_Type__c= 'AE Only' AND qtc_Multi_Site_Relationship__c = 'Parent') 
                                              OR qtc_Multi_Site_Parent_Quote__c = :quoteId) AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed' AND qtc_Cancelled__c=false];
        
         qtobj.addALL(originalQuoteChildren);
         String  response = JSON.serialize(qtobj);
        return response;
    }
    
    @AuraEnabled 
    public static  Map<String,String> getQuotesWithCLMDoc(SBQQ__Quote__c quote){   
        Map<String,String> quotesWithCLMDoc = new Map<String,String>();
        if(!quote.qtc_Multi_Site__c || quote.qtc_Multi_Site_Relationship__c == 'Child'){
            SBQQ__Quote__c q = [Select Name,(Select Id, Document_Status__c From Customer_Documents__r 
                                             Where Document_Type__c = 'AE Amendment' order by LastModifiedDate desc limit 1 )
                                From SBQQ__Quote__c where id =: quote.Id];
            if(q.Customer_Documents__r.size() > 0){
                quotesWithCLMDoc.put(q.Name,q.Customer_Documents__r[0].Document_Status__c);
            }
            
        }else{
            // SBQQ__Quote__c multisiteParent = [Select SBQQ__OriginalQuote__c  
                                     //     From SBQQ__Quote__c 
                                       //   Where id =: quote.Id  ];
           //Adding amended quote's children in map 
            for(SBQQ__Quote__c q : [Select name,(Select id, Document_Status__c From Customer_Documents__r 
                                                 Where Document_Type__c = 'AE Amendment'OR 
                                                 Document_Type__c = 'AE Order Form' order by LastModifiedDate desc limit 1 ) 
                                    From SBQQ__Quote__c 
                                    Where ((id =:quote.Id and qtc_Multi_Site__c = true AND qtc_Multi_Site_Type__c= 'AE Only' 
                                    AND qtc_Multi_Site_Relationship__c = 'Parent') OR qtc_Multi_Site_Parent_Quote__c = :quote.Id 
                                           OR qtc_Multi_Site_Parent_Quote__c =: quote.SBQQ__OriginalQuote__c)
                                    AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed'
                                    AND qtc_Cancelled__c=false]){
                                            if(q.Customer_Documents__r.size() > 0){
                                                quotesWithCLMDoc.put(q.Name,q.Customer_Documents__r[0].Document_Status__c);
                                            }
                                        }
            //Adding original quote's children in map 
    /*        for(SBQQ__Quote__c q : [Select name,(Select id, Document_Status__c From Customer_Documents__r 
                                                 Where Document_Type__c = 'AE Order Form' order by LastModifiedDate desc limit 1 ) 
                                    From SBQQ__Quote__c 
                                    Where  qtc_Multi_Site_Parent_Quote__c =: quote.SBQQ__OriginalQuote__c
                                    AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed'
                                    AND qtc_Cancelled__c=false]){
                                            if(q.Customer_Documents__r.size() > 0){
                                                quotesWithCLMDoc.put(q.Name,q.Customer_Documents__r[0].Document_Status__c);
                                            }
                                        }
*/            
        } 
        return quotesWithCLMDoc;
    }
}