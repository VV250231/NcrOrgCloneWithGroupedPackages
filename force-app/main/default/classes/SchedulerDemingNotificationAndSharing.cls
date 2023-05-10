public class SchedulerDemingNotificationAndSharing implements Schedulable {
    
    @ReadOnly
    public void execute(SchedulableContext SC)
    {  
        if(DemingValidateExecution.ValidateNotificationSwitch()){
        Set<String> MCNSet= new Set<String>(); 
        Set<String> IndustrySet = new Set<String>(); 
        Set<String> ReasonCodeSet = new Set<String>();  
        Boolean ValidateMCN=false;
        Boolean ValidateIndustry=false;
        Boolean ValidateReasonCode=false;
        Set<String> IdSetOfUser = new Set<String>();
        Set<String> CustomerRequestSet = new Set<String>();
        Set<String> NonCustomerRequestSet = new Set<String>();
      
               // For Reason Code // 
                
                ReasonCode__mdt ReasonCodeMetaDataObj = new ReasonCode__mdt();
                ReasonCodeMetaDataObj =[select id,Customer_Requested_List__c,Non_Customer_Request_List__c  from ReasonCode__mdt limit 1];
                
                if(String.isNotBlank(ReasonCodeMetaDataObj.id)){
                        
                        if(ReasonCodeMetaDataObj.Customer_Requested_List__c != null && String.isNotBlank(ReasonCodeMetaDataObj.Customer_Requested_List__c)){
                            for(String CustomerRequestString : ReasonCodeMetaDataObj.Customer_Requested_List__c.split(',')){
                                CustomerRequestSet.add(CustomerRequestString.trim());
                            }
                        }
                        
                        if(ReasonCodeMetaDataObj.Non_Customer_Request_List__c != null && String.isNotBlank(ReasonCodeMetaDataObj.Non_Customer_Request_List__c)){
                            for(String NonCustomerRequestString : ReasonCodeMetaDataObj.Non_Customer_Request_List__c.split(',')){
                                NonCustomerRequestSet.add(NonCustomerRequestString.trim());
                            }
                        }
                    
                }

                
                // End of Reason Code//
      
               //Swithc for MCN
                MCN_Switch__mdt MCNObj = new MCN_Switch__mdt();
                MCNObj =[select id,MCN_List__c,MCN_List_New__c,Turn_On__c from MCN_Switch__mdt limit 1];
                  
                //Switch for Industry
                 Industry_Switch__mdt IndustryObj= new Industry_Switch__mdt(); 
                 IndustryObj =[select id,Industry_List__c,Turn_On__c from Industry_Switch__mdt limit 1];
                
                
                //Switch for Region Code
                ReasonCodeSwitch__mdt ReasonCodeObj = new ReasonCodeSwitch__mdt();
                ReasonCodeObj = [select id,Reason_Code_List__c,Turn_On__c from ReasonCodeSwitch__mdt limit 1];
                
                Set<String> Userset= new Set<String>();
                
                if((String.isNotBlank(MCNObj.id)) && (MCNObj.Turn_On__c)){
                    ValidateMCN=true;
                    if(MCNObj.MCN_List_New__c != null && String.isNotBlank(MCNObj.MCN_List_New__c)){
                     
                         for(String McnString :MCNObj.MCN_List_New__c.split(',')){
                             MCNSet.add(McnString.replaceAll( '\\s+', ''));
                         }
                    }
                    
                    if(MCNSet.size()>0){
                        for(Deming__c DemObj : [select EditShareWithUser__c from Deming__c where Include_In_Process__c = false and Customer_No__c IN:MCNSet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c = '') and EditShareWithUser__c != '']){
                            if(!Userset.contains(DemObj.EditShareWithUser__c)){
                                Userset.add(DemObj.EditShareWithUser__c);
                            }
                        }
                    }
                    
                }
                
                if((String.isNotBlank(IndustryObj.id)) && (IndustryObj.Turn_On__c)){ 
                    ValidateIndustry=true;
                    if(IndustryObj.Industry_List__c != null && String.isNotBlank(IndustryObj.Industry_List__c)){
                        for(String IndustryString : IndustryObj.Industry_List__c.split(',')){
                             IndustrySet.add(IndustryString.trim()); 
                        }
                    }
                    
                    if(IndustrySet.size()>0){
                        for(Deming__c DemObj : [select EditShareWithUser__c from Deming__c where Include_In_Process__c = false and Customer_Industry__c IN:IndustrySet  AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c = '')  and EditShareWithUser__c != '']){
                            if(!Userset.contains(DemObj.EditShareWithUser__c)){
                                Userset.add(DemObj.EditShareWithUser__c);
                            }
                        }
                    }
                } 
                 
                if((String.isNotBlank(ReasonCodeObj.Id)) && (ReasonCodeObj.Turn_On__c)){
                    ValidateReasonCode=true;
                    if(ReasonCodeObj.Reason_Code_List__c != null &&  String.isNotBlank(ReasonCodeObj.Reason_Code_List__c)){
                        for(String ReasonCodeString :ReasonCodeObj.Reason_Code_List__c.split(',')){ 
                             ReasonCodeSet.add(ReasonCodeString.trim());
                        }
                    }
                    
                    if(ReasonCodeSet.size()>0){
                        for(Deming__c DemObj : [select EditShareWithUser__c from Deming__c where Include_In_Process__c = false and Region__c IN:ReasonCodeSet AND (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c = '') and EditShareWithUser__c != '']){
                            if(!Userset.contains(DemObj.EditShareWithUser__c)){
                                Userset.add(DemObj.EditShareWithUser__c);
                            }
                        }
                    }
                }

                
                 system.debug('1'+MCNObj.Turn_On__c);   
                 system.debug('2'+IndustryObj.Turn_On__c);
                 system.debug('2'+ReasonCodeObj.Turn_On__c);                 
                 if((String.isNotBlank(MCNObj.id)) && (MCNObj.Turn_On__c == false) && (String.isNotBlank(IndustryObj.id)) && (IndustryObj.Turn_On__c == false) && (String.isNotBlank(ReasonCodeObj.Id)) && (ReasonCodeObj.Turn_On__c == false)){
                     system.debug('>>>>>>Enter in codition');
                     for(Deming__c DemObj : [select EditShareWithUser__c from Deming__c where Include_In_Process__c = false and (Reason_Code__c IN:CustomerRequestSet OR Reason_Code__c IN:NonCustomerRequestSet OR Reason_Code__c = '') and EditShareWithUser__c != '']){
                            if(!Userset.contains(DemObj.EditShareWithUser__c)){
                                Userset.add(DemObj.EditShareWithUser__c);
                                system.debug('DemObj.EditShareWithUser__c'+DemObj.EditShareWithUser__c);
                            }
                        }
                 }
                 
                 
                system.debug('Size'+Userset.size());
                system.debug('validate'+ DemingValidateExecution.ValidateNotificationSwitch());
               if((Userset.size()>0)  && (DemingValidateExecution.ValidateNotificationSwitch())){
                  DemingNotificationAndSharing ObjDmgNfcnNhShrng = new DemingNotificationAndSharing(Userset,ValidateMCN,ValidateIndustry,ValidateReasonCode,MCNSet,IndustrySet,ReasonCodeSet,CustomerRequestSet,NonCustomerRequestSet);  
                  Database.executeBatch(ObjDmgNfcnNhShrng); 
                  system.debug('scheduled');  
               }
        } 
        
    }  
}