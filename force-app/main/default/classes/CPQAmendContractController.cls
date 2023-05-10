/**
* Class Name: CPQAmendContractController
* Created By: Dharmendra Kumar Pandey
* Creation Date: 21-OCT-2022
* 
* Change Log
* Sno				Story#				Description 		Date
* 
* 
* */
public class CPQAmendContractController {
 
    public String recordId {get;set;}
    public boolean amendFailed {get;set;}
    public String amendErrorMsg {get;set;}
    
    public CPQAmendContractController(ApexPages.StandardController stdController) {
        recordId = ApexPages.currentPage().getParameters().get('id');
    } 
    
    public PageReference viewContract(){
        Contract a = [select Id from Contract where Id = : recordId];
        PageReference pr = (new ApexPages.StandardController(a)).view();
        return pr;
    }
    
    public void amendContract(){  
        String qt = existingQuotesRelatedToContract(recordId);
        if(!String.isEmpty(qt)){
            Contract a = [select Id from Contract where Id = : recordId];
            String msg = 'Only 1 amendment per contract can be in progress at the same time. This contract currently has amendment '+qt+' in progress. Please complete quote/order/contracting of amendment '+qt+'.';
            amendErrorMsg = msg;
            amendFailed = true;
        }
    }
    
    // Added to show error message when user tried to create an other amendment if one is already in process
    public string existingQuotesRelatedToContract(Id contractId){
        Map<id,set<string>> quotesRelatedtoContract = new Map<id,set<string>>();
        string quoteName = '';
        set<string>contractids = new set<string>();
        for(SBQQ__Quote__c Qute: [SELECT Id,Name,SBQQ__Status__c ,(select id,SBQQ__Quote__c, SBQQ__Contracted__c from SBQQ__Orders__r where SBQQ__Contracted__c = false ),qtc_Cancelled__c,SBQQ__MasterContract__c,Deliver_To_Site__c, SBQQ__Ordered__c, SBQQ__Type__c, SBQQ__OriginalQuote__c
                                  FROM SBQQ__Quote__c
                                  WHERE  SBQQ__Type__c = 'Amendment' 
                                  AND SBQQ__MasterContract__c = :contractId  AND SBQQ__Status__c!='Expired']){
                                      if(Qute.SBQQ__Orders__r.size() > 0){          
                                          contractids.add(Qute.Name);
                                          
                                          quotesRelatedtoContract.put(Qute.SBQQ__MasterContract__c,contractids);
                                      }
                                      else if(Qute.SBQQ__Orders__r.size() == 0 && Qute.SBQQ__Ordered__c == false){
                                          contractids.add(Qute.Name);
                                          
                                          quotesRelatedtoContract.put(Qute.SBQQ__MasterContract__c,contractids);
                                      }
                                      
                                      
                                  }
        system.debug('-------quotesRelatedtoContract'+quotesRelatedtoContract);
        for(id cnId : quotesRelatedtoContract.keyset()){
            
            if(quotesRelatedtoContract.get(cnId).size() > 0){
                set<string> temp = quotesRelatedtoContract.get(cnId);
                for(string s:temp){
                    quoteName = s;
                    break;
                    
                }
            }
        }
        system.debug('-------quoteName'+quoteName);
        return quoteName;
        
    }
    
}