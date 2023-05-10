/*
*********************************************************
Apex Class Name    : dispatcherMDFviewCon
Test Class Name    : dispatcherMDFviewConTest
Created Date       : 1/12/2017 6:15 AM
@author            : Shiv Mahla
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
18-12-2022                 Monika                           EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                                                   
*********************************************************
*/
public class dispatcherMDFviewCon {
    public dispatcherMDFviewCon(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference getRedir() {
        PageReference pr;
       // String id = ApexPages.currentPage().getParameters().get('id');
       //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
      String id = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
        //Changes done by Yogesh - related to Story EBA_SF-1919
        Id profId= NSCCommonInfoUtil.getIdOf('dispClmnPrflId');  // Used same metadata in dispatcherClaimViewCon apex class
       	// if(UserInfo.getProfileId() == '00e70000000k6DGAAY')
        if(UserInfo.getProfileId() == profId) { //End Changes 
            pr = Page.mdfRequestView;
            pr.getParameters().put('id', id);
        } else {
            pr = new PageReference('/' + id);
            pr.getParameters().put('nooverride', '1');
        }
        return pr.setRedirect(true);
    }
    
    private final ApexPages.StandardController controller;
}