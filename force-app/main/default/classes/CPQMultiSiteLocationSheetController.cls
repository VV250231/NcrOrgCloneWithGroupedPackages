/************************************** 
Author ...............: Suraj Parihar
Created Date..........: 22-JULY-2021
Modified Date.........: 22-JULY-2021
Description...........: Controller for vf "MULTI-SITE LOCATION" which MULTI-SITE LOCATION information for customer for the related Quote in the form of excel sheet. 
***************************************/
public class CPQMultiSiteLocationSheetController {
    
    //xml doctype
    public String xlsHeader{
        get {
            String strHeader = '';
            strHeader += '<?xml version="1.0" encoding="UTF-8"?>';
            strHeader += '<?mso-application progid="Excel.Sheet"?>';
            return strHeader;
        }
        set;
    } 
    
    //Multi-Site Location Details Wrapper class 
    public class LocationDetailsClass {        
        public String Location_Type {get;set;}
        public String DBA_NAME {get;set;}
        public String DBA_ADDRESS_1 {get;set;}
        public String DBA_ADDRESS_2 {get;set;} 
        public String DBA_CITY {get;set;}
        public String DBA_STATE {get;set;}
        public String DBA_ZIP {get;set;}
        public String DBA_PHONE {get;set;}
        public String DBA_FAX {get;set;}
        public String DBA_EMAIL_ADDRESS {get;set;}
        public String DBA_CONTACT_NAME {get;set;}
        public String DBA_CONTACT_EMAIL {get;set;}
        public String CUST_SERV_EMAIL {get;set;}
        public String TAX_ID {get;set;}
        public String LEGAL_NAME {get;set;}
        public String CORP_TYPE {get;set;}
        public String CORP_ADDRESS1{get;set;}
        public String CORP_ADDRESS2{get;set;}
        public String CITY {get;set;}
        public String STATE {get;set;}
        public String ZIP {get;set;}
        public String CORP_PHONE {get;set;}
        public String CORP_FAX {get;set;}
        public String MCC_CODE {get;set;}
        public String GOODS_SERVICES_DESCRIPTION{get;set;}
        public String WEBSITE_URL_ADDRESS {get;set;}
        public String OWNER_1_FIRST_NAME {get;set;}
        public String OWNER_1_LAST_NAME {get;set;}
        public String OWNERSHIP_PERCENTAGE {get;set;}
        public String OWNER_1_SOCIAL_SEC_NUM {get;set;}
        public String OWNER_1_DATE_OF_BIRTH {get;set;}
        public String OWNER_1_HOME_ADDRESS_1 {get;set;}
        public String OWNER_1_HOME_ADDRESS_2 {get;set;}
        public String OWNER_1_CITY {get;set;}
        public String OWNER_1_STATE {get;set;}
        public String OWNER_1_ZIP {get;set;}
        public String OWNER_1_PHONE {get;set;}
        public String OWNER_1_EMAIL {get;set;}
        public String BILLING_CONTACT_NAME {get;set;}
        public String BILLING_CONTACT_PHONE {get;set;}
        public String BILLING_CONTACT_EMAIL {get;set;}
        public String REPORTING_CONTACT_NAME {get;set;}
        public String REPORTING_CONTACT_PHONE {get;set;}
        public String REPORTING_CONTACT_EMAIL {get;set;}
        public String PCI_CONTACT_NAME {get;set;}
        public String PCI_CONTACT_PHONE {get;set;}
        public String PCI_CONTACT_EMAIL {get;set;}
        public String CHARGEBACKS_CONTACT_NAME {get;set;}
        public String CHARGEBACKS_CONTACT_PHONE {get;set;}
        public String CHARGEBACKS_CONTACT_EMAIL {get;set;}
        public String BANK_ABA {get;set;}
        public String BANK_DDA {get;set;}
        public String TOTAL_MONTHLY_VOLUME {get;set;}
        public String TOTAL_ANNUAL_VOLUME {get;set;}
        public String HIGHEST_TICKET {get;set;}
        public String AVERAGE_TICKET {get;set;}
        public String NUM_DAILY_TRANSACTIONS {get;set;}
        public String HIGHEST_DAILY_SALES_VOLUME {get;set;}
        public String CARD_PRESENT {get;set;}
        public String CARD_NOT_PRESENT {get;set;}
        public String PIN_DEBIT_USED {get;set;}
        public String AMEX_SE{get;set;}
        public String MCN {get;set;}
        public String SiteID {get;set;}
        public String QuoteID {get;set;}    }    
    public List<LocationDetailsClass> locationDetails = new List<LocationDetailsClass>();    
    public void setlocationDetails(List<LocationDetailsClass> setterList){
        this.locationDetails.addAll(setterList);
    }
    
