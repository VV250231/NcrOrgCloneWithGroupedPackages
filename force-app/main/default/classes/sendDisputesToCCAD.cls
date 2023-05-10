/*************************************************************************************************
    * Author        :   Sushant  
    * Date          :   10-06-2020
    * Param         :   caseIds:  List of new Case Ids
    * Return        :   
    * Description   :   This service will Create and Update Disputes in CCAD and Give back the response
                        with CCAD Dispute Id
    *************************************************************************************************/
public class sendDisputesToCCAD {
    
    final static string SUCCESS_STATUS='OK';
    final static string FAILURE_STATUS='FAILURE';
    static Soup_Username__mdt   soup_cred;
    
    public static  void syncCaseToCCAD(list<id> caseIds, Boolean isInsertTrigger){
        Map<Id, List<Dispute_Invoices__c>> disputeInvoiceMap = new Map<Id,List<Dispute_Invoices__c>>();
        Map<Id, List<Other_Attachments__c>> otherAttachmentMap = new Map<Id, List<Other_Attachments__c>>();
        Map<Id, List<ContentDocumentLink>> FilesMap = new Map<Id, List<ContentDocumentLink>>();
        list<Case>caselist=new list<Case>();
        Set<Dispute_Invoices__c> invoicelist = new Set<Dispute_Invoices__c>();
        CaseComment caseCommentdata = new CaseComment();
        list<Other_Attachments__c> caseAttachementList = new list<Other_Attachments__c>();
        Map<String,String> FileIdandTitleMap = new Map<String,String>();
        List<dispute_integration_logs__c> dispLogList = new List<dispute_integration_logs__c>();
        
        /**********  Check ignore profile user ***********/
       /*Id currentUserProfileId = userinfo.getProfileId();        
        List<CCAD_Service_Ignored_Profile__c> ignoreProfileList = CCAD_Service_Ignored_Profile__c.getall().values();
        Boolean isSIP = false;
        for(CCAD_Service_Ignored_Profile__c ignrdProfile : ignoreProfileList) {
            if(ignrdProfile.Profile_Name__c.equalsIgnoreCase(currentUserProfileId)) {
                isSIP = true;
                break;
            }
        }*/
          Id currentUserProfileId = userinfo.getProfileId();        
        All_profie_config__c ignoreProfileList = All_profie_config__c.getValues('CCAD Service Ignored Profile');
        Boolean isSIP = false;
        for(string ignrdProfile : ignoreProfileList.Profile_Id__c.split(',')) {
            if(ignrdProfile.equalsIgnoreCase(currentUserProfileId)) {
                isSIP = true;
                break;
            }
        }
        /**********  Check ignore profile user ***********/
        
        
/******************************************************Get all the Disputes to be sent to CCAD starts**************************************************************************************/
        Map<Id, Case> caseMap = new Map<Id,case>();
        
        for(Case caseObj:[select id,CaseNumber,CCAD_Dispute_Nbr__c,ERP_Dispute_Nbr__c,Dispute_Reason__c,Disputed_Amount__c,Status,Master_Customer_Nbr__c,
                          Country_Code__c,Currency_Code__c,Dispute_Analyst_Name__c,Dispute_Close_Reason__c,Hospitality_Reporting_Code__c,Root_Cause__c,
                          Resolution_Notes__c,Total_Credit_Amount__c,Rebill_Amount__c,Followup_Questions__c,Follow_up_answers__c,Dispute_Details__c,Description,
                          RecordTypeId,Customer_Contact_Phone1__c,Customer_Contact_Email1__c,Contact.name,Alternate_Contact__r.name,Dispute_Analyst_Phone__c,
                          Line_Amount__c,Freight_Amount__c,Tax_Amount__c,Total_Invoice_Balance__c,Ordering_System__c,Issue_Department__c,Issue_Person__c,
                          Alternate_Contact__r.phone,Alternate_Contact__r.email,IsDisputeCreateNotificationSend__c,IsClosed,Dispute_Analyst_Email__c,
                          latestCaseCommentId__c,Dispute_CreatedBy_Qlook__c,Dispute_UpdatedBy_Qlook__c from case  where id IN :caseIds]){
                              caseMap.put(caseObj.id,caseObj);      
                          }
        system.debug('@@@@@@'+caseMap);
        
/*****************************************************Get all the Disputes to be sent to CCAD Ends***************************************************************************************/        
    if(!isSIP) {
/*****************************************************Set Soap Webscervice Credentials Starts***************************************************************************************/        
        
        soup_cred=[select user_name__c,password__c, EndPoint__c from Soup_Username__mdt where DeveloperName='sendDisuptesToCcad'];
        String userID=string.valueof(soup_cred.user_name__c);
        String password=soup_cred.password__c;
        String EndPoint=soup_cred.EndPoint__c;
        system.debug('@@@@@@'+userID+'>>>>>>><<<<<<<'+password+'!!!!!'+EndPoint);
/******************************************************Set Soap Webscervice Credentials Ends*****************************************************************************************************/               
            try {
    /*****************************************************Get all the Invoices related to each Disputes Starts***************************************************************************************/                    
                 
                for(Dispute_Invoices__c di : [select id,Invoice_Number__c,Total_Invoice_Amount__c,Customer_Trx_ID__c,Dispute__r.id from Dispute_Invoices__c 
                                              where Dispute__c=:caseMap.KeySet()]){ // ,
                    if(di !=null){
                        List<Dispute_Invoices__c> disputesInvoicesForKey = disputeInvoiceMap.get(di.Dispute__r.id); 
                            if (disputesInvoicesForKey == null) {
                                disputesInvoicesForKey = new List<Dispute_Invoices__c>();
                                disputeInvoiceMap.put(di.Dispute__r.id,disputesInvoicesForKey);
                            } 
                     disputesInvoicesForKey.add(new Dispute_Invoices__c( Invoice_Number__c= di.Invoice_Number__c, Customer_Trx_ID__c = di.Customer_Trx_ID__c,Total_Invoice_Amount__c = di.Total_Invoice_Amount__c ));   //                           
                  }
              }
                
                system.debug('@@@@@disputeInvoiceMapTesting '+disputeInvoiceMap); 
    /*****************************************************Get all the Invoices related to each Disputes Ends******************************************************************************************/                                
    
    /*****************************************************Get all the Comments related to each Disputes Starts***************************************************************************************/                                //Get All the Comments associated to each Disputes 
                Map<CaseComment, CaseComment> caseCommentMap = new Map<CaseComment, CaseComment>();
                    for(CaseComment ccl:  [select CommentBody, IsPublished,createddate,Parent.latestCaseCommentId__c from CaseComment where ParentId=:caseMap.keySet() 
                                       order by createddate desc limit 1])
                {
                     if(ccl!=null && (ccl.id == ccl.Parent.latestCaseCommentId__c)){
                        caseCommentdata.CommentBody=ccl.CommentBody;
                        caseCommentdata.IsPublished=ccl.IsPublished;
                    }
                }
    /*****************************************************Get all the Comments related to each Disputes Ends***************************************************************************************/                                
    
    /*****************************************************Get All the Attachments associated to each Disputes Starts***************************************************************************************/                               
    
                for(Other_Attachments__c oa:  [select Attachment_Description__c, Attachment_FULL_URL__c,Attachment_Source__c,
                                               Case__c,Case__r.id from Other_Attachments__c where Case__c=:caseMap.keySet()])
                {
                    if(oa !=null){
                    List<Other_Attachments__c> disputesAttachmentsForKey = otherAttachmentMap.get(oa.Case__r.id); 
                            if (disputesAttachmentsForKey == null) {
                                disputesAttachmentsForKey = new List<Other_Attachments__c>();
                                otherAttachmentMap.put(oa.Case__r.id,disputesAttachmentsForKey);
                            } 
                     disputesAttachmentsForKey.add(new Other_Attachments__c( Attachment_Description__c = oa.Attachment_Description__c,Attachment_FULL_URL__c = oa.Attachment_FULL_URL__c,Attachment_Source__c=oa.Attachment_Source__c ));                             
                    }
                }
                
                
    /*****************************************************Get All the Attachments associated to each Disputes Ends***************************************************************************************/                    
    
    /*****************************************************Get All the Files associated to each Disputes Starts***************************************************************************************/                               
    
                for(ContentDocumentLink  fls:  [SELECT ContentDocumentId,ContentDocument.Title, LinkedEntityId  FROM ContentDocumentLink where
                                                LinkedEntityId in ( SELECT Id FROM Case where id=:caseMap.keySet()) and LinkedEntity.Type='Case'])
                {
                    if(fls !=null){
                         FileIdandTitleMap.put(fls.ContentDocumentId,fls.ContentDocument.Title);
                         List<ContentDocumentLink> filesForKey = FilesMap.get(fls.LinkedEntityId); 
                            if (filesForKey == null) {
                                filesForKey = new List<ContentDocumentLink>();
                                FilesMap.put(fls.LinkedEntityId,filesForKey);
                            } 
                        filesForKey.add(new ContentDocumentLink ( ContentDocumentId = fls.ContentDocumentId));                             
                    }
                }
                
    /*****************************************************Get All the Files associated to each Disputes Ends***************************************************************************************/   
                //Change by Saurav(EBA_SF-1349)
                 Map<string ,Decimal> cStatusCode = new Map<string ,Decimal>();
                for(SetDisputeStatusCode__c caseDetails : [Select caseStatusCode__c,caseStatus__c from SetDisputeStatusCode__c]){
                    cStatusCode.put(caseDetails.caseStatus__c,caseDetails.caseStatusCode__c);               
                  }
                
                for(Case caseDetails : caseMap.Values()){
                    if(caseDetails.caseNumber!=null) {
                        //Change by Saurav(EBA_SF-1349)
                       string csc = string.valueOf(cStatusCode.get(caseDetails.Status));                        
                        //SetDisputeStatusCode__c csc=[Select caseStatusCode__c from SetDisputeStatusCode__c where caseStatus__c=:caseDetails.Status];
                        system.debug('@@csc: '+csc);                    
                        HttpRequest req;
                        HttpResponse res;
                        
                        try {                                   
                            //Authorize Soap Web Service
                            req=new HttpRequest();
                            res= new HttpResponse() ;
                            Blob headerValue = Blob.valueOf(userID + ':' + password);
                            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
                            Http h = new Http();
                            //Generate Request Body for Disputes Creation in CCAD    
                             List<Dispute_Invoices__c> disputeInvoices = new List<Dispute_Invoices__c>();
                             List<Other_Attachments__c> otherAttachments = new List<Other_Attachments__c>();
                             List<ContentDocumentLink> attachmentFiles = new List<ContentDocumentLink>();
                            
                            if(disputeInvoiceMap !=null){
                              disputeInvoices = disputeInvoiceMap.get(caseDetails.id);
                            }
                            if(otherAttachmentMap !=null){
                              otherAttachments = otherAttachmentMap.get(caseDetails.id);
                            }
                            if(FilesMap !=null){
                              attachmentFiles = FilesMap.get(caseDetails.id);
                            }
                           
                            if (!isInsertTrigger && disputeInvoiceMap !=null && disputeInvoiceMap.keyset().size() > 0) {
                                String DisputeCreationBody=generateRequestBodyForDisputeCreation(caseDetails,disputeInvoices,caseCommentdata,otherAttachments,attachmentFiles,csc,FileIdandTitleMap);          
                                 //system.debug('@@@@@disputeInvoiceMapTest '+disputeInvoiceMap.get(caseDetails.id)); 
                                system.debug('DisputeCreationBody@@@@' + DisputeCreationBody);  
                                req.setBody(DisputeCreationBody);
                                //Hit the Soup Webservice after Authorization and check for the response  
                                req.setMethod('POST');
                                req.setHeader('Authorization', authorizationHeader);
                                req.setHeader('Accept', 'application/xml');
                                req.setHeader('Content-Type', 'application/xml');
                                req.setEndpoint(EndPoint);
                                system.debug('req>> '+req.getBody());             
                               
                                res = h.send(req);
                                system.debug('<><><><><'+res.getBody());
                                
                                dispute_integration_logs__c dil= new dispute_integration_logs__c();
                                dil.Request__c=req.getBody();
                                dil.Response__c=res.getBody();
                                dil.Status__c=res.getStatus();
                                dil.RequestType__c='SF-CCAD';
                                dil.caseNumber__c=caseDetails.CaseNumber;
                                //dispLogList.add(dil);
                                //if(dil!=null)  insert dil;
                                
                                Dom.Document doc = res.getBodyDocument();                            
                                Dom.XMLNode rootElement = doc.getRootElement();
                                
                                Dom.XmlNode body = rootElement.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
                                System.debug('Body is: ---------------->>>'+body);
                                
                                Dom.XmlNode createDisputeNode = body.getChildElement('CreateDisputeResponse','soup.ncr.com.InvDisputeSvc');
                                System.debug('createDisputeNode is: ---------------->>>'+createDisputeNode);
                                
                                String disputeId = createDisputeNode.getChildElement('Dispute_ID', 'soup.ncr.com.InvDisputeSvc').getText();
                                // print out specific elements
                                System.debug('disputeId: ' + disputeId);
                                System.debug('responseStatus: ' + res.getStatus());
                                
                                if(res.getStatus()==SUCCESS_STATUS) {
                                    system.debug('@@@@@ POST method successfully executed');
                                    updateDisputeNumberInSFAndSendCaseCreationEmail(caseDetails,disputeId, true);
                                } 
                                dispLogList.add(genDispIntgLog(req.getBody(), res.getBody(), res.getStatus(),'SF-CCAD', caseDetails.CaseNumber));    
                                                        
                            }
                        } catch(Exception e) {
                            dispLogList.add(genDispIntgLog(req.getBody(), e.getMessage(), FAILURE_STATUS,'SF-CCAD', caseDetails.CaseNumber));
                        }
                        
                  }
                } // case for loop ends here 
            } catch(Exception ex){
                system.debug('Error occured in POST method: '+ex.getMessage());
                
                if(!caseMap.isEmpty()) {
                    for(Case caseDtl : caseMap.Values()){
                        if(caseDtl.caseNumber!=null){
                            dispLogList.add(genDispIntgLog(NULL, ex.getMessage(), FAILURE_STATUS,'SF-CCAD', caseDtl.caseNumber));
                        }
                    } 
                }
            }
            
            if(dispLogList != null) {
                insert dispLogList;  
            }
        } //else { 
            // send emails for dispute creation from MYNCR/CCAD
            // if update trigger a
            
            /*for(Case caseDetail : caseMap.Values()) {
                if(isInsertTrigger || (!isInsertTrigger && !caseDetail.IsDisputeCreateNotificationSend__c)) {
                    updateDisputeNumberInSFAndSendCaseCreationEmail(caseDetail, caseDetail.CCAD_Dispute_Nbr__c, false); 
                }
            } */
            
        //}
    }
    
