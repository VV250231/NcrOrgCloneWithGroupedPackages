/**   
* This is WEBSERVICE class to receive Deming  related information to NSC team
* They will hit this service to Send  Deming info
* @author      Satya Singh
********************************************************************************************
* CHANGE HISTORY:
********************************************************************************************
* CHANGED BY    CHANGED DATE     DESCRIPTION
* Satya Singh   24-Aug-2019    Initial Development
*/
global with sharing class DemingService {
    Webservice static ResponseOfRequest DemingRequestInfo(DemingRequest req) {
        ResponseOfRequest res= new ResponseOfRequest();
        Savepoint sp = Database.setSavepoint(); //use full to rollback if something goes wrong      
        try {
            res = validateAndGetInfo(req);
        }
        catch(DmlException de){
            res.status = STATUS_FAILURE;
            System.debug('In DMLException222'+de.getDmlMessage(0));
            res.errorMessage=de.getDmlMessage(0);
        }catch (Exception e) {
            res.status = STATUS_FAILURE;
            Database.rollback(sp);
            System.debug('Exception1111'+e.getMessage());
            
            
        }
        
        return res;
    }
    global final static String STATUS_SUCCESS = 'SUCCESS';
    global final static String STATUS_FAILURE = 'FAILURE';
    global class DemingRequest {
        webservice String orderNo;
        webService String orderId;
        webService String customerName;
        webService String customerNo;
        webService String customerCountryCode;
        webService String site;
        webService String shipToLocation;
        webService String deliveryToLocation;
        webService String deliveryToAddress1;
        webService String salesPersonName;
        webService String salesPersonGlobalId;
        webService Date RDD;
        webService Date maxPromiseDate;
        webService Date maxScheduledShipDate;
        webService Date maxScheduledArrivalDate;
        webService String CDPName;
        webService String CDPGlobalId;
        webService String CISName;
        webService String CISGlobalId;
        webService String reasonCode;
        webService String customerIndustry;
        webservice String partyNumber;  
        webService String salesOrdCode;
        webService String orderStatus;
        webService DateTime PDChangedOn;
        webService String threshold;
        webService String QuoteNumber;
        
    }
    
    private static ResponseOfRequest validateAndGetInfo(DemingRequest dmReq) {
        ResponseOfRequest response = new ResponseOfRequest();
        response.status=STATUS_FAILURE;
        if (dmReq != null) {
           if(String.isEmpty(dmReq.orderNo)){
                response.errorMessage = 'Order Number is Missing.';   
            } 
             else if(String.isEmpty(dmReq.orderId)){
                response.errorMessage = 'Order Id is Missing.';   
            }
             else if(String.isEmpty(response.errorMessage)){
                CADD_Management_History__c dmg = new CADD_Management_History__c();
           //   Deming__c dmg = new Deming__c();
                dmg.Order_number__c=dmReq.orderNo;
                dmg.Order_Id__c=dmReq.orderId;
                dmg.Customer_Name__c=dmReq.customerName;
                dmg.Customer_No__c=dmReq.customerNo;
                dmg.Customer_Country_code__c=dmReq.customerCountryCode;
                dmg.Site__c=dmReq.site;
                dmg.Ship_To_Location__c=dmReq.shipToLocation;
                dmg.Delivery_To_Location__c=dmReq.deliveryToLocation;
                dmg.delivery_to_address1__c=dmReq.deliveryToAddress1;
                dmg.SalesPerson_Name__c=dmReq.salesPersonName;
                dmg.SalesPerson_Global_Id__c=dmReq.salesPersonGlobalId;
                dmg.RDD__c=dmReq.RDD;
                dmg.Max_Promise_Date__c=dmReq.MaxPromiseDate;
                if(dmReq.MaxScheduledShipDate != null){
                    dmg.Max_Scheduled_Ship_Date__c=dmReq.MaxScheduledShipDate;
                }
                
                dmg.CDP_Name__c=dmReq.CDPName;
                dmg.CDP_Global_Id__c=dmReq.CDPGlobalId;
                dmg.CIS_Name__c=dmReq.CISName;
                dmg.CIS_Global_ID__c=dmReq.CISGlobalId;
                dmg.Reason_Code__c=dmReq.reasonCode;
                if(dmReq.maxScheduledArrivalDate != null){
                    dmg.Max_Scheduled_Arrival_Date__c=dmReq.maxScheduledArrivalDate;
                }
                
                dmg.Customer_Industry__c=dmReq.customerIndustry;
                dmg.Party_No__c=dmReq.partyNumber;
                dmg.SalesOrdCode__c=dmReq.salesOrdCode;
                 dmg.Order_Status__c=dmReq.orderStatus;
                 dmg.PDChangedOn__c=dmReq.PDChangedOn;
                 dmg.threshold__c=dmReq.threshold;
                 dmg.Quote_Number__c=dmReq.QuoteNumber;

                
                insert dmg;
                  System.debug('11111@@@@');
                response.status = STATUS_SUCCESS; 
                //List<Deming__c> demObj= [ select Order_Id__c from Deming__c where Order_Id__c=:dmReq.orderNo];
                
                
            }
            else if(String.isNotEmpty(response.errorMessage)){
                System.debug('Fields are missing in Request');
            }
            
        } else {
            response.errorMessage = 'Request is Empty';
        }
        
        return response;
    }
}