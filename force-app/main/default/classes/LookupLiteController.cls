/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
                                                   
***************************************/


public without sharing class LookupLiteController {

  @AuraEnabled
  public static List < sObject > fetchRecords(String objectName, String filterField, String searchString) {
		String queryName = ''+ searchString.trim() + '%'; 
    String query = 'SELECT Id, ' + filterField + ' FROM ' + objectName + ' WHERE ' + filterField + ' LIKE :queryName LIMIT 50000';
    //String query = 'SELECT Id, ' + filterField + ' FROM ' + objectName + ' WHERE ' + filterField + ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 50000';

	//List<SObject> ObjectContents = database.query(String.escapeSingleQuotes(query));
      //system.debug('sizeeeeeeee:::'+ObjectContents.size());

    //return Database.query(String.escapeSingleQuotes(query));
     return Database.query(String.escapeSingleQuotes(query));
  }

  @auraEnabled
  public static sObject fetchSelectedRecord(String objectName, String searchString) {
    //String whereClause = ' id = \'' + String.escapeSingleQuotes(searchString.trim()) + '\' ';
    String Recordid = String.escapeSingleQuotes(searchString.trim());
    String query = 'SELECT Id,Name,Email,MobilePhone,Phone from ' + objectName + ' where id=:searchString';
    return Database.query(String.escapeSingleQuotes(query));
  }
    
    @AuraEnabled 
    public static String fetchDspROR() {
    	return DisputeUtil.getDspROR();    
    }
  

  @AuraEnabled
  Public static String UpdateContact(String ContactIdS, String AlternateContactId, String ContactPhone, String AlternatePhone, String InvoiceMCN) {

    Set < String > ContactIdSet = new Set < String > ();
    List < String > PhoneList = new List < String > ();
    String ConfirmMsg = '';
    Map < Id,
    String > ContactPhoneMap = new Map < Id,
    String > ();
    if (String.isNotBlank(ContactIdS)) {
      ContactIdSet.add(ContactIdS);
      if (String.isNotBlank(ContactPhone)) {
        PhoneList.add(ContactPhone.toLowercase());
        ContactPhoneMap.put(ContactIdS, ContactPhone);
        if (String.isNotBlank(ContactIdS)) {

          List < Contact > CustomerContactAccount = new List < Contact > ();
          CustomerContactAccount = [Select id, Account.Master_Customer_Number__c, Email from Contact where id = :ContactIdS];

          if ((CustomerContactAccount != null) && (CustomerContactAccount.size() > 0) && (CustomerContactAccount[0].Account.Master_Customer_Number__c != InvoiceMCN) && String.isNotBlank(CustomerContactAccount[0].Email) && (!CustomerContactAccount[0].Email.toUpperCase().contains('NCR.COM'))) {
            ConfirmMsg = 'Customer Contact Does not belong to dispute customer/Account.Please select continue if you want to proceed with entered contact.';
          }

        }
      }
    }
    if (String.isNotBlank(AlternateContactId)) {
      ContactIdSet.add(AlternateContactId);
      if (String.isNotBlank(AlternatePhone)) {
        PhoneList.add(AlternatePhone.toLowercase());
        ContactPhoneMap.put(AlternateContactId, AlternatePhone);
        if (String.isNotBlank(AlternateContactId)) {
          List < Contact > AlterNateContactAccount = new List < Contact > ();
          AlterNateContactAccount = [Select id, Account.Master_Customer_Number__c, Email from Contact where id = :AlternateContactId];
          if ((AlterNateContactAccount != null) && (AlterNateContactAccount.size() > 0) && (AlterNateContactAccount[0].Account.Master_Customer_Number__c != InvoiceMCN) && String.isNotBlank(AlterNateContactAccount[0].Email) && (!AlterNateContactAccount[0].Email.toUpperCase().contains('NCR.COM'))) {
            if (String.isBlank(ConfirmMsg)) {
              ConfirmMsg = 'Alternate Contact Does not belong to dispute customer/Account.Please select continue if you want to proceed with entered contact.';
            } 
            else {
              ConfirmMsg = 'Customer Contact and Alternate Contact Does not belong to dispute customer/Account.Please select continue if you want to proceed with entered contact.';
            }
          }
        }

      }

    }

    if (ContactIdSet.size() > 0) {
      List < Contact > ConObjListtoUpdate = new List < Contact > ();
      //system.debug('><><><><><::'+ContactPhoneMap);
      for (Contact ConObj: [Select id, Phone, Email, Account.Master_Customer_Number__c from Contact where Id IN: ContactIdSet]) {

        if (String.isNotBlank(ConObj.Email)) {
          if ((ContactPhoneMap != null) && (ContactPhoneMap.containskey(ConObj.Id)) && (String.isNotBlank(ContactPhoneMap.get(ConObj.Id)))) {
            contact con = new Contact();
            con.Id = ConObj.Id;
            con.Phone = ContactPhoneMap.get(ConObj.Id);
            ConObjListtoUpdate.add(con);
          }

        }
      }
      //System.debug('ConObjListtoUpdate'+ConObjListtoUpdate);
      if (ConObjListtoUpdate.size() > 0) {
        try {
          update ConObjListtoUpdate;

        }

        catch(Exception e) {
          System.debug('');
        }
      }
    }

    return ConfirmMsg;
  }

  @AuraEnabled
  Public Static ValidateDispute CreateDisputeInCCAD(String DisputeData, String InvoiceTableDate) {

    List < dispute_integration_logs__c > dispLogList = new List < dispute_integration_logs__c > ();
    String CCADDisputeNo = '';
    ValidateDispute validObj = new ValidateDispute();
    final string SUCCESS_STATUS = 'OK';
    final string FAILURE_STATUS = 'FAILURE';  
    HttpRequest req = new HttpRequest(); 
    HttpResponse res = new HttpResponse();
      
    String disputeId;  
    try {
    //  Soup_Username__mdt soup_cred = [select user_name__c, password__c, EndPoint__c from Soup_Username__mdt where DeveloperName = 'sendDisuptesToCcad'];
    //  String userID = string.valueof(soup_cred.user_name__c);
    //  String password = soup_cred.password__c;
    //  String EndPoint = soup_cred.EndPoint__c;
    //  HttpRequest req = new HttpRequest();
     
    //  Blob headerValue = Blob.valueOf(userID + ':' + password);
    //  String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
      Http h = new Http();
      //system.debug('DisputeDate'+DisputeData);
      //system.debug('InvoiceTableDate'+InvoiceTableDate); 
      DisputeDataWrapper deserializeResults = (DisputeDataWrapper) JSON.deserialize(DisputeData, DisputeDataWrapper.class);
      system.debug('customObject>>>>>>' + deserializeResults.Submitter_Name);

      List < PardateTableDataToDisputeInvoice > InvoiceParceObj = new List < PardateTableDataToDisputeInvoice > ();
      InvoiceParceObj = PardateTableDataToDisputeInvoice.ParseSummeryData(InvoiceTableDate);

      String DisputeCreationBody = generateRequestBodyForDisputeCreation(deserializeResults, InvoiceParceObj);
      system.debug('><<><><><' + DisputeCreationBody);
      req.setBody(DisputeCreationBody);
      //Hit the Soup Webservice after Authorization and check for the response  
      req.setMethod('POST');
      //req.setHeader('Authorization', authorizationHeader);
      req.setHeader('Accept', 'application/xml');
      req.setHeader('Content-Type', 'application/xml');
      req.setEndpoint('callout:NSC_SOUP_Dispute_To_CCAD');  
    //  req.setEndpoint(EndPoint);
      req.setTimeout(120000);  //30000
      system.debug('req>> ' + req.getBody());

      res = h.send(req);
      system.debug('<><><><><' + res.getBody());
      system.debug('::::::::::::' + res.getStatus());

      dispute_integration_logs__c dil = new dispute_integration_logs__c();
      dil.Request__c = req.getBody();
      dil.Response__c = res.getBody();
      dil.Status__c = res.getStatus();
      dil.RequestType__c = 'SF-CCAD-flow';
      //dil.caseNumber__c=caseDetails.CaseNumber;
      //dispLogList.add(dil);

      Dom.Document doc = res.getBodyDocument();
      Dom.XMLNode rootElement = doc.getRootElement();

      Dom.XmlNode body = rootElement.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
      //System.debug('Body is: ---------------->>>'+body);

      Dom.XmlNode createDisputeNode = body.getChildElement('CreateDisputeResponse', 'soup.ncr.com.InvDisputeSvc');
      //System.debug('createDisputeNode is: ---------------->>>'+createDisputeNode);

     disputeId = createDisputeNode.getChildElement('Dispute_ID', 'soup.ncr.com.InvDisputeSvc').getText();
      //system.debug('pppppppppaaaaaaaaa'+createDisputeNode.getChildElement('Invoice_List_Resp', 'soup.ncr.com.InvDisputeSvc'));
      Dom.XmlNode Invoice_List_Resp = createDisputeNode.getChildElement('Invoice_List_Resp', 'soup.ncr.com.InvDisputeSvc');

      String MasterCustNo = deserializeResults.Master_Customer_Number;
      Map < String,List < String >> DisputeValidationMap = new Map < String,List < String >> ();
      for (Dom.XMLNode childElement: Invoice_List_Resp.getChildElements()) {
        //system.debug('debug Data  '+childElement.getName() + '-' + childElement.getText() );
        for (Dom.XMLNode childElement1: childElement.getChildElements()) {
          //system.debug('<><>><><><><><>'+childElement1.getName());
          //system.debug('@@@@@@@@@@@@@@@'+childElement1.getText());

          if (!DisputeValidationMap.ContainsKey(childElement1.getName())) {
            DisputeValidationMap.put(childElement1.getName(), new List < String > ());
          }
          DisputeValidationMap.get(childElement1.getName()).add(childElement1.getText());

        }
      }
      // print out specific elements 
      //System.debug('disputeId: ' + disputeId);
      //System.debug('responseStatus: ' + res.getStatus());

      if (res.getStatus() == SUCCESS_STATUS) {
        //system.debug('@@@@@ POST method successfully executed');
        //updateDisputeNumberInSFAndSendCaseCreationEmail(caseDetails,disputeId, true);
        //CCADDisputeNo = disputeId;

        if (Integer.valueOf(disputeId) == 0) {

          validObj.IsValidate = false;
          validObj.ValidationMsg = 'No Invoice To Dispute';

          if (DisputeValidationMap != null && DisputeValidationMap.KeySet().Size() > 0) {

            Set < String > CCADMcnList = new Set < String > ();
            Set < String > CCADDisputeList = new Set < String > ();
            if (DisputeValidationMap.containsKey('Master_Customer_Number')) {

              for (String MCN: DisputeValidationMap.get('Master_Customer_Number')) {
                System.debug('111111111111' + MCN);
                if (  MCN != 'No invoices to dispute' && MCN != '0' && (MCN != MasterCustNo) && (String.isNotBlank(MCN))) {
                  //validObj.ValidationMsg='Invoices exist in CCAD with different MCN'+':'+MCN;
                  //validObj.IsValidate = false; 
                  System.debug('333333333333' + MCN);
                  CCADMcnList.add(MCN);

                }
              }
            }

                                 if(DisputeValidationMap.containsKey('Dispute_ID')){
                                                For(String Dispute_ID : DisputeValidationMap.get('Dispute_ID')){
                                                    if((Integer.valueOf(Dispute_ID) != 0) && String.isNotBlank(Dispute_ID)){
                                                        CCADDisputeList.add(Dispute_ID);
                                                    }
                                                }
                                            }
                                            
                                            if((CCADMcnList != null) && (CCADMcnList.size()>0)){
                                                
                                               validObj.ValidationMsg = 'Invoices exist in CCAD with different MCN :'+CCADMcnList.size();
                                            }
                                            
                                            else if((CCADDisputeList !=null) && (CCADDisputeList.size()>0)){
                                                
                                               validObj.ValidationMsg = 'Invoices entered, already have an open dispute in CCAD :'+CCADDisputeList;
                                            }
                                            
                                            else if((CCADDisputeList != null) && (CCADDisputeList.size() == 0)){
                                                
                                             validObj.ValidationMsg = 'Invoices entered are not yet in CCAD :'+CCADDisputeList;
               								}
            dispLogList.add(sendDisputesToCCAD.genDispIntgLog(req.getBody(), res.getBody(), res.getStatus(), 'SF-CCAD-flow', disputeId));
          }

        }
        else {
            if(String.isNotBlank(disputeId)){
                  
                  validObj.IsValidate = true;
                  validObj.ValidationMsg = disputeId;
            } 
            else{
                validObj.IsValidate = false;
                validObj.ValidationMsg = res.getBody();
            }
          dispLogList.add(sendDisputesToCCAD.genDispIntgLog(req.getBody(), res.getBody(), res.getStatus(), 'SF-CCAD-flow', disputeId));

        }
      }
      else {
        dispLogList.add(sendDisputesToCCAD.genDispIntgLog(req.getBody(), res.getBody(), res.getStatus(), 'SF-CCAD-flow', disputeId));
      }

      
    }

    Catch(Exception e) {
      dispLogList.add(sendDisputesToCCAD.genDispIntgLog(req.getBody(), res.getBody(), FAILURE_STATUS,'SF-CCAD-flow',disputeId));
      //CCADDisputeNo =  e.getMessage();
      validObj.IsValidate = false;
      validObj.ValidationMsg = e.getMessage()+''+res.getBody();

    }
    if (dispLogList.size() > 0) {
        insert dispLogList;
    }  
    return validObj;
  }

  Public Class DisputeDataWrapper {
    @AuraEnabled
    Public String Dispute_ID;
    @AuraEnabled
    Public String Submitter_Name;
    @AuraEnabled
    Public String CustomerContactName;
    @AuraEnabled
    Public String Submitter_Phone_Num;
    @AuraEnabled
    Public String Submitter_Email;
    @AuraEnabled
    Public String DisputeReason;
    @AuraEnabled
    Public decimal DisputedAmount = 0.00;
    @AuraEnabled
    Public String Alternate_Contact_Name;
    @AuraEnabled
    Public String Alternate_Contact_Phone;
    @AuraEnabled
    Public String Alternate_Contact_Email;
    @AuraEnabled
    Public String FollowupQuestion;
    @AuraEnabled
    Public String FollowupAnswer;
    @AuraEnabled
    Public String DisputeDetails;
    @AuraEnabled
    Public String Dispute_Status;
    @AuraEnabled
    Public String ERP_Dispute_Number;
    @AuraEnabled
    Public String Master_Customer_Number;
    @AuraEnabled
    Public String Country;
    @AuraEnabled
    Public String Currency_Code;
    @AuraEnabled
    Public String DisputeAnalystName;
    @AuraEnabled
    Public String DisputeAnalystPhone;
    @AuraEnabled
    Public String DisputeAnalystEmail;
  }

  Private static String generateRequestBodyForDisputeCreation(DisputeDataWrapper DisputeObj, List < PardateTableDataToDisputeInvoice > InvoiceData) {
    DateTime dt = Datetime.now();
    User userObj = new User();
    userObj = [Select id,Quicklook_ID__c from User where Id =:Userinfo.getUserId()];  
    String SoupRequest = '<?xml version=\"1.0\" encoding=\"utf-8\"?>' + '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soup="soup.ncr.com.InvDisputeSvc" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/1.0">' + '<soapenv:Header/>' + '<soapenv:Body>' + '<soup:CreateDisputeRequest xmlns:soup="soup.ncr.com.InvDisputeSvc" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/1.0">' + '<soup:RequestHeader>' + '<ns:TransactionID>' + sendDisputesToCCAD.getUUID() + '</ns:TransactionID>' + '<ns:SourceSystem>NSC</ns:SourceSystem>' + '<ns:Timestamp>' + dt + '</ns:Timestamp>' + '<ns:TargetSystem>CCAD</ns:TargetSystem>' + '</soup:RequestHeader>';

    SoupRequest += '<soup:Dispute_ID>0</soup:Dispute_ID>';
    if (String.IsNotBlank(DisputeObj.Submitter_Name)) SoupRequest += '<soup:Submitter_Name>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Submitter_Name))+ '</soup:Submitter_Name>' + '';
    else SoupRequest += '<soup:Submitter_Name></soup:Submitter_Name>' + '';

    if (String.IsNotBlank(DisputeObj.Submitter_Phone_Num)) SoupRequest += '<soup:Submitter_Phone_Num>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Submitter_Phone_Num)) + '</soup:Submitter_Phone_Num>' + '';
    else SoupRequest += '<soup:Submitter_Phone_Num></soup:Submitter_Phone_Num>';

    if (String.IsNotBlank(DisputeObj.Submitter_Email)) SoupRequest += '<soup:Submitter_Email>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Submitter_Email)) + '</soup:Submitter_Email>' + '';
    else SoupRequest += '<soup:Submitter_Email></soup:Submitter_Email>';

    if (String.IsNotBlank(DisputeObj.DisputeReason)) SoupRequest += '<soup:Reason_Code>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.DisputeReason)) + '</soup:Reason_Code>' + '';
    else SoupRequest += '<soup:Reason_Code></soup:Reason_Code>';

    if (DisputeObj.DisputedAmount > 0) SoupRequest += '<soup:Amount>' + DisputeObj.DisputedAmount + '</soup:Amount>' + '';
    else SoupRequest += '<soup:Amount>0</soup:Amount>';

    if (String.IsNotBlank(DisputeObj.Alternate_Contact_Name)) {
      SoupRequest += '<soup:Alternate_Contact_Name>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Alternate_Contact_Name)) + '</soup:Alternate_Contact_Name>' + '<soup:Alternate_Contact_Phone>' + DisputeObj.Alternate_Contact_Phone + '</soup:Alternate_Contact_Phone>' + '<soup:Alternate_Contact_Email>' + String.valueOf(DisputeObj.Alternate_Contact_Email) + '</soup:Alternate_Contact_Email>';
    }
    else {
      SoupRequest += '<soup:Alternate_Contact_Name></soup:Alternate_Contact_Name>' + '<soup:Alternate_Contact_Phone></soup:Alternate_Contact_Phone>' + '<soup:Alternate_Contact_Email></soup:Alternate_Contact_Email>';

    }

    SoupRequest += '<soup:Dispute_Description>';
    if (String.IsNotBlank(DisputeObj.FollowupQuestion)) SoupRequest += 'Followup Question:  ' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.FollowupQuestion)) + '';
    if (String.IsNotBlank(DisputeObj.FollowupAnswer)) SoupRequest += ' Followup Answer: ' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.FollowupAnswer)) + '';
    if (String.IsNotBlank(DisputeObj.DisputeDetails)) SoupRequest += ' Dispute Details:  ' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.DisputeDetails)) + '';
    SoupRequest += '</soup:Dispute_Description>' +

    '<soup:Dispute_Status>' + Integer.valueOf(DisputeObj.Dispute_Status) + '</soup:Dispute_Status>';
    /*'<soup:Salesforce_Dispute_Id>'+DisputeObj.CaseNumber+'</soup:Salesforce_Dispute_Id>'*/

    /*if(String.IsNotBlank(DisputeObj.Master_Customer_Number))  
            SoupRequest+='<soup:ERP_Dispute_Number>'+DisputeObj.Master_Customer_Number+'</soup:ERP_Dispute_Number>'+'';
            else
            SoupRequest+='<soup:ERP_Dispute_Number></soup:ERP_Dispute_Number>'; */

    if (String.IsNotBlank(DisputeObj.Master_Customer_Number)) SoupRequest += '<soup:Master_Customer_Number>' + DisputeObj.Master_Customer_Number + '</soup:Master_Customer_Number>' + '';
    else SoupRequest += '<soup:Master_Customer_Number></soup:Master_Customer_Number>';

    if (String.IsNotBlank(DisputeObj.Country)) SoupRequest += '<soup:Country>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Country)) + '</soup:Country>' + ''; //country code 
    else SoupRequest += '<soup:Country></soup:Country>'; //country code 

    if (String.IsNotBlank(DisputeObj.Currency_Code)) SoupRequest += '<soup:Currency_Code>' + sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.Currency_Code)) + '</soup:Currency_Code>' + '';
    else SoupRequest += '<soup:Currency_Code></soup:Currency_Code>';
    SoupRequest += '<soup:Invoice_List>';
 
    if (InvoiceData != null && !InvoiceData.isEmpty()) {

      for (PardateTableDataToDisputeInvoice dim: InvoiceData) {
        SoupRequest += '<soup:Invoice>' + '';
        if (String.IsNotBlank(dim.InvoiceNumber)) SoupRequest += '<soup:Invoice_id>' + sendDisputesToCCAD.escapeXML(String.valueOf(dim.InvoiceNumber)) + '</soup:Invoice_id>' + '';
        else SoupRequest += '<soup:Invoice_id></soup:Invoice_id>';
        if ((Decimal.valueOf(dim.TotalInvoiceAmount)) > 0) SoupRequest += '<soup:Invoice_Amount>' + dim.TotalInvoiceAmount + '</soup:Invoice_Amount>' + '';
        else SoupRequest += '<soup:Invoice_Amount></soup:Invoice_Amount>' + '';
        SoupRequest += '</soup:Invoice>';
      }
    }
    SoupRequest += '</soup:Invoice_List>' + '<soup:Created_By>' +String.valueOf(userObj.Quicklook_ID__c)+ '</soup:Created_By>';

    if (String.IsNotBlank(DisputeObj.DisputeAnalystName)) SoupRequest += '<soup:Dispute_Analyst_QuickLook>' +sendDisputesToCCAD.escapeXML(String.valueOf(DisputeObj.DisputeAnalystName)) + '</soup:Dispute_Analyst_QuickLook>';
    else SoupRequest += '<soup:Dispute_Analyst_QuickLook></soup:Dispute_Analyst_QuickLook>' + '';

    SoupRequest += '<soup:Dispute_Close_Reason></soup:Dispute_Close_Reason>' + '';

    SoupRequest += '<soup:Hospitality_Reporting_Code></soup:Hospitality_Reporting_Code>' + '';

    SoupRequest += '<soup:Root_Cause_Code></soup:Root_Cause_Code>' + '';

    SoupRequest += '<soup:Resolution_Notes></soup:Resolution_Notes>' + '';

    SoupRequest += '<soup:Credit_Amount></soup:Credit_Amount>' + '';

    SoupRequest += '<soup:Rebill_Amount></soup:Rebill_Amount>' + '';

    SoupRequest += '<soup:Case_Comments></soup:Case_Comments>' + '<soup:Comment_Public_Flag></soup:Comment_Public_Flag>';

    SoupRequest += '<soup:Source_System>NSC</soup:Source_System>' + '<soup:Updated_By></soup:Updated_By>' + '<soup:Attachment_List>';
    SoupRequest += '</soup:Attachment_List>';

    SoupRequest += '<soup:OrderingSystem></soup:OrderingSystem>' + '';

    SoupRequest += '<soup:IssueDepartment></soup:IssueDepartment>' + '';

    SoupRequest += '<soup:IssuePerson></soup:IssuePerson>' + '';

    SoupRequest += '</soup:CreateDisputeRequest>' + '</soapenv:Body>' + '</soapenv:Envelope>';
    //system.debug('@@@@@@  ' + SoupRequest);
    return SoupRequest;
  }

  public class ValidateDispute {
    @AuraEnabled
    Public Boolean IsValidate = false;
    @AuraEnabled
    Public String ValidationMsg;
  }
}