@isTest
public class CheckForActiveUserTest {
   @isTest static void testCheckForActiveUser() {
        
        User u =[Select id,Name from User where isactive=true order by Name Desc  limit 1];
       	User doNotRep = [Select id from User where name ='Do Not Reply' limit 1];
        Account a = TestRecordsFactory.createAccount();
        System.assertNotEquals(a.id, null,'Account creation failed');  
        Deming__c DemObj= new Deming__c();
        DemObj.Order_Id__c='47593451';                                       //Select id,Order_Number__c,Order_Line_Id__c from ERP_Orders_Backlog__c          208395648
        DemObj.SalesPerson_Global_Id__c='14200124419-201100959';             //Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c  41477033784-20110098
        DemObj.SalesOrdCode__c='201100959';                                //Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c
        DemObj.Customer_No__c='7392826';
        DemObj.Order_number__c='5340549';
        DemObj.Customer_Country_code__c= 'US'; //Select id,Name,Master_Customer_Number__c,Owner.Email from Account  8533019PH
        DemObj.Max_Promise_Date__c=System.today();
        DemObj.EditShareWithUser__c=u.id;
        
        Test.StartTest();
        CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
        TargetObjectIdEmial.UserID__c=doNotRep.Id;
        TargetObjectIdEmial.Name='Do Not Reply User For CADD';
        DemObj.RelatedAccount__c=a.id;
        insert TargetObjectIdEmial;
        DemObj.Include_In_Process__c=true; 
        insert DemObj;
        lIST<String> TempList = new List<String>();
       TempList.add(DemObj.id);
        CheckForActiveUser.FilterActiveUsers(TempList);
       
    }
}