public  without sharing class  PRM_DistributorDealRegistrationCtr 
{   
     @AuraEnabled
    public static List < Deal_Registration_Detail__mdt > DealRegistration(String Industry, String Accounttheater) {
        if(Accounttheater!='CLA'){
            Accounttheater='';
        }
        return [ SELECT MasterLabel,Accounttheater__c,Deal_with_Monthly_Recurring_Rev__c,Projected_Opportunity_Value__c 
                FROM Deal_Registration_Detail__mdt where MasterLabel =:Industry and Accounttheater__c =:Accounttheater];
    }
    
    @AuraEnabled
    public static PicklistDetail getEditDetails(String recId)
    {
        //System.debug('-------recId---------'+recId);
        Deal_Registration__c objDR =  [Select Id, Name, Deal_Name__c, Campaign_Name__c, Special_Bid_Registration_Type__c, Account_Name_formula__c,Distributor__c, 
                                       Parnter_Contact_formula__c, Master_Customer_Number__c, NCR_Account_Manager__c,Region__c, Extension_Period__c,
                                       End_Customer_Company_Name__c, Street_Address__c, City__c, Postal__c, Primary_Contact_NameText__c, 
                                       FDIC__c,NCUA__c,Swift_Code__c, State__c, Country__c, Key_Decision_Maker__c, Primary_Solution__c, 
                                       Additional_Information__c, Primary_Competitor__c, Expected_Start_Date__c, Secondary_Solution__c, Partner_Opportunity__c,Funnel_Opportunity__c,
                                       Projected_Opportunity_Value__c, Probability_Score__c, Estimated_Close_Date__c, Status__c,
                                       Partner_Contact__r.Name, Partner_Industry__c, Contact_in_CC__r.Name, Contact_in_CC__c, County__c, Deal_Created_By_Distributor__c,
                                       Partner_Company_Name__c, Partner_Company_Name__r.Name,Current_installed_system__c,How_long_has_it_been_installed__c,Partner_Company_Name__r.Region__c,Partner_Company_Name__r.Account_Region__c,
                                       Deal_with_3_or_more_units__c,Deals_with_strategic_value_in_marktplce__c,Deal_with_Monthly_Recurring_Rev__c, strategic_value_in_marketplace_num__c,Deal_with_3_or_more_units_Num__c, 
                                       Is_NCR_servicing_the_Account__c, No_which_Service_option__c, If_a_competitor_which_one__c, Are_you_servicing_this_Account__c, Yes_how_many_units_are_you_servicing__c,
                                       Extension_Increment_Count__c, Extension_Status__c , Remaining_Days__c,Territory_Account_Manager__c,Territory_Account_Manager__r.Name
                                       from Deal_Registration__c where Id =: recId ];
        
        PicklistDetail objPD = PRM_DistributorDealRegistrationCtr.getPicklistValues();
        objPD.objDR = objDR;
        
        return objPD;
    }
    
    
    
    @AuraEnabled
    public static PicklistDetail getPicklistValues()
    {
        
        User partnerUserInfo = [SELECT ContactId,AccountId, Contact.AccountId, Contact.Account.Partner_Industry__c, Contact.Account.Distributor__c,Contact.Account.Region__c,Contact.Account.Account_Region__c from User where Id =: UserInfo.getUserId()];
        String parterIndustry = partnerUserInfo.Contact.Account.Partner_Industry__c;
        
        Set<String> solutionsForFinance = new Set<String>{'Branch Transformation', 'Channel Management', 'Channel Management', 'Managed Services', 'Digital Banking', 'Self Service ATM'};
            PicklistDetail objPicklistDetail = new PicklistDetail();
        
        List<Account> actDetails = [SELECT Id, Name, Account_Country_Code__c FROM Account WHERE Id =: partnerUserInfo.AccountId];
        if (actDetails.size() > 0) {
            objPicklistDetail.actDetail =actDetails[0];
        }
        
        objPicklistDetail.accountTheater = partnerUserInfo.Contact.Account.Region__c;
        objPicklistDetail.accountRegion = partnerUserInfo.Contact.Account.Account_Region__c;
        //Contact IN CC
        
        for(Contact objContact : [Select Id, Name from Contact where AccountId =: partnerUserInfo.Contact.AccountId])
        {
            if(objContact.Id != partnerUserInfo.ContactId)
                objPicklistDetail.contactNames.add(objContact.Name);
            
        }
        // Create distributor list
        if (partnerUserInfo.Contact.Account.Distributor__c != null) {
            
            objPicklistDetail.distributors.addAll((partnerUserInfo.Contact.Account.Distributor__c).split(';'));
        }
        
        
        // Create Partner Industry list
        if(partnerUserInfo.Contact.Account.Partner_Industry__c != null) {
            //objPicklistDetail.partnerIndustry.addAll((partnerUserInfo.Contact.Account.Partner_Industry__c).split(';'));
            
            for(String partnerIndustryName : (partnerUserInfo.Contact.Account.Partner_Industry__c).split(';')){
                if( !partnerIndustryName.contains('Travel') && ! partnerIndustryName.contains('Telecom') ){
                    objPicklistDetail.partnerIndustry.add(partnerIndustryName);
                }
            }
            
            //System.debug('--------------------------------')
            if(objPicklistDetail.partnerIndustry.size() > 1)
            {
                objPicklistDetail.partnerIndustry.add(0, '--None--');
            }
        }
        else
            objPicklistDetail.partnerIndustry.add('--None--');
        
        objPicklistDetail.isFIN = String.isNotBlank(parterIndustry) && parterIndustry.contains('Financial');
        //Campaign Name
        Schema.DescribeFieldResult fieldResult = Deal_Registration__c.Campaign_Name__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            objPicklistDetail.campaignName.add(f.getValue());
        }   
        
        //Deal Registration Type
        Schema.DescribeFieldResult fieldResult2 = Deal_Registration__c.Special_Bid_Registration_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple2 = fieldResult2.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple2)
        {
            objPicklistDetail.dealRegistrationType.add(f.getValue());
        }    
        
        //Country
        Schema.DescribeFieldResult fieldResult3 = Deal_Registration__c.Country__c.getDescribe();
        List<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
        
        for(Schema.PicklistEntry f : ple3)
        {
            objPicklistDetail.country.add(f.getValue());
        }    
        
        //probability
        List<OpportunityStage> oppStages = [SELECT DefaultProbability, MasterLabel FROM OpportunityStage WHERE IsActive = true];
        if (oppStages.size() > 0){
            Set<String> tempProb = new set<String>();
            for (OpportunityStage op: oppStages) {
                tempProb.add(String.valueOf(op.DefaultProbability));
            }
            objPicklistDetail.probability.addAll(tempProb);
        }
        
        //Extension_Period__c,
        Schema.DescribeFieldResult fieldResultEP = Deal_Registration__c.Extension_Period__c.getDescribe();
        List<Schema.PicklistEntry> pleEP = fieldResultEP.getPicklistValues();
        
        for(Schema.PicklistEntry f : pleEP)
        {
            objPicklistDetail.extensionPeriod.add(f.getValue());
        }  
        
        //Primary Solution
        Schema.DescribeFieldResult fieldResult4 = Deal_Registration__c.Primary_Solution__c.getDescribe();
        List<Schema.PicklistEntry> ple4 = fieldResult4.getPicklistValues();
        System.debug('Primary Solution Pick List value'+ple4);
        
        //Secondary Solution
        Schema.DescribeFieldResult fieldResult5 = Deal_Registration__c.Secondary_Solution__c.getDescribe();
        List<Schema.PicklistEntry> ple5 = fieldResult5.getPicklistValues();
        
        /*Adding Servicing Details */		
        //Is NCR servicing the Account
        Schema.DescribeFieldResult fieldResult6 = Deal_Registration__c.Is_NCR_servicing_the_Account__c.getDescribe();
        List<Schema.PicklistEntry> ple6 = fieldResult6.getPicklistValues();        
		for(Schema.PicklistEntry f : ple6)
        {
            objPicklistDetail.servicingAccount.add(f.getValue());
        } 
		
		System.debug('Is NCR servicing the Account Valuse : '+ objPicklistDetail.servicingAccount);
        
		// No which Service option
		Schema.DescribeFieldResult fieldResult7 = Deal_Registration__c.No_which_Service_option__c.getDescribe();
        List<Schema.PicklistEntry> ple7 = fieldResult7.getPicklistValues();
		for(Schema.PicklistEntry f : ple7)
        {
            objPicklistDetail.serviceOption.add(f.getValue());
        } 
		
		System.debug('No which Service option Valuse : '+ objPicklistDetail.serviceOption);
        
		// Are you servicing this Account
		Schema.DescribeFieldResult fieldResult8 = Deal_Registration__c.Are_you_servicing_this_Account__c.getDescribe();
        List<Schema.PicklistEntry> ple8 = fieldResult8.getPicklistValues();
		for(Schema.PicklistEntry f : ple8)
        {
            objPicklistDetail.servicingThisAccount.add(f.getValue());
        } 
		
		System.debug('Are you servicing this Account Valuse : '+ objPicklistDetail.servicingThisAccount);
        
        
        if(String.isNotBlank(parterIndustry))
        {
            if(parterIndustry.contains('Financial') && (parterIndustry.contains('Retail') || parterIndustry.contains('Hospitality')))
            {
                for(Schema.PicklistEntry f : ple4)
                {
                    objPicklistDetail.primarySolution.add(f.getValue());
                } 
                
                for(Schema.PicklistEntry f : ple5)
                {
                    objPicklistDetail.secondarySolution.add(f.getValue());
                }    
            }
            else if(!parterIndustry.contains('Financial') && (parterIndustry.contains('Retail') || parterIndustry.contains('Hospitality')))
            {
                for(Schema.PicklistEntry f : ple4)
                {
                    if(!solutionsForFinance.contains(f.getValue()))
                        objPicklistDetail.primarySolution.add(f.getValue());
                } 
                
                for(Schema.PicklistEntry f : ple5)
                {
                    if(!solutionsForFinance.contains(f.getValue()))
                        objPicklistDetail.secondarySolution.add(f.getValue());
                } 
            }
            else if(parterIndustry.contains('Financial') && !parterIndustry.contains('Retail') && !parterIndustry.contains('Hospitality'))
            {
                objPicklistDetail.primarySolution.addAll(solutionsForFinance) ; 
                objPicklistDetail.secondarySolution.addAll(solutionsForFinance) ; 
            } 
            
            if (parterIndustry.contains('Hospitality')) {
                objPicklistDetail.primarySolution.add('Hardware') ;
                objPicklistDetail.secondarySolution.add('Hardware') ;
            }
            System.debug('=====objPicklistDetail===='+objPicklistDetail.primarySolution);
            
        }
        
        // Map Partner Industry to  object of Metadata
        Map<String, Deal_Registration_Approval_Setting__mdt> mapPartnerIndustryToMetaDataObject = new Map<String, Deal_Registration_Approval_Setting__mdt>();
        
        for (Deal_Registration_Approval_Setting__mdt mdtRec : [SELECT MasterLabel, User_Id_OR_Queue_Id__c, DeveloperName, Primary_Solution__c, Secondary_Solution__c
                                                               FROM Deal_Registration_Approval_Setting__mdt]) 
        {
            mapPartnerIndustryToMetaDataObject.put(mdtRec.MasterLabel, mdtRec);
        }
        
        for(String strPartnerIndustry : mapPartnerIndustryToMetaDataObject.keySet())
        {
            Deal_Registration_Approval_Setting__mdt objMDT = mapPartnerIndustryToMetaDataObject.get(strPartnerIndustry);
            
            if(String.isNotBlank(objMDT.Primary_Solution__c))
            {
                objPicklistDetail.mapPartnerIndustryToPS.put(strPartnerIndustry, new List<String>());
                objPicklistDetail.mapPartnerIndustryToPS.get(strPartnerIndustry).addAll(objMDT.Primary_Solution__c.split(','));
                objPicklistDetail.mapPartnerIndustryToPS.get(strPartnerIndustry).add(0, '--None--');
            }
            else
            {
                objPicklistDetail.mapPartnerIndustryToPS.put(strPartnerIndustry, new List<String>{'--None--'});
            }
            
            if(String.isNotBlank(objMDT.Secondary_Solution__c))
            {
                objPicklistDetail.mapPartnerIndustryToSS.put(strPartnerIndustry, new List<String>());
                objPicklistDetail.mapPartnerIndustryToSS.get(strPartnerIndustry).addAll(objMDT.Secondary_Solution__c.split(','));
                
                objPicklistDetail.mapPartnerIndustryToSS.get(strPartnerIndustry).add(0, '--None--');
            }
            else
            {
                objPicklistDetail.mapPartnerIndustryToSS.put(strPartnerIndustry, new List<String>{'--None--'});
            }
        }
        
        User objLoginUser = [SELECT Id, AccountId FROM User WHERE Id =: Userinfo.getUserId()];
        List<Account> actLst = new List<Account>();
        
        List<Account> partnerAccountList = new List<Account>();
        if(objLoginUser.AccountId != null) 
        {
            Account partAct = [SELECT Id, Name, Partner_Type__c, Distributor__c,Region__c FROM Account WHERE Id =: objLoginUser.AccountId LIMIT 1];
            
            if(partAct.Partner_Type__c == 'Distributor') 
            {
                System.debug('--------------partAct.Name---------------'+partAct.Name);
                partnerAccountList = [SELECT Id, Name, Interact_Reseller_Agreement__c,Rules_of_Engagement__c,
                                      (Select Name from Contacts where Partner_User__c != null) FROM Account WHERE Distributor__c INCLUDES (:partAct.Name)];
              
                objPicklistDetail.lstParterAccountName.add('--None--');
                System.debug('--------------partnerAccountList---------------'+partnerAccountList.size());
                for(Account objAcc : partnerAccountList)
                {
                    objPicklistDetail.mapAccountNameToIRAstatus.put(objAcc.Name, objAcc.Interact_Reseller_Agreement__c);
                   objPicklistDetail.mapAccountNameToRoEstatus.put(objAcc.Name, objAcc.Rules_of_Engagement__c);
                    objPicklistDetail.lstParterAccountName.add(objAcc.Name);
                    List<String> lstContactName = new List<String>();
                    for(Contact objContact : objAcc.Contacts)
                    {
                        lstContactName.add(objContact.Name);
                    }
                    
                    objPicklistDetail.mapAccountNameTolstContact.put(objAcc.Name, new List<String>());
                    objPicklistDetail.mapAccountNameTolstContact.get(objAcc.Name).addAll(lstContactName);
                }
                
            }
        }
         // Code added by deeksharth to fetch TAM 24/9/2019
       if(actDetails.size()>0 && actDetails != NULL){
            Map<Id,String> getTAMData = PRM_GenericDealRegistration.getTAMDetails(actDetails[0].Id);
            system.debug('getTAMData >>'+getTAMData);
            
            if(getTAMData != NUll && getTAMData.size()>0){
                objPicklistDetail.getTAM = new Map<Id,String>(getTAMData);
            }
        }
        return objPicklistDetail;   
    }
    
    
    @AuraEnabled
    public static String saveDealRegistration(Deal_Registration__c objDR, String campaignName, String dealRegistrationType, String country, 
                                              String primarySolution, String secondarySolution, String extValue,  String partnerIndustry, String contactCC, String county,
                                              String selectedAccount, String selectedContact)
    {
        User partnerUserInfo = [SELECT ContactId, Contact.AccountId, Account.OwnerId, Account.Name from User where Id =: UserInfo.getUserId()];
        objDR.Campaign_Name__c =  campaignName == '--None--' ? null : campaignName;
        objDR.Special_Bid_Registration_Type__c =  dealRegistrationType == '--None--' ? null : dealRegistrationType;
        objDR.Country__c =  country == '--None--' ? null : country;
        objDR.Primary_Solution__c =  primarySolution == '--None--' ? null : primarySolution;
        objDR.Secondary_Solution__c = secondarySolution == '--None--' ? null : secondarySolution;
        objDR.Extension_Period__c =  extValue == '--None--' ? null : extValue;
        objDR.Distributor__c = partnerUserInfo.Account.Name;
        objDR.Partner_Industry__c = partnerIndustry == '--None--' ? null : partnerIndustry;
        objDR.County__c = county;
        
        objDR.Distributor_Contact__c = partnerUserInfo.ContactId;
        objDR.Distributor_Account__c = partnerUserInfo.Contact.AccountId;
        objDR.Deal_Created_By_Distributor__c = true;
        objDR.Distributor_Channel_Account_Manager__c = partnerUserInfo.Account.OwnerId;
       
        
        List<Contact> conList = [Select Id, AccountId from Contact where Name =: selectedContact and Account.Name =: selectedAccount LIMIT 1];
        
        if (conList.size() > 0) {
            Contact objContact = conList[0];
            objDR.Partner_Contact__c = objContact.Id;
            objDR.Partner_Company_Name__c = objContact.AccountId;
        }
        //Contact objContact = [Select Id, AccountId from Contact where Name =: selectedContact and Account.Name =: selectedAccount];
        //objDR.Partner_Contact__c = objContact.Id;
        //objDR.Partner_Company_Name__c = objContact.AccountId;
        
        
        objDR.Contact_in_CC__c = contactCC == '--None--' ? null : [Select Id from Contact where Name =: contactCC and AccountId =: partnerUserInfo.Contact.AccountId limit 1].Id;
        upsert objDR;
        
        return objDR.Id;
    }
    
    
    
    public class PicklistDetail
    {
        @AuraEnabled
        public Deal_Registration__c objDR;
        
        @AuraEnabled 
        public Account actDetail;
        
        @AuraEnabled
        public List<String> campaignName;
        
        @AuraEnabled
        public List<String> dealRegistrationType;
        
        @AuraEnabled
        public List<String> country;
        
        @AuraEnabled
        public List<String> probability;
        
        @AuraEnabled
        public List<String> primarySolution;
        
        @AuraEnabled
        public List<String> secondarySolution;
        
        @AuraEnabled
        public List<String> extensionPeriod;
        
        @AuraEnabled
        public List<String> distributors;
        
        @AuraEnabled
        public List<String> partnerIndustry;
        
        @AuraEnabled
        public List<String>  contactNames;
        
        @AuraEnabled
        public String accountTheater;
        
        @AuraEnabled
        public Boolean isFIN;
        
        @AuraEnabled 
        public Map<String, List<String>> mapPartnerIndustryToPS;
        
        @AuraEnabled 
        public Map<String, List<String>> mapPartnerIndustryToSS;
        
        
        @AuraEnabled 
        public Map<String, Boolean> mapAccountNameToIRAstatus;
        
        @AuraEnabled 
        public Map<String, Boolean> mapAccountNameToRoEstatus;
        
        @AuraEnabled 
        public Map<String, List<String>> mapAccountNameTolstContact;
        
        @AuraEnabled
        public List<String>  lstParterAccountName;
        
        //Added for Servicing Details Section
        @AuraEnabled
        public List<String> servicingAccount;
        
        @AuraEnabled
        public List<String> serviceOption;
        
        @AuraEnabled
        public List<String> servicingThisAccount;
        
        // Code added by deeksharth under us 1192  add TAM
        @AuraEnabled
        public Map<Id,String> getTAM;

		// Code added by deeksharth under us 1192 add TAM
         @AuraEnabled
        public String accountRegion; 
        
        public PicklistDetail()
        {
            campaignName = new List<String>();
            campaignName.add('--None--');
            
            dealRegistrationType = new List<String>();
            dealRegistrationType.add('--None--');
            
            actDetail = new Account();
            
            country = new List<String>();
            country.add('--None--');
            
            probability = new List<String>();
            
            primarySolution = new List<String>();
            primarySolution.add('--None--');
            
            secondarySolution = new List<String>();
            secondarySolution.add('--None--');
            
            extensionPeriod = new List<String>();
            extensionPeriod.add('--None--');
            
            distributors = new List<String>();
            distributors.add('--None--');
            
            partnerIndustry = new List<String>();
            //partnerIndustry.add('--None--');
            
            contactNames = new List<String>();
            contactNames.add('--None--');
            
            //Added for Servicing Details Section
            servicingAccount = new List<String>();
            servicingAccount.add('--None--');
            
            serviceOption = new List<String>();
            serviceOption.add('--None--');
            
            servicingThisAccount = new List<String>();
            servicingThisAccount.add('--None--');
            
            mapPartnerIndustryToPS = new Map<String, List<String>>();
            
            mapPartnerIndustryToSS = new Map<String, List<String>>();
            
            mapAccountNameToIRAstatus = new Map<String, Boolean>();
            
            mapAccountNameToRoEstatus = new Map<String, Boolean>();
            
            mapAccountNameTolstContact = new Map<String, List<String>>();
            
            lstParterAccountName = new List<String>();
            
            getTAM = New Map<Id,string>();
        }
    }
}