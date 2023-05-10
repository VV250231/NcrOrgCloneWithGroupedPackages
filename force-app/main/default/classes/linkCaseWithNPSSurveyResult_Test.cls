@isTest
public class  linkCaseWithNPSSurveyResult_Test  {
    @testsetup static void testData(){
        All_profie_config__c a = new All_profie_config__c();
        a.Name = 'CCAD Service Ignored Profile';
        a.Profile_Id__c ='test';
        insert a;
    }
    @isTest static void InsertSurveyFor() {
        
        //Account AccObj = TestRecordsFactory.createAccount('122002','FINANCIAL','EMEA');
        Account AccObj =  TestRecordsFactory.createAccount();
        contact conObj = TestRecordsFactory.createContact(AccObj);
        Survey_Result__c SurveyResultObj = new Survey_Result__c();
        SurveyResultObj.Name='Test Voc Survey';
        SurveyResultObj.Contact__c=conObj.id;
        SurveyResultObj.NPS_Score__c=8;
        SurveyResultObj.Immediate_Issues_Concerns__c='No';
        SurveyResultObj.Qualtrics_Response_ID__c='Qual_123';
        
        insert SurveyResultObj; 
		accObj.Industry = 'T&T:TECHNOLOGY';
        //AccObj.LOB__c='T&T';
        System.runas(TestRecordsFactory.getUser()){
        	Update  AccObj; 
        }
        System.debug('Account LOB'+[Select id,LOB__c from account where id=:accObj.id].LOB__c);
        Survey_Result__c SurveyResultObj1 = new Survey_Result__c();
        SurveyResultObj1.Name='Test Voc Survey';
        SurveyResultObj1.Contact__c=conObj.id;
        SurveyResultObj1.NPS_Score__c=5;
        SurveyResultObj1.Immediate_Issues_Concerns__c='Yes';
        SurveyResultObj1.Qualtrics_Response_ID__c='Qual_124';
       	insert SurveyResultObj1;
        test.startTest();
        AccObj.LOB__c='Other';
        Update  AccObj; 
        Survey_Result__c SurveyResultObj2 = new Survey_Result__c();
        SurveyResultObj2.Name='Test Voc Survey';
        SurveyResultObj2.Contact__c=conObj.id;
        SurveyResultObj2.NPS_Score__c=7;
        SurveyResultObj1.Immediate_Issues_Concerns__c='Yes';
        SurveyResultObj2.Qualtrics_Response_ID__c='Qual_125';
        insert SurveyResultObj2;
        Account AccObj1 =  TestRecordsFactory.createAccount('testing');
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = AccObj1.id, UserId = UserInfo.getUserId(), TeamMemberRole = 'Customer Success Manager');
        insert accTeamMember;
        
        contact conObj1 = TestRecordsFactory.createContact(AccObj1);
        case CaseObj = new Case();
       
        CaseObj.Status='New';
        CaseObj.AccountId=AccObj1.Id;
        CaseObj.ContactId=conObj1.Id;
        CaseObj.Type='Immediate';
        CaseObj.Subject='Immediate Alert';
        CaseObj.RecordTypeId=Schema.SObjectType.Case.getRecordTypeInfosByName().get('Close the Loop').getRecordTypeId();
        insert caseObj;        
        CaseObj.Case_Close_Reason__c='No Fx Action(s) Required';
        CaseObj.Status  = 'Closed';
        
        update caseObj;

        LinkCaseWithNPSSurveyResultHandler.GetMapOfFunctionalAreaAndLob();
        System.assert([Select id from Case where Survey_Result__c=:SurveyResultObj1.id].id!=null);
        test.stopTest();
        //datetime.newInstance(2014, 9, 15, 12, 30, 0); 
        //Schema.SObjectType.account.getRecordTypeInfosByName().get('person').getRecordTypeId()       
    }
}