/*
* Created by   : Saagar Kinja
* Created Date : 28nd August 2018
* This is helper class for Lead Trigger
* 
* 1 - sub_dispatcher : this method passes manages the order of execution of logic. 
* 2 - submit_for_approval : If Approval Request status is submitted, then this logic will submit record for approval cycle.
*
*/
public with sharing class CAP_Helper_Class {
    
    public static void sub_dispatcher(List<CAP_Form__c> triggernewlist,boolean ifinsert,boolean ifupdate){
       
        List<CAP_Form__c> cap_submit_for_approval = new List<CAP_Form__c>();
       
        if(ifinsert){
            for(CAP_Form__c cap : triggernewlist){
                if(cap.ApprovalRequestfront__c=='Submitted'){
                    cap_submit_for_approval.add(cap);
                }
            }
        }
        
        if(ifupdate){
            for(CAP_Form__c cap : triggernewlist){
                if(cap.ApprovalRequestfront__c=='Submitted'){
                    cap_submit_for_approval.add(cap);
                }
            }
        }
        if(cap_submit_for_approval.size()>0){
            submit_for_approval(cap_submit_for_approval);
        }
    }
    
    public static void submit_for_approval(List<CAP_Form__c> cap_submit_for_approval){
        List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
        
        for(Cap_Form__c cap : cap_submit_for_approval){
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval');
            req1.setObjectId(cap.id); 
            requests.add(req1);
            
          //  Approval.ProcessResult result = Approval.process(req1);
        }
        Approval.ProcessResult[] processResults = null;
        processResults = Approval.process(requests, true);
        
    }
    
}