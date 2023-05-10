trigger createOppTypeIDandUpdateIDReferenceObj on Opportunity_Type__c (before insert,before update) 
{
    ID_Reference__c IDRefObj=new ID_Reference__c();
    Integer IdCount;
    if(trigger.isInsert)
    {
        IDRefObj=[select Id,OpportunityType_Last_Record_ID__c from ID_Reference__c limit 1];
        IdCount=integer.valueOf(IDRefObj.OpportunityType_Last_Record_ID__c);
        for (Opportunity_Type__c oppType : trigger.new) 
        {  
            if(oppType.Opportunity_Type_Name__c==null)
            {
                if(oppType.Name!=null)           
                   oppType.Opportunity_Type_Name__c=oppType.Name;
            }
           
            if(oppType.ID__c==null)
            {
                IdCount++;
                oppType.ID__c=String.valueOf(IdCount);
            }
        }
        IDRefObj.OpportunityType_Last_Record_ID__c=String.valueOf(IdCount);
        update IDRefObj;
    }
    if(trigger.isUpdate)
    { 
        for (Opportunity_Type__c oppType : trigger.new) 
        {
            if(Trigger.oldMap.get(oppType.Id).Name !=oppType.Name) 
                    oppType.Opportunity_Type_Name__c=oppType.Name;
                      
    
         }
   }
   
}