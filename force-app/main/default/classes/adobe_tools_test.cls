@isTest
private class adobe_tools_test {

    private static testMethod void test() {
        
        /*List<echosign_dev1__SIGN_Agreement__c> agreements = [ SELECT id FROM echosign_dev1__SIGN_Agreement__c WHERE echosign_dev1__Status__c = 'Signed' LIMIT 1];*/
      
       echosign_dev1__SIGN_Agreement__c agreement = new echosign_dev1__SIGN_Agreement__c();
       agreement.Name = 'Test agreement';
       agreement.echosign_dev1__Document_Key__c = 'testkey';
       agreement.echosign_dev1__Status__c = 'Signed';
       agreement.echosign_dev1__Account__c = TestRecordsFactory.createAccount('test123').id;
       insert agreement;
 
       List<echosign_dev1__SIGN_Agreement__c> agreements = new List<echosign_dev1__SIGN_Agreement__c>();
       agreements.add(agreement);
       
        if( !agreements.isEmpty() ) {
            
            List<String> agreementIds = new List<String>();
            agreementIds.add( agreements.get(0).id );
            
            List<String> formData = adobe_tools.formData( agreementIds );
            system.assertNotEquals(formData, null);
            
        }

    }

}