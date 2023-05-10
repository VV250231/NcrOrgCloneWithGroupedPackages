@isTest
public class MarketoTestClass {
	@isTest
    public static void UnitTest(){
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get('Case').getDescribe().getRecordTypeInfosByName().get('Marketing Digital Response Team').getRecordTypeId();                       
	 Case caseObj = new Case();
         ExistingLeadContactHelper.isfirstMarketo=true;
        caseObj.RecordTypeId = CaseRecordTypeId;
        List<Case> caseList = new List<Case>();
        caseObj.DRT_Escalated_To__c ='test@test.com';
        caseObj.Chat_User_Company__c='Test';
        caseObj.Chat_User_Country__c='Test';
        caseObj.Chat_User_Email__c ='Test@test11.com';
        caseObj.Chat_User_First_Name__c ='Test';                            
        // caseObj.Chat_User_Industry__c='Test';
        caseObj.Chat_User_Last_Name__c = 'Test';
        caseObj.Chat_User_Source__c = 'Test';
        caseObj.Chat_User_Type__c ='Test';
        caseObj.Origin ='Forms';
        // caseObj.Owner.Name ='Test';
        caseObj.Agent_Notes__c = 'Test';
        caseObj.Business_Function__c ='Test';
        caseObj.Campaign_Code__c ='Test';
        caseObj.Campaign_Name__c ='Test';
        caseObj.Campaign_Status__c ='Test';
        caseObj.Campaign_Type__c ='Test';
        caseObj.City__c ='Test';
        //caseObj.RecordTypeId =,
        caseObj.Customer_Response_Time__c = '1 Days: 1 Hours: 12Minutes';
        caseObj.Staff_Response_Time__c = '0 Days: 1 Hours: 12Minutes';
        caseObj.Zip_Or_Postal_Code__c ='test';
        caseObj.State_Province__c = 'Test';
        caseObj.Title__c = 'Test';
        caseObj.Sub_Industry__c = 'Test';
        caseObj.Chat_User_Phone__c = 'Test';
        caseObj.Position__c = 'Test';
        //  caseObj.Number_of_Locations__c = 'Test';
        // caseObj.Years_In_Business__c = 'Test';
        // caseObj.Timing__c = 'Test';
        //  caseObj.Company_Annual_Sales__c = 'Test';
        // caseObj.Number_of_Employees__c = 'Test';
        caseObj.Subject ='Test'; 
        caseObj.Description='Test';
        caseObj.Status='Test';
        caseObj.Comments__c ='Test';
        caseObj.What_can_NCR_help_you_with_today__c='Test';
        caseList.add(caseObj);
        insert caseList;
        system.assert(caseList.size()>0);
        ExistingLeadContactHelper.leadAndContactWithEmail(caseList);
        

    }	
}