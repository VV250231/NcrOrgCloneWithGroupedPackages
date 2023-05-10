/****************************************************************************************************************
*   ClassName :   OpportunityTriggerDispatcher
*   Description :   
*   Author      :   
*   Version     :   42
# Modification History.: 
Story No#         Date            DevName            Description
EBA_SF-1660     1 Dec 2021      Varsha Pal           Allow users to reopen the opportunity once it is closed - changes made in beforeUpdate method
EBA_SF-1591     03-12-2022      Puneet Bhatia		 Added changes to send Payment processing application for onboarding once opportunity gets Closed/Booked.
EBA_SF-2058     05-30-2022		Puneet Bhatia        Added changes to bypass Cardtronics Opportunity Records in Apex
EBA_SF-2076     15-06-2022      Monika Mathur        Added changes on before update for Opps with misalignment between 
                                                     Actual Closed Date and derived fields from that one (Book Qtr/Month/Week)
****************************************************************************************************************/
public class OpportunityTriggerDispatcher extends TriggerHandlerBase {
    
    private static OpportunityTriggerHandler oppHdlr;
    
    /************************************** Opportunity BEFORE INSERT *************************************
* Description : 1. Replacement of UpdatereportingFields trigger 

2. Replacement of QuBy_OpportunityTrigger_BFR trigger 

3.This trigger populates the Book Date fields on the Opportunity.These fields are used in OCR extraction.
4. Convert currency other than USD to USD
5. logic to set EDSD as per first schedule
6.update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data.
7.populate standard forecast category field from custom forecast category field-
*************************************************************************************************/
    public override void beforeInsert() {
        oppHdlr = (oppHdlr != null) ? oppHdlr : new OpportunityTriggerHandler();
        //Get List of NON CPQ Opps
        ////@changed CPQ
        List <Opportunity> nonCpqOppsList=oppHdlr.fltrOutCPQ((List<Opportunity>) Trigger.new);
        // Add any Lead Conversion specific logic here     
        oppHdlr.handleLeadConversion_BeforeInsert((List<Opportunity>) Trigger.new);
        // validate channel local office selected for CPQ Opp
        oppHdlr.valdChnlLclOffc((List<Opportunity>) Trigger.new);
        //Update Commitment Risk to None While Cloning Opportunity
        oppHdlr.updateCommitmentRiskForCloneOpportunity((List<Opportunity>) Trigger.new);
        
        // Update reporting fields 
        oppHdlr.UpdateReportingFields_BeforeInsert((List<Opportunity>) Trigger.new);
        
        //Quote Validation on Opportunity
        OpportunityTriggerHandlerHelper OppTriggerHelper = new OpportunityTriggerHandlerHelper();
        if(nonCpqOppsList.Size()>0 && OppTriggerHelper.hasPermission()){
            //@changed CPQ
            oppHdlr.QouteValidationOnOpportunityClose_BeforeInsert(nonCpqOppsList);
        }
        
        //Populate OCR fields
        //Changes done by Yogesh related to EBA_SF-1381       
        //oppHdlr.PopulateOCRBookDateFields_Insert((List<Opportunity>) Trigger.new, oldMapOpportunity);
         oppHdlr.PopulateOCRBookDateFields_InsertOrUpdate((List<Opportunity>) Trigger.new);   
        //End changes -Yogesh EBA_SF-1381
       
        //Currency Conversion
        oppHdlr.CurrencyIsoConversion((List<Opportunity>) Trigger.new);
        
        //Set Expected Dilevary Start Date 
        oppHdlr.UpdateEDDtoEBD_BeforeInsert((List<Opportunity>) Trigger.new);
        
        // Populate Sales Org lookup from CDM Sales Org Code
        oppHdlr.populateSalesOrgLookup((List<Opportunity>) Trigger.new);
        
        
        //update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data.
       // oppHdlr.PopulateOcrTeamAndContactRole((List<Opportunity>) Trigger.new);
        
        //populate standard forecast category field from custom forecast category field-Nagendra
        if(CheckRecursive.runValiateOppTrigger()) {
            oppHdlr.PopulateForecastCategory_BeforeInsert((List<Opportunity>) Trigger.new);
        }
    }
    /************************************** Opportunity AFTER INSERT *************************************
* Description : 1. Replacement of clearFieldsOnOppClone trigger 
2. update campaign activity record to qualify it, if inserting opportunity has campaing Id
associated with it. - Shiv [sm250665] 
3. Auto-populate Decision Maker Contact on Renewal Opportunity -Nagendra 
4.insert/update opportunitycontactrole record based on Contact lookup on opporunity

*************************************************************************************************/
    public override void afterInsert() {
        oppHdlr = (oppHdlr != null) ? oppHdlr : new OpportunityTriggerHandler();
        ////@changed CPQ
        List <Opportunity> nonCpqOppsList=oppHdlr.fltrOutCPQ((List<Opportunity>) Trigger.new);
        List <Opportunity> CPQOppsList=oppHdlr.fltrOutNonCPQ((List<Opportunity>) Trigger.new);
        List <Opportunity> CATMOppsList=oppHdlr.fltrOutNonCATM((List<Opportunity>) Trigger.new);
        
        // added changes to filter out Non-CATM Opp List
        List<Opportunity> nonCATMOppList = new List<Opportunity>(nonCpqOppsList); 
        nonCATMOppList.addAll(CPQOppsList);
            
        List<Opportunity> newOppList = new List<Opportunity>();
        newOppList =   (List<Opportunity>) Trigger.new;
        
        //Cloning functionality - clearFieldsOnOppClone
        if((nonCpqOppsList!=null && nonCpqOppsList.size()>0) || (CATMOppsList!=null && CATMOppsList.size()>0))
            CloneOpportunityWithSchedule.InsertScheduleUnderCloneOpportunit(Trigger.NewMap.Keyset());
        
        //update campaign activity- Shiv [sm250665]  UpdateCampaignActivity trigger
        // Opportunity Channelvar =  (Opportunity) Trigger.New[0];
        //IF(Channelvar.Is_Channel_Opportunity__c == false){ = commenting to remove is_channel_opportunity__c
        //End of Switch code  
        /* This function is no more required
if(checkRecursive.runOnce()){
//system.debug('campaign Inside dispatcher'+(List<Opportunity>) Trigger.new);
UpdateCampaignActivityUtil.updateCampaignActivityToQualify((List<Opportunity>) Trigger.new);
}*/
        
        //}
        //End
        
        // NC_AGILE-895   Auto-populate Decision Maker Contact on Renewal Opportunity - Nagendra
        /*Set<ID> HOSPAndRetail_PROFILE_IDS = new Set<ID>{'00e70000000xBoN', '00e70000000xBoS', '00e70000000xBoX', '00e70000000xFkD',
            '00e70000000xBoNAAU','00e70000000xBoSAAU','00e70000000xBoXAAU','00e70000000xFkDAAU',
            '00e0m000000E5eB','00e0m000000E5eBAAS','00en0000000M2AO','00en0000000M2AOAA0',
            '00e70000001BOL5','00e70000001BOL5AAO'};*/
                
                try {
                    if(NSCCommonInfoUtil.getIdSetOf('HOSPAndRetail_PROFILE').contains(UserInfo.getProfileId())){
                        // added changes to filter out Non-CATM Opp List
                        HelperOpportunity.insertContactRoleDecisionMaker(nonCATMOppList);
                        //HelperOpportunity.insertContactRoleDecisionMaker((List<Opportunity>) Trigger.new); 
                    }
                } catch(Exception e) {
                    for(Opportunity opp: newOppList){ 
                        opp.addError('Error:' + e.getMessage());
                    }
                }
        //Logic No 4. Part of trigger PopulateOcrTeamAndContactRole
        //IF(newOppList[0].Is_Channel_Opportunity__c == false){ = comenting to remove is_channel_opportunity__c
        try {
            // added changes to filter out Non-CATM Opp List
           	HelperOpportunity.insertContactRoleFromOpportunity(nonCATMOppList);
            //HelperOpportunity.insertContactRoleFromOpportunity(newOppList);
        } catch(Exception e) {
            for(Opportunity opp: newOppList){ 
                opp.addError('Error:' + e.getMessage());
            }
        }
        //}
        Set<ID> oppIdDealRegSet = new Set<ID>();  //abhishek
        
        for(Opportunity obj: (List<Opportunity>) Trigger.new) {
            //obj.Secondary_Campaign__c=null;
            // added changes to filter out Non-CATM Opp List
            if(obj.Linked_Special_Bid_Registration__c != NULL && !obj.CATM_Record__c){ 
                oppIdDealRegSet.add(obj.Id);                          
            }
        }            
         if(!oppIdDealRegSet.isEmpty() || nonCATMOppList.size() > 0){
            if(System.isFuture() || System.isBatch() || System.isQueueable()){
                OpportunityTriggerHandler.updateRelatedObject(new Set<Id>(), oppIdDealRegSet, Trigger.newMap.keySet(), null);
            }
            else{
                OpportunityTriggerHandler.FutureUpdateRelatedObj(new Set<Id>(), oppIdDealRegSet, Trigger.newMap.keySet(), null);
            }
        }
        // Altify
        //oppHdlr.OpportunityPlanOppSyncTrigger(newOppList, null);        
    }    
    
    
    /************************************** Opportunity BEFORE UPDATE *************************************
* Description : 1. Replacement of UpdatereportingFields trigger 
2. Replacement of QuBy_OpportunityTrigger_BFR trigger  
3.This trigger populates the Book Date fields on the Opportunity.These fields are used in OCR extraction.
4. Convert currencyother than USD to USD
5. logic to set EDSD as per first schedule
6.update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data.
7.populate standard forecast category field from custom forecast category field-Nagendra
8. Opportunity can not be marked to closed until all demo requests are closed - EBA_SF-1538 - Varsha - changed on 12th Nov 2021
9. Parameters are changed in validateOportunity from oppHdlr.validateOportunity(nonCpqOppsList,oldMapOpportunity); to oppHdlr.validateOportunity(nonCpqOppsList, (Map<Id,Opportunity>)Trigger.oldMap); for the story EBA_SF-1660 - Varsha - Changed on 29th Nov 2021
*************************************************************************************************/
    public override void beforeUpdate() {
        
        oppHdlr = (oppHdlr != null) ? oppHdlr : new OpportunityTriggerHandler();
        ////@changed CPQ
        List <Opportunity> nonCpqOppsList=oppHdlr.fltrOutCPQ((List<Opportunity>) Trigger.new);
        List <Opportunity> CATMOppsList=oppHdlr.fltrOutNonCATM((List<Opportunity>) Trigger.new);
        
        List <Opportunity> nonCpqCATMOppsList = new  List<Opportunity>(nonCpqOppsList);
        nonCpqCATMOppsList.addAll(CATMOppsList);
        //CATM changes
        OpportunityTriggerHandler.updateCATMProductRollup(new Map<Id, Opportunity>(CATMOppsList), true);
        /********************************************************
* GET OLD RECORD MAP FOR INCOMING RECORDS
********************************************************/
        //Cpq Change        
        if(CheckRecursive.cpqSpclHdlg){            
            for (Opportunity opp: (List<Opportunity>)Trigger.new) { 
                //handling Forecast Category for Stage changes from Sync.
                if(opp.ForecastCategoryName!=null && opp.ForecastCategoryName!=((Opportunity)Trigger.oldMap.get(opp.Id)).ForecastCategoryName){
                    opp.Forecast_Category__c=opp.ForecastCategoryName; 
                }
            } 
		    oppHdlr.PopulateOCRBookDateFields_InsertOrUpdate((List<Opportunity>) Trigger.new);                     
            return;
        } else{
            for (Opportunity opp: (List<Opportunity>)Trigger.new) {
                opp.Skip_Validation_Rule_for_Lead_Conversion__c = false;
                //For EDD handling of CPQ opps with out primary Quote.
                if((opp.CPQ__c && opp.SBQQ__PrimaryQuote__c==null)) { 
                    opp.Expected_Delivery_Date__c=opp.CloseDate.addMonths(1); 
                }
            } 
        }
        Map < Id, sObject > oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet());
        Map < Id, Opportunity > oldMapOpportunity = new Map < Id, Opportunity > ();
        Map < Id, Opportunity > newMapOpportunity = new Map < Id, Opportunity > ();
        Map < Id, Opportunity > newMapMNonCpqOpp = new Map < Id, Opportunity > ();
        for (Id OppId: oldBeoreUpdateMap.keyset()) {
            oldMapOpportunity.put(OppId, (Opportunity) oldBeoreUpdateMap.get(OppId));
        }
        Boolean hndlFrcst=false;
        Boolean needCurrConv=false;
        List<Opportunity> updatedOrgCodeOpps = new List<Opportunity>(); 
        List<Opportunity> updOrgCodeNonCDMOpps = new List<Opportunity>(); 
        Map<Id, Opportunity> oliTypeUpdOppMap = new Map<Id, Opportunity>();
        List<Opportunity> updateChnlOffOpps = new List<Opportunity>();
       
