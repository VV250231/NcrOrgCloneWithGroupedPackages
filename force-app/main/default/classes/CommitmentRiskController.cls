/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/

public class CommitmentRiskController {    
    Public CommitmentRiskController(){
     System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement      
    }    
    @AuraEnabled 
    Public Static List<SectionWrapper> GetCommitmentRiskCustomMetaDataValues(String OppId){
        String SobjectApiName = 'Value_Prompter__c' , commaSepratedFields = '';
    
        List<CommitmentRiskSection__mdt> CustomMetaDataValues = [SELECT Label,YesOrNo__c,Question_weightage__c,Section_Name__c,SectionqQuestion__c FROM CommitmentRiskSection__mdt];
        Map<String,List<CommitmentRiskSection__mdt>> MapofRiskSeaction = new Map<String,List<CommitmentRiskSection__mdt>>();
        List<SectionWrapper> SectionListWithQuestion = new List<SectionWrapper>();
        for(CommitmentRiskSection__mdt MetadataObj : CustomMetaDataValues){
            
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = MetadataObj.Section_Name__c; 
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + MetadataObj.Section_Name__c;
            } 
            if(String.isNotBlank(MetadataObj.Label) && !MapofRiskSeaction.containsKey(MetadataObj.Label)){
               MapofRiskSeaction.put(MetadataObj.Label, new List<CommitmentRiskSection__mdt>()); 
           }
            MapofRiskSeaction.get(MetadataObj.Label).add(MetadataObj); 
        }
        
        Opportunity OppObj = [Select id,(Select Id from Value_Prompter__r),Name from Opportunity where Id =:OppId][0];
        
        string query='Select Id ,' + commaSepratedFields +' '+'from'+' '+ SobjectApiName+ ' ' +' WHERE Opportunity__c = : OppId  Limit 1' ;
        //system.debug('>>>>>>>>>>>>>>'+ Database.query(query));
        Value_Prompter__c ValuePrompterObj = new Value_Prompter__c();
       
        if(OppObj.Value_Prompter__r.Size()>0 ){
           
            ValuePrompterObj=Database.query(String.escapeSingleQuotes(query));
           // list<Value_Prompter__c> ValuePrompterObj1 = Database.query(String.escapeSingleQuotes(query));
             //system.debug('size::'+ValuePrompterObj1.size());
        } 
        
        
        for(String KeyValues : MapofRiskSeaction.KeySet()){
            SectionWrapper SectionObj= new SectionWrapper();
            SectionObj.SeactionName=KeyValues;
            List<SectionQuestionWrapper> SectionValuesList = new List<SectionQuestionWrapper>();
            Decimal SectionWeightage=0.0;
            Decimal SectionWeightageIfTrue=0.0;
            for(CommitmentRiskSection__mdt mdtObj : MapofRiskSeaction.get(KeyValues)){
                SectionQuestionWrapper SectionValues = new SectionQuestionWrapper();
                SectionValues.SectionQuestion= mdtObj.SectionqQuestion__c;
                SectionValues.QuestionWeightage=mdtObj.Question_weightage__c;
                String SectionApi=mdtObj.Section_Name__c;

                if(OppObj.Value_Prompter__r.Size()>0 && (Boolean) ValuePrompterObj.get(mdtObj.Section_Name__c)){
                    SectionValues.ifYes= (Boolean) ValuePrompterObj.get(mdtObj.Section_Name__c);
                    SectionValues.ifNo=false;
                    SectionWeightageIfTrue=SectionWeightageIfTrue+mdtObj.Question_weightage__c;
                }
                else{
                       SectionValues.ifYes= false;
                       SectionValues.ifNo=true;   
                }
                            
                SectionValuesList.add(SectionValues);
                SectionWeightage=SectionWeightage+mdtObj.Question_weightage__c;
                SectionValues.SectionApiName=mdtObj.Section_Name__c;
                
            }
            
                if(ValuePrompterObj.get('Id') != ''){
                    SectionObj.RecordId=(String) ValuePrompterObj.get('Id');
                }
                
                else {
                    SectionObj.RecordId=''; 
                }
            SectionObj.RecordsValue=SectionValuesList;
            SectionObj.SectionWeightage=SectionWeightage;
            SectionObj.SectionWeightageIfyes=SectionWeightageIfTrue;
            SectionObj.Result=(SectionWeightageIfTrue/SectionWeightage)*100;
            SectionListWithQuestion.add(SectionObj);
        }
        
        return SectionListWithQuestion; 
    }

      Public class SectionWrapper{
         
          @AuraEnabled Public String SeactionName {get;set;}
          @AuraEnabled Public Decimal SectionWeightage{get;set;}
          @AuraEnabled Public List<SectionQuestionWrapper> RecordsValue{get;set;} 
          @AuraEnabled Public Decimal SectionWeightageIfyes {get;set;}
          @AuraEnabled Public Decimal Result {get;set;} 
          @AuraEnabled Public String RecordId {get;set;}
          
          
          
      }
    
     Public Class SectionQuestionWrapper{
         @AuraEnabled Public String SectionQuestion {get;set;}
         @AuraEnabled Public Boolean ifYes {get;set;}
         @AuraEnabled Public Boolean ifNo {get;set;}
         @AuraEnabled Public Decimal QuestionWeightage{get;set;}
         @AuraEnabled Public String SectionApiName{get;set;}
         @AuraEnabled Public Value_Prompter__c ValuePrompterObj {get;set;}
         @AuraEnabled Public Boolean toggleSpinner {get;set;}
     }
}