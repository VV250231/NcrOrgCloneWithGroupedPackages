//Last Modified By - Stuti Srivastava -EBA-2060 on 25/5/2022 CATM Changes
//Last Modified By - Puneet Bhatia - EBA_SF-2536 on 04/01/2023 - Site sharing issue with partner user
//changes done for EBA_SF-2622 Salesforce is not transferring the Province field to the State field for HW RMAs. Province__c is added in query

public class CDMUtil {
    
    /*public final static Set<String> CDMAccountTypes = new Set<String>{'END CUSTOMER', 'DISTRIBUTOR', 'PARTNER', 'INTERNAL', 'LOCAL OFFICE'};
public static Set<String> CDMAccountStatuses = new Set<String>{'INACTIVE','ARCHIVE','TARGET','ACTIVE','ERP READY'};
public static Set<String> CDMSubAccountTypes = new Set<String>{'DIRECT','3RD PARTY','CHANNEL'};*/
    public final static Date maxDate = Date.newInstance(4000, 12, 31);
    public final static String DOMESTIC_ULTIMATE_REL = 'Domestic Ultimate';
    
    public static void notifyInvldPcklstVals(CDMService.AccountWrapper CDMacc) {
        Set<String> CDMAccTyps = new Set<String>(), CDMSubAccTyps = new Set<String>(), CDMAccSts = new Set<String>();
        
        CDM_Config__mdt CDMCfg = [SELECT Account_Types__c,Sub_Account_Types__c, Account_Status__c FROM CDM_Config__mdt WHERE QualifiedApiName = 'CDM' LIMIT 1];
        
        if(CDMCfg != NULL && String.isNotBlank(CDMCfg.Account_Types__c)) {
            CDMAccTyps = new Set<String>(CDMCfg.Account_Types__c.split(','));
        }
        
        if(CDMCfg != NULL && String.isNotBlank(CDMCfg.Sub_Account_Types__c)) {
            CDMSubAccTyps = new Set<String>(CDMCfg.Sub_Account_Types__c.split(','));
        }        
        
        if(CDMCfg != NULL && String.isNotBlank(CDMCfg.Account_Status__c )) {
            CDMAccSts = new Set<String>(CDMCfg.Account_Status__c .split(','));       
        }
        
        //toAddresses.addAll(NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(',')); 
        integer errCount = 0;
        String subj ='',emlBdy = '';
        String emlFtr= 'Thanks<br/>NSC Administration';
        Boolean hasErr = false;
        
        if (String.isNotBlank(CDMacc.AccountType)) {
            if (!CDMAccTyps.contains(CDMacc.AccountType.toUpperCase())) {
                subj ='Contains Invalid Account Type';
                hasErr = true;
            }            
        }
        
        if (String.isNotBlank(CDMacc.Status)) {
            if(!CDMAccSts.contains(CDMacc.Status.toUpperCase())) {
                subj = subj.length() > 0 ?  subj + ' AND Contains Invalid Account Status' : 'Contains Invalid Account Status';     
                hasErr = true;
            }   
        }
        
        
        if (hasErr) {
            emlBdy += 'Below Account' + subj +'<br/><br/>';
            emlBdy += 'Account CDM ID:'+ CDMacc.AccountCDMId   + '<br/><br/>';
            emlBdy += 'Account Name:'+CDMacc.AccountName + '<br/><br/>';
            emlBdy += 'Account Number:'+CDMacc.AccountNumber + '<br/><br/>';
            emlBdy += 'Account Type:'+CDMacc.AccountType   + '<br/><br/>';
            emlBdy += 'Account Status:'+CDMacc.Status   + '<br/><br/>';    
            
            
            emlBdy += emlFtr; 
            
            subj = 'Account ' + CDMacc.AccountName + ' ' + subj;
            notifySupportTeam(subj, emlBdy);
        }
    }
    
    public static void notifySupportTeam(String mailSub, String mailBdy){
        List<String> toAddr = new List<String>();  
        toAddr.addAll(NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(','));  
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setToAddresses(toAddr);
        //mail.setOrgWideEmailAddressId('0D270000000XZHr');
        mail.setReplyTo('NI230017@ncr.com');
        mail.setSenderDisplayName('NSC Adminisration');
        mail.setSubject(mailSub); 
        mail.setHtmlBody(mailBdy); 
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
    }
    
