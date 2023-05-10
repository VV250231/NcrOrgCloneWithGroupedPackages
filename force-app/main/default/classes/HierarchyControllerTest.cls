@isTest
private class HierarchyControllerTest {
    static testMethod void myTest() {
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
            
            Account site =new Account(Name = 'Test site', Site_Number__c = 'test1234', Primary_Bill_To__c = true,
                                    parentId = ac.Id, RecordTypeId = rtMapByName.get(Label.RT_Acc_Site).getRecordTypeId());
            insert site;
        }
        
        String st = HierarchyController.getAccountHierarchyData(parentAcc.Id);
        HierarchyController.getSites(ac.Id);
        HierarchyController.getAccountBasics(ac.Id);
        HierarchyController.getAccountSites(ac.Id, 0);
        HierarchyController.getConfs();
        HierarchyController.getCols('Opportunity','Name,Account.Name,Amount,Owner.lastName', 'Name,Account.Name,Forecast_Category__c,closedate');
        system.assert(st != null ,'Account data not returned'); 
    }
    
    
    static testMethod void relatedListTest() {
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
            
            Account site =new Account(Name = 'Test site', Site_Number__c = 'test1234', Primary_Bill_To__c = true,
                                      parentId = ac.Id,RecordTypeId = rtMapByName.get(Label.RT_Acc_Site).getRecordTypeId());
            insert site;
            
            Opportunity opp = TestRecordsFactory.createSimpleOpportunity(ac);
        }
        
       String jsonData = '{"fields":"Name, Account.Name, StageName, CloseDate, Amount","relatedFieldApiName":"AccountId","recordId":"0010100000ADHdtAAH","numberOfRecords":7,"sobjectApiName":"Opportunity","sortedBy":"Name","sortedDirection":"ASC"}';
       Account a = RelatedListController.getAccountBasics(ac.Id);
       RelatedListController.initData(jsonData);

       RelatedListController.allChildAccounts(parentAcc.Id); 
           RelatedListController.getIconName('Account');
         RelatedListController.deleteRecord(ac.Id);
       system.assertNotEquals(a, null, 'Account data not returned'); 
        
                    
                   
    }
}