/*
*********************************************************
Apex Class Name    : SyncOli
Created Date       : 
@description       : This class is used to sync only updated opportunity line items and schedule data in 
					 Opportunity Product and Product Schedule custom objects using queueable call
@author            : IDC, NSC
Modification Log:
Ver   Date         Author                    Modification
1.1   04-08-2021   Puneet Bhatia             Last Version
1.1   11-13-2021   Puneet Bhatia             Added OLI constructor and syncLineItems method to call from batch and corrected required field missing error
*********************************************************
*/
public class SyncOli implements Queueable{
    
    private Set<Id> opps, oppsRetry;
    
    public SyncOli() {}
    public SyncOli(Set<Id> records) {
        this.opps = records;
    }
    
    public SyncOli(List<OpportunityLineItem> oliLst) {
        this.opps = new Set<Id>();        
        for(OpportunityLineItem oli : oliLst) {
        	this.opps.add(oli.OpportunityId);    
        }
    }
    
    public void execute(QueueableContext context) {
        syncLineItems(null, null);    
    }

    public void syncLineItems(List<String> rtrnErrMsgLst, Set<Id> rtrnOppsRetry) {
        try{
            Datetime ignoreDate = datetime.newInstanceGMT(3000, 01, 01);
            oppsRetry=new Set<id>();
            Map <id,id> oliProdmap = new Map<id,id>();
            List <String> errorMsgList=new List <string>();
            List<OpportunityLineItemSchedule> schIdLst = new List<OpportunityLineItemSchedule>();
            List <OpportunityLineItem> oliList=[Select id, name, OpportunityId, CurrencyIsoCode, Topline_Product_Lkp__c, Topline_Product_Lkp__r.Name, TotalPrice, UnitPrice, Quantity, Unscheduled_Quantity__c, (select id, OpportunityLineItemId, ScheduleDate, Quantity, type from OpportunityLineItemSchedules) from OpportunityLineItem where OpportunityId in :opps and Topline_Product_Lkp__c != null];
            Map<Id, OpportunityLineItem> oliMap = new Map<Id, OpportunityLineItem>(oliList);
            // get list of all Opportunity products to delete
            List<Opportunity_Products__c> deleteOppPrds=[Select id, Opportunity__c, Product__c, Product__r.Name from Opportunity_Products__c where Opportunity__c in :opps];
            
            
            if(deleteOppPrds.size()>0){
                //Delete deleteOppPrds;
                Database.deleteResult[] drLst = Database.delete(deleteOppPrds,false); 
                
                integer j=0;
                for (Database.deleteResult dr : drLst) {
                    if (!dr.isSuccess()) {  
                        
                        for(Database.Error err : dr.getErrors()) {
                            if(err.getStatusCode()==System.StatusCode.UNABLE_TO_LOCK_ROW){                                
                                oppsRetry.add(deleteOppPrds[j].Opportunity__c);//Re-process request
                            }else if((!String.valueOf(err.getStatusCode()).toUpperCase().Contains('ENTITY_IS_DELETED')) 
                                     	&& (!err.getMessage().toUpperCase().Contains('ENTITY_IS_DELETED'))){                                
                                errorMsgList.add('Revenue Forecast Sync Failed for Opportunity: |'+deleteOppPrds[j].Opportunity__c + '| Product: '+deleteOppPrds[j].Product__r.Name +' Error: '+err.getStatusCode() + ': ' + err.getMessage());
                               
                            }
                        }
                    }
                    j++;
                } 
            }            
            List <Opportunity_Products__c> insertOppPrds=new List<Opportunity_Products__c>();
            List <Product_Schedules__c> prdSchdls=new List<Product_Schedules__c>();
            
            for(OpportunityLineItem oli: oliList){
                // create Opportunity products
                Opportunity_Products__c o=new Opportunity_Products__c();
                o.Name=oli.Topline_Product_Lkp__r.Name.left(79);
                o.ProductName__c= oli.Topline_Product_Lkp__r.Name;
                o.Product__c=oli.Topline_Product_Lkp__c;
                o.Opportunity_LineId__c = oli.Id;
                o.Opportunity__c=oli.OpportunityId;
                if(oli.Quantity==null){
                    o.Quantity__c=0;                    
                }else{
                    o.Quantity__c=oli.Quantity;                    
                }
                o.Total_Price__c=oli.TotalPrice;
                if(oli.UnitPrice==null){
                    o.Unit_Price__c=0;
                    
                }else{
                    o.Unit_Price__c=oli.UnitPrice;                    
                }
                o.Unscheduled_Quantity__c=oli.Unscheduled_Quantity__c;
                o.CurrencyIsoCode=oli.CurrencyIsoCode;                
                insertOppPrds.add(o);           
                
            }
            // insert Opportunity products
            if(insertOppPrds.size()>0){
                Database.SaveResult[] srList = Database.insert(insertOppPrds, false);
                integer j=0;
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        oliProdmap.put(oliList.get(j).Id, sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            if(err.getStatusCode()==System.StatusCode.UNABLE_TO_LOCK_ROW){
                                //Re-process request
                                oppsRetry.add(oliList[j].OpportunityId) ;
                            }else{                                
                                errorMsgList.add('Revenue Forecast Sync Failed for Opportunity: |'+oliList[j].OpportunityId + '| Product: '+oliList[j].Topline_Product_Lkp__r.Name +' Error: '+err.getStatusCode() + ': ' + err.getMessage());
                            }
                        }
                    }
                    j++;
                }   
            }
            
