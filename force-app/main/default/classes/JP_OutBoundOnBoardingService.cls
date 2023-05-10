/*************************************************************************************************
*   ClassName :   JP_OutBoundOnBoardingService
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1591     03-12-2022      Puneet Bhatia      Added changes to send Payment processing application for onboarding once opportunity gets Closed/Booked.
EBA_SF-1816		25-2-2022		Saurav Gautam	   Added POS_Subscription_Discount__c
EBA_SF-1816		4-3-2022		Saurav Gautam	   Added Payments_Features__c 
EBA_SF-2024		9-9-2022		Monika	   Payment Processing: Option to Withdraw Payments Application (Non-CPQ)
*************************************************************************************************/
public Without Sharing class  JP_OutBoundOnBoardingService {
    public static String initiateMerchantOnboarding(String oppId, String billingAccs) {
        String accessToken = getAccessToken();
        String response = submitRequestNew(accessToken, oppId, billingAccs);
        return response;        
    }
    
    
    /*public static String initiateMrchntBrdQuote(String QteId) {
String accessToken = getAccessToken(); 
String response = submitRequestfromQte(accessToken, QteId);
return response;

}*/
    
    public static String getAccessToken() {
        /*String labelToken = Label.Jetpay_Token;
        if(String.isNotBlank(labelToken)) {
            return labelToken;
        } else {*/
            Http http = new Http();
            HTTPRequest req = new HTTPRequest();
            //JP_EndPoint__c endpoint = null;
            //string endpointURL = '';
            String accessToken = '';
            
           /* try {
                endpoint = JP_EndPoint__c.getValues('JPAuthService');
                endpointURL = endpoint.EndPoint_URL__c;
            } catch (Exception e) {
                system.debug('Failed to find Custom Setting ZP_EndPoint__c named "ZPAuthService". Please ensure it is created/populated and try again.');
                
            }
            
            string encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(endpoint.User_Name__c + ':' + endpoint.Password__c));
            req.setEndpoint(endpointURL);*/
            req.setEndpoint('callout:JPAuthService');
           // req.setHeader('Authorization', 'Basic ' + encodedCredentials);
            req.setHeader('Content-Type', 'application/json');
            req.setMethod('POST');
            HTTPResponse resp = null;
            if (!Test.isRunningTest()) {
                resp = http.Send(req);
            } else {
                resp = new HttpResponse();
                resp.setStatusCode(200);
            }
            
            
            if (resp.getStatusCode() != 200) {
                system.debug('Callout failed! ' + resp.getStatusCode() + ': ' + resp.getStatus());
            } else {
                JSONParser parser = JSON.createParser(resp.getBody());
                String s = parser.getText();
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.VALUE_STRING) && parser.getCurrentName() == 'access_token') {
                        accessToken = parser.getText();
                    }
                }
                if (String.isEmpty(accessToken)) {
                    system.debug('## Access Token was not returned');
                } else {
                    System.debug('JP_STEP 1 : ACCESS TOKEN RECEIVED' + accessToken);
                }
                
            }
            return accessToken;
        //}
    }
    
    public static List < customFieldWrapper > getTemplate(String accessToken) {
        try{
            TemplateWrapper templateFields = new TemplateWrapper();
            Http http = new Http();
            HTTPRequest req = new HTTPRequest();
            JP_EndPoint__c endpoint = null;
            string endpointURL = '';
            
            try {
                endpoint = JP_EndPoint__c.getValues('JPTemplate');
                endpointURL = endpoint.EndPoint_URL__c;
            } catch (Exception e) {
                system.debug('Failed to find Custom Setting ZP_EndPoint__c named "ZPAuthService". Please ensure it is created/populated and try again.');
                
            }
            string encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(endpoint.User_Name__c + ':' + endpoint.Password__c));
            req.setEndpoint(endpointURL);
            System.debug('___endcodeCredentials' + encodedCredentials);
            req.setHeader('Authorization', 'Bearer ' + accessToken);
            req.setHeader('payos-application-key', '123');
            req.setHeader('x-app-name', 'pos-payos');
            req.setTimeout(120000);
            req.setMethod('GET');
            
            HTTPResponse resp = null;
            if (!Test.isRunningTest()) { 
                resp = http.Send(req);
            } else {
                resp = new HttpResponse();
                resp=JP_Mock_Service.respond(req);
            }
            
            system.debug('##'+resp.getBody());
            if (resp.getStatusCode() != 200) {
                system.debug('Callout failed! ' + resp.getStatusCode() + ': ' + resp.getStatus());
            } else {
                templateFields = (TemplateWrapper) JSON.deserialize(resp.getBody(), TemplateWrapper.class);
                JSONParser parser = JSON.createParser(resp.getBody());
                System.debug('JP_STEP 2 : TEMPLATE RECEIVED:');
                
                
            }
            return templateFields.CustomFields;
        }catch(Exception e){
            throw new TemplateException('Template Called failed to retrieve fields'+e);
        }
    }
    /*public static Map<String, String> fechCFMAP() {
JP_ProdCode_Price_map__mdt[] cf = [SELECT MasterLabel, QualifiedApiName, Product_Code__c FROM JP_ProdCode_Price_map__mdt];
Map<String, String> cfmap=new Map<String, String>();
for (JP_ProdCode_Price_map__mdt c : cf) {
cfmap.put(c.MasterLabel.toUpperCase(),c.Product_Code__c);
}
return cfmap;

}*/
    public static String handlePhone(String Phone) {
        String p= (Phone).replaceAll('\\D', '');
        p=p.removeStart('0'); 
        p=p.removeStart('1');
        if(p.length()>10)
            p=p.left(10);
        return p;
    }
    /*public static String submitRequestfromQte(String accessToken, String QteId) {
String Status = 'Success';
List < NCR_Payments_Site__c > nps = new List < NCR_Payments_Site__c > ();
List < logObject > log = new List < logObject > ();
List < String > failedSites = new List < String > ();
HttpResponse submitAppResponse;
JSONGenerator submitAppJSON;
Map<String, String> cfMap = fechCFMAP();//{'pricing.ACHReturnFee' => '9614-9018-P100','pricing.ACHProcessingTrans' => '9614-9017-P100','pricing.AmexAuthFee' => '9614-9019-P100','pricing.AuthFee' => '9614-9030-P100','pricing.SettleFee' => '9614-9035-P100','pricing.annualfee' => '9614-9025-P100','pricing.annualPCI' => '9614-9026-P100','pricing.cvv2' => '9614-9042-P100','pricing.helpdeskfee' => '9614-9045-P100','pricing.monthlyminimum' => '9614-9002-P100','pricing.applicationfee' => '9614-9027-P100','pricing.GatewayMonthly' => '9614-9043-P100','pricing.GatewayPerTrans' => '9614-9044-P100','pricing.MonthlyMaint' => '9614-9003-P100','pricing.PCIMonthly' => '9614-9011-P100','pricing.Chargebacks' => '9614-9038-P100','pricing.Retrievals' => '9614-9006-P100','pricing.AcctUpdaterPerSuccess' => '9614-9014-P100','pricing.AcctUpdaterPerTxn' => '9614-9015-P100','pricing.AVS' => '9614-9029-P100','pricing.BatchFee' => '9614-9036-P100','pricing.reportingfee' => '9614-9010-P100','pricing.acctsetupfee' => '9614-9013-P100','pricing.MerlinkCBs' => '9614-9039-P100','pricing.NSF' => '9614-9007-P100','pricing.DebitAuthFee' => '9614-9009-P100','pricing.AmexSettleFee' => '9614-9024-P100','pricing.PINDebitAccessFee' => '9614-9050-P100','pricing.pricingtype' => 'lines','pricing.AmexPT' => '9614-9022-P100','pricing.visapt' => '9614-9033-P100','pricing.AmexQual' => '9614-9023-P100','pricing.AmexMID' => '9614-9020-P100','pricing.AmexNonQual' => '9614-9021-P100','pricing.VisaQual' => '9614-9034-P100','pricing.VisaMID' => '9614-9031-P100','pricing.VisaNonQual' => '9614-9032-P100','pricing.RegCompliance' => '9614-9052-P100','pricing.PCINonCompliance' => '9614-9012-P100','pricing.ACHBatchFee' =>'9614-9008-P100','pricing.AcctUpdaterMonthly' => '9614-9016-P100'};

//fetch Quote and Quote Lines fields
SBQQ__Quote__c Qte = [Select id, Name, SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.id,SBQQ__Opportunity2__r.Opportunity_Number__c,SBQQ__Opportunity2__r.Marketing_Program__c,SBQQ__Opportunity2__r.Payments_Rep__r.Name, SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c, POS__c,SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c,SBQQ__Opportunity2__r.Channel_Office__r.Name,SBQQ__Opportunity2__r.Owner.Email,SBQQ__Opportunity2__r.Owner.Name, SBQQ__Opportunity2__r.Contacts__r.Email, SBQQ__Opportunity2__r.Contacts__r.Name,SBQQ__Opportunity2__r.Contacts__r.Phone,SBQQ__Account__c, SBQQ__Account__r.Name, SBQQ__Account__r.Master_Customer_Number__c,SBQQ__Account__r.BillingStreet, SBQQ__Account__r.BillingCity, SBQQ__Account__r.BillingState, SBQQ__Account__r.BillingCountry, SBQQ__Account__r.BillingPostalCode,qtc_Service_Type__c,qtc_Payments_Solution__c,
Deliver_To_Site__c,Deliver_To_Site__r.Name, Deliver_To_Site__r.BillingStreet, Deliver_To_Site__r.BillingCity, Deliver_To_Site__r.BillingState, Deliver_To_Site__r.BillingCountry, Deliver_To_Site__r.BillingPostalCode,Deliver_To_Site__r.Site_Number__c, Deliver_To_Site__r.cdm_Store_Branch_Number__c,
//Quote Contact fields
SBQQ__PrimaryContact__r.Name, SBQQ__PrimaryContact__r.Phone,SBQQ__PrimaryContact__r.Email,Payments_Application_Signee__r.Name,Payments_Application_Signee__r.Phone,Payments_Application_Signee__r.Email,
//Quote Line Fields
(Select id, SBQQ__ListPrice__c, SBQQ__ProductCode__c, qtc_Pricing_Type__c,qtc_Basis_Points__c,qtc_Basis_Points_Percent__c, qtc_Annual_Volume__c, qtc_Average_Check__c from SBQQ__LineItems__r where Service_Offer_Category__c='Payments Processing') from SBQQ__Quote__c    where id=:QteId
];
system.debug('####'+Qte);
//Setting End Point
JP_EndPoint__c endpoint = null;
string endpointURL = '';
endpoint = JP_EndPoint__c.getValues('SubmitApplication');
endpointURL = endpoint.EndPoint_URL__c;
List < customFieldWrapper > jpList;
//Get Template fields
try{
jpList = getTemplate(accessToken);
}catch(Exception e){
logObject lo = new logObject();
lo.status = ('Failure-Exception :' +e).left(250); lo.SubmitAppRequest=submitAppJSON.getAsString(); lo.SubmitAppResponse=submitAppResponse.getBody();lo.qte=Qte;
log.add(lo);
logOutboundRequest(log);
return 'Failure No Site Onboarded, Exception Occured: '+e;
}
if(jpList==null || jpList.size()==0){
return 'Failure No Site Onboarded, Exception Occured in fetching Template Fields: '; 
}
//TODO ITERATE SITES Phase 1 Single Site
Status = 'Success';
submitAppJSON = JSON.createGenerator(true);
//MAIN STARTS
try{
mainQteJSON(submitAppJSON, Qte);
}catch(Exception e){
Status ='Failure:Main JSON Exception' + e;
// return 'Failure:Exception Occured while sending application: '+e;

}

submitAppJSON.writeFieldName('CustomFieldAnswers');
submitAppJSON.writeStartArray();
for (customFieldWrapper jpl: jpList) {
try{
if (jpl.UserDefinedId.equalsIgnoreCase('legal.name')) {
normalJSON(submitAppJSON, Qte.SBQQ__Account__r.Name, jpl);
}
if (jpl.UserDefinedId.equalsIgnoreCase('legal.address')) {
normalAddressJSON(submitAppJSON,Qte.SBQQ__Account__r.BillingStreet, Qte.SBQQ__Account__r.BillingCity, Qte.SBQQ__Account__r.BillingState, Qte.SBQQ__Account__r.BillingPostalcode, Qte.SBQQ__Account__r.BillingCountry, jpl);
}
if (jpl.UserDefinedId.equalsIgnoreCase('dba.name')) {
if(Qte.Deliver_To_Site__r.Name.length()>40){
normalJSON(submitAppJSON, Qte.Deliver_To_Site__r.Name.left(40), jpl);

}else{
normalJSON(submitAppJSON, Qte.Deliver_To_Site__r.Name, jpl);

}
}
if (jpl.UserDefinedId.equalsIgnoreCase('dba.address')) {
normalAddressJSON(submitAppJSON, Qte.Deliver_To_Site__r.BillingStreet, Qte.Deliver_To_Site__r.BillingCity, Qte.Deliver_To_Site__r.BillingState, Qte.Deliver_To_Site__r.BillingPostalCode, Qte.Deliver_To_Site__r.BillingCountry, jpl);
}
if (jpl.UserDefinedId.equalsIgnoreCase('dba.email')) {
normalJSON(submitAppJSON, Qte.Payments_Application_Signee__r.Email, jpl);
}
if (jpl.UserDefinedId.equals('dba.phone')) {
normalJSON(submitAppJSON, handlePhone(Qte.Payments_Application_Signee__r.Phone), jpl); 
}
if (Qte.SBQQ__Opportunity2__r.Channel_Office__r.Name != null && jpl.UserDefinedId.equalsIgnoreCase('agent.name')) {
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Channel_Office__r.Name, jpl);
}
if (Qte.SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c != null && jpl.UserDefinedId.equalsIgnoreCase('agent.id')) {
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Channel_Office__r.Payments_Agent_ID__c, jpl);
}
if (Qte.POS__c != null && jpl.UserDefinedId.equals('sf.ncrpos')) {
normalJSON(submitAppJSON, Qte.POS__c, jpl); 
}
//PRICING FEES FIELDS STARTED
if (jpl.UserDefinedId.equalsIgnoreCase('pricing.pricingtype')) {
if(Qte.SBQQ__LineItems__r.size()>0)
normalJSON(submitAppJSON, Qte.SBQQ__LineItems__r[0].qtc_Pricing_Type__c, jpl);
//normalJSON(submitAppJSON, 'TIERED', jpl);
} 
//List Price based values
for(SBQQ__QuoteLine__c qli:Qte.SBQQ__LineItems__r){
if (qli.SBQQ__ProductCode__c!=null && qli.SBQQ__ProductCode__c==cfMap.get(jpl.UserDefinedId.toUpperCase())) {
//basis point
if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexPT')) {
normalFeeJSON(submitAppJSON, qli.qtc_Basis_Points_Percent__c, jpl);
}else if (jpl.UserDefinedId.equalsIgnoreCase('pricing.visapt')) {
normalFeeJSON(submitAppJSON, qli.qtc_Basis_Points_Percent__c, jpl);
}else{
normalFeeJSON(submitAppJSON, qli.SBQQ__ListPrice__c, jpl);
}
}
}         

//Add Rep Email
if (jpl.UserDefinedId.equalsIgnoreCase('sf.salesrepemail')) {
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Owner.Email, jpl);
} 
//ADD Missing Field-Ajay-EBA_SF-1374
if (jpl.UserDefinedId.equals('sf.salesrepname')) {  
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Owner.Name, jpl);   
}
//  added SF.MCN
if (jpl.UserDefinedId.equalsIgnoreCase('SF.MCN')) {
normalJSON(submitAppJSON, Qte.SBQQ__Account__r.Master_Customer_Number__c, jpl);
} 
//  added  Annual Volume ($) annual.volume, Total Number of Sites (#) number.sites ,Total Annual Transactions (#) annual.transactions
//Total_Annual_Transactions__c,Total_Annual_Volume__c,Total_Number_of_Sites__c
if (jpl.UserDefinedId.equalsIgnoreCase('annual.volume')) {
if(Qte.SBQQ__LineItems__r.size()>0)
normalFeeJSONFormatted(submitAppJSON, Qte.SBQQ__LineItems__r[0].qtc_Annual_Volume__c, jpl);
} 

if (jpl.UserDefinedId.equalsIgnoreCase('annual.transactions')) {
if(Qte.SBQQ__LineItems__r.size()>0)
normalFeeJSONFormatted(submitAppJSON, Qte.SBQQ__LineItems__r[0].qtc_Annual_Volume__c/Qte.SBQQ__LineItems__r[0].qtc_Average_Check__c, jpl);
} 

if (jpl.UserDefinedId.equalsIgnoreCase('number.sites')) {
normalFeeJSON(submitAppJSON, 1, jpl);
} 
/**********************************************************/
    //Ajay--EBA_SF-1374                
    //AJAY COMMENTED
    /* if (jpl.UserDefinedId.equalsIgnoreCase('sf.siteid')) {
normalJSON(submitAppJSON, Qte.Deliver_To_Site__r.Site_Number__c, jpl);
} 
if (Qte.SBQQ__Opportunity2__r.Channel_Office__c!=null && jpl.UserDefinedId.equalsIgnoreCase('sf.accounttype')) {
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c, jpl);
}
//ADDING MISSING FIELDS ON QUOTE
//  added sf.salesprogram   
if (jpl.UserDefinedId.equalsIgnoreCase('sf.salesprogram')) {    
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Marketing_Program__c, jpl); 
}   
//  added sf.paymentsalesrep    
if (jpl.UserDefinedId.equalsIgnoreCase('sf.paymentsalesrep')) { 
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Payments_Rep__r.Name, jpl); 
}   
//  added sf.opportunity    
if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunitynumber')) {   
normalJSON(submitAppJSON, Qte.SBQQ__Opportunity2__r.Opportunity_Number__c, jpl);    
}   
//  added sf.opportunityURL 
String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();   
if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunityURL')) {  
normalJSON(submitAppJSON, sfdcBaseURL+'/'+Qte.SBQQ__Opportunity2__r.id, jpl);   
}
//  added new Fields for Payments First and Qs/TS   qtc_Service_Type__c,qtc_Payments_Solution__c
if (jpl.UserDefinedId.equalsIgnoreCase('sf.restaurant.type')) { 
normalJSON(submitAppJSON, Qte.qtc_Service_Type__c, jpl);    
}                   
if (jpl.UserDefinedId.equalsIgnoreCase('sf.paymentssalesoffer')) {  
normalJSON(submitAppJSON, Qte.qtc_Payments_Solution__c, jpl);       
}                
}catch(Exception e){
Status = jpl.UserDefinedId+ '##Failure:Send Exception' + e;
}
}
//CUSTOM FIELD ARRAY END
try{
submitAppJSON.writeEndArray();
//MAIN ENDS 
submitAppJSON.writeEndObject();
}catch(Exception e){
Status = 'Failure:JSON Exception' + e;
}
HttpRequest submitAppRequest = new HttpRequest();
submitAppResponse = new HttpResponse();
if (!Status.containsIgnoreCase('Failure')) {           
try {
submitAppRequest.setHeader('Content-Type', 'application/json');
submitAppRequest.setHeader('x-app-name', 'pos-payos');
submitAppRequest.setHeader('Authorization', 'Bearer ' + accessToken);
submitAppRequest.setMethod('POST');
submitAppRequest.setTimeout(120000);
submitAppRequest.setEndpoint(endpointURL);
submitAppRequest.setBody(submitAppJSON.getAsString());
Http submitAppCallOut = new Http();
if (!Test.isRunningTest()) {
submitAppResponse = submitAppCallOut.send(submitAppRequest);
}
else{
Status = 'Test_Success';
}

} catch (Exception e) {

Status = 'Failure:Submit Exception' + e;
}
}
System.debug('JP_STEP 3: SUBMIT APPLICATION RESPONSE:' + submitAppResponse.getBody());
if (!Status.containsIgnoreCase('Failure')) {
try {
List<JP_OutBoundOnBoardingService.SubmitApplicationResponse> sr = new List<JP_OutBoundOnBoardingService.SubmitApplicationResponse>();
system.debug(submitAppResponse.getBody());
try{
sr = (List<SubmitApplicationResponse>)JSON.deserialize(submitAppResponse.getBody(), List<SubmitApplicationResponse>.class);
}catch(Exception e){
String exStr='Failure:Infinicept Response Failed (Validaton/Other Error): ';
if(submitAppResponse.getBody().containsIgnoreCase('A duplicate enterprise')){
exStr+='Duplicate Site, Site may already be Underwritten ';
Status = exStr;   
}else{
Status = exStr+e;  
}

}
if(sr.size()>0 && sr[0].infiniceptApplicationId!=null){
NCR_Payments_Site__c o = new NCR_Payments_Site__c(Quote__c=Qte.id, Opportunity__c = Qte.SBQQ__Opportunity2__c, NCR_Payments_Application_Status__c = sr[0].statusMessage,  InfiniceptApplicationId__c = String.valueOf(sr[0].infiniceptApplicationId),Account_Sites__c=Qte.Deliver_To_Site__c);
nps.add(o);   
}else{
//track failures 
failedSites.add(Qte.Deliver_To_Site__r.name);

}


} catch (Exception e) {
Status = 'Failure:Initiating Site Record'+e;
}
}else{
failedSites.add(Qte.Deliver_To_Site__r.name);  
}
logObject lo = new logObject();
lo.status = Status.left(250);
lo.SubmitAppRequest=submitAppJSON.getAsString();
lo.SubmitAppResponse=submitAppResponse.getBody();
lo.Qte=Qte;
log.add(lo);

String insertStatus='';
try {
if(nps.size()>0){
insert nps;
system.debug('@@'+nps[0].id);                
}

} catch (Exception e) {
insertStatus = 'Failure:Creating Site Record '+e;
}
try {
if(log.size()>0){
logOutboundRequest(log);

}
} catch (Exception e) {
insertStatus = 'Failure:Creating LOG Record '+e;
}
//if exception occured
if(insertStatus.containsIgnoreCase('Failure')){
return 'Failure: Exception occured in request: '+insertStatus;
}else{
//if faled sites size then failure happened
if (failedSites.size()==0) {
return 'Success: Application successfully sent. See NCR Payments Sites for status updates';
} else {
if(nps.size()==0){
if (!Status.containsIgnoreCase('Failure')) {
return 'Failure:All site(s) onboarding request failed, Contact Administrator to get detail of issue: ' ;
}else{
return 'Failure:All site(s) onboarding request failed, Contact Administrator to get detail of issue: '+Status ;
}

}else{
return 'Partial Failure:'+failedSites.size() +' site(s) onboarding request failed, NCR Payments Site Related List contains details of Requested submitted successfully and their Status updates. Following Sites request Failed:'+ failedSites;
}

}
}

}*/
    public static String submitRequestNew(String accessToken, String oppId, String billingAccs) {
        String Status = 'Success';
        List < NCR_Payments_Site__c > nps = new List < NCR_Payments_Site__c > ();
        List < logObject > log = new List < logObject > ();
        List < String > failedSites = new List < String > ();
        HttpResponse submitAppResponse;
        JSONGenerator submitAppJSON;
        
        //fetch opportunity fields
        Opportunity opp = [Select id, Name,StageName, Account.Industry, POS__c,Total_Annual_Transactions__c,Total_Annual_Volume__c,Total_Number_of_Sites__c, Account.Name, Owner.Email, Owner.Name, Opportunity_Number__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.Master_Customer_Number__c, Account.BillingCountry,
                           Contacts__r.Name, Contacts__r.Phone, Contacts__r.Email, Contacts__r.Fax,Payments_Application_Signee__r.Email,Payments_Application_Signee__r.Phone,Payments_Application_Signee__r.Name, Channel_Office__r.Name, Channel_Office__r.Payments_Agent_ID__c,
                           /*FEES*/
                           Chargeback_Fee_Per_Item_Fee__c, Retrieval_Fee_Per_Item_Fee__c, Account_Updater_per_Update__c, Account_Updater_per_Success__c, AVS_Fee__c, Batch_Fee__c, Merchant_Online_Reporting_Fee__c, Account_Set_up_Fee__c,Chargeback_Portal_Monthly_Fee__c,  
                           Application_Fee__c, Gateway_Monthly_Fee__c, Gateway_Transaction_Fee__c, Monthly_Acct_Maintenance_Fee__c, Monthly_PCI_Compliance_Program_Fee__c, Monthly_PIN_Debit_Access_Fee__c, CVV_Fee__c, Help_Desk_Fee__c, Monthly_Minimum_Fee__c,
                           Annual_Fee__c, Annual_PCI_Validation_Fee__c, ACH_Processing_Fee__c, ACH_Reject_Fee__c, ACH_Return_Fee__c,Bankcard_Auth_Fee__c, Bankcard_Settlement_Per_Item__c, Amex_Auth_Fee_Per_Item_Fee__c, PIN_Debit_Auth_Fee_Per_Item_Fee__c,
                           /*New Fields*/
                           PCI_Non_Compliance_Fee__c, ACH_Batch_Fee__c, Account_Updater_Monthly_Fee__c, Regulatory_Compliance_Fee__c, Amex_Settlement__c, Pricing_Type__c,Amex_Pass_Through_Plus__c, Pass_Thru_Discount_Rate__c,
                           Amex_Qualified_Tier__c, Amex_MID_Qualified_Tier__c, Amex_Non_Qualified_Tier__c, Visa_MC_Discover_Qualified_Tier__c, Visa_MC_Discover_MID_Qualified__c, Visa_MC_Discover_Non_Qualified_Tier__c,
                           /*New Field Integration EBA_SF-1294*/    
                           Marketing_Program__c, Payments_Rep__c, Payments_Rep__r.Name, EBT_Monthly_Access_Fee__c,  
                           EBT_Per_Transaction_Fee__c, Channel_Office__r.CDM_Account_Type__c, Payment_Sales_Offer__c,POS_Subscription_Discount__c,Payments_Features__c
                           FROM Opportunity where ID =: oppid
                          ];
        system.debug('####'+opp);
        //Fetch selected Sites
        List < GeneratePaymentsApplicationController.BillingSitesWrapper > siteFields = (List < GeneratePaymentsApplicationController.BillingSitesWrapper > ) JSON.deserialize(billingAccs, List < GeneratePaymentsApplicationController.BillingSitesWrapper > .class);
        List < Account > listZoura = new List < Account > ();
        Decimal RoundedETBMonFee, RoundedETBTransFee;
        if(opp.EBT_Monthly_Access_Fee__c != null){
            RoundedETBMonFee = opp.EBT_Monthly_Access_Fee__c.setScale(4);
        }
        if(opp.EBT_Per_Transaction_Fee__c != null){
            RoundedETBTransFee = opp.EBT_Per_Transaction_Fee__c.setScale(4);
        }
        for (GeneratePaymentsApplicationController.BillingSitesWrapper siteField: siteFields) {
            if (siteField.isAdded == true) {
                listZoura.add(siteField.billingSite);
            }
        }
        //Setting End Point
        JP_EndPoint__c endpoint = null;
        string endpointURL = '';
        endpoint = JP_EndPoint__c.getValues('SubmitApplication');
        endpointURL = endpoint.EndPoint_URL__c;
        List < customFieldWrapper > jpList;
        //Get Template fields
        try{
            jpList = getTemplate(accessToken);
        }catch(Exception e){
            logObject lo = new logObject();
            lo.status = ('Failure-Exception :' +e).left(250); lo.SubmitAppRequest=submitAppJSON.getAsString();lo.SubmitAppResponse=submitAppResponse.getBody();lo.opp=opp;
            log.add(lo);
            logOutboundRequest(log);
            return 'Failure No Site Onboarded, Exception Occured: '+e;
        }
        if(jpList==null || jpList.size()==0){
            return 'Failure No Site Onboarded, Exception Occured in fetching Template Fields: '; 
        }
        //ITERATE SITES
        for (Account zObj: listZoura) {
            Status = 'Success';
            submitAppJSON = JSON.createGenerator(true);
            //MAIN STARTS
            try{
                mainJSON(submitAppJSON, opp, zObj);
            }catch(Exception e){
                Status ='Failure:Main JSON Exception' + e;
                // return 'Failure:Exception Occured while sending application: '+e;
                
            }
            
            submitAppJSON.writeFieldName('CustomFieldAnswers');
            submitAppJSON.writeStartArray();
            for (customFieldWrapper jpl: jpList) {
                try{
                    if (jpl.UserDefinedId.equalsIgnoreCase('legal.name')) {
                        normalJSON(submitAppJSON, opp.Account.Name, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('legal.address')) {
                        normalAddressJSON(submitAppJSON, opp.Account.BillingStreet, opp.Account.BillingCity, opp.Account.BillingState, opp.Account.BillingPostalcode, opp.Account.BillingCountry, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('dba.name')) {
                        if(zObj.Name.length()>40){
                            normalJSON(submitAppJSON, zObj.Name.left(40), jpl);
                            
                        }else{
                            normalJSON(submitAppJSON, zObj.Name, jpl);
                            
                        }
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('dba.address')) {
                        normalAddressJSON(submitAppJSON, zObj.BillingStreet, zObj.BillingCity, zObj.BillingState, zObj.BillingPostalCode, zObj.BillingCountry, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('dba.email')) {
                        normalJSON(submitAppJSON, opp.Payments_Application_Signee__r.Email, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('dba.phone')) {
                        normalJSON(submitAppJSON, handlePhone(opp.Payments_Application_Signee__r.Phone), jpl);
                    }
                    if (opp.Channel_Office__r.Name != null && jpl.UserDefinedId.equalsIgnoreCase('agent.name')) {
                        normalJSON(submitAppJSON, opp.Channel_Office__r.Name, jpl);
                    }
                    if (opp.Channel_Office__r.Payments_Agent_ID__c != null && jpl.UserDefinedId.equalsIgnoreCase('agent.id')) {
                        normalJSON(submitAppJSON, opp.Channel_Office__r.Payments_Agent_ID__c, jpl);
                    }
                    if (opp.POS__c != null && jpl.UserDefinedId.equalsIgnoreCase('sf.ncrpos')) {
                        normalJSON(submitAppJSON, opp.POS__c, jpl);
                    }
                    //PRICING FEES FIELDS STARTED
                    //ACH_Processing_Fee__c, ACH_Reject_Fee__c, ACH_Return_Fee__c, Visa_Auth_Fee_Per_Item_Fee__c, Visa_Settlement__c, Amex_Auth_Fee_Per_Item_Fee__c, Discover_Auth_Fee_Per_Item_Fee__c, Mastercard_Auth_Fee_Per_Item_Fee__c, PIN_Debit_Auth_Fee_Per_Item_Fee__c
                    
                    
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.ACHReturnFee')) {
                        normalFeeJSON(submitAppJSON, opp.ACH_Return_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.ACHProcessingTrans')) {
                        normalFeeJSON(submitAppJSON, opp.ACH_Processing_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexAuthFee')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_Auth_Fee_Per_Item_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AuthFee')) {
                        normalFeeJSON(submitAppJSON, opp.Bankcard_Auth_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.SettleFee')) {
                        normalFeeJSON(submitAppJSON, opp.Bankcard_Settlement_Per_Item__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.annualfee')) {
                        normalFeeJSON(submitAppJSON, opp.Annual_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.annualPCI')) {
                        normalFeeJSON(submitAppJSON, opp.Annual_PCI_Validation_Fee__c, jpl);
                    }
                    //CVV_Fee__c, Help_Desk_Fee__c, Monthly_Minimum_Fee__c
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.cvv2')) {
                        normalFeeJSON(submitAppJSON, opp.CVV_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.helpdeskfee')) {
                        normalFeeJSON(submitAppJSON, opp.Help_Desk_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.monthlyminimum')) {
                        normalFeeJSON(submitAppJSON, opp.Monthly_Minimum_Fee__c, jpl);
                    }
                    //Application_Fee__c, Gateway_Monthly_Fee__c, Gateway_Transaction_Fee__c, Monthly_Acct_Maintenance_Fee__c, Monthly_PCI_Compliance_Program_Fee__c, Monthly_PIN_Debit_Access_Fee__c
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.applicationfee')) {
                        normalFeeJSON(submitAppJSON, opp.Application_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.GatewayMonthly')) {
                        normalFeeJSON(submitAppJSON, opp.Gateway_Monthly_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.GatewayPerTrans')) {
                        normalFeeJSON(submitAppJSON, opp.Gateway_Transaction_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.MonthlyMaint')) {
                        normalFeeJSON(submitAppJSON, opp.Monthly_Acct_Maintenance_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.PCIMonthly')) {
                        normalFeeJSON(submitAppJSON, opp.Monthly_PCI_Compliance_Program_Fee__c, jpl);
                    }
                    //Chargeback_Fee_Per_Item_Fee__c,Retrieval_Fee_Per_Item_Fee__c,Account_Updater_per_Update__c, Account_Updater_per_Success__c,AVS_Fee__c,Batch_Fee__c,Merchant_Online_Reporting_Fee__c,Account_Set_up_Fee__c,Merlink_Fee__c,
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.Chargebacks')) {
                        normalFeeJSON(submitAppJSON, opp.Chargeback_Fee_Per_Item_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.Retrievals')) {
                        normalFeeJSON(submitAppJSON, opp.Retrieval_Fee_Per_Item_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AcctUpdaterPerSuccess')) {
                        normalFeeJSON(submitAppJSON, opp.Account_Updater_per_Success__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AcctUpdaterPerTxn')) {
                        normalFeeJSON(submitAppJSON, opp.Account_Updater_per_Update__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AVS')) {
                        normalFeeJSON(submitAppJSON, opp.AVS_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.BatchFee')) {
                        normalFeeJSON(submitAppJSON, opp.Batch_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.reportingfee')) {
                        normalFeeJSON(submitAppJSON, opp.Merchant_Online_Reporting_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.acctsetupfee')) {
                        normalFeeJSON(submitAppJSON, opp.Account_Set_up_Fee__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.MerlinkCBs')) {
                        normalFeeJSON(submitAppJSON, opp.Chargeback_Portal_Monthly_Fee__c, jpl);
                    }
                    /*New Fields*/
                    //        ACH_Reject_Fee__c,PIN_Debit_Auth_Fee_Per_Item_Fee__c, Amex_Settlement__c, Monthly_PIN_Debit_Access_Fee__c, Pricing_Type__c,Amex_Pass_Through_Plus__c, Pass_Thru_Discount_Rate__c,
                    //       Amex_Qualified_Tier__c, Amex_MID_Qualified_Tier__c, Amex_Non_Qualified_Tier__c, Visa_MC_Discover_Qualified_Tier__c, Visa_MC_Discover_MID_Qualified__c, Visa_MC_Discover_Non_Qualified_Tier__c
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.NSF')) {
                        normalFeeJSON(submitAppJSON, opp.ACH_Reject_Fee__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.DebitAuthFee')) {
                        normalFeeJSON(submitAppJSON, opp.PIN_Debit_Auth_Fee_Per_Item_Fee__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexSettleFee')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_Settlement__c, jpl);
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.pricingtype')) {
                        normalJSON(submitAppJSON, opp.Pricing_Type__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexPT')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_Pass_Through_Plus__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.visapt')) {
                        normalFeeJSON(submitAppJSON, opp.Pass_Thru_Discount_Rate__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexQual')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_Qualified_Tier__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexMID')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_MID_Qualified_Tier__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AmexNonQual')) {
                        normalFeeJSON(submitAppJSON, opp.Amex_Non_Qualified_Tier__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.VisaQual')) {
                        normalFeeJSON(submitAppJSON, opp.Visa_MC_Discover_Qualified_Tier__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.VisaMID')) {
                        normalFeeJSON(submitAppJSON, opp.Visa_MC_Discover_MID_Qualified__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.VisaNonQual')) {
                        normalFeeJSON(submitAppJSON, opp.Visa_MC_Discover_Non_Qualified_Tier__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.RegCompliance')) {
                        normalFeeJSON(submitAppJSON, opp.Regulatory_Compliance_Fee__c, jpl);
                    } 
                    //PCI_Non_Compliance_Fee__c, ACH_Batch_Fee__c, Account_Updater_Monthly_Fee__c
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.PCINonCompliance')) {
                        normalFeeJSON(submitAppJSON, opp.PCI_Non_Compliance_Fee__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.ACHBatchFee')) {
                        normalFeeJSON(submitAppJSON, opp.ACH_Batch_Fee__c, jpl);
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.AcctUpdaterMonthly')) {
                        normalFeeJSON(submitAppJSON, opp.Account_Updater_Monthly_Fee__c, jpl);
                    } 
                    //  added SF.MCN
                    if (jpl.UserDefinedId.equalsIgnoreCase('SF.MCN')) {
                        normalJSON(submitAppJSON, opp.Account.Master_Customer_Number__c, jpl);
                    } 
                    //  added  Annual Volume ($) annual.volume, Total Number of Sites (#) number.sites ,Total Annual Transactions (#) annual.transactions
                    //Total_Annual_Transactions__c,Total_Annual_Volume__c,Total_Number_of_Sites__c
                    if (jpl.UserDefinedId.equalsIgnoreCase('annual.volume')) {
                        normalFeeJSONFormatted(submitAppJSON, opp.Total_Annual_Volume__c, jpl);
                    } 
                    
                    if (jpl.UserDefinedId.equalsIgnoreCase('annual.transactions')) {
                        normalFeeJSONFormatted(submitAppJSON, opp.Total_Annual_Transactions__c, jpl);
                    } 
                    
                    if (jpl.UserDefinedId.equals('number.sites')) {
                        normalFeeJSON(submitAppJSON, opp.Total_Number_of_Sites__c, jpl);
                    } 
                    //  added sf.siteid 
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.siteid')) {  
                        normalJSON(submitAppJSON, zObj.Site_Number__c, jpl);    
                    }   
                    //  added sf.salesprogram   
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.salesprogram')) {    
                        normalJSON(submitAppJSON, opp.Marketing_Program__c, jpl);   
                    }   
                    //  added sf.paymentsalesrep    
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.paymentsalesrep')) { 
                        normalJSON(submitAppJSON, opp.Payments_Rep__r.Name, jpl);   
                    }   
                    //  added sf.opportunity    
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunitynumber')) {   
                        normalJSON(submitAppJSON, opp.Opportunity_Number__c, jpl);  
                    }   
                    //  added sf.opportunityURL 
                    String sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();   
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunityURL')) {  
                        normalJSON(submitAppJSON, sfdcBaseURL+'/'+opp.id, jpl); 
                    }   
                    
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.ebtmonthlyaccessfee')) {  
                        //normalFeeJSON(submitAppJSON, opp.EBT_Monthly_Access_Fee__c, jpl); 
                        normalFeeJSON(submitAppJSON,RoundedETBMonFee, jpl);                         
                    }   
                    if (jpl.UserDefinedId.equalsIgnoreCase('pricing.ebtpertransactionfee')) { 
                        //normalFeeJSON(submitAppJSON, opp.EBT_Per_Transaction_Fee__c, jpl);
                        normalFeeJSON(submitAppJSON,RoundedETBTransFee, jpl);
                    }   
                    
                    //Add Rep Name  
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.salesrepname')) {  
                        normalJSON(submitAppJSON, opp.Owner.Name, jpl); 
                    }   
                    //Add Rep Email 
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.salesrepemail')) { 
                        normalJSON(submitAppJSON, opp.Owner.Email, jpl);    
                    }   
                    //Ajay-EBA_SF-1374  
                    if (opp.Channel_Office__r.CDM_Account_Type__c != null && jpl.UserDefinedId.equals('sf.accounttype')) {  
                        normalJSON(submitAppJSON, opp.Channel_Office__r.CDM_Account_Type__c, jpl);  
                    }   
                    
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.paymentssalesoffer')) {  
                        normalJSON(submitAppJSON, opp.Payment_Sales_Offer__c, jpl);     
                    }
                    //  ADDED New Fields: EBA_SF-1386
                    if (opp.Account.Industry!=null && jpl.UserDefinedId.equalsIgnoreCase('sf.restauranttype')) {   
                        if(opp.Account.Industry.containsIgnoreCase(Label.QSR)){
                            normalJSON(submitAppJSON, 'QS', jpl);    
                        }else if(opp.Account.Industry.containsIgnoreCase(Label.TSR)){
                            normalJSON(submitAppJSON, 'TS', jpl);  
                        }   
                    }
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunityname')) {   
                        normalJSON(submitAppJSON, opp.Name, jpl);                        
                    } 
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.opportunitysellingstage')) {   
                        normalJSON(submitAppJSON, opp.StageName, jpl);                        
                    } 
                     /*---------------Changes By Saurav --EBA_SF-1815------Start Here-------------------------------------*/
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.paymentsfeatures')) {
                        normalJSON(submitAppJSON, opp.Payments_Features__c, jpl);
                     /*-------------Changes By Saurav --EBA_SF-1815------End Here---------------------------------------*/
                    }
                    /*---------------Changes By Saurav --EBA_SF-1816------Start Here-------------------------------------*/
                    if (jpl.UserDefinedId.equalsIgnoreCase('sf.POSSubscriptionDiscount')) {
                        normalFeeJSON(submitAppJSON, opp.POS_Subscription_Discount__c, jpl);
                    }
                    /*---------------Changes By Saurav --EBA_SF-1816------End Here-------------------------------------*/
                    
                }catch(Exception e){
                    Status = jpl.UserDefinedId+ '##Failure:Send Exception' + e;
                }
            }
            //CUSTOM FIELD ARRAY END
            try{
                submitAppJSON.writeEndArray();
                //MAIN ENDS 
                submitAppJSON.writeEndObject();
            }catch(Exception e){
                Status = 'Failure:JSON Exception' + e;
            }
            HttpRequest submitAppRequest = new HttpRequest();
            submitAppResponse = new HttpResponse();
            if (!Status.containsIgnoreCase('Failure')) {           
                try {
                    submitAppRequest.setHeader('Content-Type', 'application/json');
                    submitAppRequest.setHeader('x-app-name', 'pos-payos');
                    submitAppRequest.setHeader('Authorization', 'Bearer ' + accessToken);
                    submitAppRequest.setMethod('POST');
                    submitAppRequest.setTimeout(120000);
                    submitAppRequest.setEndpoint(endpointURL);
                    submitAppRequest.setBody(submitAppJSON.getAsString());
                    Http submitAppCallOut = new Http();
                    if (!Test.isRunningTest()) {
                        submitAppResponse = submitAppCallOut.send(submitAppRequest);
                    }
                    else{
                        Status = 'Test_Success';
                    }
                    
                } catch (Exception e) {                    
                    Status = 'Failure:Submit Exception' + e;
                }
            }
            System.debug('JP_STEP 3: SUBMIT APPLICATION RESPONSE:' + submitAppResponse.getBody());
            if (!Status.containsIgnoreCase('Failure')) {
                try {
                    List<JP_OutBoundOnBoardingService.SubmitApplicationResponse> sr = new List<JP_OutBoundOnBoardingService.SubmitApplicationResponse>();
                    try{
                        sr = (List<SubmitApplicationResponse>)JSON.deserialize(submitAppResponse.getBody(), List<SubmitApplicationResponse>.class);
                    }catch(Exception e){
                        String exStr='Failure:Infinicept Response Failed (Validaton/Other Error): ';
                        if(submitAppResponse.getBody().containsIgnoreCase('A duplicate enterprise')){
                            Status = exStr+'Duplicate Site, Site may already be Underwritten ';   
                        }else{
                            Status = exStr+e;  
                        }
                        
                    }
                    if(sr.size()>0 && sr[0].infiniceptApplicationId!=null){
                        NCR_Payments_Site__c o = new NCR_Payments_Site__c(Opportunity__c = oppId, NCR_Payments_Application_Status__c = sr[0].statusMessage,OrganizationId__c=sr[0].organizationId,SiteId__c=sr[0].siteId,AdministratorURL__c=sr[0].administratorURL,  InfiniceptApplicationId__c = String.valueOf(sr[0].infiniceptApplicationId), Account_Sites__c=zobj.id, Cobrand__c =sr[0].cobrand, Cobrand_URL__c = sr[0].merchantClaimURL,Merchant_Application_Id__c=sr[0].merchantApplicationId); 
                        nps.add(o);   
                    }else{
                        //track failures 
                        failedSites.add(zObj.name);
                        
                    }
                    
                    
                    
                    
                } catch (Exception e) {
                    Status = 'Failure:Initiating Site Record'+e;
                }
            }else{
                failedSites.add(zObj.name);  
            }
            logObject lo = new logObject();
            lo.status = Status.left(250);
            lo.SubmitAppRequest=submitAppJSON.getAsString();
            lo.SubmitAppResponse=submitAppResponse.getBody();
            lo.opp=opp;
            log.add(lo);
            
        }
        String insertStatus='';
        try {
            if(nps.size()>0){
                insert nps;
                system.debug('@@'+nps[0].id);                
            }
            
        } catch (Exception e) {
            insertStatus = 'Failure:Creating Site Record '+e;
        }
        try {
            if(log.size()>0){
                logOutboundRequest(log);
                
            }
        } catch (Exception e) {
            insertStatus = 'Failure:Creating LOG Record '+e;
        }
        //if exception occured
        if(insertStatus.containsIgnoreCase('Failure')){
            return 'Failure: Exception occured in request: '+insertStatus;
        }else{
            //if faled sites size then failure happened
            if (failedSites.size()==0) {
                return 'Success: Application successfully sent. See NCR Payments Sites for status updates';
            } else {
                if(nps.size()==0){
                    if (!Status.containsIgnoreCase('Failure')) {
                        return 'Failure:All site(s) onboarding request failed, Contact Administrator to get detail of issue: ' ;
                    }else{
                        return 'Failure:All site(s) onboarding request failed, Contact Administrator to get detail of issue: '+Status ;
                    }
                    
                }else{
                    return 'Partial Failure:'+failedSites.size() +' site(s) onboarding request failed, NCR Payments Site Related List contains details of Requested submitted successfully and their Status updates. Following Sites request Failed:'+ failedSites;
                }
                
            }
        }
        
    }
    /*public static void mainJSONnew(JSONGenerator submitAppJSON, Opportunity opp, Zuora__CustomerAccount__c zObj) {
submitAppJSON.writeStartObject();
submitAppJSON.writeStringField('EmailAddress', opp.Contacts__r.Email);
submitAppJSON.writeStringField('OrganizationId', opp.Account.Master_Customer_Number__c);
submitAppJSON.writeStringField('SiteId', zObj.ERPSiteNumber__c);
submitAppJSON.writeStringField('AutoRun', 'true');
}*/
    public static void mainJSON(JSONGenerator submitAppJSON, Opportunity opp, Account zObj) {
        submitAppJSON.writeStartObject();
        submitAppJSON.writeStringField('EmailAddress', opp.Payments_Application_Signee__r.Email);
        submitAppJSON.writeStringField('Id', opp.Account.Master_Customer_Number__c);
        submitAppJSON.writeStringField('legalName', opp.Account.Master_Customer_Number__c);
        submitAppJSON.writeFieldName('address');
        submitAppJSON.writeStartObject();
        //Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,Account.Master_Customer_Number__c,Account.BillingCountry
        submitAppJSON.writeStringField('street', opp.Account.BillingStreet);
        submitAppJSON.writeStringField('city', opp.Account.BillingCity);
        submitAppJSON.writeStringField('state', opp.Account.BillingState);
        submitAppJSON.writeStringField('postalCode', opp.Account.BillingPostalCode);
        submitAppJSON.writeStringField('country', opp.Account.BillingCountry);
        submitAppJSON.writeEndObject();
        submitAppJSON.writeFieldName('sites');
        submitAppJSON.writeStartArray();
        submitAppJSON.writeStartObject();
        
        if(zObj.Site_Number__c==null){
            throw new NullFieldException('ERP Number for site is Empty');
        }
        //Call site method to generate dynamic JSON
        //======Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,Zuora__BillToPostalCode__c, ERPSiteNumber__c, Zuora__Status__c,cdm_Store_Branch_Number__c
        //submitAppJSON.writeStringField('Id', zObj.ERPSiteNumber__c);
        submitAppJSON.writeStringField('Id',zObj.Site_Number__c);
        //String nam=zObj.ERPSiteNumber__c+'-'+zObj.Name;
        String nam=zObj.Site_Number__c+'-'+zObj.Name;
        if(nam.length()>40){
            submitAppJSON.writeStringField('name', nam.left(50));
            
        }else{
            submitAppJSON.writeStringField('name',nam);
            
        }
        submitAppJSON.writeStringField('description', 'Fill Description');
        submitAppJSON.writeFieldName('contact');
        submitAppJSON.writeStartObject();
        submitAppJSON.writeStringField('contactPerson', opp.Payments_Application_Signee__r.Name);
        submitAppJSON.writeStringField('phoneNumber', opp.Payments_Application_Signee__r.Phone);
        submitAppJSON.writeNumberField('phoneNumberCountryCode', 1);
        submitAppJSON.writeEndObject();
        submitAppJSON.writeFieldName('address');
        submitAppJSON.writeStartObject();
        submitAppJSON.writeStringField('city', zObj.BillingCity == null ? opp.Account.BillingCity : zObj.BillingCity);
        submitAppJSON.writeStringField('country', zObj.BillingCountry == null ? opp.Account.BillingCountry : zObj.BillingCountry);
        submitAppJSON.writeStringField('postalCode', zObj.BillingPostalCode == null ? opp.Account.BillingPostalCode : zObj.BillingPostalCode);
        submitAppJSON.writeStringField('state', zObj.BillingState == null ? opp.Account.BillingState : zObj.BillingState);
        submitAppJSON.writeStringField('street', zObj.BillingStreet == null ? opp.Account.BillingStreet : zObj.BillingStreet);
        submitAppJSON.writeEndObject();
        
        if (zObj.cdm_Store_Branch_Number__c != null) {            
            Double storeId;
            try{
                storeId = Integer.valueOf(zObj.cdm_Store_Branch_Number__c);  
            }catch(Exception e){
                storeId=101;
            }
            submitAppJSON.writeNumberField('storeNumber', Integer.valueOf(storeId));
        } else {
            submitAppJSON.writeNumberField('storeNumber', 101);
        }
        submitAppJSON.writeEndObject();
        submitAppJSON.writeEndArray();
        submitAppJSON.writeStringField('AutoRun', 'true');
    }
    // For Qte
    /* public static void mainQteJSON(JSONGenerator submitAppJSON, SBQQ__Quote__c Qte) {
submitAppJSON.writeStartObject();
system.debug(Qte.SBQQ__PrimaryContact__c+'@@@Qte.SBQQ__PrimaryContact__r.Email'+Qte.SBQQ__PrimaryContact__r.Email);
submitAppJSON.writeStringField('EmailAddress', Qte.SBQQ__PrimaryContact__r.Email);
submitAppJSON.writeStringField('Id', Qte.SBQQ__Account__r.Master_Customer_Number__c);
submitAppJSON.writeStringField('legalName', Qte.SBQQ__Account__r.Master_Customer_Number__c);
submitAppJSON.writeFieldName('address');
submitAppJSON.writeStartObject();
//Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode,Account.Master_Customer_Number__c,Account.BillingCountry
submitAppJSON.writeStringField('street', Qte.SBQQ__Account__r.BillingStreet);
submitAppJSON.writeStringField('city', Qte.SBQQ__Account__r.BillingCity);
submitAppJSON.writeStringField('state', Qte.SBQQ__Account__r.BillingState);
submitAppJSON.writeStringField('postalCode', Qte.SBQQ__Account__r.BillingPostalCode);
submitAppJSON.writeStringField('country', Qte.SBQQ__Account__r.BillingCountry);
submitAppJSON.writeEndObject();
submitAppJSON.writeFieldName('sites');
submitAppJSON.writeStartArray();
submitAppJSON.writeStartObject();

if(Qte.Deliver_To_Site__r==null || (Qte.Deliver_To_Site__r!=null && Qte.Deliver_To_Site__r.Site_Number__c==null)){
throw new NullFieldException('ERP Number for site is Empty');
}
//Call site method to generate dynamic JSON
//======Id, Name,Address__c,City__c,State__c,Zuora__BillToState__c,Zuora__BillToPostalCode__c, ERPSiteNumber__c, Zuora__Status__c,cdm_Store_Branch_Number__c
//submitAppJSON.writeStringField('Id', zObj.ERPSiteNumber__c);
submitAppJSON.writeStringField('Id',Qte.Deliver_To_Site__r.Site_Number__c);
//String nam=zObj.ERPSiteNumber__c+'-'+zObj.Name;
String nam=Qte.Deliver_To_Site__r.Site_Number__c+'-'+Qte.Deliver_To_Site__r.Name;
if(nam.length()>40){
submitAppJSON.writeStringField('name', nam.left(50));

}else{
submitAppJSON.writeStringField('name',nam);

}
submitAppJSON.writeStringField('description', 'Fill Description');
submitAppJSON.writeFieldName('contact');
submitAppJSON.writeStartObject();
submitAppJSON.writeStringField('contactPerson', Qte.SBQQ__PrimaryContact__r.Name);
submitAppJSON.writeStringField('phoneNumber', Qte.SBQQ__PrimaryContact__r.Phone);
submitAppJSON.writeNumberField('phoneNumberCountryCode', 1);
submitAppJSON.writeEndObject();
submitAppJSON.writeFieldName('address');
submitAppJSON.writeStartObject();
submitAppJSON.writeStringField('city', Qte.Deliver_To_Site__r.BillingCity == null ? Qte.SBQQ__Account__r.BillingCity : Qte.Deliver_To_Site__r.BillingCity);
submitAppJSON.writeStringField('country', Qte.Deliver_To_Site__r.BillingCountry == null ? Qte.SBQQ__Account__r.BillingCountry : Qte.Deliver_To_Site__r.BillingCountry);
submitAppJSON.writeStringField('postalCode', Qte.Deliver_To_Site__r.BillingPostalCode == null ? Qte.SBQQ__Account__r.BillingPostalCode : Qte.Deliver_To_Site__r.BillingPostalCode);
submitAppJSON.writeStringField('state', Qte.Deliver_To_Site__r.BillingState == null ? Qte.SBQQ__Account__r.BillingState : Qte.Deliver_To_Site__r.BillingState);
submitAppJSON.writeStringField('street', Qte.Deliver_To_Site__r.BillingStreet == null ? Qte.SBQQ__Account__r.BillingStreet : Qte.Deliver_To_Site__r.BillingStreet);
submitAppJSON.writeEndObject();

if (Qte.Deliver_To_Site__r.cdm_Store_Branch_Number__c != null) {
Double storeId;
try{
storeId = Integer.valueOf(Qte.Deliver_To_Site__r.cdm_Store_Branch_Number__c);  
}catch(Exception e){
storeId=101;
}
submitAppJSON.writeNumberField('storeNumber', Integer.valueOf(storeId));
} else {
submitAppJSON.writeNumberField('storeNumber', 101);
}
submitAppJSON.writeEndObject();
submitAppJSON.writeEndArray();
submitAppJSON.writeStringField('AutoRun', 'true');
}*/
    //normal
    public static void normalJSON(JSONGenerator submitAppJSON, String val, customFieldWrapper jpl) {
        if(val != NULL){
            Integer id = jpl.Id;
            submitAppJSON.writeStartObject();
            submitAppJSON.writeNumberField('id', jpl.Id);
            submitAppJSON.writeStringField('userDefinedId', jpl.UserDefinedId);
            submitAppJSON.writeFieldName('value');
            submitAppJSON.writeStartObject();
            submitAppJSON.writeStringField('value', val);
            submitAppJSON.writeEndObject();
            submitAppJSON.writeEndObject();
        }
    }
    public static void normalFeeJSON(JSONGenerator submitAppJSON, Decimal val, customFieldWrapper jpl) {
        /*if(val==null){
val=0.0;
} Updated by Abhishek for EBA_SF-1256 */
        if(val != NULL){
            system.debug('$$'+val);
            Integer id = jpl.Id;
            submitAppJSON.writeStartObject();
            submitAppJSON.writeNumberField('id', jpl.Id);
            submitAppJSON.writeStringField('userDefinedId', jpl.UserDefinedId);
            submitAppJSON.writeFieldName('value');
            submitAppJSON.writeStartObject();
            submitAppJSON.WriteNumberField('value', val);
            submitAppJSON.writeEndObject();
            submitAppJSON.writeEndObject();
        }
    }
    public static void normalFeeJSONFormatted(JSONGenerator submitAppJSON, Decimal val, customFieldWrapper jpl) {
        /*if(val==null){
val=0.0;
} Updated by Abhishek for EBA_SF-1256 */
        if(val != NULL){
            Integer id = jpl.Id;
            submitAppJSON.writeStartObject();
            submitAppJSON.writeNumberField('id', jpl.Id);
            submitAppJSON.writeStringField('userDefinedId', jpl.UserDefinedId);
            submitAppJSON.writeFieldName('value');
            submitAppJSON.writeStartObject();
            submitAppJSON.writeStringField('value', val.format());
            submitAppJSON.writeEndObject();
            submitAppJSON.writeEndObject();
        }
    }
    public static void normalAddressJSON(JSONGenerator submitAppJSON, String Street, String city, String state, String postalcode, String country, customFieldWrapper jpl) {
        Integer id = jpl.Id;
        submitAppJSON.writeStartObject();
        submitAppJSON.writeNumberField('Id', jpl.Id);
        submitAppJSON.writeStringField('UserDefinedId', jpl.UserDefinedId);
        submitAppJSON.writeFieldName('Value');
        submitAppJSON.writeStartObject();
        if (country != null)
            submitAppJSON.writeStringField('Country', 'US');
        if (street != null)
            submitAppJSON.writeStringField('Street1', street.left(32));
        submitAppJSON.writeStringField('Street2', '');
        if (city != null)
            submitAppJSON.writeStringField('City', city.left(20));
        if (state != null)
            submitAppJSON.writeStringField('State', state);
        if (postalcode != null)
            submitAppJSON.writeStringField('Zip', postalcode.left(5));
        
        submitAppJSON.writeEndObject();
        submitAppJSON.writeEndObject();
    }
    
    public static String logOutboundRequest(List < logObject > log) {
        try {
            List < JPLogs__c > jplList = new List < JPLogs__c > ();
            for (logObject lg: log) {
                JPLogs__c jplogs = new JPLogs__c();
                jplogs.Type__c = 'OutBound';
                jplogs.name=lg.opp==null?lg.qte.Name+'- Outbound':lg.opp.Opportunity_Number__c+'- Outbound';
                jplogs.Opportunity_Id__c = (lg.opp != null) ? lg.opp.Opportunity_Number__c : (lg.qte?.SBQQ__Opportunity2__c != null ? lg.qte.SBQQ__Opportunity2__r.Opportunity_Number__c : null);
                    jplogs.Request__c = lg.SubmitAppRequest;
                jplogs.Response__c = lg.submitAppResponse;
                jplogs.Opportunity_Number__c = (lg.opp != null) ? lg.opp.Id : (lg.qte?.SBQQ__Opportunity2__c != null ? lg.qte.SBQQ__Opportunity2__c : null);
                    jplogs.status__c = lg.status.left(250);
                jplList.add(jplogs);
            }
            
            insert jplList;
            system.debug('!!'+jplList);
            return 'Logging Succesfull';
        } catch (Exception e) {
            return 'Error occured while Logging' + e;
        }
    }
    
    
    //Changes done for eba-sf-2024 - by Monika Mathur
    public static string initiateAppWithdrawn(String oppId, Set<Id> pymSiteIds,  String msg) {
        
        List<JPLogs__c> logs = new  List<JPLogs__c>();
        String errMsg = '';

        //fetch opportunity fields
        Opportunity opp = [Select Id, Opportunity_Number__c, CPQ__c,account.Master_Customer_Number__c FROM Opportunity where Id = :oppId]; 

       //Fetch selected Sites
        //List < GeneratePaymentsApplicationController.BillingSitesWrapper > siteFields = (List < GeneratePaymentsApplicationController.BillingSitesWrapper > ) JSON.deserialize(billingAccs, List < GeneratePaymentsApplicationController.BillingSitesWrapper > .class);
        //List < Account > listZoura = new List < Account > ();
        //for (GeneratePaymentsApplicationController.BillingSitesWrapper siteField: siteFields) {
        //if (siteField.isAdded == true) {
        //listZoura.add(siteField.billingSite);
        //}
        //}
       //iterate over sites
       //for (Account zObj: listZoura) {}

               
        List<NCR_Payments_Site__c> pymtSites = [SELECT Id, Name,Account_Sites__r.Parent.Master_Customer_Number__c, Account_Sites__r.name,SiteId__c,OrganizationId__c,AdministratorURL__c, Opportunity__c, Opportunity__r.Opportunity_Number__c,
                                                Quote__c, Quote__r.Name, Quote__r.SBQQ__Opportunity2__r.Opportunity_Number__c,                                                 
                                                Merchant_Application_Id__c, Cobrand__c                                               
                                                FROM NCR_Payments_Site__c 
                                                WHERE Id IN :pymSiteIds];
         
       try {
            if(!pymtSites.isEmpty()) {
                
                String accessToken = getAccessToken();                
                if(String.isBlank(accessToken) && !Test.isRunningTest()) throw new NullFieldException('Access Token not returned from infinicept');
                
                 JP_EndPoint__c onBoardEndPoint = JP_EndPoint__c.getValues('WithdrawApplication');
                 String WtdendpointURL = onBoardEndPoint.EndPoint_URL__c; 

                    //Map<String, JPLogs__c> payStIdvslogMap = queryLogs(pymtSites);
                    Map<String, JPLogs__c> payStIdvslogMap; 
                    
                    for (NCR_Payments_Site__c pymSite : pymtSites) {
                    String endpointURL=WtdendpointURL;
                    String mrchntAppId = '',cobrand ='', ApplicationId='',SiteId ='',OrganizationId='',ApplicationUrl='';
                    String mcn = pymSite.Account_Sites__r.Parent.Master_Customer_Number__c, dba = pymSite.Account_Sites__r.name;
                        mrchntAppId =pymSite.Merchant_Application_Id__c ;
                        cobrand = pymSite.Cobrand__c ;
                        SiteId =pymSite.SiteId__c; 
                        OrganizationId= pymSite.OrganizationId__c;
                        ApplicationUrl =pymSite.AdministratorURL__c ;
                        
                        /*JPLogs__c jplog = payStIdvslogMap.get(pymSite.Id);
                        
                        if(jplog != null && String.isNotBlank(jplog.Response__c) && !(jplog.Response__c.contains('failure') || jplog.Response__c.contains('error'))) {
                            List<SubmitApplicationResponse> sr = (List<SubmitApplicationResponse>)JSON.deserialize(jplog.Response__c, List<SubmitApplicationResponse>.class); 
                            
                            if(sr != NULL && sr.size() > 0) {
                                mrchntAppId = sr[0].merchantApplicationId;
                                cobrand = sr[0].cobrand;
                                SiteId = sr[0].siteId;
                                OrganizationId = sr[0].organizationId;
                                ApplicationUrl = sr[0].administratorURL;
                            }
                        }*/
                        
                        if(String.isBlank(mrchntAppId)) { // move it to sendWithdrawnRequest method
                            throw new NullFieldException('MerchantApplicationId not found for Payment site ' + pymSite.Name);
                        } else {                   
                            endpointURL = endpointURL.replace('{mrchntAppId}', mrchntAppId);
                        }  
                        
                        System.debug('Withdrawn endpoint>>' + endpointURL);
                         System.debug('Withdrawn opp>>' + opp);
                         System.debug('Withdrawn pymSite>>' + pymSite);
                         System.debug('Withdrawn cobrand>>' + cobrand);
                         System.debug('Withdrawn accessToken>>' + accessToken);
                         System.debug('Withdrawn logs>>' + logs);
                         System.debug('Withdrawn mcn>>' + mcn); 
                        System.debug('Withdrawn mrchntAppId>>' + mrchntAppId);
                         System.debug('Withdrawn SiteId>>' + SiteId);
                         System.debug('Withdrawn OrganizationId>>' + OrganizationId);
                        System.debug('Withdrawn ApplicationUrl>>' + ApplicationUrl);
                        System.debug('Withdrawn msg>>' + msg);
                        System.debug('Withdrawn dba>>' + dba);
                        
                        
                        //String rspMsg = sendWithdrawnRequest(opp, pymSite, endpointURL, cobrand, accessToken, logs);
                        String rspMsg = sendWithdrawnRequest(opp, pymSite, endpointURL, cobrand, accessToken, logs, mcn,mrchntAppId,SiteId,OrganizationId,ApplicationUrl,msg, dba );
                        
                        if(rspMsg != 'Success') {
                            errMsg +=  'Opportunity Number:' + opp.Opportunity_Number__c + ', Payment Site:' + pymSite.Name + '-Error:' + rspMsg + '\n';     
                        }
                    }
                
            }
       } catch (Exception e) {
           system.debug(e.getMessage());
           JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=opp.Opportunity_Number__c+'- Outbound-Withdrawn',
                                         status__c = ('Failure-Exception :' +e).left(250));
           logs.add(log);
           errMsg +=  'Opportunity Number:' + opp.Opportunity_Number__c + '-Error:' + e; 
           //return 'Error occured while Logging' + e;
       } 
        
        try {
            if(!logs.isEmpty()) {
                insert logs;
            }  
        } catch(Exception e) {
            System.debug('Error in Outbound-Withdrawn log creation:' + e.getMessage());  
            //return 'Error occured while Logging' + e;
        }
        if(String.isNotBlank(errMsg)) {
            return errMsg;
        }
        else{
             return 'Success: Application Withdrawn sent..';
        }
        // return 'Success: Application Withdrawn sent..';
        
    }
    
    
    /*public static Map<String, JPLogs__c> queryLogs(List<NCR_Payments_Site__c> pymtSites) {
        Map<String, JPLogs__c> payStIdvslogMap = new Map<String, JPLogs__c>();
        if(!pymtSites.isEmpty()) {
            String qtOrOpptyNbr= '';
            String OUTBOUND_LOG= 'OutBound', SUCCESS_STS = '%success%', ONBOARDING= '%OnBoarding%';
            
            
            for (NCR_Payments_Site__c nps : pymtSites) { 
                String recordName = (nps.Quote__c != NULL) ? nps.Quote__r.Name : nps.Opportunity__r?.Opportunity_Number__c;
                
                if(String.isNotBlank(qtOrOpptyNbr))  qtOrOpptyNbr += ' OR '; 
                qtOrOpptyNbr += 'name like \'' + recordName + '%\'';                    
            }
            qtOrOpptyNbr = '(' + qtOrOpptyNbr + ')';
            String jpQuery='SELECT Id, Name, Response__c FROM JPLogs__c WHERE ' + qtOrOpptyNbr + ' AND Type__c = :OUTBOUND_LOG AND Status__c like :SUCCESS_STS  order by createdDate desc';
            System.debug(jpquery);
            List<JPLogs__c> jpLogs = Database.query(jpquery);
            
            for (NCR_Payments_Site__c nps : pymtSites) { 
                String recordName = (nps.Quote__c != NULL) ? nps.Quote__r.Name : nps.Opportunity__r?.Opportunity_Number__c;
                
                for (JPLogs__c jpLog : jpLogs) {
                    if(jpLog.name.startsWith(recordName)) {
                        payStIdvslogMap.put(nps.Id, jpLog); 
                        break;
                    }     
              }                      
          }      
        } 
        return payStIdvslogMap;
    }*/
    
    
        public static String sendWithdrawnRequest(Opportunity opp, NCR_Payments_Site__c pymSite, String endpointURL, String cobrand, String accessToken, List<JPLogs__c> logs,String mcn,String mrchntAppId,String SiteId,String OrganizationId,String ApplicationUrl,String msg,String db) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
        integer retryCount = 0;
        integer maxRetry = Integer.valueOf(Label.MAX_RETRY_COUNT);        
        String status='Success';
        String parentName = (opp.CPQ__c &&  pymSite.Quote__c != null) ? pymSite.Quote__r.Name :opp.Opportunity_Number__c + '-' + pymSite.Name;
        
        while(retryCount < maxRetry) {
            status = 'Success';
            
            try {               
                req.setEndpoint(endpointURL); 
                req.setMethod('DELETE');
                req.setHeader('Authorization', 'Bearer ' + accessToken);                
                if(String.isNotBlank(cobrand)) req.setHeader('cobrand', cobrand); 
                req.setHeader('Content-Type', 'application/json');
                //req.setHeader('Content-Length', '512'); 
                req.setTimeout(120000); 
                withdrawnWrapper obj = new withdrawnWrapper();
                obj.MCN = mcn;
                obj.ApplicationId = mrchntAppId;
                obj.SiteId = SiteId;
                obj.OrganizationId = OrganizationId;
                obj.ApplicationUrl = ApplicationUrl;
                obj.Message = msg;
                obj.DbaName = db;
                req.setbody(json.serialize(obj));
                system.debug('reqreqreqreqreqreq'+req);
                resp = http.send(req);
                System.debug('resp.getStatus()'+resp.getStatus());
                System.debug('resp.getBody()'+resp.getBody()); 
                obj = null;
                
                if (resp.getStatus() == Label.HTTP_SUCCESS_STATUS && resp.getStatusCode() == Integer.valueOf(Label.HTTP_SUCCESS_STATUS_CODE)) {
                    System.debug('resp>>' + resp.getBody());  // parse response
                    logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-Withdrawn',Opportunity_Id__c = opp.Opportunity_Number__c, 
                                                      Request__c = 'path:'+ req + ',header:cobrand=' + cobrand, 
                                                      Response__c = resp.getBody(), status__c = status));
                    break;  
                } else {
                    retryCount++; 
                    
                    if(retryCount == maxRetry) {  
                         status = 'Failure:' + + resp.getStatus();
                         logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-Withdrawn', Request__c = 'path:'+ req.getEndpoint() + ',header:cobrand=' + cobrand, 
                                                Opportunity_Id__c = opp.Opportunity_Number__c,Response__c = (String.isNotBlank(resp.getBody())? resp.getBody() : resp.getStatus()), 
                                                status__c = status ));
                    }
                }
                
            } catch(Exception e) {
                retryCount++;

                if(retryCount == maxRetry) {
                    System.debug('Error:' + e.getMessage());
                    status = 'Failure:' + e.getMessage();
                    logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-Withdrawn', Request__c = 'path:'+ req.getEndpoint() + ',header:cobrand=' + cobrand, 
                                                Opportunity_Id__c = opp.Opportunity_Number__c,Response__c = e.getMessage(), 
                                                status__c = status));
                }
            } 
        }
        return status; 
    } 

    
    

    
     /* reverted payment site onboarding changes
     @future(callout=true)
     public static void onBoardPymntSite(String oppId, Set<Id> pymSiteIds) {
        List<JPLogs__c> logs = new  List<JPLogs__c>();
        String errMsg = '';
         
        Opportunity opp = [Select Id, Opportunity_Number__c, CPQ__c FROM Opportunity where Id = :oppId];        
        List<NCR_Payments_Site__c> pymtSites = [SELECT Id, Name, Opportunity__c, Opportunity__r.Opportunity_Number__c,
                                                Quote__c, Quote__r.Name, Quote__r.SBQQ__Opportunity2__r.Opportunity_Number__c,                                                 
                                                Merchant_Application_Id__c, Cobrand__c                                               
                                                FROM NCR_Payments_Site__c 
                                                WHERE Id IN :pymSiteIds];
         
       try {
            if(!pymtSites.isEmpty()) {
                
                String accessToken = getAccessToken();                
                if(String.isBlank(accessToken) && !Test.isRunningTest()) throw new NullFieldException('Access Token not returned from infinicept');
                
                 JP_EndPoint__c onBoardEndPoint = JP_EndPoint__c.getValues('JPOnBoarding');
                 String OnBoardendpointURL = onBoardEndPoint.EndPoint_URL__c; 
                 List<NCR_Payments_Site__c> jpLogSites = new List<NCR_Payments_Site__c>(); 
                 
                 for (NCR_Payments_Site__c pymSite : pymtSites) {                
                    String mrchntAppId = '',cobrand ='',  endpointURL=OnBoardendpointURL; 
                     
                    mrchntAppId = pymSite.Merchant_Application_Id__c;
                    cobrand = pymSite.Cobrand__c;
                    
                    if (!String.isBlank(mrchntAppId)) { // query merchant app Id and cobrand from JPLog  
                        endpointURL = endpointURL.replace('{mrchntAppId}', mrchntAppId);                        
                        System.debug('onbaording endpoint>>' + endpointURL);
                        
                        String rspMsg = sendOnboardingRequest(opp, pymSite, endpointURL, cobrand, accessToken, logs);
                         
                        if(rspMsg != 'Success') {
                            errMsg +=  'Opportunity Number:' + opp.Opportunity_Number__c + ', Payment Site:' + pymSite.Name + '-Error:' + rspMsg + '\n';     
                        }
                        
                    } else {
                        jpLogSites.add(pymSite);    
                    }
                }
                
                if(!jpLogSites.isEmpty()) { 
                    Map<String, JPLogs__c> payStIdvslogMap = queryJPLogs(jpLogSites);
                    String mrchntAppId = '',cobrand ='', endpointURL=OnBoardendpointURL;
                    
                    for (NCR_Payments_Site__c pymSite : jpLogSites) {
                        JPLogs__c jplog = payStIdvslogMap.get(pymSite.Id);
                        
                        if(jplog != null && String.isNotBlank(jplog.Response__c) && !(jplog.Response__c.contains('failure') || jplog.Response__c.contains('error'))) {
                            List<SubmitApplicationResponse> sr = (List<SubmitApplicationResponse>)JSON.deserialize(jplog.Response__c, List<SubmitApplicationResponse>.class); 
                            
                            if(sr != NULL && sr.size() > 0) {
                                mrchntAppId = sr[0].merchantApplicationId;
                                cobrand = sr[0].cobrand;
                                

                            }
                        }
                        
                        if(String.isBlank(mrchntAppId)) { // move it to sendOnboardingRequest method
                            throw new NullFieldException('MerchantApplicationId not found for Payment site ' + pymSite.Name);
                        } else {                   
                            endpointURL = endpointURL.replace('{mrchntAppId}', mrchntAppId);
                        }  
                        
                        System.debug('onbaording endpoint>>' + endpointURL);
                        String rspMsg = sendOnboardingRequest(opp, pymSite, endpointURL, cobrand, accessToken, logs);
                        
                        if(rspMsg != 'Success') {
                            errMsg +=  'Opportunity Number:' + opp.Opportunity_Number__c + ', Payment Site:' + pymSite.Name + '-Error:' + rspMsg + '\n';     
                        }
                    }
                }

            }
        } catch (Exception e) {
            system.debug(e.getMessage());
            JPLogs__c log = new JPLogs__c(Type__c = 'OutBound', name=opp.Opportunity_Number__c+'- Outbound-OnBoarding',
                                          status__c = ('Failure-Exception :' +e).left(250));
            logs.add(log);
            errMsg +=  'Opportunity Number:' + opp.Opportunity_Number__c + '-Error:' + e;  
        } 
         
         try {
             if(!logs.isEmpty()) {
                 insert logs;
             }  
         } catch(Exception e) {
            System.debug('Error in Outbound-OnBoarding log creation:' + e.getMessage());    
         }  
         
         if(String.isNotBlank(errMsg)) {
            String mailHdr ='', mailSubHdr ='', mailSub;
            mailHdr = ' Payment Site Onbording from Opportunity Closed/Booked Failed';
            mailSubHdr = mailHdr + ' for below payment sites'; 
            mailSub = mailHdr;
            List<String> rcpnts = NSC_Support_Error_Notification__c.getInstance('NSC Job Failure').ToEmailAddresses__c.split(','); 
            rcpnts.add(UserInfo.getUserEmail());
            EmailUtility.sendEmail(mailSub,mailHdr,mailSubHdr,errMsg,rcpnts);   
        }
    }
    
    
     public static Map<String, JPLogs__c> queryJPLogs(List<NCR_Payments_Site__c> pymtSites) {
        Map<String, JPLogs__c> payStIdvslogMap = new Map<String, JPLogs__c>();
        if(!pymtSites.isEmpty()) {
          String qtOrOpptyNbr= '';
          String OUTBOUND_LOG= 'OutBound', SUCCESS_STS = '%success%', ONBOARDING= '%OnBoarding%';
          
          
          for (NCR_Payments_Site__c nps : pymtSites) { 
              String recordName = (nps.Quote__c != NULL) ? nps.Quote__r.Name : nps.Opportunity__r?.Opportunity_Number__c;
              
              if(String.isNotBlank(qtOrOpptyNbr))  qtOrOpptyNbr += ' OR '; 
              qtOrOpptyNbr += 'name like \'' + recordName + '%\'';                    
          }
          qtOrOpptyNbr = '(' + qtOrOpptyNbr + ')';
          String jpQuery='SELECT Id, Name, Response__c FROM JPLogs__c WHERE ' + qtOrOpptyNbr + ' AND (NOT name like :ONBOARDING) AND Type__c = :OUTBOUND_LOG AND Status__c like :SUCCESS_STS  order by createdDate desc';
          System.debug(jpquery);
          List<JPLogs__c> jpLogs = Database.query(jpquery);
          
          for (NCR_Payments_Site__c nps : pymtSites) { 
              String recordName = (nps.Quote__c != NULL) ? nps.Quote__r.Name : nps.Opportunity__r?.Opportunity_Number__c;
              
              for (JPLogs__c jpLog : jpLogs) {
                  if(jpLog.name.startsWith(recordName)) {
                      payStIdvslogMap.put(nps.Id, jpLog); 
                      break;
                  }     
              }                      
          }      
        } 
        return payStIdvslogMap;
    }
        
    public static String sendOnboardingRequest(Opportunity opp, NCR_Payments_Site__c pymSite, String endpointURL, String cobrand, String accessToken, List<JPLogs__c> logs) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse resp;
        integer retryCount = 0;
        integer maxRetry = Integer.valueOf(Label.MAX_RETRY_COUNT);        
        String status='Success';
        String parentName = (opp.CPQ__c &&  pymSite.Quote__c != null) ? pymSite.Quote__r.Name :opp.Opportunity_Number__c + '-' + pymSite.Name;
        
        while(retryCount < maxRetry) {
            status = 'Success';
            
            try {               
                req.setEndpoint(endpointURL); 
                req.setMethod('PUT');
                req.setHeader('Authorization', 'Bearer ' + accessToken);                
                if(String.isNotBlank(cobrand)) req.setHeader('cobrand', cobrand); 
                req.setHeader('Content-Type', 'application/json');
                //req.setHeader('Content-Length', '512'); 
                req.setTimeout(120000);

                resp = http.send(req);
                System.debug(resp.getStatus());
                System.debug(resp.getBody());    
                
                if (resp.getStatus() == Label.HTTP_SUCCESS_STATUS && resp.getStatusCode() == Integer.valueOf(Label.HTTP_SUCCESS_STATUS_CODE)) {
                    System.debug('resp>>' + resp.getBody());  // parse response
                    logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-OnBoarding',Opportunity_Id__c = opp.Opportunity_Number__c, 
                                                      Request__c = 'path:'+ req.getEndpoint() + ',header:cobrand=' + cobrand, 
                                                      Response__c = resp.getBody(), status__c = status));
                    break;  
                } else {
                    retryCount++; 
                    
                    if(retryCount == maxRetry) {  
                         status = 'Failure:' + + resp.getStatus();
                         logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-OnBoarding', Request__c = 'path:'+ req.getEndpoint() + ',header:cobrand=' + cobrand, 
                                                Opportunity_Id__c = opp.Opportunity_Number__c,Response__c = (String.isNotBlank(resp.getBody())? resp.getBody() : resp.getStatus()), 
                                                status__c = status ));
                    }
                }
                
            } catch(Exception e) {
                retryCount++;

                if(retryCount == maxRetry) {
                    System.debug('Error:' + e.getMessage());
                    status = 'Failure:' + e.getMessage();
                    logs.add(new JPLogs__c(Type__c = 'OutBound', name=parentName+'- Outbound-OnBoarding', Request__c = 'path:'+ req.getEndpoint() + ',header:cobrand=' + cobrand, 
                                                Opportunity_Id__c = opp.Opportunity_Number__c,Response__c = e.getMessage(), 
                                                status__c = status));
                }
            } 
        }
        return status; 
    } */
    
    public class withdrawnWrapper {
        public string MCN;
        public String ApplicationId;
        public String SiteId;
        public String OrganizationId;
        public String ApplicationUrl;
        public String Message;
        public String DbaName;
    }
    

    class TemplateWrapper {
        public List < customFieldWrapper > CustomFields;
    }
    
    public class customFieldWrapper {
        public Integer Id;
        public String UserDefinedId;
        public List < String > ResponseValueKeys;
        public String FieldType;
    }
    
    public class SubmitApplicationResponse {        
        public String Type;
        public String merchantClaimURL;
        public String externalMerchantApplicationId;
        public String infiniceptApplicationId;
        public Integer status;
        public String statusMessage;
        public String organizationId;
        public String siteId;
        public String externalMerchantId;
        public String externalStoreId; 
        //Yogesh Changes 
        public String merchantApplicationId; 
        public String cobrand;
        public String administratorURL;
        
    }
    public class logObject {
        public Opportunity opp;
        public SBQQ__Quote__c qte;
        public String SubmitAppRequest;
        public String SubmitAppResponse;
        public String status;
    }
    public class TemplateException extends Exception {}
    public class NullFieldException extends Exception {}
    
    
}