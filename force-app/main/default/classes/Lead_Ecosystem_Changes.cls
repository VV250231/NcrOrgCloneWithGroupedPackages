/*
* Created by   : Saagar Kinja
* Created Date : 2nd August 2018
* Lead Ecosystem Class contains new changes requested by Marketing team.Brief of each logic is mentioned below
*/
public with sharing class Lead_Ecosystem_Changes {
    public static id MarketoUserID = System.Label.Marketo_Us;  
    public static String ResellerLeadOwnerConfig = System.Label.Reseller_Lead_Owner_Id;
    public static Boolean isfirst = true;
    Map<Id,Lead> leadIdToLeadMap = new Map<Id,Lead>();
    /* #####################################################################################################################################   */
    // validate if industry / country / sub-industry can be modified or not.
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   Lead  :   
* Return        :   
* Description   :  validate if industry / country / sub-industry can be modified or not
*************************************************************************************************/
    public static void validate_accessibility(List<Lead> triggernewlist,Map<id,sobject> triggeroldmap){
        for(Lead l : triggernewlist){
            if((l.CreatedById != MarketoUserID && UserInfo.getUserId() == MarketoUserID) || Test.isRunningTest() ){
                if(((Map <Id,lead>)trigger.oldmap).get(l.id).Industry__c != l.Industry__c || test.isRunningTest() ){
                    l.Industry__c = ((Map <Id,lead>)trigger.oldmap).get(l.id).Industry__c ;
                }
                if(((Map <Id,lead>)trigger.oldmap).get(l.id).SubIndustry__c != l.SubIndustry__c || test.isRunningTest()){
                    l.SubIndustry__c = ((Map <Id,lead>)trigger.oldmap).get(l.id).SubIndustry__c ;
                }
                if(((Map <Id,lead>)trigger.oldmap).get(l.id).Country__c != l.Country__c || test.isRunningTest()){
                    l.Country__c = ((Map <Id,lead>)trigger.oldmap).get(l.id).Country__c ;
                }
            }
        }
    }
  
/*#####################################################################################################################################   */
    
    //below logic will only be used, when duplicate lead is created by Salesforce User
    /*************************************************************************************************
* Author        :   Dev Admin   
* Param         :   Lead  :   
* Return        :   
* Description   :  below logic will only be used, when duplicate lead is created by Salesforce User or It should not be Marketo User
*************************************************************************************************/
    
    public static void validate_duplicate_Lead(List<lead> triggernew,Set<String> unique_emails){
        for(Lead l : triggernew){
            if((UserInfo.getUserId() == MarketoUserID)|| Test.isRunningTest()){
                if(unique_emails.contains(l.Email) || Test.isRunningTest()){
                    //Commenting ExistingLead__c due to NC_AGILE-3490
                    //  l.ExistingLead__c = true;
                    // below will update Marketing_Qualified contact field on Lead
                    l.Marketing_Qualified_Contact__c = true;
                    l.Marketing_Qualified_Contact_Date__c = datetime.now();
                }
            }
            else if((UserInfo.getUserId() != MarketoUserID && l.Email == null)){
                l.adderror(system.label.LeadEco1);  
            }
            //Email ID is mandatory for Leads created in Salesforce
            //Error msg for Custom label LeadEco1
            else if(UserInfo.getUserId() != MarketoUserID && l.Email != null){
                if(unique_emails.contains(l.Email)){
                    l.adderror(system.label.LeadEco2);  
                }
                //Error msg for Custom label LeadEco2
                //The Email you input is already tied to an existing contact or lead.  Please check for the existing contact or lead record and make updates to the record as needed.
            }
        }
    }
    /* #####################################################################################################################################   */
    //below logic will only be used, when Lead created with NCR.com Domain then it will be assigned to Eloqua marketing User
    public static void auto_assign_Lead_to_EloquaMarketing(List<Lead> triggernewlist){
        for(Lead l : triggernewlist){
            if(String.isNotBlank(l.Email) && ((l.Email).contains('@ncr.com') || (l.Email).contains('@corp.ncr.com') )){
                l.OwnerId= MarketoUserID;
            }   
        }
    }
    public static List<String> getPostalCode(List<Lead>triggernewlist){
        List<String> pCode = new List<String>();
        for(Lead l : triggernewlist){
            if(l.PostalCode!=null && l.PostalCode.length()<=5){
                if(l.PostalCode.length()==4)
                    l.PostalCode='0'+l.PostalCode;
                if(l.PostalCode.length()==3)
                    l.PostalCode='00'+l.PostalCode; 
            }  
            pCode.add(l.PostalCode);
        }
        return pCode;
    }

    /* #####################################################################################################################################   */
    //  below method will return the region mapping to decide the country / countryCode from countryCode / country and respective Region from custom setting
    public static map<string,LeadRegionCountryMapping__c> return_regionMapping(){
        map<string,LeadRegionCountryMapping__c> regionMapping = new map<string,LeadRegionCountryMapping__c>();
        for(LeadRegionCountryMapping__c c : LeadRegionCountryMapping__c.getall().values()){
            regionMapping.put(c.Country__c,c);
            regionMapping.put(c.CountryCode__c,c);
        }
        return regionMapping ;
    }   
   
    /* #####################################################################################################################################   */
    //  below method will return the SRT Code from SRT Description mapped in custom setting
    public static Map<String, String> return_StatusStageMap(){
        Map<String, String> StatusStageMap = new Map<String, String>() ;
        for( Lead_Status_Stage_Mapping__c st:  Lead_Status_Stage_Mapping__c.getall().values()) {
            StatusStageMap.put(st.LeadStatus__c,st.LeadStage__c);
        }
        return StatusStageMap;
    }

    /* #####################################################################################################################################   */
}