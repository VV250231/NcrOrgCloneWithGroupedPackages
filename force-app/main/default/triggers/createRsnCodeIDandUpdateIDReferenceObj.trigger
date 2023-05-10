trigger createRsnCodeIDandUpdateIDReferenceObj on Reason_Code__c (before insert,before update) 
{
   ID_Reference__c IDRefObj=new ID_Reference__c();
    Integer IdCount;
    if(trigger.isInsert)
    {
        IDRefObj=[select Id,ReasonCode_Last_Record_ID__c from ID_Reference__c limit 1];
        IdCount=integer.valueOf(IDRefObj.ReasonCode_Last_Record_ID__c);
        for (Reason_Code__c rc : trigger.new) 
        {  
            if(rc.ReasonCode_Name__c==null)
            {            
               if(rc.Name!=null)           
                   rc.ReasonCode_Name__c=rc.Name;
            }
           
            if(rc.ID__c==null)
            {
                IdCount++;
                rc.ID__c=String.valueOf(IdCount);
            }
        }
        IDRefObj.ReasonCode_Last_Record_ID__c=String.valueOf(IdCount);
        update IDRefObj;
    }
    if(trigger.isUpdate)
    { 
        for (Reason_Code__c rc : trigger.new) 
        {
            if(Trigger.oldMap.get(rc.Id).Name !=rc.Name) 
                      rc.ReasonCode_Name__c=rc.Name;
           
                      
    
         }
   }
}