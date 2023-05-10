// ===========================================================================
// Object: CreateQuoteServiceUtil
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: static utility methods for the CreateQuoteService
// ===========================================================================
// Changes: 2017-04-03 Reid Beckett
//           Class created
// ===========================================================================
public with sharing class CreateQuoteServiceUtil {
    @TestVisible
    static Boolean AllowMultipleQuotes = false;

    public static CreateQuoteModel.IncomingJSONBodyWrapper exportQuote(Id quoteId) {
        CreateQuoteModel.IncomingJSONBodyWrapper j = new CreateQuoteModel.IncomingJSONBodyWrapper();
        j.quoteInformation = new CreateQuoteModel.QuoteInformation();

        zqu__Quote__c qt = [select Id, zqu__Opportunity__c, zqu__ZuoraAccountID__c, zqu__StartDate__c, RecordType.Name, Renewal_Subscription_ID__c, Owner.FirstName, Owner.LastName,
                            (select Id, Name, zqu__SubscriptionRatePlanZuoraId__c, zqu__ProductRatePlanZuoraId__c, zqu__QuoteAmendment__r.zqu__Type__c from zqu__Quote_Rate_Plans__r)
                            from zqu__Quote__c where Id = :quoteId];
        j.quoteInformation.ownerFirstName = qt.Owner.FirstName;
        j.quoteInformation.ownerLastName = qt.Owner.LastName;
        j.quoteInformation.opportunityId = qt.zqu__Opportunity__c;
        j.quoteInformation.quoteType = qt.RecordType.Name;
        if(j.quoteInformation.quoteType == 'ReadOnly') {
            //change to Default or New Renewal
            if(String.isBlank(qt.Renewal_Subscription_ID__c)) {
                j.quoteInformation.quoteType = 'Default';
            }else{
                j.quoteInformation.quoteType = 'New Renewal';
                j.quoteInformation.subscriptionId = qt.Renewal_Subscription_ID__c;
            }
        }
        j.quoteInformation.billingAccountId = qt.zqu__ZuoraAccountID__c;
        j.quoteInformation.startDate = qt.zqu__StartDate__c;
        
        j.ratePlans = new CreateQuoteModel.RatePlan[]{};
        Set<Id> quoteRatePlanIds = new Set<Id>();
        for(zqu__QuoteRatePlan__c qrp : qt.zqu__Quote_Rate_Plans__r) {
            quoteRatePlanIds.add(qrp.Id);
        }

        Map<Id, List<zqu__QuoteRatePlanCharge__c>> quoteRatePlanChargesByQRPID = new Map<Id, List<zqu__QuoteRatePlanCharge__c>>();
        for(zqu__QuoteRatePlanCharge__c qrpc : [select Id, zqu__Quantity__c, zqu__EffectivePrice__c, zqu__QuoteRatePlan__c,
                                                (select Id, zqu__Tier__c, zqu__StartingUnit__c, zqu__EndingUnit__c, zqu__Effective_Price__c from zqu__Quote_RatePlan_Charge_Tier__r order by zqu__Tier__c asc)
                                                from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__c in :quoteRatePlanIds]) {
            if(quoteRatePlanChargesByQRPID.containsKey(qrpc.zqu__QuoteRatePlan__c)) {
                quoteRatePlanChargesByQRPID.get(qrpc.zqu__QuoteRatePlan__c).add(qrpc);
            }else{
                quoteRatePlanChargesByQRPID.put(qrpc.zqu__QuoteRatePlan__c, new List<zqu__QuoteRatePlanCharge__c>{ qrpc });
            }
        }
        
        for(zqu__QuoteRatePlan__c qrp : qt.zqu__Quote_Rate_Plans__r) {
            CreateQuoteModel.RatePlan rp = new CreateQuoteModel.RatePlan();
            rp.name = qrp.name;
            rp.productRatePlanId = qrp.zqu__ProductRatePlanZuoraId__c;
            if(qrp.zqu__QuoteAmendment__r.zqu__Type__c == 'RemoveProduct') {
                rp.action = 'remove';
            }else if(qrp.zqu__QuoteAmendment__r.zqu__Type__c == 'UpdateProduct') {
                rp.subscriptionRatePlanId = qrp.zqu__SubscriptionRatePlanZuoraId__c;
            }
            if(quoteRatePlanChargesByQRPID.containsKey(qrp.Id)) {
                for(zqu__QuoteRatePlanCharge__c qrpc : quoteRatePlanChargesByQRPID.get(qrp.Id)) {
                    rp.quantity = qrpc.zqu__Quantity__c;
                    rp.price = qrpc.zqu__EffectivePrice__c;
                    
                    if(!qrpc.zqu__Quote_RatePlan_Charge_Tier__r.isEmpty()) {
                        rp.tiers = new CreateQuoteModel.RatePlanTier[]{};
                            
                        for(zqu__QuoteCharge_Tier__c qctier : qrpc.zqu__Quote_RatePlan_Charge_Tier__r) {
                            CreateQuoteModel.RatePlanTier rpt = new CreateQuoteModel.RatePlanTier();
                            rpt.tier = Integer.valueOf(qctier.zqu__Tier__c);
                            rpt.startingUnit = qctier.zqu__StartingUnit__c;
                            rpt.endingUnit = qctier.zqu__EndingUnit__c;
                            rpt.price = qctier.zqu__Effective_Price__c;
                            rp.tiers.add(rpt);
                        }
                    }
                }
            }
            j.ratePlans.add(rp);
        }
        return j;
    }
    
    public static zqu__Quote__c createQuote(CreateQuoteModel.IncomingJSONBodyWrapper jsonBodyWrapper)
    {
        //validate input
        String[] errors = jsonBodyWrapper.validate();
        if(!errors.isEmpty()) {
            throw new CreateQuoteException(errors);
        }
        
        Id ownerId = null;
        if(!String.isBlank(jsonBodyWrapper.quoteInformation.ownerFirstName) && !String.isBlank(jsonBodyWrapper.quoteInformation.ownerLastName)) {
            User[] owners = [select Id from User where IsActive = true and FirstName = :jsonBodyWrapper.quoteInformation.ownerFirstName and LastName = :jsonBodyWrapper.quoteInformation.ownerLastName];
            if(owners.isEmpty()) {
                throw new CreateQuoteException('Unable to find user with first name "' + jsonBodyWrapper.quoteInformation.ownerFirstName + 
                                               '"" and last name "' + jsonBodyWrapper.quoteInformation.ownerLastName + '"');
            }            
            ownerId = owners[0].Id;
        }

        Opportunity[] opps = [select Id, Name, AccountId, /*Solution_Portfolio__c*/ Account.Subscription_Group__c, OwnerId, (select Id from zqu__Quotes__r where zqu__Primary__c = true) from Opportunity where Id = :jsonBodyWrapper.quoteInformation.opportunityId];
        if(opps.isEmpty()) {
            throw new CreateQuoteException('Opportunity with ID ' + jsonBodyWrapper.quoteInformation.opportunityId + ' not found');
        }
        if(!AllowMultipleQuotes && !opps[0].zqu__Quotes__r.isEmpty()) {
            Boolean hasQuote = false;
            for(zqu__Quote__c qt : opps[0].zqu__Quotes__r) {
                if(jsonBodyWrapper.quoteInformation.id == null || (jsonBodyWrapper.quoteInformation.id != null && jsonBodyWrapper.quoteInformation.id.substring(0,15) != String.valueOf(qt.Id).substring(0,15))) hasQuote = true;
            }
            if(hasQuote) throw new CreateQuoteException('Opportunity with ID ' + jsonBodyWrapper.quoteInformation.opportunityId + ' has an existing quote, cannot load another one');
        }
        if(ownerId == null) ownerId = opps[0].OwnerId;
        
        RecordTypeInfo rtInfo = Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get(jsonBodyWrapper.quoteInformation.quoteType);
        if(rtInfo == null) {
            throw new CreateQuoteException('Invalid Quote Type: ' + jsonBodyWrapper.quoteInformation.quoteType);
        }

        String billingAccountId = jsonBodyWrapper.quoteInformation.billingAccountId;
        if(String.isBlank(billingAccountId))
        {
            Zuora__CustomerAccount__c[] billingAccounts = null;
            String errorMessage = null;
            if(String.isBlank(jsonBodyWrapper.quoteInformation.masterCustomerNumber)){
                //find billingaccount by opp ID/account
                billingAccounts = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where Zuora__Account__c = :opps[0].AccountId and BillToFlag__c = 'Yes'];
                if(billingAccounts.isEmpty()) errorMessage = 'Could not find billing account from Opportunity ID, querying the Account ' + opps[0].AccountId;
            }else{
                //lookup from DI customer #
                billingAccounts = [select Zuora__Zuora_Id__c from Zuora__CustomerAccount__c where MasterCustomerNumber__c = :jsonBodyWrapper.quoteInformation.masterCustomerNumber];
                if(billingAccounts.isEmpty()) errorMessage = 'Could not find billing account with master customer number '+jsonBodyWrapper.quoteInformation.masterCustomerNumber;
            }
            
            if(!String.isBlank(errorMessage)) {
                throw new CreateQuoteException(errorMessage);
            }else{
                billingAccountId = billingAccounts[0].Zuora__Zuora_Id__c;
            }
        }
        
        String quoteName = 'Quote for ' + opps[0].Name;
        if(!String.isBlank(jsonBodyWrapper.quoteInformation.name)) quoteName = jsonBodyWrapper.quoteInformation.name;
        
        //create the quote
        zqu__Quote__c theQuote = new zqu__Quote__c(
            zqu__Opportunity__c = jsonBodyWrapper.quoteInformation.opportunityId, 
            Name = quoteName, zqu__ZuoraAccountId__c = billingAccountId, 
            RecordTypeId = rtInfo.getRecordTypeId(), zqu__StartDate__c = jsonBodyWrapper.quoteInformation.startDate,
            zqu__SubscriptionType__c = 'New Subscription', OwnerId = ownerId, zqu__Primary__c = true
        );
        
        if(jsonBodyWrapper.quoteInformation.quoteType == 'Amendment') {
            theQuote.zqu__ExistSubscriptionID__c = jsonBodyWrapper.quoteInformation.subscriptionId;
            theQuote.zqu__SubscriptionType__c = 'Amend Subscription';
        }
        
        if(jsonBodyWrapper.quoteInformation.quoteType == 'New Renewal') {
            theQuote.Renewal_Subscription_ID__c = jsonBodyWrapper.quoteInformation.subscriptionId;
        }
        
        if(String.isBlank(jsonBodyWrapper.quoteInformation.id)) {
            INCRDefaultValuePlugin defaultPluginImpl = (INCRDefaultValuePlugin)NCRZuoraCustomizationPluginFactory.getImpl('INCRDefaultValuePlugin', /*opps[0].Solution_Portfolio__c*/ opps[0].Account.Subscription_Group__c);
            if(defaultPluginImpl != null) defaultPluginImpl.populateDefaultFieldValue(opps[0], theQuote, null);
            
            insert theQuote;
        }else {
            theQuote.id = jsonBodyWrapper.quoteInformation.id;
        }

        return theQuote;        
    }
  
    public static ChargeGroupWrapper[] getChargeGroupsForAdd(Id theQuoteId, CreateQuoteModel.IncomingJSONBodyWrapper jsonBody) {
        Map<String, List<CreateQuoteModel.RatePlan>> ratePlansByZPRPID = CreateQuoteServiceUtil.getRatePlansByProductRatePlanId(jsonBody);
        system.debug('ratePlansByZPRPID:'+ratePlansByZPRPID);
        Map<String, Id> sfdcPRPIdsByZuoraId = CreateQuoteServiceUtil.getSFDCPRPIdsByZPRPID(ratePlansByZPRPID.keySet());
        if(sfdcPRPIdsByZuoraId.isEmpty()) return new ChargeGroupWrapper[]{};
        zqu.zChargeGroup[] lst = zqu.zQuoteUtil.getChargeGroups(theQuoteId, sfdcPRPIdsByZuoraId.values());
        ChargeGroupWrapper[] rlst = new ChargeGroupWrapper[]{};
        
        for(zqu.zChargeGroup zcg : lst) {
            CreateQuoteModel.RatePlan[] ratePlans = ratePlansByZPRPID.get(zcg.productRateplanZuoraID);
            system.debug(zcg.productRateplanZuoraID+': ' + ratePlans.size() + ' rate plans');
            String productRatePlanSFID = sfdcPRPIdsByZuoraId.get(zcg.productRateplanZuoraID);

            integer i = 0;
            for(CreateQuoteModel.RatePlan rp : ratePlans) {
                ChargeGroupWrapper cgw = new ChargeGroupWrapper();
                //Apr 25/2017 - change to query again for charge group, to handle duplicated PRPs
                if(i==0) cgw.zcg = overrideChargeGroup(zcg, rp);
                else cgw.zcg = overrideChargeGroup(zqu.zQuoteUtil.getChargeGroup(theQuoteId, productRatePlanSFID), rp);
                if(!String.isBlank(rp.subscriptionRatePlanId)) cgw.subscriptionRatePlanId = rp.subscriptionRatePlanId;
                rlst.add(cgw);
                i++;
            }
        }    

        system.debug('getChargeGroupsForAdd: returning:'+rlst.size());
        for(ChargeGroupWrapper cgw : rlst){
            system.debug(cgw);
        }
        return rlst;
    }
    
    public static zqu.zChargeGroup[] addChargeGroups(ChargeGroupWrapper[] cgwList) {
        return zqu.zQuoteUtil.addChargeGroups(unpackChargeGroupList(cgwList));
    }
    
    public static zqu.zChargeGroup[] unpackChargeGroupList(ChargeGroupWrapper[] cgwList){
        zqu.zChargeGroup[] lst = new zqu.zChargeGroup[]{};
        for(ChargeGroupWrapper cgw : cgwList){
            lst.add(cgw.zcg);
        }
        return lst;
    }
    
    public class ChargeGroupWrapper {
        public zqu.zChargeGroup zcg;
        public String subscriptionRatePlanId;
    }
    
    public static zqu.zChargeGroup[] getChargeGroupsForUpdate(CreateQuoteModel.IncomingJSONBodyWrapper jsonBody) {
        if(jsonBody.quoteInformation.quoteType == 'Amendment') {
            if(!String.isBlank(jsonBody.quoteInformation.id)) {
                Map<String, List<CreateQuoteModel.RatePlan>> ratePlansByZRPID = CreateQuoteServiceUtil.getRatePlansBySubscriptionRatePlanId(jsonBody);
                system.debug('ratePlansByZRPID:'+ratePlansByZRPID);
                zqu.zChargeGroup[] lst = zqu.zQuoteUtil.getChargeGroups(jsonBody.quoteInformation.id);
                zqu.zChargeGroup[] rlst = new zqu.zChargeGroup[]{};

                for(zqu.zChargeGroup zcg : lst) {
                    //For test methods, groupID = 1
                    String groupID = zcg.groupID;
                    if(Test.isRunningTest() && zcg.groupID == '1' && !ratePlansByZRPID.isEmpty() && 
                       !ratePlansByZRPID.values()[0].isEmpty() &&
                       !String.isBlank(ratePlansByZRPID.values()[0].get(0).subscriptionRatePlanId)) 
                    {
                           groupID = ratePlansByZRPID.values()[0].get(0).subscriptionRatePlanId;
                    }
                    system.debug('getChargeGroupsForUpdate:groupID='+groupID);
                    
                    if(ratePlansByZRPID.containsKey(groupID)) {
                        CreateQuoteModel.RatePlan[] ratePlans = ratePlansByZRPID.get(groupID);
                        for(CreateQuoteModel.RatePlan rp : ratePlans) {
                            if(rp.action != 'remove')
                                rlst.add(overrideChargeGroup(zcg, rp));
                        }    
                    }
                }
                system.debug('getChargeGroupsForUpdate: returning:'+rlst);
                return rlst;                    
            }
        }
        return null;
    }

    public static zqu.zChargeGroup[] getChargeGroupsForDelete(CreateQuoteModel.IncomingJSONBodyWrapper jsonBody) {
        if(jsonBody.quoteInformation.quoteType == 'Amendment') {
            if(!String.isBlank(jsonBody.quoteInformation.id)) {
                Map<String, List<CreateQuoteModel.RatePlan>> ratePlansByZRPID = CreateQuoteServiceUtil.getRatePlansBySubscriptionRatePlanId(jsonBody);
                zqu.zChargeGroup[] lst = zqu.zQuoteUtil.getChargeGroups(jsonBody.quoteInformation.id);
                zqu.zChargeGroup[] rlst = new zqu.zChargeGroup[]{};

                for(zqu.zChargeGroup zcg : lst) {
                    //For test methods, groupID = 1
                    String groupID = zcg.groupID;
                    if(Test.isRunningTest() && zcg.groupID == '1' && !ratePlansByZRPID.isEmpty() && 
                       !ratePlansByZRPID.values()[0].isEmpty() &&
                       !String.isBlank(ratePlansByZRPID.values()[0].get(0).subscriptionRatePlanId)) 
                    {
                           groupID = ratePlansByZRPID.values()[0].get(0).subscriptionRatePlanId;
                    }
                    
                    system.debug('getChargeGroupsForDelete:groupID='+groupID);
                    if(ratePlansByZRPID.containsKey(groupID)) {
                        CreateQuoteModel.RatePlan[] ratePlans = ratePlansByZRPID.get(groupID);
                        for(CreateQuoteModel.RatePlan rp : ratePlans) {
                            if(rp.action == 'remove')
                                rlst.add(zcg);
                        }    
                    }
                }
                system.debug('getChargeGroupsForDelete: returning:'+rlst);
                return rlst;                    
            }
        }
        return null;
    }

    public static Map<String, List<CreateQuoteModel.RatePlan>> getRatePlansByProductRatePlanId(CreateQuoteModel.IncomingJSONBodyWrapper jsonBodyWrapper)
    {
        Map<String, List<CreateQuoteModel.RatePlan>> m = new Map<String, List<CreateQuoteModel.RatePlan>>();
        for(CreateQuoteModel.RatePlan rp : jsonBodyWrapper.ratePlans) {
            if(String.isBlank(rp.subscriptionRatePlanId) || jsonBodyWrapper.quoteInformation.quoteType == 'New Renewal') {
                if(m.containsKey(rp.productRatePlanId)) {
                    m.get(rp.productRatePlanId).add(rp);
                }else{
                    m.put(rp.productRatePlanId, new CreateQuoteModel.RatePlan[]{ rp });
                }
            }
        }
        return m;
    }
    
    public static Map<Id, List<CreateQuoteModel.RatePlan>> getRatePlansBySFProductId(CreateQuoteModel.IncomingJSONBodyWrapper jsonBodyWrapper)
    {
        Map<Id, List<CreateQuoteModel.RatePlan>> m = new Map<Id, List<CreateQuoteModel.RatePlan>>();
        Set<String> productRatePlanIds = new Set<String>();
        for(CreateQuoteModel.RatePlan rp : jsonBodyWrapper.ratePlans) {
            if(!String.isBlank(rp.productRatePlanId)) {
                productRatePlanIds.add(rp.productRatePlanId);
            }
        }

        Map<String, zqu__ZProduct__c> zproductsByPRPID = new Map<String, zqu__ZProduct__c>();         
        for(zqu__ProductRatePlan__c zprp : [select Id, zqu__ZuoraId__c, zqu__ZProduct__r.Id, zqu__ZProduct__r.zqu__ZuoraId__c from zqu__ProductRatePlan__c where zqu__Deleted__c = false and zqu__ZuoraId__c in :productRatePlanIds]){
            zproductsByPRPID.put(zprp.zqu__ZuoraId__c, zprp.zqu__ZProduct__r);
        }
        
        for(CreateQuoteModel.RatePlan rp : jsonBodyWrapper.ratePlans) {
            if(!String.isBlank(rp.productRatePlanId)) {
                zqu__ZProduct__c zprod = zproductsByPRPID.get(rp.productRatePlanId);
                if(zprod != null) {
                    if(!m.containsKey(zprod.Id)) {
                        m.put(zprod.Id, new List<CreateQuoteModel.RatePlan> { rp });
                    }else{
                        m.get(zprod.Id).add(rp);
                    }
                }
            }
        }

        return m;
    }


    public static Map<String, List<CreateQuoteModel.RatePlan>> getRatePlansBySubscriptionRatePlanId(CreateQuoteModel.IncomingJSONBodyWrapper jsonBodyWrapper)
    {
        Map<String, List<CreateQuoteModel.RatePlan>> m = new Map<String, List<CreateQuoteModel.RatePlan>>();
        for(CreateQuoteModel.RatePlan rp : jsonBodyWrapper.ratePlans) {
            if(!String.isBlank(rp.subscriptionRatePlanId) && jsonBodyWrapper.quoteInformation.quoteType != 'New Renewal') {
                if(m.containsKey(rp.subscriptionRatePlanId)) {
                    m.get(rp.subscriptionRatePlanId).add(rp);
                }else{
                    m.put(rp.subscriptionRatePlanId, new CreateQuoteModel.RatePlan[]{ rp });
                }
            }
        }
        return m;
    }

    public static Map<String, String> getSFDCPRPIdsByZPRPID(Set<String> zuoraPRPIDs)
    {
        Map<String, Id> sfdcPRPIdsByZuoraId = new Map<String, Id>();
        for(zqu__ProductRatePlan__c prp : [select Id, zqu__ZuoraId__c, (select zqu__Type__c from zqu__R00N40000001mFVKEA2__r) 
                                           from zqu__ProductRatePlan__c where zqu__ZuoraId__c in :zuoraPRPIDs and zqu__Deleted__c = false order by Name asc]){
            sfdcPRPIdsByZuoraId.put(prp.zqu__ZuoraId__c, prp.Id);
        }
        return sfdcPRPIdsByZuoraId;
    }

    public static zqu.zChargeGroup overrideChargeGroup(zqu.zChargeGroup zcg, CreateQuoteModel.RatePlan rp)
    {
        for(zqu.zCharge zc : zcg.zCharges) {
            Boolean qtyChanged = false;
            if(zc.isQuantityEditable && rp.quantity != null) {
                qtyChanged = true;
                zc.QUANTITY = String.valueOf(rp.quantity);
            }
            if(qtyChanged) zcg.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(zcg.zCharges);
        }

        for(zqu.zCharge zc : zcg.zCharges) {
            Boolean priceChanged = false;
            if(zc.isEffectivePriceEditable && rp.price != null) {
                priceChanged = true;
                zc.EFFECTIVE_PRICE = String.valueOf(rp.price);
            }
            if(priceChanged) zcg.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(zcg.zCharges);
        }
        
        //tiers
        zqu__QuoteCharge_Tier__c[] tiers = new zqu__QuoteCharge_Tier__c[]{};
        for(zqu.zCharge zc : zcg.zCharges) {
            if( (zc.MODEL == 'Volume Pricing' || zc.MODEL == 'Tiered Pricing') && rp.tiers != null ) {
                for(CreateQuoteModel.RatePlanTier t : rp.tiers) {
                    zqu__QuoteCharge_Tier__c tier = new zqu__QuoteCharge_Tier__c();
                    tier.name = String.valueOf( t.tier );
                    tier.zqu__Tier__c = t.tier;
                    tier.zqu__StartingUnit__c = t.startingUnit;
                    tier.zqu__EndingUnit__c = t.endingUnit;
                    tier.zqu__Effective_Price__c = t.price;
                    tier.zqu__Price__c = t.price;
                    tier.zqu__Discount__c = 0;
                    tier.zqu__PriceFormat__c = t.priceFormat;
                    tiers.add(tier);
                }
                
                if(!tiers.isEmpty()) {
                    zc.hasCustomTiers = true;
                    zc.populateCustomChargeTiers( tiers );    
                }
            }
        }

        return zcg;
    }
    
    public static Map<String, Solution_Provider_Product__c> getSolutionProviderProductsByName(Set<String> sppNames) {
        Map<String, Solution_Provider_Product__c> m = new Map<String, Solution_Provider_Product__c>();
        for(Solution_Provider_Product__c spp : [select Id, Name from Solution_Provider_Product__c where Name in :sppNames]) {
            m.put(spp.Name, spp);
        }
        return m;
    }
    
    public static void updateRenewalQuoteRatePlans(Map<Id, String> subscriptionRatePlanIdsByQRPID) {
        Map<Id,zqu__QuoteRatePlan__c> qrpUpdates = new Map<Id,zqu__QuoteRatePlan__c>();
        for(Id qrpId : subscriptionRatePlanIdsByQRPID.keySet()) {
            String subscriptionRatePlanId = subscriptionRatePlanIdsByQRPID.get(qrpId);
            system.debug('updating QRP ' + qrpId + '; subscriptionRatePlanId='+subscriptionRatePlanId);
            zqu__QuoteRatePlan__c qrpUpdate = new zqu__QuoteRatePlan__c(
                Id = qrpId,
                Renewal_Rate_Plan_Id__c = subscriptionRatePlanId
            );
            qrpUpdates.put(qrpId, qrpUpdate);
        }
        update qrpUpdates.values();
    }
    
    public static void updateQuoteProductTPVs(Id quoteId, CreateQuoteModel.IncomingJSONBodyWrapper jsonBody) {
        //collect the TPV's
        Set<String> sppNames = new Set<String>();
        for(CreateQuoteModel.RatePlan rp : jsonBody.ratePlans) {
            if(!String.isBlank(rp.tpv)) {
                sppNames.add(rp.tpv);
            }
        }
        Map<String, List<CreateQuoteModel.RatePlan>> ratePlansByZPRPID = CreateQuoteServiceUtil.getRatePlansByProductRatePlanId(jsonBody);
        Map<String, List<CreateQuoteModel.RatePlan>> ratePlansByZRPID = CreateQuoteServiceUtil.getRatePlansBySubscriptionRatePlanId(jsonBody);        
        Map<Id, List<CreateQuoteModel.RatePlan>> ratePlansBySFPID = CreateQuoteServiceUtil.getRatePlansBySFProductId(jsonBody);        

        Map<String, Solution_Provider_Product__c> sppsByName = CreateQuoteServiceUtil.getSolutionProviderProductsByName(sppNames);
        Map<Id, Quote_Product__c> qpUpdates = new Map<Id, Quote_Product__c>();
        Quote_Product__c[] quoteProducts = [select Id, ZProduct__c, Quote_Rate_Plan__r.zqu__ProductRatePlanZuoraId__c, Quote_Rate_Plan__r.zqu__SubscriptionRatePlanZuoraId__c from Quote_Product__c where Quote__c = :quoteId];


        for(Quote_Product__c qp : quoteProducts) {
            if(qp.Quote_Rate_Plan__c != null) {
                CreateQuoteModel.RatePlan[] ratePlans1 = ratePlansByZPRPID.get(qp.Quote_Rate_Plan__r.zqu__ProductRatePlanZuoraId__c);
                if(ratePlans1 != null) {
                    for(CreateQuoteModel.RatePlan rp : ratePlans1) {
                        if(!String.isBlank(rp.tpv) && sppsByName.containsKey(rp.tpv)) {
                            qp.Solution_Provider_Product__c = sppsByName.get(rp.tpv).Id;
                            qpUpdates.put(qp.Id, qp);
                        }
                    }    
                }
                
                CreateQuoteModel.RatePlan[] ratePlans2 = ratePlansByZRPID.get(qp.Quote_Rate_Plan__r.zqu__SubscriptionRatePlanZuoraId__c);
                if(ratePlans2 != null){
                    for(CreateQuoteModel.RatePlan rp : ratePlans2) {
                        if(!String.isBlank(rp.tpv) && sppsByName.containsKey(rp.tpv)) {
                            qp.Solution_Provider_Product__c = sppsByName.get(rp.tpv).Id;
                            qpUpdates.put(qp.Id, qp);
                        }
                    }
                }
            }else if(qp.ZProduct__c != null) {
                CreateQuoteModel.RatePlan[] ratePlans3 = ratePlansBySFPID.get(qp.ZProduct__c);
                if(ratePlans3 != null) {
                    for(CreateQuoteModel.RatePlan rp : ratePlans3) {
                        if(!String.isBlank(rp.tpv) && sppsByName.containsKey(rp.tpv)) {
                            qp.Solution_Provider_Product__c = sppsByName.get(rp.tpv).Id;
                            qpUpdates.put(qp.Id, qp);
                        }
                    }
                }
            }
        }

        if(!qpUpdates.isEmpty()) {
            try {
                Database.update(qpUpdates.values(), false);
            }catch(Exception e){
                throw e;
            }
        }   
    }

    public class CreateQuoteException extends Exception {
        public String[] errors;
        
        public CreateQuoteException(String[] errors) {
            this.errors = errors;
        }
    }
}