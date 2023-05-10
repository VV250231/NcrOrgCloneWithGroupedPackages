/*
*********************************************************
Apex Class Name    : SSOErrorPageCon
Test Class Name    : SSOErrorPageConTest
Created Date       : 1/12/2017 6:15 AM
@author            : Shiv Mahla
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
19-12-2022                 Monika                           EBA_SF-2491 JDK Locale impact - Upgrade API Part 5
                                                   
*********************************************************
*/
public class SSOErrorPageCon {

  public String errorCode {get;set;}
  public String errorDetails {get;set;}
  public String errorDescription {get;set;}
  public Boolean isCaseCreated{get; set;}
  public Map<String,String> attributes = new Map<String,String>();
  //public String samlAssertion {get;set;}
  
   public SSOErrorPageCon() {
      //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
   // errorCode = ApexPages.currentPage().getParameters().get('ErrorCode');
     errorCode = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('ErrorCode'));
    //errorDetails = ApexPages.currentPage().getParameters().get('ErrorDetails');
    errorDetails = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('ErrorDetails'));
    //errorDescription = ApexPages.currentPage().getParameters().get('ErrorDescription');
      errorDescription = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('ErrorDescription'));
    //samlAssertion = SAMLHandlerUtil.samlAssertion;
  }
  public void createCase(){
   //Fetching the assignment rules on case
   // AssignmentRule AR = new AssignmentRule();
    //AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1];
    
    //Creating the DMLOptions for "Assign using active assignment rules" checkbox
    //Database.DMLOptions dmlOpts = new Database.DMLOptions();
    //dmlOpts.assignmentRuleHeader.assignmentRuleId= AR.id;
    
    Case newCase = new Case();
    newCase.Type='Problem';
    newCase.Origin='IPT SSO';
    newCase.Status='New';
    newCase.Priority='High';
    newCase.Description = 'Error has occured to user while login in to Partner Community.'+'\r\n'+
                          + 'errorCode = ' + errorCode +'\r\n'+
                          + 'errorDetails = ' + errorDetails +'\r\n'+
                          + 'errorDescription = ' + errorDescription +'\r\n';
    //if (! String.isBlank(SAMLHandlerUtil.samlAssertion)) {
        //newCase.Description +='\r\n'+'SAML Assertion = '+ samlAssertion ;
    //}
    //if (AR.Id != null) {
       // system.debug('*****');
      //  newCase.setOptions(dmlOpts);
    //}
    insert newCase;
    isCaseCreated = true;
  }
}