        /**Ajay---EBA_SF-1290---**/
        Set<id> pmntsOpp=new set<id>();
        /*****EBA_SF-1538 Start Initialization of list****/
        List<Opportunity> clsdNonCPQOpp = new List<Opportunity>();//list to store if a non-cpq opportunity stage is changed from open to closed
        /*****EBA_SF-1538 End Initialization of list****/
        for(Opportunity obj: (List<Opportunity>) Trigger.new) {
            newMapOpportunity.put(obj.Id,obj);
            
            if(!obj.CATM_Record__c) {
            /**Ajay---EBA_SF-1278---**/
            if(hndlFrcst==false && obj.Industry__c == 'Retail' && obj.Forecast_Category__c == 'Commit' && obj.Forecast_Category__c != oldMapOpportunity.get(obj.Id).Forecast_Category__c)
                hndlFrcst=true;
            if(!obj.CPQ__c){
                newMapMNonCpqOpp.put(obj.Id,obj); 
                /*****EBA_SF-1538 entry condition start****/
                if(Obj.isclosed && !(oldMapOpportunity.get(obj.Id).IsClosed)){
                    clsdNonCPQOpp.add(obj);
                }
                /*****EBA_SF-1538 entry condition end****/
            }           
               
            
            System.debug('>>OLI Type Update' + obj.IsOppLineItemTypeUpdate__c);
            if (obj.IsOppLineItemTypeUpdate__c != oldMapOpportunity.get(obj.Id).IsOppLineItemTypeUpdate__c  && obj.IsOppLineItemTypeUpdate__c) {
                obj.IsOppLineItemTypeUpdate__c = false;
                if(obj.CPQ__c == false) {
                    oliTypeUpdOppMap.put(obj.Id, obj);
                } 
            }
            
            if(obj.CPQ__c && obj.Channel_Office__c != null && ((obj.Channel_Office__c != oldMapOpportunity.get(obj.Id).Channel_Office__c)
                                                               || (obj.CPQ__c != oldMapOpportunity.get(obj.Id).CPQ__c) ||  (obj.AccountId != oldMapOpportunity.get(obj.Id).AccountId))) {
                                                                   updateChnlOffOpps.add(obj);   
                                                               }
            }
            
            if(obj.Org_Code_Diff__c == true) {
                updatedOrgCodeOpps.add(obj);            
            } else if(obj.AccountId != oldMapOpportunity.get(obj.Id).AccountId) {
                updOrgCodeNonCDMOpps.add(obj);    
            }
            
            if (obj.CPQ__c != oldMapOpportunity.get(obj.Id).CPQ__c) {
                obj.Pricebook2Id =  obj.CPQ__c ? GlobalVariable.CPQPricebookId : GlobalVariable.PricebookId;      
            }
            if(!needCurrConv && String.IsNotBlank(obj.CurrencyIsoCode) && (obj.CurrencyIsoCode != 'USD'))
                needCurrConv=true;
        }
        // Add any Lead Conversion specific logic here     
        oppHdlr.handleLeadConversion_BeforeUpdate((List<Opportunity>) Trigger.new);
        