    // validate Customer merge request
    public static CDMService.CustomerMergeResponse validateMergeRequest(CDMService.CustomerMergeRequest mrgReq) {
        String err = '', wrngStr = '';
        CDMService.CustomerMergeResponse mrgRes = new CDMService.CustomerMergeResponse();
        
        if (mrgReq == null || mrgReq.MergePartyDetail == null || mrgReq.MergePartyDetail.masterParty == null 
            || mrgReq.MergePartyDetail.victimParties == null) {
                
                err = 'Either Master or Vicim Party missing from Merge Request'; 
            } else {
                
                String mstrPrtyType = '';
                
                // check for master party
                if(String.isNotBlank(mrgReq.MergePartyDetail.masterParty.PartyNumber) && String.isNotBlank(mrgReq.MergePartyDetail.masterParty.PartyType)) {
                    mstrPrtyType = mrgReq.MergePartyDetail.masterParty.PartyType;
                    
                    integer count = 0;
                    for(CDMService.MergePartyWrapper vctmParty : mrgReq.MergePartyDetail.victimParties) {
                        count++;
                        
                        if (String.isNotBlank(vctmParty.PartyNumber) && String.isNotBlank(vctmParty.PartyType)) {
                            if (vctmParty.PartyType != mstrPrtyType) {
                                err += 'Victim Party Type mismatch with Master Party Type for Victim Party'  + count + ',';
                            }
                        } else {
                            err += 'Party Number or Party Type missing for Victim Party' + count + ',';
                        }
                    }
                    
                    if(String.isNotBlank(err)) {
                        err = err.subString(0, err.length() - 1);
                    } else if(mstrPrtyType == 'Customer_Party') {
                        wrngStr = 'Customer Merge is not applicable for NSC';    
                    }
                } else {
                    err += 'Party Number or Party Type missing for Master Party,';
                }
            }
        
        if(String.isNotBlank(err)) {
            mrgRes.status = CDMService.STATUS_FAILURE;
            mrgRes.message = err;
        } else if(String.isNotBlank(wrngStr))  {
            mrgRes.status = CDMService.STATUS_WARNING;
            mrgRes.message = wrngStr;
        } else {
            mrgRes.status = CDMService.STATUS_SUCCESS;
        }        
        return mrgRes; 
    }
    
    
    public Static String validateAccountPartyNbrs(Account mstrAcc,  Map<id,Account> vctmAccMrgMap, CDMService.CustomerMergeRequest CDMcmr) {
        String vldErr = '';
        
        if(mstrAcc == NULL) {          
            vldErr = 'Master Account not found in NSC';
        }
        
        if(vctmAccMrgMap.isEmpty()) {  // no victim parties MCNs found in NSC
            vldErr += 'No Victim Account MCNs found in NSC';
            
        } else  { // particular victim party MCN not found in NSC
            Set<String> vctmMCNSet = new Set<String>();
            
            for (Account a : vctmAccMrgMap.values()) {
                vctmMCNSet.add(a.Master_Customer_Number__c);
            }
            
            for (CDMService.MergePartyWrapper vctmParty : CDMcmr.MergePartyDetail.victimParties) {
                if (!vctmMCNSet.contains(vctmParty.PartyNumber)) {
                    vldErr += 'Victim Party with MCN:' + vctmParty.PartyNumber + ' not found in NSC';
                }
            }  
            
            if(String.isNotBlank(vldErr)) vldErr = vldErr.subString(0, vldErr.length() - 1);
        } 
        
        return vldErr;
    }
    
