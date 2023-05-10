/*
Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
*/
@IsTest
Public class MultiselecttoplinesControllerTest{
    
    static testMethod void testmultiselectlist(){
        Account acc = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = '12345',
            Name = 'Unit Test1 ',
            RecordTypeId = NSCCommonInfoUtil.getInstance().getRecordTypeId('Account','Customer'),
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL'
            
        );
        User u = TestRecordsFactory.getUser();   
        System.runas(u){
            insert acc;
        }
        
        Majors_Product_Matrix__c mp=new Majors_Product_Matrix__c (
            MCN__c='12345',
            New_Competetors__c='NCR;Diebod',
            Purchased_List__c='test1',
            Not_Sold_List__c='test2;test3',
            Producttoplines__c='test1;test2;test3'
            
        );
        insert mp;
        
        ToplineCompetetors__c cs = new ToplineCompetetors__c();
        cs.Competetors__c='test1;test2;test4;test4';
        cs.name='testcs';
        //cs.Other fiels values
        insert cs;
        
        
        MultiselecttoplinesController.getpickval_CompetitorValues();
        MultiselecttoplinesController.NewGetPicklistNotSoldValue(acc.id);
        MultiselecttoplinesController.addCompetetors('inputtext');
        MultiselecttoplinesController.saveCompetetors('NCR',acc.id);
        Majors_Product_Matrix__c str1=[select id,New_Competetors__c from Majors_Product_Matrix__c where MCN__c =:acc.Master_Customer_Number__c] ;
        System.assert(str1.New_Competetors__c=='NCR');
        MultiselecttoplinesController.SaveNotSoldvalues('inputtext2',acc.id);
        MultiselecttoplinesController.NewGetPicklistCompetetorsValue(acc.id);
        MultiselecttoplinesController.saveSelectedSoldItems('NCR','Diebod',acc.id);
        
    }     
    
}