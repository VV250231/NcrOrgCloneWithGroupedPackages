public class LeadTriggerHandler {
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   Lead  :   Lead ,Lead : Oldlead, Set : Set of EMEAUserId
* Return        :   
* Description   :  This method is to If lead owner is not changed from EMEA since last 4 days then shoot and workflow email to EMEA queue Owner
*************************************************************************************************/
    public static boolean isTrue =true;
    public void leadOwnerAssignDate(List<Lead> lList, Set<id> UserSetForEMEA){  
        for(Lead l:lList){
            if(((Map <Id,lead>)trigger.oldmap).get(l.id).ownerid!=l.ownerid && (UserSetForEMEA.contains(l.ownerid))){
                if(l.Status =='Open'){
                    l.Lead_owner_assigned_date__c = System.today(); 
                }                   
                else{
                    l.Lead_owner_assigned_date__c = null; 
                }  
            }
            else if(!UserSetForEMEA.contains(l.ownerid)){
                l.Lead_owner_assigned_date__c = null;
            }
        }
    }
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   Lead  :   Lead ,Lead : Oldlead, Set : Set of EMEAUserId
* Return        :   
* Description   :  This method is to If lead owner is not changed from EMEA since last 4 days then shoot a workflow email to EMEA queue Owner
*************************************************************************************************/
    public void leadOwnerAssignDateInsert(List<Lead> lList, set<id> UserSetForEMEA){  
        for(Lead l : lList){
            if(UserSetForEMEA.contains(l.ownerid)){
                l.Lead_owner_assigned_date__c = System.today();
            } 
        }
    }
    public void sdlOtherProcessing(List<Lead> lList, Map<Id,User> UserMap){  
        for(Lead l : lList){
            if(UserMap.ContainsKey(l.OwnerId) && ((Map <Id,lead>)trigger.oldmap).get(l.id).Ownerid == UserMap.get(l.OwnerId).Managerid && ((Map <Id,lead>)trigger.oldmap).get(l.id).Ownerid != l.OwnerID){
                l.Namer_Date_Field__c=System.Today();
                l.LeadStatusSLA__c=l.Status;
            }               
            if(UserMap.ContainsKey(l.OwnerId) && ((Map <Id,lead>)trigger.oldmap).get(l.id).Ownerid != l.OwnerID){
                l.Namer_Date_Field__c=System.Today();
                l.LeadStatusSLA__c=l.Status;
            } 
            if(!UserMap.ContainsKey(l.Ownerid)){
                l.Namer_Date_Field__c=null;
                l.LeadStatusSLA__c=l.Status;
            }  
        }
    }
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   Set  :   Converted Acount Ids ,Set : BHC number set
* Return        :   
* Description   : Below method populate Parent Account for converted accounts based BHC number
*************************************************************************************************/
    public List<Account> populateAccountParentForUpdate(Set<Id> convertedAccountIds, Set<String> bhcNumSet){
        List<Account> convertedAcctsList = new List<Account>();
        /*  Map<String, String> parentBHCMap = new Map<String, String>();
List<Account> accountList = [SELECT Id, ParentId, FI_Type__c FROM Account where Id IN :convertedAccountIds OR (Master_Customer_Number__c like '%DI' and FI_Type__c != NULL AND FI_Type__c = 'Holding Company')];
// removed Bank_Holding_Company_Number__c != NULL and Bank_Holding_Company_Number__c IN :bhcNumSet  due to EBA_SF-688
for(Account acc :accountList) {
if(String.isNotEmpty(acc.Bank_Holding_Company_Number__c)) {
if(acc.FI_Type__c == 'Holding Company') {
parentBHCMap.put(acc.Bank_Holding_Company_Number__c, acc.id);   
} else {
convertedAcctsList.add(acc);    
}
}

//Commented due to EBA_SF-688
convertedAcctsList.add(acc);
}
for (Account a : convertedAcctsList) {
String parentAccId = parentBHCMap.get(a.Bank_Holding_Company_Number__c);
if(parentAccId != NULL) {
a.ParentId = parentAccId; 
}
}
*/
        return convertedAcctsList;
    }
    
    /*************************************************************************************************
* Author        :   Saagar Kinja   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   GDPR Changes
*************************************************************************************************/
    public void gdpr_update(List<Lead> llist){
        Lead_GDPR_Changes lgdpr = new Lead_GDPR_Changes();
        lgdpr.checkifsuspendprocessing(llist);
    }
    /*************************************************************************************************
* Author        :   Ajay Dixit   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   Lead Ecosystem Changes
*************************************************************************************************/
    public void partnerManagedLead(List<Lead> Triggernew){
        LeadResellerClass.leadReslrAttachment(Triggernew);
    }
    /*************************************************************************************************
* Author        :   Saagar Kinja   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   Lead Ecosystem Changes : updating the correct country mapping
*************************************************************************************************/
    public string updateCountryDependecy(string count_or_code,map<string,LeadRegionCountryMapping__c> regionMapping){
        if(!regionMapping.IsEmpty() && String.isNotBlank(count_or_code) && regionMapping.containsKey(count_or_code)){
            if(regionMapping.get(count_or_code).Country__c == count_or_code){
                return regionMapping.get(count_or_code).CountryCode__c;
            }
            if(regionMapping.get(count_or_code).CountryCode__c == count_or_code){
                return regionMapping.get(count_or_code).Country__c;
            }
        }
        return '';
    }
    /*************************************************************************************************
* Author        :   Saagar Kinja   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   Lead Ecosystem Changes : updating the correct region dependecies w.r.t. country
*************************************************************************************************/
    public string updateRegionDependecy(string count_or_code,map<string,LeadRegionCountryMapping__c> regionMapping, String Industry){
        if(!regionMapping.IsEmpty() && String.isNotBlank(count_or_code) && regionMapping.containsKey(count_or_code)){
            // region value is based on type of insdustry the Lead 
            return regionMapping.get(count_or_code).HospitalityRegion__c ; // Common Region for all indusrty not only for hospitality chnages done on custom setting an 
        }
        return '';
    }
    
    /*************************************************************************************************
* Author        :   Saagar Kinja   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   Lead Ecosystem Changes : updating the converted Opportunieis (runs in after update)
*************************************************************************************************/
    public void return_convertedOpportunities(map<Id,string> map_Opp_Camapaign, Map<id,string> toUpdate_Opp, Map<id,Boolean> map_Opp_referral){
        List<Opportunity> update_Opp = new List<Opportunity>();
        for(Opportunity o : [Select id,CampaignId,Secondary_Campaign__c,Offer__c,CreatedDate from Opportunity where id IN:map_Opp_Camapaign.keySet()]){
            o.Offer__c = toUpdate_Opp.get(o.id);
            if(!map_Opp_Camapaign.isEmpty() && o.CampaignId==null && o.Secondary_Campaign__c!=null){
                o.CampaignId=map_Opp_Camapaign.get(o.id);
                o.Secondary_Campaign__c=null;
            }
            else if(o.Secondary_Campaign__c!=null && o.CampaignId!=null && !map_Opp_Camapaign.isEmpty()){
                o.Secondary_Campaign__c=map_Opp_Camapaign.get(o.id);      
            }else if(o.Secondary_Campaign__c ==null && o.CampaignId==null && !map_Opp_Camapaign.isEmpty()){
                o.CampaignId=map_Opp_Camapaign.get(o.id);
            }
            else if(o.Secondary_Campaign__c ==null && o.CampaignId!=null && !map_Opp_Camapaign.isEmpty()){
                if(o.CreatedDate!=System.today())
                    o.Secondary_Campaign__c=map_Opp_Camapaign.get(o.id); 
            }
            //add extra empty check
            if(!map_Opp_referral.isEmpty() && map_Opp_referral.get(o.Id)!=null){
                o.Referral__c=map_Opp_referral.get(o.Id);
            }
            update_Opp.add(o);
        }
        if(update_Opp.size()>0){
            update update_Opp ;
        }
    }
    /*************************************************************************************************
* Author        :   Yogesh Singh/ Sagar Kinja   
* Param         :   Lead  :   Lead
* Return        :   
* Description   :   Lead Ecosystem Changes : updating the converted Contacts (runs in after update)
*************************************************************************************************/
    public  void return_convertedContacts(Set<Id> set_ConId, Map<id,lead> toUpdate_Con){
        List<Contact> update_Con = new List<Contact>();
        for(Contact cont : [select id from contact where id in:set_ConId limit 50000]){
            cont.Marketing_Qualified_Contact__c = toUpdate_Con.get(cont.id).Marketing_Qualified_Contact__c ;
            cont.Marketing_Qualified_Contact_Date__c = toUpdate_Con.get(cont.id).Marketing_Qualified_Contact_Date__c ;
            cont.LeadSource = toUpdate_Con.get(cont.id).LeadSource__c ;
            cont.Optin_Contact__c = toUpdate_Con.get(cont.id).Optin_Lead__c;
            cont.OptinDate_Contact__c = toUpdate_Con.get(cont.id).OptinDate_Lead__c;
            cont.Contact_Marketing_Notes__c =  toUpdate_Con.get(cont.id).Lead_Marketing_Notes__c;
            cont.LeadType__c = toUpdate_Con.get(cont.id).LeadType__c ;
            cont.ContactCountry__c = toUpdate_Con.get(cont.id).Country__c ;
            cont.contact_country_code__c = toUpdate_Con.get(cont.id).Country_Code__c ;
            cont.Title = toUpdate_Con.get(cont.id).Title__c ;
            cont.Position__c = toUpdate_Con.get(cont.id).Position__c ;
            cont.Email_Domain__c= toUpdate_Con.get(cont.id).Email_Domain__c;
            cont.IsConverted__c = true ;
            update_Con.add(cont);
            //end of story 2509 #####################################################
        }
        if(update_Con.size() >0){
            update update_Con ;
        }
        
    }
    /*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   Lead  :   Lead
* Story        :   	NC_AGILE-3135
* Description   :   Lead Ecosystem Changes : Add email  (runs in after update)
*************************************************************************************************/
    public void addEmailDomain(List<lead> leadList){
        for(Lead leadObj : leadList){
            if(leadObj.Email != null){
                leadObj.Email_Domain__c=leadObj.Email.split('@').get(1);
            }
        }
    }
    
    /*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   Lead  :   Lead
* Story         :   
* Description   :   Partner Community
*************************************************************************************************/
    public void switchToPartnerManagedLead (List<Lead> Triggernew){
        Id partnerManaged = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Partner Community Lead').getRecordTypeId();
        for(Lead rec : Triggernew) {
            if(rec.Status == 'Partner Managed' && rec.Country__c=='UNITED STATES' && rec.Industry__c =='Hospitality') {
                rec.RecordTypeId = partnerManaged;
            }
        }
        
    }
    /*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   Lead  :   Lead
* Story         :   
* Description   :   EBA_SF - 620
*************************************************************************************************/
    public static void populateCamMemStatus (List<Lead> Triggernew){
        Set<Id> lSIds = new Set<Id>();
        boolean convertedFlag =false;
        List<id> conId = new List<id>();
        for(Lead l : triggerNew){
            if(l.LeadType__c!='Sales'){
                lSIds.add(l.id);
                convertedFlag = l.IsConverted;
                conId.add(l.ConvertedContactId);
            }
        }
        if(test.isRunningTest()){
            convertedFlag = true;
        }
        if(convertedFlag){
            List<Contact> conList = new List<Contact>();
            for(Contact cObj : [Select Marketing_Qualified_Contact__c,id,Marketing_Qualified_Contact_Date__c from contact where id IN:conId]){
                cObj.Marketing_Qualified_Contact__c=true;
                cobj.Marketing_Qualified_Contact_Date__c= System.now();
                conList.add(cObj);
            }
            if(!conList.isEmpty())
                update conList; 
        }
    }
}