/*
# Last Modified by......:  Dharmendra Kumar Pandey
# Last Modified Date..: 16-NOV-2021
*/
public class CPQMyNcrRequestAsync implements Queueable {
    @TestVisible private static Boolean bypassQuoteTrigger =false;
    private List<Order> orders;
    private Map<id,Order> oldOrdMap;
    
    private List<SBQQ__Quote__c> quotes;
    private Map<id,SBQQ__Quote__c> oldQuoteMap;
    
    public CPQMyNcrRequestAsync(){}
    public CPQMyNcrRequestAsync(List<Order> orders, Map<id,Order> oldOrdMap) {       
        this.orders = orders;
        this.oldOrdMap=oldOrdMap;
    }
    
    public CPQMyNcrRequestAsync(List<SBQQ__Quote__c> quotes, Map<id,SBQQ__Quote__c> oldQuoteMap) {       
        this.quotes = quotes;
        this.oldQuoteMap=oldQuoteMap;
    }
    
    public void execute(QueueableContext context) {
        System.debug('calling requestToMYNCR');
        if(bypassQuoteTrigger) {return;}
        if(this.orders!=null){
        	GenerateLegalDocumentService.requestToMYNCR(this.orders,this.oldOrdMap);
        } else if(this.quotes!=null){
            GenerateLegalDocumentService.requestToMYNCR(this.quotes,this.oldQuoteMap);
        }
    }
}