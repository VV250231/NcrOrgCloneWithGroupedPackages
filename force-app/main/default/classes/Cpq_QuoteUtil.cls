/*
*********************************************************
Apex Class Name    : CPQ_Util
@description       : Contains comman method for CPQ Quotes
@author            : Shiv Mahla
Modification Log:
Ver   Date         Author                               Modification
1.0   15-Dec-2021  Shiv Mahla                      Initial Version
*********************************************************
*/
global without sharing class Cpq_QuoteUtil {
    
    static final String QUOTE_STATUS_APPROVED = 'Approved';
    static final String MS_RELATIONSHIP_PARENT = 'Parent';
    static final String MS_RELATIONSHIP_CHILD = 'Child';
    static final String MS_TYPE_AE_ONLY =  'AE Only';
    static final String ERROR_MCN_MISSING = System.label.ERROR_MCN_MISSING;
    static final String ERROR_SITE_NUMBER_MISSING = System.label.ERROR_SITE_NUMBER_MISSING;
    static final String ERROR_MCN_NOT_FOUND = System.label.ERROR_MCN_NOT_FOUND;
    static final String ERROR_SITE_NOT_FOUND = System.label.ERROR_SITE_NOT_FOUND;
    static final String ERROR_WRAPPER_GENERATION = System.label.ERROR_WRAPPER_GENERATION;
    static final String ERROR_WRONG_SITE = System.label.ERROR_WRONG_SITE;
    static final String SERVICE_OFFERING_CATEGORY_PAYMENT_PROCESSING = 'Payments Processing';
    
    public static List<QuoteDetail> getQuotes(String masterCustomerNumber, String billToSiteNumber) {
        List<QuoteDetail> quoteLst = new List<QuoteDetail>();     
        try {
            Account account = CPQ_Util.getAccount(masterCustomerNumber);
            if (account == null) {
                throw new InvalidParameterException(ERROR_MCN_NOT_FOUND);
            }

            Account billToSite = CPQ_Util.getSite(billToSiteNumber);
            if (billToSite == null) {
                throw new InvalidParameterException(ERROR_SITE_NOT_FOUND);
            }

            if (billToSite.ParentId != account.Id) {
                throw new InvalidParameterException(ERROR_WRONG_SITE);
            }

            quoteLst.addAll(getOrderedQuoteDetail(masterCustomerNumber, billToSiteNumber));
            quoteLst.addAll(getUnOrderedQuoteDetail(masterCustomerNumber, billToSiteNumber)); 
            
        } catch (Exception ex) {
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex,'Cpq_QuoteUtil');
        }
        return quoteLst;   
    }

    
    // Returns Ordered QuoteDetail list which meeting to the criteria else retrun empty list
    // returns: List<QuoteDetail>
    //@param masterCustomerNumber
    //@param billToSiteNumber
    public static List<QuoteDetail> getOrderedQuoteDetail(String masterCustomerNumber, String billToSiteNumber) {
        
        List<QuoteDetail> quoteLst = new List<QuoteDetail>();
        List<Order> orders = new List<order>();
        List<id> orderedQuoteIds = new List<Id>();
        orders = getOrders(masterCustomerNumber, billToSiteNumber);
        for (Order orderRec : orders) {
            orderedQuoteIds.add(orderRec.SBQQ__Quote__c);
        }
        
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteRec = new Map<Id,SBQQ__Quote__c>();
        List<SBQQ__Quote__c> orderedQuotes = getQuotesById(orderedQuoteIds);
        
        for (SBQQ__Quote__c quote: orderedQuotes) {
            quoteIdToQuoteRec.put(quote.id,quote);
        }
        
        for (Order order : orders) {
            if (quoteIdToQuoteRec.keySet().contains(order.SBQQ__Quote__c)) {
                QuoteDetail qd = new QuoteDetail();
                qd.quoteNo                 = CPQ_Util.safeString(order.SBQQ__Quote__r.Name);
                qd.deliverToSiteNumber     = CPQ_Util.safeString(order.Deliver_To_Site__r.Site_Number__c);
                qd.deliverToSiteName       = CPQ_Util.safeString(order.Deliver_To_Site__r.Name);
                qd.deliverToSiteStreet     = CPQ_Util.safeString(order.Deliver_To_Site__r.BillingStreet);
                qd.deliverToSiteCity       = CPQ_Util.safeString(order.Deliver_To_Site__r.BillingCity);
                qd.deliverToSiteState      = CPQ_Util.safeString(order.Deliver_To_Site__r.BillingState);
                qd.deliverToSiteCountry    = CPQ_Util.safeString(order.Deliver_To_Site__r.BillingCountry);
                qd.deliverToSitePostalCode = CPQ_Util.safeString(order.Deliver_To_Site__r.BillingPostalCode);
                qd.contractNo = CPQ_Util.safeString(String.valueOf(order.qtc_Contract__r.ContractNumber));
                quoteLst.add(qd);
            }
        }
        return quoteLst;
    }

    // Returns Ordered UnOrderedQuoteDetail list which meeting to the criteria else retrun empty list
    // returns: List<QuoteDetail>
    //@param masterCustomerNumber
    //@param billToSiteNumber
    public static List<QuoteDetail> getUnOrderedQuoteDetail(String masterCustomerNumber, String billToSiteNumber) {
        List<QuoteDetail> quoteLst = new List<QuoteDetail>();
        for (SBQQ__Quote__c q : getUnorderedQuoteRecords(masterCustomerNumber, billToSiteNumber)) {
            QuoteDetail qd = new QuoteDetail();
            qd.quoteNo                 = CPQ_Util.safeString(q.Name);
            qd.deliverToSiteNumber     = CPQ_Util.safeString(q.Deliver_To_Site__r.Site_Number__c);
            qd.deliverToSiteName       = CPQ_Util.safeString(q.Deliver_To_Site__r.Name);
            qd.deliverToSiteStreet     = CPQ_Util.safeString(q.Deliver_To_Site__r.BillingStreet);
            qd.deliverToSiteCity       = CPQ_Util.safeString(q.Deliver_To_Site__r.BillingCity);
            qd.deliverToSiteState      = CPQ_Util.safeString(q.Deliver_To_Site__r.BillingState);
            qd.deliverToSiteCountry    = CPQ_Util.safeString(q.Deliver_To_Site__r.BillingCountry);
            qd.deliverToSitePostalCode = CPQ_Util.safeString(q.Deliver_To_Site__r.BillingPostalCode);
            
            if (q.SBQQ__Contracts__r.size() > 0) {
                qd.contractNo = q.SBQQ__Contracts__r[0].ContractNumber;
            }
            quoteLst.add(qd);
        }
        return quoteLst;
    }

    // Returns applicable quote list for the input MCN and Site.
    
    private static List<SBQQ__Quote__c> getUnorderedQuoteRecords(String masterCustomerNumber, String billToSiteNumber) {      
        List<SBQQ__Quote__c> quotesToReturn = new List<SBQQ__Quote__c>();     
        Set<Id> orderQuoteIds = new Set<Id>();      
        List<SBQQ__Quote__c> quoteLst = [ 
        SELECT 
                Id, Name, SBQQ__Type__c,qtc_Payments_Solution__c, qtc_Multi_Site__c,qtc_Payments_Type__c,

                Deliver_To_Site__r.Site_Number__c, Deliver_To_Site__r.Name, Deliver_To_Site__r.BillingStreet,
                Deliver_To_Site__r.BillingCity, Deliver_To_Site__r.BillingState, Deliver_To_Site__r.BillingCountry,
                Deliver_To_Site__r.BillingPostalCode,

                ( SELECT ContractNumber FROM SBQQ__Contracts__r ORDER BY CreatedDate DESC LIMIT 1),

                (Select Id FROM SBQQ__LineItems__r WHERE  Service_Offer_Category__c !=: SERVICE_OFFERING_CATEGORY_PAYMENT_PROCESSING and Service_Offer_Category__c !=null 
                        AND SBQQ__Quantity__c > 0 LIMIT 1)

        FROM 
                SBQQ__Quote__c 
        WHERE 
                SBQQ__Status__c =: QUOTE_STATUS_APPROVED 
                AND (qtc_Legal_Document_Status__c = 'Completed' OR qtc_Legal_Document_Status__c = 'Sent for Signature')
                //AND qtc_Cancelled__c = false
                AND SBQQ__Ordered__c = false
                AND SBQQ__Account__r.Master_Customer_Number__c =: masterCustomerNumber
                AND qtc_Bill_To_Site__r.Site_Number__c =:  billToSiteNumber
                AND ( qtc_Multi_Site__c = false 
                      OR (( qtc_Multi_Site_Relationship__c =: MS_RELATIONSHIP_PARENT AND qtc_Multi_Site_Type__c =: MS_TYPE_AE_ONLY) 
                                OR (qtc_Multi_Site_Relationship__c =: MS_RELATIONSHIP_CHILD )
                        )
                    )
        ];

        for (SBQQ__Quote__c quote : quoteLst) {
            if (quote.qtc_Multi_Site__c) {
                quotesToReturn.add(quote);
            } else if (! isPaymentOnlyQuote(quote)){
                quotesToReturn.add(quote);
            }
        }
        return quotesToReturn;
    }

    // get quotes by Id.
    private static List<SBQQ__Quote__c> getQuotesById(List<Id> quoteIds) {
        List<SBQQ__Quote__c> quotesToReturn = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quoteLst = [ 
        SELECT 
                Id, Name, SBQQ__Type__c,qtc_Payments_Solution__c, qtc_Multi_Site__c,qtc_Payments_Type__c,

                Deliver_To_Site__r.Site_Number__c, Deliver_To_Site__r.Name, Deliver_To_Site__r.BillingStreet,
                Deliver_To_Site__r.BillingCity, Deliver_To_Site__r.BillingState, Deliver_To_Site__r.BillingCountry,
                Deliver_To_Site__r.BillingPostalCode,

                ( SELECT ContractNumber FROM SBQQ__Contracts__r ORDER BY CreatedDate DESC LIMIT 1),

                (Select Id FROM SBQQ__LineItems__r WHERE  Service_Offer_Category__c !=: SERVICE_OFFERING_CATEGORY_PAYMENT_PROCESSING and Service_Offer_Category__c !=null 
                        AND SBQQ__Quantity__c > 0 LIMIT 1)

        FROM 
                SBQQ__Quote__c 
        WHERE 
                Id IN : quoteIds
        ];
        
        for (SBQQ__Quote__c quote : quoteLst) {
            if (quote.qtc_Multi_Site__c) {
                quotesToReturn.add(quote);
            } else if (! isPaymentOnlyQuote(quote)){
                quotesToReturn.add(quote);
            }
        }
        return quotesToReturn;
    }
    
    // Checks either quote has line items others than payments package or not.
    private static Boolean isPaymentOnlyQuote(SBQQ__Quote__c quote) {
        return ((!String.isBlank(quote.qtc_Payments_Solution__c) ) && quote.qtc_Payments_Solution__c != 'No Payments' ) && (String.isBlank(quote.qtc_Payments_Type__c ) || quote.qtc_Payments_Type__c == 'No Payments' );
    }

    // returns order
    private static List<Order> getOrders(String masterCustomerNumber, String billToSiteNumber) {
        List<Order> orders = new List<Order>();
        orders = [    
            SELECT 
                Id, Name, SBQQ__Quote__c, qtc_Bill_To_Site__c, qtc_Bill_To_Site_Number__c,
                qtc_Contract__c, qtc_Master_Quote_Number__c, qtc_Multi_Site__c,
                qtc_Multi_Site_Relationship__c, qtc_Multi_Site_Type__c,
                
                SBQQ__Quote__r.Name, SBQQ__Quote__r.qtc_Cancelled__c, SBQQ__Quote__r.SBQQ__Ordered__c,
                
                Deliver_To_Site__r.Site_Number__c, Deliver_To_Site__r.Name, Deliver_To_Site__r.BillingStreet,
                Deliver_To_Site__r.BillingCity, Deliver_To_Site__r.BillingState, Deliver_To_Site__r.BillingCountry,
                Deliver_To_Site__r.BillingPostalCode,
                
                qtc_Contract__r.ContractNumber
                
            FROM Order
            WHERE  /*(qtc_Contract__c = null OR SBQQ__Quote__r.qtc_Cancelled__c = false )
                AND */
                SBQQ__Quote__r.SBQQ__Status__c =: QUOTE_STATUS_APPROVED 
                AND (qtc_Contract__c = null OR qtc_Contract__r.EndDate > Today )
                AND (qtc_Contract__c = null OR qtc_Contract__r.qtc_Termination_Date__c > Today OR qtc_Contract__r.qtc_Termination_Date__c = null)
                AND qtc_Bill_To_Site_Number__c =: billToSiteNumber 
                AND qtc_Master_Customer_Number__c =: masterCustomerNumber
                AND ( qtc_Multi_Site__c = false OR (( qtc_Multi_Site_Relationship__c ='Parent' AND qtc_Multi_Site_Type__c ='AE Only') OR (qtc_Multi_Site_Relationship__c ='Child')) )
        ];
        return orders ; //qtc_Contract__c = null = Order is created but not yet contracted.
        
    }

    
    global class QuoteDetail {
        String deliverToSiteNumber = '';
        String deliverToSiteName = ''; 
        String deliverToSiteStreet = '';   
        String deliverToSiteCity = '';     
        String deliverToSiteState = '';     
        String deliverToSiteCountry = '';   
        String deliverToSitePostalCode = '';
        String quoteNo = '';
        String contractNo = '';
    }


    public class MissingParameterException extends Exception {}
    public class InvalidParameterException extends Exception {}

}