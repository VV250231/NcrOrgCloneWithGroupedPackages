/*************************************************************************************************
* Author        :   Ajay Dixit   
* Date          :   24-12-2020
* Param         :   Opportunity List:  List of new Opps
* Return        :   
* Description   :   Filters out records which are CPQ
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-2058     05-30-2022		Puneet Bhatia      Added changes to bypass Cardtronics Opportunity Records in Apex
Story No#       Date            DevName            Description
DI Demo Project 10-10-2022		Monika             Code related to DI Demo uncommented
*************************************************************************************************/
public with sharing class OpportunityTriggerHandler {
    public static  boolean isTrue = true;
    public static boolean isConversion =false;
    
    public List < Opportunity > fltrOutCPQ(List < Opportunity > opps) {     
        List < Opportunity > fltrLst = new List < Opportunity > ();
        for (Opportunity opp: opps) {
            if (!opp.Cpq__c && !opp.CATM_Record__c) fltrLst.add(opp);
        }
        return fltrLst;
    }
    
    public List < Opportunity > fltrOutNonCPQ(List < Opportunity > opps) {     
        List < Opportunity > fltrLst = new List <Opportunity> ();
        for (Opportunity opp: opps) {
            if (opp.Cpq__c && !opp.CATM_Record__c) fltrLst.add(opp);
        }
        return fltrLst;
    }
    
    
    public List < Opportunity > fltrOutNonCATM(List < Opportunity > opps) {     
        List < Opportunity > fltrLst = new List <Opportunity> ();
        for (Opportunity opp: opps) {
            if (opp.CATM_Record__c) fltrLst.add(opp);
        }
        return fltrLst;
    }
    /*************************************************************************************************
* Author        :   Puneet Bhatia  
* Description   :   Update Reporting fields parts of UpdateReportingFields triggers
*************************************************************************************************/    
 
    public void populateSalesOrgLookup(List<Opportunity> oppLst) { // populate SaleasOrgLookup before CDM Opportunities
        Map<String, Sales_Org__c> slsOrgMap = new Map<String, Sales_Org__c>();         
        Set<String> accGSOSet = new Set<String>();
        List<Opportunity> nonCDMOrgOpps = new List<Opportunity>();
        
        for (Opportunity opp : oppLst) {
            if(opp.Org_Code_Diff__c != NULL && opp.Org_Code_Diff__c) {
                if(String.isNotBlank(opp.Account_Global_Sales_Org_Code__c)) accGSOSet.add(opp.Account_Global_Sales_Org_Code__c);
            } else {
                nonCDMOrgOpps.add(opp);     
            }
        }
        
        if(!accGSOSet.isEmpty()) {
            // find Primary Sales Org Record
            for(Sales_Org__c so : [SELECT Id,Sales_Org_Code__c,Hierarchy_6__c FROM Sales_Org__c WHERE Sales_Org_Code__c IN :accGSOSet AND IsPrimary__c = true]) {
                slsOrgMap.put(so.Sales_Org_Code__c, so);   
                accGSOSet.remove(so.Sales_Org_Code__c);
            } 
            
            // find Non-Primary Sales Org Record, in case primary not found
            if(!accGSOSet.isEmpty()) {
                for(Sales_Org__c so : [SELECT Id,Sales_Org_Code__c, Hierarchy_6__c FROM Sales_Org__c WHERE Sales_Org_Code__c IN :accGSOSet]) {
                    slsOrgMap.put(so.Sales_Org_Code__c, so);   
                }  
            }
            
            for (Opportunity opp : oppLst) {    
                Sales_Org__c salesOrg = slsOrgMap.get(opp.Account_Global_Sales_Org_Code__c);        
                if(salesOrg != null) {
                    opp.Sales_Org__c = salesOrg.Id;
                    opp.OCR_TEAM__c =  salesOrg.Hierarchy_6__c;
                }else {
                    opp.Sales_Org__c = NULL;
                    opp.OCR_TEAM__c =  '';
                }
            }  
        }
        
        if(!nonCDMOrgOpps.isEmpty()) {
            populateNonCDMSalesOrgLookup(nonCDMOrgOpps);   
        }
    }
    
    public void populateNonCDMSalesOrgLookup(List<Opportunity> oppLst) {
        Map<Id, Id> OppAccIdmp = new Map<Id, Id>();
        
        for(Opportunity opp: oppLst) {
            OppAccIdmp.put(opp.Id, opp.AccountId);         
        }
        
        if(!OppAccIdmp.isEmpty()) {
            Map <String, Opportunity> accIdVsSlsOrgMap = new Map<String, Opportunity>();
            List <Account> accLst = [SELECT Id, (SELECT Id,Sales_Org__c, Sales_Org__r.Hierarchy_6__c,OCR_TEAM__c FROM Opportunities WHERE Id NOT IN :OppAccIdmp.keySet() AND Sales_Org__c != NULL LIMIT 1) from Account where Id IN :OppAccIdmp.values() and MDM_Data_Source_Code__c != 'CDM'];
            
            for (Account acc : accLst) {
                if(acc.Opportunities != null && acc.Opportunities.size() > 0) {    
                    accIdVsSlsOrgMap.put(acc.Id, acc.Opportunities[0]);  
                }
            }
            
            for (Opportunity opp: oppLst) {
                if (OppAccIdmp.containsKey(opp.Id) && accIdVsSlsOrgMap.containsKey(opp.AccountId)) {
                    Opportunity srcOpp = accIdVsSlsOrgMap.get(opp.AccountId);
                    opp.Sales_Org__c = srcOpp.Sales_Org__c;  
                    opp.OCR_TEAM__c = srcOpp.OCR_TEAM__c;
                }
            }
        }
    }
    
    
    public void handleLeadConversion_BeforeInsert(List<Opportunity> newOpp) {
        Boolean isLeadConvRng = !CheckRecursive.checkLeadConversionRun();
        
        if (isLeadConvRng) {
            for (Opportunity opp: newOpp) {
                isConversion =true;
                if(!opp.CATM_Record__c) opp.Secondary_Campaign__c=null;
                opp.Skip_Validation_Rule_for_Lead_Conversion__c = true;
            }
            SetOppSellingStage_BeforeInsert(newOpp);
        } else {
            for (Opportunity opp: newOpp) {
                if(!opp.CATM_Record__c) opp.Secondary_Campaign__c=null;
                opp.Skip_Validation_Rule_for_Lead_Conversion__c = false;
            }    
        }
    }
    
    
    public void handleLeadConversion_BeforeUpdate(List<Opportunity> newOpp) {
        Boolean isLeadConvRng = !CheckRecursive.checkLeadConversionRun();
        
        if (isLeadConvRng) {
            for (Opportunity opp: newOpp) {
                if(OpportunityTriggerHandler.isConversion==true)
                if(!opp.CATM_Record__c) opp.Secondary_Campaign__c=null;
                opp.Skip_Validation_Rule_for_Lead_Conversion__c = true;
            } 
        } else {
            for (Opportunity opp: newOpp) { 
                opp.Skip_Validation_Rule_for_Lead_Conversion__c = false;
            }    
        }
    }
    
    
    public void SetOppSellingStage_BeforeInsert(List<Opportunity> newOpp) {
        Map<String,Schema.RecordTypeInfo> rtInfoByName = Schema.SObjectType.Opportunity.getRecordTypeInfosByName();
        Set<Id> prtnRtTypeIds = new Set<Id>();
        
        prtnRtTypeIds.add(rtInfoByName.get('Indirect - Include in Funnel Reseller').getRecordTypeId());
        prtnRtTypeIds.add(rtInfoByName.get('Indirect - Include in Funnel Distributor').getRecordTypeId());
        
        for (Opportunity opp: newOpp) {
            if (prtnRtTypeIds.contains(opp.RecordTypeId)) {
                opp.StageName = 'Analyzing';
                opp.ForecastCategoryName = 'Pipeline';
            } 
        }  
    }
    
    /****************************************************************************************************************
* Author      :  Vivek Kumar
* Description :  Show error if a user is updating Forecast Category to "Commit" with Industry = "Retail" if
one of the 8 fields at the top of the ValuePrompter tab on an opportunity is not equal to "Yes"
*********************************************Start Here*******************************************************/ 
    public void handleUpdateForecastCategory(List<Opportunity> oppLst, Set<Id> oppIdset, Map<Id, Opportunity> oldMap){
        
        Id includeInFunnelRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();
        Id distributterRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indirect - Include in Funnel Distributor').getRecordTypeId();
        Id resellerRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indirect - Include in Funnel Reseller').getRecordTypeId();
        Set<Id> inFnlRecTypIdSet = new Set<Id>();
        
        inFnlRecTypIdSet.add(includeInFunnelRecTypeId);
        inFnlRecTypIdSet.add(distributterRecTypeId);
        inFnlRecTypIdSet.add(resellerRecTypeId);
        
        Map<Id, Value_Prompter__c> oppIdToValuePromptMap = new Map<Id, Value_Prompter__c>();
        List<Value_Prompter__c> valuePrompterList = [Select Id, Has_the_Business_Value_been_quantified__c, Do_prospect_agreed_potential_buss_value__c, Has_Plan_confirmed_with_customer__c, Access_to_the_Power_Person__c, Have_we_developed_an_eVP__c, Are_Top_Risk_Identify_if_they_Occur_CMR__c, Can_it_be_related_to_Revenue_or_Profit__c, Is_prospect_req_any_unique_or_diff_sol__c, Opportunity__c FROM Value_Prompter__c WHERE Opportunity__c IN : oppIdset];
        for(Value_Prompter__c vpObj : valuePrompterList){
            oppIdToValuePromptMap.put(vpObj.opportunity__c, vpObj);
        }
        
        for(Opportunity opp : oppLst){
            if(!opp.CATM_Record__c && inFnlRecTypIdSet.contains(opp.recordTypeId) && opp.Industry__c == 'Retail' && opp.Forecast_Category__c == 'Commit' && opp.Forecast_Category__c != oldMap.get(opp.Id).Forecast_Category__c){
                
                Value_Prompter__c obj = (oppIdToValuePromptMap.get(opp.Id) != null ? oppIdToValuePromptMap.get(opp.Id) : null);
                if(obj != null && obj.Has_the_Business_Value_been_quantified__c == false && obj.Do_prospect_agreed_potential_buss_value__c == false && obj.Has_Plan_confirmed_with_customer__c == false && obj.Access_to_the_Power_Person__c == false && obj.Have_we_developed_an_eVP__c == false && obj.Are_Top_Risk_Identify_if_they_Occur_CMR__c == false && obj.Can_it_be_related_to_Revenue_or_Profit__c == false && obj.Is_prospect_req_any_unique_or_diff_sol__c == false){
                    opp.Forecast_Category__c.addError(system.label.OppTrgHndlr1); // You cannot commit this opportunity unless at least one question on the ValuePrompter tab is equal to yes.
                }
                else if(obj == null){opp.Forecast_Category__c.addError(system.label.OppTrgHndlr1); } //You cannot commit this opportunity unless at least one question on the ValuePrompter tab is equal to yes.
            } 
        }
    }
    /*****************************************End Here*************************************************************/
    //For Update Commitment Risk To None While Cloning Opportunity
    public void updateCommitmentRiskForCloneOpportunity(List<Opportunity> oppLst){
        for(Opportunity opp : oppLst){
        	opp.Commitment_Risk__c = (opp.IsClone__c != null ? 'None' : opp.Commitment_Risk__c);
        }
    }
    
    //Update Reporting fields parts of UpdateReportingFields triggers
    public void UpdateReportingFields_BeforeInsert(List<Opportunity> newOpp){
        
        for (Opportunity opp: newOpp) {
            opp.OwnerAssignedDate__c  = Datetime.now();
            opp.Use_SF_Probability__c = 'YES';
            //opp.CampaignId=null;
            if(opp.CPQ__c && opp.isCloneWithProduct__c) opp.isCloneWithProduct__c = false;
            opp.Pricebook2Id =  opp.CPQ__c ? GlobalVariable.CPQPricebookId : GlobalVariable.PricebookId;        
        } 
        
        //OpportunityTriggerHandlerHelper.UpdateReportingFieldsInsertAndbeforeUpdate(newOpp); 
    }
    //Update Reporting fields parts of UpdateReportingFields triggers
    public void UpdateReportingFields_BeforeUpdate(List<Opportunity> newOpp, map<id,Opportunity> oldMapOpp){
        
        for (Opportunity opp: newOpp) {
            Opportunity oldOpp = oldMapOpp.get(opp.Id);
            
            if(opp.OwnerId != oldOpp.OwnerId) {
                opp.OwnerAssignedDate__c  = Datetime.now();    
            }
            
            //System.debug('current probability' + opp.Probability);
            
            //System.debug('old probability' + oldOpp.Probability);
            if(opp.StageName != oldOpp.StageName && opp.Use_SF_Probability__c != 'YES') {
                if((opp.cat_0_score_oppscore__c == null) || (opp.cat_0_score_oppscore__c <= 0) || (opp.Probability == oldOpp.Probability) || (((opp.Probability - oldOpp.Probability) > 0) && (Math.max(opp.Probability,opp.cat_0_score_oppscore__c*100) <= opp.Probability)) || (((opp.Probability - oldOpp.Probability) < 0) && (Math.min(opp.Probability,opp.cat_0_score_oppscore__c*100) >= opp.Probability))) {
                    
                    
                    opp.Use_SF_Probability__c = 'YES';
                }
            }
        }
        //Update Reporting fields parts of UpdateReportingFields triggers
        //OpportunityTriggerHandlerHelper.UpdateReportingFieldsInsertAndbeforeUpdate(newOpp); 
    }
    /*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: deleteTasks.trigger                                                        
# Version.....................: 21.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 16-07-2011                                                                                
# Last Modified by......: Darshan Singh Farswan
# Description...............: Currently we are having more than one trigger for deleting Tasks related to Opportunities. This trigger
#                                       combines all the functionalities. It deletes tasks based on following criterion.
#                                       1. Delete all the tasks whenever any opportunity is closed.
#                                       2. Delete all the Past Due Date Tasks when the Close date of any Opportunity is extended.
#                                       3. Delete the Pipeline depending on the criteria. Make sure that only one Task remains for a
#                                            particular Subject.
################################################################################################
*/
    public void DeleteTask(Set<Id> closedOppIDs,Set<Id> pastDueOppIDs, Set<Id> deleteAllIds, Set<Id> keepLatestIds){
        try{
            
            if(closedOppIDs!=null && closedOppIDs.size()>0)
            {
                List<Task>Tasks = [Select Id,whatID From Task Where IsClosed = false And Subject LIKE 'Action Required:%' AND whatID in :closedOppIDs];
                if(Tasks !=null){
                    database.delete(Tasks);
                }
            }
            if(pastDueOppIDs!= null && pastDueOppIDs.size()>0){
                List<task> tasks = [Select Id from Task where WhatId in :pastDueOppIDs And Subject = 'Action Required: Past Due Opportunity'];
                if(tasks != null && tasks.size()>0){
                    delete (tasks);
                }
            }
            if(deleteAllIds != null && deleteAllIds.size()>0){ 
                List<task> deletealltasks = [Select Id,whatId from Task where WhatId in :deleteAllIds And Subject = 'Action Required: Pipeline Opportunity Expected Delivery'];
                if(deletealltasks != null && deletealltasks .size()>0){
                    delete (deletealltasks );
                }
            }
            if(keepLatestIds != null && keepLatestIds.size()>0){ 
                List<Task> previousTasks = new List<Task>();
                List<Task> keepLatestTask= [Select Id, whatId from Task where WhatId in :keepLatestIds And Subject = 'Action Required: Pipeline Opportunity Expected Delivery' order by whatId, ActivityDate];
                if(keepLatestTask!= null && keepLatestTask.size()>0){ 
                    for(Integer i=0;i<keepLatestTask.size()-1;i++){ 
                        if(keepLatestTask[i].whatId ==keepLatestTask[i+1].whatId){
                            previousTasks.add(keepLatestTask[i]); 
                        } 
                    }
                    delete previousTasks;
                }
            } 
        }catch(Exception e){
            System.debug('Exception Caught'+e.getMessage());
        }
    }
    /*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: populateOppASolution.trigger                                                        
# Created by................: Dev Admin                                                                   
# Created Date...........: 17-01-2016                                                                                
# Last Modified by......: Varsha Pal
# Description...............: 
# All @ Payments logic, HW/SW and NCR Payments No9 attached Reason Code validation, Nullifying fields, Populating Default Pricing for Payments
# Last Changes done.......: EBA_SF - 1147(Automatically set the POS field as NCR Aloha if Payment processing is added)                                 
################################################################################################
*/
    public void populateOppASolution(List<Opportunity> newOpp,Map<id,Opportunity> oldMapOpp,Map<id,Opportunity> newMapOpportunity, Set<id> pmntsOpp){
        //System.debug('All @ Payments logic, HW/SW and NCR Payments No9t attached Reason Code, Nullifying fields');
        //get Set of Payments Product
        Set<String> paymntPrfileSet = new Set<String>();
        Set<String> PmntsRelatedPrdSet=new Set<String>(); 
        Set<String> HWMSWMPrfileSet = new Set<String>();
        Boolean HWMSWMProfileAvailable = false;
        Set<String> ProductIdSet= new Set<String>();
        NCR_Payments_Processing__mdt pynmtProsPrds = new NCR_Payments_Processing__mdt();
        List<String> FieldApiList = new List<String>();
        //Fetch payments processing fee fields from metadata
        pynmtProsPrds =[select id,ProductId__c,FieldApi__c from NCR_Payments_Processing__mdt limit 1];  
        String currentProfileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name.toUpperCase();
        if(String.isNotBlank(pynmtProsPrds.Id)){
            if(pynmtProsPrds.ProductId__c != null && String.isNotBlank(pynmtProsPrds.ProductId__c)){
                for(String PId : pynmtProsPrds.ProductId__c.split(',')){
                    ProductIdSet.add(PId.trim().toUpperCase());
                }
            }
            if((pynmtProsPrds.FieldApi__c != null) && (String.isNotBlank(pynmtProsPrds.FieldApi__c))){
                FieldApiList.addAll(pynmtProsPrds.FieldApi__c.split(','));
            }
        }
        //No_Attach_Code_Profiles__c noAttchCodeProfiles = No_Attach_Code_Profiles__c.getValues('Record1');
        All_profie_config__c noAttchCodeProfiles = All_profie_config__c.getValues('No Attach Codes Profiles');
        String pymntReasonProfiles ;
        //String HWMSWMReasonProfiles ;
        Boolean allwAllPymntsPrfle = false;
        if(noAttchCodeProfiles!=null){
            //allwAllPymntsPrfle = noAttchCodeProfiles.Allow_All_Payment_Profiles__c;
            //pymntReasonProfiles = noAttchCodeProfiles.Included_Payments_Profile__c;
            allwAllPymntsPrfle = noAttchCodeProfiles.Allow_All_Profile__c;
            pymntReasonProfiles = noAttchCodeProfiles.Profile_Name__c;
            //HWMSWMReasonProfiles = noAttchCodeProfiles.Include_HWM_SWM_Profiles__c;
            
        }
        if(!allwAllPymntsPrfle && String.isNotBlank(pymntReasonProfiles)){
            for(String paymntPrfile : pymntReasonProfiles.split(',')){
                paymntPrfileSet.add(paymntPrfile.trim().toUpperCase());
                
            }
        }
        //System.debug('____paymntPrfileSet'+paymntPrfileSet+'___currentProfileName'+currentProfileName);
        if(allwAllPymntsPrfle || paymntPrfileSet.contains(currentProfileName)){
            //get Set of Payments related products
            Prod_Reason_Required__c paymentsProducts = Prod_Reason_Required__c.getValues('Payments Related');
            String paymentsRelatedProducts = paymentsProducts.Prod_Included__c;
            //System.debug('____'+paymentsRelatedProducts);
            Boolean isOn=paymentsProducts.On__c;
            if(isOn){
                for(String prdcts :paymentsRelatedProducts.split(',')){
                    //System.debug('____prdcts'+prdcts);
                    PmntsRelatedPrdSet.add(prdcts.trim().toUpperCase());
                }         
            }
        }
        /* EBA_SF-1147 logic starts from here - we are mapping POS field value which should automatically populated based on the product type
This is added in the custom metadata named Product POS Field Mapping
*/
        Map<String,String> prdctPOSMap = new Map<String,String>();
        Map<String, Product_POS_Field_Mapping__mdt> mapPrdct = Product_POS_Field_Mapping__mdt.getAll();
        if(CheckRecursive.setAutoPOSValue){
            for(String prd : mapPrdct.keySet()){
                if(mapPrdct.get(prd).Revenue_Type__c!= null && String.isNotBlank(mapPrdct.get(prd).Revenue_Type__c)){
                    for(String PId : mapPrdct.get(prd).Revenue_Type__c.split(',')){
                        prdctPOSMap.put(PId.trim().toUpperCase(),mapPrdct.get(prd).POS_Value__c+'-'+mapPrdct.get(prd).Allow_For_All_Profiles__c+'-'+mapPrdct.get(prd).Allow_Specific_Profiles__c.toUpperCase());
                    } 
                }
            }
        }
        
        // get list of Opportunity in trigger with OLI
        List <Opportunity> triggerOpps=[Select id,Pricing_Review_Request_Status__c, (Select id,Quantity,product2.Name,product2.Product_Category__c,product2.Service_Offer_Category__c, OpportunityId,TotalPrice  from OpportunityLineItems where IsPackageLine__c=true) FROM OPPORTUNITY Where Id in:newOpp]  ;
        //Initialize different set of Opps for different validations
        Set<Id> containsHWSW=new Set<Id>();
        Set<Id> containsHWM_SWM_TS=new Set<Id>();
        Set<Id> containsPaymentRelated=new Set<Id>();
        Map<Id, Decimal> pmntsRltOppWsiteCnt= new Map<Id,Decimal>();
        Boolean needsDefaultFee=false;
        /* EBA_SF-1147 logic variable assignment started*/
        Map<Id,String> contnsPOSPrdct=new Map<Id,String>(); //This Map will contain the opportunity id if a Product is added in which we need to set the POS field automatically 
        /* EBA_SF-1147 logic variable assignment end*/
        //populate Sets
        //
        //
        for(Opportunity opp:triggerOpps){   
            
            for(OpportunityLineItem oli:opp.OpportunityLineItems){
                if(oli.product2.Service_Offer_Category__c!=null && (oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW') ){
                    containsHWSW.add(opp.id); 
                }  
                
                if(oli.Product2.Service_Offer_Category__c!=null && ProductIdSet.contains(oli.Product2.Service_Offer_Category__c.toUpperCase())){
                    pmntsRltOppWsiteCnt.put(oli.OpportunityId,oli.Quantity); 
                    if(String.isBlank(opp.Pricing_Review_Request_Status__c)){
                        needsDefaultFee=true;  
                    }
                }
                if(oli.product2.Service_Offer_Category__c == 'HWM' || oli.product2.Service_Offer_Category__c == 'SWM' || oli.product2.Service_Offer_Category__c == 'TS' || oli.product2.Service_Offer_Category__c == 'PS'){
                    containsHWM_SWM_TS.add(opp.id);
                }
                //System.Debug('____PmntsRelatedPrdSet '+PmntsRelatedPrdSet);
                for(String prodName:PmntsRelatedPrdSet){
                    if(oli.product2.Name!=null &&oli.product2.Name.toUpperCase().contains(prodName)){
                        //System.Debug('____hereee');
                        containsPaymentRelated.add(opp.id);
                        if(oli.product2.Service_Offer_Category__c!=null && (oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW') ){
                            containsHWSW.add(opp.id); 
                        }
                        break;
                    }   
                }
                /* EBA_SF-1147 logic for fetching all the opportunity for which we need to set the POS field automatically */
                if(oli.product2.Service_Offer_Category__c!=null && prdctPOSMap.get(oli.Product2.Service_Offer_Category__c.toUpperCase())!=null){
                    contnsPOSPrdct.put(opp.id,oli.Product2.Service_Offer_Category__c.toUpperCase());
                }
            }
        }
        /**Ajay---EBA_SF-1290---**/        
        pmntsOpp.addAll(pmntsRltOppWsiteCnt.keySet());
        //populate default fee if needed
        Payment_Fees_Management__c PaymentFeeDefaultValueObj = new Payment_Fees_Management__c();
        if(needsDefaultFee){
            //Fetch Payments fee record for default fees                                             
            if(FieldApiList.size()>0 && ProductIdSet.size()>0){
                PaymentFeeDefaultValueObj = Database.query('Select ' +string.join(FieldApiList, ',') + ' from Payment_Fees_Management__c limit 1');
            } 
        }
        //Validate and Populate
        for(Opportunity opp : newOpp) {
            if(opp.Reasons_for_no_Payment_Processing__c!=null){
                if(opp.Reasons_for_no_Payment_Processing__c.contains('Existing Contract (WP/NMS)') || opp.Reasons_for_no_Payment_Processing__c.contains('Existing Contract (Other)')){
                    if(opp.Payments_Contract_End_Date__c==null){
                        opp.Payments_Contract_End_Date__c.addError(system.label.OppTrgHndlr5);  //Contract End Date is Required 
                    }
                    
                }
            }
            // validation on closing Opportunity
            
            if((opp.StageName == 'Closed/Booked')  && (newMapOpportunity.get(opp.id).StageName  != oldMapOpp.get(opp.id).StageName) ){
                //System.debug('____'+containsPaymentRelated+'___'+pmntsRltOppWsiteCnt);
                if( containsHWSW.contains(opp.id) && !(containsHWM_SWM_TS.contains(opp.id)) && opp.You_have_not_selected_any_TS_HWM_or_SW__c == null){
                    opp.You_have_not_selected_any_TS_HWM_or_SW__c.addError(system.label.OppTrgHndlr2); //You have not selected any HWM, SWM or TS. Please Provide Reasons . 
                } 
                if( containsPaymentRelated.contains(opp.id) && !(pmntsRltOppWsiteCnt.keySet().contains(opp.id)) && opp.Reasons_for_no_Payment_Processing__c == null){
                    opp.Reasons_for_no_Payment_Processing__c.addError(system.label.OppTrgHndlr3); // You have not selected any NCR Payment Processing. Please Provide Reasons.
                }
            }
            //POPULATE PRICING DEFAULT VALUES
            //Runs only when There is Payments product on Include In Funnel Opp and Pricing Review not started (blank) or changed to Pending (Pricing Requested) Or has been WithDrawn or Rejected
            if(opp.RecordTypeId=='012700000001PoZAAU' && (pmntsRltOppWsiteCnt.keySet().contains(opp.id))  && 
               (String.isBlank(opp.Pricing_Review_Request_Status__c) 
                //status changed from blank to pending
                || (String.isBlank(oldMapOpp.get(opp.id).Pricing_Review_Request_Status__c) && !String.isBlank(opp.Pricing_Review_Request_Status__c) && opp.Pricing_Review_Request_Status__c.toUpperCase()=='PENDING')
                //Status is Reject or Withdrawn so that they can re request after update
                //THIS CAUSED BUG SINCE PaymentFeeDefaultValueObj WAS NOT POPULATED FROM BELOW REASON
                //||(!String.isBlank(opp.Pricing_Review_Request_Status__c) && (opp.Pricing_Review_Request_Status__c.toUpperCase()=='REJECT' || opp.Pricing_Review_Request_Status__c.toUpperCase()=='WITHDRAWN'))
               )){
                   for(String fieldApi : pynmtProsPrds.FieldApi__c.split(',')){
                       opp.put(String.valueOf(fieldApi.trim()),PaymentFeeDefaultValueObj.get(fieldApi.trim()));
                   } 
                   //Populate site
                   opp.Total_Number_of_Sites__c= pmntsRltOppWsiteCnt.get(opp.id);                                                 
               }
            //Nullifying payments reason
            if(opp.Reasons_for_no_Payment_Processing__c!=null && (pmntsRltOppWsiteCnt.keySet().contains(opp.id) || !containsPaymentRelated.contains(opp.id))){
                opp.Reasons_for_no_Payment_Processing__c=null;
            }
            if(opp.Payments_Contract_End_Date__c!=null && (pmntsRltOppWsiteCnt.keySet().contains(opp.id) || !containsPaymentRelated.contains(opp.id))){
                opp.Payments_Contract_End_Date__c=null;
            }
            if(opp.Payments_Contract_End_Date__c!=null && (opp.Reasons_for_no_Payment_Processing__c!=null && !(opp.Reasons_for_no_Payment_Processing__c.contains('Existing Contract (WP/NMS)') || opp.Reasons_for_no_Payment_Processing__c.contains('Existing Contract (Other)'))) || (opp.Reasons_for_no_Payment_Processing__c==null)){
                opp.Payments_Contract_End_Date__c=null;
            }
            //Nullifying HW/SW Reason
            if(opp.You_have_not_selected_any_TS_HWM_or_SW__c!=null && (containsHWM_SWM_TS.contains(opp.id) || !containsHWSW.contains(opp.id))){
                opp.You_have_not_selected_any_TS_HWM_or_SW__c=null;
            }
            //Nullify NCR Payments Pricing Fields
            //Runs only when There is no Payments product (REMOVED) and Pricing Review not started (blank) or changed to Pending (Pricing Requested) Or has been WithDrawn or Rejected
            if((!pmntsRltOppWsiteCnt.keySet().contains(opp.id)) 
               && 
               (String.isBlank(opp.Pricing_Review_Request_Status__c) 
                //status changed from blank to pending
                || (String.isBlank(oldMapOpp.get(opp.id).Pricing_Review_Request_Status__c) && !String.isBlank(opp.Pricing_Review_Request_Status__c) && opp.Pricing_Review_Request_Status__c.toUpperCase()=='PENDING')
                //Status is Reject or Withdrawn so that they can re request after update: 
                //JP TEAM REQUESTED TO RETAIN PRICING OF REQUEST WAS WITHDRAWN OR REJECTED OR APPROVED. IN ALL CASES.
                //||(!String.isBlank(opp.Pricing_Review_Request_Status__c) && (opp.Pricing_Review_Request_Status__c.toUpperCase()=='REJECT' || opp.Pricing_Review_Request_Status__c.toUpperCase()=='WITHDRAWN'))
               )){
                   for(String fieldApi : pynmtProsPrds.FieldApi__c.split(',')){
                       opp.put(String.valueOf(fieldApi.trim()),null);
                   } 
                   //Populate site
                   opp.Total_Number_of_Sites__c= null; 
                   //Added by Yogesh
                   //opp.Payments_Rep__c =null;
                   // nullify other Payments related field
                   opp.POS__c=null;
                   opp.Total_Annual_Transactions__c=null;
                   opp.Total_Annual_Volume__c=null;
               }
            /* EBA_SF-1147 Setting the POS field automatically based on the given product type */ 
            if(contnsPOSPrdct.get(opp.id)!=null){
                String[] prfMap = prdctPOSMap?.get(contnsPOSPrdct?.get(opp.id))?.split('-');
                System.debug('prfMap'+prfMap);
                if(Boolean.valueof(prfMap[1])||prfMap[2]?.split(',')?.contains(currentProfileName)){
                    opp.POS__c = prfMap[0];
                }
            }
            
        }
        /*

//OLD Code

Map<Id, List<OpportunityLineItem>> lineItemsByOppId = new Map<Id, List<OpportunityLineItem>>();
List<OpportunityLineItem> ListOlis =new List<OpportunityLineItem>();
Boolean isValidForAttachReasonCode=false;
Boolean isValidForShowError=true;
Boolean PymtProdsAvailable=false;
Boolean PymtPrcssngProdsAvailable = true;
Boolean paymentProcessingAvl = false;
Boolean HWMSWMAvl = false;
Boolean noHWMSWMProdsReasonReq=false;
Boolean noPymtProdsReasonReq=false;

Set<String> ProductsIncluded = new Set<String>();
Set<String> HWSWExcludedPrd = new Set<String>();                                        

Boolean isProdAvailable = false;
for(Opportunity opp : newOpp) {
if(opp.StageName == 'Closed/Booked'){

for(Prod_Reason_Required__C rsnProdct:[select id,Name,On__c,Prod_Excluded__c,Prod_Included__c from Prod_Reason_Required__C]){
if(rsnProdct.Name == 'HWSW' && rsnProdct.On__c){
for(String prdcts :rsnProdct.Prod_Included__c.split(',')){
ProductsIncluded.add(prdcts.trim().toUpperCase());
} 

}

}


//collect line items into map
for(OpportunityLineItem oli : [Select id,product2.Name,product2.Product_Category__c,product2.Service_Offer_Category__c, OpportunityId,TotalPrice  from OpportunityLineItem where OpportunityId in :Trigger.new order by product2.name])
{

ListOlis.add(oli); 



if(lineItemsByOppId.containsKey(oli.OpportunityId)) {
lineItemsByOppId.get(oli.OpportunityId).add(oli);
}else{
lineItemsByOppId.put(oli.OpportunityId, new List<OpportunityLineItem>{ oli });
}

for(String prodName:ProductsIncluded){
if(oli.product2.Name!=null &&oli.product2.Name.toUpperCase().contains(prodName)){
isProdAvailable=true;               
}    
}
if(oli.product2.Service_Offer_Category__c =='Payments Processing'){
paymentProcessingAvl = true; 
}
if(oli.product2.Service_Offer_Category__c =='HWM' || oli.product2.Service_Offer_Category__c=='SWM' ){
HWMSWMAvl = true; 
}

if(isProdAvailable && oli.product2.Service_Offer_Category__c!=null && (oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW')){
noHWMSWMProdsReasonReq=true;  
noPymtProdsReasonReq=true; 
} 
if(isProdAvailable && oli.product2.Service_Offer_Category__c!=null && !(oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW')){
noPymtProdsReasonReq=true;               
}
if(oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW'){
noHWMSWMProdsReasonReq=true;               
}
}
System.debug('______isProdAvailable'+isProdAvailable+'_____noHWMSWMProdsReasonReq'+noHWMSWMProdsReasonReq+'_____noPymtProdsReasonReq'+noPymtProdsReasonReq);
if(paymentProcessingAvl){
noPymtProdsReasonReq = false;   
}
if(HWMSWMAvl){
noHWMSWMProdsReasonReq = false;   
}
}
}


/*if(ListOlis.Size() > 0){
for(OpportunityLineItem olis : ListOlis){
if(isValidForAttachReasonCode && HWSWExcludedPrd.contains(olis.product2.Service_Offer_Category__c.toUpperCase())){
isValidForShowError=false;
}
if(PymtProdsAvailable && PaymentExcludedPrd.contains(olis.product2.Service_Offer_Category__c.toUpperCase())){
PymtPrcssngProdsAvailable=false;
}
}
} 

System.Debug('______PymtProdsAvailable'+PymtProdsAvailable+'_____PymtPrcssngProdsAvailable'+PymtPrcssngProdsAvailable);

//update Opps in loop
for(Opportunity opp : newOpp) {
Boolean portfolioChanged = false;

if((opp.StageName == 'Closed/Booked') && oldMapOpp.get(opp.id).Reasons_for_no_Payment_Processing__c!=null){
if(oldMapOpp.get(opp.id).Reasons_for_no_Payment_Processing__c.contains('Existing Contract (WP/NMS)') || oldMapOpp.get(opp.id).Reasons_for_no_Payment_Processing__c.contains('Existing Contract (Other)')){
if(opp.Payments_Contract_End_Date__c==null && oldMapOpp.get(opp.id).Payments_Contract_End_Date__c==null){
opp.Payments_Contract_End_Date__c.addError('Contract End Date is Required');    
}

}
}

if((opp.StageName == 'Closed/Booked')  && (newMapOpportunity.get(opp.id).StageName  != oldMapOpp.get(opp.id).StageName) ){
if( noHWMSWMProdsReasonReq && opp.You_have_not_selected_any_TS_HWM_or_SW__c == null){
opp.You_have_not_selected_any_TS_HWM_or_SW__c.addError('You have not selected any HWM, SWM or TS. Please Provide Reasons'); 
} 
if(noPymtProdsReasonReq && opp.Reasons_for_no_Payment_Processing__c == null){
System.Debug('#######');
opp.Reasons_for_no_Payment_Processing__c.addError('You have not selected any NCR Payment Processing. Please Provide Reasons');
}
}


}*/
    }
    
    
    /*
##################################################################################################
# Project Name..........: NSC Sales Central                                                                        
# Method Name............................: autoPopPaymntRep(EBA_SF-1184)                                                    
# Created by................: Varsha Pal                                                                   
# Created Date...........: 20-04-2020                                                                                
# Last Modified by......: Varsha Pal AND /**Ajay---EBA_SF-1290---**
# Description...............: 
# this method will auto populate payments rep if payments processing is added in the product based on the Channel/local office field's team member
# Last Changes done.......:                        
################################################################################################
*/
    
    public void autoPopPaymntRep(List<Opportunity> newOpp, Set<Id> pmntsOpp){
        //List<Opportunity> oppWithPymnt = checkForNCRPymnt(newOpp);
        Map<Id,Id> offcOppMap = new Map<Id, Id>();// Channel/local office and opportunity Map
        for(Opportunity opp : newOpp) {
            if(pmntsOpp.contains(opp.Id)){
                if(opp.Payments_Rep__c==null){
                    offcOppMap.put(opp.Channel_Office__c, opp.Id);
                }else if(CheckRecursive.setAutoPOSValue){
                    offcOppMap.put(opp.Channel_Office__c, opp.Id);
                }
            }
            else{
                opp.Payments_Rep__c=null; 
            }
        }
        Map<Id,Id> oppPymntRepMap = new Map<Id, Id>();//Map of opportunity with Payment rep id(user id)
        if(!offcOppMap.isEmpty()){
            cpq_QteToOppSync c=new cpq_QteToOppSync();
            c.getChnlOffPmntsRep(offcOppMap, oppPymntRepMap); 
        } 
        for(Opportunity opp : newOpp) {
            if(oppPymntRepMap.get(opp.id)!=null){
                opp.Payments_Rep__c= oppPymntRepMap.get(opp.id);
            }
        }
        
    }
    
    /*
//# Last Modified by......: Monika
//# Last Modified Date..: 24-05-2021   
//# Description...............: EBA_SF-1258 This story is for optimizing the process builder for updating ticket requests related opportunities &
//, EBA_SF-1261 - This story is related to Deal Registration 
*/
    @future
    public static void FutureUpdateRelatedObj(Set<ID> oppIDSet, Set<Id> oppIdsDealRegSet, Set<Id> altfyOppIds, Map<Id, Id> delAltOppMap){
        updateRelatedObject(oppIDSet, oppIdsDealRegSet, altfyOppIds, delAltOppMap);
        
    }    
    public static void updateRelatedObject(Set<ID> oppIDSet, Set<Id> oppIdsDealRegSet, Set<Id> altfyOppIds, Map<Id, Id> delAltOppMap){
        
        List<Database.SaveResult> saveRes = new List<Database.SaveResult>();
        
        //abhishek EBA_SF-1261
        if(oppIdsDealRegSet.size() > 0){
            List<Deal_Registration__c> dealRegToUpdate = new List<Deal_Registration__c>();
            for(Opportunity opp : [SELECT id, Linked_Special_Bid_Registration__c, Linked_Special_Bid_Registration__r.Funnel_Opportunity__c, Linked_Special_Bid_Registration__r.status__c, stageName FROM Opportunity WHERE Id IN: oppIdsDealRegSet]){
                if(opp.Linked_Special_Bid_Registration__r.Funnel_Opportunity__c == NULL){
                    dealRegToUpdate.add(new Deal_Registration__c(Id = opp.Linked_Special_Bid_Registration__c, Funnel_Opportunity__c = opp.Id, Status__c = ' Converted to an Opportunity'));
                }else if(opp.StageName == 'Closed/Booked' || opp.stageName == 'Closed/Booked - NonFunnel'){
                    dealRegToUpdate.add(new Deal_Registration__c(Id = opp.Linked_Special_Bid_Registration__c, Status__c = 'Closed Booked'));
                }else if(opp.StageName == 'Closed/Lost'){
                    dealRegToUpdate.add(new Deal_Registration__c(Id = opp.Linked_Special_Bid_Registration__c, Status__c = 'Closed Lost'));
                }
            }
            System.debug(dealRegToUpdate);
            if(dealRegToUpdate.size() > 0){
                saveRes = Database.Update(dealRegToUpdate, False);
                Sendfailmsg(SaveRes, dealRegToUpdate);
            }
        }
        //monika EBA_SF-1258
        if(oppIDSet.size() > 0){
            List<Junction_Ticket_Opportunity__c> junList = [Select Id from Junction_Ticket_Opportunity__c where Related_Opprtunity_to_Request__c IN : oppIDSet];
            system.debug(junList);
            if(!junList.isEmpty()){
                saveRes = Database.Update(junList, False);
                Sendfailmsg(SaveRes,junList);
            }
        }
        
        if(altfyOppIds != null && !altfyOppIds.isEmpty()) {
            try {
                List<Opportunity> oppList = [SELECT Id, RecordTypeId, AccountId, CloseDate FROM Opportunity WHERE Id IN :altfyOppIds];
                OpportunityPlanOppSyncTrigger(oppList, delAltOppMap);
            }  catch(Exception e) {
                // send error email    
            }
        }
    }
    
    
    public static void Sendfailmsg(List<Database.SaveResult> srList, List<sObject> objList){
        String msg =''; 
        integer j=0;
        sObject rcrd = objList.get(0);
        for (Database.SaveResult saveRes : srList) {
            if (!saveRes.isSuccess()) {                     
                Database.Error e = saveRes.getErrors().get(0);
                if(rcrd.getsObjectType() == Junction_Ticket_Opportunity__c.sObjectType) {
                    Junction_Ticket_Opportunity__c obj = (Junction_Ticket_Opportunity__c) objList[j];                            
                    msg = msg + 'Ticket Request failed for Opportnity ' +obj.Related_Opprtunity_to_Request__r.Opportunity_Number__c + e.getMessage() +'</br>';
                }  
                if(rcrd.getsObjectType() == Deal_Registration__c.sObjectType) {
                    Deal_Registration__c obj = (Deal_Registration__c) objList[j];                            
                    msg = msg + 'Deal Registration Failed for Opportnity' +obj.Funnel_Opportunity__r.Opportunity_Number__c +e.getMessage() +'</br>';
                }                                    
            }
            j++;
        }
        
        if(msg!=''){ 
            List<String> rcpnts = NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(',');   
            NCR_EmailMessage__c emailMsg = new NCR_EmailMessage__c(Email_Type__c = 'NCR Update Failed', Subject__c = ' Ticket Request fail to update amount when opportunity amount is updated.',html_body__c = msg);
            if(!rcpnts.isEmpty()) {
                emailMsg.Recipient1__c = rcpnts.get(0);
                
                if(rcpnts.size() > 1) {
                    emailMsg.Recipient2__c = rcpnts.get(1);
                }
            }
            Insert emailMsg;            
        }           
    }
    
    
    /*  
#############################################################################
# Project Name..........: NSC Sales Central                                                                        
# File............................: updateOpportunityTeamMember.cls                                                        
# Version.....................: 21.0 
# Created by................: Darshan Singh Farswan                                                                    
# Created Date...........: 25-04-2011                                                                                
# Last Modified by......: Darshan Singh Farswan
# Last Modified Date..: 24-04-2011
# Description...............: The trigger updates the opportunity team members whenever any opportunity
is converted from 'Exclude in Funnel' to 'Include in funnel'
##############################################################################
*/
    public void updateOpportunityTeamMember(List<Opportunity> newOpp,List<Opportunity> oldOpportunity){
        Integer i;
       // Id oldRecordTypeID = '012700000001PoUAAU';
       // Id newRecordTypeID = '012700000001PoZAAU';
        
        // Exclude from Funnel record Type Ids
        //Set<Id> oldRecordTypeIds = new Set<Id>{'012700000001PoUAAU', '0120g000000N2y1AAC'};    
        // Include in Funnel record Type Ids
        //Set<Id> newRecordTypeIds = new Set<Id>{'012700000001PoZAAU', '0120g000000YU9xAAG', '0120g000000N2y2AAC'};
        
         // Exclude from Funnel record Type Ids
        Set<Id> oldRecordTypeIds = NSCCommonInfoUtil.getIdSetOf('Exclude_In_Funnel_Opportunities');
        // Include in Funnel record Type Ids
        Set<Id> newRecordTypeIds = NSCCommonInfoUtil.getIdSetOf('Include_In_Funnel_Opportunities');

        
         List<Id> IDs = new List<Id>();
        List<OpportunityTeamMember> salesTeamMember = new List<OpportunityTeamMember>();
        for(i=0;i<newOpp.size();i++){
            if(oldOpportunity[i].RecordTypeId != newOpp[i].RecordTypeId && oldRecordTypeIds.contains(oldOpportunity[i].RecordTypeId) && newRecordTypeIds.contains(newOpp[i].RecordTypeId)){
                IDs.add(newOpp[i].id);
            }
        }
        // Dont know [Ajay]
        if(IDs != null && IDs.size()>0){
            salesTeamMember = [Select id from OpportunityTeamMember where OpportunityID in :IDs];
            update salesTeamMember;
        }
    }
    /****************************************************************************************************************
//Name          :   PS_ChangeSchedule.tgr
//Author        :   Mudit Saxena
//Date          :   2 March 2017
//Version       :   Initial
//Description   :   This Trigger is use track changes in month & year of "Expected Delivery Start Date".
If Change Occure trigger reschedule all the toplines schedule forward.
i.e. Difference of month in "Old Expected Delivery Start Date" & "New Expected Delivery Start Date",
Add the diffrence in every schedule under every topline.
20-MAR-2018        Ajay:::NEW CHANGE AS DELIVERY DATE WILL BE READONLY, SCHEDULE CHANGE WILL BE DRIVEN BY CLOSEDATE
****************************************************************************************************************/
    
    public void PS_ChangeSchedule(List<Opportunity> newOppList,Map<Id,Opportunity> oldMapOpp){
        //system.debug('inside PS_ChangeSchedule');
        //system.debug('Recursionblocker.flag'+Recursionblocker.flag);
        if(Recursionblocker.flag){
            
            /***************************************************************************************************************
//Tracking change in Month & year in "Old Close Date" & "New Close Date".
//Populating Map with opportunity id and temp date .
***************************************************************************************************************/        
            Set<ID>ConflictDate = new Set<ID>();
            Set <Opportunity> oppL=new Set<Opportunity>();
            for( Opportunity opp : newOppList ){  
                //System.Debug('+++++'+opp);
                //System.debug('new opp closedate'+opp.CloseDate);
                //System.debug('Old opp closedate'+oldMapOpp.get( opp.id ).CloseDate);
                if( opp.CloseDate!= null && oldMapOpp.get( opp.id ).CloseDate!= null ){                    
                    if(opp.IsClosed!=true && (oldMapOpp.get( opp.id ).CloseDate.Month() != opp.CloseDate.Month() || oldMapOpp.get( opp.id ).CloseDate.year() != opp.CloseDate.year()) ){
                        ConflictDate.add(opp.id);
                        //System.debug('inside conflict date set fill');
                    }                   
                }   
            }
            //system.debug('PS Change ConflictDate'+ConflictDate);
            
            
            /***************************************************************************************************************
//Tracking if conflict occure by changing date.
//Populating Set with conflicted OLI .
***************************************************************************************************************/        
            Set<Id>OLIIds = new Set<Id>();
            if( ConflictDate != null && ConflictDate.size() > 0 ){
                for( OpportunityLineItemSchedule OLIS : [ SELECT id,ScheduleDate,OpportunityLineItemId,OpportunityLineItem.Opportunity.Id from OpportunityLineItemSchedule where OpportunityLineItem.Opportunity.Id IN : ConflictDate AND  ScheduleDate < :GlobalVariable.unhandledQtyDate ORDER BY ScheduleDate ASC ] ){            
                    OLIIds.add( OLIS.OpportunityLineItemId );
                    
                }
            }
            
            if( OLIIds != null && OLIIds.size() > 0 ){
                List<OpportunityLineItemSchedule>updOLISchLst = new List<OpportunityLineItemSchedule>();
                for( OpportunityLineItemSchedule update_OLIS : [ SELECT id,ScheduleDate, Quantity, OpportunityLineItem.Opportunity.Id,OpportunityLineItem.Opportunity.CloseDate from OpportunityLineItemSchedule where OpportunityLineItem.Opportunity.Id IN : ConflictDate AND  ScheduleDate < :GlobalVariable.unhandledQtyDate ORDER BY ScheduleDate ASC ] ){
                    //system.debug(oldMapOpp.get( update_OLIS.OpportunityLineItem.Opportunity.Id ).CloseDate+'#######'+oldMapOpp.get( update_OLIS.OpportunityLineItem.Opportunity.Id ).CloseDate .monthsBetween( update_OLIS.OpportunityLineItem.Opportunity.CloseDate ) );
                    update_OLIS.ScheduleDate = update_OLIS.ScheduleDate.addMonths( oldMapOpp.get( update_OLIS.OpportunityLineItem.Opportunity.Id ).CloseDate .monthsBetween( update_OLIS.OpportunityLineItem.Opportunity.CloseDate ) );
                    updOLISchLst.add( update_OLIS );
                    oppL.add(new Opportunity(id=update_OLIS.OpportunityLineItem.Opportunity.Id ));
                }
                if( updOLISchLst != null && updOLISchLst.size() > 0 ){
                    update updOLISchLst;
                    // making dummy call so that Expected Delivery Start Date is updated as per schedule changes
                    List <Opportunity> oppLst=new List<Opportunity>();
                    oppLst.addAll(oppL); 
                    //system.debug('how many times u are executing0');
                    
                    update oppLst;
                    //system.debug('how many times u are executing');
                    
                }
            }
            Recursionblocker.flag=false;
            //system.debug('how many times u are executing 2');
            
        }
    }
    
    /*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_OpportunityTrigger_BFR                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 18-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 18-07-2016
# Description...........: This trigger is used to prevent opportunity to be Closed/Booked - NonFunnel,
if a quote under is having status "Acknowledged".
////////////////////////////
Modified By: Ajay Dixit
Description: New requirement for asking whether Quote created in other system, Yes allows to close and No gives Quby Acknowledge Quote exception
////////////////////////////
Modified By: Mudit Saxena
Date : 9 march 2017
Description: An Opportunity must have a Submitted Quote associated to it before it can be closed. The Acknowledged quote requirement no longer applies. 
Story No : NC_AGILE-295
##################################################################################################*/
    
    public void QouteValidationOnOpportunityClose_BeforeInsert(List<Opportunity> newOppList){
        Set <Id> OppsClsd = new Set<Id>();
        for( Opportunity o: newOppList){
            if ( o.StageName == 'Closed/Booked'){
                if( o.IsQuoteCreatedInOtherSystem__c == null || o.IsQuoteCreatedInOtherSystem__c == '' || o.IsQuoteCreatedInOtherSystem__c.toUpperCase()!='YES'
                   ||o.IsQuoteCreatedInOtherSystem__c.toUpperCase()== 'NO'){
                       OppsClsd.add( o.id );
                   }
            }
        }
        if(OppsClsd.size()>0){
            OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
            OppHelper.QouteValidationOnOpportunityClose( OppsClsd,newOppList);
        } 
    }
    public void QouteValidationOnOpportunityClose_BeforeUpdate(List<Opportunity> newOppList,Map<Id,Opportunity> oldMapOpp){
        Set <Id> OppsClsd = new Set<Id>();
        for( Opportunity o: newOppList){
            if ( o.stageName != oldMapOpp.get( o.id ).StageName && o.StageName == 'Closed/Booked' ){
                if( o.IsQuoteCreatedInOtherSystem__c == null || o.IsQuoteCreatedInOtherSystem__c == '' || o.IsQuoteCreatedInOtherSystem__c.toUpperCase()!='YES'
                   ||o.IsQuoteCreatedInOtherSystem__c.toUpperCase()== 'NO'){
                       OppsClsd.add( o.id );
                   } 
            }
            if( (o.stageName != oldMapOpp.get( o.id ).StageName && ( oldMapOpp.get( o.Id ).StageName=='Closed/Booked' )) ||(o.stageName != oldMapOpp.get( o.id ).StageName) && (o.stageName == 'Prospecting') && (oldMapOpp.get( o.Id ).Stagename == 'Closing')){
                /* FeatureManagement check permission added for covering the story EBA_SF-1527*/
                Integer dayFrmCls = o.CloseDate.daysBetween(System.today());
                if(o.isClosed!=true&&(!((FeatureManagement.checkPermission('Update_Closed_Opp_for_7_days')&&dayFrmCls<Integer.valueOf(Label.Opp_Grace_Sales_Rep)+1)||(FeatureManagement.checkPermission('Update_Closed_Opp_for_37_days')&&dayFrmCls<Integer.valueOf(Label.Opp_Grace_Sales_Ops)+1)))){
                    o.addError( system.label.OppTrgHndlr4, false ); //Can’t change or go back on the opportunity stage once it is in "Closing" or "Closed/Booked"
                }
            }
        }
        if(OppsClsd.size()>0){
            OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
            OppHelper.QouteValidationOnOpportunityClose( OppsClsd,newOppList);
        } 
    }
    
    /*##################################################################################################
# Project Name..........: QuBy
# File..................: QuBy_OpportunityTrigger_BFR                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena                                                                 
# Created Date..........: 18-07-2016                                                                               
# Last Modified by......: Mudit Saxena 
# Last Modified Date....: 18-07-2016
# Description...........: If Opportunity id getting delete then de-associated Quotes and send delete entry flag to QUBY

##################################################################################################*/
    
    public void OnDeleteOpp_UpdateQuBy(set<id> oppLst,List<Opportunity> oldOpportunity){
        Set<String>QuoteNumbers = new Set<String>();
        List<QuBy_Detail__c> updAllQBQuot = new List<QuBy_Detail__c>();
        for( QuBy_Detail__c QD : [ SELECT id,Quote_Number__c,Opportunity_No__c FROM QuBy_Detail__c WHERE Opportunity__c IN : oppLst ] ){
            QuoteNumbers.add( QD.Quote_Number__c );
            QD.Opportunity_No__c = '';
            updAllQBQuot.add( QD );
        }
        
        if( QuoteNumbers != null && QuoteNumbers.size() > 0 ){
            List<NSC_To_QuBy_Quote__c>NTQList = new List<NSC_To_QuBy_Quote__c>();
            for( NSC_To_QuBy_Quote__c NTQ : [ SELECT id,Linkage_Flag__c FROM NSC_To_QuBy_Quote__c WHERE Quote_Number__c IN : QuoteNumbers ] ){
                if( NTQ.Linkage_Flag__c == 'L' ){
                    NTQ.Linkage_Flag__c = 'D';
                    NTQList.add( NTQ );
                }
            }
            
            if( NTQList != null && NTQList.size() > 0 )
                update NTQList;
            
            if( updAllQBQuot != null && updAllQBQuot.size() > 0 )
                update updAllQBQuot;
        }
    }
    
    /*
####################################################################################################################
# Project Name..........: MST OCR ORDER COMMIT PHASE 3                                                                                                                            
# File............................:PopulateOCRBookDateFields.trigger                                                             
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 02-10-2016                                                                                  
# Last Modified by......: Mudasir Rashid                                                                           
# Last Modified Date..: 03-01-2017                                                                                 
# Description...............: This trigger populates the Book Date fields on the Opportunity.These fields are used in OCR extraction. 
####################################################################################################################
*/
       
    public void PopulateOCRBookDateFields_InsertOrUpdate(List<Opportunity> newOppList){
        Map<Date, OCR_Calender__c> ocrDateCalendarMap = new Map<Date, OCR_Calender__c>();
        
        for(Opportunity opp :newOppList) {
            if(opp.IsClosed) {
                Date calDate = (opp.Actual_Close_Date__c != null) ? opp.Actual_Close_Date__c : (opp.CloseDate != null ? opp.CloseDate : Date.today());
                    ocrDateCalendarMap.put(calDate, null);               
            } else {
                Date calDate = (opp.CloseDate != null) ? opp.CloseDate : Date.today();
                ocrDateCalendarMap.put(calDate, null);     
            }
        }
        if (!ocrDateCalendarMap.isEmpty()) { 
            ocrDateCalendarMap.put(Date.Today(), null);
        }
        OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
        OppHelper.PopulateOCRBookDateFields(newOppList,ocrDateCalendarMap);
    }
    //Changes done by Yogesh related to EBA_SF-1381 
    /*public void PopulateOCRBookDateFields_Update(List<Opportunity> newOppList, Map< Id, Opportunity > oldMapOpp){
Map<Date, OCR_Calender__c> ocrDateCalendarMap = new Map<Date, OCR_Calender__c>();
for(Opportunity opp :newOppList) {
Opportunity oldOpp = oldMapOpp.get(opp.Id);

//if ((opp.IsClosed != oldOpp.IsClosed) || (opp.Actual_Close_Date__c != oldOpp.Actual_Close_Date__c) 
// || (opp.CloseDate != oldOpp.CloseDate) || (opp.ForecastCategoryName != oldOpp.ForecastCategoryName)) {

if(opp.IsClosed) {
Date calDate = (opp.Actual_Close_Date__c != null) ? opp.Actual_Close_Date__c : (opp.CloseDate != null ? opp.CloseDate : Date.today());
ocrDateCalendarMap.put(calDate, null);          
} else { 
Date calDate = (opp.CloseDate != null) ? opp.CloseDate : Date.today();
ocrDateCalendarMap.put(calDate, null);    
} 
// }
}
if (!ocrDateCalendarMap.isEmpty()) {
ocrDateCalendarMap.put(Date.Today(), null);
}
OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
OppHelper.PopulateOCRBookDateFields(newOppList,ocrDateCalendarMap);
}*/
    
 
    
  /*  public void PopulateOCRBookDateFields_Insert(List<Opportunity> newOppList){
        Map<Date, OCR_Calender__c> ocrDateCalendarMap = new Map<Date, OCR_Calender__c>();
        
        for(Opportunity opp :newOppList) {
            if(opp.IsClosed) {
                Date calDate = (opp.Actual_Close_Date__c != null) ? opp.Actual_Close_Date__c : (opp.CloseDate != null ? opp.CloseDate : Date.today());
                ocrDateCalendarMap.put(calDate, null);               
            } else {
                Date calDate = (opp.CloseDate != null) ? opp.CloseDate : Date.today();
                ocrDateCalendarMap.put(calDate, null);     
            }
        }
        if (!ocrDateCalendarMap.isEmpty()) { 
            ocrDateCalendarMap.put(Date.Today(), null);
        }
        OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
        OppHelper.PopulateOCRBookDateFields(newOppList,ocrDateCalendarMap);
    }
    
    public void PopulateOCRBookDateFields_Update(List<Opportunity> newOppList, Map< Id, Opportunity > oldMapOpp){
        Map<Date, OCR_Calender__c> ocrDateCalendarMap = new Map<Date, OCR_Calender__c>();
        for(Opportunity opp :newOppList) {
            Opportunity oldOpp = oldMapOpp.get(opp.Id);
            
            //if ((opp.IsClosed != oldOpp.IsClosed) || (opp.Actual_Close_Date__c != oldOpp.Actual_Close_Date__c) 
            // || (opp.CloseDate != oldOpp.CloseDate) || (opp.ForecastCategoryName != oldOpp.ForecastCategoryName)) {
            
            if(opp.IsClosed) {
                Date calDate = (opp.Actual_Close_Date__c != null) ? opp.Actual_Close_Date__c : (opp.CloseDate != null ? opp.CloseDate : Date.today());
                ocrDateCalendarMap.put(calDate, null);          
            } else { 
                Date calDate = (opp.CloseDate != null) ? opp.CloseDate : Date.today();
                ocrDateCalendarMap.put(calDate, null);    
            } 
            // }
        }
        if (!ocrDateCalendarMap.isEmpty()) {
            ocrDateCalendarMap.put(Date.Today(), null);
        }
        OpportunityTriggerHandlerHelper OppHelper = new OpportunityTriggerHandlerHelper();
        OppHelper.PopulateOCRBookDateFields(newOppList,ocrDateCalendarMap);
    }*/
    //End Changes -Yogesh
    
    /*
####################################################################################################################
# Project Name..........: NSC                                                                                                                           
# File............................:CurrencyIsoConversion.trigger                                                             
# Created by................: Pankaj                                                                     
# Created Date...........: 09-8-2016                                                                                  
# Last Modified by......: Admin NSC                                                                           
# Last Modified Date..: 03-29-2017                                                                                 
# Description...............: Convert currencyother than USD to USD
####################################################################################################################
*/
    public void CurrencyIsoConversion (List<Opportunity> newOppList){
        Set<String> isoCodes = new Set<String>();
        Map<String,Double> conversion_rates = new Map<String,Double>();
        for(Opportunity OppObj : newOppList)
        {
            if(String.IsNotBlank(OppObj.CurrencyIsoCode) && (oppObj.CurrencyIsoCode != 'USD'))
                isoCodes.add(OppObj.CurrencyIsoCode);
        }
        
        if(isoCodes.Size()>0)
        {
            for(CurrencyType curr: [SELECT IsoCode,ConversionRate FROM CurrencyType  WHERE IsoCode in: isoCodes])
            {
                if(!conversion_rates.ContainsKey(curr.IsoCode) && String.IsnotBlank(curr.IsoCode) && curr.ConversionRate != null)
                {
                    conversion_rates.put(curr.IsoCode,curr.ConversionRate); 
                } 
                
            }
        }  
        
        for(Opportunity oppObj : newOppList)
        {
            if(String.IsNotBlank(oppObj.CurrencyIsoCode) && oppObj.CurrencyIsoCode != 'USD' && conversion_rates.ContainsKey(oppObj.CurrencyIsoCode)){
                oppObj.Currency_Conversion_Rate__c=conversion_rates.get(oppObj.CurrencyIsoCode);
                
            }
            
            else  {
                if(conversion_rates.ContainsKey(oppObj.CurrencyIsoCode))
                    oppObj.Currency_Conversion_Rate__c= conversion_rates.get(oppObj.CurrencyIsoCode); 
                
            }
            
        }
    }
    
    /**************************************
Author ...............: Ajay Dixit
Date Created .........: 8 Apr 2018
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class holds logic to set EDSD as per first schedule
***************************/
    
    public void UpdateEDDtoEBD_BeforeInsert(List<Opportunity> newOppList){
        if(EBDEDDSetting__c.getValues('EDSD_Calc')!=null && EBDEDDSetting__c.getValues('EDSD_Calc').isActive__c){
            Map<id,User> SysUser=new Map<ID, User>([Select id from User where Access_type__c='System']);
            if(!sysUser.containsKey(UserInfo.getUserId())){
                for(Opportunity Opp : newOppList){
                    opp.Expected_Delivery_Date__c=opp.CloseDate.addMonths(1);
                }   
            }
            
        }
        
    }
    public void UpdateEDDtoEBD_BeforeUpdate(List<Opportunity> newOppList,Map<id,Opportunity> newMapOpportunity) {
        if(EBDEDDSetting__c.getValues('EDSD_Calc')!=null && EBDEDDSetting__c.getValues('EDSD_Calc').isActive__c){
            Map<id,User> SysUser=new Map<ID, User>([Select id from User where Access_type__c='System']);
            if(!sysUser.containsKey(UserInfo.getUserId())){
                map<Integer,map<integer,Date>> mpFiscalMonthEndDate = new map<Integer,map<integer,Date>>();
                mpFiscalMonthEndDate= NSCCommonInfoUtil.getInstance().getFiscalMonthEndDate();
                
                Date unscheduleDate = Date.newInstance(3000, 1, 1);
                List <OpportunityLineItem> OppScheduleList=new List<OpportunityLineItem>();
                Map<ID, Date> OppWthErlySch=new Map<ID, Date>();
                
                Set<Id> OrderManOpportunities = new Set<Id>();
                
                OppScheduleList = [select id, OpportunityId,Product2.Name, (Select id,ScheduleDate from OpportunityLineItemSchedules) from OpportunityLineItem where OpportunityId in : newMapOpportunity.keySet()];
                
                for(OpportunityLineItem oli:OppScheduleList){ 
                    //check for Orderman product
                    //System.debug('____'+oli.Product2.Name);
                    if(oli.Product2.Name.containsIgnorecase('Orderman')){
                        OrderManOpportunities.add(oli.OpportunityId); 
                    }
                    for(OpportunityLineItemSchedule olis:oli.OpportunityLineItemSchedules){
                        if(olis!=null && olis.ScheduleDate.daysBetween(unscheduleDate)>0){
                            if(OppWthErlySch.get(oli.OpportunityId)!=null){
                                if(olis.ScheduleDate.daysBetween(OppWthErlySch.get(oli.OpportunityId))>0){
                                    OppWthErlySch.put(oli.OpportunityId, olis.ScheduleDate);  
                                    
                                }
                            }else{
                                OppWthErlySch.put(oli.OpportunityId, olis.ScheduleDate);
                            }
                        }
                    }
                }
                for(Opportunity Opp : newOppList){
                    if(OppWthErlySch.size()>0 && OppWthErlySch.get(opp.id)!=null){
                        Date d=OppWthErlySch.get(opp.id);
                        
                        if(OppWthErlySch.get(opp.id).year()==opp.CloseDate.year() && OppWthErlySch.get(opp.id).month()==opp.CloseDate.month()){
                            Integer numberOfDays = Date.daysInMonth(opp.CloseDate.year(), opp.CloseDate.month());
                            Date lastDayOfMonth = Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), numberOfDays);
                            //Orderman chnages
                            if(!OrderManOpportunities.contains(opp.id)){
                                opp.Expected_Delivery_Date__c=lastDayOfMonth; 
                            }else{
                                //orderman logic
                                map<integer,Date> mpMonthEndDate = new map<integer,Date>();
                                if(mpFiscalMonthEndDate.containskey(opp.CloseDate.year())){
                                    mpMonthEndDate = mpFiscalMonthEndDate.get(opp.CloseDate.year()); 
                                    opp.Expected_Delivery_Date__c=mpMonthEndDate.get(opp.CloseDate.month());
                                } 
                            }
                        }else{
                            opp.Expected_Delivery_Date__c=OppWthErlySch.get(opp.id);                        
                        }
                    }else{
                        opp.Expected_Delivery_Date__c=opp.CloseDate.addMonths(1);
                    }
                }   
            }
            
        }
        
    }
    /**
##################################################################################################
# Project Name and Request Num..........: NSC Sales Central( NSC_AGILE-604,NSCI_AGILE-30)
# File............................: PopulateOcrTeam.Trigger                                                        
# Created by................: Saritha karutrui                                                                   
# Created Date...........: 12-01-2015                                                                              
# Last Modified by......:  Puneet Bhatia ,Rahul Gaira 
# Last Modified Date..:    25-02-2016, 5-10-2016
# Description...............: This tirgger will update the ocr team value on opportunity based on the Sales Org Code  custom object mapping data.
NSCI_AGILE-30-Logic is constructed based on the new mapping file for sales org code.
NSCI_AGILE-323-Added logic to insert/update opportunitycontactrole record based on Contact lookup on opporunity
Added the Switch to escape the trigger while code run of deal Conversion
Added NC_AGILE-895   Auto-populate Decision Maker Contact on Renewal Opportunity - Nagendra

################################################################################################
*///--------------------------OCR_TEAM__c Object Deletion EBA_SF-1720---------------------------------------

    //Before insert update logic of PopulateOcrTeamAndContactRole trigger (switch logic) 
  /*  public void PopulateOcrTeamAndContactRole(List<Opportunity> newOppList){
        //start of Switch code
        //IF(newOppList[0].Is_Channel_Opportunity__c == false){ = commenting to remove Is_Channel_Opportunity__c field
        Set<String> SalesOrgSet = new  Set<String>();
        
        for (Opportunity opp : newOppList) {
            if ((opp.Sales_Org_Code__c != null) && (opp.Sales_Org_Code__c != '')) {
                SalesOrgSet.add(opp.Sales_Org_Code__c);    
            }
        }
        //System.debug('Sales org code'+SalesOrgSet);
        if((SalesOrgSet != null) && (SalesOrgSet .size() > 0)) {
            Integer i;
            List<OCR_TEAM__c> ocrInformation = new List<OCR_TEAM__c>();
            Map<String,String> Opporgcode=new Map<String,String>();
            ocrInformation= [select id,Ocr_Team__c,Sales_Org__c from OCR_TEAM__c WHERE Sales_Org__c IN :SalesOrgSet];
            //System.debug('ocrInformation'+ocrInformation);
            for(OCR_TEAM__c oct: ocrInformation){
                Opporgcode.put(oct.Sales_Org__c,oct.Ocr_Team__c);
            }
            //System.debug('Opporgcode'+Opporgcode);
            for(i=0;i<newOppList.size();i++){
                if((newOppList[i].Sales_Org_Code__c!=null && newOppList[i].Sales_Org_Code__c!='')){
                    if(Opporgcode.containsKey(newOppList[i].Sales_Org_Code__c)){
                        newOppList[i].OCR_Team_Temp__c=Opporgcode.get(newOppList[i].Sales_Org_Code__c);
                    }
                    else{
                        newOppList[i].OCR_Team_Temp__c = 'Undefined';
                    }  
                }
            }
        }
        //}
        //End of Switch code
    }//--------------------------OCR_TEAM__c Object Deletion EBA_SF-1720---------------------------------------*/

    
    /*
#############################################################################
# Project Name..........:NSC Sales Central                                                                     
# File............................: validateOpportunities.trigger
# Version.....................: 
# Created by................: NSC Admin                                                                   
# Created Date...........:  9-1-2010                                                                              
# Description...............:
populate standard forecast category field from custom forecast category field
Modification History:
Date           Developer Name          User Story
7-6-2016       Nagendra Singh          Removed Logic as part of "NSCI_AGILE-1238"-'Opportunity stage changes are not allowed after an opportunity has been closed'
1-9-2016       Nagendra SIngh          NSCI_AGILE-2091 BUG - Forecast Category Field - Moved up Forecast populate logic 
5-6-2017       Nagendra Singh          NC_AGILE-626   Bug- Forecast Category issue for DI users
##############################################################################
*/
    public void PopulateForecastCategory_BeforeInsert(List<Opportunity> newOppList){
        NSCCommonInfoUtil NSC_Util ;
        Id excludeRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exclude from Funnel').getRecordTypeId();
        Id excludeIndirectRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indirect - Exclude from Funnel').getRecordTypeId();
        /**Ajay---EBA_SF-1278---** Expecting CPQ sync is based on  user with lightning***/
        if( CPQTriggerControl.cpqSpclHdlgNew || NSCCommonInfoUtil.getInstance().userHasLightningPermission(Userinfo.getUserId())){
            for(Opportunity opp :newOppList) {
                if(opp.Forecast_Category__c != NULL) {
                    if(opp.StageName == 'Closed/Booked'){
                        opp.Forecast_Category__c = opp.ForecastCategoryName;
                    }
                    else if(opp.StageName == 'Closed/Lost'){ opp.Forecast_Category__c = opp.ForecastCategoryName;
                                                           }
                    else if(opp.StageName == 'Closed/Discontinued'){ opp.Forecast_Category__c = opp.ForecastCategoryName;
                                                                   }
                    else{
                        
                        if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                            if(opp.Forecast_Category__c == 'Exclude Pipeline') {
                                opp.ForecastCategoryName = 'Pipeline'; 
                            } else if(opp.Forecast_Category__c == 'Exclude Upside') {
                                opp.ForecastCategoryName = 'Upside'; 
                            }
                            else if(opp.Forecast_Category__c == 'Exclude Commit') {
                                opp.ForecastCategoryName = 'Commit'; 
                            }
                            else {
                                opp.ForecastCategoryName = opp.Forecast_Category__c; 
                            }
                        } else {
                            opp.ForecastCategoryName = opp.Forecast_Category__c; 
                        }
                        
                        
                    }
                    
                } else if(opp.ForecastCategoryName  != NULL) {
                    
                    if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                        if(opp.ForecastCategoryName == 'Pipeline') {
                            opp.Forecast_Category__c = 'Exclude Pipeline' ;
                        }  else if(opp.ForecastCategoryName == 'Commit') {
                            opp.Forecast_Category__c = 'Exclude Commit' ;
                        } else if(opp.ForecastCategoryName == 'Upside') {
                            opp.Forecast_Category__c = 'Exclude Upside' ;
                        } else {
                            opp.Forecast_Category__c = opp.ForecastCategoryName;  
                        }
                        
                    } else {
                        opp.Forecast_Category__c = opp.ForecastCategoryName;  
                    }
                    
                }     
            }
        }else{
            //Start of Code change NC_AGILE-626
            for(Opportunity opp :newOppList) {
                if(opp.Forecast_Category__c != NULL) {
                    if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                        if(opp.Forecast_Category__c == 'Exclude Pipeline') {
                            opp.ForecastCategoryName = 'Pipeline'; 
                        } else if(opp.Forecast_Category__c == 'Exclude Upside') {
                            opp.ForecastCategoryName = 'Upside'; 
                        }
                        else if(opp.Forecast_Category__c == 'Exclude Commit') {
                            opp.ForecastCategoryName = 'Commit'; 
                        } else {
                            opp.ForecastCategoryName = opp.Forecast_Category__c;  
                        }
                        
                    } else {
                        opp.ForecastCategoryName = opp.Forecast_Category__c; 
                    }
                    
                }
                else if(opp.ForecastCategoryName  != NULL) {
                    
                    if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                        if(opp.ForecastCategoryName == 'Pipeline') {
                            opp.Forecast_Category__c = 'Exclude Pipeline' ;
                        }  else if(opp.ForecastCategoryName == 'Commit') {
                            opp.Forecast_Category__c = 'Exclude Commit' ;
                        } else if(opp.ForecastCategoryName == 'Upside') {
                            opp.Forecast_Category__c = 'Exclude Upside' ;
                        } else {
                            opp.Forecast_Category__c = opp.ForecastCategoryName;  
                        }
                        
                    } else { 
                        opp.Forecast_Category__c = opp.ForecastCategoryName;
                    }
                    
                    
                    
                }
            }
        }
    }
    
    public void PopulateForecastCategory_BeforeUpdate(List<Opportunity> newOppList,map<id,Opportunity> oldMapOpp){
        NSCCommonInfoUtil NSC_Util ;
        Id excludeRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Exclude from Funnel').getRecordTypeId();
        Id excludeIndirectRecdTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Indirect - Exclude from Funnel').getRecordTypeId();
        //System.debug('******Is Lightning user***********'+NSCCommonInfoUtil.getInstance().userHasLightningPermission(Userinfo.getUserId()));
        if( NSCCommonInfoUtil.getInstance().userHasLightningPermission(Userinfo.getUserId())){
            
            for(Opportunity opp :newOppList) {
                //check if stagename or Forecast is changed
                if(opp.StageName != oldMapOpp.get(opp.Id).StageName ||  (opp.Forecast_Category__c != oldMapOpp.get(opp.Id).Forecast_Category__c)){
                    // System.debug('*****************'+opp.StageName);
                    // System.debug('******Custom Forecast***********'+opp.Forecast_Category__c);
                    // System.debug('******Standard Forecast***********'+opp.ForecastCategoryName);
                    if(opp.Forecast_Category__c != NULL) {
                        if(opp.StageName == 'Closed/Booked'){
                            opp.Forecast_Category__c = opp.ForecastCategoryName;
                        }
                        else if(opp.StageName == 'Closed/Lost'){ opp.Forecast_Category__c = opp.ForecastCategoryName;
                                                               }
                        else if(opp.StageName == 'Closed/Discontinued'){ opp.Forecast_Category__c = opp.ForecastCategoryName;
                                                                       }
                        else{
                            
                            if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                                if(opp.Forecast_Category__c == 'Exclude Pipeline') {
                                    opp.ForecastCategoryName = 'Pipeline'; 
                                } else if(opp.Forecast_Category__c == 'Exclude Upside') {
                                    opp.ForecastCategoryName = 'Upside'; 
                                }
                                else if(opp.Forecast_Category__c == 'Exclude Commit') {
                                    opp.ForecastCategoryName = 'Commit'; 
                                }
                                else {
                                    opp.ForecastCategoryName = opp.Forecast_Category__c; 
                                }
                            } else {
                                opp.ForecastCategoryName = opp.Forecast_Category__c; 
                            }
                            
                            
                        }
                        
                    } else if(opp.ForecastCategoryName  != NULL) {
                        if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                            if(opp.ForecastCategoryName == 'Pipeline') {
                                opp.Forecast_Category__c = 'Exclude Pipeline' ;
                            }  else if(opp.ForecastCategoryName == 'Commit') {
                                opp.Forecast_Category__c = 'Exclude Commit' ;
                            } else if(opp.ForecastCategoryName == 'Upside') {
                                opp.Forecast_Category__c = 'Exclude Upside' ;
                            } else {
                                opp.Forecast_Category__c = opp.ForecastCategoryName;  
                            }
                            
                        } else {
                            opp.Forecast_Category__c = opp.ForecastCategoryName;  
                        }
                        
                        
                    } 
                }   else if(opp.StageName != oldMapOpp.get(opp.Id).StageName ||  (opp.ForecastCategoryName != oldMapOpp.get(opp.Id).ForecastCategoryName)){
                    
                    if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                        if(opp.ForecastCategoryName == 'Pipeline') {
                            opp.Forecast_Category__c = 'Exclude Pipeline' ;
                        }  else if(opp.ForecastCategoryName == 'Commit') {
                            opp.Forecast_Category__c = 'Exclude Commit' ;
                        } else if(opp.ForecastCategoryName == 'Upside') {
                            opp.Forecast_Category__c = 'Exclude Upside' ;
                        } else {
                            opp.Forecast_Category__c = opp.ForecastCategoryName;  
                        }
                        
                    } else {
                        opp.Forecast_Category__c = opp.ForecastCategoryName; 
                    }
                    
                    
                }
                
            }
            //Going back logic
            for(Opportunity opp :newOppList){
                Opportunity oldOpp = oldMapOpp.get(opp.Id);
                if (oldOpp.isClosed && !opp.isClosed) {
                    if(opp.Forecast_Category__c =='Omitted' || opp.Forecast_Category__c =='Closed'){
                        opp.Forecast_Category__c = opp.Previous_Forecast_Category__c;
                        opp.ForecastCategoryName = opp.Previous_Forecast_Category__c;
                    }
                    
                    
                }
            }
            //finish going back logic
        }else{
            //Code change NC_AGILE-626 
            for(Opportunity opp :newOppList) {
                if(opp.StageName != oldMapOpp.get(opp.Id).StageName ||  (opp.Forecast_Category__c != oldMapOpp.get(opp.Id).Forecast_Category__c)){
                    if(opp.Forecast_Category__c !=null) {
                        
                        if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                            if(opp.Forecast_Category__c == 'Exclude Pipeline') {
                                opp.ForecastCategoryName = 'Pipeline'; 
                            } else if(opp.Forecast_Category__c == 'Exclude Upside') {
                                opp.ForecastCategoryName = 'Upside'; 
                            }
                            else if(opp.Forecast_Category__c == 'Exclude Commit') {
                                opp.ForecastCategoryName = 'Commit'; 
                            }
                            else {
                                opp.ForecastCategoryName = opp.Forecast_Category__c; 
                            }
                        } else {
                            opp.ForecastCategoryName = opp.Forecast_Category__c; 
                        }
                        
                    } 
                    else{
                        opp.Forecast_Category__c = opp.ForecastCategoryName;
                    }
                }
                else if(opp.StageName != oldMapOpp.get(opp.Id).StageName ||  (opp.ForecastCategoryName != oldMapOpp.get(opp.Id).ForecastCategoryName)){
                    
                    
                    if(opp.RecordTypeId == excludeRecdTypeId ||  opp.RecordTypeId == excludeIndirectRecdTypeId) {
                        if(opp.ForecastCategoryName == 'Pipeline') { opp.Forecast_Category__c = 'Exclude Pipeline' ;
                                                                   }  else if(opp.ForecastCategoryName == 'Commit') {
                                                                       opp.Forecast_Category__c = 'Exclude Commit' ;
                                                                   } else if(opp.ForecastCategoryName == 'Upside') {
                                                                       opp.Forecast_Category__c = 'Exclude Upside' ;
                                                                   } else {
                                                                       opp.Forecast_Category__c = opp.ForecastCategoryName;  
                                                                   }
                        
                    } else {
                        opp.Forecast_Category__c = opp.ForecastCategoryName; 
                    }
                    
                    
                }
            }
            //End of Code change NC_AGILE-626 
            
        }
    }
    /*
#############################################################################
# Project Name..........:NSC Sales Central                                                                     
# File............................: validateOpportunities.trigger
# Version.....................: 
# Created by................: NSC Admin                                                                   
# Created Date...........:  9-1-2010                                                                              
# Description...............:Validate opportunity StageName- At least one Contact Role should be assign to opportunity before it progress to the StageName.

##############################################################################
*/
    public void validateOportunity(List<Opportunity> newOppList,map<id,Opportunity> oldMapOpp){
        Map<Id, Opportunity> newOppMapLocal = new Map<Id, Opportunity>();
        Map<Id, Opportunity> oldOpportunityMapLocal = new Map<Id, Opportunity>();
        
        for(Opportunity opp :newOppList) {
            Opportunity oldOpp = oldMapOpp.get(opp.Id);
            
            if (!oldOpp.isClosed) {
                newOppMapLocal.put(opp.Id, opp);
                oldOpportunityMapLocal.put(opp.Id, oldOpp);
            }    
        }
        Validations.validateOpportunity(newOppMapLocal, oldOpportunityMapLocal);
    }
    public void validateOportunityAmount(List<Opportunity> newOppList,map<id,Opportunity> oldMapOpp){
        if (CheckRecursive.runoppAmountValidation()) {
            Map<Id, Opportunity> newOppMap = new Map<Id, Opportunity>();
            
            for(Opportunity opp :newOppList) {Opportunity oldOpp = oldMapOpp.get(opp.Id);
                if (opp.Amount != oldOpp.Amount) {newOppMap.put(opp.Id, opp);}    
            } 
            
            if(!newOppMap.isEmpty()) Validations.validateOpportunityAmount(newOppMap);
        }
    }
    public void synchToDownStream(List<Opportunity> newOppList, map<id,Opportunity> oldMapOpp){
        List <id> oppids=new List<id>(); 
        List <id> linkedoppids=new List<id>();
        List <id> closedoppids=new List<id>(); 
        Set  <id> closedSrvcoppids=new Set<id>();
        Set  <id> closedSrvcoppidsWithoutSysid=new Set<id>();
        Integer i=0;
        for(Opportunity o:newOppList){ 
            //Adding all ids and evaluation will be done later so that criteria can be customized on run time.
            if(o.USM_Opportunity_Number__c!=null){
                //system.debug('~~~'+oldOpportunityList[i].USM_Opportunity_Number__c+'-'+o.USM_Opportunity_Number__c+'-'+oldOpportunityList[i].USM_NSC_Opportunity_Sys_Id__c+'-'+o.USM_NSC_Opportunity_Sys_Id__c);
                if(oldMapOpp.get(o.Id).USM_Opportunity_Number__c==null && o.USM_NSC_Opportunity_Sys_Id__c==null){linkedoppids.add(o.id);
                }else{
                    if(!(o.USM_NSC_Opportunity_Sys_Id__c!=null && oldMapOpp.get(o.Id).USM_NSC_Opportunity_Sys_Id__c==null)){ oppids.add(o.id); 
                    }                    
                }
                
            }else if(o.StageName=='Closed/Booked'){
                closedoppids.add(o.id);
            }
            i++;
        }
        // Get Closed opps with Service products
        List <OpportunityLineItem> oliL=[Select OpportunityId, Opportunity.USM_NSC_Opportunity_Sys_Id__c from OpportunityLineItem where OpportunityId=:closedoppids and product2.Service_Offer_Category__c in ('HWM','TS','Managed Service')];
        for(OpportunityLineItem oli:oliL){
            if(oli.Opportunity.USM_NSC_Opportunity_Sys_Id__c!=null){closedSrvcoppids.add(oli.OpportunityId);
            }else{ closedSrvcoppidsWithoutSysid.add(oli.OpportunityId); 
             }
            
        }
        // Closed Srvc Opportunity for synching update
        if(closedSrvcoppids.size()>0){
            oppids.addAll(closedSrvcoppids); 
        }
        // Closed Service Opportunities without USM NSC sysid
        if(closedSrvcoppidsWithoutSysid.size()>0){
            linkedoppids.addAll(closedSrvcoppidsWithoutSysid); 
        }
        // USM Synchs
        if(oppids.size()>0){ System.enqueuejob(new synchUSMOnOppUpdateQueueable(oppids));
                            //usmCallHandler.synchUSMOnOppUpdate(oppids); 
                            
                           } 
        if(linkedoppids.size()>0){ System.enqueuejob(new synchUSMOnOppLinkQueueable(linkedoppids));
                                  //usmCallHandler.synchUSMOnOppLink(linkedoppids);
                                  
                                 }  
    }
    
    
    public void processPrimaryQuotes(List<Opportunity> newCPQOppList,Map<Id,Opportunity> oldMapOpp) {
        Set<String> prmQtIds = new Set<String>();
        for(Opportunity opp : newCPQOppList) {
            if ((oldMapOpp.get(opp.Id).CloseDate != opp.CloseDate || (oldMapOpp.get(opp.Id).payments_rep__c != null && opp.Payments_Rep__c==null)) && opp.SBQQ__PrimaryQuote__c != null) {
                prmQtIds.add(opp.SBQQ__PrimaryQuote__c);    
            }    
        }
        
        if(!prmQtIds.isEmpty() && prmQtIds.size() > 0){
            List<SBQQ__Quote__c> qList = [Select id,SBQQ__Primary__c,SBQQ__Ordered__c,SBQQ__Account__r.AutoPay_Setup__c,SBQQ__Opportunity2__c,ApprovalStatus__c,
                                          qtc_Requested_Delivery_Date__c from SBQQ__Quote__c where id in :prmQtIds];
            if(!System.isFuture() && !System.isBatch()){
                System.enqueueJob(new cpq_QteToOppSync((List<SBQQ__Quote__c>)qList, 'OPP'));   
            } 
        }
    } 
    
    
    public void valOppForMxdServOff(Map<Id, Opportunity> oppMap, Boolean isOppTypeChg) {
        Set<String> srvRevTyps = new Set<String>();
        List<Renewable_Products__c> srvPrdLst = Renewable_Products__c.getAll().values();        
        
        if (!srvPrdLst.isEmpty() && String.isNotBlank(srvPrdLst[0].Product_Revenue_Types__c)) { 
            srvRevTyps.addAll(srvPrdLst[0].Product_Revenue_Types__c.split(','));
        }
        
        if(!oppMap.isEmpty()) {
            Map<Id, Opportunity> oppWithLineMap = new Map<Id, Opportunity>([SELECT Id, (SELECT Id, Opportunity_Line_Item_Type__c FROM OpportunityLineItems WHERE Revenue_Type__c IN :srvRevTyps) FROM Opportunity WHERE Id IN :oppMap.keySet() and isClosed=false]);     
            
            for(Opportunity opp : oppMap.values()) {
                Boolean newSrvLine = false,rnwSrvLine = false;
                
                if(oppWithLineMap.containskey(opp.Id)) {
                    for (OpportunityLineItem oli : oppWithLineMap.get(opp.Id).OpportunityLineItems) {
                        if (String.isNotBlank(oli.Opportunity_Line_Item_Type__c)) {
                            
                            if (oli.Opportunity_Line_Item_Type__c == 'New') {
                                newSrvLine = true;                              
                            } else if(oli.Opportunity_Line_Item_Type__c == 'Renewal') {                            
                                rnwSrvLine = true;
                            }
                            
                            if (newSrvLine && rnwSrvLine) {   
                                if(opp.Type !=  'Existing Customer - Mixed Service Offerings') {
                                    if(!isOppTypeChg) {
                                        opp.addError('You are adding both New and Renewal Service products to this opportunity, please update Opportunity type to "Existing Customer - Mixed Service Offerings."');
                                    } else {
                                        opp.addError('This opportunity contains both New and Renewal service products, please update the service product\'s Opportunity Line Item Types for (HWM, SWM and Managed Services) Lines to be either all New OR all Renewal if you wish to change the Opportunity Type from "Existing Customer - Mixed Service Offerings".');     
                                    }
                                }
                                
                                break;
                            }
                        }    
                    }
                }
            }
        }
    }
    
    public void valdChnlLclOffc(List<Opportunity> newOppList) {
        Set<String> chnlLclOffIds = new Set<String>();
        Set<String> custAccIds = new Set<String>();
        List<Opportunity> validOpps = new List<Opportunity>();
        Map<String, Set<String>> custvsPrtnAccIdMap = new Map<String, Set<String>>();
        
        for(Opportunity opp : newOppList)  {
            if(opp.Cpq__c && opp.Channel_Office__c != NULL && opp.AccountId != NULL 
               && (!System.Label.OppChnlOffcVld_ExcPrfl.contains(UserInfo.getProfileId()))) {
                   chnlLclOffIds.add(opp.Channel_Office__c);  
                   custAccIds.add(opp.AccountId);
                   validOpps.add(opp);
               }  
        }
        
        if(!validOpps.isEmpty()) {
            List<cdm_Account_Relationship__c> accRelLst = [SELECT Id, NAME, Account__c, Related_Account__c,Relationship_Type__c FROM cdm_Account_Relationship__c 
                                                           WHERE Account__c IN :custAccIds AND Related_Account__c IN :chnlLclOffIds 
                                                           AND ((Relationship_Type__c = 'End Customer - Partner' AND Related_Account_AccountType__c = 'PARTNER')
                                                                OR (Relationship_Type__c = 'Local Office - End Customer' AND Related_Account_AccountType__c = 'LOCAL OFFICE'))];
            
            Set<String> chnlAccIds;
            for (cdm_Account_Relationship__c rel : accRelLst) {
                chnlAccIds = custvsPrtnAccIdMap.get(rel.Account__c);
                if (chnlAccIds == null) {
                    chnlAccIds = new Set<String>();  
                    custvsPrtnAccIdMap.put(rel.Account__c, chnlAccIds);
                }
                chnlAccIds.add(rel.Related_Account__c);
            }
            
            for(Opportunity opp : validOpps)  {
                chnlAccIds = custvsPrtnAccIdMap.get(opp.AccountId); 
                
                if (chnlAccIds == NULL || (chnlAccIds != NULL &&  !chnlAccIds.contains(opp.Channel_Office__c))) {
                    opp.addError(System.Label.OppChnlOffcVldMsg);      
                }
            } 
        }
    }
    
     public static void OpportunityPlanOppSyncTrigger(List<Opportunity> newOppList, Map<Id,Id> delAltOppMap){
        Set<Id> accountIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        Map<Id,Schema.RecordTypeInfo> rtMapById = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
       
        for (Opportunity opp : newOppList) {
            string rtName = rtMapById.get(opp.recordtypeid).getName();
            if(rtName != 'Exclude from Funnel' && rtName != 'Indirect - Exclude from Funnel'){ 
                accountids.add(opp.accountid);
                oppIds.add(opp.id);
            } /*else {
                if(delAltOppMap == null ) delAltOppMap = new Map<Id,Id>();
                delAltOppMap.put(opp.Id, opp.AccountId);    
            }*/
        }
        
        if(delAltOppMap != null && !delAltOppMap.isEmpty()) {
            delete [SELECT Id 
                    FROM ALTF__Account_Opportunity__c where ALTF__Opportunity__c IN :delAltOppMap.keySet() 
                    AND ALTF__Account__c  IN :delAltOppMap.values()];
        }
        
        
        Date startDate = null;
        Date endDate = null;
        Set<Id> altfyPlanAccIds = new Set<Id>();
       
        for (ALTF__Account_PLan_Row__c row : [  
           select ALTF__Effective_Account_Id__c, altf__account_plan__r.altf__min_plan_start_date__c,  altf__account_plan__r.altf__max_plan_end_date__c
            from altf__account_plan_row__c 
            where altf__effective_account_id__c in :accountIds
        ])  {
            if (startDate == null || startDate > row.altf__account_plan__r.altf__min_plan_start_date__c) {
                startDate = row.altf__account_plan__r.altf__min_plan_start_date__c;
            }
            
            if (endDate == null || endDate < row.altf__account_plan__r.altf__max_plan_end_date__c) {
                endDate = row.altf__account_plan__r.altf__max_plan_end_date__c;
            }
            altfyPlanAccIds.add(row.altf__effective_account_id__c);
        }
        new SynchronisePlannedOpportunities().createAccountOpportunities(altfyPlanAccIds, startDate, endDate, oppIds);            
    
    /* }
     public void validateOppSchForOpportunity(Map<Id,Opportunity> NewOppMap ,Map<Id,Opportunity> OldOppMap){
        List<String> RevTypLst= new List<String>();
        Set<String> OppIds= new Set<String>();
        RevTypLst.add('SW');
        RevTypLst.add('HW');
       
        for(OpportunityLineItem Oli : [Select id,OpportunityId,Unscheduled_Quantity__c ,(Select id from OpportunityLineItemSchedules),Revenue_Type__c from OpportunityLineItem where Revenue_Type__c IN : RevTypLst and OpportunityId IN : NewOppMap.KeySet()]){
            if((Oli.OpportunityLineItemSchedules.size() == 0) || (Oli.Unscheduled_Quantity__c >0)){
                OppIds.add(Oli.OpportunityId);
               
            }
        }
        
        for(Opportunity opp : NewOppMap.values()) {
            
            if((opp.Forecast_Category__c=='Upside' || opp.Forecast_Category__c=='Commit') && (OppIds.contains(opp.Id))){
                opp.addError('Please schedule all HW and SW products on product scheduler. Unable to save opportunity in current forecast category until HW and SW quantities have been scheduled.');
            }
            
            else if((opp.IsClosed != OldOppMap.get(opp.Id).IsClosed) && (opp.StageName=='Closed/Booked')  && (OppIds.contains(opp.Id))){
                opp.addError('Please schedule all HW and SW products on product scheduler. Unable to save opportunity in current forecast category until HW and SW quantities have been scheduled.');
            }
        }*/
        
    }
     /*
####################################################################################################################
# Method Name : prvntClosingofOpp(OpportunityList) - EBA_SF-1538
# Created by................: Varsha                                                                     
# Created Date...........: 11-10-2021                                                                                                                                                                 
# Description...............:It will throw an error if a non-cpq opportunity is closing but it has related open demo request
####################################################################################################################
*/
    public void prvntClosingofOpp(List<Opportunity> oppL){
        Set<Id> oppIdS = new Set<Id>();
        for(DI_Demo_Request__c di : [Select Opportunity__c from DI_Demo_Request__c where opportunity__c in: oppL and IsClosed__c=false]){
            oppIdS.add(di.Opportunity__c);
        }
        if(!oppIdS.isEmpty()){
            for(Opportunity opp:oppL){
                //System.debug('demo req status'+opp.DI_Demo_Requests__r[0].status__c);
                if(oppIdS.contains(opp.Id)){
                    opp.addError(Label.Prev_Demo_Req);//Status of all Demo Requests on the Opportunity must be marked Completed or Cancelled/Closed before the Opportunity can be Closed.
                }
            }
        }
    }
    

    //updateProductCategory - Update opportunity.products__c to contain PricebookEntry.Name from the OLIs (max 255 characters), and product_category__c to contain Product2.PMDM Product Familiy (lowest level category) 
    public static void updateCATMProductRollup(Map<Id, Opportunity> oppNewMap, Boolean doContractTermAssignment) {
        if(oppNewMap.isEmpty()) return;
        List<Opportunity> oppDetails = [Select id, (Select pricebookentry.name, product2.pmdm_product_family__c, Number_of_Terms__c From OpportunityLineItems) From Opportunity Where Id in :oppNewMap.keySet()];
        for(Opportunity op: oppDetails) {
            Set<String> products = new Set<String>();
            Set<String> productCategories = new Set<String>();
            Integer oppTerm = 0; 
            for(OpportunityLineItem ol: op.OpportunityLineItems) {
                products.add(ol.pricebookentry.name);
                if (ol.product2.pmdm_product_family__c!=null){
                    productCategories.add(ol.product2.pmdm_product_family__c);
                }
                //stuti 2426
                /*if(ol.Number_of_Terms__c!=0) {
                    oppTerm = ol.Number_of_Terms__c != null ? Integer.valueOf(ol.Number_of_Terms__c) : 0;
                }*/
            }
            oppNewMap.get(op.Id).products__c = String.join(new List<String>(products), ', ').abbreviate(255);
            oppNewMap.get(op.Id).product_category__c = String.join(new List<String>(productCategories), ', ').abbreviate(255);
            //stuti 2426
            /*if(doContractTermAssignment && op.OpportunityLineItems != null && !op.OpportunityLineItems.isEmpty()) { 
            	oppNewMap.get(op.Id).Contract_Term_Mths__c = oppTerm; 
            }*/
        }
    }
}