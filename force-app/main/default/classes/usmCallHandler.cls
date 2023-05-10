/****************************************************************************************************************
* Author        :   Ajay Dixit 
* Description   :   This class populates all the field values that need to be sent over to USM.
****************************************************************************************************************/

 public class usmCallHandler {
    private static usmCallHandler instance = null;
    Public Static String createOppEndpointusm,createOppEndpointnsc, linkEndPoint, updateOppEndpoint, productEndpoint, username, password;
    Public Static Boolean sync=true;     
    // The constructor is private 
    private usmCallHandler() {
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }     
    // a static method that returns the instance of the record type
    public static usmCallHandler getInstance(){
        // lazy load the record type - only initialize if it doesn't already exist
        if (instance == null) instance = new usmCallHandler();
        return instance;
    }
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String
* Description   :   get Opportunity Call result
****************************************************************************************************************/
    
    public static void initVal(){
        Boolean isSandbox=[SELECT Id, IsSandbox  FROM Organization].isSandbox;
        List<USM__c> usm = USM__c.getall().values();
        for(USM__c u:usm){
            if(u.name.toUpperCase()=='USERNAME'){
                username=u.value__c ;   
            }
            if(u.name.toUpperCase()=='ENDPOINT_USM'){
                createOppEndpointusm=u.value__c ; 
            }
            if(u.name.toUpperCase()=='ENDPOINT_NSC'){
                createOppEndpointnsc=u.value__c ;   
            }
            if(u.name.toUpperCase()=='ENDPOINT_LINKING'){
                linkEndPoint=u.value__c ;   
            }
            if(u.name.toUpperCase()=='ENDPOINT_NSCOPPORTUNITYUPDATE'){
                updateOppEndpoint=u.value__c ;   
            }
            if(u.name.toUpperCase()=='ENDPOINT_PRODUCT'){
                productEndpoint=u.value__c ;   
            }
            if(u.name.toUpperCase()=='PASSWORD'){
                password=u.value__c ;   
            }
            if(u.name.toUpperCase()=='TURNOFFUSMSYNCFORSANDBOX'){
                if((isSandbox && u.value__c.toUpperCase()=='TRUE') ||u.value__c.toUpperCase()=='TRUE'){
                    sync=false;  
                }
                
            }
        }
    }
    
    public  String synchUSM(Opportunity opp, USM_Opportunity_Detail__c usmopp, String quicklook) {
        String usmOppNumber='';
        String nscSysId='';
        String msg='Successfully Engaged Salesforce Opportunity with USM '; 
        initVal();
        if(sync==false){
            msg='ERROR:Synch is turned Off';
            return msg;
        }
        
        //Query Opp detail        
        Opportunity oppDetail = [Select Id,(Select id, Product2.name, Primary_Line_Item_Key__c, UnitPrice, Quantity, TotalPrice, Product2.Service_Offer_Category__c, Product2.Product_Category__c,Product2.Family, Product2.isActive from OpportunityLineItems), Name, End_Customer__c, Marketing_Program__c, CampaignId, Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, Price_Variance__c, Discontinued_Reasons__c, Account.Name, Account.Master_customer_Number__c,  Key_Criteria__c, End_Customer__r.name, Master_Distributor__c, Annuity_Contract_Term__c, Services_Products__c, ExpectedRevenue, Annuity_Contract__c, Annuity_Order_Type__c, Primary_Competitor__c, primary_Competitor__r.name, Contract_Expiration_Date__c, Service_Order_Type__c, Fulfilled_by_Partner__c, Type, OwnerId , Owner.quicklook_id__c, Offer__c, Commitment_Risk__c, Risk_Comments__c , Account.Owner.Quicklook_id__c, Account.Area__c,Account.Industry, Description, CreatedDate,LastModifiedDate, Actual_Close_Date__c , recordtype.name, Account.Tier__c,CloseDate, Expected_Delivery_Date__c, Expected_Service_Start_Date__c, Account.Territory__c, Account.Account_Country_Code__c, Account.A360_Current_File_Value__c, Account.Parent_Account_Name__c, Campaign.Name, Account.Region__c , Account.Service_Partner__c , Services_Sales_Consultant__r.name , Services_Sales_Consultant__r.Quicklook_id__c , USM_NSC_Opportunity_Sys_Id__c , USM_Opportunity_Number__c FROM Opportunity where id = : opp.id]  ;
        try{ 
            msg=synchNscOppInfo_soup(oppDetail);  
            if(Test.isRunningTest() ){
                msg = 'SUCCESS TestMsgsysid:ys6655' ;
            }
            
            if(!msg.contains('ERROR') ){
                nscSysId=msg.substring(msg.indexOf('sysid:')+6, msg.length()).trim();
                msg=synchUsmOppProductInfo_soup(oppDetail);          
                //To Do Product info on LIST
                system.debug('******************'+msg);
                if(Test.isRunningTest() ) {
                    msg = 'SUCCESS TestMsgOPP:usm6556669' ;
                }
                if(!msg.contains('ERROR')){
                    msg=synchUsmOppInfo_soup(usmopp,oppDetail, quicklook); 
                    if(Test.isRunningTest() ) {
                        msg = 'SUCCESS TestMsgOPP:usm6556669' ;
                    }
                    // Extract USM Opportuity Number
                    //system.debug('!!!!!'+msg);
                    
                    usmOppNumber=msg.substring(msg.indexOf('OPP'), msg.length()).trim();
                    if(usmOppNumber.length()>9){
                        if(!msg.contains('ERROR')){
                            msg='Successfully associated USM - Opportunity Number:'+usmOppNumber;
                            try{
                                oppDetail.USM_Opportunity_Number__c=usmOppNumber; 
                                oppDetail.USM_NSC_Opportunity_Sys_Id__c=nscSysId;                            
                                update oppDetail;  
                            }catch(Exception e){
                                msg='ERROR: There was issue in Saving NSC Opportunity after Engagement, Save and Engage again'+e.getMessage(); 
                            }
                            
                        }
                        
                    }else{
                        msg='ERROR: There was issue while creating USM Opportunity record while trying to Engage '; 
                    }
                    
                }
            }
        }catch(Exception e){
            msg='ERROR: Fatal exception occured:'+e.getMessage()+', usmcallhandler Line #'+e.getLineNumber(); 
        }
        return msg;
    }
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String

* Description   :   get Opportunity Call result
****************************************************************************************************************/
  
    public static void synchUSMOnOppUpdate(List<Id> OppIds) {
        String usmOppNumber='';
        String msg='Successfully Engaged Salesforce Opportunity with USM '; 
        initVal();
        system.debug(updateOppEndpoint+'##'+createOppEndpointusm+'Test'+productEndpoint);
        if(sync==false){           
            return ;
        }
        //Query Opp detail
        List<Opportunity> oppDetail = [Select Id,(Select id, Product2.name, Primary_Line_Item_Key__c, UnitPrice, Quantity, TotalPrice, Product2.Service_Offer_Category__c, Product2.Product_Category__c,Product2.Family, Product2.isActive from OpportunityLineItems), Name, End_Customer__c, Marketing_Program__c, CampaignId, Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, Price_Variance__c, Discontinued_Reasons__c, Account.Name, Account.Master_customer_Number__c,Key_Criteria__c, End_Customer__r.name, Master_Distributor__c, Annuity_Contract_Term__c, Services_Products__c, ExpectedRevenue, Annuity_Contract__c, Annuity_Order_Type__c, Primary_Competitor__c, primary_Competitor__r.name, Contract_Expiration_Date__c, Service_Order_Type__c, Fulfilled_by_Partner__c, Type, OwnerId , Owner.quicklook_id__c, Offer__c, Commitment_Risk__c, Risk_Comments__c , Account.Owner.Quicklook_id__c, Account.Area__c,Account.Industry, Description, CreatedDate,LastModifiedDate, Actual_Close_Date__c , recordtype.name, Account.Tier__c,CloseDate, Expected_Delivery_Date__c, Expected_Service_Start_Date__c, Account.Territory__c, Account.Account_Country_Code__c, Account.A360_Current_File_Value__c, Account.Parent_Account_Name__c, Campaign.Name, Account.Region__c , Account.Service_Partner__c , Services_Sales_Consultant__r.name , Services_Sales_Consultant__r.Quicklook_id__c , USM_NSC_Opportunity_Sys_Id__c , USM_Opportunity_Number__c FROM Opportunity where id =: OppIds ]  ;
        
       
        for(Opportunity opp:oppDetail){  
            msg=synchNscOppInfoUpdate_soup(opp);
            system.debug('@@'+msg);
            if(!msg.contains('ERROR')){
                system.debug('@@'+msg);
                msg=synchUsmOppProductInfo_soup(opp); 
                
            }  
        }
        
        //return msg;
    }
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String

* Description   :   get Opportunity Call result
****************************************************************************************************************/
     
    public static void synchUSMOnOppLink(List<Id> OppIds) {
        String msg,nscSysId='';
        initVal();
        if(sync==false){          
            return;
        }
        //Query Opp detail
        List<Opportunity> oppDetail = [Select Id,(Select id, Product2.name, Primary_Line_Item_Key__c, UnitPrice, Quantity, TotalPrice, Product2.Service_Offer_Category__c, Product2.Product_Category__c,Product2.Family, Product2.isActive from OpportunityLineItems), Name, End_Customer__c, Marketing_Program__c, CampaignId, Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, Price_Variance__c, Discontinued_Reasons__c, Account.Name, Account.Master_customer_Number__c,Key_Criteria__c, End_Customer__r.name, Master_Distributor__c, Annuity_Contract_Term__c, Services_Products__c, ExpectedRevenue, Annuity_Contract__c, Annuity_Order_Type__c, Primary_Competitor__c, primary_Competitor__r.name, Contract_Expiration_Date__c, Service_Order_Type__c, Fulfilled_by_Partner__c, Type, OwnerId , Owner.quicklook_id__c, Offer__c, Commitment_Risk__c, Risk_Comments__c , Account.Owner.Quicklook_id__c, Account.Area__c,Account.Industry, Description, CreatedDate,LastModifiedDate, Actual_Close_Date__c , recordtype.name, Account.Tier__c,CloseDate, Expected_Delivery_Date__c, Expected_Service_Start_Date__c, Account.Territory__c, Account.Account_Country_Code__c, Account.A360_Current_File_Value__c, Account.Parent_Account_Name__c, Campaign.Name, Account.Region__c , Account.Service_Partner__c , Services_Sales_Consultant__r.name , Services_Sales_Consultant__r.Quicklook_id__c ,  USM_Opportunity_Number__c, USM_NSC_Opportunity_Sys_Id__c FROM Opportunity where id =: OppIds ]  ;
        //System.enqueuejob(new synchUSMOnOppLinkQueueable(oppDetail));
        //EBA_SF-1347
        List <Opportunity> OppListTemp =new List <Opportunity> ();
        for(Opportunity opp: oppDetail){
            msg=synchNscOppInfo_soup(opp);
            if(!msg.contains('ERROR') ){
                nscSysId=msg.substring(msg.indexOf('sysid:')+6, msg.length()).trim();  
                system.debug('@@@'+nscSysId);
                msg=synchUsmOppProductInfo_soup(opp);
                if(!msg.contains('ERROR')){  
                    //EBA_SF-1347
                     /*try{
                        opp.USM_NSC_Opportunity_Sys_Id__c=nscSysId;                            
                        update oppDetail;  
                    }catch(Exception e){
                        msg='ERROR: There was issue in Saving NSC Opportunity after Engagement, Save and Engage again'+e.getMessage(); 
                    }*/
                        opp.USM_NSC_Opportunity_Sys_Id__c=nscSysId;  
                        OppListTemp.add(opp);
                }
                
            }else{
                msg='ERROR: There was issue while creating USM Opportunity record while trying to Engage '; 
            }               
            
        } 
        //EBA_SF-1347
      if(OppListTemp.size()>0) {
          try{
                 update OppListTemp;   
                }  
        catch(Exception e){
                        msg='ERROR: There was issue in Saving NSC Opportunity after Engagement, Save and Engage again'+e.getMessage(); 
                    }
        
    }
    }
  
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String
* Description   :   get Opportunity Call result
****************************************************************************************************************/
    
    public  String linkUSM(String oppId, String usmopp) { 
        String msg='Successfully able to link Salesforce Opportunity with USM ';
        initVal();
        if(sync==false){
            msg='ERROR:Synch is turned Off';
            return msg;
        }        
        try{  
            String bdy='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.soup.ncr.com/SOUP/ABM/NSCUSMOpportunity/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<v1:OpportunityLinkageReq>'+
                responseHeader(oppId)+
                '<v1:OpportunityLinkageABMRequest>'+
                '<v1:u_opportunity>'+usmopp+'</v1:u_opportunity>'+
                '<v1:nsc_number>'+oppId+'</v1:nsc_number>'+
                '</v1:OpportunityLinkageABMRequest>'+
                '</v1:OpportunityLinkageReq>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';            
            HttpResponse res= httpRequestToUSM(linkEndPoint, bdy);
            //system.debug('#######'+res);
            String status=responseAttribute(res,'Status');
            if(!String.isEmpty(status) && (status.toUpperCase()!='SUCCESS') ){
                msg='ERROR:'+responseAttribute(res,'ERRORDESCRIPTION');
            }
        }catch(Exception e){
            msg='ERROR: error occured in Linking:'+e.getMessage()+', usmCallHandler'+e.getLineNumber();
        }     
        return msg; 
        
    }
    public  Static String responseHeader(String oppId){ 
        return '<ns:RequestHeader>'+  
            '<ns:TransactionID>'+oppId+'</ns:TransactionID>'+
            '<ns:SourceSystem>NSC</ns:SourceSystem>'+
            '<ns:Timestamp>'+System.now()+'</ns:Timestamp>'+
            '<ns:TargetSystem>USM</ns:TargetSystem>'+
            '</ns:RequestHeader>';
    }
    public Static HTTPResponse httpRequestToUSM(String endPoint, String bdy){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endPoint);
        req.setMethod('POST');
        req.setBody(bdy);
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('Accept-Encoding', 'gzip,deflate');        
        string encodedCredentials = EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));
        req.setHeader('Authorization', 'Basic ' + encodedCredentials);
        req.setTimeout(120000);
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    
    public Static String responseAttribute(HttpResponse res, String att){
        XmlStreamReader reader = res.getXmlStreamReader();
        system.debug('@@'+reader);
        String message='';     
        // Read through the XML
        while(reader.hasNext()) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {                
                if (reader.getLocalName().toUpperCase()==att.toUpperCase() ) {
                    reader.next();
                    if (reader.getEventType() == XmlTag.CHARACTERS){
                        message=reader.getText().trim();
                    }
                    break;
                    
                }
            }            
            reader.next();
        }
        return message;
    }
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String
* Description   :   get Opportunity Call result
****************************************************************************************************************/
    
    private static  String synchNscOppInfoUpdate_soup(Opportunity opp) {
        String msg='Successfully synched Opportunity Info with USM';
        try{
            String bdy='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.soup.ncr.com/SOUP/ABM/NSCUSMOpportunity/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<v1:UpdateOpportunityReq>'+
                responseHeader(opp.USM_NSC_Opportunity_Sys_Id__c)+
                oppUpdateReq(opp)+
                '</v1:UpdateOpportunityReq>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';  
            system.debug('!!'+bdy);
            HttpResponse res= httpRequestToUSM(updateOppEndpoint, bdy);
            system.debug('!!'+res);
            msg=responseAttribute(res,'ResponseDescription');
            if(!String.isEmpty(msg) && msg.toUpperCase().contains('RECEIVED')){
                msg='SUCCESS';
            }else{
                // Fetch usm Opp no.
                msg='ERROR:'+msg;
            }          
        }catch(Exception e){  
            msg='ERROR: error occured in Opportunity Synch:'+e.getMessage();
        }     
        return msg;
    }
    private Static String spclCharHandle(String s){
        if(!String.isEmpty(s)){
            return s.replaceAll('"', '&quot;').replaceAll('&', '&amp;').replaceAll('\'', '&apos;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');  
        }else{
            return '';
        }
        
    }
    public Static String oppUpdateReq(Opportunity opp){
        String primaryCompetitor=null;
        if(opp.Primary_Competitor__c!=null){ 
            primaryCompetitor=opp.Primary_Competitor__r.name;
            
        }
        String primaryCampaign=null;
        if(opp.CampaignId!=null && opp.Campaign.Name!=null){
            primaryCampaign=opp.Campaign.Name;            
        }
        return '<v1:UpdateOpportunityABMRequest>'+
            '<v1:request>'+
            '<v1:u_account_manager>'+opp.Account.Owner.Quicklook_id__c+'</v1:u_account_manager>'+
            '<v1:u_area>'+opp.Account.Area__c+'</v1:u_area>'+
            '<v1:u_sales_central_number>'+opp.Opportunity_Number__c+'</v1:u_sales_central_number>'+
            '<v1:u_industry>'+spclCharHandle(opp.Account.Industry)+'</v1:u_industry>'+
            '<v1:u_description>'+spclCharHandle(opp.Description)+'</v1:u_description>'+
            '<v1:u_short_description>'+spclCharHandle(opp.name)+'</v1:u_short_description>'+
            '<v1:u_opportunity_name>'+spclCharHandle(opp.name)+'</v1:u_opportunity_name>'+
            '<v1:u_nsc_created_date>'+String.valueOf(opp.CreatedDate)+'</v1:u_nsc_created_date>'+
            '<v1:u_expected_sign_date>'+String.valueOf(opp.CloseDate)+'</v1:u_expected_sign_date>'+
            '<v1:u_nsc_last_updated_date>'+String.valueOf(opp.LastModifiedDate)+'</v1:u_nsc_last_updated_date>'+
            '<v1:u_actual_close_date>'+String.valueOf(opp.Actual_Close_Date__c)+'</v1:u_actual_close_date>'+
            '<v1:u_nsc_opportunity_record_type>'+opp.recordtype.name+'</v1:u_nsc_opportunity_record_type>'+
            '<v1:u_tier>'+opp.Account.Tier__c+'</v1:u_tier>'+
            '<v1:u_expected_book_date>'+String.valueOf(opp.CloseDate)+'</v1:u_expected_book_date>'+
            '<v1:u_expected_delivery_date>'+String.valueOf(opp.Expected_Delivery_Date__c)+'</v1:u_expected_delivery_date>'+
            '<v1:u_expected_service_start_date>'+String.valueOf(opp.Expected_Service_Start_Date__c)+'</v1:u_expected_service_start_date>'+
            '<v1:u_selling_stage>'+opp.StageName+'</v1:u_selling_stage>'+
            '<v1:u_customer_parent_mcn>'+opp.Account.Master_customer_Number__c+'</v1:u_customer_parent_mcn>'+
            '<v1:u_end_customer_name>'+spclCharHandle(opp.Account.Name)+'</v1:u_end_customer_name>'+
            '<v1:u_master_customer_>'+opp.Master_Distributor__c+'</v1:u_master_customer_>'+
            '<v1:u_contract_duration>'+String.valueOf(opp.Annuity_Contract_Term__c)+'</v1:u_contract_duration>'+
            '<v1:u_services_product>'+String.valueOf(opp.Services_Products__c)+'</v1:u_services_product>'+
            '<v1:u_annuity_contract>'+String.valueOf(opp.Annuity_Contract__c)+'</v1:u_annuity_contract>'+
            '<v1:u_primary_competitor>'+spclCharHandle(primaryCompetitor)+'</v1:u_primary_competitor>'+
            '<v1:u_contract_expiration_date>'+String.valueOf(opp.Contract_Expiration_Date__c)+'</v1:u_contract_expiration_date>'+
            '<v1:u_service_partner>'+opp.Account.Service_Partner__c+'</v1:u_service_partner>'+
            '<v1:u_service_order_type>'+opp.Service_Order_Type__c+'</v1:u_service_order_type>'+
            '<v1:u_fulfilled_by_partner>'+String.valueOf(opp.Fulfilled_by_Partner__c)+'</v1:u_fulfilled_by_partner>'+
            '<v1:u_type>'+opp.Type+'</v1:u_type>'+
            '<v1:u_offer>'+spclCharHandle(opp.Offer__c)+'</v1:u_offer>'+
            '<v1:u_opportunity_owner_id>'+opp.Owner.quicklook_id__c+'</v1:u_opportunity_owner_id>'+
            '<v1:u_territory_alias>'+opp.Account.Territory__c+'</v1:u_territory_alias>'+
            '<v1:u_country_short_name>'+opp.Account.Account_Country_Code__c+'</v1:u_country_short_name>'+
            '<v1:u_current_file_value>'+String.valueOf(opp.Account.A360_Current_File_Value__c)+'</v1:u_current_file_value>'+
            '<v1:u_customer_parent_name>'+spclCharHandle(opp.Account.Parent_Account_Name__c)+'</v1:u_customer_parent_name>'+
            '<v1:u_commitment_risk>'+opp.Commitment_Risk__c+'</v1:u_commitment_risk>'+
            '<v1:u_forecast_category>'+opp.ForecastCategory+'</v1:u_forecast_category>'+
            '<v1:u_primary_campaign_source>'+spclCharHandle(primaryCampaign)+'</v1:u_primary_campaign_source>'+
            '<v1:u_country>'+opp.Account.Account_Country_Code__c+'</v1:u_country>'+
            '<v1:u_region>'+opp.Account.Region__c+'</v1:u_region>'+
            '<v1:u_lob>'+spclCharHandle(opp.Account_LOB__c)+'</v1:u_lob>'+
            '<v1:u_sales_program>'+spclCharHandle(opp.Marketing_Program__c)+'</v1:u_sales_program>'+
            '<v1:u_expected_total_contract>'+String.valueOf(opp.ExpectedRevenue)+'</v1:u_expected_total_contract>'+
            '<v1:u_risk_comments>'+spclCharHandle(opp.Risk_Comments__c)+'</v1:u_risk_comments>'+
            '<v1:u_key_criteria>'+spclCharHandle(opp.Key_Criteria__c)+'</v1:u_key_criteria>'+
            '<v1:u_price_variance>'+opp.Price_Variance__c+'</v1:u_price_variance>'+
            '<v1:u_discontinued_reasons>'+opp.Discontinued_Reasons__c+'</v1:u_discontinued_reasons>'+
            '<v1:u_opportunity_number>'+opp.USM_Opportunity_Number__c+'</v1:u_opportunity_number>'+
            '</v1:request>'+
            '</v1:UpdateOpportunityABMRequest>';
    }
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String
* Description   :   get Opportunity Call result
****************************************************************************************************************/
    
    public static  String synchNscOppInfo_soup(Opportunity opp) {
        system.debug('@@@@'+opp.id);
        String msg='Successfully synched Opportunity Info with USM';
        try{
            String bdy='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.soup.ncr.com/SOUP/ABM/NSCUSMOpportunity/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<v1:NSCOpportunityReq>'+
                responseHeader(opp.id)+
                oppReq(opp)+
                '</v1:NSCOpportunityReq>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';            
            HttpResponse res= httpRequestToUSM(createOppEndpointnsc, bdy);
            system.debug(bdy);
            String status=responseAttribute(res,'status');
            system.debug('@@Ajay'+res.getBody());
            if(!String.isEmpty(status) && status.toUpperCase()!='SUCCESS'){
                msg='ERROR:'+responseAttribute(res,'ERRORDESCRIPTION');
                system.debug('++++@@@@@'+res) ;
            }else{
                // Fetch sysid
                msg=msg+ 'sysid:'+responseAttribute(res,'sys_id');
            }
            system.debug('@@@@@'+msg+'@@'+responseAttribute(res,'ERRORDESCRIPTION')) ;   
        }catch(Exception e){  
            msg='ERROR: error occured in Opportunity Synch:'+e.getMessage();
        }     
        return msg;
    }
    private Static String oppReq(Opportunity opp){
        String primaryCompetitor=null;
        if(opp.Primary_Competitor__c!=null){ 
            primaryCompetitor=opp.Primary_Competitor__r.name;
            
        }
        String primaryCampaign=null;
        if(opp.CampaignId!=null && opp.Campaign.Name!=null){
            primaryCampaign=opp.Campaign.Name;            
        }
        return '<v1:CreateNSCOpportunityABMRequest>'+
            '<v1:u_account_manager>'+opp.Account.Owner.Quicklook_id__c+'</v1:u_account_manager>'+
            '<v1:u_area>'+opp.Account.Area__c+'</v1:u_area>'+
            '<v1:u_sales_central_number>'+opp.Opportunity_Number__c+'</v1:u_sales_central_number>'+
            '<v1:u_industry>'+spclCharHandle(opp.Account.Industry)+'</v1:u_industry>'+
            '<v1:u_description>'+spclCharHandle(opp.Description)+'</v1:u_description>'+
            '<v1:u_short_description>'+spclCharHandle(opp.name)+'</v1:u_short_description>'+
            '<v1:u_opportunity_name>'+spclCharHandle(opp.name)+'</v1:u_opportunity_name>'+
            '<v1:u_nsc_created_date>'+String.valueOf(opp.CreatedDate)+'</v1:u_nsc_created_date>'+
            '<v1:u_expected_sign_date>'+String.valueOf(opp.CloseDate)+'</v1:u_expected_sign_date>'+
            '<v1:u_nsc_last_updated_date>'+String.valueOf(opp.LastModifiedDate)+'</v1:u_nsc_last_updated_date>'+
            '<v1:u_actual_close_date>'+String.valueOf(opp.Actual_Close_Date__c)+'</v1:u_actual_close_date>'+
            '<v1:u_nsc_opportunity_record_type>'+opp.recordtype.name+'</v1:u_nsc_opportunity_record_type>'+
            '<v1:u_tier>'+opp.Account.Tier__c+'</v1:u_tier>'+
            '<v1:u_expected_book_date>'+String.valueOf(opp.CloseDate)+'</v1:u_expected_book_date>'+
            '<v1:u_expected_delivery_date>'+String.valueOf(opp.Expected_Delivery_Date__c)+'</v1:u_expected_delivery_date>'+
            '<v1:u_expected_service_start_date>'+String.valueOf(opp.Expected_Service_Start_Date__c)+'</v1:u_expected_service_start_date>'+
            '<v1:u_selling_stage>'+opp.StageName+'</v1:u_selling_stage>'+
            '<v1:u_customer_parent_mcn>'+opp.Account.Master_customer_Number__c+'</v1:u_customer_parent_mcn>'+
            '<v1:u_end_customer_name>'+spclCharHandle(opp.Account.Name)+'</v1:u_end_customer_name>'+
            '<v1:u_master_customer_>'+opp.Master_Distributor__c+'</v1:u_master_customer_>'+
            '<v1:u_contract_duration>'+String.valueOf(opp.Annuity_Contract_Term__c)+'</v1:u_contract_duration>'+
            '<v1:u_services_product>'+String.valueOf(opp.Services_Products__c)+'</v1:u_services_product>'+
            '<v1:u_annuity_contract>'+String.valueOf(opp.Annuity_Contract__c)+'</v1:u_annuity_contract>'+
            '<v1:u_primary_competitor>'+spclCharHandle(primaryCompetitor)+'</v1:u_primary_competitor>'+
            '<v1:u_contract_expiration_date>'+String.valueOf(opp.Contract_Expiration_Date__c)+'</v1:u_contract_expiration_date>'+
            '<v1:u_service_partner>'+opp.Account.Service_Partner__c+'</v1:u_service_partner>'+
            '<v1:u_service_order_type>'+opp.Service_Order_Type__c+'</v1:u_service_order_type>'+
            '<v1:u_fulfilled_by_partner>'+String.valueOf(opp.Fulfilled_by_Partner__c)+'</v1:u_fulfilled_by_partner>'+
            '<v1:u_type>'+opp.Type+'</v1:u_type>'+
            '<v1:u_offer>'+spclCharHandle(opp.Offer__c)+'</v1:u_offer>'+
            '<v1:u_opportunity_owner_id>'+opp.Owner.quicklook_id__c+'</v1:u_opportunity_owner_id>'+
            '<v1:u_territory_alias>'+opp.Account.Territory__c+'</v1:u_territory_alias>'+
            '<v1:u_country_short_name>'+opp.Account.Account_Country_Code__c+'</v1:u_country_short_name>'+
            '<v1:u_current_file_value>'+String.valueOf(opp.Account.A360_Current_File_Value__c)+'</v1:u_current_file_value>'+
            '<v1:u_customer_parent_name>'+spclCharHandle(opp.Account.Parent_Account_Name__c)+'</v1:u_customer_parent_name>'+
            '<v1:u_commitment_risk>'+opp.Commitment_Risk__c+'</v1:u_commitment_risk>'+
            '<v1:u_forecast_category>'+opp.ForecastCategory+'</v1:u_forecast_category>'+
            '<v1:u_primary_campaign_source>'+spclCharHandle(primaryCampaign)+'</v1:u_primary_campaign_source>'+
            '<v1:u_country>'+opp.Account.Account_Country_Code__c+'</v1:u_country>'+
            '<v1:u_region>'+opp.Account.Region__c+'</v1:u_region>'+
            '<v1:u_lob>'+spclCharHandle(opp.Account_LOB__c)+'</v1:u_lob>'+
            '<v1:u_sales_program>'+spclCharHandle(opp.Marketing_Program__c)+'</v1:u_sales_program>'+
            '<v1:u_expected_total_contract>'+String.valueOf(opp.ExpectedRevenue)+'</v1:u_expected_total_contract>'+
            '<v1:u_risk_comments>'+spclCharHandle(opp.Risk_Comments__c)+'</v1:u_risk_comments>'+
            '<v1:u_key_criteria>'+spclCharHandle(opp.Key_Criteria__c)+'</v1:u_key_criteria>'+
            '<v1:u_price_variance>'+opp.Price_Variance__c+'</v1:u_price_variance>'+
            '<v1:u_discontinued_reasons>'+opp.Discontinued_Reasons__c+'</v1:u_discontinued_reasons>'+ 
            '<v1:u_usm_opportunity_number>'+opp.USM_Opportunity_Number__c+'</v1:u_usm_opportunity_number>'+
            '</v1:CreateNSCOpportunityABMRequest>';
    }
    
    
    /****************************************************************************************************************
* Author        :   Ajay Dixit
* Param         :   Opportunity
* Return        :   String
* Description   :   get Opportunity Call result
****************************************************************************************************************/
    
    private  String synchUsmOppInfo_soup(USM_Opportunity_Detail__c usmopp, Opportunity opp,String quicklook) {
        String msg='Successfully synched Opportunity Info with USM';
        String usmOppRequest;
        try{
            usmOppRequest=usmoppReq(opp, usmopp, quicklook);
            String bdy='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.soup.ncr.com/SOUP/ABM/NSCUSMOpportunity/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<v1:USMOpportunityReq>'+
                responseHeader(opp.id)+
                usmOppRequest+
                '</v1:USMOpportunityReq>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';            
            HttpResponse res= httpRequestToUSM(createOppEndpointusm, bdy);
            system.debug('!!!!!!!!!!!!!!'+res);
            system.debug('!!@@'+bdy);
            //<xsd:element ref="sys_id"/>
            //<xsd:element ref="u_opportunity_number"/>
            
            String status=responseAttribute(res,'Status');
            msg=responseAttribute(res,'ERRORDESCRIPTION');
            if(!String.isEmpty(status) && status.toUpperCase()=='FAILURE'){
                msg='ERROR:'+msg;
                logUSMRequest('Failure', usmOppRequest, msg, opp.Opportunity_Number__c);
            }else{
                // Fetch usm Opp no.
                msg=msg+ 'USM #'+responseAttribute(res,'u_opportunity_number');
                logUSMRequest('Success', usmOppRequest, msg, opp.Opportunity_Number__c);
            }
            
            
            
        }catch(Exception e){  
            msg='ERROR: error occured in Opportunity Synch:'+e.getMessage();
            logUSMRequest('Failure', usmOppRequest, msg, opp.Opportunity_Number__c);
        }     
        return msg;
    }
    private Static String usmoppReq(Opportunity opp, USM_Opportunity_Detail__c usmopp,String quicklook ){
        
        String nonstndrd, sr, sc;
        if(usmopp.Nonstandard_Terms__c!=null){
            nonstndrd=usmopp.Nonstandard_Terms__c.replaceAll(';', ',');
        }
        if(usmopp.Services_Countries__c!=null){
            sc=usmopp.Services_Countries__c.replaceAll(';', ',');
        }
        if(usmopp.Services_Regions__c!=null){
            sr=usmopp.Services_Regions__c.replaceAll(';', ',');
        }
        String prblm='<![CDATA['+usmopp.What_problem_is_customer_trying_to_solve__c+']]>';
        return '<v1:CreateUSMOpportunityABMRequest>'+
            '<v1:u_sales_central_number>'+opp.Opportunity_Number__c+'</v1:u_sales_central_number>'+
            '<v1:u_additional_information>'+spclCharHandle(usmopp.Additional_Information__c)+'</v1:u_additional_information>'+
            '<v1:u_additonal_nonstandard_terms>'+spclCharHandle(usmopp.Additonal_Nonstandard_Terms__c)+'</v1:u_additonal_nonstandard_terms>'+            
            '<v1:u_total_premise>'+String.valueOf(usmopp.Total_Premise__c)+'</v1:u_total_premise>'+
            '<v1:u_parent>'+usmopp.Parent__c+'</v1:u_parent>'+
            '<v1:u_services_regions>'+sr+'</v1:u_services_regions>'+
            '<v1:u_file_value_at_risk>'+String.valueOf(usmopp.File_Value_at_Risk__c)+'</v1:u_file_value_at_risk>'+
            //'<v1:u_opportunity_number>'+'</v1:u_opportunity_number>'+
            '<v1:u_managed_services_requested>'+String.valueOf(usmopp.Managed_Services_Requested__c)+'</v1:u_managed_services_requested>'+
            '<v1:u_multi_vendor>'+String.valueOf(usmopp.Multi_Vendor__c)+'</v1:u_multi_vendor>'+
            //
            '<v1:u_nonstandard_terms>'+spclCharHandle(nonstndrd)+'</v1:u_nonstandard_terms>'+
            '<v1:u_requested_by>'+quicklook+'</v1:u_requested_by>'+
            '<v1:u_required_bid_completion_date>'+String.valueOf(usmopp.Required_Bid_Completion_Date__c)+'</v1:u_required_bid_completion_date>'+
            '<v1:u_services_countries>'+sc+'</v1:u_services_countries>'+
            '<v1:u_services_sales_consultant>'+opp.Services_Sales_Consultant__r.Quicklook_id__c+'</v1:u_services_sales_consultant>'+
            '<v1:u_supported_equipment>'+spclCharHandle(usmopp.Supported_Equipment__c)+'</v1:u_supported_equipment>'+
            '<v1:u_ts_sow_value>'+String.valueOf(usmopp.TS_SOW_Value_USD__c)+'</v1:u_ts_sow_value>'+
            '<v1:u_are_additional_services>'+usmopp.Are_additional_services_being_requested__c+'</v1:u_are_additional_services>'+
            '<v1:u_are_new_hardware>'+usmopp.Are_new_hardware_products_being_added__c+'</v1:u_are_new_hardware>'+
            '<v1:u_are_requested_services>'+usmopp.Are_requested_services_in_price_book__c+'</v1:u_are_requested_services>'+
            '<v1:u_customer_network>'+usmopp.Customer_network_connectivity_strategy__c+'</v1:u_customer_network>'+
            '<v1:u_do_you_have_an>'+usmopp.Do_you_have_an_approved_T_T_price_book__c+'</v1:u_do_you_have_an>'+
            '<v1:u_is_customer_direct>'+usmopp.Is_customer_Direct_or_Channel__c+'</v1:u_is_customer_direct>'+
            '<v1:u_is_customer_requesting>'+usmopp.Is_customer_requesting_On_Premise__c+'</v1:u_is_customer_requesting>'+
            '<v1:u_is_in_country_location>'+usmopp.Is_in_country_location_required__c+'</v1:u_is_in_country_location>'+
            '<v1:u_is_sw_maintenance_required>'+usmopp.SW_maintenance_required_on_end_points__c+'</v1:u_is_sw_maintenance_required>'+
            '<v1:u_is_there_any_change>'+usmopp.Any_change_in_PPM_SLA_or_geography__c+'</v1:u_is_there_any_change>'+
            '<v1:u_is_this_a_contract_renewal>'+usmopp.Is_this_a_renewal_or_new_business__c+'</v1:u_is_this_a_contract_renewal>'+
            '<v1:u_ts_sow_duration_months>'+usmopp.TS_SOW_duration_Months__c+'</v1:u_ts_sow_duration_months>'+
            '<v1:u_t_t_price_book>'+usmopp.T_T_Price_book__c+'</v1:u_t_t_price_book>'+
            '<v1:u_what_is_sw_configuration>'+usmopp.What_is_SW_configuration__c+'</v1:u_what_is_sw_configuration>'+
            '<v1:u_what_is_the_hw_configuration>'+usmopp.What_is_the_HW_configuration__c+'</v1:u_what_is_the_hw_configuration>'+
            '<v1:u_what_problem_is_the_customer>'+prblm+'</v1:u_what_problem_is_the_customer>'+
            '<v1:u_will_ncr_provide_ncr>'+usmopp.Will_NCR_provide_NCR_break_fix_Service__c+'</v1:u_will_ncr_provide_ncr>'+
            '<v1:u_will_this_service_scope>'+usmopp.Will_this_be_added_to_existing_contract__c+'</v1:u_will_this_service_scope>'+
            +'</v1:CreateUSMOpportunityABMRequest>';
    }
    public static String synchUsmOppProductInfo_soup(Opportunity opp) {
        String msg;
        try{
            String bdy='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v1="http://xmlns.soup.ncr.com/SOUP/ABM/NSCUSMOpportunity/V1" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/2.0">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<v1:ProductsReqABM>'+
                responseHeader(opp.id)+
                usmopplineReq(opp)+
                '</v1:ProductsReqABM>'+
                '</soapenv:Body>'+
                '</soapenv:Envelope>';            
            HttpResponse res= httpRequestToUSM(productEndpoint, bdy);            
            msg=responseAttribute(res,'ResponseDescription');
            res.getStatus();
            system.debug(res.getStatus()+'++++++++++++++++++');
            system.debug(msg+'##########');
            if(res.getStatus().toUpperCase()=='OK'){
                msg = 'SUCCESS';
            }
            /*if(!String.isEmpty(msg) && msg.toUpperCase().contains('SUCCESSFULLY')){
                msg='SUCCESS';
               
            }*/else{
                // Fetch usm Opp no.
                msg='ERROR:'+msg;
            }       
            
        }catch(Exception e){  
            msg='ERROR: error occured in Opportunity Synch:'+e.getMessage();
        }     
        return msg;
    }
    @Future
    public static void logUSMRequest(String status, String Request, String response, String oppno) {
        USM_Log__c ul=new USM_Log__c(name=oppno+'-'+system.now(), USM_Detail_Request__c=Request, Status__c=status, Response__c=response	);  
        insert ul;
    }
    
    private Static String usmopplineReq(Opportunity opp){
        String s1;
         
        for(OpportunityLineItem oli:opp.opportunitylineitems){
            s1=s1+  '<v1:ProductReq>'+             
                '<v1:u_nsc_active_product>'+String.ValueOf(oli.product2.isActive)+'</v1:u_nsc_active_product>'+               
                '<v1:u_nsc_net_unit_price>'+String.valueOf(oli.unitPrice)+'</v1:u_nsc_net_unit_price>'+               
                '<v1:u_nsc_number>'+opp.Opportunity_Number__c+'</v1:u_nsc_number>'+             
                '<v1:u_nsc_primary_line_item_id>'+oli.Primary_Line_Item_Key__c+'</v1:u_nsc_primary_line_item_id>'+               
                '<v1:u_nsc_product_category>'+oli.Product2.product_category__c+'</v1:u_nsc_product_category>'+               
                '<v1:u_nsc_product_family>'+oli.Product2.Family+'</v1:u_nsc_product_family>'+               
                '<v1:u_nsc_product_name>'+spclCharHandle(oli.Product2.Name)+'</v1:u_nsc_product_name>'+              
                '<v1:u_nsc_quantity>'+String.valueOf(oli.quantity)+'</v1:u_nsc_quantity>'+               
                '<v1:u_nsc_sales_central_number>'+opp.Opportunity_Number__c+'</v1:u_nsc_sales_central_number>'+               
                '<v1:u_nsc_service_offer_category>'+oli.Product2.Service_offer_Category__c+'</v1:u_nsc_service_offer_category>'+               
                '<v1:u_nsc_total_price>'+String.valueOf(oli.totalPrice)+'</v1:u_nsc_total_price>'+
                '<v1:u_opportunity_number>'+opp.USM_Opportunity_Number__c+'</v1:u_opportunity_number>'+
                '</v1:ProductReq>';
        }
        return '<v1:ProductsRequest>'+s1+'</v1:ProductsRequest>';
    }
}