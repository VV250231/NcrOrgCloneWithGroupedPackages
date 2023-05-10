/****************************************************************************************************************
*   ClassName :   AccountTriggerDispatcher
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati          Removed hardcoded account partner recordtype Id
EBA_SF-2334     3rd Oct 2022    Puneet Bhatia		 Remove SF Automation to populate default Sales Org Code for CATM ONLY Accounts
****************************************************************************************************************/

public class AccountTriggerDispatcher extends TriggerHandlerBase {

    private static AccountTriggerHandler accHdlr;   
     /************************************** ACCOUNT BEFORE INSERT *************************************
     * Description : 1. Account Owner Name needed for Fund Claim object is populated on before insert.
                     2. Populate Corp Area, Corp Region, Corp Theatre, IPS Area, IPS Region fields on Account on before insert
                     3. Account Records needed to be updated if Partner Non Ror Object Records with matching Master Customer Number and Country code exists
                     4. Populate two fields Account_Region__c, Area__c, Region__c which are dependent on Account_Country_Code__c and Line Of Business (LOB)
                    
     *************************************************************************************************/
     public override void beforeInsert() {    
        accHdlr = (accHdlr != null) ? accHdlr : new AccountTriggerHandler();
         //Assuming all below logic is just for CDM Accounts(Customer/Partner), use filtered list. If some logic need to be processed for all Record Type use Trigge.New OR crete new Filter List
         List<Account> newAccLst = accHdlr.fltrAccOnlyRT((List<Account>)Trigger.new);
         
        // validate duplicate MCN in System
        accHdlr.vldtDupMCN(newAccLst);
        
        // populate Corp Area, Corp Region, Corp Theatre, IPS Area, IPS Region fields on Account 
        accHdlr.PopulatingIpsfieldsonaccount(newAccLst);
        
        // Account Records needed to be updated if Partner Non Ror Object Records with matching Master Customer Number and Country code exists
        accHdlr.populateValuesFromPartnerNonROR(newAccLst);
        
        // populate two fields Account_Region__c, Area__c, Region__c which are dependent on Account_Country_Code__c and Line Of Business (LOB)
        accHdlr.populateTheaterAreaonAccount(newAccLst);
        
        //populate CDM Account Owner on before insert
        accHdlr.UpdateAccOwner(newAccLst);
        
        //populate Account Owner Name on before insert
        accHdlr.populateAccountOwnerName(newAccLst);      
       
        //populate Interface Source Field when Account Created by Group members of "Account Admin" Group on before insert
        accHdlr.populateInterfaceSource(newAccLst);
         
        accHdlr.populateDefaultSalesOrgCode_onInsert(newAccLst);
     }
     
     
     /************************************** ACCOUNT AFTER INSERT *************************************
     * Description : 1. Create new Customer Linkage Record on Account insert
                     2. Update MCN on new Account that was created through Account Request.
                     3. An account and contact are associated Lead conversion takes place. We need to block make 
                        sure that the user only updates the existing account and do not create a new one.
     *************************************************************************************************/
     public override void afterInsert() { 
         accHdlr = (accHdlr != null) ? accHdlr : new AccountTriggerHandler();
          //Assuming all below logic is just for CDM Accounts(Customer/Partner), use filtered list. If some logic need to be processed for all Record Type use Trigge.New OR crete new Filter List
         List<Account> newAccLst = accHdlr.fltrAccOnlyRT((List<Account>)Trigger.new);        
         
         //  make sure that the user only updates the existing account and do not create a new one.
         accHdlr.blockAccountCreate(newAccLst);
         
         // update MCN on new Account created through Account Request
         accHdlr.updateMCNonAccount(newAccLst);
         
         // create new Customer Linkage Record on Account insert
        // new QuByAccountHandler().doQuBy_CustomerLinkageAfterInsert(newAccLst);
         
         //Sharing of sites
        list<account> acclist = accHdlr.fltrSites((List<Account>)Trigger.new);         
        if(acclist.size()>0)
        { 
            accHdlr.ShareSite(acclist);
        }

     }
     
     
     
     
     /************************************** ACCOUNT BEFORE UPDATE***********************************
     * Description : 1. Account Owner Name needed for Fund Claim object is populated.
                     2. This method is use to prevent non-admin users from updating account owner.
                     3. Populate Corp Area, Corp Region, Corp Theatre, IPS Area, IPS Region fields on Account   
                     4. Populate two fields Account_Region__c, Area__c, Region__c which are dependent on Account_Country_Code__c and Line Of Business (LOB)  
     *************************************************************************************************/
     
