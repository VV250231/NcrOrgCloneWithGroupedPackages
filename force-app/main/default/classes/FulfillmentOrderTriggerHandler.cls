/****************************************************************************************************************
*   ClassName :   FulfillmentOrderTriggerHandler
*   Description :   
*   Author      :   DP250110
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
****************************************************************************************************************/

public class FulfillmentOrderTriggerHandler {
    
    public FulfillmentOrderTriggerHandler(){}
    
    public void afterUpdateInsertFO(List<qtc_FulfillmentOrder__c> listFO,Map<Id,qtc_FulfillmentOrder__c> foMapOld,Boolean isUpdate){
        
        List<String> qIds=new List<String>();
        Set<ID> ids =new Set<ID>();
        Map<Id,ID> mp =new Map<ID,ID>();
        Set<ID> q2ids =new Set<ID>();
        
        for(qtc_FulfillmentOrder__c qf : listFO){
            q2ids.add(qf.qtc_Quote__c);
        }
        Map<ID, SBQQ__Quote__c> qMap = new Map<ID, SBQQ__Quote__c>([SELECT Id, Name,qtc_Multi_Site__c,SBQQ__Status__c FROM SBQQ__Quote__c where  Id IN : q2ids]);
        
        for(qtc_FulfillmentOrder__c qf : listFO){
            if (qf.qtc_Quote__c != null) {
                SBQQ__Quote__c q = qMap.get(qf.qtc_Quote__c);
                if(q.qtc_Multi_Site__c == false && q.SBQQ__Status__c!='Expired'){
                    ids.add(qf.qtc_Quote__c);
                    mp.put(qf.qtc_Quote__c,qf.Id);
                }
            }
        }
        
        List<NCR_Payments_Site__c> npsToUpdate = new List<NCR_Payments_Site__c>();
        List<NCR_Payments_Site__c> nps= [Select id,Quote__c,qtc_Fulfillment_Order__c from NCR_Payments_Site__c where Quote__c IN : ids ];
        System.debug('nps size'+nps.size());
        for(NCR_Payments_Site__c ps : nps) {
            if(mp.containsKey(ps.Quote__c)){
                if((ps.qtc_Fulfillment_Order__c==null) || (ps.qtc_Fulfillment_Order__c!=mp.get(ps.Quote__c))){
                	ps.qtc_Fulfillment_Order__c=mp.get(ps.Quote__c);
                	npsToUpdate.add(ps);
                }
            }
        }
        if(!npsToUpdate.isEmpty()) {
            update npsToUpdate;
        }
        
        if(isUpdate){
            for(qtc_FulfillmentOrder__c qf : listFO){
                if(qf.Order_Interface_Status__c!= foMapOld.get(qf.id).Order_Interface_Status__c&&qf.Order_Interface_Status__c=='Order Booked'){
                    qIds.add(qf.qtc_Quote__c);
                }
            }
            if (!qIds.isEmpty()) {
                List<SBQQ__Quote__c> qLst = [Select id,SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                                             qtc_Requested_Delivery_Date__c,SBQQ__Account__c from SBQQ__Quote__c where id in :qIds /*and qtc_Order_Authorization_Accepted_Date__c!=null*/ and (qtc_EligibleForERP__c ='True' OR qtc_EligibleForERP__c ='True Manual')];
                if(!System.isFuture() && !System.isBatch() && !qLst.isEmpty()) {
                    System.enqueueJob(new cpq_QteToOppSync(qLst, 'FO'));   
                }        
            }   
        }
    }
}