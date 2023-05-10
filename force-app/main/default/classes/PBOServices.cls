/**   
* This is WEBSERVICE class to send Opportunity related information to WOT/SPOT team
* They will hit this service to populate PBO form
* @author      Ajay Dixit
********************************************************************************************
* CHANGE HISTORY:
********************************************************************************************
* CHANGED BY    CHANGED DATE     DESCRIPTION
* Ajay Dixit	 11-Jan-2016	  Initial Development
*/
global with sharing class PBOServices {
    global final static String STATUS_SUCCESS = 'SUCCESS';
    global final static String STATUS_FAILURE = 'FAILURE';
    Webservice static PBOResponse PBOInfoRequest(PBORequest req) {
        PBOResponse res;
        Savepoint sp = Database.setSavepoint(); //use full to rollback if something goes wrong      
        try {
            res = validateAndGetInfo(req);
        } catch (Exception e) {
            Database.rollback(sp);
            res = new PBOResponse(STATUS_FAILURE, 'Exception: ' + e.getMessage());
        }
        return res;
    }
    global class PBORequest {
        webservice String oppNumber;
    }
    
    global class PBOResponse {
        webservice String status;
        webservice String message;
        webservice PBO_NSC_Detail PBOInfo;
        //PBOResponse(){}
        PBOResponse(String status, String message) {
            this.status = status;
            this.message = message;
        }
    }
    global class PBO_NSC_Detail {
        webservice DateTime createDate;
        webservice Date estimateReceiptDate;
        webservice Date actualCloseDate;
        webservice Date expectedBookDate;
        webservice Date expectedDeliveryDate;
        webservice String isCommited;
        webservice String lob;
        webservice Integer oppVolume;
        webservice String forecastCategory;
        
    }
    private static PBOResponse validateAndGetInfo(PBORequest pr) {
        PBOResponse response = new PBOResponse(STATUS_FAILURE, '');
        response.status = STATUS_FAILURE;
        if (pr != null) {
            if (String.isEmpty(pr.oppNumber)) {
                response.Message = 'Opportunity Number is missing.';
            } else {
                List < Opportunity > oppList = [Select id, CloseDate, ForecastCategoryName, CreatedDate, Actual_Close_Date__c, Expected_Delivery_Date__c, Account.Industry, isClosed, (Select id, Quantity from OpportunityLineItems order by product2.name) from Opportunity where Opportunity_Number__c = : pr.oppNumber];
                if (oppList != null && oppList.size() == 1) {
                    Decimal tq = 0;
                    Date eRD;
                    Integer i = 0;
                    List < OpportunityLineItemSchedule > oppLIS = new List < OpportunityLineItemSchedule > ();
                    oppLIS = [Select id, scheduleDate from OpportunityLineItemSchedule where opportunityLineItemId in : oppList.get(0).OpportunityLineItems];
                    for (OpportunityLineItem oli: oppList.get(0).OpportunityLineItems) {
                        tq = tq + oli.Quantity;
                    }
                    Date ignoreDate = Date.newInstance(3000, 1, 1);
                    for (OpportunityLineItemSchedule olis: oppLIS) {
                        
                        if ((i == 0 || olis.scheduleDate <= eRD) && olis.scheduleDate!=ignoreDate) {
                            eRD = olis.scheduleDate;
                        }
                        i++;
                    }
                    PBO_NSC_Detail pb = new PBO_NSC_Detail();
                    pb.createDate = oppList.get(0).CreatedDate;
                    pb.estimateReceiptDate = eRD;
                    pb.actualCloseDate = oppList.get(0).Actual_Close_Date__c;
                    pb.expectedBookDate = oppList.get(0).CloseDate;
                    pb.expectedDeliveryDate = oppList.get(0).Expected_Delivery_Date__c;
                    pb.isCommited = oppList.get(0).isClosed == true ? 'Yes' : 'No';
                    pb.lob = oppList.get(0).Account.Industry;
                    pb.oppVolume = Integer.valueOf(tq);
                    pb.forecastCategory=oppList.get(0).ForecastCategoryName;
                    response.PBOInfo = pb;
                    response.status = STATUS_SUCCESS; // valid application					
                } else {
                    response.Message = 'Invalid Opportunity Number:' + pr.oppNumber + ' OR Opportunity does not exist in NSC.';
                }
            }
            
        } else {
            response.Message = 'Unknown Exception.';
        }
        return response;
    }
}