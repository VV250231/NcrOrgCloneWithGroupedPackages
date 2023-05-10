trigger update_region_from_account on Presales_Engineer_Activity__c (before insert,before update) {
   List <ID> pseOppIdList = new  List <ID>();
   List <ID> pseAccIdList = new  List <ID>();
   Map<Id ,Account> accountMap  = new Map<Id ,Account>();
   Map<Id ,Opportunity> OpportunityMap  = new Map<Id ,Opportunity>();
   For(Presales_Engineer_Activity__c pse: Trigger.New){
      pseAccIdList.add(pse.PSE_Account__c);
      pseOppIdList.add(pse.PSE_Opportunity__c); 
   } 
   If(pseAccIdList != null && !pseAccIdList.isEmpty()){ 
        accountMap = new Map<Id, Account>([Select id , Name , Account_Region__c From Account Where id =: pseAccIdList]);
        OpportunityMap  = new Map<Id ,Opportunity>([Select id , Name, AccountId,Account.Account_Region__c From Opportunity Where id =: pseOppIdList]);
        
       
   }
   for(Presales_Engineer_Activity__c pse : Trigger.new){
       
       If(OpportunityMap != null && !OpportunityMap.isEmpty() && OpportunityMap.containsKey(pse.PSE_Opportunity__c)  )
       {
           pse.PSE_Account__c = OpportunityMap.get(pse.PSE_Opportunity__c).AccountId ;
           pse.PSE_Region__c = OpportunityMap.get(pse.PSE_Opportunity__c).Account.Account_Region__c;
           pse.PSE_Opportunity_Number_Not_Yet_Created__c = False;
       }
     If(accountMap != null && !accountMap.isEmpty() && accountMap.containsKey(pse.PSE_Account__c) )
       {
           pse.PSE_Region__c = accountMap.get(pse.PSE_Account__c).Account_Region__c;
        //  pse.PSE_Opportunity_Number_Not_Yet_Created__c = True;
       }
    
  
   }
         
  }