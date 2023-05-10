trigger createMPIDandUpdateIDReferenceObj on Marketing_Program__c (before insert,before update) 
{
    ID_Reference__c IDRefObj=new ID_Reference__c();
    Integer IdCount;
    if(trigger.isInsert)
    {
        IDRefObj=[select Id,MarketingProgram_Last_Record_ID__c from ID_Reference__c limit 1];
        if(IDRefObj!=null){
            IdCount=integer.valueOf(IDRefObj.MarketingProgram_Last_Record_ID__c);
        }else{
            IdCount=1;
        }
        for (Marketing_Program__c mp : trigger.new) 
        {  
            if(mp.MarketingProgram_OfferPortfolio__c==null)
            {
                if(mp.Name!=null && mp.Industry__c!=null)           
                    mp.MarketingProgram_OfferPortfolio__c=mp.Name+mp.Industry__c;
            }
            
            if(mp.ID__c==null)
            {
                IdCount++;
                mp.ID__c=String.valueOf(IdCount);
            }
        }
        IDRefObj.MarketingProgram_Last_Record_ID__c=String.valueOf(IdCount);
        update IDRefObj;
    }
    if(trigger.isUpdate)
    { 
        for (Marketing_Program__c mp : trigger.new) 
        {
            if(Trigger.oldMap.get(mp.Id).Name !=mp.Name 
               || Trigger.oldMap.get(mp.Id).Industry__c!=mp.Industry__c) 
                mp.MarketingProgram_OfferPortfolio__c=mp.Name+mp.Industry__c;
            
            
        }
    }
    
}