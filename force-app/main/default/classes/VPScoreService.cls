/**************************************
Author ...............: Ajay Dixit
Date Created .........: 16 Mar 2018
Last Modified By .....:
Last Modified Date ...: 
Description ..........: This class holds services exposed for Value Prompter Score and is called by QUBY via SOUP
***************************/
global with sharing class VPScoreService {
    Webservice static vpScoreResponse getVPScore(vpScoreRequest req) {
        vpScoreResponse res; //= new vpScoreResponse() commented empty block statement 
        
        try {
            res=new vpScoreResponse(null);
            if(req!=null){
                if(req.oppNumber!=null){
                    res=getVPScore(String.valueOf(req.oppNumber));
                }else{
                    res=new vpScoreResponse('Error: Opportunity Number is sent as blank for Value Prompter score'); 
                }
            }else{
                res=new vpScoreResponse('Error: Invalid request to Value Prompter score'); 
            }
            
            
        }          
        
        catch (Exception e) {
            res = new vpScoreResponse('Exception: ' + e.getMessage());
        }
        return res;
    }
    
    global class vpScoreResponse {
        webservice String status;
        webservice String errorMessage;
        webservice Double vpScore;
        webservice Boolean isQualifiedProspect;
        
        /* global vpScoreResponse(){} commented empty block statement */
        
        global vpScoreResponse(string res) {
            this.status = 'Success';
            this.errorMessage = null;
            if (res != null) {
                this.status = 'Failure';
                this.errorMessage = res;
            } 			
            
        }
    }
    global class vpScoreRequest {        
        webservice Integer oppNumber;        
    }
    private static vpScoreResponse getVPScore(String oppNo){
        vpScoreResponse res=new vpScoreResponse(null);
        List<Value_Prompter__c> vp=[Select VPQ_Score__c, Is_Qualified_Prospect__c from Value_Prompter__c where Opportunity__r.Opportunity_Number__c=:oppNo];
                            system.debug('##'+vp+'$$'+vp.size());

        if(vp!=null && vp.size()>0){
            if(vp.get(0).VPQ_Score__c!=null){
                res.vpScore=vp.get(0).VPQ_Score__c;
                res.isQualifiedProspect=vp.get(0).Is_Qualified_Prospect__c;  
            }else{
                res=new vpScoreResponse('Error: Value Prompter score does not exist for this Opportunity');
            }
            
        }else{
            
            
                List <Opportunity> o=[Select id from Opportunity where Opportunity_Number__c=:oppNo];
                if(o!=null && o.size()>0){
                    res=new vpScoreResponse('Error: Value Prompter score does not exist for this Opportunity'); 
                }else{
                    res=new vpScoreResponse('Error: Either Opportunity does not exist with this Opportunity Number or Opportunity Numer is incorrect');
                    
                }
            
        }
        
        return res;
    }
}