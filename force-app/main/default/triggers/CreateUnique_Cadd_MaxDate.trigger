trigger CreateUnique_Cadd_MaxDate on CADD_Management_History__c (Before Insert, After Insert) {
    Map<String,Date> UniqueOrderNumberSet= new Map<String,Date>();
    List<CADD_Management_History__c > HistoryObjListForUpdate = new List<CADD_Management_History__c >();
    Map<String,List<CADD_Management_History__c >> MaxHistoryListMap = new Map<String,List<CADD_Management_History__c >>();
    Map<String,Date> AggregateMap = new Map<String,Date>();
    List<Deming__c> DemObjListToUpdate = new List<Deming__c>();
    List<Deming__c> DemObjListToInsert = new List<Deming__c>();
    List<String> PrcessedOrderSet= new List<String>();
    Map<String,CADD_Management_History__c> LatestMaptoUpdateCADD= new Map<String,CADD_Management_History__c>();
    
    if(Trigger.IsAfter && Trigger.IsInsert){
        
        for(CADD_Management_History__c DemObjHistory : Trigger.New){
            if(String.isNotBlank(DemObjHistory.Order_Id__c)){
                UniqueOrderNumberSet.put(DemObjHistory.Order_Id__c,DemObjHistory.Max_Promise_Date__c);
                LatestMaptoUpdateCADD.put(DemObjHistory.Order_Id__c, DemObjHistory);   
            } 
        }
    } 
    
    if(UniqueOrderNumberSet.KeySet().Size() > 0){
        
        for(AggregateResult  AggObj :[SELECT Order_Id__c,Max(Max_Promise_Date__c) MaxDate FROM CADD_Management_History__c where Order_Id__c IN : UniqueOrderNumberSet.KeySet() GROUP BY Order_Id__c Limit 50000]){
            if(!AggregateMap.containsKey((String)AggObj.get('Order_Id__c'))){
                AggregateMap.put((String)AggObj.get('Order_Id__c'), (date)AggObj.get('MaxDate'));
            }                                    
        }
        
        for(CADD_Management_History__c  Obj : [select id,SalesOrdCode__c,Customer_Country_code__c,Site__c,Salesperson_Global_Id__c,Customer_Name__c,Customer_Industry__c,Max_Promise_Date__c,Max_Scheduled_Ship_Date__c,RDD__c,SalesPerson_Name__c,Party_No__c,Reason_Code__c,Order_number__c,Order_Id__c,Customer_No__c,Delivery_To_Location__c,delivery_to_address1__c,IsMaxPromiseDateChange__c,CDP_Global_Id__c from  CADD_Management_History__c where  Order_Id__c IN : UniqueOrderNumberSet.KeySet() order by createdDate desc limit 50000]){
            
            if(!MaxHistoryListMap.ContainsKey(Obj.Order_Id__c)){
                MaxHistoryListMap.put(Obj.Order_Id__c,new List<CADD_Management_History__c >());
            }
            MaxHistoryListMap.get(Obj.Order_Id__c).add(Obj);
        }
        
        for(String OrderId: MaxHistoryListMap.KeySet()){
            
            if(AggregateMap.containsKey(OrderId)){
                Boolean Counter = false;
                for(CADD_Management_History__c HistiryObj : MaxHistoryListMap.get(OrderId)){
                    CADD_Management_History__c HistoryObj = new CADD_Management_History__c();
                    HistoryObj.Id=HistiryObj.id;
                    if((AggregateMap.get(OrderId) == HistiryObj.Max_Promise_Date__c) && (Counter == false)){
                        
                        HistoryObj.IsMaxPromiseDateChange__c=true;
                        Counter=true;
                    } 
                    else{
                        HistoryObj.IsMaxPromiseDateChange__c=false;
                    }
                    HistoryObjListForUpdate.add(HistoryObj);
                }
            }
            
        }
        
        
        if(HistoryObjListForUpdate.size() > 0){
            update HistoryObjListForUpdate;
        }
        
    }
    
    if(LatestMaptoUpdateCADD.keySet().Size() > 0){
        Map<String,List<Deming__c>> DemObjFinalMap= New Map<String,List<Deming__c>>();
        
        for(Deming__c DemObj : [Select id,Salesperson_Global_Id__c,Max_Promise_Date__c ,Name,Order_Id__c,Cadd_Status__c,Customer_No__c from Deming__c where Order_Id__c IN : LatestMaptoUpdateCADD.keySet() and ((Cadd_Status__c = '')  OR (Cadd_Status__c= null) OR (Cadd_Status__c = 'Open')) order by Createddate desc limit 50000]){
            
            //system.debug('2222222222222222222'+DemObj.Order_Id__c);
            Deming__c DemingObjToUpdate = new Deming__c();
            if((String.isEmpty(DemObj.Cadd_Status__c) ) || (DemObj.Cadd_Status__c == 'Open')){
                //system.debug('44444444444444444'+DemObj.Order_Id__c);
                if(LatestMaptoUpdateCADD.containsKey(DemObj.Order_Id__c)){
                    system.debug('5555555555555555'+DemObj.Order_Id__c);
                    DemingObjToUpdate.Max_Promise_Date__c =LatestMaptoUpdateCADD.get(DemObj.Order_Id__c).Max_Promise_Date__c;
                    DemingObjToUpdate.id=DemObj.id;
                    DemingObjToUpdate.Include_In_Process__c=False;  
                    //System.debug('Pankaj kashyap>>>>>>>>>>'+DemObj.id);
                    DemObjListToUpdate.add(DemingObjToUpdate);  
                }
                
                LatestMaptoUpdateCADD.remove(DemObj.Order_Id__c);
            }        
            
        }
        for(String RemainingOrderId : LatestMaptoUpdateCADD.keySet()){
            
            //if(DemingValidateExecution.ValidateMCNSwitch(LatestMaptoUpdateCADD.get(RemainingOrderId))){
            
            Deming__c DemingObjToInsert = new Deming__c();
            //system.debug('33333333333333333'+LatestMaptoUpdateCADD.get(RemainingOrderId).Order_Id__c);
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).CDP_Global_Id__c)){
                DemingObjToInsert.CDP_Global_Id__c=LatestMaptoUpdateCADD.get(RemainingOrderId).CDP_Global_Id__c;
            }  
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).delivery_to_address1__c)){
                DemingObjToInsert.delivery_to_address1__c=LatestMaptoUpdateCADD.get(RemainingOrderId).delivery_to_address1__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Delivery_To_Location__c)){
                DemingObjToInsert.Delivery_To_Location__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Delivery_To_Location__c;
            }
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_No__c)){
                DemingObjToInsert.Customer_No__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_No__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Order_Id__c)){
                DemingObjToInsert.Order_Id__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Order_Id__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Order_number__c)){
                DemingObjToInsert.Order_number__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Order_number__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Reason_Code__c)){
                DemingObjToInsert.Reason_Code__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Reason_Code__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Party_No__c)){
                DemingObjToInsert.Party_No__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Party_No__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).SalesPerson_Name__c)){
                DemingObjToInsert.SalesPerson_Name__c=LatestMaptoUpdateCADD.get(RemainingOrderId).SalesPerson_Name__c;
                //String[] arrOrdCode = LatestMaptoUpdateCADD.get(RemainingOrderId).SalesPerson_Name__c.split('\\-');
                //DemingObjToInsert.SalesPerson_Name__c=arrOrdCode[0];
            } 
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).RDD__c != null){
                DemingObjToInsert.RDD__c=LatestMaptoUpdateCADD.get(RemainingOrderId).RDD__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Max_Scheduled_Ship_Date__c != null){
                DemingObjToInsert.Max_Scheduled_Ship_Date__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Max_Scheduled_Ship_Date__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Max_Promise_Date__c != null){
                DemingObjToInsert.Max_Promise_Date__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Max_Promise_Date__c;
            } 
            
            /*if(LatestMaptoUpdateCADD.containsKey(DemObj.Order_Id__c) && String.isNotBlank(LatestMaptoUpdateCADD.get(DemObj.Order_Id__c).Cadd_Status__c)){
DemingObjToInsert.Cadd_Status__c=LatestMaptoUpdateCADD.get(DemObj.Order_Id__c).Cadd_Status__c;
}*/
            //Empty If statement was commented
            //if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Industry__c != null){
                //DemingObjToInsert.Customer_Industry__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Industry__c;
            //} 
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Name__c != null){
                DemingObjToInsert.Customer_Name__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Name__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).SalesOrdCode__c != null){
                DemingObjToInsert.SalesOrdCode__c=LatestMaptoUpdateCADD.get(RemainingOrderId).SalesOrdCode__c;
            } 
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Salesperson_Global_Id__c!= null){
                DemingObjToInsert.Salesperson_Global_Id__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Salesperson_Global_Id__c;
            }
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Country_code__c!= null){
                DemingObjToInsert.Customer_Country_code__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Customer_Country_code__c;
            }
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && LatestMaptoUpdateCADD.get(RemainingOrderId).Site__c!= null){
                DemingObjToInsert.Site__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Site__c;
            }
            
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).CUSTOMER_INDUSTRY__C)){
                DemingObjToInsert.CUSTOMER_INDUSTRY__C=LatestMaptoUpdateCADD.get(RemainingOrderId).CUSTOMER_INDUSTRY__C;
            }
            if(LatestMaptoUpdateCADD.containsKey(RemainingOrderId) && String.isNotBlank(LatestMaptoUpdateCADD.get(RemainingOrderId).Quote_Number__c)){
                DemingObjToInsert.Quote_Number__c=LatestMaptoUpdateCADD.get(RemainingOrderId).Quote_Number__c;
            }
            
            DemingObjToInsert.Include_In_Process__c=False;
            DemObjListToInsert.add(DemingObjToInsert);
            
            //}
            
        }
        if(DemObjListToInsert.size()>0){
            insert DemObjListToInsert;
        }
        if(DemObjListToUpdate.size()>0){
            Update DemObjListToUpdate;
        }
        
    }    
}