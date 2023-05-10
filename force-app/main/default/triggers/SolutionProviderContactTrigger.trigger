/****************************************************************************************************************
*   TriggerName :   SolutionProviderTrigger
*   Description :   
*   Author      :   Brian Rickard
*   Version     :   Initial
****************************************************************************************************************/
trigger SolutionProviderContactTrigger on Solution_Provider_Contact__c (before insert, before update, before delete,
  after insert, after update, after delete, after undelete) 
{
    new SolutionProviderContactTriggerDispatcher().run(); 
}