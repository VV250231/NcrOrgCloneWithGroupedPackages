/**************************************
Author ...............: Ajay Dixit
Date Created .........: 25 Aug 2021
Last Modified By .....: Ajay Dixit
Last Modified Date ...: 25 Aug 2021
Description ..........: EBA_SF-1496::ERP Cloud : Disputes : Send disputes from SF to ERP Cloud (via RPA).
This class holds outbound call to Create or Close the dispute in ERP, The rqst is first sent to RPA through SOUP, RPA Bot process rqst and creates or Closes Dispute in ERP.
***************************/
public class SyncDisputeToERPCld {
    @future (callout=true)
    public static void disputeCallout(Set<id> caseL, Boolean isInsert ) {
        //Initialize Variables
        Boolean stpPrcsng=false;
        Set<String> dispNos=new Set<String>();
        String dispNosStr='', Intrfc='SF-ERP CLOUD Disputes', failr='FAILURE:Callout to ERP :';
        String trId =new Uuid().getValue();
        Http http = new Http();
        List<Dispute_Invoices__c> dispL=new List<Dispute_Invoices__c>();
        Map<string, rpaClsd> clsdDispts=new Map<string, rpaClsd>();
        HttpRequest rqst = new HttpRequest();
        HttpResponse rsp=new HttpResponse();
        // start Execution
        try{
            String Q=(isInsert==true?Label.Dispute_RPA_Insert_Q:Label.Dispute_RPA_Closed_Q);            
            setHeader(rqst, trId);             
            JSONGenerator reqbdy=JSON.createGenerator(true);
            /*###################################################*/            
            try{
                //reqbdy=mainJSON_test(reqbdy, '110230', '1016', 2, 100001);
                reqbdy=mainJSON(reqbdy, caseL, isInsert, dispNos, Q, dispL, clsdDispts);
                for(String s:dispNos) {
                    dispNosStr += (dispNosStr == ''?'':',')+s;
                }
            }catch(Exception e){
                CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(caseL), null,failr+e.getMessage().left(200),dispNosStr,dispNosStr,Intrfc);//insertDisputeLogs(String transId, String req, String res, String status, String caseNumber, String reqType)
                stpPrcsng=true;
            }
            /*#################### SENDING ###############################*/
            if(!stpPrcsng && reqbdy.getAsString().length()>0){
                try{
                    rqst.setbody(reqbdy.getAsString());                    
                    rsp = http.send(rqst);
                    if (rsp.getStatusCode() != 200) {                        
                        //CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst.getbody()), String.valueOf(rsp.getbody()),failr+rsp.getStatus(),dispNosStr,dispNosStr,Intrfc);//insertDisputeLogs(String transId, String req, String res, String status, String caseNumber, String reqType)
                        rsp = http.send(rqst);
                        if (rsp.getStatusCode() != 200) {                            
                            CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst.getbody()), String.valueOf(rsp.getbody()),failr+rsp.getStatus(),dispNosStr,dispNosStr,Intrfc);//insertDisputeLogs(String transId, String req, String res, String status, String caseNumber, String reqType)
                        	 // Fire Failure Email to RPA
                            sendFailureEmail(dispL, clsdDispts, Q);
                        }else {
                            CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst.getbody()), String.valueOf(rsp.getbody()),'SUCCESS: '+rsp.getStatus(),dispNosStr,dispNosStr,Intrfc);
                        } 
                    } else {
                        CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst.getbody()), String.valueOf(rsp.getbody()),'SUCCESS: '+rsp.getStatus(),dispNosStr,dispNosStr,Intrfc);
                    } 
                }catch(Exception e){
                    CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst.getbody()), String.valueOf(rsp.getbody()),failr+e.getMessage().left(200),dispNosStr,dispNosStr,Intrfc);//insertDisputeLogs(String transId, String req, String res, String status, String caseNumber, String reqType)
                    sendFailureEmail(dispL, clsdDispts, Q);
                }   
            }
        }
        catch(Exception e){
            CCADDLogsUtility.insertDisputeLogs(trId,String.valueOf(rqst), String.valueOf(rsp),failr+e.getMessage().left(200),dispNosStr,dispNosStr,Intrfc);            
        } 
    }
    public static JSONGenerator mainJSON(JSONGenerator reqbdy, Set<id> DisputeIds, Boolean isInsert, Set<String> dispNos, String Q, List<Dispute_Invoices__c> dispL, Map<string, rpaClsd> clsdDispts) {
        dispL.addAll([select id, Name,dispute__r.Status,MCN__c,toLabel(Dispute__r.Dispute_Reason__c),Dispute__r.Dispute_Close_Reason__c,Dispute__r.CCAD_Dispute_Nbr__c, Invoice_Number__c from Dispute_Invoices__c where Dispute__c in:DisputeIds order by Dispute__c]);
        System.debug(dispL);
        if(dispL.size()>0){
            reqbdy.writeStartObject();
            reqbdy.writeStringField('queueName', Q);
            reqbdy.writeStringField('commitType', 'AllOrNothing');
            reqbdy.writeFieldName('queueItems');
            reqbdy.writeStartArray();
            
            
            if(isInsert){
                for(Dispute_Invoices__c di:dispL)
                {    
                    system.debug('@@');
                    reqbdy.writeStartObject();
                    reqbdy.writeStringField('Priority', 'High');
            		reqbdy.writeFieldName('SpecificContent');
                    dispNos.add(di.Dispute__r.CCAD_Dispute_Nbr__c);
                    reqbdy.writeStartObject();
                    reqbdy.writeStringField('Salesforce Dispute Number', di.Dispute__r.CCAD_Dispute_Nbr__c);
                    reqbdy.writeStringField('MCN', di.MCN__c);
                    reqbdy.writeStringField('Invoice Number', di.Invoice_Number__c);
                    reqbdy.writeStringField('Dispute Reason',di.Dispute__r.Dispute_Reason__c);
                    reqbdy.writeEndObject();
                    reqbdy.writeStringField('DeferDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
            		reqbdy.writeStringField('DueDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
                    reqbdy.writeStringField('Reference',di.Invoice_Number__c);
                    reqbdy.writeEndObject();
                }  
            }else{
                
                for(Dispute_Invoices__c di:dispL)
                {                
                    String d=di.Dispute__r.CCAD_Dispute_Nbr__c;
                    
                    if(clsdDispts.containsKey(d)) {
                        clsdDispts.get(d).invCnt++;
                        
                    } else{
                        rpaClsd rc=new rpaClsd();
                        rc.mcn=di.MCN__c;
                        rc.invCnt=1;
                        clsdDispts.put(d,rc);
                    }              
                } 
                dispNos.addAll(clsdDispts.keySet());
                for(String d:clsdDispts.keySet())
                {   
                    reqbdy.writeStartObject();             
                    reqbdy.writeStringField('Priority', 'High');
            		reqbdy.writeFieldName('SpecificContent');
                    reqbdy.writeStartObject();
                    reqbdy.writeStringField('Salesforce Dispute Number', d);
                    reqbdy.writeStringField('MCN', clsdDispts.get(d).mcn);
                    reqbdy.writeStringField('Invoice Count', String.valueOf(clsdDispts.get(d).invCnt));
                    reqbdy.writeEndObject();                    
                    reqbdy.writeStringField('DeferDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
            		reqbdy.writeStringField('DueDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
                    reqbdy.writeStringField('Reference',d);
                    reqbdy.writeEndObject();
                    
                }  
                
            }           
            //reqbdy.writeEndObject();
            reqbdy.writeEndArray();
            reqbdy.writeEndObject();
        }
        return reqbdy;
    }
    //To be removed, just for testing
    /*public static JSONGenerator mainJSON_test(JSONGenerator reqbdy, String DisputeId,String MCN, Integer Count, Integer InitialInvoice) {
reqbdy.writeStartObject();
reqbdy.writeStringField('queueName', 'sfpoc');
reqbdy.writeStringField('commitType', 'AllOrNothing');
reqbdy.writeFieldName('queueItems');
reqbdy.writeStartArray();
Integer j=0;
for(Integer i=0; i<count; i++)
{
j=j+i;
reqbdy.writeStartObject();
reqbdy.writeStringField('Priority', 'High');
reqbdy.writeFieldName('SpecificContent');
reqbdy.writeStartObject();
reqbdy.writeStringField('Salesforce Dispute Number', DisputeId);
reqbdy.writeStringField('MCN', MCN);
reqbdy.writeStringField('Invoice Number', InitialInvoice+''+i);
reqbdy.writeStringField('Dispute Reason', 'Dispute Reason'+i);
reqbdy.writeEndObject();
reqbdy.writeStringField('DeferDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
reqbdy.writeStringField('DueDate',system.now().formatGmt('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\''));
reqbdy.writeStringField('Reference',InitialInvoice+''+i);
reqbdy.writeEndObject();

}
reqbdy.writeEndArray();
reqbdy.writeEndObject();

return reqbdy;
}*/
    public static void setHeader( HttpRequest rqst, String trId) {
        rqst.setEndpoint('callout:Diputes_ERPCloud');//https://osbdev-ha.ncr.com/ext/ea/services/uipath/invoiceDispute
        //rqst.setEndpoint('https://osbdev-ha.ncr.com/ext/ea/services/uipath/invoiceDispute');//https://osbdev-ha.ncr.com/ext/ea/services/uipath/invoiceDispute
        rqst.setMethod('POST');
        rqst.setHeader('Content-Type', 'application/json');
        rqst.setHeader('x-transaction-id',  trId); 
        rqst.setHeader('cache-control', 'no-cache');
        rqst.setHeader('SourceSystem',  'NSC');
    } 
    public class rpaClsd{
        String mcn;
        Integer invCnt=0;
    }
    public static void sendFailureEmail(List<Dispute_Invoices__c> dispL,  Map<string, rpaClsd> clsdDispts, String Q){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setTargetObjectId(userinfo.getUserId()); 
        mail.setSenderDisplayName('Salesforce Support'); 
        //Todo Set OWD Email
        mail.setReplyTo('no-reply@ncr.com');
        String templt=(clsdDispts.size()>0?'SF_RPA_Closed_Failed_Notification':'SF_RPA_Failed_Notification'),  mb='';
        EmailTemplate et= [Select Id,Subject,HtmlValue,body from EmailTemplate where DeveloperName  = :templt];
        if(clsdDispts.size()>0){
            mb=mb+Label.Dispute_Email_2;
            for(String d:clsdDispts.keySet())
            {   
                mb += '<tr><td>' + d + '</td><td>' +clsdDispts.get(d).mcn + '</td><td>' + String.valueOf(clsdDispts.get(d).invCnt) + '</td><td>' + d + '</td></tr>';
            }
            mb +='<table>';            
        }else{
            mb=mb+Label.Dispute_Email_1;
            for(Dispute_Invoices__c di:dispL)
            {   
                mb += '<tr><td>' + di.Dispute__r.CCAD_Dispute_Nbr__c + '</td><td>' + di.MCN__c + '</td><td>' + di.Invoice_Number__c + '</td><td>' + di.Dispute__r.Dispute_Reason__c +'</td><td>' + di.Invoice_Number__c + '</td></tr>';
            }
            mb +='<table>'; 
        }
        String htmlbdy = et.HtmlValue, plainbdy = et.body;
        htmlbdy=htmlbdy.replace('###TABLE',mb);
        plainbdy=plainbdy.replace('###TABLE',mb);
        htmlbdy=htmlbdy.replace('##Queue',Q);
        plainbdy=plainbdy.replace('##Queue',Q); 
        mail.setSaveAsActivity(false);
        //To DO set Distribution Email Id
        mail.toAddresses = new String[] { 'ad250024@ncr.com','sa185043@ncr.com'};
            mail.setHtmlbody(htmlbdy);
        mail.setPlainTextbody(plainbdy);
        mail.setSubject(et.Subject+Q);
        //mail.setTreatTargetObjectAsRecipient(false);
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage> {mail};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
    }
}