     public override void beforeUpdate() {
        /********************************************************
* Ajay---EBA_SF-1279---** None of the below logic is expected to run when updates coming from Quote, 
* since CPQTriggerControl.cpqSpclHdlgNew is set to true when Quote is updated, we will use this to remove un-necessary logic
* ********************************************************/
      /*** Ajay---EBA_SF-1352 ********************* REMOVED---*/
        /*if(CPQTriggerControl.cpqSpclHdlgNew){
            return;
        }*/
        /********************************************************
* GET OLD RECORD MAP FOR INCOMING RECORDS
********************************************************/
         
       
         
        accHdlr = (accHdlr != null) ? accHdlr : new AccountTriggerHandler();
        //Assuming all below logic is just for CDM Accounts(Customer/Partner), use filtered list. If some logic need to be processed for all Record Type use Trigge.New OR crete new Filter List
        List<Account> newAccLst = accHdlr.fltrAccOnlyRT((List<Account>)Trigger.new);
        
        Map<Id, sObject> oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet()); 
        
        /********************************************************
* LOCAL VARIABLES AND LISTS TO STORE RECORD IDS
********************************************************/
        // thrAreaAccList -list of accounts for which Theater, Area and Region need to be populated  
        List<Account> ipsAccLst = new List<Account>(), thrAreaAccList = new List<Account>();  
           accHdlr.EmailConsolidation(newAccLst, (Map<Id,Account>)Trigger.OldMap);

        // list of accounts for which Owner change 
        // list of accounts for which Owner or Account Owner Name change
        // List<Account> owrChgAccLst = new List<Account>() //commented as per of story EBA_SF-1475 
        List<Account> owrIdAndNameChgAccts = new List<Account>();  
        
        List<Account> dftOrgCodeAccts = new List<Account>(); // changed CDM Source Org Code Accounts
        
        /**********************************************************
* COMPARE RECORD OLD AND NEW VALUE AND EXECUTE YOUR LOGIC IF THERE IS ANY CHANGE
*******************************************************/
        
        for(Account acc : newAccLst)  {
            Account oldAcc = (Account)oldBeoreUpdateMap.get(acc.Id);  
            
            if ((oldAcc != null) && (oldAcc.Account_Country_Code__c != acc.Account_Country_Code__c)) {
                ipsAccLst.add(acc);
            }
            
            // check eligible record for Theater, Area and Region change
            if ((oldAcc != null) && ( (acc.Industry != oldAcc.Industry) || (acc.Account_Country_Code__c != oldAcc.Account_Country_Code__c ) ||(acc.BillingCountry != oldAcc.BillingCountry )
                                     || (acc.CDM_SMB_Flag__c != oldAcc.CDM_SMB_Flag__c ) || (acc.LOB__c != oldAcc.LOB__c ) || (acc.MDM_Billing_Location_Country_Code__c != oldAcc.MDM_Billing_Location_Country_Code__c ))) {
                                         thrAreaAccList.add(acc);          
                                     }
            
            // check if ownership changed for any record
            /*if (acc.OwnerId  != oldAcc.OwnerId) {
                owrChgAccLst.add(acc);    
            } commented as per of story EBA_SF-1475*/
            
            // check if owner changed or Account Owner Name changed
            if ((acc.OwnerId  != oldAcc.OwnerId) || (acc.Account_Owner_Name__c != oldAcc.Account_Owner_Name__c) || (acc.Account_Owner_Name__c == null)) {
                owrIdAndNameChgAccts.add(acc);  
            }
            
            
            if(accHdlr.isCDMAccount(acc) && !accHdlr.isCATMAccount(acc)) {
                if (String.isBlank(acc.Global_Sales_Org_Code__c) || (acc.Use_Default_Sales_Org_Code__c && (acc.Industry != oldAcc.Industry || acc.Account_Country_Code__c != oldAcc.Account_Country_Code__c))) {
                    if(acc.Use_Default_Sales_Org_Code__c && String.isBlank(acc.CDM_Source_SOC__c)) {
                        dftOrgCodeAccts.add(acc);           
                    } else {
                        acc.Use_Default_Sales_Org_Code__c = false;
                        acc.Global_Sales_Org_Code__c = acc.CDM_Source_SOC__c;          
                    } 
                } else {
                    if (String.isNotBlank(acc.CDM_Source_SOC__c) && (acc.CDM_Source_SOC__c != oldAcc.CDM_Source_SOC__c)) {
                        acc.Use_Default_Sales_Org_Code__c = false;
                        acc.Global_Sales_Org_Code__c = acc.CDM_Source_SOC__c;     
                    }
                }
            } 
        }
        
