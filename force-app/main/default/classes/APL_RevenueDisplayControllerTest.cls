@isTest
private class APL_RevenueDisplayControllerTest {
    
    static testMethod void myTest() {
        Account acc=TestRecordsFactory.createAccount();
  
        List<APL_Account_Revenue__c> aplRevenueList = new List<APL_Account_Revenue__c>{new APL_Account_Revenue__c(Account__c= acc.Id, fml_account_code__c='4001', 
                                            customer_nbr__c = acc.Master_Customer_Number__c, USD_Amount__c= 100),
                                            new APL_Account_Revenue__c(Account__c= acc.Id, fml_account_code__c='4002', 
                                            customer_nbr__c = acc.Master_Customer_Number__c, USD_Amount__c= 100)
                                            };
        insert aplRevenueList;
        
        List<APL_Revenue_Category_Mapping__c> revCatList = new List<APL_Revenue_Category_Mapping__c>{ new APL_Revenue_Category_Mapping__c(FML_Account_Code__c = '4001', 
                                                                                                        Category__c  = 'HARDWARE MAINTENANCE_4001'),
                                                                                                      new APL_Revenue_Category_Mapping__c(FML_Account_Code__c = '4002', 
                                                                                                        Category__c  = 'SW MAINTENANCE_4002')
                                                                                                     }; 
       
        insert revCatList ;
        
        APL_RevenueDisplayController.getRevenueByCategory(acc.Id);
        APL_HierarchyRevenueDisplayController.RevenueWrapper r= APL_HierarchyRevenueDisplayController.getRevenueByCategory(acc.Id);
        System.assertEquals(r.HWM_Value,100);
    }
}