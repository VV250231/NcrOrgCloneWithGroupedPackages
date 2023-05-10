public class USMDetailController {
    @AuraEnabled
    public static Boolean  checkUSMOpportunity(String opportunityId){
        Boolean USMOpportunity = false;
        //system.debug('opportunityId>>>>>>' + opportunityId);
        List<Opportunity> oppDetail = [Select Id, Name,Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, Account.Account_Country_Code__c, Account.Name  FROM Opportunity where id = : opportunityId]  ;
        
        if(oppDetail.size() > 0){
            List<opportunityLineItem> products = [Select id, product2.Service_Offer_Category__c  From opportunityLineItem where OpportunityId= : oppDetail[0].Id];
            
            if(products.size() > 0){
                for(opportunityLineItem oli : products){
                    if(oli.product2.Service_Offer_Category__c == 'HWM' || oli.product2.Service_Offer_Category__c == 'TS' || oli.product2.Service_Offer_Category__c == 'Managed Service'){
                        USMOpportunity = true;
                        break;
                    }
                }
            }
            
            
        }
        
        return USMOpportunity;
        
        
    }
    
     @AuraEnabled
   public static Boolean  checkClosedOpportunity(String opportunityId){
        Boolean isClosed = false;
        //system.debug('opportunityId>>>>>>' + opportunityId);
        List<Opportunity> oppDetail = [Select Id, Name,Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, isClosed, Account.Account_Country_Code__c  FROM Opportunity where id = : opportunityId]  ;
        
        if(oppDetail[0].isClosed){
            isClosed = true;
        }
        
        return isClosed;
        
        
    }
    
    @AuraEnabled
    public static Opportunity  checkEngagedService(String opportunityId){
        
        //system.debug('opportunityId>>>>>>' + opportunityId);
        List<Opportunity> oppDetail = [Select Id, USM_Opportunity_Number__c  FROM Opportunity where id = : opportunityId]  ;
        if(oppDetail.size() > 0){
            return oppDetail[0];
        }else
            return null;
        
        
    }
    
    
    @AuraEnabled
    public static USMDetailWrapper  getOpportunity(String opportunityId){
        //system.debug('opportunityId>>>>>>' + opportunityId);
        List<Opportunity> oppDetail = [Select Id, Name,Opportunity_Number__c, Account_LOB__c, StageName, ForecastCategory, Services_Sales_Consultant__r.Name,Services_Sales_Consultant__r.Id, Account.Account_Country_Code__c, Account.Name  FROM Opportunity where id = : opportunityId]  ;
        
        if(oppDetail.size() > 0){
            List<opportunityLineItem> products = [Select id, product2.Service_Offer_Category__c  From opportunityLineItem where OpportunityId= : oppDetail[0].Id];
            USMDetailWrapper usm =  new USMDetailWrapper();
            Opportunity opp = oppDetail[0];
            usm.opp = opp;
            if(opp.Account_LOB__c == 'T&T'){
                usm.isLOB = true;
            }
            
            if(products.size() > 0){
                for(opportunityLineItem oli : products){
                    if(oli.product2.Service_Offer_Category__c == 'Managed Service'){
                        usm.isManagedService = true;
                        break;
                    }
                }
            }
            
            return usm;
        }
        else
            return null;
        
        
    }
    @AuraEnabled
    public static String  getUserDetail(){
        User u = [Select Id, Quicklook_id__c FROM User where id = : UserInfo.getUserId()]  ;
        system.debug('###'+u.Quicklook_ID__c);
        return u.quicklook_id__c;
    }
    
    @AuraEnabled
    public static string saveUSMOpportunity(USM_Opportunity_Detail__c usmOpportunity){
       /* system.debug('usmOpportunity>>>>>>' + usmOpportunity);
        if(usmOpportunity != null){
            try{
                upsert usmOpportunity;
            }catch(Exception ex){
                system.debug('Exception>>>' + ex.getMessage());
                return ex.getMessage();
            }
            return 'sucess';
        }else
            return 'null opportunity';*/
        return null;
    }
    
    
    @AuraEnabled
    public static string callUSMService(Opportunity opp, USM_Opportunity_Detail__c usmopp, String quicklook){
        String Message='ERROR occured while synching, Please contact Administrator';  
        //system.debug('@@@@ SSC'+opp.Service_Sales_consultant__c);
        Message=usmCallHandler.getInstance().synchUSM(opp, usmopp, quicklook);
        return Message;
    }
    
    @AuraEnabled
    public static string setServiceSales(Opportunity opp){
        String msg='Success'; 
        
        try{
            //if(!opp.Service_Sales_Consultant__c.contains('005')){
             //   return msg;
            //}
            Opportunity opp1=new Opportunity(id=opp.id, Services_Sales_Consultant__c=opp.Services_Sales_Consultant__c);
            update opp1;
        }catch(Exception e){
            String errMsg;
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                errMsg= e.getMessage().split('FIELD_CUSTOM_VALIDATION_EXCEPTION,')[1];
            }else{
               errMsg= e.getMessage();
            }
            msg=' ERROR:Opportunity have issues to address, correct issues and Engage again. Issue detail:<br/> '+errMsg;
            
        }
        //system.debug('!!!'+msg);
        return msg;
    }
    @AuraEnabled
    public static string callUSM_LinkService(String oppid, String usmoppid){
        String Message='ERROR occuered while synching, Please contact Administrator';        
        Opportunity opp=[Select Opportunity_Number__c from Opportunity where id=:oppid]; 
        Message=usmCallHandler.getInstance().linkUSM(opp.Opportunity_Number__c, usmoppid);
        //system.debug('oppid'+opp.Opportunity_Number__c+'usmopp'+usmoppid);
        if(!Message.toUpperCase().contains('ERROR')|| Test.isRunningTest() ){
            try{
                Opportunity o=new Opportunity(id=oppId, usm_Opportunity_Number__c=usmoppid);
                update o; 
            }catch(Exception e){
                Message='ERROR: There was issue in Saving NSC Opportunity after Engagement, Save and Engage again'+e.getMessage(); 
            }
            
        }
        return Message;
    }
}