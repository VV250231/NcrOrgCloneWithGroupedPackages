public class PRM_AccountController 
{
	@AuraEnabled
    public static List<Account> getAccounts(String selectedView)
    {
       
        List<Account> lstAccount;
            
        if(selectedView == 'All Accounts')
        {
            lstAccount =  [Select Id, Name, Owner.Name, RecordType.Name, LOB__c, Partner_Program_Level__c
                       from Account order by CreatedDate ];
        }
        else
        {
            lstAccount =  [Select Id, Name, Owner.Name, RecordType.Name, LOB__c, Partner_Program_Level__c
                       		from Account where OwnerId =: UserInfo.getUserId() order by CreatedDate ];
        }
        return lstAccount;
    }
    
    
    @AuraEnabled
    public static Account getAccountDetail(String recId)
    {
        Account objAccount = [Select Id, Name, Phone, Fax, Website, Partner_Program_Level__c, 
                              Industry, CurrencyIsoCode, Area__c, Account_Region__c, LOB__c,BillingAddress, Account_Name_Local__c,
                              BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, Interact_Reseller_Agreement__c,rules_of_engagement__c
                              From Account where Id =: recId];
        return objAccount;
    }
    
   //removed executive_sponsorship_program_2017__c from query due to EBA_SF-688
}