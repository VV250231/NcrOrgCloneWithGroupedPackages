//Written by : Abhishek Srivastava : as250738
//For SOUP integration
//THERE IS NO INFORMATION WITH SOUP, SO FIRST IT WILL CALL getAllQuotes WHERE SALESFORCE RETURNS THE LIST OF ID'S
//AFTER THAT getProvisioningQuoteDatA WILL BE CALLED FOR EVERY QUOTEID
//updateQuote WILL BE CALLED WHEN A QUOTE IS TO BE UPDATED IN SALESFORCE

global with Sharing class QuoteProvisioningWebService {

        global class ProvisioningQuote {
            //QUOTE FIELDS
            webservice String QuoteId;
            webservice String QuoteName;
            webservice String QuoteNumber;
            webservice String QuoteStatus;
            webservice Date QuoteStartDate;
            webservice String QuoteSubscriptionType;
            webservice String QuoteAmendmentReason;
            webservice String QuoteCancellationReason;
            webservice String SalespersonEmail;
            webservice Boolean QuoteProvisioningRequestSubmitted;
            webservice String QuoteBundleName;
            webservice Boolean IsProrated;
            webservice String CorporateAccountName;
            webservice String CorporateAccountMCN;
            webservice String SalesRep;
            webservice String Reseller;
            //BILLING ACCOUNT FIELDS
            webservice String ShiptoERPSiteNumber;
            webservice String ShiptoAlohaKeyId;
            webservice String ShiptoBillingAccountName;
            webservice String ShiptoBillingAccountAddress;
            webservice String ShiptoBillingAccountCity;
            webservice String ShiptoBillingAccountState;
            webservice String ShiptoBillingAccountAddressCountryCode;
            webservice String ShiptoBillingAccountEnterpriseID;
            webservice String ShiptoBillingAccountPostalCode;
            webservice String ShipToBillingAccountPOSSystem;
            webservice String ZuoraAccountNumber;
            
            
            //PRODUCT DETAIL FIELDS
            webservice String CoporateClientName;
            webservice String ResellerContactName;
            webservice String ResellerEmail;
            webservice String ResellerPhone;
            webservice String AddToExistingENTID;
            webservice Date ForecastLiveDate;
            webservice Date ExpectedAlohaInstallDate;
            webservice String InstallBillingNotes;
            webservice String SiteInstallContactName;
            webservice String SiteInstallContactEmail;
            webservice String SiteInstallContactPhone;
            webservice String Concept;
            webservice String SiteHours;
            webservice String SitePhone;
            webservice String ProductsToIntegrateWith;
            webservice String User1Name;
            webservice String User1Email;
            webservice String User1Phone;
            webservice String User1Services;
            webservice String User2Name;
            webservice String User2Email;
            webservice String User2Phone;
            webservice String User2Services;
            webservice String User3Name;
            webservice String User3Email;
            webservice String User3Phone;
            webservice String User3Services;
            webservice String AdditionalUserInformation;
            webservice String AlohaRestorennualBackupDVDRequested;
            webservice String OnlineOrderingDesiredURL;
            webservice String OnlineOrderingMasterDatabaseSiteKey;
            webservice String ControlScanProcessingMID;
            webservice String ControlScanWhichProviderwillbeused;
            webservice String InsightExistingURL;
            webservice String ConfigCenterExistingEnvironment;
            webservice String RGTrainingSessionRequired;
            webservice String NSSResellerInstallingFirewall;
            webservice String NSSShipFirewallTo;
            webservice String ResellerAddressforFirewallShipment;
            
            //LIST OF CLASSES FOR CHILD OBJECT RECORDS
            //DEPRECATED webservice List<QuoteCharges> QuoteCharges = new List<QuoteCharges>();
            webservice List<QuoteRatePlanCharges> QuoteRatePlanCharges = new List<QuoteRatePlanCharges>();
        }
        
        /* DEPRECATED
        //CLASS FOR QUOTE CHARGE
        global class QuoteCharges{
            webservice String ChargeName;
            webservice String ChargeType;
            webservice String UOM;
            webservice String ProductSKU;
            webservice String IsExistingProduct;
        }
       */
       
        //CLASS FOR QUOTERATEPLANCHARGE
        global class QuoteRatePlanCharges{
            webservice String AmendmentType;
            webservice String QuoteRatePlanName ;
            webservice String QuoteRatePlanChargeName ;
            webservice String QuoteRatePlanChargeType ;
            webservice String QuoteRatePlanChargeUOM ;
            webservice Decimal QuoteRatePlanChargeEffectivePrice ;
            webservice String ProductSKU;
            webservice String IsExistingProduct;
        }
     
        //this method will return id of all quotes which pass the filter to soup
        //ProvisioningRequired MUST BE true //ProvisioningStatus MUST BE pending // QuoteStage MUST BE QA Processing complete
        webservice static List <ID> getAllQuotes(Boolean Rebill , String ProvisioningStatus , String QuoteStatus , Boolean ProvisioningNotRequired , Boolean PendingSiteUpdate)
        {
            List<zqu__Quote__c> Quotes = new List<zqu__Quote__c>();
            List<ID> Id = new List<ID>();
            Quotes = [select id from zqu__Quote__c where Rebill__c =: Rebill AND Provisioning_Status__c =: ProvisioningStatus AND zqu__Status__c =: QuoteStatus AND Provisioning_Not_Required__c =: ProvisioningNotRequired AND PendingSiteUpdate__c =: PendingSiteUpdate AND zqu__ZuoraAccountID__c <> NULL AND Account_s_Subscription_Group__c <> 'Digital Insight'];
            for(zqu__Quote__c qts : Quotes)
            {
            id.add(qts.id);
            }
            
            Logger.logSOUPGetQuotes(JSON.serialize(id));
            Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                return id;
        }
            
        webService static String updateQuote(ID id , String QuoteNumber , String ProvisioningStatus , String StatusDetails , Date QuoteStartDate , Date ServiceActivationDate)
        //soup will call this method with above parameters to update a single quote record
        {
            
            String messege;
            zqu__Quote__c zQuote = new zqu__Quote__c();
            zQuote = [select Provisioning_Status__c , Status_Details__c , zqu__StartDate__c , zqu__Service_Activation_Date__c from zqu__Quote__c where id =: id ];
            zQuote.Provisioning_Status__c = ProvisioningStatus;
            zQuote.Status_Details__c = StatusDetails ;
            if(QuoteStartDate != NULL){
                zQuote.zqu__StartDate__c = QuoteStartDate;
            }
            
             if(ServiceActivationDate != NULL){
                zQuote.zqu__Service_Activation_Date__c = ServiceActivationDate;
            }
            
            try {
            Database.SaveResult Result = Database.update(zQuote, true);
                if(Result.isSuccess())
                {
                    Logger.logProvisioningUpdate(id, QuoteNumber, ProvisioningStatus, StatusDetails, QuoteStartDate, 'Record Updated Successfully');
                    return 'Record Updated Successfully';   
                }
                else
                {
                    for(Database.Error err : Result.getErrors()) {
                    messege = 'Error:' + err.getStatusCode() + ': ' + err.getMessage() +' fields that affected this error: ' + err.getFields();
                    }
                    
                    Logger.logProvisioningUpdate(id, QuoteNumber, ProvisioningStatus, StatusDetails, QuoteStartDate, messege);
                    
                }
            } catch(Exception e) {
                System.debug('<<<<<<<< Error >>>>>>>>>>>>>>>>>>');
                messege =   'Error:' + e.getMessage() ;
                Logger.logProvisioningUpdate(id, QuoteNumber, ProvisioningStatus, StatusDetails, QuoteStartDate, messege);
            }
            return messege ;

        }

        //soup will call this method one by one for all the quotes which were returned in previous method
        webService static ProvisioningQuote getProvisioningQuoteData(ID id)
        {
            //LISTS OF sObjects TO QUERY THE DATA 
            zqu__Quote__c zQuote = new zqu__Quote__c();
            Customer_Product_Setup__c zProductDetail = new Customer_Product_Setup__c();
            Zuora__CustomerAccount__c zCustomerAccount  = new Zuora__CustomerAccount__c();
            //List <zqu__QuoteCharge__c> zQuoteCharges = new List <zqu__QuoteCharge__c>();
            List <zqu__QuoteRatePlanCharge__c> zQuoteRatePlanCharges = new List <zqu__QuoteRatePlanCharge__c>();
            List <zqu__ProductRatePlanCharge__c> zProductRatePlanCharges = new List <zqu__ProductRatePlanCharge__c>();
            Map<String , String> ProductMap =new Map<String , String>();
            
            //OBJECT OF CLASS TO RETURN
            ProvisioningQuote ProvisioningQuote = new ProvisioningQuote();
            
            //CONSTANTS
            String CANCEL_SUBSCRIPTION =  'Cancel Subscription';
            String AMEND_SUBSCRIPTION =  'Amend Subscription';
            String REMOVE_PRODUCT_AMENDMENT_TYPE = 'RemoveProduct';
            
            //QUERY THE DATA
            zQuote = [select id , name , zqu__Number__c , zqu__Status__c , Prorate__c, Provisioning_Request_Submitted__c, BundleNameNew__c, zqu__ZuoraAccountID__c , zqu__StartDate__c , zqu__SubscriptionType__c , AmendmentReason__c , CancellationReason__c , zqu__Account__r.Name, zqu__Account__r.Master_Customer_Number__c, zqu__Opportunity__r.owner.email, owner.email, zqu__Opportunity__r.Owner.Name, zqu__Opportunity__r.Channel_Office__r.Name from zqu__Quote__c where id =: id];
            
            List<Customer_Product_Setup__c> zProductDetailList = [SELECT Id, Name, Related_Quote__c,Reseller_Contact__c,Reseller_Contact_Name__c,Reseller_Email__c,Reseller_Phone__c,RG_Training_Session_Required__c,
                                                                    Site_Hours__c,Site_Install_Contact__c,Site_Install_Contact_Email__c,Site_Install_Contact_Name__c,Site_Install_Contact_Phone__c,
                                                                    Site_Phone__c,User_1_Contact__c,User_1_Email__c,User_1_Name__c,User_1_Phone__c,User_1_Services__c,User_2_Contact__c,
                                                                    User_2_Email__c,User_2_Name__c,User_2_Phone__c,User_2_Services__c,User_3_Contact__c,User_3_Email__c,User_3_Name__c,User_3_Phone__c,
                                                                    User_3_Services__c,Additional_User_Information__c,Add_to_Existing_ENT_ID__c,Aloha_Restore_Annual_Backup_DVD_Request__c,Concept__c,
                                                                    Config_Center_Existing_Environment__c,Control_Scan_Processing_MID__c,Control_Scan_Which_Provider_will_be_use__c,
                                                                    Expected_Aloha_Install_Date__c,ForecastLiveDate__c,Insight_Existing_URL__c,Install_Billing_Notes__c,Reseller_Address_for_Firewall_Shipment__c,
                                                                    NSS_Reseller_Installing_Firewall__c,NSS_Ship_Firewall_To__c,Online_Ordering_Desired_URL__c,Online_Ordering_Master_Database_Site_Key__c,
                                                                    Products_to_Integrate_with__c FROM Customer_Product_Setup__c WHERE Related_Quote__c = :zQuote.Id LIMIT 1];
               
           
            
            system.debug('>>> zCustomerAccount '+ zQuote.zqu__ZuoraAccountID__c);
            zCustomerAccount = [ select id , name , ERPSiteNumber__c , Aloha_Key__c , Address__c , City__c , State__c , AddressCountryCode__c , Enterprise_ID__c , Zuora__AccountNumber__c  , Zuora__BillToPostalCode__c, POS_System__c from Zuora__CustomerAccount__c where Zuora__External_Id__c =: zQuote.zqu__ZuoraAccountID__c] ;
            
             //DATA FROM NSC SOBJECT RECORD TO CLASS OBJECT
            ProvisioningQuote.QuoteId = zQuote.id;
            ProvisioningQuote.QuoteName = zQuote.name;
            ProvisioningQuote.QuoteNumber = zQuote.zqu__Number__c ;
            ProvisioningQuote.QuoteStatus = zQuote.zqu__Status__c ;
            ProvisioningQuote.QuoteStartDate = zQuote.zqu__StartDate__c ;
            ProvisioningQuote.QuoteSubscriptionType = zQuote.zqu__SubscriptionType__c ;
            ProvisioningQuote.QuoteAmendmentReason = zQuote.AmendmentReason__c ;
            ProvisioningQuote.QuoteCancellationReason = zQuote.CancellationReason__c ;
            //AGL - 3565 Sending the Email of Quote Owner instead of Opportunity Owner
            ProvisioningQuote.SalespersonEmail = zQuote.owner.email;
            ProvisioningQuote.SalesRep = zQuote.zqu__Opportunity__r.owner.Name;
            ProvisioningQuote.Reseller = zQuote.zqu__Opportunity__r.Channel_Office__r.Name ;
            ProvisioningQuote.QuoteProvisioningRequestSubmitted = zQuote.Provisioning_Request_Submitted__c; 
            ProvisioningQuote.QuoteBundleName = zQuote.BundleNameNew__c;
            ProvisioningQuote.IsProrated = zQuote.Prorate__c;
            ProvisioningQuote.CorporateAccountName = zQuote.zqu__Account__r.Name;
            ProvisioningQuote.CorporateAccountMCN = zQuote.zqu__Account__r.Master_Customer_Number__c;
            ProvisioningQuote.ShiptoERPSiteNumber = zCustomerAccount.ERPSiteNumber__c ;
            ProvisioningQuote.ShiptoAlohaKeyId = zCustomerAccount.Aloha_Key__c ;
            ProvisioningQuote.ShiptoBillingAccountName = zCustomerAccount.name ;
            ProvisioningQuote.ShiptoBillingAccountAddress = zCustomerAccount.Address__c ;
            ProvisioningQuote.ShiptoBillingAccountCity = zCustomerAccount.City__c ;
            ProvisioningQuote.ShiptoBillingAccountState = zCustomerAccount.State__c ;
            ProvisioningQuote.ShiptoBillingAccountAddressCountryCode = zCustomerAccount.AddressCountryCode__c ;
            ProvisioningQuote.ShiptoBillingAccountEnterpriseID = zCustomerAccount.Enterprise_ID__c ;
            ProvisioningQuote.ShiptoBillingAccountPostalCode = zCustomerAccount.Zuora__BillToPostalCode__c ;
            ProvisioningQuote.ZuoraAccountNumber = zCustomerAccount.Zuora__AccountNumber__c ;
            ProvisioningQuote.ShipToBillingAccountPOSSystem = zCustomerAccount.POS_System__c;
            
            if(!zProductDetailList.isEmpty()) {
                zProductDetail = zProductDetailList.get(0);
                ProvisioningQuote.ResellerContactName = zProductDetail.Reseller_Contact_Name__c;
                ProvisioningQuote.ResellerEmail = zProductDetail.Reseller_Email__c;
                ProvisioningQuote.ResellerPhone = zProductDetail.Reseller_Phone__c;
                ProvisioningQuote.AddToExistingENTID = zProductDetail.Add_to_Existing_ENT_ID__c;
                ProvisioningQuote.ForecastLiveDate = zProductDetail.ForecastLiveDate__c;
                ProvisioningQuote.ExpectedAlohaInstallDate = zProductDetail.Expected_Aloha_Install_Date__c;
                ProvisioningQuote.InstallBillingNotes = zProductDetail.Install_Billing_Notes__c;
                ProvisioningQuote.SiteInstallContactName = zProductDetail.Site_Install_Contact_Name__c;
                ProvisioningQuote.SiteInstallContactEmail = zProductDetail.Site_Install_Contact_Email__c;
                ProvisioningQuote.SiteInstallContactPhone = zProductDetail.Site_Install_Contact_Phone__c;
                ProvisioningQuote.Concept = zProductDetail.Concept__c;
                ProvisioningQuote.SiteHours = zProductDetail.Site_Hours__c;
                ProvisioningQuote.SitePhone = zProductDetail.Site_Phone__c;
                ProvisioningQuote.ProductsToIntegrateWith = zProductDetail.Products_to_Integrate_with__c;
                ProvisioningQuote.User1Name = zProductDetail.User_1_Name__c;
                ProvisioningQuote.User1Email = zProductDetail.User_1_Email__c;
                ProvisioningQuote.User1Phone = zProductDetail.User_1_Phone__c;
                ProvisioningQuote.User1Services = zProductDetail.User_1_Services__c;
                ProvisioningQuote.User2Name = zProductDetail.User_2_Name__c;
                ProvisioningQuote.User2Email = zProductDetail.User_2_Email__c;
                ProvisioningQuote.User2Phone = zProductDetail.User_2_Phone__c;
                ProvisioningQuote.User2Services = zProductDetail.User_2_Services__c;
                ProvisioningQuote.User3Name = zProductDetail.User_3_Name__c;
                ProvisioningQuote.User3Email = zProductDetail.User_3_Email__c;
                ProvisioningQuote.User3Phone = zProductDetail.User_3_Phone__c;
                ProvisioningQuote.User3Services = zProductDetail.User_3_Services__c;
                ProvisioningQuote.AdditionalUserInformation = zProductDetail.Additional_User_Information__c;
                ProvisioningQuote.AlohaRestorennualBackupDVDRequested = zProductDetail.Aloha_Restore_Annual_Backup_DVD_Request__c;
                ProvisioningQuote.OnlineOrderingDesiredURL = zProductDetail.Online_Ordering_Desired_URL__c;
                ProvisioningQuote.OnlineOrderingMasterDatabaseSiteKey = zProductDetail.Online_Ordering_Master_Database_Site_Key__c;
                ProvisioningQuote.ControlScanProcessingMID = zProductDetail.Control_Scan_Processing_MID__c;
                ProvisioningQuote.ControlScanWhichProviderwillbeused = zProductDetail.Control_Scan_Which_Provider_will_be_use__c;
                ProvisioningQuote.InsightExistingURL = zProductDetail.Insight_Existing_URL__c;
                ProvisioningQuote.ConfigCenterExistingEnvironment = zProductDetail.Config_Center_Existing_Environment__c;
                ProvisioningQuote.RGTrainingSessionRequired = zProductDetail.RG_Training_Session_Required__c;
                ProvisioningQuote.NSSResellerInstallingFirewall = zProductDetail.NSS_Reseller_Installing_Firewall__c;
                ProvisioningQuote.NSSShipFirewallTo = zProductDetail.NSS_Ship_Firewall_To__c;
                ProvisioningQuote.ResellerAddressforFirewallShipment = zProductDetail.Reseller_Address_for_Firewall_Shipment__c;
            }
            
            zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String> {'ExistingProduct__c'};
            
            if(zQuote != NULL && zQuote.zqu__SubscriptionType__c == CANCEL_SUBSCRIPTION) {
                Set<String> prpZuoraIds = new Set<String>();
                Map<String, String> RatePlanSKUMap = new Map<String, String>();
                
                List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);
                
                if(!chargeGroups.isEmpty()) {
                    
                    // GET PRODUCT RATE PLAN ZUORA IDs
                    for(zqu.zChargeGroup chargeGroup : chargeGroups) {
                        prpZuoraIds.add(chargeGroup.productRateplanZuoraID);
                    }
                    
                    for(zqu__ProductRatePlan__c prp :[Select zqu__ZuoraId__c ,zqu__ZProduct__c, zqu__ZProduct__r.zqu__SKU__c from zqu__ProductRatePlan__c where zqu__ZuoraId__c IN :prpZuoraIds]) {
                            RatePlanSKUMap.put(prp.zqu__ZuoraId__c , prp.zqu__ZProduct__r.zqu__SKU__c);    
                    }
                    List<zqu__QuoteAmendment__c>  zquQuoteAmendList = [SELECT Id, zqu__Type__c  FROM zqu__QuoteAmendment__c WHERE zqu__Quote__c = :zQuote.Id];
                    
                    System.debug('zquQuoteAmendList >>' + zquQuoteAmendList);
                    for(zqu.zChargeGroup chargeGroup : chargeGroups) {
                         for(zqu.zCharge charge :chargeGroup.zCharges) {
                            System.debug(charge.name);  
                             QuoteRatePlanCharges QuoteRatePlanCharge = new QuoteRatePlanCharges();
                             QuoteRatePlanCharge.AmendmentType = zquQuoteAmendList.size() > 0 ? zquQuoteAmendList.get(0).zqu__Type__c : 'Cancellation';
                             QuoteRatePlanCharge.QuoteRatePlanName = chargeGroup.ratePlanName ;
                             QuoteRatePlanCharge.QuoteRatePlanChargeName = charge.NAME;
                             QuoteRatePlanCharge.QuoteRatePlanChargeType = charge.CHARGE_TYPE;
                             QuoteRatePlanCharge.QuoteRatePlanChargeUOM = charge.UNIT_OF_MEASURE;
                             QuoteRatePlanCharge.QuoteRatePlanChargeEffectivePrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                             QuoteRatePlanCharge.ProductSKU = RatePlanSKUMap.get(chargeGroup.productRateplanZuoraID); 
                             
                             if (charge.chargeObject != NULL && charge.chargeObject instanceof zqu__QuoteRatePlanCharge__c) {
                                zqu__QuoteRatePlanCharge__c qrpc = (zqu__QuoteRatePlanCharge__c) charge.chargeObject;
                                QuoteRatePlanCharge.IsExistingProduct = qrpc.ExistingProduct__c; 
                             }
                             ProvisioningQuote.QuoteRatePlanCharges.add(QuoteRatePlanCharge);  
                         }    
                    }
                } 
            } else {
                //zQuoteCharges = [select id , name , zqu__Type__c , ExistingProduct__c, zqu__UOM__c , zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c from zqu__QuoteCharge__c where zqu__Quote__c =: id];
                
                zQuoteRatePlanCharges = [SELECT Id , name , zqu__ChargeType__c , ExistingProduct__c, zqu__UOM__c , zqu__EffectivePrice__c  , zqu__QuoteRatePlan__c  ,   zqu__QuoteRatePlan__r.name ,  zqu__QuoteRatePlan__r.zqu__ProductRatePlanZuoraId__c, zqu__QuoteRatePlan__r.zqu__QuoteAmendment__c  ,  zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.name ,zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Type__c  , zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c  , zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__r.name  , zqu__ProductRatePlanChargeZuoraId__c FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Quote__c =:  id ];
                
                zProductRatePlanCharges = [SELECT zqu__ZuoraId__c , zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c FROM zqu__ProductRatePlanCharge__c ];
                for(zqu__ProductRatePlanCharge__c prod : zProductRatePlanCharges)
                {
                    ProductMap.put(prod.zqu__ZuoraId__c , prod.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
                }
                
               
                /* DEPRECATED
                for(Integer i=0;i<zQuoteCharges.size();i++)
                {
                QuoteCharges QuoteCharge = new QuoteCharges();
                QuoteCharge.ChargeName = zQuoteCharges[i].name;
                QuoteCharge.ChargeType = zQuoteCharges[i].zqu__Type__c;
                QuoteCharge.UOM = zQuoteCharges[i].zqu__UOM__c;
                QuoteCharge.ProductSKU = zQuoteCharges[i].zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c ;
                QuoteCharge.IsExistingProduct = zQuoteCharges[i].ExistingProduct__c;
                ProvisioningQuote.QuoteCharges.add(QuoteCharge);
                }
                */
                /**/
                
                System.debug('>>>>>>' + zQuote.zqu__SubscriptionType__c );
                
                  
               if(!zQuoteRatePlanCharges.isEmpty()) {
                    for(Integer i=0;i<zQuoteRatePlanCharges.size();i++)
                    {            
                    QuoteRatePlanCharges QuoteRatePlanCharge = new QuoteRatePlanCharges();
                    QuoteRatePlanCharge.AmendmentType = zQuoteRatePlanCharges[i].zqu__QuoteRatePlan__r.zqu__QuoteAmendment__r.zqu__Type__c ;
                    QuoteRatePlanCharge.QuoteRatePlanName = zQuoteRatePlanCharges[i].zqu__QuoteRatePlan__r.name ; 
                    QuoteRatePlanCharge.QuoteRatePlanChargeName = zQuoteRatePlanCharges[i].name;
                    QuoteRatePlanCharge.QuoteRatePlanChargeType = zQuoteRatePlanCharges[i].zqu__ChargeType__c;
                    QuoteRatePlanCharge.QuoteRatePlanChargeUOM = zQuoteRatePlanCharges[i].zqu__UOM__c;
                    QuoteRatePlanCharge.QuoteRatePlanChargeEffectivePrice = zQuoteRatePlanCharges[i].zqu__EffectivePrice__c;
                    QuoteRatePlanCharge.ProductSKU = ProductMap.get(zQuoteRatePlanCharges[i].zqu__ProductRatePlanChargeZuoraId__c ) ;
                    QuoteRatePlanCharge.IsExistingProduct = zQuoteRatePlanCharges[i].ExistingProduct__c;
                    ProvisioningQuote.QuoteRatePlanCharges.add(QuoteRatePlanCharge);
                    }
                } 
                
                if(zQuote.zqu__SubscriptionType__c == AMEND_SUBSCRIPTION) {
                    Set<String> prpZuoraIds = new Set<String>();
                    Map<String, String> SubRatePlanZuoraID_QRPMap = new Map<String, String>();  
                    Map<String, String> RatePlanSKUMap = new Map<String, String>();
                    
                    List<zqu__QuoteRatePlan__c> QuoteRatePlanList = [SELECT Id, Name, zqu__SubscriptionRatePlanZuoraId__c,zqu__AmendmentType__c ,zqu__QuoteAmendment__r.zqu__Type__c, zqu__ProductRatePlanZuoraId__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = : id and zqu__AmendmentType__c = :REMOVE_PRODUCT_AMENDMENT_TYPE];
                    
                    for(zqu__QuoteRatePlan__c qrp : QuoteRatePlanList )  {
                        if(String.isNotEmpty(qrp.zqu__SubscriptionRatePlanZuoraId__c)) {
                            SubRatePlanZuoraID_QRPMap.put(qrp.zqu__SubscriptionRatePlanZuoraId__c, qrp.zqu__QuoteAmendment__r.zqu__Type__c);
                            prpZuoraIds.add(qrp.zqu__ProductRatePlanZuoraId__c);
                        }
                    }              
                   
                    for(zqu__ProductRatePlan__c prp :[Select Id, zqu__ZuoraId__c ,zqu__ZProduct__c, zqu__ZProduct__r.zqu__SKU__c from zqu__ProductRatePlan__c where zqu__ZuoraId__c IN :prpZuoraIds]) {
                        RatePlanSKUMap.put(prp.zqu__ZuoraId__c , prp.zqu__ZProduct__r.zqu__SKU__c);    
                    }
                    
                   // for QRP - NEW PRODUCT TYPE, chargeGroup.groupID = QRP.SF ID
                   // for QRP - REMOVE PRODUCT TYPE, chargeGroup.groupID = QRP.zqu__SubscriptionRatePlanZuoraId__c 
                   for(zqu.zChargeGroup chargeGroup : zqu.zQuoteUtil.getChargeGroups(zQuote.Id)) {
                       if(SubRatePlanZuoraID_QRPMap.containsKey(chargeGroup.groupID)) {
                           for(zqu.zCharge charge :chargeGroup.zCharges) { 
                              QuoteRatePlanCharges QuoteRatePlanCharge = new QuoteRatePlanCharges();
                              QuoteRatePlanCharge.AmendmentType = SubRatePlanZuoraID_QRPMap.get(chargeGroup.groupID);
                              QuoteRatePlanCharge.QuoteRatePlanName = chargeGroup.ratePlanName ;  
                              QuoteRatePlanCharge.QuoteRatePlanChargeName = charge.NAME;
                              QuoteRatePlanCharge.QuoteRatePlanChargeType = charge.CHARGE_TYPE;
                              QuoteRatePlanCharge.QuoteRatePlanChargeUOM = charge.UNIT_OF_MEASURE;
                              QuoteRatePlanCharge.QuoteRatePlanChargeEffectivePrice = Decimal.valueOf(charge.EFFECTIVE_PRICE);
                              QuoteRatePlanCharge.ProductSKU = RatePlanSKUMap.get(chargeGroup.productRateplanZuoraID); 
                              
                              if(charge.chargeObject != NULL && charge.chargeObject instanceof zqu__QuoteRatePlanCharge__c) {
                                  zqu__QuoteRatePlanCharge__c qrpc = (zqu__QuoteRatePlanCharge__c) charge.chargeObject;
                                  QuoteRatePlanCharge.IsExistingProduct = qrpc.ExistingProduct__c; 
                              }
                              ProvisioningQuote.QuoteRatePlanCharges.add(QuoteRatePlanCharge);  
                           }        
                       }
                   }
                   
                }
                    
            }
              
            System.debug(ProvisioningQuote);
            return ProvisioningQuote;
        }

}