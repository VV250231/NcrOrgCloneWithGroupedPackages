/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: OppQuoteLinkageController.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Description...........: This class is used as generalised class for QuBy quote creation.
                          This class is also used for opportunity search from QuBy.  
Modification History
Version     Story No.     ModifiedBy      Date        Description
1.1        NC_AGILE-824  Nagendra Singh  18-9-2017   Remove OPID from Opportunity search functionality
##################################################################################################*/

global with sharing class OppQuoteLinkageController {

    global final static String STATUS_SUCCESS = 'SUCCESS';
    global final static String STATUS_FAILURE = 'FAILURE';
    global Enum COMPARISON_OPR {STARTS_WITH, CONTAINS, EQUALS}
    global Enum QuBy_OPR{ QUBY_LINK, QUBY_DELINK, QUBY_DELETE }
    
    private final static Set<String> appOPRSet = new Set<String>();
   
    static {
        for( QuBy_OPR a : QuBy_OPR.values()){
            appOPRSet.add( a.name() );    
        } 
    }
    
    /*##################################################################################################
    # Method Name............: OppQuoteLinkage
    # Param..................: QuoteObject orderObj                                                        
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 23-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 23-08-2016
    # Description............: This method is use Attach Or Dettach Quote to given opportunity.                          
    ##################################################################################################*/
    webservice static QuoteResponse OppQuoteLinkage( QuoteObject orderObj ) {
        QuoteResponse response = NULL;
        OrderController quoteObj = new OrderController();
        Logger logger = new Logger();
         
        try {
            logger.logRequest( orderObj );
            response = validateInputQuote( orderObj );
            
            if ( response != null && response.status == OppQuoteLinkageController.STATUS_SUCCESS ) {                
                if( orderObj.appName == OppQuoteLinkageController.QuBy_OPR.QUBY_Link.name() ) {
                    response =  quoteObj.attachQubYQuote( orderObj );             
                }else if( orderObj.appName == OppQuoteLinkageController.QuBy_OPR.QUBY_DELETE.name() || orderObj.appName == OppQuoteLinkageController.QuBy_OPR.QUBY_DELINK.name() ){
                    response = quoteObj.dettachQuByQuote( orderObj );
                }
            } 
        } catch( Exception e ) {
            System.debug( '::EXCEPTION::' + e );
            response = new QuoteResponse();
            response.status = OppQuoteLinkageController.STATUS_FAILURE;  
            response.message = e.getMessage();    
        }
        logger.logResponse(response, orderObj);
        System.debug( '>>>>> Output Response >>>>>' + response );
        return response;
    }
    
    /*##################################################################################################
    # Method Name............: NSCOppSearch
    # Param..................: OppSearchRequest srchReq                                                        
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 23-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 23-08-2016
    # Description............: This method is use search opportunity in NSC.                          
    ##################################################################################################*/
    webservice static OppSearchResponse NSCOppSearch( OppSearchRequest srchReq ) {
        OppSearchResponse srchRes = new OppSearchResponse();
        OrderController orderObj = new OrderController();
        try {
            if ( srchReq != null ) { 
                if ( !( String.isEmpty( srchReq.custNumber ) || String.isEmpty( srchReq.accCountryCode )) ) {//V1.1 removed OfferPortfolio from if condition
                    srchRes  = orderObj.runOppSearch( srchReq );  
                } else {
                    srchRes.status = OppQuoteLinkageController.STATUS_FAILURE;
                    srchRes.message = 'MSG : Required Customer Number, Country Code and Offer Portfolio';     
                }        
            } else {
                srchRes.status = OppQuoteLinkageController.STATUS_FAILURE;
                srchRes.message = 'MSG : Required Search Input';
            }
        } catch( Exception e ) {
            srchRes.status = OppQuoteLinkageController.STATUS_FAILURE;
            srchRes.message = 'ERR : ' + e.getMessage();    
        }
        Logger.logSearchCall( JSON.serialize( srchReq ), JSON.serialize( srchRes ) );
        return srchRes; 
    }
    
    /*##################################################################################################
    # Method Name............: validateInputQuote
    # Param..................: QQuoteObject orderObj                                                        
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 23-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 23-08-2016
    # Description............: This method is use validate the inputs.                          
    ##################################################################################################*/
    private static QuoteResponse validateInputQuote( QuoteObject orderObj ) {
        QuoteResponse response = new QuoteResponse();
        response.status = OppQuoteLinkageController.STATUS_FAILURE; 
        
        if ( orderObj != null ) {
            if ( String.isEmpty( orderObj.appName ) || ( !appOPRSet.contains( orderObj.appName.toUpperCase() ) ) ) {                        
                response.message = 'Invalid Application';
            }else if ( String.isEmpty( orderObj.OpportunityNumber ) || String.isEmpty( orderObj.quoteNumber ) ) {
                response.message = 'Null Opportunity Number or Quote Number';                 
            } else if ( String.isEmpty( orderObj.quoteName ) ) {
                response.message = 'Blank Quote Name';                
            }else {
                response.status = OppQuoteLinkageController.STATUS_SUCCESS;  // valid application
            }  
        } else { response.message = 'Null Quote Input'; }
        return response;   
    }
    
    /*##################################################################################################
    # Method Name............: OppSearchRequest
    # Param..................:                                                         
    # Created by.............: Mudit Saxena                                                                 
    # Created Date...........: 23-08-2016                                                                               
    # Last Modified by.......: Mudit Saxena 
    # Last Modified Date.....: 23-08-2016
    # Description............: This wrapper class for NSC Opportunity Search.
    ##################################################################################################*/
    global class OppSearchRequest {
        webservice String oppName;
        webservice COMPARISON_OPR oppNameOPR;
        webservice String oppNumber;
        webservice COMPARISON_OPR oppNumberOPR;
        webservice String userQuickLookId;
        webservice String accCountryCode;
        webservice String custNumber;
        webservice String offerPortfolio;
    }
    
    global class OppSearchResponse {
        webservice String status;
        webservice String message;
        webservice List<Opportunity> oppList; 
        
        global OppSearchResponse(){}
        
        global OppSearchResponse( String status, String message ) {
            this.status = status;
            this.message = message;
        } 
    }
}