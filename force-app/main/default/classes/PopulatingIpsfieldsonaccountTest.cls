@IsTest
private class PopulatingIpsfieldsonaccountTest{
static testmethod void createAccount(){
IPS_Field_Country_Code__c ipsdata=new IPS_Field_Country_Code__c(Account_Country_Code__c='A2',Corp_Area__c='SOUTH EASTERN EUROPE', Corp_Region__c='EUROPE',Corp_Theater__c='EMEA', IPS_Area__c='EMERGING',IPS_Region__c='EUROPE');
insert ipsdata;
Account ac=new Account();
ac.Name='Test IPS Fields';
ac.Account_Country_Code__c='A2';
ac.MDM_Industry_Name__c='FINANACIAL:BANKING';
    system.runAs(TestRecordsFactory.getUser()){
     insert ac;   
    }
System.assertNotEquals(ac.id, null,'Account is Null');  
}
}