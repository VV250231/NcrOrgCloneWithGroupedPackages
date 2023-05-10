/**************************************
Author ...............: Pandey, Dharmendra Kumar
Modified Date.........: 03-JUN-2021
Description...........: Update legal document status on the quote
***************************************/

public class CPQCustomerDocTriggerHandler {
    
    List<Customer_Document__c> listNewRecords = new List<Customer_Document__c>();
    
    public CPQCustomerDocTriggerHandler(List<Customer_Document__c> listTriggerNew){
        this.listNewRecords = listTriggerNew;
    }
    
    class DocDate {
        DateTime orderAuthSentDate;
        DateTime orderAuthAccDate;
    }
    
    /**
* This method updates below fields on the Quote.
* qtc_Order_Authorization_Sent_Date__c, qtc_Order_Authorization_Accepted_Date__c, qtc_Customer_Setup_Complete_Date__c
* 
*/
    public void updateLegalDocStatus(){
        try {
            Map<String,String> quoteIDMap = new Map<String,String>();
            Map<String,String> quoteIDPONumMap = new Map<String,String>();
            Map<String,DocDate> qMap = new Map<String,DocDate>();
            for(Customer_Document__c customerDoc:listNewRecords){
                if(customerDoc.Quote__c != null && customerDoc.Document_Type__c!=null){
                     SBQQ__Quote__c qt = [Select id,qtc_Legal_Document_Status__c from SBQQ__Quote__c where id =: customerDoc.Quote__c ORDER BY LastModifiedDate DESC LIMIT 1];
                if(!'Completed'.equals(qt.qtc_Legal_Document_Status__c) || ('Completed'.equals(qt.qtc_Legal_Document_Status__c) && !Label.CPQ_EXCLUDED_CLM_DOC_STATUS.split(',').contains(customerDoc.Document_Status__c))){
                //if(!Label.CPQ_EXCLUDED_CLM_DOC_STATUS.split(',').contains(customerDoc.Document_Status__c)){
                        if(customerDoc.Document_Type__c.equals('AE Order Form') || customerDoc.Document_Type__c.equals('AE Amendment')){
                            quoteIDMap.put(customerDoc.Quote__c, customerDoc.Document_Status__c);
                             quoteIDPONumMap.put(customerDoc.Quote__c, customerDoc.PO_Number__c);
                            
                        }
                    	
                        /*if((customerDoc.Document_Sent_Date__c!=null || customerDoc.Customer_Signature_Date__c!=null) && customerDoc.Document_Type__c.equals('AE Shipment/Order Authorization')){
                            DocDate docDates = qMap.get(customerDoc.Quote__c);
                            if(docDates==null){
                                docDates = new DocDate(); 
                                qMap.put(customerDoc.Quote__c,docDates);
                            }
                            docDates.orderAuthSentDate=customerDoc.Document_Sent_Date__c;
                            docDates.orderAuthAccDate=customerDoc.Customer_Signature_Date__c;
                        }*/
                        
                    }
                    
                    if(!Label.CPQ_EXCLUDED_CLM_DOC_STATUS.split(',').contains(customerDoc.Document_Status__c)){
                                            	
                        if((customerDoc.Document_Sent_Date__c!=null || customerDoc.Customer_Signature_Date__c!=null) && customerDoc.Document_Type__c.equals('AE Shipment/Order Authorization')){
                            DocDate docDates = qMap.get(customerDoc.Quote__c);
                            if(docDates==null){
                                docDates = new DocDate(); 
                                qMap.put(customerDoc.Quote__c,docDates);
                            }
                            docDates.orderAuthSentDate=customerDoc.Document_Sent_Date__c;
                            docDates.orderAuthAccDate=customerDoc.Customer_Signature_Date__c;
                        }
                        
                    }
                }
            }
            
            Set<String> allKeys = new Set<String>();
            allKeys.addAll(quoteIDMap.keySet());
            allKeys.addAll(qMap.keySet());
            List<SBQQ__Quote__c> quotes = [Select id,qtc_Legal_Document_Status__c,qtc_Order_Authorization_Sent_Date__c, qtc_Order_Authorization_Accepted_Date__c,qtc_PO_Number__c from SBQQ__Quote__c where id IN:allKeys];
            for(SBQQ__Quote__c quote : quotes){
                if(quoteIDMap.get(quote.ID)!=null){
                    quote.qtc_Legal_Document_Status__c=quoteIDMap.get(quote.ID);
                }
                if(quoteIDPONumMap.get(quote.ID)!=null){
                    quote.qtc_PO_Number__c=quoteIDPONumMap.get(quote.ID);
                }
                if(qMap.get(quote.ID)?.orderAuthSentDate!=null && quote.qtc_Order_Authorization_Sent_Date__c==null){
                    quote.qtc_Order_Authorization_Sent_Date__c=qMap.get(quote.ID)?.orderAuthSentDate;
                }
                if(qMap.get(quote.ID)?.orderAuthAccDate!=null && quote.qtc_Order_Authorization_Accepted_Date__c==null){
                    quote.qtc_Order_Authorization_Accepted_Date__c=qMap.get(quote.ID)?.orderAuthAccDate;
                }
            }
            
            
            if(quotes.size()>0){
                SBQQ.TriggerControl.disable();
                update quotes;
            }
            
        } catch (Exception ex) {
            system.debug('Error Occured : CPQCustomerDocTriggerHandler.updateLegalDocStatus : '+ex.getMessage());
            NSC_ExceptionHandlerUtil.publishErrorMessageEvent(ex, 'CPQCustomerDocTriggerHandler');
        } finally {
            SBQQ.TriggerControl.enable(); 
        }
    }
}