/****************************************************************************************************************
*   TriggerName :   SolutionProviderTrigger
*   Description :   
*   Author      :   Brian Rickard
*   Version     :   Initial
****************************************************************************************************************/
trigger SolutionProviderTrigger on Solution_Provider__c (before insert, before update, before delete,
  after insert, after update, after delete, after undelete) {
      
    new SolutionProviderTriggerDispatcher().run();
      
}