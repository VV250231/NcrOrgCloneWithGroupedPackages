trigger insertContactinAccountTeam on cdm_Account_Relationship__c (after insert, after update, after Delete) 
{
    //Related Partner End customer Map to Add
    Map<id,List<id>> addMap=new Map<id,List<id>>();
    //Related Partner End customer Map for removal	
    Map<id,List<id>> removeMap=new Map<id,List<id>>();    
    if(Trigger.isDelete){
        for(cdm_Account_Relationship__c car : Trigger.old)
        {
            if(Trigger.oldMap.get(car.id).Related_Account_AccountType__c ==  Label.AccRel_AccTyp_EC && Trigger.oldMap.get(car.id).Relationship_Type__c ==Label.AccRel_RelTyp_ECP) {
                list <id> relEndCustL = removeMap.get(car.Account__c);
                if(relEndCustL!=null)
                {
                    relEndCustL.add(Trigger.oldMap.get(car.id).Related_Account__c);
                }else
                {
                    removeMap.put(Trigger.oldMap.get(car.id).Account__c,new List<id>{Trigger.oldMap.get(car.id).Related_Account__c});
                }     
            }       
        }
    }else{
        for(cdm_Account_Relationship__c car : Trigger.new)
        {
            List<id> relatedEC=addMap.get(car.Account__c);
            if(car.Related_Account_AccountType__c == Label.AccRel_AccTyp_EC && car.Relationship_Type__c ==Label.AccRel_RelTyp_ECP ){
                if(Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(car.id).Related_Account_AccountType__c!=car.Related_Account_AccountType__c || Trigger.oldMap.get(car.id).Account__c!=car.Account__c || (car.Active__c && Trigger.oldMap.get(car.id).Active__C==false )))){
                    if(relatedEC!=null){
                        relatedEC.add(car.Related_Account__c);
                    }else{
                        addMap.put(car.Account__c,new List<id>{car.Related_Account__c});
                    }  
                }           
            }
            else 
            {
                if(Trigger.isUpdate && ((Trigger.oldMap.get(car.id).Related_Account_AccountType__c ==  Label.AccRel_AccTyp_EC && Trigger.oldMap.get(car.id).Relationship_Type__c ==Label.AccRel_RelTyp_ECP) || (car.Active__c==false && Trigger.oldMap.get(car.id).Active__C==true )))
                {  
                    list <id> relEndCustL = removeMap.get(car.Account__c);
                    if(relEndCustL!=null)
                    {
                        relEndCustL.add(Trigger.oldMap.get(car.id).Related_Account__c);
                    }else
                    {
                        removeMap.put(Trigger.oldMap.get(car.id).Account__c,new List<id>{Trigger.oldMap.get(car.id).Related_Account__c});
                    }  
                }
            }
        }
    }    
    if(removeMap.size()>0)
    {
        System.enqueueJob(new AccountRelationshipHandler(removeMap,true));
    }    
    if(addMap.size()>0)
    { 
        System.enqueueJob(new AccountRelationshipHandler(addMap,false));
    }
}