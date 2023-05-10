/**************************************
  Author ...............: Sanjay Pandit
  Date Created .........: 22-Sep-2020
  Last Modified By .....:
  Last Modified Date ...: 
  Description ..........: SC2015_AGL-5787, Trigger Consolidation  
***************************************/
public with sharing class ZuoraQuoteRatePlanChargeTriggerHelper {
    ZuoraChargeUtil chargeUtil = new ZuoraChargeUtil(); 
    
   /**CalcACVandAddOLIs on Before Update**/
    public void onBeforeUpdateCalcACVandAddOLIs(List<zqu__QuoteRatePlanCharge__c> QRPClistNew, Map<Id, zqu__QuoteRatePlanCharge__c> mapOldQRPC, Map<Id, zqu__QuoteRatePlanCharge__c> mapNewQRPC)
    {
            Map<Id, Boolean> zChargeProcessedMap = CheckRecursive.getProcessedChargeMap(new Set<Id>(mapNewQRPC.keySet()));
            List<zqu__QuoteRatePlanCharge__c> updateChargeList = new List<zqu__QuoteRatePlanCharge__c>();
            
            for (zqu__QuoteRatePlanCharge__c zCharge : QRPClistNew) {
                zqu__QuoteRatePlanCharge__c oldCharge = mapOldQRPC.get(zCharge.Id);
                Boolean isZChargeProcessed = zChargeProcessedMap.get(zCharge.Id);
                System.debug('isZChargeProcessed ::' + isZChargeProcessed );
                
                if((isZChargeProcessed != null) && (isZChargeProcessed == false)) { // if charge not already processed
                    if ((zCharge.zqu__ChargeType__c != oldCharge.zqu__ChargeType__c) || (zCharge.zqu__Period__c != oldCharge.zqu__Period__c)
                            || (zCharge.zqu__EffectivePrice__c != oldCharge.zqu__EffectivePrice__c)) { // check for minimum charge code also
                            
                        updateChargeList.add(zCharge);       
                    } 
                } 
            }
            if (!updateChargeList.isEmpty())  
            {
                chargeUtil.populateChargeACVBefore(updateChargeList);
            }
     }
    
    /**CalcACVandAddOLIs on Before Insert**/
    public void onBeforeInsertCalcACVandAddOLIs(List<zqu__QuoteRatePlanCharge__c> QRPClistNew)
    {   	
        chargeUtil.populateChargeACVBefore(QRPClistNew);    
    }
    
    /**calcChargeACV**/
    public void onAfterInsertCalcACVandAddOLIs(Map<Id, zqu__QuoteRatePlanCharge__c> mapNewQRPC){
        chargeUtil.calcChargeACV(mapNewQRPC.keySet(), true); 
    }
    
    public void onAfterUpdateCalcACVandAddOLIs(List<zqu__QuoteRatePlanCharge__c> QRPClistNew, Map<Id, zqu__QuoteRatePlanCharge__c> mapOldQRPC, Map<Id, zqu__QuoteRatePlanCharge__c> mapNewQRPC)
    {
        Set<Id> chargeIds = new Set<Id>();
        Map<Id, Boolean> zChargeProcessedMap = CheckRecursive.getProcessedChargeMap(new Set<Id>(mapNewQRPC.keySet()));
        
        for(zqu__QuoteRatePlanCharge__c zCharge : QRPClistNew) {
            zqu__QuoteRatePlanCharge__c oldCharge = mapOldQRPC.get(zCharge.Id);
            Boolean isZChargeProcessed = zChargeProcessedMap.get(zCharge.Id);
            System.debug('isZChargeProcessed ::' + isZChargeProcessed );
            
            if((isZChargeProcessed != null) && (isZChargeProcessed == false)) { // if charge not already processed 
                if ((zCharge.zqu__ChargeType__c != oldCharge.zqu__ChargeType__c) || (zCharge.zqu__Period__c != oldCharge.zqu__Period__c)
                    || (zCharge.zqu__EffectivePrice__c != oldCharge.zqu__EffectivePrice__c)) {
                        
                        chargeIds.add(zCharge.Id);
                    }
            }
        }
        
        if (!chargeIds.isEmpty())  {
            chargeUtil.calcChargeACV(chargeIds, false);
            CheckRecursive.addChargeToProcessedSet(chargeIds);
        }
    }
    
    public void onAfterDeleteCalcACVandAddOLIs(List<zqu__QuoteRatePlanCharge__c> QRPClistOld){
        Set<Id> QRPIds = new Set<Id>();
        for (zqu__QuoteRatePlanCharge__c zCharge : QRPClistOld) {
            if(zCharge.zqu__QuoteRatePlan__c != null) {
                QRPIds.add(zCharge.zqu__QuoteRatePlan__c);    
            }            
        }
        if (!QRPIds.isEmpty()) {
            chargeUtil.calcACVFromRatePlan(QRPIds);
        }
    }

    public void onAfterUnDeleteCalcACVandAddOLIs(Map<Id, zqu__QuoteRatePlanCharge__c> mapNewQRPC){
        chargeUtil.calcChargeACV(mapNewQRPC.keySet() , true);  
    }
    
    
    /*********
     * defaultChannelOfficeField
     * 
     * **********/
    Set<String> prdRatePlanChargeZuoraIdSet = new Set<String>();
    Set<ID> quoteRatePlanSet = new Set<ID>();    
    Set<String> zSRPCSet = new Set<String>();    
    
    List<zqu__QuoteRatePlan__c> qrpList = new List<zqu__QuoteRatePlan__c>();
    List<Zuora__SubscriptionProductCharge__c> spcList = new List<Zuora__SubscriptionProductCharge__c>();

    
    Map<ID, ID> QRPOppOwnerIdMap = new Map<ID, ID>();
    Map<ID, ID> QRPOppChannelOffMap = new Map<ID, ID>();
    Map<ID, String> qRPOppChannelOffNameMap = new Map<ID, String>();
    Map<ID,Opportunity> qRPOppNameMap = new Map<ID,Opportunity>();
    
    Map<String, zqu__ProductRatePlanCharge__c> prdRatePlanChgMap = new Map<String, zqu__ProductRatePlanCharge__c>();
    Map<String, Zuora__SubscriptionProductCharge__c> spcMap = new Map<String, Zuora__SubscriptionProductCharge__c>();
    Map<String,String> mapPRPCandBillingTiming = new Map<String,string>(); //map of product rate plan charge and billing timing
    Map<String,String> mapPRPCandMinimumChargeCode = new Map<String,string>();
    Map<String,String> mapPRPCandProductUsageMetric  = new Map<String,string>();
    // below vars are used with qpId on Charge logic
    list<Quote_Product__c> QPList = new list<Quote_Product__c>();
    list<zqu__QuoteChargeSummary__c> qcsummaryList = new list<zqu__QuoteChargeSummary__c>();
    Map<string, List<zqu__QuoteChargeSummary__c> > SKUWithListOfChargesMap  = new map <string,list<zqu__QuoteChargeSummary__c>>();
    Map<String,String> UniqWithQPID = new Map<String,String>();
    Map<String,String> SKUWithQPID = new Map<String,String>();
    Map<String,String> QRPCWithUniq = new Map<String,String>();

    
    public void onBeforedefaultChannelOfficeField(List<zqu__QuoteRatePlanCharge__c> QRPClistNew)
    {
        
        	for (zqu__QuoteRatePlanCharge__c z : QRPClistNew) {
            //Story 4774
            if(z.ExistingProduct__c == 'Yes' && z.AmendmentType__c != 'UpdateProduct'){
                z.ExcludefromNewBookingACV__c = 'Yes';
            }
            else{
                z.ExcludefromNewBookingACV__c = 'No'; 
            }
            if(z.zqu__QuoteRatePlan__c != NULL) {
                quoteRatePlanSet.add(z.zqu__QuoteRatePlan__c);
            }
            if(z.zqu__ProductRatePlanChargeZuoraId__c != NULL) {
                prdRatePlanChargeZuoraIdSet.add(z.zqu__ProductRatePlanChargeZuoraId__c);
            }
         
                if(!Test.isRunningTest()){     
                   if(z.AmendmentType__c.equalsIgnoreCase('UpdateProduct') && String.isNotBlank(z.zqu__SubscriptionRatePlanChargeZuoraId__c)){
                        zSRPCSet.add(z.zqu__SubscriptionRatePlanChargeZuoraId__c);
                   }
                }
        }
            
        	if(!prdRatePlanChargeZuoraIdSet.isEmpty()) {
            List<zqu__ProductRatePlanCharge__c> prdRatePlanChgList = [SELECT zqu__ZuoraId__c ,Cost__c, PartnerCommission__c, SalesChannelPartnerCommissionPercent__c,
                                                                      SupportChannelPartnerCommissionPercent__c,zqu__BillingTiming__c,ProductUsageMetric__c,MinimumChargeCode__c
                                                                      FROM zqu__ProductRatePlanCharge__c WHERE zqu__ZuoraId__c IN :prdRatePlanChargeZuoraIdSet];
            for (zqu__ProductRatePlanCharge__c prpc :prdRatePlanChgList) {
                prdRatePlanChgMap.put(prpc.zqu__ZuoraId__c, prpc);
                mapPRPCandBillingTiming.put(prpc.id,prpc.zqu__BillingTiming__c);
                mapPRPCandMinimumChargeCode.put(prpc.id,prpc.MinimumChargeCode__c);
                mapPRPCandProductUsageMetric.put(prpc.id,prpc.ProductUsageMetric__c);
            }
        }
        
        	if(!zSRPCSet.isEmpty()){
          for (Zuora__SubscriptionProductCharge__c spc :[SELECT id,FinalBookingACV__c,SupportChannelPartner__c, ChannelPartner__c,SalesChannelPartnerCommissionPercent__c, SupportChannelPartnerCommissionPercent__c,
                           WholesalerCommissionPercent__c, Zuora__Zuora_Id__c, Wholesaler__c,MinimumChargeCode__c, ProductUsageMetric__c FROM Zuora__SubscriptionProductCharge__c WHERE Zuora__Zuora_Id__c in :zSRPCSet]) {
            spcMap.put(spc.Zuora__Zuora_Id__c, spc);
            }
        }
        
        	if(!quoteRatePlanSet.isEmpty()) {
            qrpList = [SELECT Id, zqu__Quote__c, zqu__AmendmentType__c, zqu__Quote__r.zqu__Opportunity__c, zqu__Quote__r.zqu__Opportunity__r.OwnerId,zqu__Quote__r.zqu__Opportunity__r.Channel_Office__c,
                       zqu__Quote__r.zqu__Opportunity__r.ChannelOfficeName__c ,zqu__Quote__r.zqu__Opportunity__r.Account.Subscription_Group__c,zqu__Quote__r.zqu__Opportunity__r.Opportunity_Classification__c                   
                       FROM zqu__QuoteRatePlan__c WHERE id IN :quoteRatePlanSet];
                //below query used for qpId on charge logic
                QPList = [Select id,Quote_Rate_Plan__c,SKUandPRPCID__c,ProductId__c,PRPCImplementationValue__c from Quote_Product__c WHERE Quote_Rate_Plan__c IN :quoteRatePlanSet];
                if(QPList.size() > 0){
                    qcsummaryList  =[select id,zqu__QuoteRatePlanCharge__c,zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c,zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c,
                                     zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c,ImplementationQuoteProductCreation__c from zqu__QuoteChargeSummary__c where zqu__QuoteRatePlan__c in : quoteRatePlanSet]; 
                    
                }

        } 
                   
        if(!qrpList.isEmpty()) {
            for(zqu__QuoteRatePlan__c qrp : qrpList)  {
                if(qrp.zqu__Quote__c != NULL && qrp.zqu__Quote__r.zqu__Opportunity__c != NULL) {
                    qRPOppNameMap.put(qrp.Id,qrp.zqu__Quote__r.zqu__Opportunity__r);
                    if(qrp.zqu__Quote__r.zqu__Opportunity__r.OwnerId != NULL) {
                        QRPOppOwnerIdMap.put(qrp.Id, qrp.zqu__Quote__r.zqu__Opportunity__r.OwnerId);
                    }                        
                    if(qrp.zqu__Quote__r.zqu__Opportunity__r.Channel_Office__c != NULL) {
                        QRPOppChannelOffMap.put(qrp.Id, qrp.zqu__Quote__r.zqu__Opportunity__r.Channel_Office__c);
                        qRPOppChannelOffNameMap.put(qrp.Id, qrp.zqu__Quote__r.zqu__Opportunity__r.ChannelOfficeName__c);
                    }  
                }   
            }                                                                              
        }
        //----------------------------------------Start of qpId On Charges logic------------------------------------------
        system.debug('Check1');
        if(QPList.size() > 0) {
            for(Quote_Product__c qp : QPList)  {
                UniqWithQPID.put(String.valueOf(qp.SKUandPRPCID__c), String.valueOf(qp.Id));
            }
            if(qcsummaryList.size() > 0){
                for(zqu__QuoteChargeSummary__c qcs : qcsummaryList){
                    if(qcs.zqu__QuoteRatePlanCharge__c != null){
                        if(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c != null && qcs.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c != null){
                            QRPCWithUniq.put(String.valueOf(qcs.zqu__QuoteRatePlanCharge__c), String.valueOf(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qcs.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c)+string.Valueof(qcs.id)+String.valueOf(0));
                        }
                    }
                    if(SKUWithListOfChargesMap .containsKey(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) && SKUWithListOfChargesMap .get(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c) != null) {
                        List<zqu__QuoteChargeSummary__c> lst_chargesSum = SKUWithListOfChargesMap .get(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
                        lst_chargesSum.add(qcs );
                        SKUWithListOfChargesMap .put(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c,lst_chargesSum); 
                    } else {
                        SKUWithListOfChargesMap .put(qcs.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, new List<zqu__QuoteChargeSummary__c> {qcs });
                    }
                }
            }
			for(string sku : SKUWithListOfChargesMap.keySet()){
                boolean skuProduct = false;
                String UniqKey = '';
                for(zqu__QuoteChargeSummary__c qcsListItem : SKUWithListOfChargesMap .get(sku)){
                    if(qcsListItem.ImplementationQuoteProductCreation__c  == '1 Quote Product per quantity'){
                        if(!UniqWithQPID.containsKey(UniqKey)){
                            UniqKey = String.valueOf(qcsListItem.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qcsListItem.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c)+string.Valueof(qcsListItem.id)+String.valueOf(0);
                        }
                        
                    }
                    if(qcsListItem.ImplementationQuoteProductCreation__c == '1 Quote Product per charge'){
                        if(!UniqWithQPID.containsKey(UniqKey)){
                            UniqKey = String.valueOf(qcsListItem.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qcsListItem.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c)+string.Valueof(qcsListItem.id)+String.valueOf(0);
                        }
                    }
                    if(qcsListItem.ImplementationQuoteProductCreation__c == '1 Quote Product for SKU'){
                        skuProduct = true;
                        if(!UniqWithQPID.containsKey(UniqKey)){
                            UniqKey = String.valueOf(qcsListItem.zqu__QuoteRatePlan__r.zqu__ProductRatePlan__r.zqu__ZProduct__c)+String.valueOf(qcsListItem.zqu__QuoteRatePlanCharge__r.zqu__ProductRatePlanCharge__c)+string.Valueof(qcsListItem.id)+String.valueOf(0);
                        }
                    }
                }
                if(skuProduct == true){
                    if(UniqWithQPID.containsKey(UniqKey)){
                        SKUWithQPID.put(sku, UniqWithQPID.get(UniqKey));
                    }
                }
            }
        }
        //----------------------------------------end of qpId On Charges logic------------------------------------------
    }
    
    public void onBeforeInsertdefaultChannelOfficeField(List<zqu__QuoteRatePlanCharge__c> QRPClistNew)
    {
        //Calling first onBefore Function then isInsert
        onBeforedefaultChannelOfficeField(QRPClistNew);
        
        //Calling second step
        for(zqu__QuoteRatePlanCharge__c qrpc : QRPClistNew) {
            
            zqu__ProductRatePlanCharge__c prpc = prdRatePlanChgMap.get(qrpc.zqu__ProductRatePlanChargeZuoraId__c);
            Zuora__SubscriptionProductCharge__c spc = String.isNotBlank(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c) && spcMap.containsKey(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c)?spcMap.get(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c):null;
            String OppOwnerId = QRPOppOwnerIdMap.get(qrpc.zqu__QuoteRatePlan__c);
            String OppChannelOffIfd = QRPOppChannelOffMap.get(qrpc.zqu__QuoteRatePlan__c);
            String OppChannelOffName = qRPOppChannelOffNameMap.get(qrpc.zqu__QuoteRatePlan__c);
           
            //for story SC2015_AGL-4666
            if(spc != null && String.isNotBlank(spc.FinalBookingACV__c)){
                qrpc.PreviousFinalBookingACV__c = spc.FinalBookingACV__c ;
            }
            else{qrpc.PreviousFinalBookingACV__c='0';}
            
            // for story SC2015_AGL-4348 1st sept 17'
            if(mapPRPCandBillingTiming != null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandBillingTiming.get(qrpc.zqu__ProductRatePlanCharge__c)))
            {
                qrpc.zqu__BillingTiming__c = mapPRPCandBillingTiming.get(qrpc.zqu__ProductRatePlanCharge__c) ;
            }
            
            // for story SC2018_AGL-4535 added on 02/19/2018'
            if(DIQuoteUtil.isDigitalInsight(qRPOppNameMap.get(qrpc.zqu__QuoteRatePlan__c))){
                if(spc == Null){
                    if(mapPRPCandMinimumChargeCode!= null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandMinimumChargeCode.get(qrpc.zqu__ProductRatePlanCharge__c)))
                    {
                        qrpc.MinimumChargeCode__c = mapPRPCandMinimumChargeCode.get(qrpc.zqu__ProductRatePlanCharge__c) ;
                    }
                    if(mapPRPCandProductUsageMetric!= null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandProductUsageMetric.get(qrpc.zqu__ProductRatePlanCharge__c)))
                    {
                        qrpc.ProductUsageMetric__c = mapPRPCandProductUsageMetric.get(qrpc.zqu__ProductRatePlanCharge__c) ;
                    }
                }else{
                    if(String.isNotBlank(spc.MinimumChargeCode__c) )
                    {
                        qrpc.MinimumChargeCode__c = spc.MinimumChargeCode__c ;
                    }
                    if(String.isNotBlank(spc.ProductUsageMetric__c)) 
                    {
                        qrpc.ProductUsageMetric__c = spc.ProductUsageMetric__c;
                    }
                }
            }
            
            if(OppOwnerId != NULL) {
                qrpc.Salesperson_Lkp__c = OppOwnerId;     
            }
            
            if(OppChannelOffIfd != NULL) {
                qrpc.ChannelPartner_Lkp__c = OppChannelOffIfd;
                qrpc.SupportChannelPartnerLkp__c = OppChannelOffIfd;
            }
            
            if(String.isEmpty(qrpc.ChannelPartner__c)) {
                qrpc.ChannelPartner__c = OppChannelOffName;
                if(spc != NULL){
                    if(String.isEmpty(OppChannelOffName) && !String.isEmpty(spc.ChannelPartner__c)){
                        qrpc.ChannelPartner__c = spc.ChannelPartner__c;
                    } 
                }
            }
            
            if(String.isEmpty(qrpc.SupportChannelPartner__c)) {
                qrpc.SupportChannelPartner__c = OppChannelOffName;
                if(spc != NULL){
                    if(String.isEmpty(OppChannelOffName) && !String.isEmpty(spc.SupportChannelPartner__c)){
                        qrpc.SupportChannelPartner__c = spc.SupportChannelPartner__c;
                    }
                }
            }
                        
            if(String.isEmpty(qrpc.Wholesaler__c)) {
                qrpc.Wholesaler__c = qrpc.AccountPrimaryWholesalerCooperative__c;
                if(spc != NULL){
                    if(String.isEmpty(qrpc.Wholesaler__c) && !String.isEmpty(spc.Wholesaler__c)){
                        qrpc.Wholesaler__c = spc.Wholesaler__c;
                    }
                }
            }
            
            if(String.isEmpty(qrpc.WholesalerCommissionPercent__c)) {
                qrpc.WholesalerCommissionPercent__c = '0';
            }
            
            if(prpc != NULL) {
                qrpc.Cost__c = prpc.Cost__c;
                qrpc.PartnerCommission__c  =  prpc.PartnerCommission__c;                   
            }
               
            if(spc != NULL){
                if(String.isEmpty(qrpc.SalesChannelPartnerCommissionPercent__c) && spc != NULL){                       
                    if(!String.isEmpty(spc.SalesChannelPartnerCommissionPercent__c)){
                        qrpc.SalesChannelPartnerCommissionPercent__c = spc.SalesChannelPartnerCommissionPercent__c;
                    } 
                }
            }
            
            if(prpc != NULL){
                if(String.isEmpty(qrpc.SalesChannelPartnerCommissionPercent__c) && prpc != NULL){
                    if(!String.isEmpty(prpc.SalesChannelPartnerCommissionPercent__c)){
                        qrpc.SalesChannelPartnerCommissionPercent__c = prpc.SalesChannelPartnerCommissionPercent__c;
                    } 
                }
            }
            
            if(spc != NULL){
                if(String.isEmpty(qrpc.SupportChannelPartnerCommissionPercent__c) && spc != NULL){
                    if(!String.isEmpty(spc.SupportChannelPartnerCommissionPercent__c)){
                        qrpc.SupportChannelPartnerCommissionPercent__c = spc.SupportChannelPartnerCommissionPercent__c;
                    } 
                }
            }
            
            if(prpc != NULL){
                if(String.isEmpty(qrpc.SupportChannelPartnerCommissionPercent__c) && prpc != NULL){
                    if(!String.isEmpty(prpc.SupportChannelPartnerCommissionPercent__c)){
                        qrpc.SupportChannelPartnerCommissionPercent__c = prpc.SupportChannelPartnerCommissionPercent__c;
                    } 
                }
            }
            
        }
    }
    
    public void onBeforeUpdatedefaultChannelOfficeField(List<zqu__QuoteRatePlanCharge__c> QRPClistNew)
    {
        //Calling first onBefore Function then isInsert
        onBeforedefaultChannelOfficeField(QRPClistNew);
        integer i=1;
        //Calling second step
        for(zqu__QuoteRatePlanCharge__c qrpc : QRPClistNew) {
            Zuora__SubscriptionProductCharge__c spc = String.isNotBlank(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c) && spcMap.containsKey(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c)?spcMap.get(qrpc.zqu__SubscriptionRatePlanChargeZuoraId__c):null;
            //populating quote product id to send to zuora
            system.debug('Check1');
            if(!UniqWithQPID.isEmpty() || !SKUWithQPID.isEmpty()){
                if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product for SKU'){
                    if(SKUWithQPID.containsKey(qrpc.PID_SKU__c)){
                        qrpc.QuoteProductId__c = SKUWithQPID.get(qrpc.PID_SKU__c);
                    }
                }else if(qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per charge' || qrpc.ImplementationQuoteProductCreation__c == '1 Quote Product per quantity'){
                    if(QRPCWithUniq.containsKey(qrpc.id)){
                        if(UniqWithQPID.containsKey(QRPCWithUniq.get(qrpc.id))){
                            qrpc.QuoteProductId__c = UniqWithQPID.get(QRPCWithUniq.get(qrpc.id));
                        }
                    }
                }
            }
        
            //for story SC2015_AGL-4666
            if(spc != null  && String.isNotBlank(spc.FinalBookingACV__c)){
               qrpc.PreviousFinalBookingACV__c = spc.FinalBookingACV__c ;
            }
            else{qrpc.PreviousFinalBookingACV__c='0';}
            
            // for story SC2015_AGL-4348  1st sept 17'
            if(mapPRPCandBillingTiming != null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandBillingTiming.get(qrpc.zqu__ProductRatePlanCharge__c)))
            {
                qrpc.zqu__BillingTiming__c = mapPRPCandBillingTiming.get(qrpc.zqu__ProductRatePlanCharge__c) ;
            }
            if(String.isNotEmpty(qrpc.PartnerCommission__c )) {
                 qrpc.Partner_Commission_currency__c =  Decimal.valueOf(qrpc.PartnerCommission__c);
            }
             
            if(String.isNotEmpty(qrpc.Cost__c)) {
                 qrpc.Cost_currency__c = Decimal.valueOf(qrpc.Cost__c);
            }
            
            qrpc.GrossProfit_currency__c = qrpc.Gross_Profit_Calculation__c;
            qrpc.GrossProfit__c = String.valueOf(qrpc.Gross_Profit_Calculation__c); 
            qrpc.PartnerCost__c  = String.valueOf(qrpc.Partner_Cost__c);
            
            // for story SC2015_AGL-4348 added on 02/19/2018'
            if(DIQuoteUtil.isDigitalInsight(qRPOppNameMap.get(qrpc.zqu__QuoteRatePlan__c))){
                if(spc == Null){
                    if(mapPRPCandMinimumChargeCode!= null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandMinimumChargeCode.get(qrpc.zqu__ProductRatePlanCharge__c))){
                        qrpc.MinimumChargeCode__c = mapPRPCandMinimumChargeCode.get(qrpc.zqu__ProductRatePlanCharge__c) ;
                    }
                    if(mapPRPCandProductUsageMetric!= null && String.isNotBlank(qrpc.zqu__ProductRatePlanCharge__c) && String.isNotBlank(mapPRPCandProductUsageMetric.get(qrpc.zqu__ProductRatePlanCharge__c))){
                        qrpc.ProductUsageMetric__c = mapPRPCandProductUsageMetric.get(qrpc.zqu__ProductRatePlanCharge__c) ;
                    }
                }else{
                    if(String.isNotBlank(spc.MinimumChargeCode__c) ){
                        qrpc.MinimumChargeCode__c = spc.MinimumChargeCode__c ;
                    }
                    if(String.isNotBlank(spc.ProductUsageMetric__c)){
                        qrpc.ProductUsageMetric__c = spc.ProductUsageMetric__c ;
                    }
                }
            }
        }
    }
}