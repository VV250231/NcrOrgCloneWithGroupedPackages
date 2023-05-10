/*##################################################################################################
# Project Name..........: CPQ QuBy                                                                    
# File..................: OrderController.cls                                                        
# Version...............: 32.0 
# Created by............: Mudit Saxena
# Created Date..........: 23-08-2016                                                                              
# Description...........: This class is used to create SOAP service for QuBy quote creation.
Modification History
Version     Story No.     ModifiedBy      Date        Description
1.1        NC_AGILE-824  Nagendra Singh  18-9-2017   Remove OPID from Opportunity search functionality

 	 EBA_SF-170             Santosh Jha    1/20/2022  1 -Technical Debt - Apex SOQL injection - Part 1
                                                   
################################################################################################*/

global with sharing class OrderController {
    
    
    /**
* This method is used to fetch QuBy__c record by QuBy_Detail__c Id.
*
* @param orderId - QuBy_Detail__c ID
* @return QuBy__c record 
*/
   @TestVisible private QuBy_Detail__c getQuByQuote( String orderId ) {
        if ( orderId != null ) {
            List<QuBy_Detail__c> linkedQuotes = [ SELECT Id, Opportunity__c FROM QuBy_Detail__c WHERE id =: orderId LIMIT 1 ];                                                
            if(!linkedQuotes.isEmpty()) {
                return linkedQuotes.get(0);
            }
        }
        return null;
    }
    
    /**
* This method is used to fetch opportunity record by opportunity number.
*
* @param oppNum- Opportunity Number
* @return Opportunity record 
*/
    @TestVisible private Opportunity getOpptybyOpptyNum(String oppNum) {
        System.debug('@@@@'+oppNum);
     
        if(!String.isEmpty(oppNum)) {
            List<Opportunity> oppList = [SELECT Id, Opportunity_Number__c FROM Opportunity WHERE Opportunity_Number__c = :oppNum LIMIT 1];
            System.debug('@@@@@@'+oppList.get(0));
            if(!oppList.isEmpty()) {
               return oppList.get(0);   
            } 
        }
      //  System.debug('@@@@@@'+o);
        return null;
    }
    
    @TestVisible private QuBy_Detail__c getQuByByQuoteNum( String quoteNum ) {
        System.debug('@@@@@@@@'+quoteNum);
        if( !String.isEmpty( quoteNum ) ) {
            List<QuBy_Detail__c> orderList = [ SELECT Id, Name ,Quote_Number__c,Annuity_Quote_Status__c,Solution_Quote_Status__c,Opportunity__c,Opportunity_No__c FROM QuBy_Detail__c WHERE Quote_Number__c =: quoteNum LIMIT 1 FOR UPDATE ];
            System.debug('@@@@@@@@'+orderList);
            if(!orderList.isEmpty()) {
                return orderList.get(0);
            }
        }
        return null;   
    }
    
    @TestVisible private void updateQuByDetail( QuBy_Detail__c quoteDetail ){
        update quoteDetail;
    }
    
    public QuoteResponse attachQubYQuote( QuoteObject orderObj ){
       // if( !test.isRunningTest() ){        
            QuoteResponse response = new QuoteResponse();      
            Opportunity oppObj = getOpptybyOpptyNum( orderObj.OpportunityNumber );
            QuBy_Detail__c quoteDetail = getQuByByQuoteNum( orderObj.quoteNumber );
            system.debug('$$'+oppObj);
            system.debug('$$'+quoteDetail);
            
            //Checking if opportunity exist or not
            if( oppObj != null ){
                Savepoint s1 = Database.setSavepoint();
                //Checking quote details is exist or not.
                if( quoteDetail != null ){
                    //Checking if already linked or not.                
                    if( quoteDetail.Opportunity__c == null ){
                        try {
                            // create Quote Association
                            quoteAssociation(oppObj, quoteDetail);
                        }catch( Exception e ) {
                            Database.rollback( s1 );response.status = OppQuoteLinkageController.STATUS_FAILURE;  
                            response.message = e.getMessage(); 
                        }
                    }else{
                        try{
                            //quoteAssociation(oppObj, quoteDetail);
                            system.debug( ':::::::' + oppObj );
                            system.debug( ':::::::' + oppObj.Id );
                            system.debug( ':::::::' + quoteDetail );
                            //quoteDetail.Opportunity__c = oppObj.Id;
                            quoteDetail.Opportunity_No__c = oppObj.Opportunity_Number__c;
                            system.debug( ':::::::' + quoteDetail );
                            update quoteDetail;
                        }catch( Exception e ) {
                            Database.rollback( s1 );
                            response.status = OppQuoteLinkageController.STATUS_FAILURE;  
                            response.message = e.getMessage(); 
                        }
                    }
                }else{
                    // create Quote Detail
                    QuBy_Detail__c qd = createQubyDetail(orderObj);
                    // create quote association
                    quoteAssociation(oppObj, qd);
                }
                response.status = OppQuoteLinkageController.STATUS_SUCCESS;
            }else{
                response.status = OppQuoteLinkageController.STATUS_FAILURE;  
                response.message = 'Invalid Opportunity Number';
            }
            return response;
      /*  }else{
            QuoteResponse response = new QuoteResponse(); 
            response.status = OppQuoteLinkageController.STATUS_SUCCESS;
            
            
            return response;  
        }*/
    }
    
    @TestVisible private void quoteAssociation(Opportunity oppObj, QuBy_Detail__c quoteDetail){        
        //quoteDetail.Opportunity__c = oppObj.Id;
        quoteDetail.Opportunity_No__c = oppObj.Opportunity_Number__c;
        updateQuByDetail( quoteDetail );
        
    }
    
    @TestVisible private QuBy_Detail__c createQubyDetail(QuoteObject orderObj){
       // if( !test.isRunningTest() ){ 
            QuBy_Detail__c qd=new QuBy_Detail__c();
            qd.Name=orderObj.quoteName;
            qd.Quote_Number__c=orderObj.quoteNumber;
            qd.CurrencyIsoCode=orderObj.quoteCurrency;
            qd.Solution_Quote_Status__c = orderObj.Status;
            qd.MCN__c=orderObj.MCN;
            qd.Solution_Modification_Date__c = orderObj.lastModifiedDate;
            
            insert qd;
            return qd;
       /* }else{
            return null;
        }*/
    }
    
    public QuoteResponse dettachQuByQuote( QuoteObject orderObj ){
        
        QuoteResponse response = new QuoteResponse();
        QuBy_Detail__c quoteDetail = getQuByByQuoteNum( orderObj.quoteNumber );
        //if( !test.isRunningTest() ){ 
            if( quoteDetail != null ){
                Savepoint s1 = Database.setSavepoint();
                try {
                    quoteDetail.Opportunity_No__c = null;
                    //quoteDetail.Opportunity__c = null;
                    updateQuByDetail( quoteDetail );
                }catch( Exception e ) {
                    Database.rollback( s1 );
                    response.status = OppQuoteLinkageController.STATUS_FAILURE;  
                    response.message = e.getMessage(); 
                }
            }else{
                response.status = OppQuoteLinkageController.STATUS_FAILURE;  
                response.message = 'Invalid Quote Number';
            }
        //}
        return response;
    }
    
    /**
* This method is used to search opportunity record by OppSearchRequest object members.
*
* @param srchReq- OppQuoteLinkageController.OppSearchRequest object
* @return OppQuoteLinkageController.OppSearchResponse object
*/
    public OppQuoteLinkageController.OppSearchResponse runOppSearch(OppQuoteLinkageController.OppSearchRequest srchReq) {
        OppQuoteLinkageController.OppSearchResponse srchRes = new OppQuoteLinkageController.OppSearchResponse(OppQuoteLinkageController.STATUS_SUCCESS, 'MSG:');
        List<Opportunity> oppList = new List<Opportunity>();
        String  dynamicQuery =  'SELECT Id, Name, Opportunity_Number__c, Account.Name,' 
            + 'Account.Master_Customer_Number__c, Owner.Quicklook_ID__c,' 
            + 'LastModifiedDate, LastModifiedBy.Name From Opportunity ';
        String queryCondition = '';  
        String queryConditionMCN = '';                         
        Boolean NonROR_Flag = false;
        Boolean blankSearch = true;
        integer resultSize = 0;
        integer MAX_RESULT_SIZE = 100;
        
        String ctryCodewithMCN = srchReq.accCountryCode + srchReq.custNumber;
        String ownerQuickLookId = srchReq.userQuickLookId; 
        String reqOppName = srchReq.oppName;
        String reqOppNum = srchReq.oppNumber;
        /*String offerPortfolio=srchReq.offerPortfolio;
List<String> offerPortFolioList=offerPortfolio.split('\\|',0);
String offerPrtfolioString='(Solution_Portfolio__c=\'';
Integer j=1;
for(String o:offerPortFolioList){
offerPrtfolioString+=o;
if(j==offerPortFolioList.size()){
offerPrtfolioString=offerPrtfolioString+'\')';
}
if(j<offerPortFolioList.size() && offerPortFolioList.size()>1){
offerPrtfolioString=offerPrtfolioString+'\' OR Solution_Portfolio__c=\'';
}
j++;
}*/
        List<Account> relAccList = [SELECT Id from Account
                                    WHERE Country_with_Master_customer_Number__c = :ctryCodewithMCN 
                                    LIMIT 1];
        
        if (!relAccList.isEmpty()) { // ROR Scenario
            queryConditionMCN += ' Account.Country_with_Master_customer_Number__c = :ctryCodewithMCN';
            //queryCondition+=offerPrtfolioString+' AND isClosed=false';
            queryCondition +=' id !=null';    //done for EBA_SF-1374
        } else { // NON ROR Scenario
            //queryCondition+=offerPrtfolioString+' AND isClosed=false'; 
            queryCondition += ' id !=null'; // done for EBA_SF-1374
            NonROR_Flag = true;
        }    
        
        // quicklook filter
        if (!String.isEmpty(ownerQuickLookId)) { 
            blankSearch = false;
            if (!String.isEmpty(queryCondition)) {
                queryCondition += ' AND ';
            }
            queryCondition += ' Owner.Quicklook_ID__c = :ownerQuickLookId ';
        } 
        
        // oppname filter
        if (!String.isEmpty(reqOppName)) {
            string searchreqOppName = '%' + reqOppName  + '%';
            blankSearch = false;
            if (!String.isEmpty(queryCondition)) {
                queryCondition += ' AND ';
            }    
             
            if (srchReq.oppNameOPR == OppQuoteLinkageController.COMPARISON_OPR.EQUALS) {
                queryCondition += ' Name = :reqOppName ' ;
            } else if (srchReq.oppNameOPR == OppQuoteLinkageController.COMPARISON_OPR.CONTAINS) {
                
                queryCondition += ' Name LIKE : searchreqOppName' ;
                
            } else if (srchReq.oppNameOPR == OppQuoteLinkageController.COMPARISON_OPR.STARTS_WITH) {
               
                queryCondition += ' Name LIKE : searchreqOppName' ;
            }     
        }
        
        // opp number filter
        if (!String.isEmpty(reqOppNum)) {
             string searchreqOppNum = '%' +reqOppNum  + '%';
            blankSearch = false;
            if (!String.isEmpty(queryCondition)){
                queryCondition += ' AND ';   
            }
            
            if (srchReq.oppNumberOPR == OppQuoteLinkageController.COMPARISON_OPR.EQUALS) {
                queryCondition += ' Opportunity_Number__c = :reqOppNum ' ;
            } else if (srchReq.oppNumberOPR == OppQuoteLinkageController.COMPARISON_OPR.CONTAINS) {
                queryCondition += ' Opportunity_Number__c LIKE : searchreqOppNum' ;
            } else if (srchReq.oppNumberOPR == OppQuoteLinkageController.COMPARISON_OPR.STARTS_WITH) {
                queryCondition += ' Opportunity_Number__c LIKE : searchreqOppNum' ;
            }     
        }
        
        if (!String.isEmpty(queryCondition)) {  
            String dynamicQuery1=dynamicQuery;
            /*if(!String.isEmpty(queryConditionMCN)){
                dynamicQuery  += ' WHERE ' + String.escapeSingleQuotes(queryCondition) + ' AND '+String.escapeSingleQuotes(queryConditionMCN) + ' LIMIT 110';
            }
            else{
                dynamicQuery  += ' WHERE ' + String.escapeSingleQuotes(queryCondition)  + ' LIMIT 110';
            }*/
            if(!String.isEmpty(queryConditionMCN)){
                dynamicQuery  += ' WHERE ' + queryCondition + ' AND '+ queryConditionMCN + ' LIMIT 110';
            }
            else{
                dynamicQuery  += ' WHERE ' + queryCondition  + ' LIMIT 110';
            }
            system.debug('@@@@'+dynamicQuery);
            oppList = Database.Query(String.escapeSingleQuotes(dynamicQuery));
            resultSize = oppList.size();
            if(resultSize==0 && !String.isEmpty(queryConditionMCN)){
                dynamicQuery1  += ' WHERE ' + queryCondition + ' LIMIT 110';
                system.debug('@@@ query:::'+dynamicQuery1 );
                oppList = Database.Query(String.escapeSingleQuotes(dynamicQuery1));   // String.escapeSingleQuotes
                resultSize = oppList.size();
                if(oppList.size()>0){
                    srchRes.message += 'No records matched criteria including the Customer. Results are returned based on other criteria entered. ';
                }
                
            }
            
            // trim list to size 100
            if (resultSize >= MAX_RESULT_SIZE) {
                for(integer i = resultSize - 1; i >= MAX_RESULT_SIZE; i--) {
                    oppList.remove(i);
                }
            }
        }
        
        if (NonROR_Flag) {
            srchRes.message += 'Customer with MCN: ' + srchReq.custNumber + ' does not exist in NSC.';
            
            if(oppList.isEmpty()) {
                if(blankSearch) {
                    srchRes.message += 'No records returned since criteria are blank.';
                } else {
                    srchRes.message += 'No records returned based on criteria entered above.';
                }  
            } else {
                srchRes.oppList = oppList;
                if(resultSize > MAX_RESULT_SIZE) {
                    srchRes.message += 'More than 100 opportunities match the search criteria. Only 100 opportunities are being displayed.'
                        + 'Refine Search to narrow down the result.';
                } else {
                    srchRes.message += 'Returned Opportunity records are based on criteria entered above.';   
                }
            }
        } else {
            if(oppList.isEmpty()) {
                srchRes.message += 'No Opportunity records were found matching the search criteria.';
            } else {
                srchRes.oppList = oppList; 
                if(resultSize > MAX_RESULT_SIZE) {
                    srchRes.message += 'More than 100 opportunities match the search criteria. Only 100 opportunities are being displayed.' 
                        + 'Refine Search to narrow down the results.';    
                }
            }
        }  
        return srchRes;
    }
    
    public class OrderLinkageException extends Exception {} 
}