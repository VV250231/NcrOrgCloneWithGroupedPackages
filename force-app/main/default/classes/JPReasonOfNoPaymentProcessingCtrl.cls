public class JPReasonOfNoPaymentProcessingCtrl {
    @auraEnabled
    public static ReasonCodeRequiredWrapper reasonRequireOrNot(String oppId) {

     
        //Boolean containSrvcCatgryHWSW = false;
        //Boolean containsSrvcCatgryHWM_SWM_TS = false;
        //Boolean isPymtProdAvailable = false;
        //Boolean paymentProcessingAvl = false;
        //Boolean noHWMSWMProdsReasonReq=false;
        //Boolean noPymtProdsReasonReq=false;
        Boolean containSrvcCatgryHWSW = false,containsSrvcCatgryHWM_SWM_TS = false,isPymtProdAvailable = false,paymentProcessingAvl = false, noHWMSWMProdsReasonReq=false,noPymtProdsReasonReq=false;
        NCR_Payments_Processing__mdt paymentProcessingProducts = new NCR_Payments_Processing__mdt();
        Set<String> ProductIdSet= new Set<String>();
   
       
        Set<String> PmntsRelatedPrdSet=new Set<String>();
        //No_Attach_Code_Profiles__c noAttchCodeProfiles = No_Attach_Code_Profiles__c.getValues('Record1');
        //Boolean allwAllPymntsPrfle = noAttchCodeProfiles.Allow_All_Payment_Profiles__c;
        //String pymntReasonProfiles = noAttchCodeProfiles.Included_Payments_Profile__c;
        
        
        
        All_profie_config__c noAttchCodeProfiles = All_profie_config__c.getValues('No Attach Codes Profiles');
        Boolean allwAllPymntsPrfle = noAttchCodeProfiles.Allow_All_Profile__c;
        String pymntReasonProfiles = noAttchCodeProfiles.Profile_Name__c;
        
        //String HWMSWMReasonProfiles = noAttchCodeProfiles.Include_HWM_SWM_Profiles__c;
        Set<String> paymntPrfileSet = new Set<String>();
        //Set<String> HWMSWMPrfileSet = new Set<String>();
        Boolean paymentProfileAvailable =false , HWMSWMProfileAvailable = false;
        //Boolean HWMSWMProfileAvailable = false;
        String currentProfileName = '';
        //System.debug('___allwAllPymntsPrfle__'+allwAllPymntsPrfle);
        if(!allwAllPymntsPrfle){
            //System.debug('heree');
          currentProfileName=[Select Id,Name from Profile where Id=:UserInfo.getProfileId()].Name.toUpperCase();  
            //System.debug('____currentProfileName___'+currentProfileName);
        }
        

        if(String.isNotBlank(pymntReasonProfiles)){
           
            if(!allwAllPymntsPrfle){
                for(String paymntPrfile : pymntReasonProfiles.split(',')){
                    paymntPrfileSet.add(paymntPrfile.trim().toUpperCase());
                    
                }
            }
            
                //System.debug('____paymntPrfileSet'+paymntPrfileSet+'___currentProfileName'+currentProfileName);
                if(allwAllPymntsPrfle || paymntPrfileSet.contains(currentProfileName)){
                    paymentProfileAvailable = true;
                   Prod_Reason_Required__c paymentsProducts = Prod_Reason_Required__c.getValues('Payments Related');
                     String paymentsRelatedProducts = paymentsProducts.Prod_Included__c;
                     Boolean isOn=paymentsProducts.On__c;
                    if(isOn){
                                 for(String prdcts :paymentsRelatedProducts.split(',')){
                                          PmntsRelatedPrdSet.add(prdcts.trim().toUpperCase());
                                 }    
                      }
                }
            }
        /* if(String.isNotBlank(HWMSWMReasonProfiles)){
           
                for(String HWMSWMPrfile : HWMSWMReasonProfiles.split(',')){
                    HWMSWMPrfileSet.add(HWMSWMPrfile.trim().toUpperCase());
                    
                }
              if(HWMSWMPrfileSet.contains(currentProfileName)){
                  HWMSWMProfileAvailable = true;
              }
         }*/

        
        
        
        
         paymentProcessingProducts =[select id,ProductId__c  from NCR_Payments_Processing__mdt limit 1];  
        if(String.isNotBlank(paymentProcessingProducts.Id)){
            if(paymentProcessingProducts.ProductId__c != null && String.isNotBlank(paymentProcessingProducts.ProductId__c)){
                for(String PId : paymentProcessingProducts.ProductId__c.split(',')){
                    ProductIdSet.add(PId.trim().toUpperCase());
                }
            }
        }
        
        
   
        for(OpportunityLineItem oli : [Select id,product2.Name,product2.Product_Category__c,product2.Service_Offer_Category__c, OpportunityId,TotalPrice  from OpportunityLineItem where OpportunityId =:oppId order by product2.name])
        {
             //New Code
            if(  oli.product2.Name!=null && !isPymtProdAvailable){
                 for(String prodName:PmntsRelatedPrdSet){
                    if(oli.product2.Name!=null &&oli.product2.Name.toUpperCase().contains(prodName)){
                       isPymtProdAvailable = true;
                    }    
                }
            }
           
            if(!containSrvcCatgryHWSW && oli.product2.Service_Offer_Category__c!=null && (oli.product2.Service_Offer_Category__c=='HW' ||  oli.product2.Service_Offer_Category__c=='SW') ){
                     containSrvcCatgryHWSW=true; 
                }
            if(oli.product2.Service_Offer_Category__c == 'HWM' || oli.product2.Service_Offer_Category__c == 'SWM' || oli.product2.Service_Offer_Category__c == 'TS' || oli.product2.Service_Offer_Category__c == 'PS'){
                    containsSrvcCatgryHWM_SWM_TS = true;
                }
            if(ProductIdSet.contains(oli.product2.Service_Offer_Category__c.toUpperCase())){
                     paymentProcessingAvl = true; 
            }
           
        }
            
            
       
       //System.debug('___paymentProfileAvailable'+paymentProfileAvailable+'___isPymtProdAvailable___'+isPymtProdAvailable+'__containSrvcCatgryHWSW___'+containSrvcCatgryHWSW);
        if(isPymtProdAvailable){ 
            if(paymentProfileAvailable && !containsSrvcCatgryHWM_SWM_TS && containSrvcCatgryHWSW){
                //System.debug('____lie 164');
             noHWMSWMProdsReasonReq = true;   
            }
             
            if(paymentProfileAvailable && !paymentProcessingAvl){
                //System.debug('____lie 169');
             noPymtProdsReasonReq = true;    
            }
               
        }
        if(containSrvcCatgryHWSW && !containsSrvcCatgryHWM_SWM_TS){          
                 //System.debug('____lie 176  ');
                noHWMSWMProdsReasonReq = true;
            }
            
        
        

        
       
            
        ReasonCodeRequiredWrapper rsnCode =new ReasonCodeRequiredWrapper(noHWMSWMProdsReasonReq,noPymtProdsReasonReq);
        return rsnCode;
    }
    
     @auraEnabled
    public static Boolean isContractDateAvl(String oppId) {
                Boolean isContractDateReq = false;
         for(Opportunity opp:[select Payments_Contract_End_Date__c from Opportunity where id=:oppId limit 1]){
            if(opp.Payments_Contract_End_Date__c == null){
                isContractDateReq = true;
            }            
        }
                return isContractDateReq;
        
    }
    

    public class ReasonCodeRequiredWrapper {
        @AuraEnabled public Boolean noHWMSWMProdsReasonReq{get;set;}
        @AuraEnabled public Boolean noPymtProdsReasonReq{get;set;}
        
        
        
        public ReasonCodeRequiredWrapper(Boolean noHWMSWMProdsReasonReq, Boolean noPymtProdsReasonReq) {
            this.noHWMSWMProdsReasonReq = noHWMSWMProdsReasonReq;
            this.noPymtProdsReasonReq = noPymtProdsReasonReq;
            //this.isContractDateReq = isContractDateReq;
            
        }
    }
}