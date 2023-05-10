trigger SolutionProviderProductInterfaceTrigger on Solution_Provider_Product_Interface__c (after insert, after update) {
    
    new SolutionProviderProductIFTrigDispatch().run();
    
}