    private static String generateRequestBodyForDisputeCreation(Case caselist, List<Dispute_Invoices__c> disputeInvoiceList,  CaseComment caseCommentdata, List<Other_Attachments__c> caseAttachementList, List<ContentDocumentLink> fileList, string csc, Map<String,String> FileIdandTitleMap ){
        DateTime dt = Datetime.now();
        system.debug('@@@@@caselist '+caselist);   
        system.debug('@@@@@disputeInvoiceList '+disputeInvoiceList);   
        system.debug('@@@@@caseCommentdata '+caseCommentdata);  
        system.debug('@@@@@caseAttachementList '+caseAttachementList);  
        system.debug('@@@@@fileList '+fileList);
        system.debug('@@@@@csc '+csc);
        
        String SoupRequest='<?xml version=\"1.0\" encoding=\"utf-8\"?>'+
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:soup="soup.ncr.com.InvDisputeSvc" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/1.0">'+
        '<soapenv:Header/>'+
        '<soapenv:Body>'+
            '<soup:CreateDisputeRequest xmlns:soup="soup.ncr.com.InvDisputeSvc" xmlns:ns="http://xmlns.ncr.com/SOUP/Common/1.0">'+
            '<soup:RequestHeader>'+
            '<ns:TransactionID>'+getUUID()+'</ns:TransactionID>'+
            '<ns:SourceSystem>NSC</ns:SourceSystem>'+
            '<ns:Timestamp>'+dt+'</ns:Timestamp>'+
            '<ns:TargetSystem>CCAD</ns:TargetSystem>'+
            '</soup:RequestHeader>';
            if(String.IsNotBlank(caselist.CCAD_Dispute_Nbr__c))                                               
            SoupRequest+='<soup:Dispute_ID>'+caselist.CCAD_Dispute_Nbr__c+'</soup:Dispute_ID>'+'';
            else                                                
            SoupRequest+='<soup:Dispute_ID>0</soup:Dispute_ID>';
            if(String.IsNotBlank(caselist.Contact.name))                                               
            SoupRequest+='<soup:Submitter_Name>'+escapeXML(String.valueOf(caselist.Contact.name))+'</soup:Submitter_Name>'+'';
            else
            SoupRequest+='<soup:Submitter_Name></soup:Submitter_Name>'+'';
            if(String.IsNotBlank(caselist.Customer_Contact_Phone1__c))                                               
             SoupRequest+='<soup:Submitter_Phone_Num>'+escapeXML(String.valueOf(caselist.Customer_Contact_Phone1__c))+'</soup:Submitter_Phone_Num>'+'';
        else
            SoupRequest+='<soup:Submitter_Phone_Num></soup:Submitter_Phone_Num>';
        if(String.IsNotBlank(caselist.Customer_Contact_Email1__c))  
             SoupRequest+='<soup:Submitter_Email>'+escapeXML(String.valueOf(caselist.Customer_Contact_Email1__c))+'</soup:Submitter_Email>'+'';
        else
            SoupRequest+='<soup:Submitter_Email></soup:Submitter_Email>';
        
         if(String.IsNotBlank(caselist.Dispute_Reason__c))  
            SoupRequest+='<soup:Reason_Code>'+escapeXML(String.valueOf(caselist.Dispute_Reason__c))+'</soup:Reason_Code>'+'';
        else
            SoupRequest+='<soup:Reason_Code></soup:Reason_Code>';
        if((caselist.Disputed_Amount__c) >0)  
            SoupRequest+='<soup:Amount>'+caselist.Disputed_Amount__c+'</soup:Amount>'+'';
        else
            SoupRequest+='<soup:Amount>0</soup:Amount>';
        if(String.IsNotBlank(caselist.Alternate_Contact__r.name)){  
            SoupRequest+='<soup:Alternate_Contact_Name>'+escapeXML(String.valueOf(caselist.Alternate_Contact__r.name))+'</soup:Alternate_Contact_Name>'+
            '<soup:Alternate_Contact_Phone>'+caselist.Alternate_Contact__r.phone+'</soup:Alternate_Contact_Phone>'+
            '<soup:Alternate_Contact_Email>'+escapeXML(String.valueOf(caselist.Alternate_Contact__r.email))+'</soup:Alternate_Contact_Email>';
         }
        else
        {
            SoupRequest+='<soup:Alternate_Contact_Name></soup:Alternate_Contact_Name>'+
            '<soup:Alternate_Contact_Phone></soup:Alternate_Contact_Phone>'+
            '<soup:Alternate_Contact_Email></soup:Alternate_Contact_Email>';
      
        }
      
           SoupRequest+='<soup:Dispute_Description>';
            if(String.IsNotBlank(caselist.Followup_Questions__c))
                SoupRequest+='Followup Question:  '+escapeXML(String.valueOf(caselist.Followup_Questions__c))+'';
                if(String.IsNotBlank(caselist.Follow_up_answers__c))
                SoupRequest+=' Followup Answer: '+escapeXML(String.valueOf(caselist.Follow_up_answers__c))+'';  
                if(String.IsNotBlank(caselist.Dispute_Details__c))  
                SoupRequest+=' Dispute Details:  '+escapeXML(String.valueOf(caselist.Dispute_Details__c))+'';
            SoupRequest+='</soup:Dispute_Description>'+  
                
            '<soup:Dispute_Status>'+Integer.valueOf(csc)+'</soup:Dispute_Status>'+
            '<soup:Salesforce_Dispute_Id>'+caselist.CaseNumber+'</soup:Salesforce_Dispute_Id>';
             if(String.IsNotBlank(caselist.ERP_Dispute_Nbr__c))  
                SoupRequest+='<soup:ERP_Dispute_Number>'+caselist.ERP_Dispute_Nbr__c+'</soup:ERP_Dispute_Number>'+'';
            else
               SoupRequest+='<soup:ERP_Dispute_Number></soup:ERP_Dispute_Number>'; 
            if(String.IsNotBlank(caselist.Master_Customer_Nbr__c))  
                SoupRequest+='<soup:Master_Customer_Number>'+caselist.Master_Customer_Nbr__c+'</soup:Master_Customer_Number>'+'';
            else
               SoupRequest+='<soup:Master_Customer_Number></soup:Master_Customer_Number>';
            
            if(String.IsNotBlank(caselist.Country_Code__c))  
                SoupRequest+='<soup:Country>'+escapeXML(String.valueOf(caselist.Country_Code__c))+'</soup:Country>'+''; //country code 
                else
                 SoupRequest+='<soup:Country></soup:Country>'; //country code 
            
            if(String.IsNotBlank(caselist.Currency_Code__c))  
                SoupRequest+='<soup:Currency_Code>'+escapeXML(String.valueOf(caselist.Currency_Code__c))+'</soup:Currency_Code>'+'';
            else
                SoupRequest+='<soup:Currency_Code></soup:Currency_Code>'; 
            SoupRequest+='<soup:Invoice_List>';
             
                if(disputeInvoiceList!=null && !disputeInvoiceList.isEmpty()){
                    for(Dispute_Invoices__c dim: disputeInvoiceList){
                      SoupRequest+='<soup:Invoice>'+'';
                      if(String.IsNotBlank(dim.Invoice_Number__c))  
                            SoupRequest+='<soup:Invoice_id>'+escapeXML(String.valueOf(dim.Invoice_Number__c))+'</soup:Invoice_id>'+'';
                            else
                             SoupRequest+='<soup:Invoice_id></soup:Invoice_id>';
                      if((dim.Total_Invoice_Amount__c) > 0)  
                            SoupRequest+='<soup:Invoice_Amount>'+dim.Total_Invoice_Amount__c+'</soup:Invoice_Amount>'+'';
                            else
                             SoupRequest+='<soup:Invoice_Amount></soup:Invoice_Amount>'+'';    
                      SoupRequest+='</soup:Invoice>';
                   }
                }
            SoupRequest+='</soup:Invoice_List>'+
            '<soup:Created_By>'+caselist.Dispute_CreatedBy_Qlook__c+'</soup:Created_By>';
         if(String.IsNotBlank(caselist.Dispute_Analyst_Name__c))  
            SoupRequest+='<soup:Dispute_Analyst_QuickLook>'+escapeXML(String.valueOf(caselist.Dispute_Analyst_Name__c))+'</soup:Dispute_Analyst_QuickLook>'; 
        else
             SoupRequest+='<soup:Dispute_Analyst_QuickLook></soup:Dispute_Analyst_QuickLook>'+'';
             if(String.IsNotBlank(caselist.Dispute_Close_Reason__c))  
                SoupRequest+='<soup:Dispute_Close_Reason>'+escapeXML(String.valueOf(caselist.Dispute_Close_Reason__c))+'</soup:Dispute_Close_Reason>'+'';
             else
             SoupRequest+='<soup:Dispute_Close_Reason></soup:Dispute_Close_Reason>'+'';
            
            if(String.IsNotBlank(caselist.Hospitality_Reporting_Code__c))  
                SoupRequest+='<soup:Hospitality_Reporting_Code>'+caselist.Hospitality_Reporting_Code__c+'</soup:Hospitality_Reporting_Code>'+'';
            else
             SoupRequest+='<soup:Hospitality_Reporting_Code></soup:Hospitality_Reporting_Code>'+'';
            
        if(String.IsNotBlank(caselist.Root_Cause__c))  
                SoupRequest+='<soup:Root_Cause_Code>'+caselist.Root_Cause__c+'</soup:Root_Cause_Code>'+'';
        else
             SoupRequest+='<soup:Root_Cause_Code></soup:Root_Cause_Code>'+'';
        
        if(String.IsNotBlank(caselist.Resolution_Notes__c))  
                SoupRequest+='<soup:Resolution_Notes>'+escapeXML(String.valueOf(caselist.Resolution_Notes__c))+'</soup:Resolution_Notes>'+'';
        else
            SoupRequest+='<soup:Resolution_Notes></soup:Resolution_Notes>'+'';
        
     if((caselist.Total_Credit_Amount__c) > 0)  
            SoupRequest+='<soup:Credit_Amount>'+caselist.Total_Credit_Amount__c+'</soup:Credit_Amount>'+'';
        else
           SoupRequest+='<soup:Credit_Amount></soup:Credit_Amount>'+''; 
        
        if((caselist.Rebill_Amount__c) > 0)  
            SoupRequest+='<soup:Rebill_Amount>'+caselist.Rebill_Amount__c+'</soup:Rebill_Amount>'+'';
        else
           SoupRequest+='<soup:Rebill_Amount></soup:Rebill_Amount>'+'';  
             
            if(!String.isBlank(caseCommentdata.CommentBody)){
               SoupRequest+= '<soup:Case_Comments>'+escapeXML(String.valueOf(caseCommentdata.CommentBody))+'</soup:Case_Comments>'+
                '<soup:Comment_Public_Flag>'+caseCommentdata.IsPublished+'</soup:Comment_Public_Flag>';
             }
        else
        {
            SoupRequest+='<soup:Case_Comments></soup:Case_Comments>'+
            '<soup:Comment_Public_Flag></soup:Comment_Public_Flag>';
        }
            
            SoupRequest+='<soup:Source_System>NSC</soup:Source_System>'+
            '<soup:Updated_By>'+caselist.Dispute_UpdatedBy_Qlook__c+'</soup:Updated_By>'+    
            '<soup:Attachment_List>';
        
        if(caseAttachementList!=null && !caseAttachementList.isEmpty()){ 
            for(Other_Attachments__c oa: caseAttachementList){
                SoupRequest+='<soup:Attachment>'+
                    '<soup:Attachment_Source>'+oa.Attachment_Source__c+'</soup:Attachment_Source>'+
                    '<soup:Attachment_Description>'+escapeXML(oa.Attachment_Description__c)+'</soup:Attachment_Description>';
                if(String.IsNotBlank(oa.Attachment_FULL_URL__c))  
                    //SoupRequest+='<soup:Attachment_FULL_URL>'+EncodingUtil.urlEncode(oa.Attachment_FULL_URL__c, 'UTF-8')+'</soup:Attachment_FULL_URL>'+'';
                    SoupRequest+='<soup:Attachment_FULL_URL>'+escapeXML(oa.Attachment_FULL_URL__c)+'</soup:Attachment_FULL_URL>'+'';
                else
                    SoupRequest+='<soup:Attachment_FULL_URL></soup:Attachment_FULL_URL>'+'';
                SoupRequest+='</soup:Attachment>'; 
            }  
        }     
            if(fileList!=null && !fileList.isEmpty()){ 
                for(ContentDocumentLink cdl: fileList){
                    SoupRequest+='<soup:Attachment>'+
                        '<soup:Attachment_Source>NSC</soup:Attachment_Source>'+
                        '<soup:Attachment_Description>'+escapeXML(FileIdandTitleMap.get(cdl.ContentDocumentId))+'</soup:Attachment_Description>';
                if(String.IsNotBlank(cdl.ContentDocumentId))  
                SoupRequest+='<soup:Attachment_FULL_URL>'+System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cdl.ContentDocumentId+'</soup:Attachment_FULL_URL>'+'';
                else
                   SoupRequest+='<soup:Attachment_FULL_URL></soup:Attachment_FULL_URL>'+'';
                   SoupRequest+='</soup:Attachment>'; 
                   }
                }
        SoupRequest+='</soup:Attachment_List>';
        if(String.IsNotBlank(caselist.Ordering_System__c))  
                 SoupRequest+='<soup:OrderingSystem>'+caselist.Ordering_System__c+'</soup:OrderingSystem>'+'';
            else
              SoupRequest+='<soup:OrderingSystem></soup:OrderingSystem>'+'';
             
         if(String.IsNotBlank(caselist.Issue_Department__c))  
                SoupRequest+='<soup:IssueDepartment>'+caselist.Issue_Department__c+'</soup:IssueDepartment>'+'';
            else
                SoupRequest+='<soup:IssueDepartment></soup:IssueDepartment>'+'';
             
         if(String.IsNotBlank(caselist.Issue_Person__c))  
                SoupRequest+='<soup:IssuePerson>'+escapeXML(caselist.Issue_Person__c)+'</soup:IssuePerson>'+'';
            else
             SoupRequest+='<soup:IssuePerson></soup:IssuePerson>'+'';

         SoupRequest+='</soup:CreateDisputeRequest>'+            
        '</soapenv:Body>'+
        '</soapenv:Envelope>'; 
        
        return SoupRequest; 
        }

   
    @future(callout=true)
    public static void syncCaseToCCAD_With_Future(list<id> caseIds, Boolean IsTriggerInsertrun) {
        syncCaseToCCAD(caseIds, IsTriggerInsertrun);
    }

