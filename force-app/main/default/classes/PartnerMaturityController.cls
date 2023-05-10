/****************************************************************************************************************
* ClassName     :   PartnerMaturityController
* Author        :   Puneet Bhatia
* Version       :   Initial
* Description   :   This Class is used by PartnerMaturityStatus component for showing Partner Maturity Levels.
****************************************************************************************************************/
public without sharing class PartnerMaturityController {
    final static String INITIAL_MATURITY_LEVEL = 'LEVEL 0';
    final static String ALL_LEVEL_COMPLETED = 'ALL LEVEL COMPLETED';
    final static String NEW_STATUS = 'New', APRVD_STATUS = 'Approved', RJCT_STATUS = 'Rejected';    
    
    /*****************************************************************************************************
    * Param         :   Account Record id
    * Return        :   MaturityLevelWrapper list
    * Description   :   This method return wrapper of Partner Maturity Levels and Partner Maturity Status 
                        records related to Account.
    ******************************************************************************************************/
    @AuraEnabled 
    public static List<MaturityLevelWrapper> getPartnerMaturityLevels(String accId) {
        List<MaturityLevelWrapper> partMatLvls = new List<MaturityLevelWrapper>(); 
        
        if(String.isNotBlank(accId)) {
            String sntzdAccId =  String.escapeSingleQuotes(accId);
            
            // get Account and Account Team member details
            List<Account> accLst = [SELECT Id, OwnerId, Partner_Maturity_Level__c, 
                                       (SELECT UserId FROM AccountTeamMembers) 
                                        FROM Account WHERE Id = :sntzdAccId LIMIT 1];
            
            if(!accLst.isEmpty()) {
                
                // get account maturity level and maturity status
                List<Partner_Maturity_Status__c> pmsLst = [SELECT Id, 
                                                            Name, Order__c, Action__c, Maturity_Level__c,
                                                            Date_Completed__c, EST_Complete_Date__c,  
                                                            Action_Code__c, Status__c, Comments__c,HelpText__c,
                                                            Action_Owner__c, Partner_Maturity_Level__c,
                                                            Partner_Maturity_Level__r.Name, Partner_Maturity_Level__r.Account__c,
                                                            Partner_Maturity_Level__r.Approval_Status__c,
                                                            Partner_Maturity_Level__r.Approver_Comments__c,
                                                            Partner_Maturity_Level__r.No_of_Actions__c,
                                                            Partner_Maturity_Level__r.Complete_Actions__c,
                                                            Partner_Maturity_Level__r.Approved_Date__c
                                                            FROM Partner_Maturity_Status__c
                                                            WHERE Partner_Maturity_Level__r.Account__c = :sntzdAccId];
                
                String currMatLvl = getCurrentMaturityLevel(accLst.get(0)); 
                Map<String, Partner_Maturity_Status__c> exstMatLvls = new Map<String, Partner_Maturity_Status__c>();                                            
                
                if(!pmsLst.isEmpty()) {
                    for(Partner_Maturity_Status__c pms : pmsLst) {
                        String lvlOrdCode = pms.Maturity_Level__c + '-' + pms.Order__c;
                        exstMatLvls.put(lvlOrdCode, pms);      
                    }  
                } 
                partMatLvls = populateMatLvlWrapperList(currMatLvl, accLst.get(0), exstMatLvls);                                                                                       
            }                                                
        }
        return partMatLvls; 
    }
    
    
    /*****************************************************************************************************
    * Param         :   Account Record
    * Return        :   Current Maturity Level of Account
    * Description   :   This method return current Maturity Level of Account, if Current Maturity Level
                        is blank, then it updates it to 'LEVEL 0'.
    ******************************************************************************************************/
    public static String getCurrentMaturityLevel(Account ptnrAcc) {
        String currMatLvl;
        
        if(ptnrAcc != null && ptnrAcc.Id != null) {
            
            // if blank Partner_Maturity_Level__c and current user has permission to update Value Prompter
            if(String.isBlank(ptnrAcc.Partner_Maturity_Level__c) && Schema.sObjectType.Account.isUpdateable()) {
                ptnrAcc.Partner_Maturity_Level__c = INITIAL_MATURITY_LEVEL;    
                update ptnrAcc; // check if user has permission to update Account
            }  
            currMatLvl = ptnrAcc.Partner_Maturity_Level__c;
        }        
        return currMatLvl;     
    }    
    
    
    /*****************************************************************************************************
    * Param         :  currentMatLvl - Current Maturity Level of Account
                       partnerAcc - Partner Account Record
                       existMatLevels - Existing maturity level and action records of Account 
                                
    * Return        :   MaturityLevelWrapper list
    * Description   :   This method return current Maturity Level of Account, if Current Maturity Level
                        is blank, then it updates it to 'LEVEL 0'.
    ******************************************************************************************************/
    public static List<MaturityLevelWrapper> populateMatLvlWrapperList(String currMatLvl, Account ptnrAcc, Map<String, Partner_Maturity_Status__c> exstMatLvls) {
        Map<String, MaturityLevelWrapper> matLvlAndWrapMap = new Map<String, MaturityLevelWrapper>();
        
        // get all maturity levels from custom setting and sort them by name
        List<PartnerMaturityLevelActions__c> allMatLvls = PartnerMaturityLevelActions__c.getall().values();
        allMatLvls.sort();
        
        // check logged in user edit access
        Boolean usrEditAcss = getCurrUsrEditAcss(ptnrAcc);
        currMatLvl = (currMatLvl == 'ALL LEVEL COMPLETED') ? 'LEVEL 6' :  currMatLvl;
        integer currMatLvlNbr = String.isNotBlank(currMatLvl) ? integer.valueOf(currMatLvl.right(1)) : -1;
       
            
        for (PartnerMaturityLevelActions__c pla : allMatLvls) {
            String loCode = pla.Name;
            String levelAprvlStatus = 'New';
            String levelApprvlComments = '';
            Date levelApprvdDate = null; 
               
            MaturityActionWrapper matwrp = new MaturityActionWrapper();  
            
            if (exstMatLvls.containsKey(loCode)) { // also check if exist mat level less that current mat level 
                Partner_Maturity_Status__c exstMat = exstMatLvls.get(loCode);
                
                matwrp.actionLevel = exstMat.Maturity_Level__c;
                matwrp.actionOrder = exstMat.Order__c;
                matwrp.action =  exstMat.Action__c;
                matwrp.actionCode = exstMat.Action_Code__c;
                matwrp.helptext = exstMat.HelpText__c;
                // populate level Id only for exiting records
                matwrp.levelId = exstMat.Partner_Maturity_Level__c; 
                matwrp.dateCompleted = String.valueOf(exstMat.Date_Completed__c);
                matwrp.status = exstMat.Status__c;
                matwrp.actionOwner = exstMat.Action_Owner__c;
                matwrp.estCompleteDate = String.valueOf(exstMat.EST_Complete_Date__c);
                matwrp.actionComments = exstMat.Comments__c;
                levelAprvlStatus = exstMat.Partner_Maturity_Level__r.Approval_Status__c;
                levelApprvlComments = exstMat.Partner_Maturity_Level__r.Approver_Comments__c;
                levelApprvdDate = exstMat.Partner_Maturity_Level__r.Approved_Date__c;
            } else {
                matwrp.actionLevel = pla.Level__c ;
                matwrp.actionOrder = pla.Order__c;
                matwrp.action =  pla.Action__c;
                 matwrp.helptext = pla.HelpText__c;
                
                // if(pla.Level__c == currentMatLvl) { set actionCode only for current maturity level
                    matwrp.actionCode = pla.Level__c.replace(' ', '') + '-' + pla.Order__c + '-' + ptnrAcc.Id; 
                    matwrp.dateCompleted = null;
                    matwrp.status = '';
                    matwrp.actionOwner = '';
                    matwrp.estCompleteDate = null;
                    matwrp.actionComments = '';
                //}
            }
            
            // create maturity levels
            MaturityLevelWrapper tmpMatWrp = matLvlAndWrapMap.get(matwrp.actionLevel);
            
            if(tmpMatWrp == null) { 
                tmpMatWrp = new MaturityLevelWrapper();
                tmpMatWrp.level = matwrp.actionLevel;
                tmpMatWrp.uniqname = matwrp.actionLevel.replace(' ', '');
                tmpMatWrp.currentMatlevel = currMatLvl;
                tmpMatWrp.aprvlStatus = levelAprvlStatus;
                tmpMatWrp.aprvlComments = levelApprvlComments;
                tmpMatWrp.aprvlDate = (levelApprvdDate != null) ? Datetime.newInstance(levelApprvdDate.year(), levelApprvdDate.month(),levelApprvdDate.day()).format('yyyy-MM-dd'): '';
                tmpMatWrp.actionsList = new List<MaturityActionWrapper>();
                
                if(usrEditAcss) {
                    if(String.isNotBlank(tmpMatWrp.level)) {
                        integer matLvlNbr = integer.valueOf(tmpMatWrp.level.right(1));
                        tmpMatWrp.editAccesss = (currMatLvlNbr >= 0 && matLvlNbr >= currMatLvlNbr) ? true : false;    
                    }
                }
               
                matLvlAndWrapMap.put(matwrp.actionLevel, tmpMatWrp);
            }
            
            tmpMatWrp.actionsList.add(matwrp);
        }
        
        return matLvlAndWrapMap.values();       
    }
    
    /*****************************************************************************************************
    * Param         :   partnerAcc - Partner Account Record
    * Return        :   current user access to update partner maturity status
    * Description   :   This method return current user access to update partner maturity status.
    ******************************************************************************************************/
    public static Boolean getCurrUsrEditAcss(Account ptnrAcc) {
        Boolean editAcss = false;
        // 02, 04 and System admin profileIds
        // //Changes done by Yogesh - related to Story EBA_SF-1918
       // Set<Id> adminPrflIds = new Set<Id>{'00e700000013gPe', '00e70000000x3eg', '00e70000000sR8U'};
       Set<Id> adminPrflIds = NSCCommonInfoUtil.getIdSetOf('PMC_ProfileId');
        // End Changes by Yogesh
        Set<Id> accOwrTeamIds = new Set<Id>();
        
        accOwrTeamIds.add(ptnrAcc.OwnerId);
        
        for (AccountTeamMember atm : ptnrAcc.AccountTeamMembers) {
            accOwrTeamIds.add(atm.UserId);
        } 
        
        if (adminPrflIds.contains(UserInfo.getProfileId()) || accOwrTeamIds.contains(UserInfo.getUserId())) {
            editAcss = true; 
        }   
        return editAcss;
    }
    
    @AuraEnabled 
    public static void saveCurrentMatLevel(String activeLevel, String accId, String currMatJson) {
        try {
            List<MaturityActionWrapper> currMatActLst = (List<MaturityActionWrapper>) System.JSON.deserialize(currMatJson, List<MaturityActionWrapper>.class);    
            
            // upsert Partner_Maturity_Level__c record
            Partner_Maturity_Level__c parentMatLvl = new Partner_Maturity_Level__c(Name = activeLevel, Account__c = accId, LEVEL_Code__c = activeLevel.replace(' ', '')  + '-' + accId);  
            upsert parentMatLvl LEVEL_Code__c;
            //System.debug(parentMatLevel.Id);
            
            List<Partner_Maturity_Status__c> pmsLst = new List<Partner_Maturity_Status__c>();
            
            for(MaturityActionWrapper actWrp : currMatActLst)  {
                Partner_Maturity_Status__c pms = new Partner_Maturity_Status__c();
                
                pms.Action_Code__c = actWrp.actionCode;
                pms.Action__c = actWrp.action;
                pms.Action_Owner__c =  actWrp.actionOwner;
                pms.Order__c = actWrp.actionOrder;
                pms.Date_Completed__c = String.isNotBlank(actWrp.dateCompleted) ? Date.valueOf(actWrp.dateCompleted) : null;
                pms.Status__c = actWrp.status; 
                pms.EST_Complete_Date__c = String.isNotBlank(actWrp.estCompleteDate) ? Date.valueOf(actWrp.estCompleteDate) : null;
                pms.Comments__c = actWrp.actionComments; 
                pms.HelpText__c = actWrp.helptext; 
                
                if(String.isBlank(actWrp.levelId)) {
                    pms.Partner_Maturity_Level__c =  parentMatLvl.Id;   
                }
                pmsLst.add(pms); 
            }
            
            upsert pmsLst Action_Code__c; 
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }   
    
    @AuraEnabled
    public static void submitForApproval(String accId, String currentMatlevel) {
        if (String.isNotBlank(accId) && String.isNotBlank(currentMatlevel)) {
            List<Partner_Maturity_Level__c> pmlevel = [SELECT Id, Name, Approval_Status__c, No_of_Actions__c, Complete_Actions__c, Account__r.Owner.ManagerId FROM Partner_Maturity_Level__c WHERE Account__c = :accId AND Name = :currentMatlevel LIMIT 1];
            
            if (!pmlevel.isEmpty()) {
                String apprvlSts = pmlevel.get(0).Approval_Status__c;
                Integer ttlActCount = Integer.valueOf(pmlevel.get(0).No_of_Actions__c);
                Integer compActCount = Integer.valueOf(pmlevel.get(0).Complete_Actions__c);
                
                if (apprvlSts != 'Approved' && apprvlSts != 'Submitted') {
                    if((ttlActCount > 0) && (ttlActCount == compActCount)) {
                        
                        //Update Approval Requester on Partner Maturity record 
                        Partner_Maturity_Level__c sbmtLvl = new Partner_Maturity_Level__c(Id = pmlevel.get(0).Id, Approval_Requester__c = UserInfo.getUserId());
                        update sbmtLvl;
                        
                        Approval.ProcessSubmitRequest appreq = new Approval.ProcessSubmitRequest();
                        appreq.setComments('Submitting Partner Maturity Level for approval.');
                        appreq.setObjectId(pmlevel.get(0).Id);
                        
                        // Submit the approval request for the account
                        Approval.ProcessResult rslt = Approval.process(appreq);
                        
                        // Verify the result
                        System.debug(rslt.isSuccess());  
                    } else {
                        throw new AuraHandledException('For each level, populating all fields (except comments) for each action is required, before Submitting for Approval.');      
                    }
                } else if(apprvlSts == 'Submitted') {
                    throw new AuraHandledException('This Partner Maturity Level is already Submitted for Approval');        
                } 
                
                else {
                    throw new AuraHandledException('This Partner Maturity Level is already Approved');      
                } 
                
            }
            
        }
    }
    
    @AuraEnabled 
    public static List<String> getStatusPickListVals() {
        List<String> stsPklst = new List<String>();
        for(Schema.PicklistEntry ple : Partner_Maturity_Status__c.Status__c.getDescribe().getPicklistValues()) {
            stsPklst.add(ple.getValue());
        }          
        return stsPklst;  
    } 
    
    
    /*****************************************************************************************************
    * Param         :   Account Record id
    * Return        :   MaturityLevelWrapper list
    * Description   :   This method return wrapper of Partner Maturity Levels and Partner Maturity Status 
                        records related to Account.
    ******************************************************************************************************/
    @AuraEnabled 
    public static MaturityLevelWrapper getPartnerMaturityStatusList(String lvlId) {
        List<MaturityActionWrapper> pmsLst = new List<MaturityActionWrapper>(); 
        MaturityLevelWrapper pmlwrp = new MaturityLevelWrapper();
        pmlwrp.actionsList = pmsLst; 
        
        if(String.isNotBlank(lvlId)) {
            String sntzdLvlId = String.escapeSingleQuotes(lvlId);

            // get partner maturity level and maturity status
            List<Partner_Maturity_Level__c> pmlLst = [SELECT Id, Name, Account__c,
                                                        (SELECT Id, Name, Order__c, Action__c, 
                                                         Date_Completed__c, EST_Complete_Date__c,  
                                                         Action_Code__c, Status__c, Comments__c,HelpText__c,
                                                         Action_Owner__c, Maturity_Level__c 
                                                         FROM Partner_Maturity_Status__r Order by Action_Code__c)
                                                         FROM Partner_Maturity_Level__c
                                                         WHERE Id = :sntzdLvlId LIMIT 1];
           
            if(!pmlLst.isEmpty()) {
                Partner_Maturity_Level__c currMatLvl = pmlLst.get(0);    
                
                if(!currMatLvl.Partner_Maturity_Status__r.isEmpty()) {
                    for(Partner_Maturity_Status__c pms : currMatLvl.Partner_Maturity_Status__r) {
                        MaturityActionWrapper pmswrp = new MaturityActionWrapper();
                        pmswrp.actionLevel = pms.Maturity_Level__c;
                        pmswrp.actionOrder = pms.Order__c;
                        pmswrp.action = pms.Action__c;
                        pmswrp.actionCode = pms.Action_Code__c;            
                        pmswrp.dateCompleted = String.valueOf(pms.Date_Completed__c);
                        pmswrp.status = pms.Status__c;
                        pmswrp.actionOwner = pms.Action_Owner__c;
                        pmswrp.estCompleteDate = String.valueOf(pms.EST_Complete_Date__c);
                        pmswrp.actionComments = pms.Comments__c;
                        pmswrp.helptext = pms.HelpText__c;
                        pmsLst.add(pmswrp);   
                    }
                } 
                
                pmlwrp.level = currMatLvl.Name;
                pmlwrp.uniqname = currMatLvl.Name.replace(' ', '');
                pmlwrp.currentMatlevel = currMatLvl.Name;            
            }        
                                                                                                                               
        }
        return pmlwrp; 
    }
    
    
    /****************************************************************************************************************
    * Author        :   Puneet Bhatia
    * Description   :   Wrapper Class
    ****************************************************************************************************************/
    public class MaturityLevelWrapper implements Comparable {
        @AuraEnabled 
        public Boolean editAccesss{
            get {
                if(editAccesss == null) editAccesss = false; 
                return editAccesss;
            }
            private set;
        }
        @AuraEnabled 
        public String aprvlStatus{get; private set;}
        @AuraEnabled 
        public String aprvlComments{get; private set;}
        @AuraEnabled 
        public String aprvlDate{get; private set;}
        @AuraEnabled 
        public String level{get; private set;}
        @AuraEnabled 
        public String uniqname{get; private set;}
        @AuraEnabled 
        public String currentMatlevel{get; private set;}
        @AuraEnabled 
        public List<MaturityActionWrapper> actionsList{get;set;} 
        
        public Integer compareTo(Object ObjToCompare) {
            integer lvlnum = integer.valueOf(this.level.right(1));
            integer complvlnum = integer.valueOf(((MaturityLevelWrapper)ObjToCompare).level.right(1));
            integer result = (lvlnum > complvlnum ? 1 : (lvlnum < complvlnum ? -1 : 0));
            return result;
        }
    }
    
    /****************************************************************************************************************
    * Author        :   Puneet Bhatia
    * Description   :   Wrapper Class
    ****************************************************************************************************************/
    public class MaturityActionWrapper {
        // keep all variables in string format for JSON safe
        @AuraEnabled 
        public String levelId{get; private set;}
        @AuraEnabled 
        public String actionCode{get; private set;}
        @AuraEnabled 
        public String actionLevel{get; private set;}
        @AuraEnabled 
        public String action{get; private set;}
        @AuraEnabled
        public String actionOrder{get; private set;}  
        @AuraEnabled
        public String dateCompleted{get;set;}  
        @AuraEnabled
        public String status{get;set;} 
        @AuraEnabled
        public String actionOwner{get;set;}  
        @AuraEnabled
        public String estCompleteDate{get;set;} 
        @AuraEnabled
        public String actionComments{get;set;}
        @AuraEnabled
        public String helptext{get;set;}
    }
}