    public static void processAcctRltns(CDMService.AccountWrapper CDMacc, String relatedFromAccId, Boolean isNewAcc) {
        List<cdm_Account_Relationship__c> upsrtRelLst = new List<cdm_Account_Relationship__c>();
        Map<String, CDMService.RelationshipWrapper> inpLclOfcPrtyNbrMap = new Map<String, CDMService.RelationshipWrapper>();
        Map<String, CDMService.RelationshipWrapper> inpPrtnrOfPrtyNbrMap = new Map<String, CDMService.RelationshipWrapper>();
        
        if (CDMacc.LocalOffice_Of_Relation != NULL && !CDMacc.LocalOffice_Of_Relation.isEmpty()) {          
            for (CDMService.RelationshipWrapper relWrp : CDMacc.LocalOffice_Of_Relation) {
                inpLclOfcPrtyNbrMap.put(relWrp.Related_PartyNumber, relWrp);          
            }
        }
        
        if (CDMacc.Partner_Of_Relation != NULL && !CDMacc.Partner_Of_Relation.isEmpty()) {
            for (CDMService.RelationshipWrapper relWrp : CDMacc.Partner_Of_Relation) {
                inpPrtnrOfPrtyNbrMap.put(relWrp.Related_PartyNumber, relWrp);            
            }
        }
        
        if(!inpLclOfcPrtyNbrMap.isEmpty() || !inpPrtnrOfPrtyNbrMap.isEmpty()) {   // CDMacc.AccountNumber          
            List<cdm_Account_Relationship__c> exstRelLst = checkExistingRelationship(CDMacc.AccountNumber, inpLclOfcPrtyNbrMap, inpPrtnrOfPrtyNbrMap);   
            
            if(!exstRelLst.isEmpty()) {
                upsrtRelLst.addAll(exstRelLst);    
            }
            
            if(!inpLclOfcPrtyNbrMap.isEmpty() || !inpPrtnrOfPrtyNbrMap.isEmpty()) {
                addWait(1000);  
                
                exstRelLst = checkExistingRelationship(CDMacc.AccountNumber, inpLclOfcPrtyNbrMap, inpPrtnrOfPrtyNbrMap);   
                
                if(!exstRelLst.isEmpty()) {
                    upsrtRelLst.addAll(exstRelLst);    
                }
            }
            
            CDMService.RelationshipWrapper inpRel;          
            if(!inpLclOfcPrtyNbrMap.isEmpty() || !inpPrtnrOfPrtyNbrMap.isEmpty()) {   
                Set<String> relMCNs = new Set<String>();
                relMCNs.addAll(inpLclOfcPrtyNbrMap.keySet());
                relMCNs.addAll(inpPrtnrOfPrtyNbrMap.keySet());                
                List<Account> relAccts = getRelatedAccounts(relMCNs);
                
                for (Account relAcc : relAccts) {                    
                    
                    if(inpLclOfcPrtyNbrMap.containsKey(relAcc.Master_Customer_Number__c)) {
                        inpRel = inpLclOfcPrtyNbrMap.get(relAcc.Master_Customer_Number__c);
                        inpLclOfcPrtyNbrMap.remove(relAcc.Master_Customer_Number__c);
                        
                        cdm_Account_Relationship__c newFwdAccRel = new cdm_Account_Relationship__c();
                        String revRelCode = '', revRelName='';
                        
                        newFwdAccRel.Relationship_Type__c = inpRel.RelationShip_Name;                      
                        newFwdAccRel.Relationship_Code__c = inpRel.RelationShip_Code;
                        
                        if (inpRel.RelationShip_Code.equalsIgnoreCase('Local Office Of')) {
                            newFwdAccRel.Name = 'NCR End Customer';
                            revRelCode = 'End Customer Of';
                            revRelName = 'Local Office';
                            
                        } else  if (inpRel.RelationShip_Code.equalsIgnoreCase('End Customer Of')) {
                            newFwdAccRel.Name = 'Local Office'; 
                            revRelCode = 'Local Office Of';
                            revRelName = 'NCR End Customer';
                        }
                        
                        newFwdAccRel.Account__c = relatedFromAccId;
                        newFwdAccRel.Related_Account__c = relAcc.Id;
                        newFwdAccRel.Account_Number__c = CDMacc.AccountNumber; 
                        newFwdAccRel.Related_Account_Number__c = relAcc.Master_Customer_Number__c;
                        newFwdAccRel.Active__c = (inpRel.RelationShip_Status != NULL && inpRel.RelationShip_Status == 'A') ? TRUE : FALSE;
                        
                        if (String.isNotBlank(inpRel.ROR_Update_Datetime)) {
                            newFwdAccRel.ROR_Update_Date_Time__c = Datetime.valueOfGMT(inpRel.ROR_Update_Datetime.replace('T',' ').replace('Z', ''));
                        }
                        newFwdAccRel.Start_Date__c = String.isNotBlank(inpRel.RelationShip_StartDate) ? Date.valueOf(inpRel.RelationShip_StartDate) : NULL;
                        
                        if (String.isNotBlank(inpRel.RelationShip_End_Date)) {
                            Date relEndDate = Date.valueOf(inpRel.RelationShip_End_Date);
                            Date maxDate = Date.newInstance(4000, 12, 31);
                            if(relEndDate > maxDate) newFwdAccRel.End_Date__c = maxDate;                                  
                            else newFwdAccRel.End_Date__c = relEndDate; 
                        } else {
                            newFwdAccRel.End_Date__c = NULL;    
                        }                        
                        
                        upsrtRelLst.add(newFwdAccRel);
                        
                        if(isNewAcc) {
                            cdm_Account_Relationship__c revAccRel = createReverseRelationship(newFwdAccRel, revRelCode, revRelName);
                            upsrtRelLst.add(revAccRel);   
                        }
                    } 
                    
                    
                    if (inpPrtnrOfPrtyNbrMap.containsKey(relAcc.Master_Customer_Number__c)) {
                        inpRel = inpPrtnrOfPrtyNbrMap.get(relAcc.Master_Customer_Number__c);
                        inpPrtnrOfPrtyNbrMap.remove(relAcc.Master_Customer_Number__c);
                        
                        cdm_Account_Relationship__c newFwdAccRel = new cdm_Account_Relationship__c();
                        String revRelCode = '', revRelName='';
                        
                        newFwdAccRel.Relationship_Type__c = inpRel.RelationShip_Name;
                        newFwdAccRel.Relationship_Code__c = inpRel.RelationShip_Code;
                        
                        if (inpRel.RelationShip_Code.equalsIgnoreCase('Partner Of')) {
                            newFwdAccRel.Name = 'End Customer'; 
                            revRelCode = 'End Customer Of';
                            revRelName = 'Partner'; 
                            
                        } else  if (inpRel.RelationShip_Code.equalsIgnoreCase('End Customer Of')) {
                            newFwdAccRel.Name = 'Partner'; 
                            revRelCode = 'Partner Of';
                            revRelName = 'End Customer';
                        }  
                        
                        newFwdAccRel.Account__c = relatedFromAccId;
                        newFwdAccRel.Related_Account__c = relAcc.Id;
                        newFwdAccRel.Account_Number__c = CDMacc.AccountNumber; 
                        newFwdAccRel.Related_Account_Number__c = relAcc.Master_Customer_Number__c;
                        newFwdAccRel.Active__c = (inpRel.RelationShip_Status != NULL && inpRel.RelationShip_Status == 'A') ? TRUE : FALSE;
                        
                        
                        
                        if (String.isNotBlank(inpRel.ROR_Update_Datetime)) {
                            newFwdAccRel.ROR_Update_Date_Time__c = Datetime.valueOfGMT(inpRel.ROR_Update_Datetime.replace('T',' ').replace('Z', ''));
                        }
                        newFwdAccRel.Start_Date__c = String.isNotBlank(inpRel.RelationShip_StartDate) ? Date.valueOf(inpRel.RelationShip_StartDate) : NULL;
                        
                        
                        if (String.isNotBlank(inpRel.RelationShip_End_Date)) {
                            Date relEndDate = Date.valueOf(inpRel.RelationShip_End_Date);
                            Date maxDate = Date.newInstance(4000, 12, 31);
                            if(relEndDate > maxDate) newFwdAccRel.End_Date__c = maxDate;                                  
                            else newFwdAccRel.End_Date__c = relEndDate;                             
                        } else {
                            newFwdAccRel.End_Date__c = NULL;    
                        }
                        upsrtRelLst.add(newFwdAccRel); 
                        
                        if (isNewAcc) {
                            cdm_Account_Relationship__c revAccRel = createReverseRelationship(newFwdAccRel, revRelCode, revRelName);
                            upsrtRelLst.add(revAccRel);   
                        }
                    }
                }
            } 
            
        }
        
        if (!upsrtRelLst.isEmpty()) {
            upsert upsrtRelLst;
        }     
        
        /*
String errorMsg = '';
if (!inputLocalOfficePartyNbrMap.isEmpty()) {         
errorMsg += 'Related Account Numbers: ' + String.join(new List<String>(inputLocalOfficePartyNbrMap.keySet()),',') + ' not found in NSC';       
}   

if (!inputPartnerOfPartyNbrMap.isEmpty()) {         
errorMsg += '<br/> Related Account Numbers:' +  String.join(new List<String>(inputPartnerOfPartyNbrMap.keySet()),',') + ' not found in NSC';      
}   

if (String.isNotBlank(errorMsg )) {
throw new CDMCustomException(errorMsg);
} */
    }
    
