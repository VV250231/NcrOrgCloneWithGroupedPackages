/*
*********************************************************
Apex Class Name    : incentPrgSuccessMessageCon
Test Class Name    : incentPrgSuccessMessageConTest
Created Date       : 2/9/2017 5:09 AM
@author            : Shiv Mahla
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
                                                   
*********************************************************
*/
public class incentPrgSuccessMessageCon {
    public incentPrgSuccessMessageCon() {
        //String message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
        //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
        String message = String.escapeSingleQuotes('' + ApexPages.CurrentPage().GetParameters().Get('message'));
        //String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer');
        String pageHeaderReferer = String.escapeSingleQuotes(ApexPages.currentPage().getHeaders().get('Referer')); 
    
        // Use the referrer parameter to only show the message when coming from right page.
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('Incentive') && message != 'null') {
          ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message)); 
        }
    }
}