/****************************************************************************************************************
//Name          :   CloneOpportunityWithSchedule.tgr(Opportunity)
//Author        :   Pankaj Kashyap
//Date          :   26 March 2017
//Version       :   Initial 1.0
//Description   :   This trigger will work for Opportunity Clone with product and its schedule.
//Modified by   : Saagar Kinja : Logic to adjest cloned opportunity product schedules based on new expected delivery date
****************************************************************************************************************/

global class CloneOpportunityWithSchedule{
    
    public static void InsertScheduleUnderCloneOpportunit(Set<ID> OppIdList){
        Set<String> OpportunityIdFromCloned = new Set<String>();
        Map<String,Opportunity> MapOpp =new Map<String,Opportunity>();
        Map<String,Date> incorrectOppFirstSchedule =new Map<String,Date>();
        Map<String,List<OpportunityLineItemSchedule>> MapOppSchedule =new Map<String,List<OpportunityLineItemSchedule>>();
        List<OpportunityLineItem> olilisttoInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItemSchedule> ScheduelListForCloneOpportunity = new List<OpportunityLineItemSchedule>();
        MAP<id,Opportunity> mappoppsc = new MAP<id,Opportunity>();MAP<id,Opportunity> mappoppscc = new MAP<id,Opportunity>();
        for(Opportunity oppobj : [select id,name,isCloneWithProduct__c,IsClone__c,CloseDate from Opportunity Where id IN : OppIdList and isCloneWithProduct__c = true])
        {
            
            if(String.isNotBlank(oppobj.IsClone__c)){
                OpportunityIdFromCloned.add(oppobj.IsClone__c);
            }
            
            if(!MapOpp.containsKey(oppobj.IsClone__c)){
                MapOpp.put(oppobj.IsClone__c,oppobj);
                mappoppscc.put(oppobj.id,oppobj);
            }
            
            
        }
        for(Opportunity o : [Select id,CloseDate from Opportunity where id IN:MapOpp.keyset() ]){
            mappoppsc.put(o.id,o);
        }
        
        for(OpportunityLineItem Oli :[select id,name,opportunityid,Scheduled_Qty__c,Revenue_Type__c,Is_Subscriptioned__c,Product_Category__c,Total_Cost_Value__c, One_Time_Fee__c, Number_of_Terms__c, Monthly_Fee__c, Actual_Contract_Value__c, (Select id,OpportunityLineItem.Opportunity.Id ,OpportunityLineItemId,Quantity,ScheduleDate,Type,OpportunityLineItem.Opportunity.CloseDate from OpportunityLineItemSchedules order by ScheduleDate ASC),Opportunity.CloseDate,pricebookentryid, quantity,totalPrice,ServiceDate,Discount,Description,ListPrice,Product2ID,ProductCode,UnitPrice,Subtotal from OpportunityLineItem where Opportunityid IN : MapOpp.KeySet()]){
            
            
            if(MapOpp.ContainsKey(Oli.opportunityid)) 
            {
                OpportunityLineItem ListOfOli = new OpportunityLineItem(OpportunityId = MapOpp.get(Oli.opportunityid).Id,PricebookEntryId = Oli.pricebookentryid ,Quantity =Oli.Quantity, TotalPrice=Oli.TotalPrice, ProductClonedFromId__c= Oli.id ,Scheduled_Qty__c = Oli.Scheduled_Qty__c,Revenue_Type__c = Oli.Revenue_Type__c, Product_Category__c = Oli.Product_Category__c, Is_Subscriptioned__c=oli.Is_Subscriptioned__c,Total_Cost_Value__c=oli.Total_Cost_Value__c, One_Time_Fee__c=oli.One_Time_Fee__c, Number_of_Terms__c=oli.Number_of_Terms__c, Monthly_Fee__c=oli.Monthly_Fee__c, Actual_Contract_Value__c=oli.Actual_Contract_Value__c);
                olilisttoInsert.add(ListOfOli); 
                
            }
            
            if(!MapOppSchedule.ContainsKey(Oli.id)){
                MapOppSchedule.put(Oli.id , New List<OpportunityLineItemSchedule>());
            }
            
            
            for(OpportunityLineItemSchedule olis : Oli.OpportunityLineItemSchedules){
                
                if(MapOppSchedule.containsKey(olis.OpportunityLineItemId))
                {
                    MapOppSchedule.get(Oli.id).add(olis);
                }
                if(oli.opportunity.CloseDate>olis.ScheduleDate){
                    if(!incorrectOppFirstSchedule.containsKey(oli.id)){
                        incorrectOppFirstSchedule.put(oli.id,olis.ScheduleDate);
                    }
                }
                
            }
            
        }
        
        
        insert olilisttoInsert;
        system.debug('test'+incorrectOppFirstSchedule+'mapscc'+mappoppscc+'mapsc'+mappoppsc);
        for(OpportunityLineItem oli : olilisttoInsert)
        {
            
            if(MapOppSchedule.containsKey(oli.ProductClonedFromId__c))
            {
                if(!incorrectOppFirstSchedule.containsKey(oli.ProductClonedFromId__c)){
                    for(OpportunityLineItemSchedule olisObj : MapOppSchedule.get(oli.ProductClonedFromId__c))
                    {
                        OpportunityLineItemSchedule olis = new  OpportunityLineItemSchedule(OpportunityLineItemId=oli.id,Quantity=olisObj.Quantity,
                                                                                            ScheduleDate= olisObj.ScheduleDate.addMonths(mappoppsc.get(olisObj.OpportunityLineItem.Opportunity.Id ).CloseDate.monthsBetween( MapOpp.get(olisObj.OpportunityLineItem.Opportunity.Id ).CloseDate ) ),
                                                                                            Type ='Quantity');
                        
                        ScheduelListForCloneOpportunity.add(olis);                
                    }  
                }else{
                    for(OpportunityLineItemSchedule olisObj : MapOppSchedule.get(oli.ProductClonedFromId__c))
                    {
                        Integer monthdifference= incorrectOppFirstSchedule.get(oli.ProductClonedFromId__c).monthsBetween(olisObj.ScheduleDate) +1;
                        system.debug('##'+monthdifference+'oppid'+oli.OpportunityId );
                        OpportunityLineItemSchedule olis = new  OpportunityLineItemSchedule(OpportunityLineItemId=oli.id,Quantity=olisObj.Quantity,
                                                                                            ScheduleDate= mappoppscc.get(oli.OpportunityId).CloseDate.addMonths(monthdifference)  ,
                                                                                            Type ='Quantity');
                        
                        ScheduelListForCloneOpportunity.add(olis);                
                    }                      
                }
                
                
            }
            
        }
        
        Insert ScheduelListForCloneOpportunity;
        
        
    }
    
}