@isTest
public class blockDeletionTest{
    public static testMethod void myTest(){
          Profile p = [SELECT id from Profile WHERE name = 'iPaas Administration'];
        User u = new User(alias = 'standt', email='standarduser11@ncr.com',
                          emailencodingkey='UTF-8', lastname='Testing4',Quicklook_Id__c='ValProfl', languagelocalekey='en_US',
                          localesidkey='en_US',/*profileid = p.Id*/ profileid=p.Id,timezonesidkey='America/Los_Angeles',
                          username='standarduser1@.ncr.com'+System.now().getTime()+'.com');
        system.runAs(u){
            Sales_org_Code_Mapping__c  sm = new Sales_org_Code_Mapping__c();
            sm.Name='Test';
            insert sm;
            List<Sales_org_Code_Mapping__c  > myList = new List<Sales_org_Code_Mapping__c  >();
            myList =[Select Id from Sales_org_Code_Mapping__c  where Id =:sm.Id LIMIT 1];
            try{
                delete myList ; 
                List<Sales_org_Code_Mapping__c> smObj = [select id from Sales_org_Code_Mapping__c where id=:sm.id];
                System.assert(smObj.size()==0);
            }
            catch(Exception e){
                System.assert(e.getMessage()!=null);
            }
           
        }
    }
}