        //validate channel local office selected for CPQ Opp
        if(!updateChnlOffOpps.isEmpty()) {
            oppHdlr.valdChnlLclOffc(updateChnlOffOpps);
        }
        
        if(!oliTypeUpdOppMap.isEmpty()) {
            oppHdlr.valOppForMxdServOff(oliTypeUpdOppMap, false); //add nonCpqOppsList check
        }
        
        // Update reporting fields 
        // /**Ajay---EBA_SF-1278---**/
        if(!CPQTriggerControl.cpqSpclHdlgNew)
            oppHdlr.UpdateReportingFields_BeforeUpdate((List<Opportunity>) Trigger.new, oldMapOpportunity);
        
        //populateOppASolution - Reid suggested changes
        ////@changed CPQ
        /**Ajay---EBA_SF-1290--ADDED LOGIC TO POPULATE SET FOR NON-CPQ PAyments Rep related Opp-**/
        if(nonCpqOppsList.Size()>0)
            oppHdlr.populateOppASolution(nonCpqOppsList, oldMapOpportunity, newMapOpportunity,pmntsOpp);
        
        //Quote Validation on Opportunity
        ////@changed CPQ
        OpportunityTriggerHandlerHelper OppTriggerHelper = new OpportunityTriggerHandlerHelper();
        if(nonCpqOppsList.Size()>0 && OppTriggerHelper.hasPermission()){
            oppHdlr.QouteValidationOnOpportunityClose_BeforeUpdate(nonCpqOppsList, oldMapOpportunity);
        }
        