    public List<LocationDetailsClass> getlocationDetails(){ 
        return this.locationDetails;
    }    
    
    string QuoteId = '';
    //Default Constructor
    public CPQMultiSiteLocationSheetController() {        
        //Get All querystring parameters
        QuoteId = ApexPages.currentPage().getParameters().get('id');
        SBQQ__Quote__c lstQli;
        
        if(QuoteId != null){
            lstQli=[select SBQQ__Account__r.Master_Customer_Number__c, SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingPostalCode, SBQQ__Account__r.Name, SBQQ__Account__r.Phone,SBQQ__Account__r.Fax ,qtc_Bill_To_Site__r.BillingStreet, qtc_Bill_To_Site__r.BillingCity, qtc_Bill_To_Site__r.BillingPostalCode,  qtc_Bill_To_Site__r.BillingState, name,Payments_Application_Signee__r.Phone,Payments_Application_Signee__r.Email,Payments_Application_Signee__r.name,Payments_Application_Signee__r.MailingAddress,(Select id,Account_Sites__r.name,Site_Number__c,Account_Sites__r.BillingStreet,Account_Sites__r.BillingCity,Account_Sites__r.BillingState, Account_Sites__r.BillingPostalCode from NCR_Payments_Sites__r where qtc_Primary_Site__c!=true), qtc_Average_Check__c, qtc_Annual_Volume__c from SBQQ__Quote__c where id=:QuoteId ];
        }
        
        if(lstQli != null){ 
            addDynamicRows(lstQli);
        }        
        
    }
    
    public void addDynamicRows(SBQQ__Quote__c lstQli) {
        LocationDetailsClass clsObject;
        for(NCR_Payments_Site__c ql : lstQli.NCR_Payments_Sites__r){
            clsObject = new LocationDetailsClass();  
            clsObject.DBA_NAME = String.valueOf(ql.Account_Sites__r.name);
            clsObject.DBA_ADDRESS_1 = String.valueOf(ql.Account_Sites__r.BillingStreet);
            clsObject.DBA_CITY = String.valueOf(ql.Account_Sites__r.BillingCity);
            clsObject.DBA_STATE = String.valueOf(ql.Account_Sites__r.BillingState);
            clsObject.DBA_ZIP = String.valueOf(ql.Account_Sites__r.BillingPostalCode);
            clsObject.DBA_PHONE = String.valueOf(lstQli.Payments_Application_Signee__r.Phone);
            clsObject.DBA_EMAIL_ADDRESS = String.valueOf(lstQli.Payments_Application_Signee__r.Email);
            clsObject.DBA_CONTACT_NAME = String.valueOf(lstQli.Payments_Application_Signee__r.name);
            clsObject.DBA_CONTACT_EMAIL = String.valueOf(lstQli.Payments_Application_Signee__r.Email);
            clsObject.LEGAL_NAME = String.valueOf(lstQli.SBQQ__Account__r.Name);
            clsObject.CORP_ADDRESS1 = String.valueOf(lstQli.SBQQ__Account__r.BillingStreet);
            clsObject.CITY = String.valueOf(lstQli.SBQQ__Account__r.BillingCity);
            clsObject.STATE = String.valueOf(lstQli.SBQQ__Account__r.BillingState);
            clsObject.ZIP = String.valueOf(lstQli.SBQQ__Account__r.BillingPostalCode);
            clsObject.CORP_PHONE = String.valueOf(lstQli.SBQQ__Account__r.Phone);
            clsObject.CORP_FAX = String.valueOf(lstQli.SBQQ__Account__r.Fax);
            Decimal monthlyVol =(lstQli.qtc_Annual_Volume__c/12).setscale(0);
            clsObject.TOTAL_MONTHLY_VOLUME = String.valueOf(monthlyVol);
            clsObject.TOTAL_ANNUAL_VOLUME = String.valueOf(lstQli.qtc_Annual_Volume__c);
            clsObject.AVERAGE_TICKET = String.valueOf(lstQli.qtc_Average_Check__c);
            clsObject.MCN = String.valueOf(lstQli.SBQQ__Account__r.Master_Customer_Number__c);
            clsObject.SiteID = String.valueOf(ql.Site_Number__c);
            clsObject.QuoteID = String.valueOf(lstQli.name);
            locationDetails.add(clsObject);
        } 
    }
}