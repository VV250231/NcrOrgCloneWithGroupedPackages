public without sharing class  AllAccountCntrl {
    
    @AuraEnabled
    public static List<Account> AccountSearched(String searchkey, Integer ofset){ 
        List<Account> accList = new List<Account>();
        String ofsetStrng='';
        Integer ofset1=Integer.valueOf(ofset);
        if(ofset!=null && ofset1>0){
            ofsetStrng ='OFFSET '+String.valueOf(ofset1);
        }
        system.debug('##'+ofsetStrng);
        String srchKey=String.escapeSingleQuotes(searchkey);
        
        String query='Select Id, Name, Master_Customer_Number__c, Active_Account__c, Account_Country_Code__c, Industry, Lob__c, Owner.Name, recordtype.name, Area__c from Account where name like \'%'+srchKey+'%\'  or Master_Customer_Number__c like \'%'+srchKey+'%\' Order By Name Limit 25 '+ofsetStrng ; 
        system.debug('##'+query);
        accList = Database.query(query);
        system.debug(accList);
        return accList;
    }
    
    @AuraEnabled
    public static Integer count(String searchkey){ 
        String srchKey=String.escapeSingleQuotes(searchkey);
        String query='Select Id from Account where name like \'%'+srchKey+'%\'  or Master_Customer_Number__c like \'%'+srchKey+'%\' ' ; 
        system.debug('##'+query);
        List<Account> accList = Database.query(query);
        return accList.size();
    }
    
}