        //Validate Forecast Categary for reatil Industry 
        // if(!Test.isRunningTest())
        // /**Ajay---EBA_SF-1278---**/
        if(hndlFrcst)
            oppHdlr.handleUpdateForecastCategory((List<Opportunity>) Trigger.new, Trigger.NewMap.keySet(), oldMapOpportunity);
        
        //Populate OCR date fields        
      //Changes done by Yogesh related to EBA_SF-1381       
        //oppHdlr.PopulateOCRBookDateFields_Update((List<Opportunity>) Trigger.new, oldMapOpportunity);
         oppHdlr.PopulateOCRBookDateFields_InsertOrUpdate((List<Opportunity>) Trigger.new);   
        //End changes -Yogesh EBA_SF-1381
        //Currency Conversion
        //Ajay--EBA_SF-1352--**/
        if(needCurrConv)
            oppHdlr.CurrencyIsoConversion((List<Opportunity>) Trigger.new);
        
        //Set Expected Dilevary Start Date 
        if(nonCpqCATMOppsList.Size()>0 && OpportunityTriggerHandler.isTrue) {
            OpportunityTriggerHandler.isTrue=false;
            oppHdlr.UpdateEDDtoEBD_BeforeUpdate(nonCpqCATMOppsList, newMapMNonCpqOpp);
        }
        
        
        //Populate Sales Org lookup from CDM Sales Org Code
        if(!updatedOrgCodeOpps.isEmpty()) {
            oppHdlr.populateSalesOrgLookup(updatedOrgCodeOpps);
        }
        if(!updOrgCodeNonCDMOpps.isEmpty()) {
            oppHdlr.populateNonCDMSalesOrgLookup(updOrgCodeNonCDMOpps);    
        }
        