    public static void syncCaseToCCAD_Without_Future(list<id> caseIds, Boolean IsTriggerInsertrun) {
        syncCaseToCCAD(caseIds, IsTriggerInsertrun);
    }
       
    public static void updateDisputeNumberInSFAndSendCaseCreationEmail(Case caseDetail, String DisputeId, Boolean isUpdateCCADNumber)
    {
        sendDisputesToCCAD.runOnce();
        if (isUpdateCCADNumber) {
            case updateCcadDiputeNumber= new case();
            //updateCcadDiputeNumber.CCAD_Dispute_Nbr__c=disputeId;
            updateCcadDiputeNumber.id=caseDetail.Id;
            updateCcadDiputeNumber.latestCaseCommentId__c='';
            if(updateCcadDiputeNumber!=null)
                update updateCcadDiputeNumber;
        }
        
       
        //New Changes
        List<Case> CaseIdSet = new List<Case>();
        List<Case> CaseListToUpdate = new List<Case>();
        
   		CCAD_Config__mdt ccadCnfg = [SELECT Id,Send_CCAD_emails__c FROM CCAD_Config__mdt WHERE QualifiedApiName = 'Org_Config' LIMIT 1];
       
        if(!caseDetail.IsDisputeCreateNotificationSend__c && ccadCnfg.Send_CCAD_emails__c){
            if(caseDetail.RecordTypeId==Schema.SObjectType.Case.getRecordTypeInfosByName().get('Dispute').getRecordTypeId()
               && caseDetail.IsClosed == false 
               && String.isNotBlank(caseDetail.Customer_Contact_Email1__c)  && String.isNotBlank(caseDetail.Dispute_Analyst_Email__c)
               && caseDetail.Dispute_Analyst_Name__c != NULL && !caseDetail.Dispute_Analyst_Name__c.equalsIgnoreCase('ASSIGNED TO QUEUE')){
                   CaseIdSet.add(caseDetail);
                  system.debug('@@@@@CaseIdSet1 '+CaseIdSet); 
                   Case CaseObjToUpdate = new Case();
                   CaseObjToUpdate.Id =caseDetail.id;
                   CaseObjToUpdate.IsDisputeCreateNotificationSend__c = true;
                   CaseListToUpdate.add(CaseObjToUpdate);
                   
               }
        }
        system.debug('@@@@@CaseIdSet2 '+CaseIdSet); 
        system.debug('@@@@@CaseIdSet3 '+CaseIdSet.size()); 
        if(CaseIdSet != null && CaseIdSet.size()>0){
             system.debug('@@@@@sks '+CaseIdSet.size());   
            CCAD_disputeEmailNotifications.DisputeCreate_Notifications(CaseIdSet);
            if(CaseListToUpdate != null && CaseListToUpdate.size() >0){
                
                update CaseListToUpdate;
            }
        }
        //new changes end
        
    }
    
   
    
     public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    private static boolean run = true;
    public static boolean runOnce(){
    if(run){
     run=false;
     return true;
    }
    else{
    return run;
     }
 }
    
  public static String escapeXML(String data){ 
        String ParsedForm='';
      if(String.isNotBlank(data)){
        ParsedForm=data.replaceALL('&','&amp;');
        ParsedForm=ParsedForm.replaceALL('>','&gt;');
        ParsedForm=ParsedForm.replaceALL('<','&lt;');
        ParsedForm=ParsedForm.replaceALL('"','&quot;');
        ParsedForm=ParsedForm.replaceALL('\'','&apos;');
      }
       
        
        return ParsedForm;
    }
    
    public static dispute_integration_logs__c genDispIntgLog(String reqMsg, String respMsg, String status, String requestType, String caseNumber) {
        Dispute_integration_logs__c dil= new Dispute_integration_logs__c();
        dil.Request__c=reqMsg;
        dil.Response__c=respMsg;
        dil.Status__c=status;
        dil.RequestType__c=requestType;
        dil.caseNumber__c=caseNumber;   
        return dil;
    }
 
}