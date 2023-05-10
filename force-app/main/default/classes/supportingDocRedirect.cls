/*
*********************************************************
Apex Class Name    : supportingDocRedirect
Test Class Name    : supportingDocRedirectTest
Created Date       :  3/15/2017 11:24 AM
@author            : Shiv Mahla
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
                                                   
*********************************************************
*/
public class supportingDocRedirect {
    public String coOpId {get;set;}
    
    public supportingDocRedirect(ApexPages.StandardSetController ssc) {
        //coOpId  = apexpages.currentpage().getparameters().get('id');
        //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
         coOpId=  String.escapeSingleQuotes(apexpages.currentpage().getparameters().get('id'));
    }
    
    // Redirect to support Doc
    public PageReference redirectToNewSupportDoc() {
        PageReference pr = Page.co_op_supporting_document;
        pr.getParameters().put('coOpid',coOpId);
        return pr;
    }
}