    public static List<cdm_Account_Relationship__c> checkExistingRelationship(String mstrMCN, Map<String, CDMService.RelationshipWrapper> inpLclOfcPrtyNbrMap, Map<String, CDMService.RelationshipWrapper> inpPtnrOfPrtyNbrMap) {
        List<cdm_Account_Relationship__c> upsrtRelLst = new List<cdm_Account_Relationship__c>();
        
        if (!inpLclOfcPrtyNbrMap.isEmpty() || !inpPtnrOfPrtyNbrMap.isEmpty()) {             
            List<cdm_Account_Relationship__c> exstAccRelLst = [SELECT Id, Name, Start_Date__c, End_Date__c, ROR_Update_Date_Time__c,Active__c, Account__c,
                                                               Related_Account__c, Account__r.Master_Customer_Number__c, Related_Account__r.Master_Customer_Number__c,
                                                               Relationship_Type__c, Relationship_Code__c FROM cdm_Account_Relationship__c 
                                                               WHERE Account__r.Master_Customer_Number__c = :mstrMCN
                                                               AND (Related_Account__r.Master_Customer_Number__c IN :inpLclOfcPrtyNbrMap.keySet() OR Related_Account__r.Master_Customer_Number__c IN :inpPtnrOfPrtyNbrMap.keySet()) FOR UPDATE]; 
            
            
            for (cdm_Account_Relationship__c exstRel : exstAccRelLst) {       
                CDMService.RelationshipWrapper inpLclOfcRel= inpLclOfcPrtyNbrMap.get(exstRel.Related_Account__r.Master_Customer_Number__c);
                
                if (inpLclOfcRel != NULL && inpLclOfcRel.RelationShip_Name == exstRel.Relationship_Type__c && inpLclOfcRel.RelationShip_Code == exstRel.Relationship_Code__c) {
                    inpLclOfcPrtyNbrMap.remove(exstRel.Related_Account__r.Master_Customer_Number__c);  // remove relationshiop from input list
                    
                    Datetime inpRelDtTime = NULL;
                    if (String.isNotBlank(inpLclOfcRel.ROR_Update_Datetime)) {
                        inpRelDtTime = Datetime.valueOfGMT(inpLclOfcRel.ROR_Update_Datetime.replace('T',' ').replace('Z', ''));
                    }
                    
                    if(inpRelDtTime != NULL && exstRel.ROR_Update_Date_Time__c != NULL && inpRelDtTime > exstRel.ROR_Update_Date_Time__c) {
                        exstRel.Active__c = (inpLclOfcRel.RelationShip_Status != NULL && inpLclOfcRel.RelationShip_Status == 'A') ? TRUE : FALSE;
                        exstRel.ROR_Update_Date_Time__c = inpRelDtTime; 
                        exstRel.Start_Date__c = String.isNotBlank(inpLclOfcRel.RelationShip_StartDate) ? Date.valueOf(inpLclOfcRel.RelationShip_StartDate) : NULL;
                        
                        if (String.isNotBlank(inpLclOfcRel.RelationShip_End_Date)) {
                            Date relEndDate = Date.valueOf(inpLclOfcRel.RelationShip_End_Date);
                            Date maxDate = Date.newInstance(4000, 12, 31);
                            if(relEndDate > maxDate) exstRel.End_Date__c = maxDate;                                   
                            else exstRel.End_Date__c = relEndDate; 
                        } else {
                            exstRel.End_Date__c = NULL;    
                        }    
                        upsrtRelLst.add(exstRel);
                    }
                }
                
                CDMService.RelationshipWrapper inpPtnrOfRel= inpPtnrOfPrtyNbrMap.get(exstRel.Related_Account__r.Master_Customer_Number__c);
                
                if (inpPtnrOfRel != NULL && inpPtnrOfRel.RelationShip_Name == exstRel.Relationship_Type__c && inpPtnrOfRel.RelationShip_Code == exstRel.Relationship_Code__c) {
                    inpPtnrOfPrtyNbrMap.remove(exstRel.Related_Account__r.Master_Customer_Number__c); // remove relationshiop from input list
                    
                    Datetime inpRelDtTime = NULL;
                    if (String.isNotBlank(inpPtnrOfRel.ROR_Update_Datetime)) {
                        inpRelDtTime = Datetime.valueOfGMT(inpPtnrOfRel.ROR_Update_Datetime.replace('T',' ').replace('Z', ''));
                    }
                    
                    if(inpRelDtTime == NULL || inpRelDtTime > exstRel.ROR_Update_Date_Time__c) {                  
                        exstRel.Active__c = (inpPtnrOfRel.RelationShip_Status != NULL && inpPtnrOfRel.RelationShip_Status == 'A') ? TRUE : FALSE;
                        exstRel.ROR_Update_Date_Time__c = inpRelDtTime; 
                        exstRel.Start_Date__c = String.isNotBlank(inpPtnrOfRel.RelationShip_StartDate) ? Date.valueOf(inpPtnrOfRel.RelationShip_StartDate) : NULL;
                        
                        if (String.isNotBlank(inpPtnrOfRel.RelationShip_End_Date)) {
                            Date relEndDate = Date.valueOf(inpPtnrOfRel.RelationShip_End_Date);
                            Date maxDate = Date.newInstance(4000, 12, 31);
                            if(relEndDate > maxDate) exstRel.End_Date__c = maxDate;                                   
                            else exstRel.End_Date__c = relEndDate; 
                        } else {
                            exstRel.End_Date__c = NULL;    
                        }    
                        upsrtRelLst.add(exstRel);
                    }
                }
            }  
        }
        return upsrtRelLst;
    }
    