        //update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data.
        ////Ajay--EBA_SF-1352--Added Logic to avoid recurrence****/
        ////--------------------------OCR_TEAM__c Object Deletion EBA_SF-1720---------------------------------------

      //  if(CheckRecursive.runOnce())
       //     oppHdlr.PopulateOcrTeamAndContactRole((List<Opportunity>) Trigger.new);
        
        //populate standard forecast category field from custom forecast category field-Nagendra
        //System.debug('Inside before update'+CheckRecursive.runValiateOppTrigger());
        if(CheckRecursive.runValiateOppTrigger()) {
            oppHdlr.PopulateForecastCategory_BeforeUpdate((List<Opportunity>) Trigger.new,oldMapOpportunity);
            if(nonCpqOppsList.Size()>0)
                oppHdlr.validateOportunity(nonCpqOppsList, (Map<Id,Opportunity>)Trigger.oldMap);// changes done for EBA_SF-1660
        }else{
            if(nonCpqOppsList.Size()>0)
                oppHdlr.validateOportunityAmount(nonCpqOppsList, oldMapOpportunity);
        }
        //(EBA_SF-1184)
        ///**Ajay---EBA_SF-1290---EVALUATES NON-CPQ only payments rep**/
        oppHdlr.autoPopPaymntRep(nonCpqOppsList, pmntsOpp);
       // oppHdlr.validateOppSchForOpportunity(newMapOpportunity,oldMapOpportunity);
        /*****EBA_SF-1538 logic calling start****/
        if(!clsdNonCPQOpp.isEmpty()&&Label.Demo_Req_Val_Stop=='F'){
            oppHdlr.prvntClosingofOpp(clsdNonCPQOpp);
        }
        /*****EBA_SF-1538 logic calling end****/
    }
    /************************************** Opportunity AFTER UPDATE *************************************
* Description : 1. Delete all the tasks whenever any opportunity is closed.. 

2.Delete all the Past Due Date Tasks when the Close date of any Opportunity is extended.

3. Delete the Pipeline depending on the criteria. Make sure that only one Task remains for a
particular Subject.
4 .updates the opportunity team members whenever any opportunity
is converted from 'Exclude in Funnel' to 'Include in funnel'                 
5.sends the email to the manager of group 'FIN MEA Saudi Arabia-Sales' whenever the Amount or selling stage or Expected book date of opportunity of the group 'FIN MEA Saudi Arabia-Sales' is updated.
6. This Trigger is use track changes in month & year of "Expected Delivery Start Date".
If Change Occure trigger reschedule all the toplines schedule forward.
7. Auto-populate Decision Maker Contact on Renewal Opportunity - Nagnedra
8.update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data
constructed based on the new mapping file for sales org code,insert/update opportunitycontactrole record based on Contact lookup on opporunity
escape the trigger while code run of deal Conversion
*************************************************************************************************/
    public override void afterUpdate() {
        oppHdlr = (oppHdlr != null) ? oppHdlr : new OpportunityTriggerHandler();
        ////@changed CPQ
        List <Opportunity> nonCpqOppsList=oppHdlr.fltrOutCPQ((List<Opportunity>) Trigger.new);
        List <Opportunity> CPQOppsList=oppHdlr.fltrOutNonCPQ((List<Opportunity>) Trigger.new);
        List <Opportunity> CATMOppsList=oppHdlr.fltrOutNonCATM((List<Opportunity>) Trigger.new);
        
        List <Opportunity> nonCpqCATMOppsList = new  List<Opportunity>(nonCpqOppsList);
        nonCpqCATMOppsList.addAll(CATMOppsList);
        
        if(CheckRecursive.cpqSpclHdlg){
            return;
        }
        /********************************************************
* GET OLD RECORD MAP FOR INCOMING RECORDS
********************************************************/
        List<Opportunity> newOppList = new List<Opportunity>();
        newOppList =   (List<Opportunity>) Trigger.new; 
        
        List<Opportunity> oldOppLst = new List<Opportunity>();
        oldOppLst =  (List<Opportunity>) Trigger.old;
        
        Map< Id, Opportunity> mapNewOpportunity =new  Map< Id, Opportunity>();
        Map<Id, Opportunity> changedOppTypeMap = new  Map<Id, Opportunity>();
        Set<ID> oppIDSet = new Set<ID>();  //EBA_SF-1262
        Set<ID> oppIdDealRegSet = new Set<ID>();  //EBA_SF-1261
        List<Opportunity> oppLst = new List<Opportunity>();
        /************* Moved code from bottom to top to improve performance***************/
        //Ajay--EBA_SF-1352--**/
        Map < Id, sObject > oldBeoreUpdateMap = this.getOldBeforeUpdateMap(Trigger.newMap.keySet());
        
        Map < Id, sObject > recOldMap = this.getOldAfterUpdateMap(Trigger.newMap.keySet());
        //system.debug('oldBeoreUpdateMap'+oldBeoreUpdateMap);
        //system.debug('recOldMap'+recOldMap);
        Map < Id, Opportunity > oldMapOpportunity = new Map < Id, Opportunity > ();
        
        for (Id OppId: recOldMap.keyset()) {
            oldMapOpportunity.put(OppId, (Opportunity) recOldMap.get(OppId));
        }
        /*******************/
        Map<Id,Id> delAltOppMap = new Map<Id,Id>();
        Set<Id> atfyOppIds = new Set<Id>();        
        
        for(Opportunity opp: newOppList) {
            mapNewOpportunity.put(opp.id,opp);
            
            if(!opp.CATM_Record__c) {
            Opportunity oldOpp = (Opportunity)Trigger.oldMap.get(opp.id);
            //Yogesh - Altify Changes
            if(opp.RecordTypeId != oldOpp.RecordTypeId || opp.stageName != oldOpp.stageName || opp.CloseDate != oldOpp.CloseDate ){
                atfyOppIds.add(opp.Id);
            }
            
            if(opp.AccountId != oldOpp.AccountId) {
                atfyOppIds.add(opp.Id);
                delAltOppMap.put(opp.Id, oldOpp.AccountId);    
            }
            //End Altify Changes 
            if(opp.Type != oldOpp.Type && opp.CPQ__c == false && oldOpp.Type == 'Existing Customer - Mixed Service Offerings') {
                changedOppTypeMap.put(opp.Id, opp);
            }
            //monika EBA_SF-1262
            if((opp.Amount != oldOpp.Amount) && opp.Amount != NULL){   //check if Amount On Opportunity is changed
                oppIDSet.add(opp.Id);
                
            }
            //abhishek EBA_SF-1261
            if(opp.Linked_Special_Bid_Registration__c != NULL){ 
                oppIdDealRegSet.add(opp.Id);                          
            }
            if(opp.Contacts__c != null && opp.Contacts__c != oldMapOpportunity.get(opp.Id).Contacts__c) {
                oppLst.add(opp);
            }
            }
        }
        
        if(CheckRecursive.runOppRelatedObject()){
            if(!oppIDSet.isEmpty() || !oppIdDealRegSet.isEmpty() || !atfyOppIds.isEmpty()){ 
                if(System.isFuture() || System.isBatch() || System.isQueueable()){
                    OpportunityTriggerHandler.updateRelatedObject(oppIDSet, oppIdDealRegSet, atfyOppIds, delAltOppMap);
                }
                else{
                    OpportunityTriggerHandler.FutureUpdateRelatedObj(oppIDSet, oppIdDealRegSet,atfyOppIds, delAltOppMap);
                }
            }
        }
        
        if(!changedOppTypeMap.isEmpty()) {
            oppHdlr.valOppForMxdServOff(changedOppTypeMap, true);      
        }
          
        
        /**Ajay---EBA_SF-1278---**/
        if (!CPQTriggerControl.cpqSpclHdlgNew && CheckRecursive.runValiateOppTrigger()) {
            Set < Id > closedOppIDs = new Set < Id > ();
            Set < Id > pastDueOppIDs = new Set < Id > ();
            Set < Id > deleteAllIds = new Set < Id > ();
            Set < Id > keepLatestIds = new Set < Id > ();
            try {
                for (Integer i = 0; i < Trigger.new.size(); i++) {
                    
                    if(!newOppList[i].CATM_Record__c ) {  // added changes to filter out Non-CATM Opp List
                    if (newOppList[i].Isclosed == true) {
                        if (oldOppLst[i].Isclosed == false) {
                            closedOppIDs.add(Trigger.new[i].Id);
                        }
                    }
                    if (newOppList[i].CloseDate > oldOppLst[i].CloseDate) {
                        if (newOppList[i].isclosed != true) {
                            pastDueOppIDs.add(newOppList[i].Id);
                        }
                    }
                    if (oldOppLst[i].ForecastCategoryName == 'Pipeline' && (oldOppLst[i].StageName == 'Offering' || oldOppLst[i].StageName == 'Validating' || oldOppLst[i].StageName == 'Analyzing') /*&& Trigger.old[i].Solution_Portfolio__c != 'IPS' - -P360 Initial Change - Ahad*/ && oldOppLst[i].Expected_Delivery_Date__c < System.today() + 120) {
                        if (newOppList[i].ForecastCategoryName == 'Pipeline' && (newOppList[i].StageName == 'Offering' || newOppList[i].StageName == 'Validating' || newOppList[i].StageName == 'Analyzing') /*&& Trigger.old[i].Solution_Portfolio__c != 'IPS' - -P360 Initial Change - Ahad*/ && newOppList[i].Expected_Delivery_Date__c < System.today() + 120) {
                            keepLatestIds.add(newOppList[i].Id);
                        } else {
                            deleteAllIds.add(newOppList[i].Id);
                        }
                    }
                }
            }
            }
            Catch(Exception e){
                System.debug('Exception'+e.getMessage()); 
            }
            
            //Delete task 
            //if(!Test.isRunningTest())
            oppHdlr.DeleteTask(closedOppIDs, pastDueOppIDs, deleteAllIds, keepLatestIds);
            
        }
        //update teammember
        ///**Ajay---EBA_SF-1278---** This logic runs on RecordType Chang so shouldnt be working for CPQ Quote sync, although no SOQL improvement but helps performance/
        if(!CPQTriggerControl.cpqSpclHdlgNew)
            oppHdlr.updateOpportunityTeamMember((List<Opportunity>) Trigger.new, (List<Opportunity>) Trigger.old);
        
        //Send email to manager of group 'FIN MEA Saudi Arabia-Sales'
        /*if(CheckRecursive.runSendEmailToOppOwnerOnce()) {  
//oppHdlr.SendEmailtoOppOwnerManager((List<Opportunity>) Trigger.new,mapNewOpportunity, oldMapOpportunity);
}*/
        //PS_ChangeSchedule trigger
        if(nonCpqCATMOppsList.size()>0)
            oppHdlr.PS_ChangeSchedule(nonCpqCATMOppsList,oldMapOpportunity);
        
        
        
        //insert/update opportunitycontactrole record based on Contact lookup on opporunity
        //IF(newOppList[0].Is_Channel_Opportunity__c == false){ = comenting to removing is_channel_opportunity__c
        /*List<Opportunity> oppLst = new List<Opportunity>();

for(Opportunity opp : newOppList) {
if(opp.Contacts__c != null && opp.Contacts__c != oldMapOpportunity.get(opp.Id).Contacts__c) {
oppLst.add(opp);
}
}*/
        if(!oppLst.isEmpty()){
            try {
                HelperOpportunity.updateContactRoleFromOpportunity(oppLst);
            } catch(Exception e) {
                newOppList[0].addError('Error:' + e.getMessage());
            }  
        }
        
        //}
        if(CheckRecursive.usmOutBoundCallRunCheck() && nonCpqOppsList.size()>0) {
            system.debug('@@@@');
            /****************************************************************************************************************
* Author        :   Ajay Dixit 
* Description   :   This trigger sends opportunity updates to USM when Usm Opp No. is not blank and updates are not done by users specified as system.
****************************************************************************************************************/
            if((UserInfo.getName().toUpperCase().contains('SOUP') && !System.isBatch()) || !NSCCommonInfoUtil.getInstance().getSystemUsers().contains(UserInfo.getUserId())){
                oppHdlr.synchToDownStream(nonCpqOppsList, (Map<Id, Opportunity>) Trigger.oldMap);
                
            }
            
        }
        
        oppHdlr.processPrimaryQuotes(CPQOppsList, oldMapOpportunity);
        // Added by Dharmendra Story#SFCPQ-1173
        System.enqueueJob(new CPQOppToQuoteSync(CPQOppsList, oldMapOpportunity));
    }
    /************************************** Opportunity BEFORE DELETE *************************************
* Description : 
1. Replacement of QuBy_OpportunityTrigger_BFR trigger  Delete logic

*************************************************************************************************/
    public override void beforeDelete() {
        oppHdlr = (oppHdlr != null) ? oppHdlr : new OpportunityTriggerHandler();
        
        set<id> OppId = new set<id>();
        for( Opportunity o: (List<Opportunity>) trigger.old ){
            if(!o.CATM_Record__c) { // added changes to filter out Non-CATM Opportunities
            OppId.add( o.id );
        }
        }
        if( OppId != null && OppId.size() > 0 ){
            oppHdlr.OnDeleteOpp_UpdateQuBy(OppId,(List<Opportunity>) trigger.old );
        }
    }
}