        /**********************************************************
* EXECUTE YOUR LOGIC IF LOCAL VARIABLE CHANGE OR LOCAL LIST HAS SIZE > 0 
*********************************************************/
        
        
        //validate duplicate MCN in System  
        if(!Test.isRunningTest())        
            accHdlr.vldtDupMCN(newAccLst);
        
        // Add any Lead Conversion specific logic here        
        accHdlr.HandleLeadConversion(newAccLst);
        
       
        
        if (!ipsAccLst.isEmpty()) {
            accHdlr.PopulatingIpsfieldsonaccount(newAccLst);
        } 
        
        // populateTheaterAreaOnAccount list blank check
        if (!thrAreaAccList.isEmpty()) {
            accHdlr.populateTheaterAreaonAccount(thrAreaAccList);    
        }
        
        // prevent non-admin users from updating account owner
        /*if (!owrChgAccLst.isEmpty()) {
            accHdlr.blockOwnerShipChangeOnAccount(owrChgAccLst); 
        } commented as per of story EBA_SF-1475 */
        
        if (!owrIdAndNameChgAccts.isEmpty()) {
            accHdlr.populateAccountOwnerName(owrIdAndNameChgAccts);          
        }
        
        
         if (!dftOrgCodeAccts.isEmpty()) { 
             accHdlr.populateDefaultSalesOrgCode(dftOrgCodeAccts);
         }
        
        
        if(!newAccLst.isEmpty()) {
            accHdlr.PopulateNextTierRevenue(newAccLst);
        }
        
