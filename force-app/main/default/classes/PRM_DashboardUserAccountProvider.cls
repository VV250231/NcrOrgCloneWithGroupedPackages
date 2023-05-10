public class PRM_DashboardUserAccountProvider {
    @AuraEnabled(cacheable=true)
    public static String getCurrentPartnerAccount(){
        Contact[] c = [SELECT AccountId FROM Contact WHERE Partner_User__c != NULL AND 
                       Partner_User__c =: UserInfo.getUserId() LIMIT 1]; // WHERE Partner_User__c != NULL AND Partner_User__c =: UserInfo.getUserId() LIMIT 1
        if(c.size()>0 && c[0].AccountId != NULL){
            return c[0].AccountId;
        }else{
            return NULL;
        }
    }
 @AuraEnabled(cacheable=true)
    public static Boolean dashboardVisibility(){
        String accountId = PRM_DashboardUserAccountProvider.getCurrentPartnerAccount();
        Account accRecord = [SELECT ISO_Country_Code__c, Partner_Program_Industry__c, Account_Region__c FROM Account WHERE Id =:accountId];
        //Commenting due to EBA_SF-1435
      /*  if(accRecord != NULL){
            if(accRecord.Partner_Program_Industry__c == 'Hospitality' && accRecord.ISO_Country_Code__c == 'US'){
               return false; 
            }else {
                return true;
            }
        }
    else{
            return false;
        }*/
        return true;
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getAccountListforCams(){
        List<Account> CAMAccountList = [SELECT Id, Name FROM Account WHERE OwnerId =: System.UserInfo.getUserId() AND 
                                        RecordType.Name ='Partner'];
        system.debug('CAMAccountList:------->'+CAMAccountList);
        if(!CAMAccountList.isEmpty()){
            return CAMAccountList;
        }else{
            return NULL;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<User> getOwnedUsers(){
        List<User> CAMList = [SELECT Id, Name FROM USER WHERE ManagerId =: System.UserInfo.getUserId()];
        if(!CAMList.isEmpty()){
            system.debug('CAMListCAMListCAMListCAMList----> '+CAMList);
            return CAMList;
        }else{
            return NULL;
        }
    }
    
    @AuraEnabled(cacheable = true)
    public static List<Account> getOwnedAccounts(String SelectedAcId){
        List<Account> CAMAccountList = [SELECT Id, Name FROM Account WHERE OwnerId =: SelectedAcId AND 
                                        RecordType.Name ='Partner'];
        system.debug('CAMAccountList:------->'+CAMAccountList);
        if(!CAMAccountList.isEmpty()){
            return CAMAccountList;
        }else{
            return NULL;
        }
    }

    @AuraEnabled(cacheable=true)
    public static DashboardVisibility getDashboardVisibility(){  
         String currentYear = System.Today().year()+'';
        
        //Contact contactRecord = [SELECT Account.Partner_Program_Industry__c, Account.ISO_Country_Code__c ,Partner_User__r.Tier_attainment_annual_revenue__c, Partner_User__r.Percent_revenue_net_new_customers__c, Partner_User__r.Growth_reward_gold_and_platinum_only__c, Partner_User__r.Market_development_funds_MDF__c FROM Contact WHERE Partner_User__c != NULL AND Partner_User__c =: UserInfo.getUserId() LIMIT 1];
        
        DashboardVisibility dashboardVisibilityInfo = new DashboardVisibility();
        
        User[] userRecord  =  [Select Id,Name, ContactId, Contact.AccountId , Tier_attainment_annual_revenue__c, Percent_revenue_net_new_customers__c, Growth_reward_gold_and_platinum_only__c, Market_development_funds_MDF__c FROM User Where Id = :UserInfo.getUserId() LIMIT 1];
        if (userRecord.size() > 0) {
            dashboardVisibilityInfo.userRecord = userRecord[0];
            if(userRecord[0].Contact.AccountId != null){
                Account[]  accountRecord = [SELECT Id, Name, Partner_Program_Industry__c, ISO_Country_Code__c, Account_Region__c, LOB__c FROM Account WHERE Id = :userRecord[0].Contact.AccountId ];
                dashboardVisibilityInfo.accountRecord = accountRecord[0];
                //1518
             Partner_Revenue__c [] prmrevrecord  = [Select id,Subscription_Sites__c, Traditional_Sites__c from Partner_Revenue__c where Partner_Account__c =:userRecord[0].Contact.AccountId AND Year__c =:currentYear];
                if(!prmrevrecord.isempty()){
                dashboardVisibilityInfo.prmrevrecord = prmrevrecord[0];
                }
                
             try{
                 User[] usrPrfl = [Select id, ProfileId from User where ProfileId IN: Label.HOSPSMB.split(',') AND Id = :UserInfo.getUserId()];
                 if(!usrPrfl.isempty()){
                dashboardVisibilityInfo.usrPrfl = usrPrfl[0];
                }
             }
                catch (Exception  e){
                    dashboardVisibilityInfo.usrPrfl = null;
                } 
            }
        }
        
        return dashboardVisibilityInfo;
    }

   public class DashboardVisibility{
        @AuraEnabled       
        public User userRecord;
        
        @AuraEnabled
        public Account accountRecord;
       //1518
       @AuraEnabled
       public Partner_Revenue__c prmrevrecord; 
       //1518
      @AuraEnabled
      public User usrPrfl;
       
    }

}