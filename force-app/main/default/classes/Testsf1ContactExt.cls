@isTest 
private class Testsf1ContactExt {
    static testMethod void myUnitTest() { 
        // create new Opportunity object 
        Opportunity opp = TestUtitlity.createOppRecord();  
        ApexPages.currentPage().getParameters().put('Id', opp.Id);    
        
        ApexPages.StandardController stdctr = new ApexPages.StandardController(opp); 
        sf1ContactExt conObj = new sf1ContactExt(stdctr);
        PageReference p = conObj.redirectToContact();
        system.debug('p');
        system.assertNotEquals(p, null);
    }

}