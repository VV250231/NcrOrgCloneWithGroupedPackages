trigger SolutionProviderProductTrigger on Solution_Provider_Product__c (after insert, after update, after undelete) {
    
      new SolutionProviderProductTriggerDispatcher().run();
}