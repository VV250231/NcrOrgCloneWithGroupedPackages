/*##################################################################################################
# File..................: AllowAccountToAdmin.cls                                                        
# Version...............: 38.0 
# Created by............: Mudit Saxena
# Created Date..........: 11-02-2016                                                                               
# Last Modified by......: Mudit Saxena
# Last Modified Date....: 11-02-2016                                                                               
# Description...........: This class is used to allow admins to access New Account Functionality
################################################################################################*/

public with sharing class AllowAccountToAdmin {
    
    public static Set<String> alwdPrfl = new Set<String>{'Soup Integration'}; 
    public static Set<String> alwdGrp = new Set<String>{ 'Account Admin' };
    List<string> grpName = new List<string>();
    //public static Set<String>allowedProfile = new Set<String>{ '01 GS Admin','02 NSC Administrator','03 PRM Admin','04 NSC UI Administrator','System Administrator' };
    
    public string selRecTypeID{get;set;}
    
    public AllowAccountToAdmin( ApexPages.StandardController controller ){        
        selRecTypeID = ApexPages.currentPage().getParameters().get('RecordType');        
    }
      
    public boolean getislightningView(){
        String Theme = UserInfo.getUiThemeDisplayed();
        return ((Theme == 'Theme4d' || Theme == 'Theme4t')  ? true : false);
    }
    
    
    public boolean getisAllowedView(){
        String prflName = [SELECT name FROM profile WHERE id =:UserInfo.getProfileId() LIMIT 1 ].Name;
        for(GroupMember m : [select group.name from GroupMember where UserOrGroupId = :UserInfo.getUserId() AND group.name IN: alwdGrp]){
            grpName.add(m.group.name);
        }
        return ((alwdPrfl.Contains( prflName ) || grpName.size()>0) ? true : false);
    }
    
    public string getErrorMsg(){
        //return 'You are not authorized to create an account in NSC.For ERP Country, create the account in CWEB. For Non-ERP country, request for new Account through the "Account Request" tab in NSC. ';
    return 'You are not authorized to create an account in NSC. Please raise Account creation request through Customer Portal';
    }
    
    
}