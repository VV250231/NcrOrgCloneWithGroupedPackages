/*
##################################################################################################
# Class Name............................:dispatcherClaimViewCon.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class dispatcherClaimViewCon {
    public dispatcherClaimViewCon(ApexPages.StandardController controller) {
        this.controller = controller;
    }
    
    public PageReference getRedir() {
        String id = ApexPages.currentPage().getParameters().get('id');
        SFDC_MDF_Claim__c claim = new SFDC_MDF_Claim__c();
        List<SFDC_MDF_Claim__c> claimList = [SELECT Id, Name,Fund_Request__c FROM SFDC_MDF_Claim__c WHERE Id =: id LIMIT 1];
        if (claimList.size() > 0) {
            claim = claimList[0];
        }
        PageReference pr;
        //Changes done by Yogesh - related to Story EBA_SF-1919
        Id pROFId= NSCCommonInfoUtil.getIdOf('dispClmnPrflId'); // Used same metadata in dispatcherMDFViewCon apex class
      // if(UserInfo.getProfileId() == '00e70000000k6DGAAY')
      
        if(UserInfo.getProfileId() == pROFId) { //End Changes
            pr = Page.mdfRequestView;
            pr.getParameters().put('id', claim.Fund_Request__c);
        } else {
            pr = new PageReference('/' + id);
            pr.getParameters().put('nooverride', '1');
        }
        return pr.setRedirect(true);
    }
    
    private final ApexPages.StandardController controller;
}