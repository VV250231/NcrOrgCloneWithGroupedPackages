@RestResource(urlMapping='/AutoPaySetup/')
global class CustomerAutoPaySetup {
    @HttpPost
    global static void AutoPaySetup(){
        String fieldname, fieldValue,Status,MCN,BillToSiteNo,TransactionID,ResponseMessage,emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,bodyMsg;
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonString = req.requestBody.toString();
        JSONParser parser = JSON.createParser(jsonString);
        while(parser.nextToken() != null){
            if(parser.getCurrentToken() != JSONToken.END_OBJECT){
                parser.nextValue();
                fieldName = parser.getCurrentName();
                fieldValue = parser.getText();
                if(fieldName == 'AutopayStatus'){
                    Status = fieldValue;
                }else if(fieldName == 'MCN'){
                    MCN = fieldValue;
                }else if(fieldName == 'BillToSite'){
                    BillToSiteNo = fieldValue;
                }else if(fieldName == 'TransactionID'){
                    TransactionID = fieldValue;
                }
            }
        }
        if(!string.isEmpty(Status)){
            if(!string.isEmpty(MCN) && !string.isEmpty(BillToSiteNo)){
                List<SBQQ__Quote__c> QuoteRec = [select id,qtc_Bill_To_Site__c,SBQQ__Opportunity2__r.ownerId from SBQQ__Quote__c where SBQQ__Account__r.Master_Customer_Number__c =:MCN AND qtc_Bill_To_Site__r.Site_Number__c=:BillToSiteNo AND SBQQ__Opportunity2__r.CPQ__c = true AND SBQQ__Opportunity2__r.IsClosed = false];
                set<Id> OwnrIds = new set<Id>();
                if(QuoteRec.size()>0 && QuoteRec[0].qtc_Bill_To_Site__c != null){
                    for(SBQQ__Quote__c obj : QuoteRec){
                        OwnrIds.add(obj.SBQQ__Opportunity2__r.ownerId);
                    }
                    Account BillToAcct = [select id,Name from account where Id=:QuoteRec[0].qtc_Bill_To_Site__c];
                    if(Status.contains('SUCCESS')){
                        BillToAcct.AutoPay_Setup__c = 'True';
                        emailHeader = 'AutoPay Setup Succeeded';
                        bodyMsg = 'AutoPay has been successfully activated for this site.';
                    }else{
                        BillToAcct.AutoPay_Setup__c = 'Fail';
                        //emailHeader = 'AutoPay Setup Failed';
                        //bodyMsg = 'AutoPay has been Failed for this user.'+Status;
                    }
                    try{
                        update BillToAcct;
                        ResponseMessage = 'SUCCESS:AutoPay Status Updated successfully';
                        //--Send Email Notification to Opportunity Owner if AutoPay Setup Succeeded--
                        if(Status.contains('SUCCESS') && OwnrIds.size()>0){
                            List<user> OppOwner = [select id,email from user where id in :OwnrIds];
                            if(OppOwner.size()>0){
                                List<String> toaddress = new List<String>();
                                for(user usr : OppOwner){
                                    if(usr.email != null){
                                        toaddress.add(usr.email);
                                    }
                                }
                                EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
                                emailSubject = emailHeader + ' for '+BillToAcct.Name;
                                emailSubHeader = emailHeader + ' for '+BillToAcct.Name;
                                emailBodytoReplaced = 'Hello,<br><br>'+bodyMsg+'<b><br>Site Name: '+BillToAcct.Name+ '<br>Site Number: '+BillToSiteNo+'<br>Master Cusomer number: '+MCN+'<b><br><br>';
                                EmailBody = template.HtmlValue;
                                CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,toaddress);
                            }
                        }
                    }catch(DmlException e){ResponseMessage = 'FAILURE:'+string.valueOf(e);}
                }else{ResponseMessage = 'FAILURE:Related_BillToSite_NotFound';}
            }else{ResponseMessage = 'FAILURE:MCN_OR_BillToSite_Missing';}
        }else{ResponseMessage = 'FAILURE:Status_Missing';}
        res.addHeader('Content-Type', 'application/json');
        String response = '{"TransactionID":"'+TransactionID+'", "Status":"'+ResponseMessage+'", "Timestamp":"'+DateTime.now().formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ')+'"}';
        res.responseBody = Blob.valueOf(response);
        MY_NCR_user_log__c Log = new MY_NCR_user_log__c();
        Log.TransactionID__c = TransactionID;
        if(Status.contains('SUCCESS')){
            Log.Status__c = 'SUCCESS';
        }else{Log.Status__c = 'FAILURE';}
        Log.Site_Address_Number__c = BillToSiteNo;
        Log.Error_message__c = ResponseMessage;
        Log.Account_MCN__c = MCN;
        Log.RequestType__c = 'Inbound';
        Log.Request__c = jsonString;
        Log.Response__c = response;
        insert Log;
    }
}