            // Schedule Calculation
            for(OpportunityLineItem oli: oliList){
                
                if(oliProdmap.get(oli.Id) !=  NULL) {                    
                    for(OpportunityLineItemSchedule olis:oli.OpportunityLineItemschedules){
                        // create schedules and assign id                
                        if(ignoreDate>olis.ScheduleDate && olis.Type=='Quantity' && olis.Quantity>0){
                            schIdLst.add(olis);
                            Product_Schedules__c ps=new Product_Schedules__c();
                            ps.Name=(olis.ScheduleDate+'-'+oli.Topline_Product_Lkp__r.Name).left(79);
                            ps.Product__c=oliProdmap.get(oli.Id);
                            ps.Schedule_Date__c=olis.ScheduleDate;
                            ps.Schedule_Quantity__c=olis.Quantity;
                            ps.Schedule_Amount__c=olis.Quantity*oli.UnitPrice;
                            ps.CurrencyIsoCode=oli.CurrencyIsoCode;
                            system.debug('$$$'+oli.id);
                            prdSchdls.add(ps);                            
                        }
                        
                    }
                }
            }
            if(insertOppPrds.size()>0){
                // insert schedules
                Database.SaveResult[] srListS = Database.insert(prdSchdls, false);
                integer j=0;
                
                for (Database.SaveResult sr : srListS) {
                    
                    if (!sr.isSuccess()){
                        //OpportunityLineItemSchedule schId = schIdLst[j]
                        OpportunityLineItem oli  =  oliMap.get(schIdLst[j].OpportunityLineItemId);
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            if(err.getStatusCode()==System.StatusCode.UNABLE_TO_LOCK_ROW){
                                //Re-process request
                                oppsRetry.add(oli.OpportunityId) ;   
                                
                            }else{                                
                                errorMsgList.add('Revenue Forecast Sync Failed for Opportunity : |'+oli.OpportunityId + '| Product: '+oli.Topline_Product_Lkp__r.Name +' Error: '+err.getStatusCode() + ': ' + err.getMessage());
                                
                            }
                        }
                    }
                    j++;
                }
                
            }
            
            if(Test.isRunningTest()) { errorMsgList.add('testing error'); }
            
            if(errorMsgList.size()>0){
                if(System.isQueueable()) {
               		sendEmail(errorMsgList, 'Please retrigger or resolve issue for each individual Records below:');    
                } else if(rtrnErrMsgLst != null) {
                	rtrnErrMsgLst.addAll(errorMsgList); 
                } 
            }
            if(oppsRetry.size()>0){
                if(System.isQueueable()) {
                	System.enqueueJob(new SyncOli(oppsRetry));
                } else if(rtrnOppsRetry != null) {
                	rtrnOppsRetry.addAll(oppsRetry);   
                }
            }
            
            if(Test.isRunningTest()) { throw new CustomException('testing exception');} 
            
        }
        catch(Exception e){
            //comment for test
            if(!e.getMessage().toUpperCase().Contains('ENTITY_IS_DELETED')){
                List <String> oppList=new List <string>();
                for(id i:opps){
                    oppList.add(i) ;
                    if(rtrnErrMsgLst != null) rtrnErrMsgLst.add('Revenue Forecast Sync Failed for Opportunity :'+i  +' due to Error: ' + e.getMessage()); 
                }
                
                if(rtrnOppsRetry != null && !rtrnOppsRetry.isEmpty()) {
                    rtrnOppsRetry.clear();
                }
                if(System.isQueueable()) {
                	sendEmail(oppList,'Exception Occured is:'+e.getMessage()+'<Br/>'+e.getStackTraceString());
                } 
           }

        }
        
    }
    
    public void sendEmail(List<String> bdy, string ex) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        message.toAddresses = new String[] {'ad250024@ncr.com', 'NI230017@ncr.com','pb185126@ncr.com'};
            //message.toAddresses = new String[] { 'ad250024@ncr.com', 'sk250842@ncr.com','at250303@ncr.com'};
            message.subject =  'Sync Rvenue Forecasting OLI Issue';
        String err='';
        for(String s:bdy){
            err=err+'<br/>'+s;
        }
        message.htmlbody =ex+ '<br/> Following Opportunities have issue, Please take appropriate action:'+err;        
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (results[0].success) {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: '
                         + results[0].errors[0].message);
        }
    }
    
    public class CustomException extends Exception {}
       
}