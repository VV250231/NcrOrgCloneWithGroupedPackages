@isTest
private class TestEmailUtility {
    static testMethod void myTest() {
        List<String> toEmailAddrss = new List<String>{'test1@test.com','test2@test.com',
                                                    'test3@test.com','test4@test.com',
                                                    'test5@test.com'};
        EmailUtility.sendEmail('Test Sub','Test Header', 'Test SubHeader', 'Test body', toEmailAddrss);
                                                                                                            
        Test.startTest();
            System.enqueueJob( new AsyncNotifier ('Test Header','Test SubHeader','Test Sub','Test body',toEmailAddrss));
         system.assert(toEmailAddrss.size()>0);
        Test.stopTest();                                                                                                          
    }
   
}