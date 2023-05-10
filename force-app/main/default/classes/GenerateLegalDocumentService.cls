/**************************************
Author ...............: Suraj Parihar
Modified Date.........: 11-NOV-2021
Last Modified By......: Pankaj Pandey
Description...........: SFCPQBLG-250,SFCPQBLG-224,SFCPQBLG-519,SFCPQBLG-1216 

***************************************/
public class GenerateLegalDocumentService {
   
    @auraEnabled
    public static SBQQ__Quote__c validateCreditApplicationStatus(Id qid){
        //List<SBQQ__QuoteLine__c> qlines = [Select id from SBQQ__QuoteLine__c where Revenue_Type__c = 'Payments Processing' and Product_Type__c = 'Sub-Package' and SBQQ__RequiredBy__c = null and SBQQ__Quote__c=:qid and SBQQ__quote__r.qtc_Multi_Site__c=false]; 
        List<SBQQ__QuoteLine__c> qlines = [Select id,SBQQ__quote__r.qtc_Multi_Site__c,SBQQ__quote__r.qtc_Multi_Site_Type__c from SBQQ__QuoteLine__c where Revenue_Type__c = 'Payments Processing' and Product_Type__c = 'Sub-Package' and SBQQ__RequiredBy__c = null and SBQQ__Quote__c=:qid ];
        
        if (qlines.size() == 0 || (qlines.get(0).SBQQ__quote__r.qtc_Multi_Site__c == true && qlines.get(0).SBQQ__quote__r.qtc_Multi_Site_Type__c != 'PP Only')) { 
            return [Select id,Name,DocuSign_Folder__c,ACH_Recipient__c,CreatedDate, SBQQ__Account__c,SBQQ__PrimaryContact__c,qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.AutoPay_Setup__c,SBQQ__Account__r.Credit_Application_Status__c,SBQQ__Type__c, SBQQ__Primary__c, qtc_Customer_Type__c, qtc_New_Aloha_Key_Number__c, qtc_Existing_Aloha_Key_Number__c, qtc_Existing_Hosted_Enterprise_ID__c, SBQQ__Account__r.Parent.Customer_Number__c, qtc_Multi_Site__c,qtc_Multi_Site_Relationship__c,qtc_Order_Form_Notes__c, qtc_Channel_Local_Office_Record_Type__c,ACH_Recipient__r.Email,SBQQ__Account__r.MDM_Enterprise_Nbr__c,SBQQ__Account__r.MDM_Customer_Entity_Nbr__c,SBQQ__Account__r.Master_Customer_Number__c,qtc_Offering__c  from SBQQ__Quote__c where id =:qid]; 
            
        } 
        else{ 
            return null;// New behavior when using Safe Navigation. Earlier, this would throw an exception. 
        }
    }
    
