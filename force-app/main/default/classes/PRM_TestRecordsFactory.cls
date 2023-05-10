@isTest
public class PRM_TestRecordsFactory { 
        
    /**
    * @purpose : Create customer account
    * @param : suffix - suffix to add with field values to differentiate with other account
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field. -- future use --
    * @return : Account record.
    */
    public static Account createCustomerAccount(String suffix, Map<String,String> fieldApiNameToFieldValue){
        
        Account objAccount = new Account();
        objAccount.Name = 'Customer Test Account'+suffix;
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'FINANCIAL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '9166111'+suffix;
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();       
        return objAccount;
    }
    /**
    * @purpose : Create partner account
    * @param : suffix - suffix to add with field values to differentiate with other account
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field. -- future use --
    * @return : Account record.
    */
    public static Account createPartnerAccount(String suffix, Map<String,String> fieldApiNameToFieldValue){
        
        Account objAccount = new Account();
        objAccount.Name = 'Partner Test Account'+suffix;
        objAccount.Account_Country_Code__c = 'US';
        objAccount.Active_Account__c = true;
        objAccount.CurrencyIsoCode = 'USD';
        objAccount.Industry = 'RETAIL:CHANNEL';
        objAccount.Account_Region__c = 'EMEA';
        objAccount.Master_Customer_Number__c = '9166344'+suffix;
        objAccount.Partner_Industry__c = 'Financial;Retail';
        objAccount.LOB__c = 'FINANCIAL';
        objAccount.Account_Region__c = 'CLA';
        objAccount.Partner_Program_Industry__c = 'Retail';
        objAccount.Partner_Program_Level__c = 'Silver';
        objAccount.Counterpoint__c = true;
        
        /*  List<RecordType> actRecordtypes = [SELECT Id, Name From RecordType WHERE DeveloperName='Partner' AND IsActive = true AND SobjectType = 'Account' Limit 1];
            if(actRecordtypes.size() > 0)
            objAccount.RecordTypeId = actRecordtypes[0].Id;
            */
        
        objAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        
        return objAccount;
    }
    
    /**
    * @purpose : Create partner contact
    * @param : AccountID - Id of the account to which contact is associated
    * @param : suffix - suffix to add with field values to differentiate with other contact
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field. - future use --
    * @return : contact record.
    */
    public static Contact createPartnerContact(Id AccountID, String suffix, Map<String,String> fieldApiNameToFieldValue)
    {
        Contact con = new Contact();
        con.lastName = 'Mahla'+suffix;
        //@gmail.com --+'@domain.com
        con.Email = 'test'+suffix+'@domain.com';
        con.AccountId = AccountID;
        con.Active_Contact__c = true;
        con.Web_Portal_Login__c = 'wplUser'+suffix;
        return con;
        
    }
    
