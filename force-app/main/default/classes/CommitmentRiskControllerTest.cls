@isTest
public class CommitmentRiskControllerTest {
    @isTest private static void testMethodGetCommitmentRiskCustomMetaDataValues(){        
        List<Opportunity> opps = new List<Opportunity>();              
        // For each account just inserted, add opportunities                
        opps.add(new Opportunity(Name='Opportunity',
                                 StageName='Prospecting',
                                 CloseDate=System.today().addMonths(1)
                                ));
        
        insert opps;
        List<Value_Prompter__c> valuePrompterList = new List<Value_Prompter__c>();
        valuePrompterList.add(new Value_Prompter__c(Name='Value',                                             
                                                    Opportunity__c=opps[0].id));
        insert valuePrompterList;
        CommitmentRiskController.SectionQuestionWrapper secWrpClass = new CommitmentRiskController.SectionQuestionWrapper();        
        List<CommitmentRiskController.SectionQuestionWrapper> SectionValuesList = new List<CommitmentRiskController.SectionQuestionWrapper>();        
        secWrpClass.ifYes= true;
        secWrpClass.QuestionWeightage=20;
        secWrpClass.SectionApiName='ABC';
        secWrpClass.SectionQuestion='AAA';
        secWrpClass.toggleSpinner=true;
        secWrpClass.ValuePrompterObj = valuePrompterList[0];
        SectionValuesList.add(secWrpClass);        
        CommitmentRiskController.SectionWrapper secWrp = new CommitmentRiskController.SectionWrapper();
        secWrp.SeactionName='ABC';
        secwrp.SectionWeightage= 20;
        secwrp.RecordsValue = SectionValuesList;
        secwrp.SectionWeightageIfyes =20;
        test.startTest();     
        List<Opportunity> oppList= [SELECT name,id,(Select id from Value_Prompter__r) FROM Opportunity Where Name = 'Opportunity'];   
         System.assertNotEquals(oppList, null,'Opportunty with Opportunity Name not found '); 
        CommitmentRiskController.GetCommitmentRiskCustomMetaDataValues(oppList[0].id);
        test.stopTest();     
        
    }
}