    @future (callout=true)
    public static void newUser(Id qid){
        String trId;
        HttpRequest req;
        HttpResponse res;
        String ErrorMsg;
        String sts;
        SBQQ__Quote__c q = [Select id,ACH_Recipient__r.firstname,qtc_Legal_Document_Status__c,ACH_Recipient__r.lastname,ACH_Recipient__r.Email,SBQQ__PrimaryContact__r.firstname,SBQQ__PrimaryContact__r.lastname,SBQQ__PrimaryContact__r.email,SBQQ__Account__r.Master_Customer_number__C,qtc_Bill_To_Site__r.Site_Number__c,Name,
                            qtc_Multi_Site_Type__c,qtc_Multi_Site_Relationship__c,qtc_Multi_Site_Parent_Quote__c,qtc_Bill_To_Site__r.AutoPay_Setup__c,SBQQ__SalesRep__r.Email,(select id,qtc_Legal_Document_Status__c, qtc_Bill_To_Site__r.Site_Number__c,SBQQ__Primary__c,SBQQ__Status__c,qtc_Bill_To_Site__r.AutoPay_Setup__c from MS_Child_Quotes__r) from SBQQ__Quote__c where id =:qid]; 
        try{
            GenerateLegalDocumentService reqBody = new GenerateLegalDocumentService();
            GenerateLegalDocumentService.UserRequestABM reqObj = new GenerateLegalDocumentService.UserRequestABM();
            GenerateLegalDocumentService.RequestHeader hdrReq = new GenerateLegalDocumentService.RequestHeader(); 
            trId = new Uuid().getValue();
            hdrReq.TransactionID = trId; 
            hdrReq.SourceSystem='NSC';
            hdrReq.Timestamp=String.valueOf(DateTime.now());
            hdrReq.TransactionType= 'Create';
            hdrReq.TargetSystem='MyNCR';
            
            reqObj.RequestHeader=hdrReq; 
            GenerateLegalDocumentService.UserRequest usr= new GenerateLegalDocumentService.UserRequest();
            // Incase of multi site if child quote do not have ACH contact then use Parent's ACH contach to send MY NCR
            if(q.qtc_Multi_Site_Relationship__c=='Child' && q.ACH_Recipient__c == null){
                SBQQ__Quote__c qParent= [Select id,ACH_Recipient__r.firstname,ACH_Recipient__r.lastname,ACH_Recipient__r.Email,SBQQ__PrimaryContact__r.firstname,SBQQ__PrimaryContact__r.lastname,SBQQ__PrimaryContact__r.email from SBQQ__Quote__c where id =:q.qtc_Multi_Site_Parent_Quote__c];
                usr.FirstName=  qParent.ACH_Recipient__r.firstname;
                usr.LastName = qParent.ACH_Recipient__r.lastname;
                usr.Email=qParent.ACH_Recipient__r.email;
            } else {
                usr.FirstName=  q.ACH_Recipient__r.firstname;
                usr.LastName = q.ACH_Recipient__r.lastname;
                usr.Email=q.ACH_Recipient__r.email;
            }
            usr.MCN = q.SBQQ__Account__r.Master_Customer_number__C;
            //Add below billTosite by Dharmendra 18-Jun-2021
            Set<String> billToSites = new Set<String>();
            billToSites.add(q.qtc_Bill_To_Site__r.Site_Number__c);
            // Incase of multi site quote childs/parent should be Primary and Approved.
            // Not cheking parent for Primary and Approved status becuase parent have generate buttons 
            // which only possible after approve status and primary flag true
            for(SBQQ__Quote__c msQuote : q.MS_Child_Quotes__r) {
                if(msQuote.SBQQ__Primary__c && msQuote.SBQQ__Status__c=='Approved' && msQuote.qtc_Legal_Document_Status__c!='Completed'){
                    billToSites.add(msQuote.qtc_Bill_To_Site__r.Site_Number__c);
                }
            }
            
            //SFCPQBLG-853 - ACH is blank and bill to site auto pay true/manual then skip ACH validation at myncr is required
            if(q.ACH_Recipient__c == null && (q.qtc_Bill_To_Site__r.AutoPay_Setup__c =='Manual' || q.qtc_Bill_To_Site__r.AutoPay_Setup__c =='True')){
                usr.SkipACHValidation = true;
            }
            
            usr.BillToSites = billToSites;
            reqObj.UserRequest = usr;
            reqBody.UserRequestABM = reqObj;
            Http http = new Http();
            req = new HttpRequest();
            req.setEndpoint('callout:Soup_Autopay');
            
            req.setMethod('POST');
            req.setTimeout(12000); 
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            
            req.setBody(JSON.serialize(reqBody));
            //System.debug('req>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+reqBody);
            res = http.send(req);
            System.debug('status'+res.getStatusCode());
            System.debug('res'+res.getBody());
            
            if(res.getStatusCode()==404 || res.getStatusCode()==500){
                if(res.getStatus()=='Not Found'){
                    ErrorMsg = 'some problem at SOUP end.';
                }else{
                    ErrorMsg = 'some problem at SOUP Or MyNCR end. ' + res+'.';
                }
                sts ='FAILURE';
            }
            else if(String.isEmpty(res.getBody())){
                ErrorMsg = res+'.';
                sts ='FAILURE';
            }
            else{
                JSONParser prs = JSON.createParser(res.getBody());           
                while (prs.nextToken() != null) {
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Status')) {
                        prs.nextToken();
                        sts = prs.getText();
                    }
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Message')) {
                        prs.nextToken();
                        ErrorMsg  = prs.getText();
                    }
                    
                }
                
            }
            createLogs(q,sts,ErrorMsg,trId,req,res);
        }
        catch(Exception ex){
            ErrorMsg = ex.getMessage()+'.';
            sts ='FAILURE';
            createLogs(q,sts,ErrorMsg,trId,req,res);
        }
    }
    
    
    public UserRequestABM UserRequestABM;
    public class RequestHeader {
        public String TransactionID;
        public String SourceSystem;
        public String TransactionType;
        public String Timestamp;
        public String TargetSystem;
    }
    
    public class UserRequestABM {
        public RequestHeader RequestHeader;
        public UserRequest UserRequest;
    }
    
    public class UserRequest {
        public String FirstName;
        public String LastName;
        public String Email;
        public String MCN;
        //public String BillToSite;
        public Set<String> BillToSites = new Set<String>();
        
        public String IsAasUser ='yes';
        public String Locale = 'en_US';
        public String UserRole = 'Customer Admin';
        
        public Boolean ResendEmail = false;
        public Set<String> DeactivateBillSite = new Set<String>();
        public Boolean SkipACHValidation = false;
        
    }
    
    
    //Method created for generateCreditApplicationButton by Stuti
    @auraEnabled
    public static Opportunity validateGenerateCreditApplication(Id oid){
        return [Select id,CPQ__c, Name,CreatedDate, Account.Name, Account.Master_Customer_Number__c from Opportunity where id =:oid]; 
        
    }
    
    public static void createLogs(SBQQ__Quote__c q,String sts, String ErrorMsg,String trId,HttpRequest req, HttpResponse res){
        MY_NCR_user_log__c obj = new MY_NCR_user_log__c();
        obj.Contact__c = q.ACH_Recipient__c;
        obj.Quote__c = q.ID;
        obj.Account_MCN__c = q.SBQQ__Account__r.Master_Customer_number__C;
        obj.Site_Address_Number__c = q.qtc_Bill_To_Site__r.Site_Number__c;
        if(req!=null){
            obj.Request__c = String.valueOf(req.getBody());
        }else{
            obj.Request__c = String.valueOf(req);
        }
        obj.Response__c = String.valueOf(res);
        obj.RequestType__c = 'Outbound';
        obj.Error_message__c = ErrorMsg;
        obj.Status__c = sts;
        obj.TransactionID__c = trId;
        obj.Sales_Rep_Email__c = q.SBQQ__SalesRep__r.Email;
        try{
            insert obj; 
        }catch(Exception e){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.donotreply@ncr.com'];
            string body= String.format(System.Label.MyNCREmailBodyExc, new List<String>{e.getMessage(),String.valueof(e.getLineNumber()),URL.getSalesforceBaseUrl().toExternalForm()+'/'+q.id,q.Name});
            EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String eBody=template.HtmlValue;
            eBody = eBody.replace('#Body', body).replace('#Header', 'Logging Failed').replace('#HeadLine', 'MyNCR User Logs - Logging Failed');
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String sub= 'Logging Failed - MyNCR User Logs';
            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'GLDC Log Failed', Subject__c =sub , title__c=sub, html_body__c=eBody);
            List<String> sndTo = new List<String>();
            sndTo.addAll(System.Label.BatchJobEmailNotificationList.split(','));
            if(sndTo.size()>0){
                ncrEmail.Recipient1__c = sndTo.get(0);
                if(sndTo.size()>1){
                    ncrEmail.Recipient2__c = sndTo.get(1);
                }
                if(sndTo.size()>2){
                    ncrEmail.Recipient3__c = sndTo.get(2);
                }
                if(sndTo.size()>3){
                    ncrEmail.Recipient4__c = sndTo.get(3);
                }
                if(sndTo.size()>4){
                    ncrEmail.Recipient5__c = sndTo.get(4);
                }
            }
            insert ncrEmail;
        }
    }
    
    @auraEnabled
    Public Static List<ContactWrap> GetAllACHContacts(String AccId){
        Set<String> conIdSet= new Set<String>();
        List<ContactWrap> conWrapLst= new List<ContactWrap>();
        for(Contact con : [Select id,Name from Contact Where AccountId = :AccId]){
            
            if(!conIdSet.contains(con.Id)){
                conIdSet.add(con.Id);
                ContactWrap conObj = new ContactWrap();
                conObj.ConName=con.Name;
                conObj.ConId=con.Id;
                conWrapLst.add(conObj);
            }
            
            
        }
        
        for(AccountContactRelation acr : [Select Contact.id,Contact.Name from AccountContactRelation Where AccountId = :AccId]){
            if(!conIdSet.contains(acr.Contact.Id)){
                conIdSet.add(acr.Contact.Id);
                ContactWrap conObj = new ContactWrap();
                conObj.ConName=acr.Contact.Name;
                conObj.ConId=acr.Contact.Id;
                conWrapLst.add(conObj);
            }
            
        }        
        
        //system.debug('conWrapLst'+conWrapLst);
        return conWrapLst;
    }
    
    @auraEnabled
    Public Static String SaveACHContactOnQuote(String ConId,String qid){
        String msg='';
        if(String.isNotBlank(ConId)){
            SBQQ__Quote__c QuoteObj = new SBQQ__Quote__c();
            QuoteObj.id=qid;
            QuoteObj.ACH_Recipient__c=ConId;
            Update QuoteObj;
            msg='Success';
        }
        return msg;
    }
    
    public class ContactWrap{
        @auraEnabled
        Public  String ConName;
        @auraEnabled
        Public  String ConId ;
    }
    
    //This method return multi_site quote details
    @auraEnabled
    public static String getMultiSiteQuote(String qId){
        List<SBQQ__Quote__c> qtobj = [select id,Name,qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.Site_Number__c, qtc_Bill_To_Site__r.Name, qtc_Multi_Site_Relationship__c, qtc_Bill_To_Site__r.AutoPay_Setup__c, qtc_Customer_Type__c, qtc_New_Aloha_Key_Number__c, qtc_Existing_Aloha_Key_Number__c, qtc_Existing_Hosted_Enterprise_ID__c, qtc_Offering__c, SBQQ__Account__r.Credit_Application_Status__c from SBQQ__Quote__c where  ((id=:qId and qtc_Multi_Site__c = true AND qtc_Multi_Site_Type__c= 'AE Only' AND qtc_Multi_Site_Relationship__c = 'Parent') OR qtc_Multi_Site_Parent_Quote__c = :qId) AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed' AND qtc_Cancelled__c=false];
        String  response = JSON.serialize(qtobj);
        return response;
    }
	
	
    
    //Called From GenerateLegalDocumentComponent, method will return quoteNames and document status for which we have already sent AE Order Form
    @auraEnabled  
    public static  Map<String,String> getQuotesWithCLMDoc(SBQQ__Quote__c quote){   
        Map<String,String> quotesWithCLMDoc = new Map<String,String>();
        if(!quote.qtc_Multi_Site__c || quote.qtc_Multi_Site_Relationship__c == 'Child'){
            SBQQ__Quote__c q = [Select Name,(Select Id, Document_Status__c From Customer_Documents__r 
                                             Where Document_Type__c = 'AE Order Form' order by LastModifiedDate desc limit 1 )
                                From SBQQ__Quote__c where id =: quote.Id];
            if(q.Customer_Documents__r.size() > 0){
                quotesWithCLMDoc.put(q.Name,q.Customer_Documents__r[0].Document_Status__c);
            }
            
        }else{
            for(SBQQ__Quote__c q : [Select name,(Select id, Document_Status__c From Customer_Documents__r 
                                                 Where Document_Type__c = 'AE Order Form' order by LastModifiedDate desc limit 1 ) 
                                    From SBQQ__Quote__c 
                                    Where ((id =:quote.Id and qtc_Multi_Site__c = true AND qtc_Multi_Site_Type__c= 'AE Only' 
                                            AND qtc_Multi_Site_Relationship__c = 'Parent') OR qtc_Multi_Site_Parent_Quote__c = :quote.Id)
                                    AND SBQQ__Primary__c=true AND SBQQ__Status__c='Approved' AND qtc_Legal_Document_Status__c!='Completed'
                                    AND qtc_Cancelled__c=false]){
                                        if(q.Customer_Documents__r.size() > 0){
                                            quotesWithCLMDoc.put(q.Name,q.Customer_Documents__r[0].Document_Status__c);
                                        }
                                    }
            
        }
        return quotesWithCLMDoc;
        
    }
   /* //TODO - this should be removed after testing in sprint 15
    @auraEnabled
    Public Static String SaveOrderFormNoteOnQuote(String OrderFormNote,String qid){
        String msg='';
        
        SBQQ__Quote__c QuoteObj = new SBQQ__Quote__c();
        QuoteObj.id=qid;
        QuoteObj.qtc_Order_Form_Notes__c=OrderFormNote;
        Update QuoteObj;
        msg='Success';
        
        return msg;
    }
    */
    @auraEnabled
    Public Static String SaveQuoteFields(String OrderFormNote,String qid){
        String msg='';
        
        SBQQ__Quote__c QuoteObj = new SBQQ__Quote__c();
        QuoteObj.id=qid;
        QuoteObj.qtc_Order_Form_Notes__c=OrderFormNote;
        Update QuoteObj;
        msg='Success';
        
        return msg;
    }
    
    /**
    * Modified By: Dharmendra Kumar Pandey
    * Method called from OrderTriggerHandler.cls
    * Only updated bill to site send to MyNCR for AutoPay setup process
    * skip order if Payment only quote, AutoPay setup True or Manual,
    */
    public static void requestToMYNCR(List<Order> triggerNew, Map<Id, Order> triggerOldMap ){
        List<Id> lstOrderToEvaluate = new List<Id>();
        List<Id> oldBillToSiteIds = new List<Id>();
        List<Id> quotes = new List<Id>();
        for( Order tOrder : triggerNew ){
            Order oldOrder = triggerOldMap.get(tOrder.Id);
            if(tOrder.qtc_Bill_To_Site__c != oldOrder.qtc_Bill_To_Site__c){ 
                if(oldOrder.qtc_Bill_To_Site__c!=null){
                    oldBillToSiteIds.add(oldOrder.qtc_Bill_To_Site__c);
                }
                quotes.add(tOrder.SBQQ__Quote__c);
            }
        }
        Map<Id, Account> updatedOrderAcctMap = new Map<Id, Account>([Select Id, Site_Number__c from Account where ID IN :oldBillToSiteIds]);
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id, qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.AutoPay_Setup__c, qtc_Bill_To_Site__r.Site_Number__c,qtc_Payments_Solution__c,qtc_Payments_Type__c,qtc_Multi_Site__c,qtc_Multi_Site_Relationship__c,qtc_Multi_Site_Type__c FROM SBQQ__Quote__c where Id IN :quotes]);
        
        for( Order tOrder : triggerNew ){
            Order oldOrder = triggerOldMap.get(tOrder.Id);
            if(tOrder.qtc_Bill_To_Site__c != oldOrder.qtc_Bill_To_Site__c){ 
                SBQQ__Quote__c quote = quoteMap.get(tOrder.SBQQ__Quote__c);
    			Boolean paymentOnly = (quote.qtc_Multi_Site__c == false && quote.qtc_Payments_Solution__c != null /*&& quote.qtc_Payments_Solution__c != 'No Payments'*/ && (/*quote.qtc_Payments_Type__c == 'No Payments' ||*/ quote.qtc_Payments_Type__c == null))
                    || (quote.qtc_Multi_Site__c == true && 'Parent'.equals(quote.qtc_Multi_Site_Relationship__c) && ('AE+PP'.equals(quote.qtc_Multi_Site_Type__c) ||'PP Only'.equals(quote.qtc_Multi_Site_Type__c)));
                if(!paymentOnly /* && (String.isBlank(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c))*/) {
	                requestToMYNCR(tOrder.SBQQ__Quote__c,updatedOrderAcctMap.get(oldOrder.qtc_Bill_To_Site__c)?.Site_Number__c);
                }
            }
        }
    }

    /**
    * Called from afterupdate trigger of quote.
    * Request send to my ncr if Bill To Site updated and document status completed, not payment only.
    */
    public static void requestToMYNCR(List<SBQQ__Quote__c> triggerNew, Map<Id, SBQQ__Quote__c> triggerOldMap ){
        List<Id> lstQuoteToEvaluate = new List<Id>();
        List<Id> oldBillToSiteIds = new List<Id>();
        List<Id> quotes = new List<Id>();
        
        for(SBQQ__Quote__c tQuote : triggerNew ){
            SBQQ__Quote__c oldQuote = triggerOldMap.get(tQuote.Id);
            if(tQuote.qtc_Bill_To_Site__c != oldQuote.qtc_Bill_To_Site__c){ 
                if(oldQuote.qtc_Bill_To_Site__c!=null){
                    oldBillToSiteIds.add(oldQuote.qtc_Bill_To_Site__c);
                }
                    quotes.add(tQuote.Id);
            }
        }
        Map<Id, Account> updatedQuoteAcctMap = new Map<Id, Account>([Select Id, Site_Number__c from Account where ID IN :oldBillToSiteIds]);
        Map<Id,SBQQ__Quote__c> quoteMap = new Map<Id,SBQQ__Quote__c>([SELECT Id, qtc_Bill_To_Site__c,qtc_Bill_To_Site__r.AutoPay_Setup__c, qtc_Bill_To_Site__r.Site_Number__c,qtc_Payments_Solution__c,qtc_Payments_Type__c,qtc_Multi_Site__c,qtc_Multi_Site_Relationship__c,qtc_Multi_Site_Type__c FROM SBQQ__Quote__c where Id IN :quotes]);
        Map<Id,SBQQ__Quote__c> qDocsSentMap = new Map<Id,SBQQ__Quote__c>([Select Id,(Select Id, Document_Status__c From Customer_Documents__r 
                                             Where Document_Type__c = 'AE Order Form' order by LastModifiedDate desc limit 1 ) From SBQQ__Quote__c where id IN: quotes]);
        
        
        for( SBQQ__Quote__c tQuote : triggerNew ){
            SBQQ__Quote__c oldQuote = triggerOldMap.get(tQuote.Id );
            if(tQuote.qtc_Bill_To_Site__c != oldQuote.qtc_Bill_To_Site__c){
                Boolean docSent = qDocsSentMap.get(tQuote.Id).Customer_Documents__r!=null;
                SBQQ__Quote__c quote = quoteMap.get(tQuote.Id);
                  Boolean paymentOnly = (quote.qtc_Multi_Site__c == false && quote.qtc_Payments_Solution__c != null /*&& quote.qtc_Payments_Solution__c != 'No Payments'*/ && (/*quote.qtc_Payments_Type__c == 'No Payments' ||*/ quote.qtc_Payments_Type__c == null))
                      || (quote.qtc_Multi_Site__c == true && 'Parent'.equals(quote.qtc_Multi_Site_Relationship__c) && ('AE+PP'.equals(quote.qtc_Multi_Site_Type__c) ||'PP Only'.equals(quote.qtc_Multi_Site_Type__c)));
                if(docSent && !paymentOnly /*&& (String.isBlank(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c))*/) {
                    requestToMYNCR(tQuote.Id,updatedQuoteAcctMap.get(oldQuote.qtc_Bill_To_Site__c)?.Site_Number__c);
                }
            }
        }
       }
    
   /**
    * This method called on click of resendAutoPaySetup button on account layout, request to MYNCR
    * AccountID
    * ACH ContactID
    * */
    
    public static String resendAutoPayRequest(Id actId, Id achContId){
        HttpRequest req;
        HttpResponse res;
        SBQQ__Quote__c q;
        String trId;
        string ErrorMsg;//errormessage from response
        string sts;//status from response
        Account act = [SELECT Id,Name, Master_Customer_Number__c,MDM_Enterprise_Nbr__c,MDM_Customer_Entity_Nbr__c FROM Account where Id=:actId];
        Contact achContact =[SELECT Email, FirstName, LastName FROM Contact WHERE Id =: achContId];
        String mcn = act.Master_Customer_Number__c;
        try {
            GenerateLegalDocumentService reqBody = new GenerateLegalDocumentService();
            GenerateLegalDocumentService.UserRequestABM reqObj = new GenerateLegalDocumentService.UserRequestABM();
            GenerateLegalDocumentService.RequestHeader hdrReq = new GenerateLegalDocumentService.RequestHeader(); 
            
			sts = validateAccount(act, achContact);
			trId = new Uuid().getValue();
            //System.debug('req>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>'+sts);		
			if(sts == null){
			
            hdrReq.TransactionID = trId; 
            hdrReq.SourceSystem='NSC';
            hdrReq.Timestamp=String.valueOf(DateTime.now());
            hdrReq.TransactionType= 'Create';
            hdrReq.TargetSystem='MyNCR';
            
            reqObj.RequestHeader=hdrReq; 
            GenerateLegalDocumentService.UserRequest usr= new GenerateLegalDocumentService.UserRequest();
            usr.FirstName=  achContact.firstname;
            usr.LastName = achContact.lastname;
            usr.Email=achContact.email;
            usr.MCN = mcn;
            usr.BillToSites = new Set<String>();
            usr.DeactivateBillSite = new Set<String>();
            usr.ResendEmail = true;
            reqObj.UserRequest = usr;
            reqBody.UserRequestABM = reqObj;
            
            // SOUP_Endpoint__c endPt = SOUP_Endpoint__c.getInstance('Autopay');
            
            Http http = new Http();
            req = new HttpRequest();
            req.setEndpoint('callout:Soup_Autopay');
           /* system.debug('EndPoint>>>>>' + req.getEndpoint());
            req.setEndpoint('https://osbcert-ha.ncr.com/ext/ea/services/NSC/Payment/api/createUser');
            String username = 'sa231080'; 
            String password = 'CEH9uanDRg3USsfFbpdWMry<V>c4tm'; 
            Blob headerValue = Blob.valueOf(username + ':' + password); 
            String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);*/
            req.setMethod('POST');
            req.setTimeout(120000); 
            //req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setBody(JSON.serialize(reqBody));
            System.debug('req>>>>>>'+reqBody);
            res = http.send(req);
            System.debug('response from myncr' + res);
            if(res.getStatusCode()==404 || res.getStatusCode()==500){
                if(res.getStatus()=='Not Found'){
                    ErrorMsg = 'some problem at SOUP end.';
                }else{
                    ErrorMsg = 'some problem at SOUP Or MyNCR end. ' + res+'.';
                } 
                sts ='FAILURE - Something went wrong.';
            } else if(String.isEmpty(res.getBody())){
                ErrorMsg = res+'.';
                sts ='FAILURE - Something went wrong.';
            } else {
                JSONParser prs = JSON.createParser(res.getBody());           
                while (prs.nextToken() != null) {
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Status')) {
                        prs.nextToken();
                        sts = prs.getText();
                    }
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Message')) {
                        prs.nextToken();
                        ErrorMsg  = prs.getText();
                    }
                }
                if(sts == 'FAILURE' && ErrorMsg.startsWith('ERROR: MCNs must be part of the same EE')){
                    /*String eEntity = ErrorMsg.substringBetween('(', ')');
                    sts ='FAILURE - This contact and email address (' + achContact.firstname +' ' 
                        + achContact.lastname + ',' + ' ' + achContact.email 
                        +') already has a MyNCR account under a different Enterprise Entity (' +eEntity 
                        +'). Either merge this MCN under the existing Enterprise Entity or update the contact with a different email address.';
                    */
                     sts ='FAILURE - Something went wrong.';
                }
                
                //system.debug('sts>>>>>' + sts);
            }
            createLogsNew(act,achContact,sts,ErrorMsg,trId,req,res); 
		}	
            
        } catch(Exception ex) {
            ErrorMsg = ex.getMessage()+'.';
            sts ='FAILURE - Something went wrong.';
            createLogsNew(act,achContact,sts,ErrorMsg,trId,req,res);
        } 
            return sts;
    }
    
    /**
    * This method called from Order Trigger when Bill To Site updated on the Order.
    * A request send to MYNCR which have details about new bill_to_site and Old bill_to_site validity.
    * Stroy#
    * Modified By: Dharmendra Kumar Pandey
    * Modification Date:19-NOV-2021
    * Id qid: Quote Id
    * String oBTSiteNo: Old Bill To Site Number - Required when called from Order Trigger
    * */ 
        
    /*ToDo : Fetch ACH contact from parent if ach = blank and ms_relationship = child*/
     @Future(callout=true)
    public static void requestToMYNCR(Id qid, String oBTSiteNo){
        myNcrCallout(qid, oBTSiteNo);
    }
    
    public static void myNcrCallout(Id qid, String oBTSiteNo) {
        //System.debug('Inside requestToMYNCR' + 'quote id' + qid +'  ' + oBTSiteNo);
        HttpRequest req;
        HttpResponse res;
        SBQQ__Quote__c q;
        String trId;
        string ErrorMsg;//errormessage from response
        string sts;//status from response
        String billToSiteNo;
        
        SBQQ__Quote__c quote = [SELECT Id,Name,qtc_Bill_To_Site__r.AutoPay_Setup__c,qtc_Multi_Site_Type__c,qtc_Multi_Site_Relationship__c,qtc_Multi_Site_Parent_Quote__c, ACH_Recipient__c, qtc_Bill_To_Site__c,SBQQ__Ordered__c, ACH_Recipient__r.Email, ACH_Recipient__r.FirstName,
                                ACH_Recipient__r.LastName, qtc_Bill_To_Site__r.Site_Number__c,SBQQ__Account__r.Master_Customer_Number__c,SBQQ__SalesRep__r.Email 
								FROM SBQQ__Quote__c where id =:qid];             
        
        try{
            if(quote.SBQQ__Ordered__c){
                Order order= [SELECT Id, qtc_Bill_To_Site__r.Site_Number__c,qtc_Bill_To_Site__r.AutoPay_Setup__c FROM Order WHERE SBQQ__Quote__r.Id =:qid]; 
                if(order.qtc_Bill_To_Site__c!=null /*&& (String.isBlank(order.qtc_Bill_To_Site__r.AutoPay_Setup__c) || 'Fail'.equals(order.qtc_Bill_To_Site__r.AutoPay_Setup__c))*/) {
                	billToSiteNo = order.qtc_Bill_To_Site__r.Site_Number__c;
                }
            } else {
                if(quote.qtc_Bill_To_Site__c!=null /*&& (String.isBlank(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c) || 'Fail'.equals(quote.qtc_Bill_To_Site__r.AutoPay_Setup__c))*/) {
                	billToSiteNo = quote.qtc_Bill_To_Site__r.Site_Number__c;
                }
            }
            
            GenerateLegalDocumentService reqBody = new GenerateLegalDocumentService();
            GenerateLegalDocumentService.UserRequestABM reqObj = new GenerateLegalDocumentService.UserRequestABM();
            GenerateLegalDocumentService.RequestHeader hdrReq = new GenerateLegalDocumentService.RequestHeader(); 
            trId = new Uuid().getValue();
            hdrReq.TransactionID = trId; 
            hdrReq.SourceSystem='NSC';
            hdrReq.Timestamp=String.valueOf(DateTime.now());
            hdrReq.TransactionType= 'Create';
            hdrReq.TargetSystem='MyNCR';
            reqObj.RequestHeader=hdrReq; 
            
            GenerateLegalDocumentService.UserRequest usr= new GenerateLegalDocumentService.UserRequest();
            
            if(quote.qtc_Multi_Site_Relationship__c=='Child' && quote.ACH_Recipient__c == null){
                SBQQ__Quote__c qParent= [Select id,ACH_Recipient__r.firstname,ACH_Recipient__r.lastname,ACH_Recipient__r.Email,SBQQ__PrimaryContact__r.firstname,SBQQ__PrimaryContact__r.lastname,SBQQ__PrimaryContact__r.email from SBQQ__Quote__c where id =:quote.qtc_Multi_Site_Parent_Quote__c];
                usr.FirstName=  qParent.ACH_Recipient__r.firstname;
                usr.LastName = qParent.ACH_Recipient__r.lastname;
                usr.Email=qParent.ACH_Recipient__r.email;
            } else {
                usr.FirstName=  quote.ACH_Recipient__r.firstname;
                usr.LastName = quote.ACH_Recipient__r.lastname;
                usr.Email=quote.ACH_Recipient__r.email;
            }
            usr.MCN = quote.SBQQ__Account__r.Master_Customer_number__C;
            if(String.isBlank(usr.Email)){
                usr.SkipACHValidation = true;
            }
            Set<String> billToSites = new Set<String>();
            if(!String.isBlank(billToSiteNo)){
            	billToSites.add(billToSiteNo);
            }
            usr.BillToSites = billToSites;
            System.debug('request body' + reqBody);
            //SetDeactivateBill To Attribute here after validating it whether old bill to site have used at any quote
            //order if not used then set in DeactivateBill of MyNCR request.
            Set<String> deactivateBToSs = new Set<String>();
            if(!String.isBlank(usr.MCN) && !String.isBlank(oBTSiteNo)){
                Boolean isValid = Cpq_QuoteUtil.getQuotes(usr.MCN,oBTSiteNo).size()>0;
                if(!isValid){
                    deactivateBToSs.add(oBTSiteNo);
                    usr.DeactivateBillSite = deactivateBToSs;
                    //removed from "BillToSites": [] attribute to avoid confusion if present
                    usr.BillToSites.remove(oBTSiteNo);
                }
            }
            
            // if nothing to send to MY NCR then break the process
            if(billToSites.isEmpty() && deactivateBToSs.isEmpty()){
                System.debug('Inside empty check');
            	return;
            }
                        
            reqObj.UserRequest = usr;
            reqBody.UserRequestABM = reqObj;
            System.debug('request body' + reqBody);
            
            Http http = new Http();
            req = new HttpRequest();
            req.setEndpoint('callout:Soup_Autopay');
            
            req.setMethod('POST');
            req.setTimeout(12000); 
          
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setBody(JSON.serialize(reqBody));
            res = http.send(req);
          
            System.debug('res'+res.getBody());
            
            if(res.getStatusCode()==404 || res.getStatusCode()==500){
                if(res.getStatus()=='Not Found'){
                    ErrorMsg = 'some problem at SOUP end.';
                }else{
                    ErrorMsg = 'some problem at SOUP Or MyNCR end. ' + res+'.';
                } 
                sts ='FAILURE';
            } else if(String.isEmpty(res.getBody())){
                ErrorMsg = res+'.';
                sts ='FAILURE';
            } else {
                JSONParser prs = JSON.createParser(res.getBody());           
                while (prs.nextToken() != null) {
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Status')) {
                        prs.nextToken();
                        sts = prs.getText();
                    }
                    if ((prs.getCurrentToken() == JSONToken.FIELD_NAME) && (prs.getText() == 'Message')) {
                        prs.nextToken();
                        ErrorMsg  = prs.getText();
                    }
                }
            }
            createLogs(quote,sts,ErrorMsg,trId,req,res);
        } catch(Exception ex) {
            System.debug('Inside exception'+ ex);
            ErrorMsg = ex.getMessage()+'.';
            sts ='FAILURE';
            createLogs(quote,sts,ErrorMsg,trId,req,res);
        }
    }
    public static void createLogsNew(Account act, Contact cnt,String sts, String ErrorMsg, String trId,HttpRequest req, HttpResponse res){
        try{
        MY_NCR_user_log__c obj = new MY_NCR_user_log__c();
        obj.Contact__c = cnt.Id;
        obj.Account_MCN__c = act.Master_Customer_number__C;
        if(req!=null){
            obj.Request__c = String.valueOf(req.getBody());
        }else{
            obj.Request__c = String.valueOf(req);
        }
        obj.Response__c = String.valueOf(res);
        obj.RequestType__c = 'Outbound';
        obj.Error_message__c = ErrorMsg;
        obj.Status__c = sts;
        obj.TransactionID__c = trId;
        obj.Sales_Rep_Email__c = UserInfo.getUserEmail();
               
            insert obj; 
        }catch(Exception e){
            OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'salesforce.donotreply@ncr.com'];
            string body= String.format(System.Label.MyNCREmailBodyExc, new List<String>{e.getMessage(),String.valueof(e.getLineNumber()),URL.getSalesforceBaseUrl().toExternalForm()+'/'+act.id,act.Name});
            EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String eBody=template.HtmlValue;
            eBody = eBody.replace('#Body', body).replace('#Header', 'Logging Failed').replace('#HeadLine', 'MyNCR User Logs - Logging Failed');
            //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String sub= 'Logging Failed - MyNCR User Logs';
            NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'GLDC Log Failed', Subject__c =sub , title__c=sub, html_body__c=eBody);
            List<String> sndTo = new List<String>();
            sndTo.addAll(System.Label.BatchJobEmailNotificationList.split(','));
            if(sndTo.size()>0){
                ncrEmail.Recipient1__c = sndTo.get(0);
                if(sndTo.size()>1){
                    ncrEmail.Recipient2__c = sndTo.get(1);
                }
                if(sndTo.size()>2){
                    ncrEmail.Recipient3__c = sndTo.get(2);
                }
                if(sndTo.size()>3){
                    ncrEmail.Recipient4__c = sndTo.get(3);
                }
                if(sndTo.size()>4){
                    ncrEmail.Recipient5__c = sndTo.get(4);
                }
            }
            insert ncrEmail;
        }
    }
    
    @InvocableMethod
    public static List<String> invokeResendAutoPayRequest(List<List<ID>> Ids){
        List<String> msg = new List<String>();
        String message = GenerateLegalDocumentService.resendAutoPayRequest(Ids[0][0], Ids[0][1]);
        msg.add(message);
        return msg;
        
    }
	
	//This method return count of account with different enterprise having same ACH 
    @auraEnabled
    public static Integer getAccountOfEnterprise(String email, String ee, String ce){
        Integer count = [SELECT count() FROM CONTACT WHERE EMAIL=:email AND (ACCOUNT.MDM_ENTERPRISE_NBR__C !=:ee OR ACCOUNT.MDM_CUSTOMER_ENTITY_NBR__C !=:ce) LIMIT 1];
        return count;
      }
    @auraEnabled
    public static Integer getAccountOfEnterpriseUI(SBQQ__Quote__c quote){
        Integer count = [SELECT count() FROM CONTACT WHERE EMAIL=:quote.ACH_Recipient__r.Email AND (ACCOUNT.MDM_ENTERPRISE_NBR__C !=:quote.SBQQ__Account__r.MDM_Enterprise_Nbr__c OR ACCOUNT.MDM_CUSTOMER_ENTITY_NBR__C !=:quote.SBQQ__Account__r.MDM_Customer_Entity_Nbr__c) LIMIT 1];
        
        return count;
      }
	  public static String validateAccount(Account act, Contact achContact){
		String sts = null;
          if(act !=null && achContact !=null){
              if(act.MDM_Enterprise_Nbr__c == null || act.MDM_Enterprise_Nbr__c == ''){
				sts ='FAILURE - CMDM update required. MDM Enterprise Entity should not be blank.';
			}else if(act.MDM_Customer_Entity_Nbr__c == null || act.MDM_Customer_Entity_Nbr__c == ''){
				sts ='FAILURE - CMDM update required. MDM Customer Entity should not be blank.';
			} else if(act.MDM_Enterprise_Nbr__c == 'EE_PENDING'){
				sts ='FAILURE - MDM update required. MCN ' +   act.Master_Customer_Number__c + ' should not be aligned to a temporary Enterprise Entity.';
			}else if(act.MDM_Customer_Entity_Nbr__c == 'CE_PENDING'){
				sts ='FAILURE - CMDM update required. MCN ' +   act.Master_Customer_Number__c + ' should not be aligned to a temporary Customer Entity.';
			}/*else if(getAccountOfEnterprise(achContact.email, act.MDM_Enterprise_Nbr__c, act.MDM_Customer_Entity_Nbr__c) > 0){
				sts ='FAILURE - CMDM update required. MCNs must be part of the same Enterprise/Customer Entity.';
			}*/
          }
			
          return sts;
	  }
    
}