@isTest
public class EntitlementSectionHandlerTest {
@isTest
    public static void getAccountEntitlementListTest(){
        Account ac=new Account();
        Account parentAcc =new Account();
        Map<String,Schema.RecordTypeInfo> rtMapByName = Schema.SObjectType.Account.getRecordTypeInfosByName();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
            parentAcc.Name='Test Parent Account';
            parentAcc.Account_Country_Code__c='A2';
            parentAcc.MDM_Industry_Name__c='FINANACIAL:BANKING';
            parentAcc.RecordTypeId = rtMapByName.get(Label.RT_Acc_Enterprise).getRecordTypeId();
            insert parentAcc;
            
            ac.Name='Test Account';
            ac.Account_Country_Code__c='A2';
            ac.MDM_Industry_Name__c='FINANACIAL:BANKING';
            ac.RecordTypeId = rtMapByName.get(Label.RT_Acc_Customer).getRecordTypeId();
            ac.parentId = parentAcc.Id;
            insert ac; 
        } 
        
        List<Account_Entitlements__c> entitlmentList = new  List<Account_Entitlements__c>();
        Account_Entitlements__c el = new Account_Entitlements__c(Account__c = ac.Id);
        el.Primary_Product_Desc__c = 'Test';
        el.Active_Count__c = 4;
        el.Hold_Count__c =2;
        el.Expired_Count__c = 23;
        entitlmentList.Add(el);
        
        Account_Entitlements__c el1 = new Account_Entitlements__c(Account__c = ac.Id);
        el1.Primary_Product_Desc__c = 'Test';
        el1.Active_Count__c = 4;
        el1.Hold_Count__c =2;
        el1.Expired_Count__c = 23;        
        entitlmentList.Add(el1);
        
        insert entitlmentList;
        System.assertNotEquals(el1, null,'entitlmentList should not be null');

        EntitlementSectionHandler.getAccountEntitlementList(ac.id);
        EntitlementSectionHierarchy.getAccountEntitlementList(ac.Id);
    }
    

}