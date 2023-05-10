@isTest
private class Account_Related_ContractsHandlerTest {
    
    @isTest
    private static void test_sumOpp_UseCase1(){
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Data Backup and Recovery Admin' Limit 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorvjkhbvjhgejghwefg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          Quicklook_ID__c = '293103',
                          TimeZoneSidKey='America/New_York', UserName='standarduser@testorvjkhbvjhgejghwefg.com');
        insert u;
        
        System.runAs(u) {
            list<Contract> updateContract = new list<Contract>();
            //Creating FIAccount Record Type Account
            String FIAccountTypeID = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().
                get('Customer').getRecordTypeId();
            system.debug('FIAccountTypeID: '+FIAccountTypeID); 
            
            Account acc =  new Account();
            acc.Name = 'TestAccount';
            acc.RecordTypeId = FIAccountTypeID;
            //acc.Contract_Actual_ACV__c = 10000;
            //acc.Total_Annual_Contract_Value__c = 20000;
            acc.Type ='Customer';
            insert acc;
            
            //Creating FIContract Record Type Contract
            //String FIContractTypeID = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().
            //    get('FI Contract').getRecordTypeId();
            //system.debug('FIContractTypeID: '+FIContractTypeID) ;
            
            //created the Contract record with mandatory fields
            list<Contract> lstContract = new list<Contract>();
            Contract firstContract = new Contract ();
            //firstContract.RecordTypeId = FIContractTypeID; 
            firstContract.AccountId = acc.id;
            firstContract.Status ='Draft';
            firstContract.CATM_Record__c = TRUE;
            firstContract.StartDate =system.today();
            firstContract.ContractTerm = 14;
            //firstContract.Annual_Contract_Value__c=20000.00;
            firstContract.Actual_ACV__c =1000.00;
            firstContract.Products__c = 'TestProduct, TestProduct2';
            lstContract.add(firstContract);
            
            //Creating FIContract Record Type Contract
            //String FIContractTypeID2 = Schema.getGlobalDescribe().get('Contract').getDescribe().getRecordTypeInfosByName().
            //    get('FI Contract').getRecordTypeId();
            //system.debug('FIContractTypeID: '+FIContractTypeID2) ;
            
            //created the Contract record with mandatory fields
            
            Contract SecondContract = new Contract ();
            //SecondContract.RecordTypeId = FIContractTypeID2;
            SecondContract.AccountId = acc.id;
            SecondContract.Status ='Draft';
            SecondContract.CATM_Record__c = true;
            SecondContract.StartDate =system.today();
            SecondContract.ContractTerm = 14;
            //SecondContract.Annual_Contract_Value__c=30000.00;
            SecondContract.Actual_ACV__c =2000.00;
            SecondContract.Products__c = 'TestProduct2, TestProduct3';
            //lstContract.add(SecondContract);
            insert lstContract;
            
            Test.startTest();
            
            firstContract.Status ='Activated';
            //SecondContract.Status ='Activated';
            update lstContract;
            
            //List<Account> account_Obj  =  [SELECT Id,Name,Has_Support_Plan__c,Opp_Total_Amount__c from Account];
            //System.assertEquals(true,account_Obj.size()>0);
            
            //set<id> accid = new set<id>();
            //accid.add(acc.id);
            
            //Account_Related_ContractsHandler obj01 = new Account_Related_ContractsHandler();
            //Account_Related_ContractsHandler.allContractedproducts(lstContract);
            //Account_Related_ContractsHandler.sumCOntracts(accid);
            //Account_Related_ContractsHandler.countOfContracts(acc.id);
            delete lstContract; 
            Test.stopTest();
        }
   
    }
    
}