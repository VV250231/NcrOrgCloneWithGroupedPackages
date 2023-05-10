@isTest
public class ContractExpireUpdateCls_Test {
    
    @isTest
    public static void testdata(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Data Backup and Recovery Admin' Limit 1]; 
        User u = new User(Alias = 'standt', Email='standarduser@testorvjkhbvjhgejghwefg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          Quicklook_ID__c = '293103',
                          TimeZoneSidKey='America/New_York', UserName='standarduser@testorvjkhbvjhgejghwefg.com');
        insert u;
        
        
        
        System.runAs(u){
            List<Account> lstAccount = new List<Account>();
            for(Integer i=0; i<2; i++)
            {
                account acc = new Account();
                acc.BillingCity ='test';
                acc.Name = 'testing';
                acc.CATM_Region__c = 'NABG';
                lstAccount.add(acc);
            }
            insert lstAccount;
            
            List<Contract> lstContract = new List<Contract>();
            List<Contract> updContracts = new List<Contract>();
            for(Account acc:lstAccount)
            {
                Contract con =new Contract();
                //con.Status = 'Activated';
                con.AccountId = acc.Id;
                con.CATM_Record__c = true;
                con.Renewal_Type__c = 'Automatic Extension';
                //con.RecordTypeId= recordTypeId;
                con.Owner_Expiration_Notice_Date__c = system.Today();
                con.EndDate = system.Today();
                con.CPQ__c = FALSE;
                //con.Account.region__c ='NABG';
                lstContract.add(con);
            }
            
            insert lstContract;
            for(Contract con: lstContract){
                //con.RecordTypeId= recordTypeId;
                con.EndDate = system.today() + 30;
                con.Renewal_Period_Months__c = 1;
                
                con.Status = 'Activated';
                updContracts.add(con);
            }
            
            update updContracts;
            
            Test.startTest();
            
            //Database.executeBatch(new ContractExpireUpdateBatch());        
            ContractExpireUpdateCls sch = new ContractExpireUpdateCls();
            String cron = '0 0 6 1/1 * ? *';
            id job = System.schedule('UpdateContractEnddate' , cron, sch);
            
            ContractExpireUpdateBatch cb = New ContractExpireUpdateBatch();
            
            Database.QueryLocator ql = cb.start(null);
            cb.execute(null, updContracts);
            cb.Finish(null);
            
            Test.stopTest();
        }
    }
}