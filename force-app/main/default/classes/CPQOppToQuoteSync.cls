/*********************
* Story No#         Date            DevName                Description
* SFCPQBLG-1173 	09-AUG-2022		 DP250110				AASe: Systematic Opportunity Closed/Lost Logic
* 
* ****************************/
public class CPQOppToQuoteSync implements Queueable {
    
    private List<Opportunity> newCPQOppList;
    private Map<Id,Opportunity> oldMapOpp;
    
    public CPQOppToQuoteSync(){}
    
    public CPQOppToQuoteSync(List<Opportunity> newCPQOppList,Map<Id,Opportunity> oldMapOpp){
        this.newCPQOppList = newCPQOppList;
        this.oldMapOpp = oldMapOpp;
    }
    
    public void execute(QueueableContext context) {
        //Todo: Update Opp close flag to autocloselost false
        List<Id> optClsLst = new List<Id>();
        
        for(Opportunity opt : newCPQOppList){
            if(opt.CPQ__c && opt.StageName=='Closed/Lost' && oldMapOpp.get(opt.Id).StageName!='Closed/Lost' && !opt.qtc_auto_closedlost__c){
                optClsLst.add(opt.id);
            }
        }
        if(optClsLst.size()>0){
            expireQuotes(optClsLst);
        }
    }
    
    public void expireQuotes(List<Id> optLst) {
        List<SBQQ__Quote__c> qList = [SELECT Id, Name, ApprovalStatus__c, CreatedDate,SBQQ__ExpirationDate__c, qtc_Legal_Document_Status__c,
                                      qtc_Multi_Site__c, qtc_Multi_Site_Relationship__c, qtc_Multi_Site_Type__c,SBQQ__Opportunity2__c,
                                      SBQQ__Ordered__c,SBQQ__Primary__c,qtc_Payments_Only_Quote__c,SBQQ__Status__c, qtc_Status_of_all_Applications__c,
                                      SBQQ__Type__c,SBQQ__Opportunity2__r.CPQ__c,SBQQ__Opportunity2__r.StageName 
                                      FROM SBQQ__Quote__c WHERE SBQQ__Status__c != 'Expired'
                                      AND SBQQ__Ordered__c = false 
                                      AND (NOT qtc_Legal_Document_Status__c LIKE 'Completed%') 
                                      AND (qtc_Status_of_all_Applications__c != 'ApprovedAndBoarded') 
                                      AND SBQQ__Opportunity2__r.Id in :optLst];
        List<id> qIds = new List<Id>();
        if(!qList.isEmpty() && qList.size() > 0){
            for(SBQQ__Quote__c qt:qList){
                qt.SBQQ__Status__c='Expired';
                qIds.add(qt.id);
            }
            try {
                SBQQ.TriggerControl.disable(); 
                update qList;
                List<qtc_FulfillmentOrder__c> qFOs = [SELECT Id, Name, Order_Interface_Status__c, qtc_Quote__c,qtc_Quote_Name__c, qtc_Quote_Number__c, qtc_Quote__r.Id
                                                      FROM qtc_FulfillmentOrder__c where qtc_Quote__r.Id IN :qIds];
                for(qtc_FulfillmentOrder__c qFO:qFOs){
                    qFO.Order_Interface_Status__c = 'Quote Expired';
                }
                if(qFOs.size()>0){
                    update qFOs;
                }
            } catch(Exception e) { 
                // make entery in error log
                System.debug('Exception Occured in expireQuotes-Quote Expiring :'+e.getMessage()+'<Br/>'+e.getStackTraceString());
            } finally {
                SBQQ.TriggerControl.enable();
            }
        }
    } 

}