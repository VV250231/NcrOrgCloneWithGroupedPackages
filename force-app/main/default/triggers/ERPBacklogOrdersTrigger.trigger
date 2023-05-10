trigger ERPBacklogOrdersTrigger on ERP_Orders_Backlog__c (after insert , after update ) {
    
    
    if(Trigger.isAfter && ERPBacklogOrdersTriggerHandler.runOnce() ) {
        List<ERP_Orders_Backlog__c> deleteList = new List<ERP_Orders_Backlog__c>() ;
        List<ERP_Orders_Backlog__c> updateList = new List<ERP_Orders_Backlog__c>() ;
        for(ERP_Orders_Backlog__c order : Trigger.new) {
            if(order.Tran_Code__c == 'D') {
               
                deleteList.add(new ERP_Orders_Backlog__c(Id=order.Id) ) ;
            } /*else if(order.Tran_Code__c == 'U' || order.Tran_Code__c == 'I') {
                ERP_Orders_Backlog__c nOrder = order.clone(true, true, true, true) ;
                updateList.add(nOrder) ;
            }*/
        }
        
        if(!deleteList.isEmpty() ) {
            delete deleteList ;
            
        }
        
       /* if(!updateList.isEmpty() ) {
            upsert  updateList Order_Line_Id__c ; 
            //ERPBacklogOrdersTriggerHandler.isFirstRun = false ;
        }*/
    }
}