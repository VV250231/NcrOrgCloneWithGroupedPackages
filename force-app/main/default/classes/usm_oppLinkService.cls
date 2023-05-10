/**************************************
Author ...............: Ajay Dixit
Date Created .........: 13 Sep 2018
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class holds services exposed for associating usm Opportunity with NSC Opportunity
***************************/
global with sharing class usm_oppLinkService {
    Webservice static usmLinkServiceResponse usmOppLink(usmLinkServiceRequest req) {
        usmLinkServiceResponse res = new usmLinkServiceResponse(null);
        
        try {
            if(req!=null){
                if(req.nscOppNum!=null && req.usmOppNum!=null){
                    res=engageUsm(String.valueOf(req.nscOppNum), String.valueOf(req.usmOppNum));
                }else{
                    res=new usmLinkServiceResponse('Error:USM Opportunity Number or NSC Opportunity Number is sent as blank for linking NSC and USM Opportunuty'); 
                }
            }else{
                res=new usmLinkServiceResponse('Error: Invalid request for Engaging / Linking USM and NSC Opportunity'); 
            }
            
            
        }          
        
        catch (Exception e) {
            res = new usmLinkServiceResponse('Exception: ' + e.getMessage());
        }

        return res;
    }
    
    global class usmLinkServiceResponse {
        webservice String status;
        webservice String errorMessage;
         
        global usmLinkServiceResponse(string res) {
            this.status = 'Success';
            this.errorMessage = null;
            if (res != null) {
                this.status = 'Failure';
                this.errorMessage = res;
            }           
            
        }
    }
    global class usmLinkServiceRequest {        
        webservice String nscOppNum;   
        webservice String usmOppNum;
    }
    private static usmLinkServiceResponse engageUsm(String nscOppNum, String usmOppNum){
        usmLinkServiceResponse res=new usmLinkServiceResponse(null);      
        List <Opportunity> o=[Select id, Opportunity_Number__c, usm_Opportunity_Number__c from Opportunity where Opportunity_Number__c=:nscOppNum    OR usm_Opportunity_Number__c=:usmOppNum];
        if(o!=null && o.size()>0){
            //Put business logic here
            if(o.size()>1){
                String oppno;
                for(Opportunity opp:o){
                    if(nscOppNum==opp.Opportunity_Number__c && opp.USM_Opportunity_Number__c!=usmOppNum)  {
                     oppno=opp.USM_Opportunity_Number__c;   
                    } 
                }
               res=new usmLinkServiceResponse('Error: This NSC Opportunity is already associated with other USM Opportunity USM Opp#:'+oppno);
            }else{
                if(nscOppNum!=o.get(0).Opportunity_Number__c){   
                    if(o.get(0).USM_Opportunity_Number__c!=null && o.get(0).USM_Opportunity_Number__c==usmOppNum){
                        res=new usmLinkServiceResponse('Error: This USM Opportunity number is aleady associated with NSC Opportunity: '+o.get(0).Opportunity_Number__c);
                    }else{
                       res=new usmLinkServiceResponse('Error: NSC Opportunity Number entered is incorrect, Please verify'); 
                    }
                    
                }else if(o.get(0).USM_Opportunity_Number__c!=null && o.get(0).USM_Opportunity_Number__c!=usmOppNum){
                   res=new usmLinkServiceResponse('Error: This NSC Opportunity is already associated with other USM Opportunity USM Opp#:'+o.get(0).USM_Opportunity_Number__c); 
                }else if(o.size()==1){
                    o.get(0).USM_Opportunity_Number__c=usmOppNum;
                    update o;
                }
            }
        }else{
            res=new usmLinkServiceResponse('Error: Either Opportunity does not exist with this Opportunity Number or Opportunity Numer is incorrect');
            
        }
        if(res.status=='Success'){
            System.debug('USM Opportunity successfully linked with NSC Opportunity');    
        }
        return res;
        
    }
    
}