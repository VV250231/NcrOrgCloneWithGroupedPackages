@isTest
public class AutoPopulateHierarchyFieldsTest{
    public static testMethod void TestAutoPopulateHierarchyFields(){
    
    Product2 Pro = new Product2();
    Pro.Name = 'ATM Machine';
    Pro.L0_Category_text__c = 'NCR';
    Pro.L1_Category_text__c = 'ABC';
    Pro.L2_Category_text__c = 'DEF';
    Pro.L3_Category_text__c = 'GHI';
    Pro.L4_Category_text__c = 'JKL';
    Pro.L0_Category__c = '';
    Pro.L1_Category__c = '';
    Pro.L2_Category__c  = '';
    Pro.L3_Category__c = '';
    Pro.L4_Category__c = 'Test Topline 123';
        
    insert Pro;
        System.assert(pro.id!=null);
    }
    }