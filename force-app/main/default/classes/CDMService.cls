/**************************************
Author ...............: IDC, NSC
Date Created .........: 1 Jan, 2019
Modification Log
By - Stuti Srivastava -EBA-2060 on 25/5/2022
By - Santosh Jha -    EBA_SF-2276 on 25/9/2022
By - Basel Altamimi - SFHS Project on 28/7/2022
By - Puneet Bhatia - EBA_SF-2189 on 05/08/2022
By - Puneet Bhatia - EBA_SF-2334  on 03/10/2022
By - Parth Sharma - EBA_SF-2478 on 03/02/2023
Description ..........: This class exposed as Business Service to send Customer and Account data from CDM to NSC and called via SOUP.
changes done for EBA_SF-2622 Salesforce is not transferring the Province field to the State field for HW RMAs. Province__c is added in query
***************************/
global with sharing class CDMService {
    
    global final static String STATUS_SUCCESS = 'SUCCESS', STATUS_FAILURE = 'FAILURE', STATUS_WARNING = 'WARNING';
    //global final static String STATUS_FAILURE = 'FAILURE';
    //global final static String STATUS_WARNING = 'WARNING';
    global Enum CDMAction {AccountCreate, AccountUpdate, CustomerCreate, CustomerUpdate}
    
    webservice static CustomerHierarchyResponse syncCustomerHierachy(CustomerHierarchyRequest inputCustHrchyReq) {
        System.debug(inputCustHrchyReq);
        CustomerHierarchyResponse res = new CustomerHierarchyResponse();
        Savepoint sp = Database.setSavepoint();
        Boolean doRtry = false;
        
        do {
            try {
                if ((inputCustHrchyReq != null) && String.isNotBlank(inputCustHrchyReq.CDMActionType)) {
                    if ((inputCustHrchyReq.Customer != null) && 
                        (inputCustHrchyReq.CDMActionType == CDMAction.CustomerCreate.name() || 
                         inputCustHrchyReq.CDMActionType == CDMAction.CustomerUpdate.name())) 
                    {
                        
                        CustomerWrapper CDMcust = inputCustHrchyReq.Customer;
                        String vldtnErr = validateCustomer(CDMcust);
                        Boolean isVldCstmr = String.isBlank(vldtnErr);
                        
                        if (isVldCstmr) {                                                                     
                            String custSFId = createCustomer(CDMcust);
                            
                            if (!String.isBlank(custSFId)) {
                                res.recordSFId = custSFId;
                                res.status = STATUS_SUCCESS;
                            }
                        } else {                    
                            res.status = STATUS_FAILURE;
                            res.message = vldtnErr;
                        }
                    } else if ((inputCustHrchyReq.Customer != null) && (inputCustHrchyReq.Customer.Account != null) 
                               && (inputCustHrchyReq.CDMActionType == CDMAction.AccountCreate.name() || inputCustHrchyReq.CDMActionType == CDMAction.AccountUpdate.name())) {
                                   
                                   CustomerWrapper CDMcust = inputCustHrchyReq.Customer;
                                   AccountWrapper CDMacc = inputCustHrchyReq.Customer.Account;
                                   
                                   Boolean isVldCustmr = String.isBlank(validateCustomer(CDMcust)); //check if valid Customer
                                   String vldtnErr = validateAccount(CDMacc); //check if valid Account
                                   Boolean isVldAcc = String.isBlank(vldtnErr);
                                   String custSFId = NULL;
                                   
                                   // create customer if it is valid
                                   if (isVldCustmr) { custSFId = createCustomer(CDMcust);}
                                   
                                   if (isVldAcc) {
                                       String accSFId = createAccount(CDMacc, custSFId,CDMcust);
                                       
                                       if (String.isNotBlank(accSFId)) {                           
                                           res.recordSFId = accSFId; // return only Account Id in response
                                           res.status = STATUS_SUCCESS;
                                       }
                                   } else {       
                                       res.status = STATUS_FAILURE; // return only Account validation error    
                                       res.message = vldtnErr;
                                   }
                               } else {
                                   res.status = STATUS_FAILURE;
                                   res.message = 'Invalid input or Invalid action for CDM Service';
                               }
                }  else {
                    res.status = STATUS_FAILURE;
                    res.message = 'Invalid input or Invalid action for CDM Service';
                }
                doRtry = false; 
            } catch(System.DMLException ex) {
                
                if (StatusCode.DUPLICATE_VALUE == ex.getDmlType(0)) {
                    doRtry = true;    
                    CDMUtil.addWait(500);                    
                } else {
                    doRtry = false;
                    if(sp != NULL) Database.RollBack(sp);
                    res.status = STATUS_FAILURE;
                    res.message = ex.getMessage() + ex.getStackTraceString();
                } 
            }
            catch(Exception e) {
                doRtry = false;
                if(sp != NULL) Database.RollBack(sp);
                res.status = STATUS_FAILURE;
                res.message = e.getMessage() + e.getStackTraceString();
            } 
        } while(doRtry);   
        
        CDMLogger.logCustomerHierachySync(JSON.serialize(inputCustHrchyReq), JSON.serialize(res));
        return res;
    }
    
    
    global class CustomerHierarchyRequest {
        webService CustomerWrapper Customer; 
        webService String CDMActionType;
    }
    
    
    global class CustomerWrapper {
        webService String CustomerCDMId;
        webService String CustomerNumber;
        webService String CustomerName;
        webService String PhoneticName;
        webService String LegalEntityName;
        webService String Status;
        webService String StatusCode;
        webService String SICCode;
        webService String NAICSCode;
        webService String NCR_Industry;
        webService String NCR_SubIndustry;
        webService String NCR_Tiering;
        webService String Credit_Limit_Requested;  
        webService String Credit_Limit_Allowed;
        webService String DUNS_Number;
        webService String Website;
        webService String FI_Type;
        webService String Corporate_Address_Line1;
        webService String Corporate_Address_Line2;
        webService String Corporate_Address_Line3;
        webService String Corporate_Address_Line4;
        webService String Corporate_City;
        webService String Corporate_State;
        webService String Corporate_Country;
        webService String Corporate_PostalCode;
        webService String LatitudeGeocode;
        webService String LongitudeGeocode;
        webService String ROR_Update_Datetime; 
        webService String Product_Original_Corporation; //Added By Stuti Srivastava as a part of EBA-2060 
        webService AccountWrapper Account;
        
        webService String Global_Ultimate_DUNS_Number;
        webService String Domestic_Ultimate_DUNS_Number;
        webService List<RelationshipWrapper> CustomerRelations;
    }
    
    global class AccountWrapper {
        webService String AccountCDMId;
        webService String AccountNumber;
        webService String Status;
        webService String StatusCode;
        webService String AccountName;
        webService String AlternateName;
        webService String LegalEntityName;
        webService String SICCode;
        webService String NAICSCode;
        webService String NCRIndustry;
        webService String NCRSubIndustry;
        webService String AccountType;
        webService String SubAccountType;
        webService String OperatingUnit;
        webService String OperatingUnitName;
        webService String GlobalOrgCode;
        webService String AccountOwner_QuicklookID;
        webService String AccountCreditLimit;
        webService String EECode;
        webService String EEName;
        webService String CECode;
        webService String CEName;
        webService String BrandParentName; // Operational Parent Name
        webService String BrandParentCode; // Operational Parent DUNS Number
        webService String BrandParent_StartDate;
        webService String BrandParent_EndDate;
        webService String Billing_Address_Line1;
        webService String Billing_Address_Line2;
        webService String Billing_Address_Line3;
        webService String Billing_Address_Line4;
        webService String Billing_City;
        webService String Billing_State;
        webService String Billing_Country;
        webService String Billing_PostalCode;
        webService String LatitudeGeocode;
        webService String LongitudeGeocode;
        webService String Shipping_Country;
        webService String CustomerSource;
        webService String CustomerLocalLanguageFlag;
        webService String SMBFlagLov;
        webService String GlobalCustomerNumber;
        webService String HSRShortName;
        webService String Custom1;
        webService String Product_Original_Corporation; //Added By Stuti Srivastava as a part of EBA-2060
        //Added By Vivek Kumar
        webService String ManagedServiceCustomer;
        //Added By Basel Altamimi
        webService String PartyType;
        webService String Country;
        webService String NCRPartyUsage;
        webService Boolean PulseFlag;
        webService String Regionlov;
        webService String PaymentTerm;
      
      //Added for story EBA_SF-2189
        webService String SourceSystemNumber;

        webService List<RelationshipWrapper> Partner_Of_Relation;
        webService List<RelationshipWrapper> LocalOffice_Of_Relation; 
        webService SiteListWrapper Sites;
        
    }
    
    global class SiteListWrapper {
        webService List<SiteWrapper> Site;
    }
    
    global class SiteWrapper {
        webService String SiteCDMId;
        webService String SiteNumber;
        webService String SiteName;
        webService String Address_Line1;
        webService String Address_Line2;
        webService String Address_Line3;
        webService String Address_Line4;
        webService String City;
        webService String State;
        webService String County; //Country Code
        webService String Province;
        webService String Country;
        webService String PostalCode;
        webService String Channel_Org_Code;
        webService String NCR_Status;
        webService String Solution_SetID;
        webService String VATTaxNationalID; //CNPJ Number for Brazil OperatingUnit
        webService String StoreNumber;
        webService String Product_Original_Corporation; //Added By Stuti Srivastava as a part of EBA-2060
        webService SiteUseListWrapper SiteUseList;
    }
    
    global class SiteUseListWrapper {
        webService List<SiteUseWrapper> SiteUse;
    }
    
    global class SiteUseWrapper {
        webService String SiteUseType;
        webService String Status;
    }
    
    
    global class CustomerHierarchyResponse {
        webservice String recordSFId;
        webservice String status;
        webservice String message;   
    }
    
    
    global class RelationshipWrapper {
        webService String Related_PartyNumber;   
        webService String Related_PartyName;
        webService String RelationShip_Name;
        webService String RelationShip_Code;
        webService String RelationShip_StartDate;
        webService String RelationShip_End_Date;
        webService String RelationShip_Status;  
        webService String ROR_Update_Datetime;   
    }
    
    private static String validateCustomer(CustomerWrapper CDMcust) {
        String err = '';
        
        if(String.isBlank(CDMcust.CustomerCDMId)) {
            err = 'Customer CDM ID is missing';
        } else if(String.isBlank(CDMcust.CustomerNumber)) { 
            err = 'Customer Number is missing';
        } else if(String.isBlank(CDMcust.CustomerName)) {
            err = 'Customer Name is missing';
        }
        return err;
    }
    
    private static String validateAccount(AccountWrapper CDMacc) {
        String err = '';
        
        if(String.isBlank(CDMacc.AccountCDMId)) {
            err = 'Account CDM ID is missing';
        } else if(String.isBlank(CDMacc.AccountNumber)) {
            err = 'Account Number is missing';
        } else if(String.isBlank(CDMacc.AccountName)) {
            err = 'Account Name is missing';
        } else if(String.isBlank(CDMacc.OperatingUnit)) {
            err = 'Account Operating Unit is missing';
        } else if(String.isBlank(CDMacc.Status)) {
            err = 'Accont Status is missing';
        } else if(String.isBlank(CDMacc.AccountType)) {
            err = 'Account Type is missing';            
        } 
        
        List<DisableCDMNSCSupportNotifications__c> cdm_ntfy = DisableCDMNSCSupportNotifications__c.getall().values();
        if(cdm_ntfy[0].TurnMailOn__c ==  'ON'){
            CDMUtil.notifyInvldPcklstVals(CDMacc);
        }
        
        return err;
    }
    
    public static Account getCustomerDetail(String cstmrNbr) {
        Account cstmr = null;
        if (String.isNotBlank(cstmrNbr)) {
            List<Account> cstmrLst = [SELECT Id, Customer_Number__c, ParentId, Parent.Customer_Number__c,Global_Ultimate_Lookup__c, 
                                       Global_Ultimate_Lookup__r.DUNS__c, Domestic_Ultimate_Lookup__c, Domestic_Ultimate_Lookup__r.DUNS__c,
                                       RoR_Update_Date_Time__c 
                                       FROM Account WHERE Customer_Number__c = :cstmrNbr LIMIT 1 FOR UPDATE];
            if(!cstmrLst.isEmpty()) cstmr = cstmrLst.get(0);
        }
        return cstmr;
    }
    
    public static List<Account> getAccountDetail(String ccWithMCN, SiteListWrapper sites) {
        List<Account> accLst = new List<Account>(); 
        //Map<String, Account> accMap = new Map<String, Account();
        Set<String> siteNbrs = new Set<String>();
        
        if (sites != NULL && sites.site != NULL && sites.site.size() > 0) {
            for (SiteWrapper st : sites.site) {
                if(String.isNotBlank(st.SiteNumber)) siteNbrs.add(st.SiteNumber);    
            }   
        }
        //changes done for EBA_SF-2622 Salesforce is not transferring the Province field to the State field for HW RMAs. Province__c is added in query
        if (String.isNotBlank(ccWithMCN)) {
            accLst = [SELECT Id, RecordType.Name, Country_with_Master_customer_Number__c,Site_Number__c,ROR_Operational_Parent__c, ROR_Operational_Parent__r.Customer_Number__c,
                      Account_CDM_ID__c, Name, CDM_Account_Status__c, ParentId, Channel_Organization_Code__c, cdm_Store_Branch_Number__c, BillingStreet, BillingCity, BillingState,Province__c, 
                      BillingCountry, BillingPostalCode,cdm_Solution_Set_Id__c, cdm_NationalVatTaxID__c, 
                      Primary_Bill_To__c, Primary_Ship_To__c,Primary_Deliver_To__c,
                      Bill_To__c, Ship_To__c, Deliver_To__c
                      FROM Account WHERE (RecordType.Name IN ('Customer', 'Partner') AND Country_with_Master_customer_Number__c = :ccWithMCN) OR (RecordType.Name='Site' AND Site_Number__c IN :siteNbrs) FOR UPDATE]; // LIMIT 1
        }
        return accLst;
    }

    @TestVisible
    private static String createCustomer(CustomerWrapper CDMcst) {
        if (CDMcst != null && String.isNotBlank(CDMcst.CustomerCDMId) && String.isNotBlank(CDMcst.CustomerNumber)) {
            Id EnterpriseRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise').getRecordTypeId();
            Account exstCst = getCustomerDetail(CDMcst.CustomerNumber);
            
            Account cst = new Account();
            cst.RecordTypeId = EnterpriseRecTypeId;
            if (exstCst != NULL) cst.Id = exstCst.Id;
            cst.Customer_CDM_Id__c = CDMcst.CustomerCDMId;
            //cst.Name = (String.isNotBlank(CDMcst.CustomerName) && CDMcst.CustomerName.length() > 80) ? (CDMcst.CustomerName.substring(0, 77) + '...') : CDMcst.CustomerName;
            // Standard Account Name filed length is 255.
            cst.Name = CDMcst.CustomerName;
            cst.Customer_Number__c = CDMcst.CustomerNumber;
            cst.Name = CDMcst.CustomerName;
            cst.Phonetic_Name__c = CDMcst.PhoneticName;  
            cst.CDM_Account_Status__c = CDMcst.Status;
            cst.CDM_Status_Code__c = CDMcst.StatusCode;
            cst.Sic = CDMcst.SICCode;
            cst.NAICS_Code__c = CDMcst.NAICSCode;
            cst.NCR_Industry__c = CDMcst.NCR_Industry;  
            cst.NCR_Sub_Industry__c = CDMcst.NCR_SubIndustry;  
            cst.NCR_Tiering_Text__c = CDMcst.NCR_Tiering;
            //cust.Enterprise_Entity__c = CDMcust.Enterprise_Entity;
            cst.Credit_Limit_Requested__c = CDMcst.Credit_Limit_Requested;
            cst.Credit_Limit_Allowed__c = CDMcst.Credit_Limit_Allowed;  
            cst.DUNS__c = CDMcst.DUNS_Number;
            cst.Website = CDMcst.Website;
            //cst.FI_Type__c = CDMcst.FI_Type;  
            cst.Enterprise_FI_Type__c = CDMcst.FI_Type;
            //cust.Legal_Entity_Name__c = CDMcust.LegalEntityName;
            cst.Billing_Latitude_Geocode__c= CDMcst.LatitudeGeocode;
            cst.Billing_Longitude_Geocode__c= CDMcst.LongitudeGeocode;
            //cust.Parent_Customer_Number__c = CDMcust.Parent_CustomerNumber;  
            cst.BillingStreet = CDMUtil.trimStr((String.isNotBlank(CDMcst.Corporate_Address_Line1) ? CDMcst.Corporate_Address_Line1 : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line2) ? ('\n' + CDMcst.Corporate_Address_Line2) : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line3) ? ('\n' + CDMcst.Corporate_Address_Line3) : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line4) ? (',' +  CDMcst.Corporate_Address_Line4) : ''), 255);
            cst.BillingCity = CDMUtil.trimStr(CDMcst.Corporate_City,40);  
            cst.BillingState = CDMcst.Corporate_State; 
            cst.BillingCountry = CDMcst.Corporate_Country;
            cst.BillingPostalCode = CDMcst.Corporate_PostalCode;          
            cst.RoR_Update_Date_Time__c= String.isNotBlank(CDMcst.ROR_Update_Datetime) ? Datetime.valueOfGMT(CDMcst.ROR_Update_Datetime.replace('T',' ').replace('Z', '')) : null;
            cst.CDM_Account_Type__c = 'Enterprise'; 
      cst.OriginalCorporation__c = CDMcst.Product_Original_Corporation; // Changes by Stuti - EBA 2060

            Boolean recalcChildGU = CDMUtil.processCstmrRltns(cst, exstCst, CDMcst, EnterpriseRecTypeId); //process Customer Relationships

            upsert cst Customer_Number__c;  

            return cst.Id;
        }
        return null;
    }

    @TestVisible
    private static String createAccount(AccountWrapper CDMacc, String custSFId, CustomerWrapper CDMcst) {
        if (CDMacc != null && String.isNotBlank(CDMacc.AccountCDMId) && String.isNotBlank(CDMacc.AccountNumber)) {
            Account exstAcc; Map<String, Account> extSiteNbrMap = new Map<String, Account>(); 
            Boolean isNewAcct = false;
            String ctryWithMCN = CDMacc.OperatingUnit + CDMacc.AccountNumber;
            List<Account> exstAccAndSiteLst = getAccountDetail(ctryWithMCN, CDMacc.Sites);
            
            for (Account acc : exstAccAndSiteLst) {
                if((Acc.RecordType.Name == 'Customer' || Acc.RecordType.Name == 'Partner')) {
                    if (Acc.Country_with_Master_customer_Number__c == ctryWithMCN) {
                        exstAcc = acc;  
                    }
                } else {
                    extSiteNbrMap.put(acc.Site_Number__c, acc);  
                }
            } 

            Account acc = new Account();
            if (exstAcc != NULL) 
                acc.Id = exstAcc.Id; 
            else  
                isNewAcct = true; 
            
            acc.Account_CDM_Id__c = CDMacc.AccountCDMId;
            acc.Master_Customer_Number__c = CDMacc.AccountNumber;
            acc.CDM_Account_Status__c = CDMacc.Status;
            acc.CDM_Status_Code__c = CDMacc.StatusCode;
            acc.Name = CDMacc.AccountName;
            acc.Account_Name_Local__c = CDMacc.AlternateName;
            acc.Industry = CDMacc.NCRSubIndustry;
            acc.CDM_Account_Type__c = (CDMacc.AccountType).toUppercase();
            acc.Account_Country_Code__c = CDMacc.OperatingUnit;            
            acc.CDM_Account_Manager__c = CDMacc.AccountOwner_QuicklookID;
            acc.BillingStreet =CDMUtil.trimStr((String.isNotBlank(CDMacc.Billing_Address_Line1) ? CDMacc.Billing_Address_Line1 : '')
                                + (String.isNotBlank(CDMacc.Billing_Address_Line2) ? ('\n' + CDMacc.Billing_Address_Line2) : '')
                                + (String.isNotBlank(CDMacc.Billing_Address_Line3) ? ('\n' + CDMacc.Billing_Address_Line3) : '')
                                + (String.isNotBlank(CDMacc.Billing_Address_Line4) ? (',' +  CDMacc.Billing_Address_Line4) : ''), 255);
            acc.BillingCity = CDMUtil.trimStr(CDMacc.Billing_City, 40);
            acc.BillingState = CDMacc.Billing_State;
            acc.BillingCountry = CDMacc.Billing_Country;
            
            acc.BillingPostalCode = CDMacc.Billing_PostalCode;
            acc.Billing_Longitude_Geocode__c = CDMacc.LongitudeGeocode;
            acc.Billing_Latitude_Geocode__c = CDMacc.LatitudeGeocode;   
            
            //Added by Parth Sharma as part of EBA_SF-2478 to populate Corporate_Address__c field on account.
            acc.Corporate_Street__c = CDMUtil.trimStr((String.isNotBlank(CDMcst.Corporate_Address_Line1) ? CDMcst.Corporate_Address_Line1 : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line2) ? ('\n' + CDMcst.Corporate_Address_Line2) : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line3) ? ('\n' + CDMcst.Corporate_Address_Line3) : '')
                                + (String.isNotBlank(CDMcst.Corporate_Address_Line4) ? (',' +  CDMcst.Corporate_Address_Line4) : ''), 255);
            acc.Corporate_City__c = CDMUtil.trimStr(CDMcst.Corporate_City,40);  
            acc.Corporate_State__c = CDMcst.Corporate_State; 
            acc.Corporate_Country__c = CDMcst.Corporate_Country;
            acc.Corporate_PostalCode__c = CDMcst.Corporate_PostalCode;  
           
            acc.NAICS_Code__c = CDMacc.NAICSCode;
            acc.Sic = CDMacc.SICCode;
            acc.Customer_Source__c = CDMacc.CustomerSource;
            acc.CDM_Sub_Account_Type__c = CDMacc.SubAccountType;
            acc.CDM_Customer_Local_Language__c = CDMacc.CustomerLocalLanguageFlag;
            acc.CDM_SMB_Flag__c = (String.isNotBlank(CDMacc.SMBFlagLov) && CDMacc.SMBFlagLov.toUpperCase() == 'Y') ? TRUE : FALSE;
            acc.Global_Customer_Number__c = CDMacc.GlobalCustomerNumber;
            acc.HSR_Short_Name__c = CDMacc.HSRShortName;
            acc.OriginalCorporation__c = CDMacc.Product_Original_Corporation;  // Changes by Stuti - EBA 2060

            // Added by Basel Altamimi as part of SFHS-637
            acc.Party_Type__c = CDMacc.PartyType;
            acc.Country__c = CDMacc.Country;
            acc.NCR_Party_Usage__c = CDMacc.NCRPartyUsage;
            acc.Pulse_Flag__c = CDMacc.PulseFlag != null ? CDMacc.PulseFlag : false;
            acc.Region_LOV__c = CDMacc.Regionlov;
            
            /***** Handle Global Sales Org Code Changes -Start *****/
            acc.CDM_Source_SOC__c = CDMacc.GlobalOrgCode; 
            
            //EBA_SF-2334 - avoid default Sales Org Code population for CATM ONLY Accounts
            if(String.isBlank(CDMacc.GlobalOrgCode) && (String.isBlank(CDMacc.Product_Original_Corporation) 
                                                        || CDMacc.Product_Original_Corporation.toUpperCase() != System.Label.CATM_ORGCORP)) {             
                if(exstAcc == NULL) acc.Use_Default_Sales_Org_Code__c = true;
            }
            /***** Handle Global Sales Org Code Changes -End ******/
            
            /**************  MDM fields mapping- start ***************/
            acc.MDM_Industry_Code__c = CDMacc.NCRSubIndustry;
            acc.MDM_Industry_Name__c = CDMacc.NCRSubIndustry;
            acc.MDM_Sub_Industry_Code__c = CDMacc.SICCode;
            //acc.MDM_Sub_Industry_Name__c = ''; // not getting from CDM
            acc.MDM_ERP_Country_Entity_Code__c = CDMacc.OperatingUnit;            
            acc.MDM_ERP_Country_Entity_Name__c = CDMacc.OperatingUnitName;
            acc.MDM_Customer_Entity_Name__c = CDMacc.CEName;
            acc.MDM_Customer_Entity_Nbr__c = CDMacc.CECode;
            acc.MDM_Enterprise_Name__c = CDMacc.EEName;
            acc.MDM_Enterprise_Nbr__c = CDMacc.EECode;
            acc.MDM_Billing_Location_Country_Code__c = CDMacc.Billing_Country;
            acc.MDM_Shipping_Location_Country_Code__c = CDMacc.Shipping_Country;    
            /**************  MDM fields mapping- end ***************/
            
            /**************** Operational Parent handling -start ******************/
            if(String.isNotBlank(CDMacc.BrandParentCode) && String.isNotBlank(CDMacc.BrandParentName)) {
                
                if (CDMacc.BrandParent_EndDate != NULL && Date.valueOf(CDMacc.BrandParent_EndDate) <= Date.today()) {    
                    if (exstAcc != null && exstAcc.ROR_Operational_Parent__c != NULL && exstAcc.ROR_Operational_Parent__r.Customer_Number__c == CDMacc.BrandParentCode) {
                        acc.ROR_Operational_Parent__c = null;
                        acc.MDM_Brand_Name__c = '';   
                        acc.MDM_Brand_Code__c = '';
                        acc.Operational_Parent_Start_Date__c = null;
                        acc.Operational_Parent_End_Date__c = null;   
                    }  
                    
                } else {                    
                    acc.MDM_Brand_Code__c = CDMacc.BrandParentCode;
                    
                    if(CDMacc.BrandParentName.length() > 255) {
                        acc.MDM_Brand_Name__c = CDMacc.BrandParentName.subString(0,255);
                    } else {
                        acc.MDM_Brand_Name__c = CDMacc.BrandParentName;
                    }
                    
                    Date maxDate = Date.newInstance(4000, 12, 31);
                    if (CDMacc.BrandParent_StartDate != NULL) {
                        Date brdParentStartDate = Date.valueOf(CDMacc.BrandParent_StartDate);                    
                        acc.Operational_Parent_Start_Date__c  = (brdParentStartDate > maxDate) ?  maxDate : brdParentStartDate;
                    }
                    
                    if (CDMacc.BrandParent_EndDate != NULL) {    
                        Date brdParentEndDate = Date.valueOf(CDMacc.BrandParent_EndDate);                            
                        acc.Operational_Parent_End_Date__c =  (brdParentEndDate > maxDate) ?  maxDate : brdParentEndDate;
                    }
                    
                    Customer__c OPRef = new Customer__c(Customer_Number__c = CDMacc.BrandParentCode);
                    acc.ROR_Operational_Parent__r = OPRef;
                }
            }
            /**************** Operational Parent handling -end ******************/
            acc.ror_update_date_time__c = Datetime.now();        
            acc.Country_with_Master_customer_Number__c = CDMacc.OperatingUnit + CDMacc.AccountNumber;   
            //acc.Customer__c = String.isNotBlank(custSFId) ? custSFId : NULL; 
            acc.ParentId = String.isNotBlank(custSFId) ? custSFId : NULL; 
            //Added By Vivek Kumar
            acc.Managed_Services_Customer__c = (CDMacc.ManagedServiceCustomer == 'Y' ? true : false);
            //Added for story EBA_SF-2189
            acc.Source_System_Number__c = CDMacc.SourceSystemNumber;
            acc.PaymentTerm__c = CDMacc.PaymentTerm;
            
            if(!isNewAcct) { // !isNewAcct && !isNewSites
                List<Account> updtActs = new List<Account>{acc};
                List<Account> upsrtSites = new List<Account>{};
                List<Account> sites = CDMUtil.generateSites(acc.Id, extSiteNbrMap, CDMacc.Sites); 
                for(Account s : sites) {
                    if(s.Id != NULL) updtActs.add(s); 
                    else upsrtSites.add(s);
                }
                if (!updtActs.isEmpty()) update updtActs;
                if (!upsrtSites.isEmpty()) upsert upsrtSites Site_Number__c;
            }  else {
                upsert acc Country_with_Master_customer_Number__c;  
                List<Account> siteAccts = CDMUtil.generateSites(acc.Id, extSiteNbrMap, CDMacc.Sites);
                upsert siteAccts Site_Number__c;
            }
            
            if(acc.Id != NULL) {
                CDMUtil.processAcctRltns(CDMacc, acc.Id, isNewAcct);  
            }
            return acc.Id;
        }
        return null;
    }
    
    
    
    /*****************************************************************CDM MERGE SEIVICE STARTED***************************************************************************************************   
Author ...............: IDC, NSC
Date Created .........: 14 Mar, 2019
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class exposed as Business Service to Merge Customer and Account In NSC from data Received from CDM To NSC and called via SOUP. 
*********************************************************************************************************************************************************************************************/    
    webservice static CustomerMergeResponse syncCustomerMerge(CustomerMergeRequest inputMergeReq) {
        System.debug(inputMergeReq);
        CustomerMergeResponse mrgRes = new CustomerMergeResponse();
        Savepoint sp = NULL;
        try
        {
            CustomerMergeRequest CDMcmr = inputMergeReq; 
            mrgRes = CDMUtil.validateMergeRequest(CDMcmr);  // check if both parties present and  MCN should not be blank for all parties
            
            if(mrgRes.status == STATUS_SUCCESS) {
                sp = Database.setSavepoint();
                
                String mergeError = MergeCustomer(CDMcmr);
                
                if(String.isNotBlank(mergeError)) {
                    mrgRes.status = STATUS_FAILURE;
                    mrgRes.message = mergeError;
                }
            } 
        }
        catch(Exception e) {
            if(sp != NULL) Database.RollBack(sp);
            mrgRes.status = STATUS_FAILURE;
            mrgRes.message = e.getMessage();
        }
        
        CDMLogger.logCustomerMergeSync(JSON.serialize(inputMergeReq), JSON.serialize(mrgRes));        
        return mrgRes;
    }
    
    
    global class CustomerMergeRequest {
        webService String RequestId;  
        webService String RequestName;
        webService String ResolutionStatus;      
        webService String ResolutionStatusMessage;  
        webService String ResolutionType;
        webService String CreationDate;     
        webService String CreatedBy; 
        webService String LastUpdateDate; 
        webService String LastUpdatedBy;   
        webService MergePartyDetailWrapper MergePartyDetail;
    }
    
    global class CustomerMergeResponse {
        webservice String status;
        webservice String message;      
    }
    
    global class MergePartyDetailWrapper {
        webService List<MergePartyWrapper> victimParties;
        webService MergePartyWrapper masterParty;
    }
    
    
    global class MergePartyWrapper {
        webService String PartyId; // accountid
        webService String PartyType; //Account_Party and Customer_Party
        webService String PartyNumber; //mcn
        webService String PartyName; //account name
        webService String MasterFlag; //true or false
    }
    
    
    
    private static String MergeCustomer(CustomerMergeRequest CDMcmr) {        
        Set<ID> Acc_Deac = new Set<ID>();
        Set<ID> Acc_Merg = new Set<ID>();
        Map<id,Account> vctmAccMrgMap= new Map<id,Account>();
        List<Opportunity> updOppLst = new List<Opportunity>();
        List<Account> updAccLst = new List<Account>();
        List<String> prtysMCNSet = new List<String>();
        Account mstrAcc; 
        
        
        // get list of victim  party and Master party with details
        List<MergePartyWrapper> VctmPrts = new List<MergePartyWrapper>(CDMcmr.MergePartyDetail.victimParties); 
        MergePartyWrapper Mstrprty = CDMcmr.MergePartyDetail.masterParty;
        
        //Add master PartyNumber to partiesMCNSet
        prtysMCNSet.add(Mstrprty.PartyNumber);
        
        //Add Victim PartyNumber to partiesMCNSet List
        for(MergePartyWrapper s : VctmPrts){
            prtysMCNSet.add(s.PartyNumber);    
        }       
        
        //Get Victim Parties Account Ids
        for(Account a : [SELECT Id,Master_Customer_Number__c 
                         FROM Account 
                         WHERE Master_Customer_Number__c IN : prtysMCNSet 
                         AND Interface_Source__c = 'CDM'  limit 50000 FOR UPDATE]){ 
                             
                             if(a.Master_Customer_Number__c == Mstrprty.PartyNumber){
                                 mstrAcc = a;
                             }
                             else {
                                 vctmAccMrgMap.put(a.id,a);
                             }
                         }
        
        String vldPrtyNbrs = CDMUtil.validateAccountPartyNbrs(mstrAcc, vctmAccMrgMap, CDMcmr);
        
        if(String.isBlank(vldPrtyNbrs)) { // No validation error
            
            // get opportunities for victim accounts and Update Account ids on Victim Opportunities with Master's AccountId
            for(Opportunity op : [select Id from Opportunity where AccountId IN : vctmAccMrgMap.keySet() limit 50000]){
                op.AccountId=mstrAcc.Id;            
                updOppLst.add(op);
            } 
            
            if(updOppLst.size() > 0){
                update updOppLst ;
            }
            
            // Update Victim Account Parties IsMerged__c Field as True
            for(Account ac : vctmAccMrgMap.values()) {
                ac.CDM_IsMerged__c=true;
                updAccLst.add(ac);
            }
            
            //for(ID d : Acc_Merg_Map.keyset()){ Account acc = Acc_Merg_Map.get(d); acc.CDM_IsMerged__c=False; update_Acc.add(acc); }
            if(updAccLst.size() > 0) {
                update updAccLst ;
            }  
        } 
        
        return vldPrtyNbrs;
    }
    
}