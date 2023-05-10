@isTest
private class Test_SalesforceMapPrivacy {
    
    static testMethod void checkPermissionSet()
    {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'TestUser', Email='testuser@testuser.com',
                          EmailEncodingKey='UTF-8', LastName='User', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,Quicklook_ID__c='tu123456',
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuserx@testuser.com');
        If(u !=null)
            insert u;
        
        // Query your permission set name from Organization that your want to test.
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'MapsUser'];
        
        // Assign the above inserted user for the above Permission Set.
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = u.Id;
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        // Run your code with inserted user.
        System.runAs(u)
        {
            Test_SalesforceMapPrivacy pr = new Test_SalesforceMapPrivacy();
        }
        SalesforceMapPrivacyControllerClass.HasSalesforceMapPermission(u.id); 
        SalesforceMapPrivacyControllerClass.removeSalesforceMapPermission(u.id); 
        system.assertEquals( SalesforceMapPrivacyControllerClass.removeSalesforceMapPermission(u.id),false);
    }
}