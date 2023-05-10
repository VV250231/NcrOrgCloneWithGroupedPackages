/*
*********************************************************
Apex Class Name    : OpportunityViewController
Test Class Name    : OpportunityViewControllerTest
Created Date       :  1/10/2019 12:38 AM
@author            : Puneet Bhatia
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
Date                       Modified by                      Modification
1/20/2022 3:00 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
*********************************************************
*/
public with sharing class OpportunityViewController{
  
  public String SelectelValue{get;set;}
  Public List<Opportunity> OpportunityList{get;set;}
  Public String AccountId{get;set;}
  public String soqlQuery='';  
  public Boolean stage=true;  
  
  Public List<SelectOption> OptionValue{
  get{
          
           OptionValue = new List<SelectOption>();
           OptionValue.add(new SelectOption('THIS_QUARTER','Current Quarter Opportunities'));
           OptionValue.add(new SelectOption('NEXT_QUARTER','Next Quarter Opportunities'));
           OptionValue.add(new SelectOption('THIS_YEAR','Current Year Opportunities'));
           OptionValue.add(new SelectOption('Previous_Year_Closed_Opportunity','Previous Year Closed Opportunities'));
           OptionValue.add(new SelectOption('Total_Closed_Opportunity','Total Closed Opportunities'));
           OptionValue.add(new SelectOption('All_Lost_Opportunity','Lost Opportunities'));
          return OptionValue;
     }
     
   set;}
  
  public OpportunityViewController(ApexPages.StandardSetController controller){
      if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))) {
          //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
          //AccountId= ApexPages.currentPage().getParameters().get('id');
          AccountId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
      }
      //system.debug('><><><><'+SelectelValue); 
      if(String.isBlank(SelectelValue)){
         OpportunityList=new List<Opportunity>();           
          SelectelValue='THIS_QUARTER';
          stage=false;
          soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = false AND Accountid= : AccountId AND CloseDate = THIS_QUARTER limit 10000';
      }
      //system.debug('soqlQuery'+soqlQuery);
      for(Opportunity OppOj :database.query(String.escapeSingleQuotes(soqlQuery)) )
      {
      
        OpportunityList.add(OppOj); 
      }
  
  }
      
   
 public PageReference GetFilterOpportunity(){
 
  OpportunityList=new List<Opportunity>();
  
  
  
  if(SelectelValue.equals('THIS_QUARTER')){
    stage=false;
     SelectelValue='THIS_QUARTER';
   
       soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = false AND Accountid= : AccountId  AND CloseDate = THIS_QUARTER  Order by Amount Desc limit 10000';
      //soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed =' + stage + ' AND Accountid='+'\''+AccountId+'\'' +' AND CloseDate =' + SelectelValue + ' Order by Amount Desc limit 10000';
  }
     
     else if( SelectelValue.equals('NEXT_QUARTER')){
         stage=false;
         SelectelValue='NEXT_QUARTER';
         
         soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = false AND Accountid= : AccountId  AND CloseDate = NEXT_QUARTER  Order by Amount Desc limit 10000';
         //soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed =' + stage + ' AND Accountid='+'\''+AccountId+'\'' +' AND CloseDate =' + SelectelValue + ' Order by Amount Desc limit 10000';
     }
     
     else if( SelectelValue.equals('THIS_YEAR')){
         stage=false;
         SelectelValue='THIS_YEAR';
         
         soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = false AND Accountid= : AccountId  AND CloseDate = THIS_YEAR  Order by Amount Desc limit 10000';
         //soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed =' + stage + ' AND Accountid='+'\''+AccountId+'\'' +' AND CloseDate =' + SelectelValue + ' Order by Amount Desc limit 10000';
     }
     
     
     else if(SelectelValue.equals('Previous_Year_Closed_Opportunity')){
         stage=true;
         soqlQuery = 'select id,AccountId,StageName,name,Amount,CloseDate,Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = true AND Accountid= : AccountId  AND CloseDate = LAST_YEAR  Order by Amount Desc limit 10000';
         //soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE isClosed ='+stage+' AND Accountid='+'\''+AccountId+'\'' +' AND CloseDate = LAST_YEAR Order by Amount Desc limit 10000';
     }
     
     
  
  else if(SelectelValue.equals('Total_Closed_Opportunity')){
      stage=true;
      
soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE IsClosed = true AND Accountid= : AccountId Order by Amount Desc limit 10000';
  }
  
else if(SelectelValue.equals('All_Lost_Opportunity')) {
         string stagename='Closed/Lost';
         soqlQuery = 'select id,name,AccountId,StageName,Amount,CloseDate,Opportunity.Account.Name,ForecastCategoryName from Opportunity WHERE Accountid= : AccountId  AND StageName=:stagename Order by Amount Desc limit 10000';
     }
 
  
  for(Opportunity OppOj :database.query(String.escapeSingleQuotes(soqlQuery)) )
  {
      
      OpportunityList.add(OppOj); 
  }
  return null;
 }      
}