    /**
    * @purpose : Create partner user
    *@param : AccountID - Id of the account to which contact is associated
    * @param : suffix - suffix to add with field values to differentiate with other contact
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field. - future use --
    * @return : contact record.
    */
    public static User createPartnerUser(Id ContactId, String suffix,Map<String,String> fieldApiNameToFieldValue)
    {
        //Insert Partner User
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'IPT Partner Community Login User' Limit 1];
        User u = new User();
        u.ContactId = contactId;
        u.Username = 'testUser'+suffix+'@ncr.com';
        u.ProfileId = portalProfile.Id;
        u.Alias = 'test'+suffix;
        u.Email = 'test'+suffix+'@domain.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'last'+suffix;
        u.CommunityNickname = 'testCN'+suffix;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.FederationIdentifier = 'test'+suffix;
        return u;   
    }
    
    public static Deal_Registration__c createDealRegistration(String dealName, String starus){
        Deal_Registration__c dealRegistrationRecord = new Deal_Registration__c();
        dealRegistrationRecord.Deal_Name__c = dealName;
        dealRegistrationRecord.Status__c = starus;
        dealRegistrationRecord.Partner_Industry__c = 'Retail';
        dealRegistrationRecord.Special_Bid_Registration_Type__c ='Net New Customer';
        dealRegistrationRecord.Country__c = 'Barbados';
        dealRegistrationRecord.End_Customer_Company_Name__c='Test Customer';
        dealRegistrationRecord.State__c='Test State';
        dealRegistrationRecord.City__c='Test City';
        dealRegistrationRecord.Postal__c='Test';
        dealRegistrationRecord.Primary_Contact_NameText__c='Test Primary Contact Name';
        dealRegistrationRecord.Primary_Solution__c='ATM 30 series';
        dealRegistrationRecord.Primary_Competitor__c='Test Competitor';
        dealRegistrationRecord.Projected_Opportunity_Value__c=2000000;
        dealRegistrationRecord.Expected_Start_Date__c = Date.today()+1;
        dealRegistrationRecord.Estimated_Close_Date__c = Date.today()+20;
        Return dealRegistrationRecord;
    }
    
    public static User createUser(Id ContactId,String profileName, String suffix,Map<String,String> fieldApiNameToFieldValue)
    {
        //Insert Partner User
        Profile userProfile = new Profile();
        if(profileName!= null){
            userProfile = [SELECT Id FROM Profile WHERE Name = : profileName Limit 1];
        } 
        User u = new User();
        u.ContactId = contactId;
        u.Username = 'testUser'+suffix+'@ncr.com';
        u.ProfileId = userProfile.Id;
        u.Alias = 'test'+suffix;
        u.Email = 'test'+suffix+'@domain.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'last'+suffix;
        u.CommunityNickname = 'testCN'+suffix;
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.FederationIdentifier = 'test'+suffix;
        u.Quicklook_ID__c = 'test'+suffix;
        return u;   
    }

    public static user createSoupUser() {
        Profile userProfile = new Profile();
        userProfile = [SELECT Id FROM Profile WHERE Name = 'Soup Integration' Limit 1];
        UserRole role = new UserRole();
        role = [SELECT DeveloperName,Id,Name FROM UserRole WHERE Name = 'AptraXpress User'];
        User u = new User();
        u.Username = 'soup1User@ncr.com';
        u.ProfileId = userProfile.Id;
        u.UserRoleId  = role.Id;
        u.Alias = 'sou1';
        u.Email = 'soupUse1@ncr.com';
        u.EmailEncodingKey = 'UTF-8';
        u.LastName = 'user';
        u.CommunityNickname = 'nick';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.LocaleSidKey = 'en_US';
        u.LanguageLocaleKey = 'en_US';
        u.Quicklook_ID__c = 'tes639';
        return u; 
    }
    
   /**
    * @purpose : Create Channel Program
    * @param : AccountID - Id of the account to which contact is associated
    * @param : suffix - suffix to add with field values to differentiate with other contact
    * @param: fieldApiNameToFieldValue - To add specifice value with particular field. - future use --
    * @return : contact record.
    */
    public static ChannelProgram createChannelProgram(String name, String suffix, Map<String,String> fieldApiNameToFieldValue)
    {
        ChannelProgram cp = new ChannelProgram();
        cp.Name = name + (String.isBlank(suffix) ? '' : suffix);
        cp.isActive = true;
        return cp;
    }
    
    public static ChannelProgramLevel createChannelProgramLevel(String name,String ChannelProgramId,String suffix,integer rank, Map<String,String> fieldApiNameToFieldValue) {
        ChannelProgramLevel cpl = new ChannelProgramLevel();
        cpl.Name = name + (String.isBlank(suffix) ? '' : suffix);
        cpl.ProgramId = ChannelProgramId;
        cpl.rank = rank;
        return cpl;
    }
    
    public static ChannelProgramMember createChannelProgramMember(Id channelProgramId, Id partnerId, Id channleProgramLevelId,Map<String,String> fieldApiNameToFieldValue) {
        ChannelProgramMember cpm = new ChannelProgramMember();
        cpm.ProgramId = channelProgramId;
        cpm.PartnerId = partnerId;
        cpm.LevelId	= channleProgramLevelId;
        return cpm;
    } 
        
    public static Channel_Level_Revenue_Information__c createChannelLevelRevenueInformation(Id channelProgramLevelId, String industry, String solution, Decimal thresholdRevenue, Map<String,String> fieldApiNameToFieldValue) {
        Channel_Level_Revenue_Information__c channelRevInfo = new Channel_Level_Revenue_Information__c();
        channelRevInfo.Channel_Program_Level__c = channelProgramLevelId;
        channelRevInfo.Industry__c = industry;
        channelRevInfo.solution__c = solution;
        channelRevInfo.Threshold_Revenue__c = thresholdRevenue;
        channelRevInfo.Percent_Revenue_Net_New_Customer__c = '10';
        return channelRevInfo;
    }
    /*
    * CreatedBy : Naman Kumar 
    * @purpose : Create Partner Revenue Records
    * @param : AccountID - Id of the account to which Partner Revenue is associated
    * @param : numberOfRecords - Number of records of Partner Revenue
    * @return : list of Partner Revenue records.
	*/
    public static List<Partner_Revenue__c> partnerRevenueList(Id accountId){
        List<Partner_Revenue__c> listOfPartnerRev = new List<Partner_Revenue__c>();
        for(Integer i=0; i<4; i++){
            listOfPartnerRev.add(new Partner_Revenue__c(
                Direct_Revenue__c=1000, Indirect_Revenue__c=1000, Hardware__c=1000, Software__c=1000, Professional_Services__c=1000,  
                TS__c=1000, Hosted__c=1000, SaaS__c=1000,POSaaS__c=1000,Total_Services_Revenue__c=1000,Solution_from_Net_New_Customers__c=1000,
                Subscription_from_Net_New_Customers__c=1000,First_Half__c=4000,Second_Half__c=4000,Partner_Account__c=accountId, Year__c = String.valueOf(System.today().year())
            ));
        }
        return listOfPartnerRev;
    }
    /*
    * CreatedBy : Naman Kumar 
    * @purpose : Create ChannelProgramLevel Records
    * @param : channelProgramId - Id of the Channel Program
    * @return : list of ChannelProgramLevel records.
	*/
    public static List<ChannelProgramLevel> channelProgramLevel(Id channelProgramId){
        List<ChannelProgramLevel> channelProgramLevelList = new List<ChannelProgramLevel>();
        List<String> channelProgLevelNames = new List<String>{'Silver', 'Gold', 'Platinum'};
        List<String> perRevNetNewCustomer = new List<String>{'0-10', '10-12', '12'};
        for(Integer i=0; i<3; i++){
            channelProgramLevelList.add(new ChannelProgramLevel(
                Name=channelProgLevelNames[i],
                ProgramId = channelProgramId,
                Rank=(i+1),
                Percent_Revenue_Net_New_Customer__c=perRevNetNewCustomer[i]
            ));
        }
        return channelProgramLevelList;
    }
	/*
    * CreatedBy : Naman Kumar 
    * @purpose : Create ChannelProgramLevel Records
    * @param : channelProgramId - Id of the Channel Program
    * @return : list of ChannelProgramLevel records.
	*/
    public static List<Channel_Level_Revenue_Information__c> channelLevelRevInfo(Set<Id> channelProgramLevelIdSet){
        List<Channel_Level_Revenue_Information__c> channelLevelRevList = new List<Channel_Level_Revenue_Information__c>();
        List<String> industries = new List<String>{'Retail', 'Retail-Counterpoint', 'Hospitality', 'Financial'};
        List<Decimal> thresholdRevenue = new List<Decimal>{0, 1000000, 3000000};
        List<Id> channelProgramIdList = new List<Id>(channelProgramLevelIdSet);
        for(Id cplId :channelProgramLevelIdSet){
            for(Integer i=0; i<4; i++){
                Channel_Level_Revenue_Information__c obj = new Channel_Level_Revenue_Information__c();
                System.debug(channelProgramIdList);
                System.debug('contains::::::::::::::::::::::::::'+thresholdRevenue[channelProgramIdList.indexOf(cplId)]);
                obj.Threshold_Revenue__c = thresholdRevenue[channelProgramIdList.indexOf(cplId)];
                obj.Channel_Program_Level__c=cplId;
                obj.Industry__c = industries[i];
                if(industries[i]=='Retail-Counterpoint'){
                    obj.Solution__c = 'Counterpoint';
                    obj.Industry__c = 'Retail';
                }
                channelLevelRevList.add(obj);
            }
        }
        return channelLevelRevList;
    }
    
    /*
    *Created By : Ritesh Kumar
    * @purpose : Create Market Share Captures  
    */
    public static Market_Share_Captures__c createMarketShareCaptures(String name, String description ,String url){
        Market_Share_Captures__c marketShareCapturesRecord = new Market_Share_Captures__c(); 
        marketShareCapturesRecord.Name = name;
        marketShareCapturesRecord.Description__c = description;
        marketShareCapturesRecord.URL__c = url;
        Return marketShareCapturesRecord;
    }
    
    /*
    *Created By : Ritesh Kumar
    * @purpose : Create Channel Benefit Action Packs 
    */
    public static Channel_Benefit_Action_Packs__c createBenefitActionPacks( String packsLabel, Integer sequenceNumber, String actionPackCategory, String description ,String url){
        Channel_Benefit_Action_Packs__c benefitActionPacksRecord = new Channel_Benefit_Action_Packs__c(); 
        benefitActionPacksRecord.Name = packsLabel; 
        benefitActionPacksRecord.Sequence_Number__c = sequenceNumber; 
        benefitActionPacksRecord.Action_Pack_Category__c = actionPackCategory;
        benefitActionPacksRecord.Brief_Description__c = description;
        benefitActionPacksRecord.URL__c = url;
        Return benefitActionPacksRecord;
    }
    
    /*
    *Created By : Ritesh Kumar
    * @purpose : Create MDF Claim 
    */
    public static SFDC_MDF_Claim__c createFundClaim(String fundName, String account, String fundRequest, String status){
        SFDC_MDF_Claim__c fundClaim = new SFDC_MDF_Claim__c();
        fundClaim.Name = fundName;
        fundClaim.Account__c = account;
        fundClaim.Fund_Request__c  = fundRequest;
        fundClaim.Status__c = status;
        Return fundClaim;
    }
    
    /*
    *Created By : Ritesh Kumar
    * @purpose : Create MDF Request 
    */
    public static SFDC_MDF__c createFundRequest(String fundName, String account,String status){
        SFDC_MDF__c fundRequest = new SFDC_MDF__c();
        fundRequest.Name = fundName;
        fundRequest.Account__c = account; 
        fundRequest.Status__c  = status;
        fundRequest.Activity_Date__c = Date.today()+30;
        fundRequest.End_Date__c =  Date.today()+60;
        Return fundRequest;
    }
    
    /*
    *Created By : Ritesh Kumar
    * @purpose : Insert Attachment to an object 
    */
    public static void insertAttachment(String ParentId, String attachmentName){
        Attachment attachmentRecord = new Attachment();
        attachmentRecord.Name=attachmentName;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attachmentRecord.body=bodyBlob;
        attachmentRecord.parentId=ParentId;
        attachmentRecord.ContentType = 'application/msword'; 
        insert attachmentRecord;
    }
    
    /*
    *Created By : Shiv Mahla
    * @purpose : Insert Co-Bradning Request to an object.
    */
    
    public static Co_Branding_Request__c createCoBrandingRequest(Account act, String subject, String description) {
        Co_Branding_Request__c cbr = new Co_Branding_Request__c();
        cbr.Account__c = act.Id;
        cbr.Subject__c = subject;
        cbr.Description__c = description;
        return cbr;
        
    }
    
    
}