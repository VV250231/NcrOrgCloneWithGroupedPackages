/****************************************************************************************************************
* Author        :  Dev Admin   
* Param         :  Lead  : All Lead Ecosystem Events    
* Return        :  Success  
* Description   :  Below All the method defind and when they would be executed
*Last Modified By: Stuti Srivastava : CSI-578 :CATM User seems to be able to create lead with duplicate email
* 9-Aug-2022	: EBA_SF-2213 Changes Industry, SAL and Stage
****************************************************************************************************************/
/* ######################################## start - Lead Ecosystem Changes #################################### */
public class LeadTriggerDispatcher extends TriggerHandlerBase{
    /**** CLASS LEVEL VARIABLES *****************************************************/
    private static LeadTriggerHandler ldHandler;
    private static map<string,LeadRegionCountryMapping__c> cSetting_ReigionMapping  = lead_Ecosystem_Changes.return_regionMapping() ; // get country to country_code to Region mapping from custom setting
    private static map<string,string> cSetting_Status_Stage_Mapping  = lead_Ecosystem_Changes.return_StatusStageMap() ; // get stage to status to SRT Description mapping from custom setting
    set<id> lead_marketing_qualified_lead_old = new set<id>();
    //private Map<String,String> industry_mapping = new Map<String,String>{'Financial'=>'FIN','Hospitality'=>'HOS','Telecom'=>'TEL','Retail'=>'RET','Payments & Network'=>'P&T'}; 
    private Map<String, List<String>> industry_mapping = NSCCommonInfoUtil.getDependentPicklistValues(Lead.Industry_Code__c);
        /************************       TRIGGER CORE OPERATIONS      *******************/  
        // before insert will fire only once for inserting records
        public override void beforeInsert() { 
            ldHandler = (ldHandler != null) ? ldHandler : new LeadTriggerHandler();
            LeadUtil lu = LeadUtil.getInstance();
            set<id> sdlUserIdSet=lu.getSDLQueueUser();
            set<id> UserSetForEMEA=lu.getEMEAUser();  
            set<string> storeAllEmail = new set<string>();
            set<string> duplicateEmails = new set<string>();
            List<Lead> leadList = new List<Lead>();
            List<Lead> partnerManagedLeads = new List<Lead>();
            List<Lead> pLeads = new List<Lead>();
            List<Lead> lList = new List<lead>();
            for (lead l:(List <lead>)trigger.new){
                 leadList.add(l); 
                // update the lead source value(standard) from custom lead source field, Runs for CATM Lead as well (CSI-463)
                if(!string.isBlank(l.LeadSource__c)){
                    l.LeadSource = l.LeadSource__c;
                }
                if( l.Email !=null && (l.Email.contains('@') || l.Email.Contains('.')) &&(!l.Email.Contains('@ncr.com') || !l.Email.Contains('@corp.ncr.com'))){
                    l.synctoMarketo__c =true;   
                }
                Id LeadId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get('HOSP_Restaurant').getRecordTypeId();
                if((l.RecordTypeId==LeadId)&&(l.LeadSource =='Sales-HOS-Restaurant Data'|| l.LeadSource =='Sales-HOS-Restaurant Data-Weekly' ||l.LeadSource =='Sales-HOS-CHD Data' ))
                   //|| (l.LeadSource__c =='Sales-HOS-Restaurant Data'|| l.LeadSource__c =='Sales-HOS-Restaurant Data-Weekly' ||l.LeadSource__c =='Sales-HOS-CHD Data' ))
                {
                    l.synctoMarketo__c =false;
                }

				
                //######EBA_SF-2213 start###
                //update the industry code value
                if(!string.isblank(l.Industry__c) && !industry_mapping.isEmpty() && industry_mapping.containsKey(l.Industry__c)){
                    List<String> indCodeLst = industry_mapping.get(l.Industry__c);
                    if(indCodeLst != null && indCodeLst.size() > 0) {
						 l.Industry_Code__c = indCodeLst.get(0);                        
                    }
                    //l.Industry_Code__c = industry_mapping.get(l.Industry__c);
                    l.Industry = l.Industry__c;
                }                
                if(l.Status=='Accepted'){
                    l.SAL_Trigger__c=true;
                    l.SAL_Date__c = system.now();
                }  
                // update the lead stage from lead status
                if(!string.isblank(l.status) && !cSetting_Status_Stage_Mapping.isEmpty() && cSetting_Status_Stage_Mapping.containsKey(l.status)){
                    l.Lead_Stage__c = cSetting_Status_Stage_Mapping.get(l.Status);
                }
                //######EBA_SF-2213 End###
               //CATM changes
                if(!CheckforCATMleads(l)){
                if(l.Status =='Open' && l.INQ_Trigger_Date__c==null && l.SAL_Date__c==null){
                    l.INQ_Trigger_Date__c = System.Now();
                    l.INQ_Trigger__c =true;
                }
                
                if(l.Country__c==LeadTriggerVariableClass.uState && l.Industry__c == LeadTriggerVariableClass.Hosp && l.Status ==LeadTriggerVariableClass.pManaged){
                    pLeads.add(l);
                }
               
                
                if(l.Country__c==LeadTriggerVariableClass.uState && l.Industry__c == LeadTriggerVariableClass.Hosp){
                    partnerManagedLeads.add(l);
                }                
                // update the dependent countryCode from country for Salesforce User and Country from countryCode for Lenos/Eloqua User (sk250817)
                if(l.Country__c != null ){ // this logic is for Salesforce users
                    l.Country_Code__c = ldhandler.updateCountryDependecy(l.Country__c,cSetting_ReigionMapping);
                    l.Region__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c);
                    l.Region_Ecosystem__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c); 
                    l.Country = l.Country__c;
                }
                else if(l.Country_Code__c != null ){ // this logic is for Lenos and Eloqua users
                    l.Country__c =  ldhandler.updateCountryDependecy(l.Country_Code__c,cSetting_ReigionMapping);
                    l.Region__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c);
                    l.Region_Ecosystem__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c);
                    l.Country = ldhandler.updateCountryDependecy(l.Country_Code__c,cSetting_ReigionMapping);
                }
                
                lList.add(l);
            }
                if(!string.isblank(l.Email)){
                    storeAllEmail.add(l.Email);  
                } 
            }
            // below logic will assign all leads with email containing NCR domain to Eloqua Marketing
            //CATM changes
            List<Lead> nCATMlst = new List<Lead>(); 
            for(Lead l :(List<lead>)trigger.new){
                if(!CheckforCATMleads(l)){
                    nCATMlst.add(l);
                }
            }
            //CATM changes
            if(!nCATMlst.isempty()){
            	Lead_Ecosystem_Changes.auto_assign_Lead_to_EloquaMarketing(nCATMlst);
                if(Lead_Recursion_Validate.isFirstTime){
                    ldhandler.gdpr_update(nCATMlst);
                }
            }
            if(!lList.isEmpty())
                ldHandler.leadOwnerAssignDateInsert(lList, UserSetForEMEA);
            
            if(!leadList.isEmpty())
                ldHandler.addEmailDomain(leadList);
            if(!partnerManagedLeads.isEmpty())
                Lead_Ecosystem_Changes.getPostalCode(partnerManagedLeads);
            if(storeAllEmail.size() > 0){
                for(Lead l : [Select id,Email from Lead where Email IN:storeAllEmail limit 50000]){
                    duplicateEmails.add(l.Email); 
                    lead_marketing_qualified_lead_old.add(l.id);
                }
                for(Contact l : [Select id,email from contact where email IN:storeAllEmail limit 50000]){
                    duplicateEmails.add(l.Email); 
                }
            }
            if(duplicateEmails.size()>0){
                //CATM changes
                //if(!leadLst.isempty()){ //Stuti No Lead Duplicate CSI-578
                	Lead_Ecosystem_Changes.validate_duplicate_Lead((List <lead>)trigger.new,duplicateEmails);
                //}
            }
            
            if(!pLeads.isEmpty())
                ldHandler.switchToPartnerManagedLead(pLeads);
        }
    // after insert will fire only once for after records inserted
    public override void afterInsert() {
        ldHandler = (ldHandler != null) ? ldHandler : new LeadTriggerHandler();
       // LeadCamapignClass.addCampaignBasedOnLeadSource((List <lead>)trigger.new);
        //CATM changes
            List<Lead> nCATMlst = new List<Lead>();
            for(Lead l :(List<lead>)trigger.new){
                if(!CheckforCATMleads(l)){
                    nCATMlst.add(l);
                }
            }
        if(!nCATMlst.isEmpty()){
        	LeadCamapignClass.addCampaignBasedOnLeadSource(nCATMlst);
        }
        // list to hold Ids of leads for running Assignment Rule
        List<String> leadIds = new List<String>();
        List<Lead>campaignLeadList = new List<Lead>();
        List<CampaignMember> campaignMembers= new List<CampaignMember>();
        List<Lead> partnerManagedLeads = new List<lead>();
        String MarketoProfile = System.Label.Lead_Marketo_Profile;
        Id marketoProfileId=    NSCCommonInfoUtil.getInstance().getProfileId(MarketoProfile);
        //    Id lenosProfileId=    NSCCommonInfoUtil.getInstance().getProfileId('Lenos Administration');
        List<LeadShare> lead_share = new List<LeadShare>();
        for (lead l:(List <lead>)trigger.new){
            //CATM Changes
            if(!CheckforCATMleads(l)){
            //Give access to Creater of lead
            LeadShare lshare = new LeadShare();
            lshare.LeadId = l.Id ;
            lshare.UserOrGroupId =UserInfo.getUserID() ;
            lshare.LeadAccessLevel = 'read';
            lshare.RowCause = 'Manual';
            lead_share.add(lshare);
            campaignLeadList.add(l);
            // populate list where Assignment rule need to be run, using CommonUtils
            //// if(( (UserInfo.getProfileId() == eloquaProfileId && l.Industry__c != 'Hospitality' ) || (UserInfo.getProfileId() == lenosProfileId && l.Industry__c != 'Hospitality' )  ) ||
            //l.Run_Rule__c)
            if((UserInfo.getProfileId() == marketoProfileId &&  l.Run_Rule__c )  || l.Run_Rule__c){ 
                leadIds.add(l.Id); 
            }
            /* ######################################## end - Lead Ecosystem Changes #################################### */
            //Create Campaign member for live chat Leads
            if (! String.isBlank(l.Sys_Campaign_Id__c)){
                campaignMembers.add(new CampaignMember(CampaignId = l.Sys_Campaign_Id__c,LeadId = l.Id, Status = 'Not Started'));
            }
            if(l.Country__c=='UNITED STATES' && l.Industry__c =='Hospitality' && l.PostalCode!=null){
                partnerManagedLeads.add(l);
            }
        }
        if(partnerManagedLeads.size()>0 ){
            ldHandler.partnerManagedLead(partnerManagedLeads); 
        }
        // Calling method to run Assignment rule 
        if(leadIds.size()>0) {
            DMLOptions.performAssignmentRule(leadIds);
        }
        //insert Campaign members Live chat
        if (campaignMembers.size() > 0){
            insert campaignMembers;
        }
        /* ######################################## start - Lead Ecosystem Changes #################################### */
        //insert to give access
        if(lead_share.size()>0){
            Database.SaveResult[] leadshare_insert = Database.insert(lead_share,false);
        }
        // submit all old lead duplicate leads
        if(lead_marketing_qualified_lead_old.size()>0 ){
            Lead_Trigger_Future_method.updatelead(lead_marketing_qualified_lead_old); 
        }
        // if(campaignLeadList.size() > 0) {
        //     ldHandler.return_campaignData(campaignLeadList);
        /*if(LeadCamapignClass.isFirst){

LeadCamapignClass.addCampaignBasedOnLeadSource((List <lead>)trigger.new);
LeadCamapignClass.isFirst =false;  
//  }
}*/
    }
    }
    // before Update will fire only once for updated records
    public override void beforeUpdate() {
        ldHandler = (ldHandler != null) ? ldHandler : new LeadTriggerHandler();
        // fetching member of Namer Queue "UpdateStage Trigger"
        LeadUtil lu=LeadUtil.getInstance();
        set<id> sdlUserIdSet=lu.getSDLQueueUser();
        set<id> UserSetForEMEA=lu.getEMEAUser();
        set<id> namerQueueUserSet = lu.getNamerQueueUser();
        List <lead> pLeads=new List <lead>();
        List<Lead> lList = new List<Lead>();
        
        
        Map<Id,User> mauriceUserMap=new Map<Id,User>();       
        for(User userobj : [Select id,name,Email,managerid from User where manager.Name='Maurice Settles']){
            mauriceUserMap.put(userobj.id,userobj);
        }
        for (lead l:(List <lead>)trigger.new){
            //update the lead source value(standard) from custom lead source field, This should run for CATM Leads as well(CSI-463)
            if(l.LeadSource__c != ((Map<id,lead>)trigger.oldmap).get(l.id).LeadSource__c &&  !string.isBlank(l.LeadSource__c)){
                l.LeadSource = l.LeadSource__c;
            }
            if( l.Email !=null && (l.Email.contains('@') || l.Email.Contains('.')) &&(!l.Email.Contains('@ncr.com') || !l.Email.Contains('@corp.ncr.com'))){
                l.synctoMarketo__c =true;   
            }
           // if((l.LeadSource!= ((Map<id,lead>)trigger.oldmap).get(l.id).LeadSource) || 
              // (l.LeadSource__c != ((Map<id,lead>)trigger.oldmap).get(l.id).LeadSource__c &&  !string.isBlank(l.LeadSource__c))&&
              Id LeadId = Schema.SObjectType.lead.getRecordTypeInfosByDeveloperName().get('HOSP_Restaurant').getRecordTypeId();
                if((l.RecordTypeId==LeadId)&&(l.LeadSource =='Sales-HOS-Restaurant Data'|| l.LeadSource =='Sales-HOS-Restaurant Data-Weekly' ||l.LeadSource =='Sales-HOS-CHD Data' ))
                   //|| (l.LeadSource__c =='Sales-HOS-Restaurant Data'|| l.LeadSource__c =='Sales-HOS-Restaurant Data-Weekly' ||l.LeadSource__c =='Sales-HOS-CHD Data' ))
                {
                    l.synctoMarketo__c =false;
                }
            //######EBA_SF-2213 start###
            //update the industry code value
            if(l.Industry__c!= ((Map<id,lead>)trigger.oldmap).get(l.id).Industry__c && !string.isblank(l.Industry__c) && !industry_mapping.isEmpty() && industry_mapping.containsKey(l.Industry__c)){
                List<String> indCodeLst = industry_mapping.get(l.Industry__c);
                if (indCodeLst != null && indCodeLst.size() > 0) {
                    l.Industry_Code__c = indCodeLst.get(0);                        
                }                   
                //l.Industry_Code__c = industry_mapping.get(l.Industry__c);
                l.Industry = l.Industry__c;
            }
            if(((Map <Id,lead>)trigger.oldmap).get(l.id).Status != l.Status) {
                if(l.Status=='Accepted'){
                    l.SAL_Trigger__c=true;
                }
            }
            //update the lead stage from lead status
            if(l.status != ((Map<id,lead>)trigger.oldmap).get(l.id).status && !string.isblank(l.status) && !cSetting_Status_Stage_Mapping.isEmpty() && cSetting_Status_Stage_Mapping.containsKey(l.status)){
                l.Lead_Stage__c = cSetting_Status_Stage_Mapping.get(l.Status);
            }
            //######EBA_SF-2213 END###
            //CATM
            if(!CheckforCATMleads(l)){
            
            if(l.Status =='Open' && l.INQ_Trigger_Date__c==null && l.SAL_Date__c==null){
                l.INQ_Trigger_Date__c = System.Now();
                l.INQ_Trigger__c =true;
            }
            
            if(((Map <Id,lead>)trigger.oldmap).get(l.id).Status != l.Status) {              
                if(l.Country__c==LeadTriggerVariableClass.uState && l.Industry__c == LeadTriggerVariableClass.Hosp && l.Status ==LeadTriggerVariableClass.pManaged){
                    System.debug('@@@@@'+l);
                    pLeads.add(l);
                }
            }        
            // update the dependent countryCode from country for Salesforce User and Country from countryCode for Lenos/Eloqua User (sk250817)
            if( l.Country__c != ((Map <Id,lead>)trigger.oldmap).get(l.id).Country__c ){ // this logic is for Salesforce users
                l.Country_Code__c = ldhandler.updateCountryDependecy(l.Country__c,cSetting_ReigionMapping);
                l.Region__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c);
                l.Region_Ecosystem__c = ldhandler.updateRegionDependecy(l.Country__c,cSetting_ReigionMapping,l.Industry__c);
            }
            else if(l.Country_Code__c != ((Map <Id,lead>)trigger.oldmap).get(l.id).Country_Code__c ){ // this logic is for Lenos and Eloqua users
                l.Country__c =  ldhandler.updateCountryDependecy(l.Country_Code__c,cSetting_ReigionMapping);
                l.Region__c = ldhandler.updateRegionDependecy(l.Country_Code__c,cSetting_ReigionMapping,l.Industry__c);
                l.Region_Ecosystem__c = ldhandler.updateRegionDependecy(l.Country_Code__c,cSetting_ReigionMapping,l.Industry__c);
            }
            //NAMER Queue logic as per "UpdateStage trigger" 
            if(l.Status != ((Map <Id,lead>)trigger.oldmap).get(l.id).Status ){
                l.TestCheckBox__c = True;
            }
            Integer ts=Integer.valueOf(system.now().getTime()-l.CreatedDate.getTime())/1000;
            if(namerQueueUserSet.contains(((Map <Id,lead>)trigger.oldmap).get(l.id).OwnerId) && l.OwnerId != ((Map <Id,lead>)trigger.oldmap).get(l.id).OwnerId && ts>10){
                l.Reassign_Date__c = System.now();
                l.TestCheckBox__c = False;               
            } 
            // SDL Group notification logic            
            //       ldHandler.updateNamercheckbox(l, ((Map <Id,lead>)trigger.oldmap).get(l.id), sdlUserIdSet, false);
            lList.add(l);
            
        }
        }
        if(!lList.isEmpty()){
            ldHandler.leadOwnerAssignDate(lList, UserSetForEMEA); 
            ldHandler.sdlOtherProcessing(lList, mauriceUserMap);
        }
        /* ######################################## start - Lead Ecosystem Changes #################################### */
        if(Lead_Recursion_Validate.isFirstTime){
            Lead_Recursion_Validate.isFirstTime = false;
            //CATM
            //CATM changes
            List<Lead> nCATMlst = new List<Lead>();
            for(Lead l :(List<lead>)trigger.new){
                if(!CheckforCATMleads(l)){
                    nCATMlst.add(l);
                }
            }
            if(!nCATMlst.isEmpty()){
            ldhandler.gdpr_update(nCATMlst);
            
            // validate if industry / country / sub-industry can be modified or not.
            Lead_Ecosystem_Changes.validate_accessibility(nCATMlst,trigger.oldmap);   
            
            
            
        }
            
            List<Lead> leadList = new List<Lead>();
            for(Lead l : (List<lead>)trigger.new){
                if(l.Email != ((Map<id,lead>)trigger.oldmap).get(l.id).Email || l.Status != ((Map<id,lead>)trigger.oldmap).get(l.id).Status){
                    leadList.add(l); 
                }
            }
            if(!leadList.isEmpty())
                ldHandler.addEmailDomain(leadList);
        }
        
        if(!pLeads.isEmpty()){
            System.debug('@@@@@'+pLeads);
            Lead_Ecosystem_Changes.getPostalCode(pLeads);        
            ldHandler.switchToPartnerManagedLead(pLeads);
            
        }
    }
    // before Update will fire only once for updated records
    public override void afterUpdate() {
        ldHandler = (ldHandler != null) ? ldHandler : new LeadTriggerHandler();
        // Bank_Holding_Company_Number__c logic: trigger "PopulateConvertedAccountParent"
        Set<Id> convertedAccountIds = new Set<Id>();
        Set<String> bhcNumSet = new Set<String>();  
        List<Opportunity> converted_OppList = new List<Opportunity>(); // store all opportunities converted from lead
        Set<Id> set_OppId = new Set<Id>(); // store all converted opportunities id converted from lead
        Map<id,string> toUpdate_Opp = new Map<id,string>(); // store all converted Opportunities id with lead to update the Opportunities
        List<Contact> converted_ConList = new List<Contact>(); // store all contact converted from lead
        Set<Id> set_ConId = new Set<Id>(); // store all converted contact id converted from lead
        Map<id,lead> toUpdate_Con = new Map<id,lead>(); // store all converted contact id with lead to update the Contacts
        Set<String> setCampaignCode =new Set<String>();
        Map<id,String> Map_Opp_Camapaign= new Map<id,String>();
        Map<id,Boolean> Map_Opp_Referral = new Map<id,Boolean>();
        CampaignMember campID = new CampaignMember();
        //CATM changes
            List<Lead> nCATMlst = new List<Lead>();
            for(Lead l :(List<lead>)trigger.new){
                if(!CheckforCATMleads(l)){
                    nCATMlst.add(l);
                }
            }
            
       // List<Lead> lList = (List <lead>)trigger.new;
        
        List<lead> pMLeads = new List<Lead>();
        
        Lead leadId=((List <lead>)trigger.new)[0];
        //CATM
        if(!CheckforCATMleads(leadId)){
        if(leadId.ConvertedContactId!=null)
            for(CampaignMember cam: [Select Id, CampaignId, LeadId, ContactId from CampaignMember where LeadId =: leadId.ID OR ContactID =:leadId.ConvertedContactId ORDER BY SystemModstamp DESC LIMIT 1]){
            //campId=[Select Id, CampaignId, LeadId, ContactId from CampaignMember where LeadId =: leadId.ID OR ContactID =:leadId.ConvertedContactId ORDER BY SystemModstamp DESC LIMIT 1];
            	campId=cam;    
            }
        }
        for (lead l:(List <lead>)trigger.new){
            if(!CheckforCATMleads(l)){
            // populating set for update Parent on Account
            if (((Map <Id,lead>)trigger.oldmap).get(l.id).isConverted == false && l.isConverted == true && String.isNotEmpty(l.Bank_Holding_Company_Number__c) && l.FI_Type__c != 'Holding Company') {
                if (l.ConvertedAccountId != null) {
                    convertedAccountIds.add(l.ConvertedAccountId);   
                    bhcNumSet.add(l.Bank_Holding_Company_Number__c);
                }
            }
            // below code will get all converted lead contacts and opportunities 
            if (((Map <Id,lead>)trigger.oldmap).get(l.id).isConverted == false && l.isConverted == true ){
                if(!string.isEmpty(l.ConvertedContactId)){ // store all converted contact id's
                    set_ConId.add(l.ConvertedContactId);
                    toUpdate_Con.put(l.ConvertedContactId,l);
                }
                if(!string.isEmpty(l.ConvertedOpportunityId)){ // store all converted opportunities id's
                    if(campID!=null){
                        Map_Opp_Camapaign.put(l.ConvertedOpportunityId,campID.campaignID);  
                    }
                    /*if(l.Referral_Source__c != null)
                        Map_Opp_Camapaign.put(l.ConvertedOpportunityId,l.Referral_Source__c);*/
                    toUpdate_Opp.put(l.ConvertedOpportunityId,l.Offer_Description__c);
                    if(l.Referral_Source__c!=null){
                        Map_Opp_Referral.put(l.ConvertedOpportunityId,true);
                    }
                }
            }
                //CATM
            }
        }
        // populating Common List of accounts that can be used to make single DML statement on accounts
        List <Account> updateParent=ldHandler.populateAccountParentForUpdate(convertedAccountIds, bhcNumSet);        
        // at last make a update calls on all account updated with parent id.     
        update updateParent;
        if(Map_Opp_Camapaign.size()>0){
            if(LeadTriggerHandler.isTrue==True){
                LeadTriggerHandler.isTrue=False;
                ldHandler.return_convertedOpportunities(Map_Opp_Camapaign,toUpdate_Opp,Map_Opp_Referral) ;
            }
        }
        if(set_ConId.size()>0){
            ldHandler.return_convertedContacts(set_ConId, toUpdate_Con) ;
        }
        List<Lead>campaignLeadList = new List<Lead>();
        for (lead l:(List <lead>)trigger.new){
            //CATM Changes
            if(!CheckforCATMleads(l)){
            if (((Map <Id,lead>)trigger.oldmap).get(l.id).LeadSource__c != l.LeadSource__c) {
                if(l.LeadSource__c==LeadTriggerVariableClass.LeadSourceValue || l.LeadSource__c==LeadTriggerVariableClass.LeadSourceValue_Sales)
                    campaignLeadList.add(l);
            }
            if(((Map <Id,lead>)trigger.oldmap).get(l.id).PostalCode != l.PostalCode) { // Replace Status with PostalCode

                if(l.Country__c==LeadTriggerVariableClass.uState && l.Industry__c == LeadTriggerVariableClass.Hosp && l.PostalCode!=null){ // Removed this  - && l.Status ==LeadTriggerVariableClass.pManaged
                    if(Lead_Ecosystem_Changes.isFirst){
                        Lead_Ecosystem_Changes.isfirst = false;
                        pMLeads.add(l);
                    }
                }
            }
                //CATM
            }
        }
        if(!pMLeads.isEmpty()){
            ldHandler.partnerManagedLead(pMLeads);
        }
        if(campaignLeadList.size() > 0) {
            if(LeadCamapignClass.isFirst){
                LeadCamapignClass.updateAddCampaignBasedOnLeadSource(campaignLeadList);
                LeadCamapignClass.isFirst = false;   
            }
        }
        if(LeadTriggerHandler.isTrue){
            LeadTriggerHandler.isTrue =false;
            //CATM changes
            if(!nCATMlst.isempty()){
            	LeadTriggerHandler.populateCamMemStatus(nCATMlst);
            }
        }
    }
    
    /* ######################################## end - Lead Ecosystem Changes #################################### */
//CATM changes
    public static boolean CheckforCATMleads(Lead l){
        boolean b = false;
        b= l.CATM_Record__c;
        /*if(label.CATM_Skip_lead_Records.split(',').contains(l.LeadSource__c)){
             b = true;
        }*/
        return b; 
    }
}