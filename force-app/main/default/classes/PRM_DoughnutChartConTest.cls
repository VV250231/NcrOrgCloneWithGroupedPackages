@isTest
public class PRM_DoughnutChartConTest {
    
    @isTest
    public static void getDoughnutChartDataTest(){        
        //Creating an account.
        
        ChannelProgram  channelProgramRecord = new ChannelProgram();
        channelProgramRecord.Name ='Channel Program 2020';
        channelProgramRecord.IsActive = true;
        Insert channelProgramRecord;
        
        List <ChannelProgramLevel> channelProgramLevelList = new List<ChannelProgramLevel>();
        channelProgramLevelList.add(new ChannelProgramLevel(Name ='Silver',ProgramId=channelProgramRecord.Id,Rank=1));
        channelProgramLevelList.add(new ChannelProgramLevel(Name ='Platinum',ProgramId=channelProgramRecord.Id,Rank=2));
        channelProgramLevelList.add(new ChannelProgramLevel(Name ='Gold',ProgramId=channelProgramRecord.Id,Rank=3));
        Insert channelProgramLevelList;
        
        Account accountRecord = PRM_TestRecordsFactory.createPartnerAccount('Test',null); 
        //accountRecord.ChannelProgramName='Channel Program 2020';
        accountRecord.Partner_Program_Level__c='Platinum';
        accountRecord.Partner_Program_Industry__c ='RETAIL';
        accountRecord.Counterpoint__c=true;
        // accountRecord.Partner_Industry__c ='Hospitality;Financial';
        
        User accountUsere = [SELECT Id, Name FROM User WHERE Name ='Soup User' LIMIT 1];        
        System.runAS(accountUsere){
            Insert accountRecord;
        }
        
        Contact contactRecord = PRM_TestRecordsFactory.createPartnerContact(accountRecord.Id,'Test',null);
        Insert contactRecord;
        
        User portalUser = PRM_TestRecordsFactory.createPartnerUser(contactRecord.Id,'u', null);
        Insert portalUser;
        
        Insert new ChannelProgramMember(PartnerId=accountRecord.Id,ProgramId=channelProgramRecord.Id,LevelId= channelProgramLevelList[1].Id);
        
        List<Channel_Level_Revenue_Information__c> levelRevenueInformation = new List<Channel_Level_Revenue_Information__c>();
        levelRevenueInformation.add(new Channel_Level_Revenue_Information__c(Channel_Program_Level__c= channelProgramLevelList[1].Id, Industry__c='Retail', Solution__c='Counterpoint',Threshold_Revenue__c=3000000, Percent_Revenue_Net_New_Customer__c = '12' ));
        levelRevenueInformation.add(new Channel_Level_Revenue_Information__c(Channel_Program_Level__c= channelProgramLevelList[2].Id, Industry__c='Retail',Solution__c='Counterpoint', Threshold_Revenue__c=3000000, Percent_Revenue_Net_New_Customer__c = '12' ));
        Insert levelRevenueInformation;
        
        
        
        List <Partner_Revenue__c> partnerRevenueList = new List <Partner_Revenue__c>();
        partnerRevenueList.add( new Partner_Revenue__c(
            Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
            TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
            Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=4000,Partner_Account__c=accountRecord.Id, Year__c = String.valueOf(System.today().year())));
        
        Insert partnerRevenueList;
               System.assertNotEquals(partnerRevenueList, null,'partnerRevenueList should not be null');

        Test.startTest();
        PRM_DoughnutChartCon.getDoughnutChartData(accountRecord.Id); 
        Test.stopTest(); 
        
    }
    
}