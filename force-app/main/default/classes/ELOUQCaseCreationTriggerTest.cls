@isTest
public class ELOUQCaseCreationTriggerTest {
    @isTest 
    private static void testInsertMethod(){
        Contact con = new Contact(Lastname ='Test', Email='test@test.com');
        insert con;
        List<Eloqua_Form__c> eloquaFormList= new List<Eloqua_Form__c>();
        Eloqua_Form__c eloquaFormObj = new Eloqua_Form__c();
        eloquaFormObj.First_Name__c ='Test';
        eloquaFormObj.Last_Name__c = 'Test';
        eloquaFormObj.Company__c = 'Test';
        eloquaFormObj.Country__c = 'Test';
        //eloquaFormObj.Industry__c = 'Test';
        eloquaFormObj.Campaign_Type__c = 'Test';
        eloquaFormObj.Campaign_Code__c = 'Test';
        eloquaFormObj.Campaign_Name__c= 'Test';
        eloquaFormObj.Campaign_Status__c = 'Test';
        eloquaFormObj.Campaign_Start_Date__c =System.today();
        eloquaFormObj.Campaign_End_Date__c = System.today();
        eloquaFormObj.State_Province__c = 'Test'; 
        eloquaFormObj.City__c = 'Test';
        eloquaFormObj.Business_Function__c ='Test';
        eloquaFormObj.Case_Origin__c ='Form';
        eloquaFormObj.Eloqua_Form_Sub_Name__c = 'Test';
        eloquaFormObj.Email_Address__c = 'test@test.com';
        eloquaFormObj.Form_Submit_URl__c = 'Test';
        eloquaFormObj.Source__c = 'Test';
        eloquaFormObj.Referring_Source__c = 'Test';
        eloquaFormObj.Zip_Or_Postal_Code__c = 'Test';
        eloquaFormObj.Sub_Industry__c = 'Test';
        eloquaFormObj.What_can_NCR_help_you_with_today__c = 'Test';
        eloquaFormObj.Title__c = 'Test';
        eloquaFormObj.Comments__c = 'Test';  
        eloquaFormObj.Business_Phone__c = 'Test';
        eloquaFormObj.SFDC_Contact_ID__c = con.id;
       // eloquaFormObj.SFDC_Lead_ID__c = ;
        eloquaFormList.add(eloquaFormObj);     
        Test.startTest();
		insert eloquaFormList;
        system.assert(eloquaFormList.size()>0);
        system.assertEquals(eloquaFormObj.City__c,'Test');
        Test.stopTest();
    }
}