    public static cdm_Account_Relationship__c createReverseRelationship(cdm_Account_Relationship__c fwdAccRel, String rvRelCode, String rvRelName) {
        cdm_Account_Relationship__c rvAccRel = new cdm_Account_Relationship__c();   
        rvAccRel.Relationship_Type__c = fwdAccRel.Relationship_Type__c;                      
        rvAccRel.Relationship_Code__c = rvRelCode;
        rvAccRel.Name = rvRelName;        
        rvAccRel.Account__c = fwdAccRel.Related_Account__c;
        rvAccRel.Related_Account__c = fwdAccRel.Account__c;
        rvAccRel.Account_Number__c = fwdAccRel.Related_Account_Number__c; 
        rvAccRel.Related_Account_Number__c = fwdAccRel.Account_Number__c;
        rvAccRel.Active__c = fwdAccRel.Active__c;
        rvAccRel.ROR_Update_Date_Time__c = fwdAccRel.ROR_Update_Date_Time__c;
        rvAccRel.Start_Date__c = fwdAccRel.Start_Date__c;
        rvAccRel.End_Date__c = fwdAccRel.End_Date__c;  
        
        return rvAccRel;
    }
    
    public static List<Account> getRelatedAccounts(Set<String> relMCNs) {
        return [SELECT Id, Master_Customer_Number__c FROM Account WHERE Master_Customer_Number__c IN :relMCNs];  
    }
    
    public static void addWait(integer millisecs) {
        System.debug('<<wait start>>');
        Long strtTime = DateTime.now().getTime();
        Long fnlTime = DateTime.now().getTime();
        Long milsecsToWait = millisecs; // vary this depending on your "sleep" needs
        while (fnlTime - strtTime < milsecsToWait) {
            fnlTime = DateTime.now().getTime();
        }
        System.debug('<<wait end>>');
    }   
    
