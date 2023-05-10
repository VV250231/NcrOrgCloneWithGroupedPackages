@isTest
public class ChannelProgramTest {
    @isTest
    public static void testChannelProgram() {
        // Create Partner Account
        List<Account> accountList = new List<Account>();
        User u01 = TestRecordsFactory.getUser();
        System.runAs(u01){
        accountList.add(PRM_TestRecordsFactory.createPartnerAccount(null,null));
        accountList.add(PRM_TestRecordsFactory.createPartnerAccount('1',null));
        insert accountList;
        }
        Account partner = accountList[0];
        Account partner1 = accountList[1] ;
       
        // Create Partner Contact
        List<Contact> contactList = new List<Contact>();
        contactList.add(PRM_TestRecordsFactory.createPartnerContact(partner.Id, '1', null));
        contactList.add(PRM_TestRecordsFactory.createPartnerContact(partner1.Id, '2', null));
        insert contactList;
        Contact partnerContact = contactList[0];
        Contact partnerContact1 = contactList[1];
        // Create Partner User
        User u = PRM_TestRecordsFactory.createPartnerUser(partnerContact.Id, '1', null);
        insert u;
        User u1 = PRM_TestRecordsFactory.createPartnerUser(partnerContact1.Id, '2', null);
        insert u1;
        // Create Channel Program
        ChannelProgram cp = PRM_TestRecordsFactory.createChannelProgram('Channel Program 20-20', null, null);
        insert cp;
        // Create Channel Program Levels
        List<ChannelProgramLevel> ChannelProgramLevels = new List<ChannelProgramLevel>();
        ChannelProgramLevel silver = PRM_TestRecordsFactory.createChannelProgramLevel('Silver', cp.Id, null, 1, null) ;
        ChannelProgramLevel gold = PRM_TestRecordsFactory.createChannelProgramLevel('Gold', cp.Id, null, 2, null) ;
        ChannelProgramLevel platinum = PRM_TestRecordsFactory.createChannelProgramLevel('Platinum', cp.Id, null, 3, null) ;
        ChannelProgramLevels.add(silver);
        ChannelProgramLevels.add(gold);
        ChannelProgramLevels.add(platinum);
        if (ChannelProgramLevels.size() > 0) insert ChannelProgramLevels;
        
        // Create Channel Program Revenue information
        List<Channel_Level_Revenue_Information__c> revInformationLst = new List<Channel_Level_Revenue_Information__c>();
        for (ChannelProgramLevel cpl : ChannelProgramLevels) {
            Channel_Level_Revenue_Information__c cpri = PRM_TestRecordsFactory.createChannelLevelRevenueInformation(cpl.Id,'Retail','',1000.00,null);
            revInformationLst.add(cpri);
        }
        for (ChannelProgramLevel cpl : ChannelProgramLevels) {
            Channel_Level_Revenue_Information__c cpri = PRM_TestRecordsFactory.createChannelLevelRevenueInformation(cpl.Id,'Retail','Counterpoint',700.00,null);
            revInformationLst.add(cpri);
        }
        for (ChannelProgramLevel cpl : ChannelProgramLevels) {
            Channel_Level_Revenue_Information__c cpri = PRM_TestRecordsFactory.createChannelLevelRevenueInformation(cpl.Id,'Hospitality','',700.00,null);
            revInformationLst.add(cpri);
        }
        for (ChannelProgramLevel cpl : ChannelProgramLevels) {
            Channel_Level_Revenue_Information__c cpri = PRM_TestRecordsFactory.createChannelLevelRevenueInformation(cpl.Id,'Financial','',700.00,null);
            revInformationLst.add(cpri);
        }
        if (revInformationLst.size() > 0) insert revInformationLst;
        
        // Create Channel Program Member
        List<ChannelProgramMember> ChannelProgramMemberList = new List<ChannelProgramMember>();
        ChannelProgramMemberList.add(PRM_TestRecordsFactory.createChannelProgramMember(cp.Id, partner.Id, ChannelProgramLevels[0].Id, null));
        ChannelProgramMemberList.add(PRM_TestRecordsFactory.createChannelProgramMember(cp.Id, partner1.Id, ChannelProgramLevels[0].Id, null));
        insert ChannelProgramMemberList;
        ChannelProgramMember cpm = ChannelProgramMemberList[0];
        ChannelProgramMember cpm1 = ChannelProgramMemberList[1];
        // Test different Scinarios
        update partner1;
        update ChannelProgramLevels;
        delete cpm1;
        List<ChannelProgramMember> cmpList = [select id from ChannelProgramMember where PartnerId=:partner1.Id];
        System.assert(cmpList.size()==0);
        try {
        	delete ChannelProgramLevels[0];
        } catch (Exception ex) {
            System.debug('Error: '+ex.getMessage());        }
    }
}