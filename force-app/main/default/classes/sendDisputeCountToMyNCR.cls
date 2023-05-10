/****************************************************************************************************
* Author        :   Saurav  
* Date          :   04-08-2021
* Description   :   This REST service will send Dispute Count to MyNCR
*************************************************************************************************/

@RestResource(urlMapping='/invoiceDispute/count') 
global class sendDisputeCountToMyNCR {
    @HttpGet
    global static DisputeResponse disputeCount(){
        String mcns,dspId='',transId= '', srcSys='';
        DisputeResponse dispResp  = new DisputeResponse();
        DisputeResponseHeader respHeader = new DisputeResponseHeader();
        DisputeListWrapper dispListHeadr = new DisputeListWrapper();
        RestRequest request = RestContext.request;    
        Map <String, String> reqHeaders = RestContext.request.headers;
        Map <String, String> reqParams = RestContext.request.params;
        String caseNbr= null; 
        
        if(reqHeaders != null && !reqHeaders.isEmpty()) {
            transId = reqHeaders.get('x-transaction-id');         
        }
        
        if(reqParams != null && !reqParams.isEmpty()) {
            mcns = reqParams.get('MCNs'); 
        }
        String errorVald = reqVald(transId,mcns);
        Boolean ValdReq =String.isBlank(errorVald);
        try {
            if(ValdReq){
                String dspRtId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(Label.RT_Case_Dispute).getRecordTypeId();
                String dspQry = ' SELECT count(id) DspCount,Status FROM Case WHERE RecordTypeId=:dspRtId';
                if (String.isNotBlank(mcns)) { 
                    List<String> mcnLst = mcns.split(',');                    
                    //if(mcnLst.size() > 1000) throw new DisputeException('More than 1000 MCNs not allowed in Send Dispute Count'); 
                    dspQry += ' AND Account.Master_Customer_Number__c IN :mcnLst';
                }
                dspQry += ' Group By Status';
                System.debug(dspQry);
                List<AggregateResult> aggList = Database.query(dspQry);
                Map<string ,Decimal> cStatusCode = new Map<string ,Decimal>();               
                
                for(SetDisputeStatusCode__c caseDetails : [Select caseStatusCode__c,caseStatus__c from SetDisputeStatusCode__c]){
                    cStatusCode.put(caseDetails.caseStatus__c,caseDetails.caseStatusCode__c); 
                }  
                List<DisputeDetail> dspLst = new List<DisputeDetail>();                   
                for(AggregateResult aggr:aggList) {                              
                    DisputeDetail dsp = new DisputeDetail();    
                    string csc = string.valueOf(cStatusCode.get((String)aggr.get('Status')));                     
                    dsp.count =(integer)aggr.get('DspCount'); 
                    System.debug('##############Count#############'+dsp.count);
                    dsp.Status = csc;  
                    System.debug('##############Status#############'+dsp.Status);
                    dspLst.add(dsp);
                } 
                dispListHeadr.Dispute = dspLst; 
                respHeader.Status = 'SUCCESS';
            } else {
                respHeader.Status = 'FAILURE';   
                dispListHeadr.ResponseDescription = errorVald;               
            }           
            
        }
        catch(Exception e) {
            respHeader.Status = 'FAILURE';   
            dispListHeadr.ResponseDescription = e.getMessage();
        }   
        
        respHeader.TransactionID = String.isNotBlank(transId) ? transId : '';       
        respHeader.Timestamp = Datetime.now().format();
        dispResp.ResponseHeader = respHeader;
        dispResp.InvoiceDisputeResponse = dispListHeadr; 
        
        CCADDLogsUtility.insertDisputeLogs(transId, String.valueOf(reqParams), String.valueOf(dispResp), dispResp.ResponseHeader.Status, dspId, 'GetDispuetCount_' + (String.isNotBlank(srcSys) ? srcSys :'Unknown') + '-SF'); 
        
        return dispResp; 
    }
    public static String reqVald(String transId,String mcns ){
        String err = '';
        if(String.isBlank(transId))  {
            err = 'Transacton ID not found in Get Dispute Count Request';    
        } else if (String.isBlank(mcns)) {
            err = 'Master Customer Number missig in Get Dispute Count Request';  
        }  
        return err;
        
    }         
    
    global class DisputeResponse {
        global DisputeResponseHeader ResponseHeader;
        global DisputeListWrapper InvoiceDisputeResponse;   
    }
    
    global class DisputeListWrapper { 
        global String ResponseCode;
        global String ResponseDescription;
        List<DisputeDetail> Dispute;    
    }
    global class DisputeDetail {            
        global String Status; 
        global Integer Count;
    }
    public class DisputeException extends Exception{}
}