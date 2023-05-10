@isTest
public class NPSScoreCalcTest {
	@isTest
    public static void accList(){
        Account ac=new Account();
        User Usr = [Select Id from User Where Name = 'Soup User'];
        System.runAs(Usr){
        ac.Name='TestNPS';
        ac.Account_Country_Code__c='A2';
        ac.MDM_Industry_Name__c='FINANACIAL:BANKING';
        insert ac;
    		} 
        Contact con = TestRecordsFactory.createContact( ac );
       	List <Survey_Result__c> npscoreList = new List<Survey_Result__c>();
        String NPS_Year  = String.valueOf(System.Today().year());
        Survey_Result__c npl = new Survey_Result__c();
        npl.Name = NPS_Year+' Testing';
        npl.NPS_Score__c = 9;
        npl.Respondent_End_Date__c= System.today();
        npl.Contact__c = con.Id;
        npl.Qualtrics_Response_ID__c = '12345';
        npscoreList.add(npl);
        insert npscoreList;
        Account accObj = [select id,NPS__c from account where id=:ac.id];
        System.assert(accObj.NPS__c==100);
    }
}