    public static List<Account> generateSites(String parentAccId, Map<String, Account> extSiteNbrMap, CDMService.SiteListWrapper sites) {
        List<Account> siteAccLst = new List<Account>();
        Set<String> unqSiteNbrs = new Set<String>();
        //EBA_SF-1338--current owner of site record to default to NSC Admin for new sites
        //Custom label - Site owner quicklook "adminnsc"
       User nscadmin = new User(Quicklook_ID__c = Label.Site_owner_quicklook);
        
        
        if (sites != NULL && sites.site != NULL && sites.site.size() > 0) {
            
            for (CDMService.SiteWrapper sw : sites.site) {
                if (String.isNotBlank(sw.SiteNumber) && String.isNotBlank(sw.SiteName) && String.isNotBlank(sw.NCR_Status)) {
                    if (!unqSiteNbrs.contains(sw.SiteNumber)) {
                        String billingAddress = (String.isNotBlank(sw.Address_Line1) ? sw.Address_Line1 : '')
                            + (String.isNotBlank(sw.Address_Line2) ? ('\n' + sw.Address_Line2) : '')
                            + (String.isNotBlank(sw.Address_Line3) ? ('\n' + sw.Address_Line3) : '')
                            + (String.isNotBlank(sw.Address_Line4) ? (',' +  sw.Address_Line4) : '');
                        //changes done for EBA_SF-2622 Salesforce is not transferring the Province field to the State field for HW RMAs. Province__c = sw.Province is added 
                        Account siteAcc = new Account(Account_CDM_ID__c = sw.SiteCDMId, Name = sw.SiteName, Site_Number__c = sw.SiteNumber,
                                                      CDM_Account_Status__c = sw.NCR_Status, ParentId = parentAccId, CDM_Account_Type__c = 'Site', 
                                                      Channel_Organization_Code__c = sw.Channel_Org_Code, cdm_Store_Branch_Number__c = sw.StoreNumber,
                                                      BillingStreet = trimStr(billingAddress, 255), BillingCity = trimStr(sw.City, 40), BillingState = sw.State,Province__c = sw.Province, 
                                                      BillingCountry = sw.Country, BillingPostalCode = sw.PostalCode,  
                                                      cdm_Solution_Set_Id__c = sw.Solution_SetID, cdm_NationalVatTaxID__c = sw.VATTaxNationalID,
                                                      Primary_Bill_To__c = false, Primary_Ship_To__c = false, Primary_Deliver_To__c = false,
                                                      Bill_To__c = false, Ship_To__c = false, Deliver_To__c = false,owner=nscadmin,
                                                      // Added by Stuti receiving Original Corporation field from CDM as part of story 2060
                                                      OriginalCorporation__c = sw.Product_Original_Corporation);
                        //Account exstSite = extSiteNbrMap.get(sw.SiteNumber);
                        //if(exstSite != NULL) siteAcc.Id = exstSite.Id;  
                        
                        if(sw.SiteUseList != NULL && sw.SiteUseList.SiteUse != NULL && sw.SiteUseList.SiteUse.size() > 0) {
                            for (CDMService.SiteUseWrapper su : sw.SiteUseList.SiteUse) {
                                Boolean isActiveSiteUse = (su.Status == 'A' ? true : false); 
                                
                                if(isActiveSiteUse) {
                                    switch on su.SiteUseType {
                                        when 'PRIMARY_BILL_TO' {
                                            siteAcc.Primary_Bill_To__c = true;
                                            siteAcc.Bill_To__c = true;
                                        }
                                        when 'BILL_TO' {
                                            siteAcc.Bill_To__c = true;
                                        }
                                        when 'PRIMARY_SHIP_TO' {
                                            siteAcc.Primary_Ship_To__c = true;
                                            siteAcc.Ship_To__c = true;
                                        }
                                        when 'SHIP_TO' {
                                            siteAcc.Ship_To__c = true;
                                        }
                                        when 'PRIMARY_DELIVER_TO' {
                                            siteAcc.Primary_Deliver_To__c = true;
                                            siteAcc.Deliver_To__c = true;
                                        }
                                        when 'DELIVER_TO' {
                                            siteAcc.Deliver_To__c = true;
                                        }
                                    }
                                }
                            }   
                        }   
                        
                        Account exstSite = extSiteNbrMap.get(sw.SiteNumber);
                        if(exstSite != NULL) {
                            if(isSiteDiff(exstSite, siteAcc)) {
                                 siteAcc.Id = exstSite.Id; 
                                 siteAccLst.add(siteAcc);
                            }
                        } else { siteAccLst.add(siteAcc);  }
                        
                        unqSiteNbrs.add(sw.SiteNumber);
                    }    
                } else {
                    throw new CDMCustomException('Site number, name or status missing for one of Account site');
                }
                 
            } 
         
        }
        
        return siteAccLst;
    }
    
    private static Boolean getBooleanValue(Object var) {
        return var != null ? (Boolean) var : false;
    }

