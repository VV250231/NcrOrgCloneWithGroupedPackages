public class LogPMDMRequests {
    @future
    public static void logPMDMProductCall(String req, String res) {
        PMDM_Request_log__c lgObj;
        ProductRequest pr;         
        try {
            if (!String.isEmpty(req)) {
                lgObj = new PMDM_Request_log__c(); 
                pr = (ProductRequest) JSON.deserialize(req, ProductRequest.Class);
                String logName = pr.Product_Name+': ' + Datetime.now();
                if(logName.length() > 80 ) logName = logName.substring(0,80);
                //lgObj.name = pr.Product_Name+': ' + Datetime.now();
                lgObj.name = logName;
                lgObj.Request_type__c='Product';
                lgObj.PMDM_key__c=pr.ID;
                ResponseOfRequest  response =  (ResponseOfRequest) JSON.deserialize(res, ResponseOfRequest.Class);
                lgObj.Status__c=response.status;
                lgObj.Response_Message__c=response.errorMessage;
                lgObj.Detailed_Request__c=pr.toString();
                if (!(pr.OfferPortfolioSet==null || pr.OfferPortfolioSet.offer_Portfolio==null || String.isEmpty(pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio))||pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio)=='null'))
                    lgObj.Offer_Portfolio__c=pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio);
            }
            
            if(lgObj != null) {
                insert lgObj ; 
            }
        } catch(Exception e) {
            lgObj = new PMDM_Request_log__c(); 
            lgObj.Name = 'pr-Failed Logging-' + ':' + Datetime.now();
            lgObj.Detailed_Request__c = req;
            String errMsg = e.getMessage();
            
            if (errMsg.length() > 255) {   
                lgObj.Response_Message__c = errMsg.subString(0, 255);     
            } else {
                lgObj.Response_Message__c = errMsg;
            }  
            insert lgObj;
        }
        
    }
    @future
    public static void logPMDMSolutionCall(String req, String res) {
        PMDM_Request_log__c lgObj;
        SolutionRequest sr;         
        try {
            if (!String.isEmpty(req)) {
                lgObj = new PMDM_Request_log__c(); 
                sr = (SolutionRequest) JSON.deserialize(req, SolutionRequest.Class);
                lgObj.name = sr.getSolMap(sr.SolutionSet.Solution).get('name')+': ' + Datetime.now();
                lgObj.Request_type__c='Solution';
                lgObj.PMDM_key__c=sr.getSolMap(sr.SolutionSet.Solution).get('id');
                ResponseOfRequest  response =  (ResponseOfRequest) JSON.deserialize(res, ResponseOfRequest.Class);
                lgObj.Status__c=response.status;
                lgObj.Response_Message__c=response.errorMessage;
                lgObj.Detailed_Request__c=sr.toString();

            }
            
            if(lgObj != null) {
                insert lgObj ; 
            }
        } catch(Exception e) {
            lgObj = new PMDM_Request_log__c(); 
            lgObj.Name = 'SR-Failed Logging-' + ':' + Datetime.now();
            lgObj.Detailed_Request__c = req;
            String errMsg = e.getMessage();
            
            if (errMsg.length() > 255) {   
                lgObj.Response_Message__c = errMsg.subString(0, 255);     
            } else {
                lgObj.Response_Message__c = errMsg;
            }  
            insert lgObj;
        }
        
    }
    
}