        //Notification to Opportunity Owner if Autopay setup to Manual - SFCPQBLG-308 (sm250665)
        List<Account> sitesLst = accHdlr.fltrSites((List<Account>)Trigger.new);
        if (sitesLst.size() > 0) {
            accHdlr.checkAutoPaySetupManually(sitesLst,(Map<id,Account>) Trigger.oldMap);
        }
    }
    
    
    /************************************** ACCOUNT AFTER UPDATE *************************************
* Description : 1. The NSCContact Extract only sends the contacts that are modified after the Timestamp. But if the related Account are modified,
contacts are not modified. This trigger modifies the Contacts whenever the account, fulfilling certain criteria is updated. 

2. Create new Customer Linkage Record when record owner changes

3. Updates the record type of the contacts if record type of account is changed.

4. Checks the primary contact checkbox on the contact if contact is selected as primary
UnChecks the primary contact checkbox on the contact if contact is removed as primary
*************************************************************************************************/
    
    public override void afterUpdate() {
        /*******************************************************************************
* EXECUTE YOUR LOGIC IF LOCAL VARIABLE CHANGE OR LOCAL LIST HAS SIZE > 0 
********************************************************************************/
        
        accHdlr = (accHdlr != null) ? accHdlr : new AccountTriggerHandler(); 
        /********************************************************
* Ajay---EBA_SF-1279---** ONLY DIServiceNow sync is expected to run but not sure about necessity, further reduced chances to reduce run 
* None of OTHER the below logic is expected to run when updates coming from Quote, 
* since CPQTriggerControl.cpqSpclHdlgNew is set to true when Quote is updated, we will use this to remove un-necessary logic
* ********************************************************/
        /*** Ajay---EBA_SF-1352 ********************* REMOVED---*/
        /*if(CPQTriggerControl.cpqSpclHdlgNew){
            if(!Test.isRunningTest()){
                List<Account> newAccLst = accHdlr.fltrAccOnlyRT((List<Account>)Trigger.new);
                List<Account> diAccLst =  new List<Account>();              
                    for(Account acc : newAccLst)  {
                        if(acc.Subscription_Group__c == 'Digital Insight' && String.isNotEmpty(acc.DI_Customer__c)){
                            diAccLst.add(acc);
                        }
                    }
                if(diAccLst.size()>0)
                accHdlr.syncToServiceNow(diAccLst);
            }
            return;
        }  */        
           
        
        //Assuming all below logic is just for CDM Accounts(Customer/Partner), use filtered list. If some logic need to be processed for all Record Type use Trigge.New OR crete new Filter List
        List<Account> newAccLst = accHdlr.fltrAccOnlyRT((List<Account>)Trigger.new);
        List<Account> sitesLst = accHdlr.fltrSites((List<Account>)Trigger.new);
        /********************************************************
* GET OLD RECORD MAP FOR INCOMING RECORDS
********************************************************/
        
        Map<Id, sObject> recOldMap = this.getOldAfterUpdateMap(Trigger.newMap.keySet());
        
        /********************************************************
* LOCAL VARIABLES AND LISTS TO STORE RECORD IDS
********************************************************/
        
        // Ids of the account records for which recordType changed from non-partner to partner
        Set<Id> prtrAccIds = new Set<Id>();
        
        // Ids of the account records for which recordtype Ids are changed.
        Set<Id> actIdSet = new Set<Id>();
        
        // primary contact change account list
        List<Account> primConAccList = new List<Account>();
        
        // new and old account map specific for records where owner changed
        Map<Id, Account> newOwrChgAccMap = new Map<Id, Account>(), oldOwrChgAccMap = new Map<Id, Account>();
        
        List<Account> syncToCDMAccts = new List<Account>();           
        Set<String> chgGblSOAccIds = new Set<String>();
        /**********************************************************
* COMPARE RECORD OLD AND NEW VALUE AND EXECUTE YOUR LOGIC IF THERE IS ANY CHANGE
*******************************************************/
        
        for(Account acc : newAccLst)  {
            Account oldAcc = (Account)recOldMap.get(acc.Id);
            
            // change logic for updateContactForPartnerAccount trigger 
            boolean updateflag = false;
            //if((acc.RecordTypeID =='0127000000014kqAAA' ||  acc.RecordTypeId == '012700000001UVtAAM') && acc.isPartner == true  && acc.partnership_status__c == 'active') {
            // EBA_SF-1617 Removed hardcoded account partner recordtype Id - Modified by Kapil Bhati
            if(acc.RecordTypeID == NSCCommonInfoUtil.getIdOf('Account_RecordTypeId') && acc.isPartner == true  && acc.partnership_status__c == 'active') {
                 //if((acc.RecordTypeID != oldAcc.RecordTypeID) && (oldAcc.RecordTypeID !='0127000000014kqAAA' &&  oldAcc.RecordTypeId != '012700000001UVtAAM')) {
                 // EBA_SF-1617 Removed hardcoded account partner recordtype Id - Modified by Kapil Bhati
                if((acc.RecordTypeID != oldAcc.RecordTypeID) && (oldAcc.RecordTypeID==NSCCommonInfoUtil.getIdOf('Account_RecordTypeId'))) {
                    updateflag = true;
                }
                else if(acc.isPartner != oldAcc.isPartner){
                    updateflag = true;
                }
                else if(acc.partnership_status__c !=  oldAcc.partnership_status__c){
                    updateflag = true;
                }
            } 
            if(updateflag) { prtrAccIds.add(acc.Id);} 
            
            // change logic for UpdateContactRecordType trigger 
            if (acc.RecordTypeId != oldAcc.RecordTypeId) {
                actIdSet.add(acc.Id);
            }
            
            //checks if the primary contact field has changed during the update.
            if (oldAcc.Primary_Contact__c != acc.Primary_Contact__c) {
                primConAccList.add(acc);
            }
            
            // check if Owner Changed for Account for quby linkage scenario
            if (acc.OwnerId != oldAcc.OwnerId) {
                newOwrChgAccMap.put(acc.Id, acc);
                oldOwrChgAccMap.put(acc.Id, oldAcc);
            }
            
            
            if((acc.Account_CDM_ID__c != NULL) && (acc.MDM_Data_Source_Code__c == 'CDM') && (acc.Master_Customer_Number__c != NULL) 
               && ((acc.Master_Customer_Number__c != oldAcc.Master_Customer_Number__c) || (acc.OwnerId != oldAcc.OwnerId) || (acc.DI_Customer__c != oldAcc.DI_Customer__c ))) {
                   syncToCDMAccts.add(acc);            
               }
            
            if (acc.Global_Sales_Org_Code__c != oldAcc.Global_Sales_Org_Code__c) {
                chgGblSOAccIds.add(acc.Id);    
            }
            
        }
        
        
        
        
        if (!prtrAccIds.isEmpty()) {
            accHdlr.updateContactsForPartnerAccts(prtrAccIds);
        }
        
        if (!actIdSet.isEmpty()) {
            
            // updates the record type of the contacts if record type of account is changed
            accHdlr.UpdateContactRecordTypeFromAcct(actIdSet);    
        }
        
        if (!primConAccList.isEmpty()) {
            
            /* check Partner_Primary_Contact__c field on Account if contact is selected as primary and 
uncheck Partner_Primary_Contact__c from other contacts under same account. */                
            accHdlr.updatePrimaryContact(primConAccList);  
        }
        
        if(!newOwrChgAccMap.isEmpty()) {
           // new QuByAccountHandler().doQuBy_CustomerLinkageAfterUpdate(newOwrChgAccMap, oldOwrChgAccMap); 
            //added by Varsha
            if(System.isFuture() || System.isBatch()){
                AccountTriggerHandler.UpdateCAM(newOwrChgAccMap.keyset());             
            }else{                 
                AccountTriggerHandler.UpdateCAMFuture(newOwrChgAccMap.keyset());
            } 
        }
        //if(shouldIRun.canIRun() && !Test.isRunningTest())
        if(!Test.isRunningTest()){
            accHdlr.syncToServiceNow(Trigger.new);
        } 
        
        /***** Update CDM Sales Org Code on Opporunities of Account *****/
        if (!chgGblSOAccIds.isEmpty()) {
            accHdlr.UpdateSalesOrgOnOpps(chgGblSOAccIds);        
        }
        
        /****** Update Account Owner in CDM *******/
        if(!syncToCDMAccts.isEmpty()) {
            accHdlr.syncAccountOwnerwithCDM(syncToCDMAccts);
        }
        /****** Update Account Owner in CDM *******/
        
        if(!newAccLst.isEmpty()) {
            accHdlr.enrollForChannelProgram(newAccLst);
            accHdlr.UpdateDealStatusPartnerTerminated(newAccLst,(Map<id,Account>) Trigger.oldMap);
            accHdlr.notifyAccountOwnerChangeToPramata(newAccLst,(Map<id,Account>) Trigger.oldMap);
        }
        // accHdlr.UpdteSiteOwnr((List<Account>)Trigger.New,(Map<id,Account>) Trigger.oldMap, (Map<id,Account>) Trigger.NewMap);
        //Auto Closed Booked Oppty when AutoPay Setup becomes TRUE
        if (sitesLst.size() > 0) {
            accHdlr.checkForAutoPaySetup(sitesLst,(Map<id,Account>) Trigger.oldMap);
            
            //Sharing of sites
            accHdlr.ShareSite(sitesLst);
        }
        /*If(newOwrChgAccSet!= null && !newOwrChgAccSet.isempty())
{ AccountTriggerHandler.UpdateCAM(newOwrChgAccSet);
}*/
        
    }
    
    
    /************************************** ACCOUNT AFTER DELETE *************************************
*  Description : 1. Update Sales Org Code on Oppprtunities for merge Account 
*************************************************************************************************/
    public override void afterDelete() {
        accHdlr = (accHdlr != null) ? accHdlr : new AccountTriggerHandler(); 
        
        Set<String> mstrAccIds = new Set<String>(); // Set of MasterRecordIds as a result of merge call
        
        for (Account acc : (List<Account>)Trigger.old)  {
            if(String.isNotBlank(acc.MasterRecordId)) mstrAccIds.add(acc.MasterRecordId);    
        }
        if (!mstrAccIds.isEmpty()) accHdlr.UpdateSalesOrgOnOpps(mstrAccIds);    
    }
}