    public static Boolean processCstmrRltns(Account updCstmr, Account exstCstmr, CDMService.CustomerWrapper CDMcst, Id entRTId) {
        Boolean recalcChildGU = false;
        String dmstcDUNS = null, EPPrtyNbr = null;
        List<Hierarchy_Relation__c> hrList = new List<Hierarchy_Relation__c>();
        
        CDMService.RelationshipWrapper EPOfRel = getEPOfRltnShip(CDMcst.CustomerRelations); // get Enterprise parent relationship
        
        if (EPOfRel != NULL) {
            if (exstCstmr == NULL && (Date.valueOf(EPOfRel.RelationShip_End_Date) <= Date.today() || EPOfRel.RelationShip_Status != 'A')) {
                // do nothing, no need to consume end dated relationship for new Customer
                System.debug('Relationship already ended or inactive');
            } else if (exstCstmr != NULL && EPOfRel.Related_PartyNumber == exstCstmr.Parent.Customer_Number__c 
                       && Date.valueOf(EPOfRel.RelationShip_End_Date) > Date.today() && EPOfRel.RelationShip_Status == 'A') {
                           
              populateEPFields(updCstmr, EPOfRel, false);       
            } else {
                Hierarchy_Relation__c hr = new Hierarchy_Relation__c(From_Party_Number__c = CDMcst.CustomerNumber, To_Party_Number__c = EPOfRel.Related_PartyNumber, 
                                                                     Relationship_Name__c = EPOfRel.RelationShip_Name, Relationship_Code__c = EPOfRel.RelationShip_Code, 
                                                                     Relationship_Status__c = EPOfRel.RelationShip_Status);
                hr.Start_Date__c = String.isNotBlank(EPOfRel.RelationShip_StartDate) ? Date.valueOf(EPOfRel.RelationShip_StartDate) : NULL;
                hr.End_Date__c = String.isNotBlank(EPOfRel.RelationShip_End_Date) ? (Date.valueOf(EPOfRel.RelationShip_End_Date) > maxDate ? maxDate : Date.valueOf(EPOfRel.RelationShip_End_Date)) : NULL;
                hrList.add(hr);
                // create custom relation object and schedule its processing     
            }    
            
        } 
        
        if (CDMcst.Domestic_Ultimate_DUNS_Number != CDMcst.DUNS_Number) { // check domestic DUNS should not point to itself
            
            if (exstCstmr == NULL || (exstCstmr != NULL && exstCstmr.Domestic_Ultimate_Lookup__c == NULL)
                || (exstCstmr != NULL && CDMcst.Domestic_Ultimate_DUNS_Number != exstCstmr.Domestic_Ultimate_Lookup__r.DUNS__c
                    && (exstCstmr.RoR_Update_Date_Time__c == null || Date.valueOf(CDMcst.ROR_Update_Datetime) > exstCstmr.RoR_Update_Date_Time__c))) {
                        
                        if (String.isNotBlank(CDMcst.Domestic_Ultimate_DUNS_Number)) {                            
                            dmstcDUNS = CDMcst.Domestic_Ultimate_DUNS_Number; 
                        } else {
                            updCstmr.Domestic_Ultimate_Lookup__c = NULL;        
                        }     
                    }
        }
        
        //if Enterprise Parent or Domestic Ultimate change
        if (String.isNotBlank(EPPrtyNbr) || String.isNotBlank(dmstcDUNS)) { 
            List<Account> prntCstmrAccts = getPrntCstmrAccts(EPPrtyNbr, dmstcDUNS);
            
            for (Account ca : prntCstmrAccts) {
                if (String.isNotBlank(EPPrtyNbr) && ca.Customer_Number__c == EPPrtyNbr) {
                    updCstmr.ParentId = ca.Id; 
                    updCstmr.Global_Ultimate_Lookup__c = (ca.Global_Ultimate_Lookup__c != null ? ca.Global_Ultimate_Lookup__c : ca.Id);
                } else if (String.isNotBlank(dmstcDUNS) && ca.DUNS__c == dmstcDUNS) { 
                    updCstmr.Domestic_Ultimate_Lookup__c = ca.Id;       
                }
            }
            
            if (String.isNotBlank(EPPrtyNbr) && updCstmr.ParentId == NULL) {
                // create EP
                Account EPCstmr = createEPCstmr(EPOfRel.Related_PartyNumber, EPOfRel.Related_PartyName, entRTId);
                updCstmr.ParentId = EPCstmr.Id;
                updCstmr.Global_Ultimate_Lookup__c = EPCstmr.Id;
            }
            
            if (String.isNotBlank(dmstcDUNS) && updCstmr.Domestic_Ultimate_Lookup__c == NULL) {
                //create relation object
                hrList.add(new Hierarchy_Relation__c(From_Party_Number__c = CDMcst.CustomerNumber, To_Party_Number__c = dmstcDUNS, 
                                                     Relationship_Name__c = DOMESTIC_ULTIMATE_REL));
            } 
        }
        
        if (!hrList.isEmpty()) {
            insert hrList;
            scheduleHRYUpdate();
        }
        
        return recalcChildGU;
        
    }
    
    
    // get Enterprise parent relationship from relationship list
    public static CDMService.RelationshipWrapper getEPOfRltnShip(List<CDMService.RelationshipWrapper> cstmrRltns) {
        CDMService.RelationshipWrapper EPOfRel = null;
        
        //found one Enterprise Parent of relationship
        if (cstmrRltns != null && cstmrRltns.size() > 0) {
            for (CDMService.RelationshipWrapper rw : cstmrRltns) {
                if (rw.RelationShip_Name.equalsIgnoreCase('Enterprise Parent') && rw.RelationShip_Code.equalsIgnoreCase('Enterprise Child of') 
                    && String.isNotBlank(rw.Related_PartyNumber) && String.isNotBlank(rw.RelationShip_End_Date)) {
                        if (EPOfRel != null) {
                            if (rw.RelationShip_End_Date > EPOfRel.RelationShip_End_Date) {
                                EPOfRel = rw;    
                            }                         
                        } else {
                            EPOfRel = rw;    
                        }    
                    }
            }   
        }
        return EPOfRel;
    }
    
    // Query Enterprise Parent or DU Customer
    public static List<Account> getPrntCstmrAccts(String EPPrtyNbr, String dmstcDUNS) {
        String cstmrQuery = 'SELECT Id, DUNS__c, Customer_Number__c, Global_Ultimate_Lookup__c FROM Account WHERE RecordType.Name = \'Enterprise\'';
        
        if (String.isNotBlank(EPPrtyNbr) && String.isNotBlank(dmstcDUNS)) {
            cstmrQuery += ' AND (DUNS__c = :dmstcDUNS OR Customer_Number__c = :EPPrtyNbr)';      
        } else if(String.isNotBlank(EPPrtyNbr)) {
            cstmrQuery += ' AND Customer_Number__c = :EPPrtyNbr';        
        } else if(String.isNotBlank(dmstcDUNS)) {
            cstmrQuery += ' AND DUNS__c = :dmstcDUNS';     
        } 
        return (List<Account>) Database.query(cstmrQuery);
    }
    
