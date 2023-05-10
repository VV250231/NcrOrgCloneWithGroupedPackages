/* Class Name : prmHorizontalBarChartController 
* Date : 10/09/19 
* Description : This Class  is used in Partner Portal for displaying Net New Customer partner revenue under 2020 Program
* DeveloperName : Deeksharth Sriwastava
*/
public without sharing class prmHorizontalBarChartController {
    public static List<Account> userAccountDetails = new List<Account>();
    /*This method returns the partner revenue Data for current year */
    @AuraEnabled(cacheable = true)
    public static Partner_Revenue__c getPartnerInfo(String accId){
        /*if(userAccountDetails.isEmpty()) Commenting to enable the class to accept accountid from parent component.
            userAccountDetails = prmGenericDataHelper.getCurrentUserAccountData();*/
        system.debug('Id RECIEVED: - - - - >');
        Partner_Revenue__c pRevenue = new Partner_Revenue__c();
        if(accId != NULL){
            pRevenue =[SELECT Id, Total_Solution_Revenue__c, Solution_from_Net_New_Customers__c, 
                   Percent_of_Total_Rev_Net_New_Cust__c,Revenue_to_Target__c FROM Partner_Revenue__c WHERE Year__c =: String.valueOf(System.today().year())
                   AND Partner_Account__c =: accId LIMIT 1];
        }
        if(pRevenue != NULL){
            return pRevenue;
        }
        return new Partner_Revenue__c();
    }
    /*This method returns the channel partner Data from ChannelProgramLevel */
    @AuraEnabled(cacheable = true)
    public static List<String> getChannelPartnerInfo(){
        List<ChannelProgramLevel> channelPartnerLst = new List<ChannelProgramLevel>();
        List<String> prcntRevenueList = new List<String>();
        channelPartnerLst  = prmHorizontalBarChartController.getpartnerLevelData();
        if(channelPartnerLst.size()>0){
            for(ChannelProgramLevel obj :   channelPartnerLst){
                if(!String.isBlank(obj.Percent_Revenue_Net_New_Customer__c))
                    prcntRevenueList.add(obj.Percent_Revenue_Net_New_Customer__c);
            }
           if(prcntRevenueList.size()>0)
               return prcntRevenueList;
        }
        return new List<String>();
    }
      /*This method returns channel partner program Data*/
    public static List<ChannelProgramLevel> getpartnerLevelData(){
        List<ChannelProgramLevel> channelPartnerDataLst = new List<ChannelProgramLevel>();
        channelPartnerDataLst =[SELECT Id,Name,Percent_Revenue_Net_New_Customer__c FROM ChannelProgramLevel WHERE (Name = 'Silver' Or Name = 'Gold' or Name = 'Platinum' ) ORDER BY Rank ASC limit 3];
        if(channelPartnerDataLst.size()>0)
            return channelPartnerDataLst;

        return new List<ChannelProgramLevel>();
    }
}