/**************************************
Author ...............: Ajay Dixit
Date Created .........: 16 Oct 2017
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class holds services exposed for Product management and is called by PMDM via SOUP
***************************/
global with sharing class PMDMServices {
    Webservice static ResponseOfRequest ProductSyncRequest(ProductRequest req) {
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); //use full to rollback if something goes wrong         
        try {
            res = validateProductRequest(req);
            if (res.status.equals(ResponseOfRequest.STATUS_SUCCESS)) {
                PMDMProcessing pd = new PMDMProcessing();
                res = pd.productProcess(req);
            }          
        }
        catch (Exception e) {
            Database.rollback(sp);
            res = new ResponseOfRequest('Exception: ' + e.getMessage());
        }
        LogPMDMRequests.logPMDMProductCall(JSON.serialize(req), JSON.serialize(res));
        return res;
    }
    private static ResponseOfRequest validateProductRequest(ProductRequest pr) {
        ResponseOfRequest response = new ResponseOfRequest();
        response.status = ResponseOfRequest.STATUS_FAILURE;
        
        if (pr != null) {
            if (String.isEmpty(pr.Product_Name)) {
                response.errorMessage = 'Product Name is missing.';
                
            } else if (String.isEmpty(pr.ID)) {
                response.errorMessage = 'Product MDM key is mandatory';
            } else if (String.isEmpty(pr.Product_Status)) {
                response.errorMessage = 'Product Status is missing';
            } else if (String.isEmpty(pr.Product_Type)) {
                response.errorMessage = 'Product Type is missing';
            } else if (String.isEmpty(pr.Revenue_Type)) {
                response.errorMessage = 'Revenue Type is missing';
            }  else if (String.isEmpty(pr.ROR_Modified_By)) {
                response.errorMessage = 'Ror Modified By is missing';
            } else if (String.isEmpty(pr.Ror_Created_By)) {
                response.errorMessage = 'Ror Created By is missing';
            }  else if (pr.ROR_Created_Date==null ) {
                response.errorMessage = 'Ror Created Date is missing';
            }  else if (pr.ROR_Modified_Date==null ) {
                response.errorMessage = 'ROR Modified Date is missing';
            } 
            // commented for testing
           /* else if (pr.DivisionSet==null || pr.DivisionSet.Division==null || String.isEmpty(pr.getStringVsp(pr.DivisionSet.Division))||pr.getStringVsp(pr.DivisionSet.Division)=='null') {
                response.errorMessage = 'Aligned Industry / Division are missing';
            }  else if (pr.OfferPortfolioSet==null || pr.OfferPortfolioSet.offer_Portfolio==null || String.isEmpty(pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio))||pr.getStringVs(pr.OfferPortfolioSet.offer_Portfolio)=='null') {
                response.errorMessage = 'Aligned Offer Portfolio (Industry Group) is missing';
            }*/  else {
                response.status = ResponseOfRequest.STATUS_SUCCESS; // valid application
            }
        } else {
            response.errorMessage = 'The product request sent is NULL';
        }
        return response;
    }
    
    
    Webservice static ResponseOfRequest SolutionSyncRequest(SolutionRequest req) {
        ResponseOfRequest res = new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); //use full to rollback if something goes wrong         
        try {
            res = validateSolnRequest(req);
            if (res.status.equals(ResponseOfRequest.STATUS_SUCCESS)) {
                PMDMProcessing pd = new PMDMProcessing();
                res = pd.solutionProcess(req);
            }          
        }
        catch (Exception e) {
            Database.rollback(sp);
            res = new ResponseOfRequest('Exception: ' + e.getMessage());
        }
        LogPMDMRequests.logPMDMSolutionCall(JSON.serialize(req), JSON.serialize(res));
        return res;
    }
    private static ResponseOfRequest validateSolnRequest(SolutionRequest pr) {
        ResponseOfRequest response = new ResponseOfRequest();
        response.status = ResponseOfRequest.STATUS_FAILURE;
        
        if (pr != null) {
            if (String.isEmpty(pr.Offer_Status)) {
                response.errorMessage = 'Offer status is missing in request';
            } else if (String.isEmpty(pr.Offer_Type)) {
                response.errorMessage = 'Offer Type is missing in request';
            }  else {
                response.status = ResponseOfRequest.STATUS_SUCCESS; // valid application
            }
        } else {
            response.errorMessage = 'The product request sent is NULL';
        }
        return response;
    }
    
}