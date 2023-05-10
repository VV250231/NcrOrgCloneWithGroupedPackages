@isTest
public class OpenDispatchesHandlerTest {
    @isTest
    public static void getDispatchTest(){
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
        List<APL_Account_Open_Dispatches__c> openDispatchList = new  List<APL_Account_Open_Dispatches__c>();
        APL_Account_Open_Dispatches__c od = new APL_Account_Open_Dispatches__c();
        od.Priority_code__c = '1';
        od.Account_Master_Lookup__c = ac.id;
        od.SLA_Category__c = 'Open Call Outside SLA';
        openDispatchList.Add(od);
         APL_Account_Open_Dispatches__c od1 = new APL_Account_Open_Dispatches__c();
         od1.Account_Master_Lookup__c = ac.id;
        od1.Priority_code__c = '2';
        od1.SLA_Category__c = 'Open Call Within SLA';
         openDispatchList.Add(od1);
         APL_Account_Open_Dispatches__c od2 = new APL_Account_Open_Dispatches__c();
         od2.Account_Master_Lookup__c = ac.id;
        od2.Priority_code__c = '2';
        od2.SLA_Category__c = 'Open Call Within SLA';
         openDispatchList.Add(od2);
        insert openDispatchList;
        system.assert(openDispatchList.size() >0); 
        OpenDispatchesHandler.getDispatch(ac.id);
        OpenDispatchesHierarchyHandler.getDispatch(ac.id);
        OpenDispatchesHierarchyHandler.getDispatch(parentAcc.id);
    }
}