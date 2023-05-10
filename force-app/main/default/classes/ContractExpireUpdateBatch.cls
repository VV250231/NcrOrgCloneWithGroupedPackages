global class ContractExpireUpdateBatch implements Database.Batchable<sObject> {
    // Start Method
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Id recordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByName().get('FI Contract').getRecordTypeId();
        String query = 'SELECT Id, AccountId, OwnerExpirationNotice, Account.region__c, StartDate, EndDate,Renewal_Type__c,'+
            'Owner_Expiration_Notice__c, Owner_Expiration_Notice_Date__c,Renewal_Period_Months__c,  Contract_End_Date_Override__c '+
            ' FROM Contract where Renewal_Type__c=\'Automatic Extension\' AND Status = \'Activated\' AND Contract_End_Date_Override__c = true '+
            'AND Account.region__c =\'NABG\' AND Owner_Expiration_Notice_Date__c = today AND catm_record__c = true';
        System.debug('qry '+query);
        return Database.getQueryLocator(query);   
    }
    //Execute Method
    global void execute(Database.BatchableContext BC, List<Contract> scope) {
        if(scope!=null && scope.size()>0){
            List<Contract> upplistContract = new List<Contract>();
            for(Contract con : scope)
            {
                if(con.CATM_Record__c) {
                    integer dt = Integer.valueOf(con.Renewal_Period_Months__c);
                    
                    con.EndDate = con.EndDate.addMonths(dt);
                    upplistContract.add(con);
                    system.debug('upplistContract 1'+upplistContract); 
                }

            }
            try{
                if(!upplistContract.isEmpty() && upplistContract!=null){
                    update upplistContract;
                    system.debug('upplistContract'+upplistContract);
                }
                
            }
            catch(Exception ex){
                System.debug(' stack trace  '+ex.getStackTraceString());
                System.debug(' excetion  '+ex);
            }
        }
        
    }
    // Finish Method
    global void finish(Database.BatchableContext BC) {
        
    }
    
}