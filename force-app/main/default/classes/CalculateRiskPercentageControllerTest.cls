@isTest
public class CalculateRiskPercentageControllerTest {
    @isTest
    public static void testMethodCalculateRiskPercentageController(){
                
        Opportunity Opp = new Opportunity();                              
        Opp.Name='TestOpsads';
        Opp.StageName='Prospecting';
        Opp.CloseDate=System.today();
        insert Opp;
        Opportunity Opp1 = new Opportunity();                              
        Opp1.Name='TestOpsads1';
        Opp1.StageName='Prospecting';
        Opp1.CloseDate=System.today();
        insert Opp1;
        Value_Prompter__c VmObj= new  Value_Prompter__c(Name='ABC',Opportunity__c=opp.id);
        insert VmObj;
        Map<String,String> mapp = new Map<String,String>();
        mapp.put('Id',vmObj.Id);
        mapp.put('Power_Person_has_access_to_funds_bdgt__c', 'true');
        Mapp.put('Opportunity__c',opp.id);
        String jsonstr = '[{"Has_a_cost_justification_been_completed__c": true, "Opportunity__c":"'+opp1.id+'"}]';
             
        CalculateRiskPercentageController.UpsertRecord(jsonstr);
        Value_Prompter__c vpObj = [select id from Value_Prompter__c where Opportunity__c=:opp1.id];
        System.assert(vpObj.id!=null);
    }
}