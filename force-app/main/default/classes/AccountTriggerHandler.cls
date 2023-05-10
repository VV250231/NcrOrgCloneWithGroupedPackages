/****************************************************************************************************************
*   ClassName :   AccountTriggerHandler
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1788     31 Jan 2022     Kapil Bhati          Removed hardcoded profile Id from blockAccountCreate method
EBA_SF-2334     3rd Oct 2022    Puneet Bhatia		 Remove SF Automation to populate default Sales Org Code for CATM ONLY Accounts
****************************************************************************************************************/
public class AccountTriggerHandler {
    final String ADMINNSC_QLID = 'adminnsc';    
    User currUsr;
    
    public AccountTriggerHandler() { 
        if(!CPQTriggerControl.cpqSpclHdlgNew)
            currUsr = [SELECT Profile.Name from User where Id =:Userinfo.getUserId()]  ;
    }
    /*************************************************************************************************
* Author        :   Ajay Dixit   
* Date          :   24-11-2020
* Param         :   accList:  List of new Accounts
* Return        :   
* Description   :   Filters out records other than Accounts (Customer/Partner Record Type)
*************************************************************************************************/
    public List < Account > fltrAccOnlyRT(List < Account > accLst) {
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Customer).getRecordTypeId();
        Id prtnrRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Partner).getRecordTypeId();
        List < Account > fltrLst = new List < Account > ();
        for (Account acc: accLst) {
            if (acc.RecordTypeId == custRecTypeId || acc.RecordTypeId == prtnrRecTypeId) fltrLst.add(acc);
        }
        return fltrLst;
    }
    /*************************************************************************************************
* Author        :   Ajay Dixit   
* Date          :   15-APR-2021
* Param         :   accList:  List of new Accounts
* Return        :   
* Description   :   Filters out records Sites
*************************************************************************************************/
    public List < Account > fltrSites(List < Account > accLst) {
        Id custRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Site).getRecordTypeId();      
        List < Account > fltrLst = new List < Account > ();
        for (Account acc: accLst) {
            if (acc.RecordTypeId == custRecTypeId) fltrLst.add(acc);
        }
        return fltrLst;
    }
    
    /*************************************************************************************************
* Author        :   IDC, NSC   
* Date          :   11-01-2019
* Param         :   accList:  List of new Accounts
* Return        :   
* Description   :   Prevent users from creating duplicate MCN Accounts
*************************************************************************************************/
    public void vldtDupMCN(List<Account> accLst) {
        Map<String, Account> unqAccMap = new Map<String, Account>();
        Set<String> accIdSet = new Set<String>();
        // Added by DIvya
        //User  currentUserProfile = [SELECT Profile.Name from User where Id =:Userinfo.getUserId() ]  ;
        for(Account acc : accLst)  {   
            if(String.isNotBlank(acc.Master_Customer_Number__c)) {
                if(!unqAccMap.containsKey(acc.Master_Customer_Number__c)) {
                    unqAccMap.put(acc.Master_Customer_Number__c, acc);  
                    if(acc.Id != NULL) accIdSet.add(acc.Id);
                } else  {
                    if(acc.Id != NULL) 
                        //Error msg for Acc_Err1 Custom label
                        //'Another Account "' + acc.Name + '" with same Master Customer Number -' + acc.Master_Customer_Number__c + ' exist in updated Accounts list.
                        acc.addError((string.format(system.label.Acc_Err1,new List<string>{acc.Name,acc.Master_Customer_Number__c})));
                    
                    else 
                        //Error msg for Acc_Err2 Custom label
                        //Another Account "' + acc.Name + '" with same Master Customer Number -' + acc.Master_Customer_Number__c + ' exist in new Accounts list.
                        acc.addError((string.format(system.label.Acc_Err2, new List<String>{acc.Name,acc.Master_Customer_Number__c})));
                } 
            } 
        }
        
        if (!unqAccMap.isEmpty()) {
            for(Account dupAcc : [Select Name, Master_Customer_Number__c from ACCOUNT WHERE Master_Customer_Number__c IN :unqAccMap.keySet() AND Id NOT IN :accIdSet]) {
                if(unqAccMap.containsKey(dupAcc.Master_Customer_Number__c) ) {
                    unqAccMap.get(dupAcc.Master_Customer_Number__c).addError((string.format(system.label.Acc_Err3, new List<string>{dupAcc.Name,dupAcc.Master_Customer_Number__c})));    } 
            } 
            //Error msg for Acc_Err3 Custom label
            //'Another account "' + dupAcc.Name + '" with same Master Customer Number -' + dupAcc.Master_Customer_Number__c + ' exist in System. Please update Account "Master Customer Number" to a new number
        }            
    }
    
    /*************************************************************************************************
* Author        :   Admin NSC   
* Date          :   12-03-2015
* Param         :   newAccountList:  List of new Accounts
* Return        :   
* Description   :   Populate Corp Area, Corp Region, Corp Theatre, IPS Area, IPS Region fields on Account on before insert
*************************************************************************************************/
    public void PopulatingIpsfieldsonaccount(List<Account> newAccts) {
        Set<String> ctrycode = new Set<String>();
        
        for (Account acc :newAccts) {
            
            if(String.isNotBlank(acc.Account_Country_Code__c)) {
                ctrycode.add(acc.Account_Country_Code__c);
            }
        }
        
        if(!ctrycode.isEmpty()) {
            List<IPS_Field_Country_Code__c> ipsInfo = getIPSFldsInfoFrmCtryCode(ctrycode);
            
            if (!ipsInfo.isEmpty()) {
                
                for(Account acc :newAccts) {
                    for(IPS_Field_Country_Code__c ip :ipsInfo) {
                        if(acc.Account_Country_Code__c == ip.Account_Country_Code__c) {
                            acc.Corp_Area__c=ip.Corp_Area__c;
                            acc.Corp_Region__c=ip.Corp_Region__c;
                            acc.Corp_Theatre__c=ip.Corp_Theater__c;
                            acc.IPS_Area__c=ip.IPS_Area__c;
                            acc.IPS_Region__c=ip.IPS_Region__c;
                        }
                    }
                }
            }
        }
    }
    
    public List<IPS_Field_Country_Code__c> getIPSFldsInfoFrmCtryCode(Set<String> ctrycode) {
        List<IPS_Field_Country_Code__c> ipsInfo = new List<IPS_Field_Country_Code__c>();
        if(ctrycode != null && ctrycode.size() > 0) {
            ipsInfo = [SELECT Account_Country_Code__c,Corp_Area__c,Corp_Region__c,Corp_Theater__c,IPS_Area__c,IPS_Region__c FROM IPS_Field_Country_Code__c WHERE Account_Country_Code__c IN: ctrycode];
        }
        return ipsInfo;
    }
    
    /*************************************************************************************************
* Author        :   Gayatri Sharma   
* Date          :   30-07-2012  
* Param         :   newAccountList:  List of new Accounts
* Return        :   
* Description   :   Account Records needed to be updated if Partner Non Ror Object Records with matching Master Customer Number and Country code exists.
*************************************************************************************************/
    public void populateValuesFromPartnerNonROR(List<Account> newAccLst) {
        List<String> ctryCodeWthMCN = new List<String>();
        Map<String,Partner_NonROR__c> prtnrMap = new Map <String,Partner_NonROR__c>();
        
        for(Account acc : newAccLst) {
            if(acc.Account_Country_Code__c != null && acc.Master_Customer_Number__c != null){
                ctryCodeWthMCN.add(acc.Account_Country_Code__c+acc.Master_Customer_Number__c);
            }    
        }
        
        if (!ctryCodeWthMCN.isEmpty()) {
            List<Partner_NonROR__c> partners = [select Country_with_Master_customer_Number__c, Master_Customer_Number__c,Address1__c ,Address2__c , City__c , State__c , Zip_Code__c , Country_Code__c , Website_Address__c , Telephone__c, Doing_Business_As__c, Application_Referral__c from Partner_NonROR__c where Country_with_Master_customer_Number__c in :ctryCodeWthMCN];
            
            if(!partners.isEmpty()) {
                for(Partner_NonROR__c partner : partners) {
                    prtnrMap.put(partner.Country_with_Master_customer_Number__c, partner);
                }
                
                for (Account acc : newAccLst) {
                    if(prtnrMap.containsKey(acc.Account_Country_Code__c+acc.Master_Customer_Number__c)){
                        if(acc.BillingStreet == null){
                            acc.BillingStreet = (prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Address1__c + ' ' + prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Address2__c);
                        }
                        if(acc.BillingCity == null){
                            acc.BillingCity = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).City__c;
                        }
                        if(acc.BillingState == null){
                            acc.BillingState = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).State__c;
                        }
                        if(acc.BillingCountry == null){
                            acc.BillingCountry = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Country_Code__c;
                        }
                        if(acc.BillingPostalCode == null){
                            acc.BillingPostalCode = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Zip_Code__c;
                        }
                        if(acc.ISO_Country_Code__c == null){
                            acc.ISO_Country_Code__c = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Country_Code__c;
                        }
                        if(acc.Website == null){
                            acc.Website = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Website_Address__c;
                        }
                        if(acc.Phone == null){
                            acc.Phone = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Telephone__c; 
                        }
                        /* if(acc.Doing_Business_As__c == null){
acc.Doing_Business_As__c = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Doing_Business_As__c; 
}*/
                        //Commentig due to EBA_SF-688
                        if(acc.Comments__c == null){
                            acc.Comments__c = prtnrMap.get(acc.Account_Country_Code__c+acc.Master_Customer_Number__c).Application_Referral__c; 
                        }
                    }
                }
            }
        }
    }
    
    /*************************************************************************************************
* Author        :   Darshan Singh Farswan   
* Date          :   30-07-2012 
* Param         :   newAccountList:  List of new Accounts
* Return        :   
* Description   :   An account and contact are associated Lead conversion takes place. We need to block make 
sure that the user only updates the existing account and do not create a new one.
*************************************************************************************************/
    public void blockAccountCreate(List<Account> newAccLst) {
        /* Set<Id> PrflIDs = new set<Id>{'00e700000013gXJAAY','00e700000013gX4AAI','00e700000013b75AAA','00e70000001BOS6AAO','00e700000013b70AAA','00e700000013b6PAAQ','00e70000001BOdxAAG','00e70000001BOe2AAG','00e70000001BOe7AAG','00e70000001Nz5RAAS','00e70000001Nz5WAAS',
'00e70000000sR8WAAU','00e70000000sR8XAAU','00e70000000sR8YAAU','00e70000000sR8ZAAU','00e70000000sR8aAAE','00e70000000x3XVAAY','00e70000000x3oMAAQ','00e70000000x3oSAAQ','00e70000000x4ZoAAI','00e70000000x4ZpAAI','00e70000000x8q3AAA',
'00e70000000x908AAA','00e70000000x90DAAQ','00e70000000xA4NAAU','00e70000000xATXAA2','00e70000000xATYAA2','00e70000000xATZAA2','00e70000000xBICAA2','00e70000000xBIDAA2','00e70000000xBIEAA2','00e70000000xBoNAAU','00e70000000xBoSAAU',
'00e70000000xBoXAAU','00e70000000xBpuAAE','00e70000000xBqJAAU','00e70000000xBqOAAU','00e70000000xBvJAAU','00e70000000xC4uAAE','00e70000000xC5EAAU','00e70000000xCWAAA2','00e70000000xCagAAE','00e70000000xE3lAAE','00e70000000xE7xAAE',
'00e70000000xFkDAAU','00e70000000xGM5AAM','00e70000000xOrWAAU','00e70000000xP2VAAU','00e70000000xSgLAAU','00e70000000xU61AAE','00e70000000xUM9AAM','00e70000000xUMAAA2','00e70000000xUTZAA2','00e70000000xUZSAA2','00e70000000xUzkAAE',
'00e70000000xV4zAAE','00e70000000xV54AAE','00e70000000xV59AAE','00e70000000xV5EAAU','00e70000000xV6RAAU','00e70000000xVA4AAM','00e70000000xVDIAA2','00e70000000xVDNAA2','00e70000000xVJpAAM','00e70000000xVK9AAM','00e70000000xVKOAA2',
'00e70000000xVKPAA2','00e700000013YIGAA2','00e700000013YgPAAU','00e700000013fIDAAY','00e700000013gAKAAY','00e700000013gK6AAI','00e700000013gX9AAI','00e70000001BO6YAAW','00e70000001BOL5AAO','00e70000001BOLUAA4','00e70000001BP38AAG',
'00e70000001NyoaAAC','00e70000001NyofAAC','00e70000001NypJAAS','00e70000001NyxmAAC'};*/
        // EBA_SF-1788 Removed hardcoded profile Ids - Modified by Kapil Bhati    
        List<Id> prflIDsList = System.Label.Profile_Ids.split(',');
        Set<Id> PrflIDs = new Set<Id>(prflIDsList);        
        List<Lead> leads = new List<Lead>();
        List<Id> acId = new List<Id>();
        Set<Id> accountIDs = new Set<Id>();
        
        if(PrflIDs.contains(UserInfo.getProfileId())) {
            for(Account acc : newAccLst){
                acId.add(acc.id);
            }
            
            leads = [Select ConvertedAccountId from Lead where ConvertedAccountId in :acId];
            
            if(!leads.isEmpty()){
                for(Lead l : leads){
                    accountIDs.add(l.ConvertedAccountId);
                }
                for(Account acct : newAccLst) {
                    if(accountIDs.contains(acct.id)){
                        acct.adderror(system.label.Acc_Err7);
                    }
                }
            }
        }
    }
    // Error msg for Custom label Acc_Err7
    //Prior to converting a lead, an Account must be created in ERP.  If your lead is associated with</br> an existing Account, please return to the previous screen and select "Attach to Existing" account.</br></p> <b>Tips on Account creation-</b></br><p>If the Account you are attempting to create does not exist in NSC, and is located in an ERP country,</br> then please create the account in CWEB. The Account will appear in NSC in 24 hours</br> and you will be able to select it as "Attach to Existing" account when converting the Lead.</p></br> <p>If the account you are attempting to create does not exist in NSC, and is located in a non-ERP country,</br> then please go to the “Account Request” tab in NSC and request for a new account.</br> Once Admin creates the new Account in NSC, you will be able to select it as "Attach to Existing" account when converting the Lead.</br></p>
    
    /*************************************************************************************************
* Author        :   Darshan Singh Farswan   
* Date          :   01-06-2011
* Param         :   partnerAccIds:  Set of Account Ids
* Return        :   
* Description   :   The NSCContact Extract only sends the contacts that are modified after the Timestamp. But if the related Account are modified,
contacts are not modified. This trigger modifies the Contacts whenever the account, fulfilling certain criteria is updated. 
*************************************************************************************************/
    public void updateContactsForPartnerAccts(Set<Id> prtnrAccIds) {
        if (prtnrAccIds != null && prtnrAccIds.size() > 0) {
            List<Contact> cntLst = [SELECT Id FROM Contact WHERE AccountId IN :prtnrAccIds AND Portal_user__c =  true AND web_portal_login__c != NULL];
            if(!cntLst.isEmpty()) update cntLst;            
        }
    }
    
    /*************************************************************************************************
* Author        :   Admin, NSC 
* Date          :   09-09-2015
* Param         :   partnerAccIds:  Set of Account Ids
* Return        :   
* Description   :   This trigger updates the record type of the contacts if record type of account is changed.
*************************************************************************************************/
    public void UpdateContactRecordTypeFromAcct(Set<Id> actIdSet) {
        // Create a map which describes what will be the record type of contact for particular record type of the account
        Map<String,String> actToConRecType = new Map<String,String>{'Customer'=>'CustomerContact',                                                                 
            'Partner'=>'PartnerContact'};     
                
                // Get all Active Account RecordTypes that are available to the running user
                Map<String,Id> accTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Account.SObjectType);
        
        // Get all Active contact RecordTypes that are available to the running user
        Map<String,Id> cntTypesMap = RecordTypeInfoUtil.GetRecordTypeIdsByDeveloperName(Contact.SObjectType);
        
        // List of the account records for which record type is changed
        List<Account> chgRecTypActLst;
        
        
        if(actIdSet != null && actIdSet.size() > 0) {
            List<Contact> conLst = new List<Contact>();
            
            chgRecTypActLst = [SELECT Id, RecordType.Name, 
                               (SELECT Id, RecordTypeId FROM Contacts) FROM Account WHERE Id IN :actIdSet];
            
            for (Account act : chgRecTypActLst) {
                // Check respective contact record type of account is there or not.One more check either current account type is available for current user or not.
                if (actToConRecType.get(act.RecordType.Name) != null && accTypesMap.get(act.RecordType.Name) != null) {
                    if (cntTypesMap.get(actToConRecType.get(act.RecordType.Name)) != null) {
                        Id recordTypeId = cntTypesMap.get(actToConRecType.get(act.RecordType.Name));
                        for (Contact con : act.contacts) {
                            if (con.RecordTypeId != cntTypesMap.get('NCRContact')) {
                                con.recordTypeId = recordTypeId;
                                conLst.add(con);
                            }
                        }
                    }
                }
            }
            
            if (conLst.size() > 0) {
                update conLst;
            }
        }
    }
    
    
    /**************************************************************************************************************************************** 
* Author        :   Darshan Singh Farswan
* Date          :   03-05-2011  
* Param         :   newAccountList  :  List of new Accounts               
* Return        :   
* Description   :   This method will populate two fields Account_Region__c, Area__c, Region__c which are dependent on Account_Country_Code__c and Line Of Business (LOB)

* Change Request           Developer name       Last Modified Date      Last Modified by                Description
* NSC_AGILE-611            Saritha karuturi     11/20/2015              Saritha Karuturi                Modified the Line 47# in if condition to update the account area,theater,region on edit and save.
The previous logic is existed when account is edited then change the value for Industry and then save.

* NSC_AGILE-178            Shiv Mahla           1/29/2016               Shiv Mahla                      User wants to overide the Region,Theatar, Area Mapping regardless what is the value in LOB and Country Code.
I am adding below line of condition in the code.
Trigger.new[i].Account_Country_Code__c!=Trigger.old[i].Account_Country_Code__c || Trigger.new[i].LOB__c!=Trigger.old[i].LOB__c
Note: But if user change LOB and Country Code Region, Theatar and Area will populate from mapping table.    
EBA_SF-1648 :               Saurav              11/30/2021              Saurav                          Region/Theater MCN data is based on the Corporate Country Codes instead of Account Country Code
*****************************************************************************************************************************************/
    public void populateTheaterAreaOnAccount(List<Account> newAccLst) { 
        Map<String,String> indLOB = new Map<String, String>{'FINANCIAL'=>'FINANCIAL','HOSPITALITY'=>'HOSPITALITY','RETAIL'=>'RETAIL','T&T'=>'T&T','TLG'=>'HOSPITALITY'};//'TLG'=>'Travel to 'TLG' =>'HOSPITALITY' NC_AGILE-2790-Change Account LOB from Travel to Hospitality
            Map<String,Theater_Area_Mapping__c> mapInfo = NSCCommonInfoUtil.getInstance().getTheaterAreaMapping();
        Map<String,Theater_Area_Mapping__c> SMB_mapInfo = NSCCommonInfoUtil.getInstance().SMB_getTheaterAreaMapping();  
        Theater_Area_Mapping__c areaInfo = null;    
        Theater_Area_Mapping__c SMBareaInfo = null;
        
        for (Account acc : newAccLst)  {
            if (String.isNotBlank(acc.Industry)) {
                String LOB = acc.Industry.Split(':',2).get(0);
                acc.LOB__c = indLOB.containsKey(LOB) ? indLOB.get(LOB) : '';
            } else { 
                acc.LOB__c = '';}
            
            //--------------------------------Change By Saurav Start Here (EBA_SF-1648)-------------------------------------------------------------------      
            if (String.isNotBlank(acc.Account_Country_Code__c)||String.isNotBlank(acc.BillingCountry)) {
                areaInfo = null;
                String ctryLOB = null;
                if(acc.LOB__c !='HOSPITALITY'){
                    ctryLOB = acc.Account_Country_Code__c + acc.LOB__c;
                }
                else if(acc.LOB__c=='HOSPITALITY'){
                    
                    
                    if (string.isnotBlank(acc.BillingCountry))
                    {
                        ctryLOB = acc.BillingCountry + acc.LOB__c;
                    }
                    else {
                        ctryLOB = acc.Account_Country_Code__c + acc.LOB__c;                        
                    }
                }
                //-------------------------------------------End Here-----------------------------------------------------------------------------           
                if (!acc.CDM_SMB_Flag__c && String.isNotBlank(acc.LOB__c) && (mapInfo.containsKey(ctryLOB))){
                    areaInfo = mapInfo.get(ctryLOB);
                    acc.Region__c = areaInfo.Theater__c; 
                    acc.Area__c = areaInfo.Area__c;
                    acc.Account_Region__c = areaInfo.Region__c;
                }
                //--------------------------------Change By Saurav Start Here (EBA_SF-1648)-------------------------------------------------------------------     
                else if (acc.CDM_SMB_Flag__c && acc.BillingCountry =='US' && acc.LOB__c=='HOSPITALITY' && String.isNotBlank(acc.LOB__c) && (SMB_mapInfo.containsKey(ctryLOB))){ 
                    //-------------------------------------------End Here------------------------------------------------------------------------------------------          
                    SMBareaInfo = SMB_mapInfo.get(ctryLOB); 
                    acc.Region__c = SMBareaInfo.Theater__c;     
                    acc.Area__c = SMBareaInfo.Area__c;  
                    acc.Account_Region__c = SMBareaInfo.Region__c;
                    
                }
                else{
                    acc.Region__c = ''; 
                    acc.Area__c = '';
                    acc.Account_Region__c = '';   
                }
            }
            
            if(String.isNotBlank(acc.MDM_Billing_Location_Country_Code__c)) {
                areaInfo = null;                
                String ctryLOB = String.ValueOf(aCC.MDM_Billing_Location_Country_Code__c) + String.ValueOf(acc.LOB__c);
                
                if(String.isNotBlank(acc.LOB__c) && (mapInfo.containsKey(ctryLOB))){
                    areaInfo = mapInfo.get(ctryLOB);
                    acc.Billing_Theatre__c = areaInfo.Theater__c; 
                    acc.Billing_Area__c = areaInfo.Area__c;
                    acc.Billing_Region__c = areaInfo.Region__c;
                }
                else{
                    acc.Billing_Theatre__c = ''; 
                    acc.Billing_Area__c = '';
                    acc.Billing_Region__c = '';   
                }
            }
        }
    }
    
    
    /*************************************************************************************************
* Author        :   Admin NSC
* Date          :   06-10-2013   
* Param         :   newAccountList  :  List of new Accounts               
* Return        :   
* Description   :   This method is use to prevent non-admin users from updating account owner.
*************************************************************************************************/
    /* public void blockOwnerShipChangeOnAccount(List<Account> newAccLst) {
Set<Id> adminPrfs = new Set<Id>{'00e700000013gAK','00e700000013gAKAAY','00e700000013gPe','00e700000013gPeAAI','00e700000013YgP','00e700000013YgPAAU','00e70000000x3eg','00e70000000x3egAAA','00e70000000x8q3','00e70000000x8q3AAA','00e70000000xE3l','00e70000000xE3lAAE','00e70000000xE7x','00e70000000xE7xAAE','00e70000000sR8U','00e70000000sR8UAAU','00e700000013YIG','00e700000013YIGAA2','00e70000000xUTZAA2'};    
if(!adminPrfs.contains(UserInfo.getProfileId())) {
for (Account acc : newAccLst) {
acc.addError(system.label.Acc_Err4); 
}
//Error msg for Acc_Err4 Custom label
//You are not authorized to change the Account Owner. Only System Administrators can transfer records.
}

} commented as per of story EBA_SF-1475 */
    
    /*************************************************************************************************
* Author        :   Admin NSC
* Date          :   10-03-2008  
* Param         :   primConAccList :  List of accounts for which primary contact field changed during update               
* Return        :   
* Description   :   trigger on after update of an Account
Checks the primary contact checkbox on the contact if contact is selected as primary
UnChecks the primary contact checkbox on the contact if contact is removed as primary
makes use of the 2 validation rules for insert

// related validation rules
Validation Rule:
1. On Account:
PrimaryContact_From_Account
And( LEN( Primary_Contact__c ) <> 0, NOT( ISNULL( Primary_Contact__r.AccountId ) ) , Primary_Contact__r.AccountId <> Id)
The Primary Contact should be a Contact on the Account

2. On Contact
Primary_Associated_To_Account
And( Partner_Primary_Contact__c, OR(LEN(Account.Primary_Contact__c) = 0, Id <> Account.Primary_Contact__c))
Contact should be set as Primary Contact on the Account
*************************************************************************************************/
    public void updatePrimaryContact(List<Account> prmConAccLst) {
        List<Contact> conLst = new List<Contact>();
        Map<Id, Id> accPrmConIdMap = new Map<Id, Id>(); // Account => Primary Contact map
        
        if (prmConAccLst != null && prmConAccLst.size() > 0) {
            for (Account acc : prmConAccLst) {
                
                /*  //commented - all other contacts are checked on the account as there may be bad data.
Id oldPrimaryContactId = Trigger.oldMap.get(a.Id).Primary_Contact__c;
if (oldPrimaryContactId != null) {
Contact contact = new Contact(Id = oldPrimaryContactId);
contact.Partner_Primary_Contact__c = false;
contactList.add(contact);
}  */                 
                Id prmConId = acc.Primary_Contact__c;                
                // check Partner Primary Contact field on Primary Contact
                if (prmConId != null) {
                    conLst.add(new Contact(Id = prmConId, Partner_Primary_Contact__c = true));
                    accPrmConIdMap.put(acc.Id, prmConId);
                }    
            }
            
            Map<Id, Account> accMap = new Map<Id, Account>(prmConAccLst);
            List<Contact> acctConts = [Select Id, AccountId, Partner_Primary_Contact__c from Contact where AccountId IN :accMap.keySet()];
            
            for (Contact c : acctConts) {
                Id primaryContactId = accPrmConIdMap.get(c.AccountId);
                
                // uncheck Partner Primary Contact field on Non Primary Contact
                if (c.Id != primaryContactId && c.Partner_Primary_Contact__c) {
                    c.Partner_Primary_Contact__c = false;
                    conLst.add(c);
                }
            }    
        }
        
        if(!conLst.isEmpty()) update conLst;
    }
    /*************************************************************************************************
* Author        :   Shephalika Belapurkar        
* Date          :   03-05-2011       
* Param         :   newAccountList  :  List of new Accounts               
* Return        :   
* Description   :   Account Owner Name needed for Fund Claim object is populated through this trigger.        
*************************************************************************************************/
    public void populateAccountOwnerName(List<Account> newAccLst) {
        if (newAccLst != null && newAccLst.size() > 0) {
            List<ID> accOwrIds = new List<ID>();
            Map <Id, String> usrMap = new Map<Id, String>();
            
            for (Account acc : newAccLst) {
                accOwrIds.add(acc.OwnerId);     
            } 
            
            if(!accOwrIds.isEmpty()) {
                List<User> uLst = [Select Id, LastName, FirstName from User where id in :accOwrIds];
                for(User u: uLst){
                    usrMap.put(u.Id, u.FirstName +' '+ u.LastName);
                }
                for(Integer i=0;i < accOwrIds.size();i++){
                    if(usrMap.containskey(accOwrIds.get(i))){
                        newAccLst[i].Account_Owner_Name__c = usrMap.get(accOwrIds.get(i));
                    }
                }
            }
        }
    }
    
    
    
    /********************************* Sync NSC Account Owner with CDM- Start *******************************************/
    public void syncAccountOwnerwithCDM(List<Account> updAccts) {
        CDM_Config__mdt cdmCnfg = [SELECT Allow_Account_Sync__c FROM CDM_Config__mdt WHERE QualifiedApiName = 'CDM' LIMIT 1];
        
        if(cdmCnfg.Allow_Account_Sync__c && !updAccts.isEmpty()) {                           
            System.enqueueJob(new CDMOrgAPIController(updAccts)); //ID jobID = System.enqueueJob(new CDMOrgAPIController(updAccts));
        }
    }
    /********************************************************Sync NSC Account Owner with CDM- End************************/ 
    
    /*****************************************************NSC Account Owner Populate from CDM Account Manager Quicklook *******************************************/   
    public Void UpdateAccOwner(List<Account> AccLst)
    {
        Set<String> AccMgrQlid = New Set<String>();
        Map<string,string> usrqlkmap = new Map<string,string>();
        
        for (Account A : AccLst)
        {
            if (A.CDM_Account_Manager__c != NULL)
            {
                AccMgrQlid.Add(A.CDM_Account_Manager__c.toLowerCase());
            }
        }
        
        AccMgrQlid.add(ADMINNSC_QLID);
        
        if (!AccMgrQlid.IsEmpty()) {
            
            for (User U : [Select Id,Quicklook_ID__c from USER where Quicklook_ID__c IN: AccMgrQlid AND UserType = 'Standard' AND isactive = true LIMIT 50000 ]){  
                if(!string.isblank(U.Quicklook_ID__c)) {                    
                    usrqlkmap.put(U.Quicklook_ID__c.toLowerCase(), U.Id);    
                }                
            }
        }
        
        if(!usrqlkmap.isEmpty()) {
            for(Account a : AccLst) {
                String cdmMgrQLId = a.CDM_Account_Manager__c;
                
                if(!String.isBlank(cdmMgrQlId)){
                    String usrId = usrqlkmap.get(cdmMgrQlId.toLowerCase());
                    a.OwnerId = usrId != null ? usrId : usrqlkmap.get(ADMINNSC_QLID);
                }                
            }
        }
    }
    /************************************************************END**************************************************************/  
    
    /*****************************************************Populate Interface Source Field*******************************************/
    public  void populateInterfaceSource(List<Account> accLst)
    {        
        Set<string> grpUsr = new Set<string>();
        //get all group memebers
        for(GroupMember gm : [select UserorGroupID from GroupMember where group.name = 'Account Admin']){
            String UsrorGrpID = gm.UserorGroupID;            
            if (UsrorGrpID.startsWith('005')) {
                grpUsr.add(UsrorGrpID);
            }
        }
        
        if(currUsr.Profile.Name != 'Soup Integration' && currUsr.Profile.Name != 'iPaas Administration' && currUsr.Profile.Name != 'Data Backup and Recovery Admin') {
            for(Account a : accLst) {                
                if(grpUsr.contains(UserInfo.getUserId()) && String.Isblank(a.Account_CDM_ID__c) && String.Isblank(a.UpdateByLeadConversion__c)) {
                    a.MDM_Data_Source_Code__c = 'Salesforce';
                    a.Interface_Source__c='Salesforce';
                } else {      
                    
                    if (Userinfo.getUserType() != 'PowerPartner') {
                        
                        a.addError(system.label.Acc_Err5);
                    } else {
                        a.addError(system.label.Acc_Err6);
                    }
                }
            }
        }
    }   
    // Error msg for Acc_Err5 Custom label
    //You are not authorized to create an account in NSC.If you want create a new acount, please raise a request to CDM for the same.
    //Error msg for Acc_Err6 Custom label
    //You are not authorized to create an account in the Partner Community.  Please use the “Choose Existing” option for Account – search and select your account.
    
    /************************************************************END**************************************************************/ 
    
    
    /******************************* Handle Lead Conversion -start*****************************/    
    public void HandleLeadConversion(List<Account> newAccLst) {
        
        for (Account ac : newAccLst) {            
            Account oldAc = (Account)Trigger.oldMap.get(ac.ID);
            
            If (ac.UpdateByLeadConversion__c == 'Y') {
                CheckRecursive.checkLeadConversionRun();
                ac.UpdateByLeadConversion__c = null; 
                
                If (!String.isBlank(ac.BillingStreet)) {
                    ac.BillingStreet = oldAc.BillingStreet;
                }  
                
                If (!String.isBlank(ac.BillingCity)) {
                    ac.BillingCity = oldAc.BillingCity;   
                }  
                
                If (!String.isBlank(ac.BillingState)) {
                    ac.BillingState = oldAc.BillingState;
                }  
                
                If (!String.isBlank(ac.BillingPostalCode)) {
                    ac.BillingPostalCode = oldAc.BillingPostalCode;
                }  
                
                If (!String.isBlank(ac.BillingCountry)) {
                    ac.BillingCountry = oldAc.BillingCountry;
                }                  
            }
        }
    }    
    /******************************* Handle Lead Conversion -end*****************************/   
    
    
    /*************************************************************************************************
* Author        :   Admin NSC
* Date          :   9-13-2010  
* Param         :   newAccountList  :  List of new Accounts               
* Return        :   
* Description   :   This method is used as replacement for updateMCN trigger on Account. 
This method is use to update MCN on new Account created through Account Request.
*************************************************************************************************/
    public void updateMCNonAccount(List<Account> newAccLst) {
        try
        {
            List<Account> acclst=new List<Account>();
            set<string> recordTypeSet=new set<string>();
            
            for(RecordType rt : [Select Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Account' AND Name in('customer','Partner')]) {
                recordTypeSet.add(rt.Id);   
            } 
            
            for (Account account : newAccLst) 
            {
                Account accountobj = new AccountUtil().populateAccwithMCN(account, recordTypeSet);
                if(accountobj != null) acclst.add(accountobj);   
            }
            if(acclst.size()<=100)
            {
                update acclst;
            }
            else
            {
                list<account> fstbatchlst=new list<account>();
                list<account> nxtbatchlst=new list<account>();
                for(integer i=0;i<acclst.size();i++)
                {
                    if(i<100)
                    {
                        fstbatchlst.add(acclst[i]);
                    }
                    else
                    {
                        nxtbatchlst.add(acclst[i]);
                    }
                }
                update fstbatchlst;
                update nxtbatchlst;
            }
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
        }
    }
    
    /*************************************************************************************************
* Author        :   Brian Rickard
* Date          :   08-14-2017  
* Param         :   accounts  :  List of new Accounts               
* Return        :   
* Description   :   Send DI Account data to ServiceNow
*************************************************************************************************/
    public void syncToServiceNow(List<Account> accts)
    {
        Set<ID> accountIds = getAccountIDs(accts);
        List<Zuora__CustomerAccount__c> zuoraAccts = [select Zuora__AccountNumber__c, Zuora__External_ID__c, Zuora__Account__c, BillToFlag__c 
                                                      from Zuora__CustomerAccount__c 
                                                      where Zuora__Account__c in :accountIds order by Id limit 1];
        Map<ID, AccountTeamMember> accMap = new Map<ID, AccountTeamMember>();
        for(AccountTeamMember act : [SELECT AccountId,TeamMemberRole, UserId, user.quicklook_id__C FROM AccountTeamMember WHERE AccountID =: accountIds and TeamMemberRole = 'Digital Strategy Manager' order by LastModifiedDate]){
            accMap.put(act.AccountID, act);
        }
        
        List<string> accJsonList=new List<String>();
        for(Account account : accts)
        {
            try
            {
                if(account.Subscription_Group__c == 'Digital Insight' && String.isNotEmpty(account.DI_Customer__c))
                {
                    string accountJson = '';
                    try 
                    {
                        // Add the IDs that we need from the Customer Account
                        String diMgrQlid = '';
                        AccountTeamMember atm= accMap.get(account.Id);
                        if(atm != null){
                            diMgrQlid = atm.user.quicklook_id__c;
                        }
                        Zuora__CustomerAccount__c za = findZuoraAccount(account, zuoraAccts);
                        accountJson = InjectZuoraIDs(account, za, diMgrQlid);
                    }
                    catch(exception e) 
                    {
                        accountJson = JSON.serializePretty(account); // If we don't have the Billing Account, we still send the data
                    }
                    
                    accJsonList.add(accountJson);
                    // Make the call with the modified json
                    //DIServiceNowInterface.SendToSoup(accountJson, 'Account', 'POST');
                }
            }
            catch(Exception e)
            {
                System.debug('Failed to send Account to SOUP for ServiceNow. Exception: ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        
        if ((CheckRecursive.checkOppOrgUpdtBtchRun()) && (!System.isFuture()) && (!System.isBatch())) {
            DIServiceNowInterface.SendToSOUP(accJsonList, 'Account', 'POST'); 
        }
        
    }
    
    private Set<ID> getAccountIDs(List<Account> accts)
    {
        Set<ID> ids = new Set<ID>(); 
        for(Account a : accts)
        {
            ids.Add(a.id);
        }
        return ids;
    }
    
    private Zuora__CustomerAccount__c findZuoraAccount(Account a, List<Zuora__CustomerAccount__c> zuoraAccounts) { 
        
        Zuora__CustomerAccount__c billToAccount = null; 
        Zuora__CustomerAccount__c shipToAccount = null; 
        
        for(Zuora__CustomerAccount__c za : zuoraAccounts)
        {
            if(za.Zuora__Account__c == a.Id) {
                if(za.BillToFlag__c == 'Yes')
                {
                    billToAccount = za;  // Bill-to is the one we want, so if we find it, just break out so we can return it.
                    break;
                }
                else
                {
                    shipToAccount = za; // We may still find a Bill-To account, so don't break out yet. 
                }
                
            }
        }
        
        if(billToAccount != null) { return billToAccount;}
        if(shipToAccount != null) { return shipToAccount;}
        
        return null;
    }
    
    // Helper method for syncToServiceNow (above)
    private static string InjectZuoraIDs(Account account, Zuora__CustomerAccount__c zuoraAccount, String diMgrQL)
    {
        string js = JSON.serializePretty(account);     
        
        // Pull the ending bracket off the request, add two attributes from the Zuora Customer Account, 
        // and then close it all back up. Whitespace and newlines are just so it looks nice in the logs.
        js = js.substring(0, js.Length()-2) + ',\n'; 
        if(zuoraAccount !=null){
            js = js + '  "SCA_Account_Id" : "' + zuoraAccount.Zuora__External_ID__c + '",\n';
            js = js + '  "SCA_Account_Number" : "' + zuoraAccount.Zuora__AccountNumber__c + '",\n';
        }
        
        
        if(string.isNotBlank(diMgrQL)){
            js = js + '  "Digital_Strategy_Manager_Quicklook" : "' + diMgrQL + '"\n';   
        }
        else{
             js = js + '  "Digital_Strategy_Manager_Quicklook" : ' + null + '\n';   
        }
        
        js=js+'}';
        
        return js;
    }
    
    public void populateDefaultSalesOrgCode_onInsert(List<Account> newAccLst) {
        List<Account> dftOrgCodeAccts = new List<Account>();
        
        for(Account acc : newAccLst) {           
            if(!isCATMAccount(acc) && String.isBlank(acc.Global_Sales_Org_Code__c) && String.isBlank(acc.CDM_Source_SOC__c) && acc.Use_Default_Sales_Org_Code__c) {
                dftOrgCodeAccts.add(acc);  
            }            
        }
        
        if (!dftOrgCodeAccts.isEmpty()) { 
            populateDefaultSalesOrgCode(dftOrgCodeAccts);
        } 
    }
        
        
    public void populateDefaultSalesOrgCode(List<Account> accLst) { 
        if(CheckRecursive.runDfltSlsOrgOnce() && (UserInfo.getName().toUpperCase().contains('SOUP')  || NSCCommonInfoUtil.getInstance().getSystemUsers().contains(UserInfo.getUserId()))){
            Set<String> ctryCodeSet = new Set<String>();
            Set<String> indrySet = new Set<String>();
            Map<String,Map<String, String>> indCtryCodeMap = new Map<String,Map<String, String>>();
            
            for (Account acc : accLst) {
                if (String.isNotBlank(acc.Account_Country_Code__c) && String.isNotBlank(acc.Industry)) {
                    ctryCodeSet.add(acc.Account_Country_Code__c);
                    String shrtInd = acc.Industry.split(':').get(0).left(3);
                    shrtInd = shrtInd.equalsIgnoreCase('HOS') ? 'HSR' : shrtInd;
                    indrySet.add(shrtInd);
                }
            } 
            
            if ((!ctryCodeSet.isEmpty()) && (!indrySet.isEmpty())) {
                List<cdm_Default_Sales_Org__c> deftSOCs = [SELECT Default_Global_Sales_Org_Code__c,Industry__c,Operating_Unit__c 
                                                           FROM cdm_Default_Sales_Org__c 
                                                           WHERE Operating_Unit__c  IN :ctryCodeSet AND Industry__c IN :indrySet]; 
                
                for (cdm_Default_Sales_Org__c dfo : deftSOCs) {                     
                    Map<String, String> tempCtryMap = indCtryCodeMap.get(dfo.Industry__c);                     
                    if (tempCtryMap == NULL) {
                        tempCtryMap  = new Map<String, String>();                     
                        indCtryCodeMap.put(dfo.Industry__c, tempCtryMap);
                    }                 
                    tempCtryMap.put(dfo.Operating_Unit__c, dfo.Default_Global_Sales_Org_Code__c);    
                }
            }
            
            for(Account acc : accLst) {   
                // populate default Org Code
                if (String.isNotBlank(acc.Account_Country_Code__c)  && String.isNotBlank(acc.Industry)) {
                    String shrtInd = acc.Industry.split(':').get(0).left(3);
                    shrtInd = shrtInd.equalsIgnoreCase('HOS') ? 'HSR' : shrtInd;
                    
                    Map<String, String> tempCtryMap = indCtryCodeMap.get(shrtInd);
                    
                    if (tempCtryMap != NULL &&  tempCtryMap.get(acc.Account_Country_Code__c) != NULL) {
                        acc.Global_Sales_Org_Code__c  = tempCtryMap.get(acc.Account_Country_Code__c) ;
                    }
                }
            }
        } 
    }
    
    
    public Boolean isCDMAccount(Account acc) {
        return (acc.MDM_Data_Source_Code__c == 'CDM' ? true : false);
    }
    
    public Boolean isCATMAccount(Account acc) {
        return (String.isNotBlank(acc.OriginalCorporation__c) && acc.OriginalCorporation__c.toUpperCase() == System.Label.CATM_ORGCORP ? true : false);
    }
    
    public void UpdateSalesOrgOnOpps(Set<String> updGblSOAccIds) {
        if(!System.isBatch()) {
            Integer oppCount = [SELECT count() FROM Opportunity WHERE AccountId IN :updGblSOAccIds];
            
            if(oppCount > 0) {
                Database.executeBatch(new UpdateOppSalesOrgCode(updGblSOAccIds, 'Account'), 20);    
            }
        }  
    }
    
    
    /*************************************************************************************************
* Author        :   Naman Kumar(nk250337) 
* Date          :   6th September 2019  
* Param         :   accounts  :  List of new Accounts               
* Return        :   
* Description   :  Version 1.1 , which populate Channel Program Next Level Revenue field on Account Object
*************************************************************************************************/
    public void PopulateNextTierRevenue(List<Account> AccList) {
        if (PRM_TriggersController.getTriggersStatus('PopulateNextTierRevenue')) {
            if (checkRecursive.runPopulateNextTierRevenue()) {
                Set<String> channelProgramNames = new Set<String>();
                Map<String, String> mapOfChannelProgramIdName = new Map<String, String>();
                for (Account accObj :AccList) {
                    if(accObj.ChannelProgramName != null) {
                        channelProgramNames.add(accObj.ChannelProgramName);
                    }
                }
                for (ChannelProgram cpObj :[SELECT Id, Name FROM ChannelProgram WHERE Name IN:channelProgramNames]) {
                    mapOfChannelProgramIdName.put(cpObj.Name, cpObj.Id);
                }
                //converting Channel Program Ids list into Set to Call PRM_ChannelProgramUtilityCon1 constructor.
                Set<String> channelProgramIds = new Set<String>(mapOfChannelProgramIdName.values());
                PRM_ChannelProgramUtilityCon1 levelSchema = new PRM_ChannelProgramUtilityCon1(channelProgramIds);
                
                for (Account accObj :AccList) {
                    if (!String.isBlank(accObj.Partner_Program_Level__c)) {
                        String nextLevel = levelSchema.getNextLevel(mapOfChannelProgramIdName.get(accObj.ChannelProgramName), accObj.Partner_Program_Level__c);
                        String nextToNextLevel;
                        String solution;
                        if (accObj.Counterpoint__c) {
                            solution = 'Counterpoint';
                        }
                        if (nextLevel != null){
                            PRM_ChannelProgramUtilityCon1.LevelInformation levelInfoObj = levelSchema.getLevelInformation(nextLevel, accObj.Partner_Program_Industry__c, solution);
                            if (levelInfoObj != null){
                                accObj.Channel_Program_Next_Level_Revenue__c = levelInfoObj.thresholdRevenue;   
                            } else {
                                accObj.Channel_Program_Next_Level_Revenue__c = 0;
                            }
                            nextToNextLevel = levelSchema.getNextLevel(mapOfChannelProgramIdName.get(accObj.ChannelProgramName), nextLevel);
                        }
                        if (!String.isBlank(nextToNextLevel)){
                            
                            PRM_ChannelProgramUtilityCon1.LevelInformation levelInfoObj = levelSchema.getLevelInformation(nextToNextLevel, accObj.Partner_Program_Industry__c, solution);
                            if (levelInfoObj != null){
                                accObj.Channel_Program_Revenue_to_Platinum__c = levelInfoObj.thresholdRevenue;
                            } else {
                                accObj.Channel_Program_Revenue_to_Platinum__c = 0;
                            }
                        } else {
                            accObj.Channel_Program_Revenue_to_Platinum__c = 0;
                        }
                    } else {
                        accObj.Channel_Program_Next_Level_Revenue__c = 0;
                        accObj.Channel_Program_Revenue_to_Platinum__c = 0;
                    }
                }
            }        
        }
    }
    
    /*************************************************************************************************
* Author        :   Shiv Mahla 
* Date          :    
* Param         :   accounts  :  List of new Accounts               
* Return        :   
* Description   :  This trigger align partner account to channel partner level. 
To make this trigger functionaning properly make sure. we have records of channel program 
level under the channel program level with the same name as partner level.
*************************************************************************************************/
    public void enrollForChannelProgram (List<Account> AccList) {
        if (PRM_TriggersController.getTriggersStatus('enrollForChannelProgram') && checkRecursive.runenrollForChannelProgram()) {
            List<ChannelProgram> ChannelProgramList = [SELECT Id FROM ChannelProgram WHERE IsActive = true LIMIT 1];
            if(ChannelProgramList.size() > 0) {
                List<ChannelProgramLevel> channelProgLevelList = new List<ChannelProgramLevel>();
                channelProgLevelList = [SELECT Id, Name, ProgramId, Rank FROM ChannelProgramLevel WHERE ProgramId =: ChannelProgramList[0].Id];
                Map<String,ChannelProgramLevel> levelNameToRec = new Map<String,ChannelProgramLevel>();
                for(ChannelProgramLevel cpl : channelProgLevelList) {
                    levelNameToRec.put(cpl.Name, cpl);
                }
                Set<Id> actIds = new Set<Id>();
                for(Account act : AccList){
                    actIds.add(act.id);
                }
                List<ChannelProgramMember> chanPrgMemberList = [SELECT Id,partnerId, ProgramId, 
                                                                LevelId,Level.Name FROM ChannelProgramMember
                                                                WHERE partnerId IN:actIds AND ProgramId =: ChannelProgramList[0].Id
                                                               ];
                Map<Id,ChannelProgramMember> actIdToChannelProgMember = new Map<Id,ChannelProgramMember>();
                for(ChannelProgramMember cpm : chanPrgMemberList) {
                    actIdToChannelProgMember.put(cpm.partnerId, cpm);
                }
                List<ChannelProgramMember> cpmToInsert = new List<ChannelProgramMember>();
                List<ChannelProgramMember> cpmToupdate = new List<ChannelProgramMember>();
                List<ChannelProgramMember> cpmToDelete = new List<ChannelProgramMember>();
                for(Account act : AccList) {
                    // If partner program level is changed than re-enrolled to correct level.
                    if(actIdToChannelProgMember.get(act.Id) != null && levelNameToRec.get(act.Partner_Program_Level__c)!=null){
                        if(actIdToChannelProgMember.get(act.Id).level.Name != act.Partner_Program_Level__c) {
                            ChannelProgramMember cpmRec = actIdToChannelProgMember.get(act.Id);
                            cpmRec.LevelId = levelNameToRec.get(act.Partner_Program_Level__c).Id;
                            cpmToupdate.add(cpmRec);
                        }
                        // If Partner Program Level is changed but new level doesn't exist in to channle program level of respective channel program.
                        // than delete old enrollement.
                    } else if(actIdToChannelProgMember.get(act.Id) != null && levelNameToRec.get(act.Partner_Program_Level__c)==null){
                        cpmToDelete.add(actIdToChannelProgMember.get(act.Id));
                        // If enrollement doesn't exist and level is available into list. 
                    } else if(act.Partner_Program_Level__c != 'No Program Level' && act.IsPartner == true && actIdToChannelProgMember.get(act.Id) == null && levelNameToRec.get(act.Partner_Program_Level__c)!=null){
                        ChannelProgramMember cpm = new ChannelProgramMember();
                        cpm.partnerId = act.Id;
                        cpm.ProgramId = ChannelProgramList[0].Id;
                        cpm.LevelId = levelNameToRec.get(act.Partner_Program_Level__c).Id;
                        cpmToInsert.add(cpm);
                    }
                }
                try {
                    if(cpmToupdate.size()>0){
                        update cpmToupdate;
                    }
                    if(cpmToDelete.size() > 0){
                        delete cpmToDelete;
                    }
                    if(cpmToInsert.size() > 0){
                        insert cpmToInsert;
                    }
                } catch (Exception ex) {
                    system.debug('***'+ex.getMessage());
                }
                
            }  
        }
    }
    
    
    /*************************************************************************************************
* Author        :   Sushant
* Date          :   14-01-2021
* Param         : 
* Description   :  Auto Closed Booked Oppty when AutoPay Setup becomes TRUE
*added the code for checking amendment order form for amendment quote - Varsha on 4th Jan 2022
/*************************************************************************************************/    
    Public void checkForAutoPaySetup(List<Account> AccLst, Map<id, Account> oldMap){
        List<id> autoPaySetupAccIds = new List<id>();
        List<String> qIds=new List<String>();
        Set<Id> qtAccIds = new Set<Id>();
        
        for (Account acc: AccLst){
            if((acc.AutoPay_Setup__c=='True' || acc.AutoPay_Setup__c=='Manual') && acc.Bill_To__c && (acc.AutoPay_Setup__c != oldMap.get(acc.id).AutoPay_Setup__c)){
                autoPaySetupAccIds.add(acc.id);
            } 
        }
        
        if(!autoPaySetupAccIds.isEmpty() && autoPaySetupAccIds.size() > 0){
            for(SBQQ__Quote__c sq :[Select id, SBQQ__Account__c, qtc_Bill_To_Site__c from SBQQ__Quote__c where qtc_Bill_To_Site__c in :autoPaySetupAccIds]) {
                qIds.add(sq.id);
                if (sq.SBQQ__Account__c != null) qtAccIds.add(sq.SBQQ__Account__c); //Account of Quote should be same as Customer Document Account
            }
        }
        
        System.debug('@@@@qIds: '+qIds);
        System.debug('@@@@qtAccIds: '+qtAccIds);
        
        if(!qIds.isEmpty() && !qtAccIds.isEmpty()) {
            Map<Id, Id> AEOF_qtAccIdMap = new Map<Id, Id>();
            Set<Id> AEMA_AccIds = new Set<Id>();
            List<Id> AMOF_QIds = new List<Id>();
            //CLM Documents related to current Quote
            List<customer_document__c> custDocs=[Select id,Document_Type__c,Document_Status__c,Quote__c, Account__c from customer_document__c 
                                                 where Document_Status__c='Completed'
                                                 AND ((Quote__c in :qIds AND (Document_Type__c='AE Order Form' OR Document_Type__c='AE Amendment')) OR 
                                                      (Account__c IN : qtAccIds AND Document_Type__c='AE Master Agreement'))];  
            
            System.debug('@@@@custDocs: '+custDocs);
            if (!custDocs.isEmpty()) {                
                for (Customer_Document__c cd : custDocs) { 
                    if (cd.Account__c != NULL) {
                        if (cd.Document_Type__c == 'AE Master Agreement') { 
                            AEMA_AccIds.add(cd.Account__c);
                        } else if (cd.Document_Type__c == 'AE Order Form' && cd.Quote__c != NULL) { 
                            AEOF_qtAccIdMap.put(cd.Quote__c, cd.Account__c);    
                        }
                        /*added below condition for EBA_SF-1697 start*/
                        else if (cd.Document_Type__c == 'AE Amendment' && cd.Quote__c != NULL) { 
                            AMOF_QIds.add(cd.Quote__c);    
                        }
                        /*added below condition for EBA_SF-1697 end*/
                    }
                }
                System.debug('@@@@AEMA_AccIds: '+AEMA_AccIds);
                System.debug('@@@@AEOF_qtAccIdMap: '+AEOF_qtAccIdMap);
                
                
                if ((!AEMA_AccIds.isEmpty() && !AEOF_qtAccIdMap.isEmpty())||!AMOF_QIds.isEmpty()) {
                    qIds.clear(); // clear existing quote Ids
                    for (Id qId : AEOF_qtAccIdMap.keySet()) {
                        if (AEMA_AccIds.contains(AEOF_qtAccIdMap.get(qId))) qIds.add(qId);
                    }
                    qIds.addall(AMOF_QIds);//filling all the quotes ids if amendment order form is completed
                }
            }
            
            else{
                qIds.clear(); // clear existing quote Ids  
            }
            
            System.debug('@@@@qIds_after_clear: '+qIds);
            
            if (!qIds.isEmpty()) {
                List<SBQQ__Quote__c> qLst = [Select id,SBQQ__Primary__c,qtc_Ordered_Custom__c,SBQQ__Ordered__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                                             qtc_Requested_Delivery_Date__c,SBQQ__Account__c from SBQQ__Quote__c where id in :qIds ];
                
                System.debug('@@@@qLst: '+qLst);
                if(!System.isFuture() && !System.isBatch() && !qLst.isEmpty()) {
                    System.enqueueJob(new cpq_QteToOppSync(qLst, 'AC'));   
                } 
            }  
        }
    }       
    /*************************************************************************************************
* Author        :   Shiv (sm250665)
* Date          :   2 -Sep-2021
* Param         : 
* Description   :  Send email alert to Opportunity Owners if Autopay setup set to Manual.
/*************************************************************************************************/  
    
    public void checkAutoPaySetupManually(List<Account> AccLst, Map<id, Account> oldMap){
        List<id> autoPaySetupAccIds = new List<id>();
        for (Account acc: AccLst){
            if(acc.AutoPay_Setup__c == 'Manual' && acc.AutoPay_Setup__c != oldMap.get(acc.id).AutoPay_Setup__c && acc.Bill_To__c && oldMap.get(acc.id).AutoPay_Setup__c != 'True'){
                autoPaySetupAccIds.add(acc.id);
            } 
        }
        if (autoPaySetupAccIds.size() > 0) {
            List<Id> quoteIds = new List<Id>();
            for (SBQQ__Quote__c quote: cpq_AutoPayUtil.getOpenOpportunityQuotesBySiteIds(autoPaySetupAccIds)) {
                quoteIds.add(quote.Id);
            }
            if (quoteIds.size() > 0) {
                cpq_AutoPayUtil.handleOppOwnerNotification(autoPaySetupAccIds,quoteIds);
            }
            
        }
    } 
    
    
    /*************************************************************************************************
* Author        :   Simran Grewal 
* Date          :    
* Param         :   accounts  :  List of new Accounts               
* Return        :   
* Description   :  When partner gets deactive in org. Their respective Deal reg
status will set to "Partner Terminated". 
*************************************************************************************************/
    public void UpdateDealStatusPartnerTerminated (List<Account> AccList, Map<id, Account> oldMap) {
        if(checkRecursive.runUpdateDealStatusPartnerTerminated()){
            Set <Id> accID = New Set <Id> (); 
            Id actRecTypeId;
            // additional enhancement just to avoid query 
            // /**Ajay---EBA_SF-1279---**/
            actRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.RT_Acc_Partner).getRecordTypeId();
            if(actRecTypeId != null){
                for(Account a : AccList){
                    if(a.RecordTypeId == actRecTypeId && a.Active_Account__c == false && oldMap.get(a.Id).Active_Account__c == true){
                        accID.add(a.Id);
                    }   
                } 
            }
            If(!accId.isEmpty()){
                List<Deal_registration__c> DealstoUpdate = new List<Deal_registration__c>();
                for(Deal_registration__c dr :[Select Status__c,Partner_Company_Name__c from Deal_registration__c where Partner_Company_Name__c IN : accId AND  Status__c != 'Partner Terminated'] ){
                    dr.Status__c = 'Partner Terminated';
                    DealstoUpdate.add(dr);
                }
                if(!DealstoUpdate.isEmpty()){
                    update DealstoUpdate;
                }
            }
            
        }
    }
    
    /*************************************************************************************************
* Author        :   Puneet Bhatia 
* Date          :   13/06/2019 03:26 
* Param         :   accounts  :  List of new Accounts, Old Map of Account             
* Return        :   
* Description   :  
*************************************************************************************************/    
    public void notifyAccountOwnerChangeToPramata (List<Account> AccList, Map<id, Account> oldMap) {
        Set<String>  ownerUpdatedAcctIds = new Set<String>();
        
        for (Account account : AccList) {
            Account oldAccount = oldMap.get(account.Id);
            Id oldOwnerId = oldAccount.OwnerId;
            Id newOwnerId = account.OwnerId;
            
            // If the owner has changed, then update appropriate Pramata Contract Assocs
            // Id starting with 005 denotes User object
            if (String.valueOf(newOwnerId).startsWith('005') && oldOwnerId != newOwnerId) {
                ownerUpdatedAcctIds.add(account.Id);   
            }
        } 
        
        if(!ownerUpdatedAcctIds.isEmpty()) {
            update [SELECT Id 
                    FROM prmtsf__Pramata_Contract_Account_Assoc__c 
                    WHERE prmtsf__Account__c IN :ownerUpdatedAcctIds];  
        }  
    } 
    
    /*************************************************************************************************
* Author        :   Pankaj Kashyap
* Date          :   29-11-2021
* Param         :   AccList:  List of new Accounts , oldMap : MapOfOldAccount passes from Dispatcher
* Return        :   
* Description   :   Update Related Site Onwe if Parent Account Owner is Updated
*************************************************************************************************/
    
    /* Public void UpdteSiteOwnr(List<Account> AccList, Map<id, Account> oldMap , Map<Id,Account> newMap){
Set<Id> ParentIdSet= new Set<Id>();
List<Account> SiteListToUpdate = new List<Account>();
Map<Id,String> OwnerIdMap= new Map<Id,String>();
for(Account acc: AccList){

if((acc.OwnerId != oldMap.get(acc.id).OwnerId)){
ParentIdSet.add(acc.Id);
} 
OwnerIdMap.put(acc.id,acc.ownerID);

}



if(ParentIdSet != null && ParentIdSet.size()>0){
//update SiteListToUpdate;
//system.debug('>>>>>>>>call from trigger');
//database.executeBatch(new UpdateSiteOwnerBatch(ParentIdSet)); // Calling batch class.
for(Account AccObj : [Select id ,name,ParentId from Account where RecordType.Name='Site' and ParentId IN : ParentIdSet]){

if(newMap.containsKey(AccObj.ParentId)){
Account Acc = new Account();
Acc.Id = AccObj.Id;
Acc.OwnerID =  newMap.get(AccObj.ParentId).OwnerId;
SiteListToUpdate.add(Acc);
}
}

if(SiteListToUpdate != null && SiteListToUpdate.size()>0){
update SiteListToUpdate;
}
}

}*/
    /*************************************************************************************************
* Author        :   Simran Grewal
* Date          :   11-12-2020
* Param         : newOwrChgAccSet:  Set of new Account in Which owner has been changed
* Return        :   
* Description   :   Update CAM field on opp when Account Owner is changed(For partner users)
*************************************************************************************************/
    @future
    public static void UpdateCAMFuture(Set<Id> newOwrChgAccSet){
        UpdateCAM(newOwrChgAccSet);
    }
    public static void UpdateCAM(Set<Id> newOwrChgAccSet){
        //PT_U = Partner User
        Set<Id> PT_U = new Set<Id>();
        List<Opportunity> opps = new List<Opportunity>();
        for(User u: [Select id from User Where AccountId IN :newOwrChgAccSet AND IsActive = TRUE]){
            PT_U.add(u.Id);
        }
        for(Opportunity opp : [SELECT id,CAM__c,Owner.Account.OwnerId,Skip_Validation_Rule_for_Lead_Conversion__c FROM Opportunity  WHERE OwnerId IN :PT_U AND IsClosed = FALSE ]){
            opp.CAM__c = opp.Owner.Account.OwnerId;
            opp.Skip_Validation_Rule_for_Lead_Conversion__c = true;
            opps.add(opp);
        }  
        if(!opps.isEmpty()){
            CheckRecursive.cpqSpclHdlg=true;
            Database.update(opps,false);
        }
        
    }
    public void EmailConsolidation(List<Account> triggernew, Map<ID, Account> oldMap){
        Map<Id,Account> accMap = new Map<Id, Account>();
        //List<Messaging.SingleEmailMessage> leadOwnerMsgs = new List<Messaging.SingleEmailMessage>();
        for(Account acc : triggernew){
            if(acc.Credit_Application_Status__c != oldMap.get(acc.id).Credit_Application_Status__c){
                accMap.put(acc.Id, acc);
                System.debug('@@Email'+accMap);
            }
        }
        
        if(!accMap.isEmpty()){
            Set<id> oppOwnrIds = new Set<Id>();
            for(Opportunity opp : [Select id,isClosed,StageName,OwnerId from Opportunity where AccountId In:accMap.keySet()]){
                if(opp.isClosed ==false){
                    oppOwnrIds.add(opp.OwnerId);
                    System.debug('@@Email'+oppOwnrIds);
                }
            }
            List<User> emailIds = new List<User>();
            for(User uObj:[Select id,email,Name from User where id In:oppOwnrIds]){
                emailIds.add(uObj);
                System.debug('@@Email'+emailIds);
            }
            if(!emailIds.isEmpty()){
                sendCompleteNotification(accMap.Values(), emailIds); 
            }
        }
        // System.debug('@@@@@'+leadOwnerMsgs);
        // Messaging.sendEmail(leadOwnerMsgs);
    }
    public static void sendCompleteNotification(Account obj, List<User> emailIds){
        List<Messaging.SingleEmailMessage> message1 = new List<Messaging.SingleEmailMessage>();
        Contact c = [select id, Email from Contact where id =:BPM_Configuration__c.getValues('BPMContactIdForNotifyActionOwner').values__c];
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'Email Alert To Open Opportunity Owner'];
        for(User emails : emailIds){
            System.debug('@@Email'+emails);
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(c.id); 
            message.setSenderDisplayName(emails.Name); 
            message.setReplyTo('no-reply@company.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            //    message.setSubject(emailTemplate.subject);
            //   message.setHTMLBody(emailTemplate.Body);
            message.setTreatTargetObjectAsRecipient(false);
            message.setSaveAsActivity(false);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(obj.Id); //This is important for the merge fields in template to work
            message.toAddresses = new String[] { emails.Email};
                message1.add(message);    
            /*  message.toAddresses = new String[] { emails.Email};
Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
if (results[0].success) 
{
System.debug('The email was sent successfully.');
} else {
System.debug('The email failed to send: ' +  results[0].errors[0].message);
}*/
            
        }
        // Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message1};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(message1);
        if (results[0].success) 
        {
            System.debug('The email was sent successfully.');
        } else {
            System.debug('The email failed to send: ' +  results[0].errors[0].message);
        }
        
        
    }  
    
    public void ShareSite(List<Account> newSites) {
        List<AccountTeamMember> atmL = new List<AccountTeamMember>();
        Map<Id, Set<Id>> accVsSiteIdMap = new Map<Id, Set<Id>>();
        Set<Id> siteIds;
        for (Account site : newSites) {
            if(site.Active_Account__c){
                if (String.isNotBlank(site.ParentId)) {
                    siteIds = accVsSiteIdMap.get(site.ParentId);
                    if (siteIds == NULL)                    
                        accVsSiteIdMap.put(site.ParentId, new Set<Id>{site.Id});    
                    else
                        siteIds.add(site.Id);
                }      
            }
            
        }
        
        //Fetch all accont teams with role Channel Partner and create team on respective sites
        List <AccountTeamMember> atmAccs=[Select id, AccountId,  UserId,  TeamMemberRole from AccountTeamMember where AccountId =:accVsSiteIdMap.keySet() and TeamMemberRole=:Label.ATM_Role_CP and User.isActive=true];
        for(AccountTeamMember atm:atmAccs){
            Sharing_Site_EndCustomer sse=new Sharing_Site_EndCustomer();
            atmL.addAll(sse.createTeamMmbr(accVsSiteIdMap.get(atm.AccountId), atm.UserId));  
        }            
        if(!atmL.isEmpty()) 
            insert atmL;
        
    }
}