public class IncentiveProgramListCon {
  
  public list<SelectOption> incentivePrograms {get;set;}
  public String selectedProgram {get;set;}
  public Account partAct {get;set;}
  public String partActId {get;set;}
  public User currentUser {get;set;}
  public Boolean validPartnForOptIn {get;set;}
  public String validateMessage {get;set;}
  
  public IncentiveProgramListCon () {
  
      validPartnForOptIn = true;      
      List<User> users = [SELECT Id, Name, UserName, AccountId, ContactId FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
      if (users.size() > 0) {
          currentUser = users[0];
          partActId = users[0].AccountId;
      }
      
      if (partActId != null) {
          List<Account> accounts = [SELECT Id, LOB__c,Partner_Industry__c, Master_Customer_Number__c, Account_Region__c, Partner_Program_Level__c FROM Account WHERE Id =: partActId LIMIT 1];
          if (accounts.size() > 0) {
              partAct = accounts[0];
          }
      }
     // List<String> allowedLOB = new List<String>();
     // allowedLOB.add('RETAIL');
     String allowedLOB='Retail';
      
      Set<String> allowedRegions = new Set<String>();
      allowedRegions.add('EMEA');
      allowedRegions.add('EUROPE');
      allowedRegions.add('MEA');
      
      Set<String> allowedPartnerLevels = new Set<String>();
      allowedPartnerLevels.add('ADVANCED');
      allowedPartnerLevels.add('PREMIER');
      allowedPartnerLevels.add('ELITE');
     
      if (!partAct.Partner_Industry__c.contains(allowedLOB) || !allowedRegions.contains(partAct.Account_Region__c)) {
          validPartnForOptIn = false;
          validateMessage = 'You do not have any Incentive programs available at the moment. Please visit us back.';
      }
      
      incentivePrograms = new List<SelectOption>();
      incentivePrograms.add(new SelectOption('null','Please Select'));
      
      String partnerlevel = partAct.Partner_Program_Level__c;
      if (partAct != null && Incentive_All_Program_Config__c.getInstance('IncentiveProgram') != null
          && Incentive_All_Program_Config__c.getInstance('IncentiveProgram').Partner_Levels_for_Quarterly_Incentive__c != null
          &&  (new set<String> (Incentive_All_Program_Config__c.getInstance('IncentiveProgram').Partner_Levels_for_Quarterly_Incentive__c.split(','))).contains(partnerlevel.toUpperCase())) {
          
          incentivePrograms.add(new SelectOption('Quarterly Sales Incentive','Quarterly Sales Incentive'));
          
       }  
       
       if (partAct != null && Incentive_All_Program_Config__c.getInstance('IncentiveProgram') != null
          && Incentive_All_Program_Config__c.getInstance('IncentiveProgram').Partner_Levels_for_Annual_Incentive__c!= null
          &&  (new set<String> (Incentive_All_Program_Config__c.getInstance('IncentiveProgram').Partner_Levels_for_Annual_Incentive__c.split(','))).contains(partnerlevel.toUpperCase())) {
           incentivePrograms.add( new SelectOption('Annual Quota Incentive','Annual Quota Incentive'));
           
       } 
       
       if (! (incentivePrograms.size() > 1)){
           validPartnForOptIn = false;
           validateMessage = 'You do not have any available incentives at this time. Please check back in the future.';
       }
      
  }
  
  public PageReference next() {
      PageReference pr;
      if(selectedProgram == 'null') {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please Select an Incentive Program.'));
          return null;
      }
      
      if(selectedProgram == 'Quarterly Sales Incentive') {
          pr = Page.QuarterlySalesIncentive;
          pr.getParameters().put('id','Quarterly Sales Incentive');
      } else if (selectedProgram == 'Annual Quota Incentive') {
          pr = Page.Incentive_Program_Annual;
          pr.getParameters().put('id','Annual Quota Incentive');
      }
      
      return pr;
      
  }
}