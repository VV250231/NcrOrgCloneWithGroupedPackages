/*
####################################################################################################################                                                        
# Created by................: Ajay Dixit                                                                      
# Created Date...........: 07-06-2017                                                                                  
# Last Modified by......: Saagar Kinja                                                                           
# Last Modified Date..: 02-08-2018  // Added GDPR Changes test cases + Lead Ecosystem test cases                                                                              
# Description...............: Combined test class for all Lead Triggers
####################################################################################################################
*/

@isTest
public class LeadTriggerTest {
    @testSetup
    public static void unitUserMethod(){
        Profile pf= [Select Id from profile where Name='04 NSC UI Administrator'];
        List<User> uList = new List<user>();
        User userList = new User();
        userList.LastName = 'Test';
        userList.IsActive = true;
        userList.Email = 'Test@test.com';
        userList.Username = 'Test@test.com' + System.currentTimeMillis();
        userList.CompanyName = 'TEST';
        userList.Title = 'title';
        userList.Quicklook_ID__c='tt250288';
        userList.FederationIdentifier ='tt250288';
        // userList.ContactId = '0037000000U47qkAAB';
        userList.Alias = 'alias';
        userList.TimeZoneSidKey = 'America/Los_Angeles';
        userList.EmailEncodingKey = 'UTF-8';
        userList.LanguageLocaleKey = 'en_US';
        userList.LocaleSidKey = 'en_US';
        userList.ProfileId = pf.id;
        userList.IsActive = true;
        uList.add(userList);
        insert uList;        
        
    }
    public static testMethod void testLeadAssignment(){
        //create custom setting for country code mapping
        LeadRegionCountryMapping__c countrymapping = new LeadRegionCountryMapping__c(NAME='AT',FinancialRegion__c = 'EUROPE',HospitalityRegion__c = 'EUROPE',
                                                                                     RetailRegion__c = 'EMEA',TelecomRegion__c = 'EUROPE',
                                                                                     Country__c = 'AUSTRIA',CountryCode__c = 'AT' );
        insert countrymapping;
        // test Lead Insert trigger
        Lead l = new Lead(LastName ='TestLast', Campaign_Code__c='C001',Company = 'NCR Corp',  country='India',Industry__c = 'Hospitality',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='aaa_unique@zzz.com',
                          Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');        
        Profile p = [SELECT Id FROM Profile WHERE Name='Marketo Administration'];
        insert l;
    }
    static testMethod void PopulateDays_Between_Fields() { 
        //create custom setting for country code mapping
        LeadRegionCountryMapping__c countrymapping = new LeadRegionCountryMapping__c(NAME='AT',FinancialRegion__c = 'EUROPE',HospitalityRegion__c = 'EUROPE',
                                                                                     RetailRegion__c = 'EMEA',TelecomRegion__c = 'EUROPE',
                                                                                     Country__c = 'AUSTRIA',CountryCode__c = 'AT' );
        insert countrymapping;
        Account acc = TestRecordsFactory.createAccount();
        Lead l1= new Lead(lastname='test', Campaign_Code__c='C001',company=acc.name,Industry__c = 'Retail',Country__c='AUSTRIA',Email='bbb_unique@zzz.com',
                          Status='Open',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');    
        insert l1 ;    
        Lead l2= new Lead(Industry__c = 'Retail',Country__c='AUSTRIA',Status='Open',Lead_Stage__c='MQL',LeadType__c='Chat',
                          LeadSource__c='Paid - Display',Email='bbb_unique@zzz.com');
        l2.lastname = 'test';
        l2.company = acc.name;
        l2.MQL_Date__c = System.today();
        l2.SQL_Date__c = System.today().adddays(1);
        l2.SAL_Date__c = System.today().adddays(2);
        insert l2 ;    
        update l1 ;   
        update l2 ;
        
    }
    public static testMethod void testEMEARETWorkflow(){  
        //create custom setting for country code mapping
        LeadRegionCountryMapping__c countrymapping = new LeadRegionCountryMapping__c(NAME='AT',FinancialRegion__c = 'EUROPE',HospitalityRegion__c = 'EUROPE',
                                                                                     RetailRegion__c = 'EMEA',TelecomRegion__c = 'EUROPE',
                                                                                     Country__c = 'AUSTRIA',CountryCode__c = 'AT' );
        insert countrymapping;
        Lead ld = new Lead(LastName ='TestLead', Campaign_Code__c='C001',Company = 'NCR',Industry__c = 'Telecom',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='ccc_unique@zzz.com',
                           Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');
        Group EMEAGroup = [select id,name from group where developername = 'EMEA' limit 1]; 
        GroupMember EMEAGroupMemberId = [select UserOrGroupId,GroupId  from GroupMember where GroupId =:EMEAGroup.id limit 1];
        ld.OwnerId = EMEAGroupMemberId.UserOrGroupId;
        insert ld;
        ld.status = 'Qualified';
        Update ld;
        System.assertEquals(ld.Status, 'Qualified');
        
    }
    public static testMethod void testNAMERWorkflow(){
        User u =[Select id,name,Email,managerid from User where manager.Name='Maurice Settles'][0];
        Lead ld = new Lead(LastName ='TestLead', Company = 'NCR', Ownerid=u.Managerid,Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='ddd_unique@zzz.com',
                           Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');
        insert ld;
        
        ld.OwnerId=u.id;
        Update ld;
        System.assertEquals(ld.OwnerId, u.id);
    }
    static testmethod void testCampaign() {
        Id u =NSCCommonInfoUtil.getIdOf('Campaign_ID');
        system.runAs([select id from user where id=:u][0]){        
            Campaign cmpgn=new Campaign();
            cmpgn.CurrencyIsoCode='USD';
            cmpgn.Name='test cmpgn'+system.now();
            insert cmpgn;
            Lead l= new Lead(lastname='test', company='NCR',Industry__c = 'Banking',Country__c='AUSTRIA',Email='eee_unique@zzz.com',
                             Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');  
            l.lastName = 'User';
            l.Sys_Campaign_Id__c = cmpgn.Id;
            insert l;
            Lead ld = new Lead(LastName ='TestLead', Company = 'NCR',Industry__c = 'Banking',Country__c='AUSTRIA',Email='eee_unique@zzz.com',
                               Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');
            insert ld;
            
            CampaignMember newMember = new CampaignMember(Leadid = ld.id, status='Sent', campaignid = cmpgn.id);
            insert newMember ;
            ld.Status = 'Nurture';
            update ld;
            System.assertEquals(ld.Status, 'Nurture');
            //Lead_Trigger_Future_method.covertestcoverage();
        }
        
    }
    static testMethod void runTestPopulateConverted() {
        List<Account> accList = new List<Account>(); 
        accList.add(TestRecordsFactory.createAccount('I'));
        Account a = TestRecordsFactory.createAccount('J');
        if(!accList.isEmpty())
            accList.add(a);
        
        Contact c = TestRecordsFactory.createContact(a);
        Opportunity o =TestRecordsFactory.createOpportunity(a);
        
        // Lead l = TestRecordsFactory.createLead();
        Lead l = new Lead(LastName ='TestLast', Campaign_Code__c='C001',Company = 'NCR Corp', Industry__c = 'Banking',Country__c='AUSTRIA',Email='eee_unique@zzz.com',
                          Status='Open',Lead_Stage__c='INQ',LeadType__c='Chat',LeadSource__c='Paid - Display');
        insert l;
        l.Bank_Holding_Company_Number__c = 'BH1234';
        l.FI_Type__c = 'Branch';
        update l;
        
        
        Campaign cmpgn=new Campaign();
        cmpgn.CurrencyIsoCode='USD';
        cmpgn.Name='test cmpgn'+system.now();
        cmpgn.Campaign_Code__c='Sales-HOS-FabFive';
        insert cmpgn;                                     
        CampaignMember newMember = new CampaignMember(Leadid = l.id, status='Sent', campaignid = cmpgn.id);
        insert newMember;
        
        Test.startTest();
        
        LeadTriggerHandler.isTrue=True;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id); 
        lc.setAccountId(a.Id);
        lc.setContactId(c.Id);
        lc.setOpportunityName(o.Name);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        system.runAs(TestRecordsFactory.getUser()){
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());  
        }
        Test.stopTest();    
    }
    
    static testMethod void runLeadConTest() {
        List<Account> accList = new List<Account>(); 
        accList.add(TestRecordsFactory.createAccount('I'));
        
        Account a = TestRecordsFactory.createAccount('J');
        if(!accList.isEmpty())
            accList.add(a);
        
        Contact c = TestRecordsFactory.createContact(a);
        Opportunity o =TestRecordsFactory.createOpportunity(a);
        // Lead l = TestRecordsFactory.createLead();
        
        Lead l = new Lead(LastName ='TestLast', Campaign_Code__c='C001',Company = 'NCR Corp', Industry__c = 'Banking',Country_Code__c='US',Email='eee_unique@zzz.com',
                          Status='Open',Lead_Stage__c='INQ',LeadType__c='Chat',LeadSource__c='Paid - Display');
        insert l;
        update l;
        
        Campaign cmpgn=new Campaign();
        cmpgn.CurrencyIsoCode='USD';
        cmpgn.Name='test cmpgn'+system.now();
        cmpgn.Campaign_Code__c='Sales-HOS-FabFive';
        insert cmpgn;                                     
        CampaignMember newMember = new CampaignMember(Leadid = l.id, status='Sent', campaignid = cmpgn.id);
        insert newMember;
        
        Test.startTest();
        
        LeadTriggerHandler.isTrue=True;
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(l.Id); 
        lc.setAccountId(a.Id);
        lc.setContactId(c.Id);
        lc.setOpportunityName(o.Name);
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        system.runAs(TestRecordsFactory.getUser()){
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());  
        }
        Test.stopTest();    
    }
    
    
    
    public static testMethod void testLead_KPI_insert(){
        
        List<Lead> linsert = new List<Lead>();
        List<Lead> lupdate = new List<Lead>();
        
        Lead l1 = new Lead(LastName ='TestLast1', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='fff_unique@zzz.com',
                           Status='Open',Lead_Stage__c='INQ',LeadType__c='Chat',LeadSource__c='Paid - Display'); 
        Lead l2 = new Lead(LastName ='TestLast2', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='ggg_unique@zzz.com',
                           Status='Marketing Qualified',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');
        Lead l3 = new Lead(LastName ='TestLast3', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='hhh_unique@zzz.com',
                           Status='Accepted',Lead_Stage__c='SAL',LeadType__c='Chat',LeadSource__c='Paid - Display'); 
        Lead l4 = new Lead(LastName ='TestLas4', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='iii_unique@zzz.com',
                           Status='Accepted - SGL',Lead_Stage__c='SGL',LeadType__c='Chat',LeadSource__c='Paid - Display'); 
        Lead l5 = new Lead(LastName ='TestLast5', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='jjj_unique@zzz.com',
                           Status='Qualified',Lead_Stage__c='SQL',LeadType__c='Chat',LeadSource__c='Paid - Display'); 
        Lead l7 = new Lead(LastName ='TestLast7', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='lll_unique@zzz.com',
                           Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display'); 
        Lead l8 = new Lead(LastName ='TestLast8', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='mmm_unique@zzz.com',
                           Status='NetSuite Managed',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display');
        Lead l9 = new Lead(LastName ='TestLast9', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='mmm_unique@zzz.com',
                           Status='Nurture',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display', Return_to_Nurture_Reason__c= 'Not a Decision Maker');
        Lead l10 = new Lead(LastName ='TestLast10', Company = 'NCR Corp', Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='mmm_unique@zzz.com',
                           Status='Disqualified',Lead_Stage__c='MQL',LeadType__c='Chat',LeadSource__c='Paid - Display', Disqualified_Reason__c= 'Duplicate');
        linsert.add(l1); 
        linsert.add(l2);
        linsert.add(l3);
        linsert.add(l4);
        linsert.add(l5);
        linsert.add(l7);
        linsert.add(l8);
        linsert.add(l9);
        linsert.add(l10);
        insert linsert;
        
        
        l1.Status = 'Marketing Qualified';
        l2.Status = 'Accepted';
        l3.Status = 'Accepted - SGL';
        l4.Status = 'Qualified';
        l5.Status = 'Nurture';
        l7.Status = 'Open';
        l8.Country_Code__c = 'US';
        l8.PostalCode = '1234';
        l8.Status = 'Partner Managed';
        
        lupdate.add(l1);lupdate.add(l2);lupdate.add(l3);lupdate.add(l4);
        lupdate.add(l5);lupdate.add(l7);lupdate.add(l8);
        try{
            update lupdate;}
        catch(Exception ex){
            System.debug('In Exception');
        }
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(lupdate);
        Lead_ChangeStatus testController = new  Lead_ChangeStatus(sc);
        
        // below test case if for controller of Lead Progress Tracker
        
        List<Lead_progress_tracker__c> lpt_list = new List<Lead_progress_tracker__c>();
        lpt_list.add(new Lead_progress_tracker__c(name='1',Index__c=1,Stage__c='Stage-1',Status1__c = 'Open'));
        lpt_list.add(new Lead_progress_tracker__c(name='2',Index__c=2,Stage__c='Stage-2',Status1__c = 'Researching'));
        lpt_list.add(new Lead_progress_tracker__c(name='3',Index__c=3,Stage__c='Stage-3',Status1__c = 'Marketing Qualified',Status2__c = 'Partner Managed',Status3__c = 'NetSuite Managed'));
        lpt_list.add(new Lead_progress_tracker__c(name='4',Index__c=4,Stage__c='Stage-4',Status1__c = 'Accepted',Status2__c = 'Accepted - SGL'));
        lpt_list.add(new Lead_progress_tracker__c(name='5',Index__c=5,Stage__c='Stage-5',Status1__c = 'Contacted',Status2__c = 'Deferred',Status3__c = 'Pending',Status4__c = 'Deferred - SGL',status5__c = 'Contacted - SGL',status6__c = 'Pending - SGL'));
        lpt_list.add(new Lead_progress_tracker__c(name='6',Index__c=6,Stage__c='Stage-6',Status1__c = 'Qualified'));
        lpt_list.add(new Lead_progress_tracker__c(name='7',Index__c=100,Stage__c='Stage-7',Status1__c = 'Disqualified'));
        lpt_list.add(new Lead_progress_tracker__c(name='8',Index__c=101,Stage__c='Stage-8',Status1__c = 'Nurture'));
        insert lpt_list ;
        
        List<Lead_progress_tracker_dependencies__c> lpdt_list = new List<Lead_progress_tracker_dependencies__c>();
        lpdt_list.add(new Lead_progress_tracker_dependencies__c( name='1', DependentField__c = 'Return_to_Nurture_Reason__c',Status__c = 'Nurture'));
        lpdt_list.add(new Lead_progress_tracker_dependencies__c( name='2', DependentField__c = 'Disqualified_Reason__c',Status__c = 'Disqualified'));
        insert lpdt_list ;
        
        
        Controller_lead_process_tracker Progress_track = new Controller_lead_process_tracker() ;
        Controller_lead_process_tracker.load_lead('nurt') ;
        Controller_lead_process_tracker.load_lead('disq') ;
        Controller_lead_process_tracker.get_dependent_fieldvalue('nurt') ;
        Controller_lead_process_tracker.get_dependent_fieldvalue('disq') ;
        //Controller_lead_process_tracker.get_tracker_details(l5.Id);
        Controller_lead_process_tracker.get_tracker_details(l7.id);
        Controller_lead_process_tracker.updateLead(l5.id,l5.Status,'Not Ready', 'test');
        
    }
    public static testmethod void test_partner(){
        
        LeadRegionCountryMapping__c obj = new LeadRegionCountryMapping__c();
        obj.name= 'Test';
        obj.Country__c = 'UNITED STATES';
        obj.CountryCode__c = 'US';
        obj.FinancialRegion__c = 'Test';
        obj.HospitalityRegion__c = 'Test';
        obj.New_Region__c = 'Test';
        obj.RetailRegion__c = 'Test';
        obj.TelecomRegion__c = 'Test';
        insert obj;
        
        //  below for partner managed
        //  below for partner managed
        User u = [select id, isactive from user where Quicklook_ID__c = 'tt250288'  limit 1];
        List<Reseller__c> rese = new List<Reseller__c>();
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ZIPCode_file__c='111222',ToEmail__c='xcx@xcx.com', CCEmail__c='test@test.com'));
        rese.add(new Reseller__c(CountryCode__c='TH',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='Thai',ResellerContactLastName__c='Thai',ZIPCode__c='111221', ZIPCode_file__c='111222',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        //rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner_Quicklook__c='sk250817',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ToEmail__c='xcx@xcx.com'));
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ZIPCode_file__c='1',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ZIPCode_file__c='11',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ZIPCode_file__c='111',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='US1',ResellerContactLastName__c='US1',ZIPCode__c='111222', ZIPCode_file__c='1112',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        rese.add(new Reseller__c(CountryCode__c='US',NCR_Lead_Owner__c=u.id,NCR_Lead_Owner_Quicklook__c='ys250288',ResellerContactFirstName__c='Thai',ResellerContactLastName__c='Thai',ZIPCode__c='111221', ZIPCode_file__c='1112220',ToEmail__c='xcx@xcx.com',CCEmail__c='test@test.com'));
        insert rese ;
        ResellerNotificationSwitchs__c resellerSwitchButton =new ResellerNotificationSwitchs__c();
        resellerSwitchButton.Name='SwitchTest';
        resellerSwitchButton.ResellerSwitch__c = true;
        insert resellerSwitchButton;
        LeadOwnerNotificationSwitch__c LeadOwnerNotificationSwitch = new LeadOwnerNotificationSwitch__c();
        LeadOwnerNotificationSwitch.Name ='LeadOwnerSwtich';
        LeadOwnerNotificationSwitch.Lead_Owner_Swtich__c = true;
        insert LeadOwnerNotificationSwitch;
        Lead l_partner = new Lead(LastName ='1.8 ln hos', Company = 'NCR Corp', Industry__c = 'Hospitality',SubIndustry__c='Banking',Country__c='UNITED STATES', Country_Code__c='US',Email='fff_unique@zzzpartner.com',
                                  Status='Partner Managed',Lead_Stage__c='INQ',LeadType__c='Event',LeadSource__c='Sales-Referral (SGL)',PostalCode='111222');
        
        Lead l_partner1 = new Lead(LastName ='1.8 ln hos', LeadOwnerManage__c='unique250288@ncr.com',Company = 'NCR Corp', Industry__c = 'Hospitality',SubIndustry__c='Banking',Country__c='UNITED STATES', Country_Code__c='US',Email='fff_uniquea@zzzpartner.com',
                                   Status='Qualified',Lead_Qualified_DateTime__c=System.now().addHours(-169),Lead_Stage__c='INQ',LeadType__c='Event',LeadSource__c='Sales-Referral (SGL)', PostalCode='111222');
        
        Lead l_partner2 = new Lead(LastName ='1.8 ln hos', LeadOwnerManage__c='1unique250288@ncr.com',Company = 'NCR Corp', Industry__c = 'Hospitality',SubIndustry__c='Banking',Country__c='UNITED STATES', Country_Code__c='US',Email='f1ff_uniquea@zzzpartner.com',
                                   Status='Qualified',Lead_Qualified_DateTime__c=System.now(),Lead_Stage__c='INQ',LeadType__c='Event',LeadSource__c='Sales-Referral (SGL)', PostalCode='111222');
        
        insert l_partner ;
        insert l_partner1;
        insert l_partner2;
        
        Test.startTest();
        LeadNotificationBatchApex obj1 = new LeadNotificationBatchApex();
        Database.executeBatch(obj1);
        Lead_Trigger_Future_method.updatecontact(new Set<Id>{l_partner.Id});
        Lead_Trigger_Future_method.updatelead(new Set<Id>{l_partner.Id});
        LeadResellerClass.leadReslrAttachment(new List<Lead>{l_partner});
        LeadResellerClass.leadReslrAttachment(new List<Lead>{l_partner1});
        Test.stopTest();
        
        l_partner.PostalCode = '111222' ;
        l_partner.Status = 'Partner Managed';
        l_partner.Industry__c='Hospitality'; 
        update l_partner ;
        
        l_partner.PostalCode = '' ;
        l_partner.Status = 'Open';
        update l_partner ;
        
        l_partner.PostalCode = '111221' ;
        l_partner.Country__c = 'THAILAND';
        
        update l_partner ;
        Lead_Ecosystem_Changes le=new Lead_Ecosystem_Changes();
        List<Lead> leadList = new List<Lead>{l_partner};
            
            }
    public static testmethod void test_campaignList(){
        Campaign cmpgn=new Campaign();
        cmpgn.CurrencyIsoCode='USD';
        cmpgn.Name='test cmpgn'+system.now();
        cmpgn.Campaign_Code__c='Sales-HOS-FabFive';
        insert cmpgn;
        String LeadSourceValue ='Sales-HOS-Restaurant Data';
        String LeadSource_Sales_HOS_RestaurantData = LeadSourceValue.replaceAll( '\\s+', '');
        
        Lead l= new Lead(lastname='test', company='NCR',Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='eee_unique@zzz.com',
                         Status='Partner Managed',Campaign_Code__c='Sales-HOS-FabFive',Lead_Stage__c='MQL',LeadType__c='Sales',LeadSource__c='Test');  
        l.lastName = 'User';
        insert l;
        l.LeadSource__c ='Sales-HOS-Restaurant Data';
        l.Campaign_Code__c='Sales-HOS-RestaurantData';
        LeadCamapignClass.isFirst =true;
        update l;
        l.LeadSource__c ='Sales-HOS-Fab Five';
        l.Campaign_Code__c='Sales-HOS-FabFive';
        LeadCamapignClass.isFirst =true;
        update l;
        Lead l1= new Lead(lastname='test', company='NCR',Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='eee_unique@zzz.com',
                          Status='Partner Managed',Campaign_Code__c='Sales-HOS-FabFive',Lead_Stage__c='MQL',LeadType__c='Sales',LeadSource__c='Sales-HOS-Fab Five');  
        l1.lastName = 'User';
        insert l1; 
        l.Sys_Campaign_Id__c = cmpgn.Id; 
        Lead l2= new Lead(lastname='test10', company='NCR',Industry__c = 'Banking',SubIndustry__c='Banking',Country__c='AUSTRIA',Email='fff_unique@zzz.com',
                          Status='Partner Managed',Lead_Stage__c='MQL',LeadType__c='Sales');  
        insert l2; 
        CampaignMember newMember = new CampaignMember(Leadid = l2.id, status='Sent', campaignid = cmpgn.id);
        insert newMember ;
        List<lead> leadList = new List<Lead>{l};
            if(LeadCamapignClass.isFirst){
                LeadCamapignClass.updateAddCampaignBasedOnLeadSource(leadList);
                
                //LeadCamapignClass.addCampaignBasedOnLeadSource(leadList);
                LeadCamapignClass.isFirst=false;
            }
        
        Lead_GDPR_Changes leadObj = new Lead_GDPR_Changes();
        leadObj.checkifindividualexist(leadList);
        //leadObj.assignindividualrecord(leadList);
        leadObj.createindividualrecord(leadList);
    }    
}