    // create Enterprise Parent Account
    // use recordTypeId instead of AccountType population
    public static Account createEPCstmr(String CstmrNbr, String CstmrName, String entRTId) {
        Account ca = new Account(Name = CstmrName, Customer_Number__c = CstmrNbr, CDM_Account_Type__c = 'CUSTOMER', RecordtypeId = entRTId);
        insert ca; 
        return ca;
    }
    
    // populate Enterprise parent specific fields on Customer
    public static void populateEPFields(Account updCstmr, CDMService.RelationshipWrapper EPOfRel, Boolean isClearEP) {
        if (isClearEP) {
            updCstmr.ParentId = null;
            updCstmr.Global_Ultimate_Lookup__c = null;
            updCstmr.cdm_Enterprise_Parent_Start_Date__c = null;
            updCstmr.cdm_Enterprise_Parent_End_Date__c = null;
            updCstmr.cdm_Enterprise_Parent_Number__c = '';
            updCstmr.cdm_Enterprise_Parent_Status__c = '';    
        } else {
            updCstmr.cdm_Enterprise_Parent_Start_Date__c = String.isNotBlank(EPOfRel.RelationShip_StartDate) ? Date.valueOf(EPOfRel.RelationShip_StartDate) : NULL;
            updCstmr.cdm_Enterprise_Parent_End_Date__c = String.isNotBlank(EPOfRel.RelationShip_End_Date) ? (Date.valueOf(EPOfRel.RelationShip_End_Date) > maxDate ? maxDate : Date.valueOf(EPOfRel.RelationShip_End_Date)) : NULL;
            updCstmr.cdm_Enterprise_Parent_Number__c = EPOfRel.Related_PartyNumber;
            updCstmr.cdm_Enterprise_Parent_Status__c = (EPOfRel.RelationShip_Status != NULL && EPOfRel.RelationShip_Status == 'A') ? 'Active' : 'Inactive';         
        }
    }
    
    public static void scheduleHRYUpdate() {
        List<AsyncApexJob> asyncObjList = [SELECT Id, Status, TotalJobItems, NumberOfErrors 
                                           FROM AsyncApexJob WHERE ApexClassID = :System.Label.AccHrchyRecalcClassId and 
                                           JobType = 'ScheduledApex' and 
                                           Status IN('Holding','Queued','Preparing','Processing')];
        try {
            if(asyncObjList.isEmpty() || (asyncObjList.size() == 0)) { 
                Datetime nextSchdTime = Datetime.now().addMinutes(1);                
                System.schedule('Account Hierarchy Calculation', '0 ' + nextSchdTime.minute() + ' ' + nextSchdTime.hour() + ' ' + nextSchdTime.day() + ' ' +  nextSchdTime.format('MMM').toUpperCase() + ' ? ' + nextSchdTime.year(), new ScheduleAccountGUUpdate());
            }
        } catch(Exception e) {
            System.debug('Hierarchy Schedule Error:' + e.getMessage());
        }
    } 
    
    public static String trimStr(String inStr, integer maxLen) {
      if(String.isNotBlank(inStr) && inStr.length() > maxLen) 
            inStr = inStr.left(maxLen);
        return inStr; 
    }
    
    public static Boolean isSiteDiff(Account exstSite, Account updSite) {        
        return (exstSite.Account_CDM_ID__c != updSite.Account_CDM_ID__c || exstSite.Name != updSite.Name 
                || exstSite.CDM_Account_Status__c != updSite.CDM_Account_Status__c || exstSite.ParentId != updSite.ParentId
                || exstSite.Channel_Organization_Code__c != updSite.Channel_Organization_Code__c || exstSite.cdm_Store_Branch_Number__c != updSite.cdm_Store_Branch_Number__c
                || exstSite.BillingStreet != updSite.BillingStreet || exstSite.BillingCity != updSite.BillingCity || exstSite.BillingState != updSite.BillingState
                || exstSite.BillingCountry != updSite.BillingCountry || exstSite.BillingPostalCode != updSite.BillingPostalCode 
                || exstSite.cdm_Solution_Set_Id__c != updSite.cdm_Solution_Set_Id__c || exstSite.cdm_NationalVatTaxID__c != updSite.cdm_NationalVatTaxID__c 
                || exstSite.Primary_Bill_To__c != updSite.Primary_Bill_To__c || exstSite.Primary_Ship_To__c != updSite.Primary_Ship_To__c || exstSite.Primary_Deliver_To__c != updSite.Primary_Deliver_To__c 
                || exstSite.Bill_To__c != updSite.Bill_To__c || exstSite.Ship_To__c != updSite.Ship_To__c || exstSite.Deliver_To__c != updSite.Deliver_To__c);
    }
    
    
    public class CDMCustomException Extends Exception {}
}