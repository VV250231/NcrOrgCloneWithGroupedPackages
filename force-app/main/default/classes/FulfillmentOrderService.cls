/**
 * @author ATG
 * @description This Service class is used to create and update Fulfillment Orders and Fufillment Order Products from the Quote
*/
public with sharing class FulfillmentOrderService {
    static final string TYPE_AMENDMENT = 'Amendment',
                        ELIGIBLE_FOR_ERP_FALSE = 'FALSE',
                        ELIGIBLE_FOR_ERP_TRUE = 'TRUE',
                        ORDER_TYPE_HSR_RENTAL_SOURCING = 'HSR Rental Sourcing',
                        LEGAL_DOCUMENT_STATUS_COMPLETED = 'Completed';

    Map<Id, FulfillmentOrderWrapper> mapFulfillmentOrderWrapperByQuoteId = new Map<Id, FulfillmentOrderWrapper>();
    Map<Id, SBQQ__Quote__c> mapRequeriedQuoteById = new Map<Id, SBQQ__Quote__c>();
    List<qtc_FulfillmentOrder__c> listFulfillmentOrderToUpsert = new List<qtc_FulfillmentOrder__c>();
    List<qtc_FulfillmentOrderProduct__c> listFulfillmentOrderProductsToUpsert = new List<qtc_FulfillmentOrderProduct__c>();
    List<Quote_Ordered__e> listQuoteOrderEvents = new List<Quote_Ordered__e>();
    
    /**
     * @description Constructor method to Instantiate the Object and sets the map of the Inner Class Fulfillment Order Wrapper
     * @param   thisListQuote   List of Quotes from Trigger
     */
    public FulfillmentOrderService(List<SBQQ__Quote__c> thisListQuote) {
        for( SBQQ__Quote__c thisQuote : thisListQuote){
            this.mapFulfillmentOrderWrapperByQuoteId.put( thisQuote.Id, new FulfillmentOrderWrapper( thisQuote, this ));
        }
    }

    /**
     * @description Run method to invoke the Object. It will query related Quote lines and for existing 
     *              Fulfillment Order and Fulfillment Order Product Records. It wll then evaluate and 
     *              Upsert Fufillment Order and Order Products.
     */
    public FulfillmentOrderService run(){
        queryData();
        for(FulfillmentOrderWrapper thisWrapper : this.mapFulfillmentOrderWrapperByQuoteId.values()){
            thisWrapper.processWrapper();
            if( thisWrapper.isValid ){
                listFulfillmentOrderToUpsert.add( thisWrapper.fulfillmentOrder );
            }
        }
        upsert listFulfillmentOrderToUpsert;

        for(FulfillmentOrderWrapper thisWrapper : this.mapFulfillmentOrderWrapperByQuoteId.values()){
            if( thisWrapper.isValid ){
                thisWrapper.addMissingFulfillmentOrderIds();
                listFulfillmentOrderProductsToUpsert.addAll( thisWrapper.mapFulfillmentOrderProductByKey.values() );
            }
        }
        upsert listFulfillmentOrderProductsToUpsert;

        List<SBQQ__Quote__c> listQuotesToUpdate = reEvaluateQuote();
        update listQuotesToUpdate;
        if(!this.listQuoteOrderEvents.isEmpty()){
            List<Database.SaveResult> results = EventBus.publish(this.listQuoteOrderEvents);
        }

        return this;
    }

    /**
     * @description Query method to Query for Quote Lines, Fufillment Orders and Fufillment Order Products.
     *              The Queried data will be added to the associated Quote's Inner Class FufillmentOrderWrapper.
     */
    private void queryData(){
        Set<Id> setQuoteIds = this.mapFulfillmentOrderWrapperByQuoteId.keySet();
        Set<Id> setFulfillmentOrderIds = new Set<Id>();
        mapRequeriedQuoteById = new Map<Id, SBQQ__Quote__c>(
            [   SELECT  SBQQ__Account__r.Account_Country_Code__c, SBQQ__Opportunity2__r.Invoice_Trigger__c,
                        SBQQ__Account__r.Master_Customer_Number__c, qtc_Bill_To_Site__r.Site_Number__c,
                        qtc_Ship_To_Account__r.Site_Number__c, Deliver_To_Site__r.Site_Number__c,
                        SBQQ__SalesRep__r.Global_ID__c,SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c,
                        SBQQ__Opportunity2__r.CAM__c,SBQQ__OriginalQuote__c
                FROM SBQQ__Quote__c 
                WHERE Id IN : setQuoteIds]
        );

        for( SBQQ__QuoteLine__c thisQuoteLine : [   SELECT  Id, SBQQ__Quote__c,SBQQ__OptionLevel__c, SBQQ__Product__c, SBQQ__ProductOption__c, 
                                                            SBQQ__Quantity__c, SBQQ__PriorQuantity__c ,SBQQ__UpgradedSubscription__c,  
                                                            SBQQ__Product__r.Name, SBQQ__ListPrice__c, SBQQ__Product__r.qtc_Exclude_from_ERP__c,
                                                            SBQQ__Product__r.PMDM_Unique_Key__c, qtc_Required_By_Product__c, SBQQ__Number__c,
                                                            qtc_Pass_Through__c, qtc_Hardware_Role__c, 
                                                            qtc_SW_Key_End_Date__c, qtc_SW_Key_Start_Date__c,
                                                            qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,
                                                            qtc_Product_Code__c, qtc_Software_System_Name__c,SBQQ__ProductFamily__c,
                                                            SBQQ__EffectiveQuantity__c,SBQQ__Description__c, SBQQ__Quote__r.qtc_Quote_Name__c,Product_Category__c,qtc_Product_Type__c
                                                    FROM SBQQ__QuoteLine__c 
                                                    WHERE SBQQ__Quote__c IN :setQuoteIds 
                                                        AND qtc_Pass_Through__c = false
                                                        AND SBQQ__OptionLevel__c <> null]){
            FulfillmentOrderWrapper thisWrapper = this.mapFulfillmentOrderWrapperByQuoteId.get( thisQuoteLine.SBQQ__Quote__c );
            thisWrapper.addQuoteLine( thisQuoteLine );
        }
        for( qtc_FulfillmentOrder__c thisFulfillmentOrder : [   SELECT  Id, qtc_Quote__c, qtc_Quote_Number__c, qtc_Quote_Name__c, 
                                                                        qtc_Country_Code__c, qtc_MCN__c, qtc_Bill_To_Site__c, qtc_Ship_To_Account__c,
                                                                        qtc_DeliverToSite__c, qtc_Invoice_Trigger__c, qtc_PO_Number__c,atc_QuickBaseProjectNumber__c,
                                                                        qtc_ERP_Quote_Type__c, qtc_Order_Source__c, qtc_Sequence_Number__c, qtc_PaymentTerms__c,
                                                                        qtc_New_Aloha_Key_Number__c, CurrencyIsoCode, qtc_Conversion_Type__c, qtc_CIS__c,
                                                                        qtc_CDP__c, qtc_Requested_Delivery_Date__c, qtc_Customer_PO_Date__c, qtc_Order_Type__c ,qtc_Type__c,
                                                                        qtc_Has_Payments_Processing__c,qtc_Payments_Type__c,qtc_Existing_Aloha_Key_Number__c,qtc_Existing_Hosted_Enterprise_ID__c,
                                                                        qtc_Submitted_Date__c,qtc_Customer_Setup_Complete_Date__c,qtc_Order_Authorization_Accepted_Date__c    
                                                                FROM qtc_FulfillmentOrder__c 
                                                                WHERE qtc_Quote__c IN :setQuoteIds ]){
            setFulfillmentOrderIds.add( thisFulfillmentOrder.Id );
            FulfillmentOrderWrapper thisWrapper = this.mapFulfillmentOrderWrapperByQuoteId.get( thisFulfillmentOrder.qtc_Quote__c );
            thisWrapper.setFulfillmentOrder( thisFulfillmentOrder ); 
        }

        for( qtc_FulfillmentOrderProduct__c thisFulfillmentOrderProduct : [ SELECT Id, qtc_FulfillmentOrder__c, qtc_FulfillmentOrder__r.qtc_Quote__c, qtc_Product__c, 
                                                                                    qtc_Quantity__c, qtc_ProductOption__c,
                                                                                    qtc_Hardware_Role__c, qtc_MDM_Product_ID__c, qtc_SW_Key_Start_Date__c,
                                                                                    qtc_SW_Key_End_Date__c, qtc_Unit_List_Price__c, qtc_Qty_to_Ship__c,  
                                                                                    qtc_Software_NOT_Ship_Qty__c, qtc_Software_Media_Set__c, qtc_Software_Release_Number__c,
                                                                                    qtc_Package_ID__c, qtc_Sub_Package_ID__c, qtc_Software_System_Name__c, qtc_LineNumber__c,qtc_product_family__c,
                                                                                    qtc_Description__c,qtc_Effective_Quantity__c
                                                                            FROM qtc_FulfillmentOrderProduct__c 
                                                                            WHERE qtc_FulfillmentOrder__c IN : setFulfillmentOrderIds]){
            FulfillmentOrderWrapper thisWrapper = this.mapFulfillmentOrderWrapperByQuoteId.get( thisFulfillmentOrderProduct.qtc_FulfillmentOrder__r.qtc_Quote__c );
            thisWrapper.addFulfillmentOrderProduct( thisFulfillmentOrderProduct );
        }   
    }

    /**
     * @description Class to query for the Fulfillment Order's rollup summary and update the quote's eligible for ERP field
     */
    private List<SBQQ__Quote__c> reEvaluateQuote(){
        Set<Id> setQuoteIds = this.mapFulfillmentOrderWrapperByQuoteId.keySet();
        List<SBQQ__Quote__c> listQuoteToUpdate = new List<SBQQ__Quote__c>();
        Map<Id, qtc_FulfillmentOrder__c> mapFulfillmnetOrderByQuoteId = new  Map<Id, qtc_FulfillmentOrder__c>();
        for(qtc_FulfillmentOrder__c thisFulfillmentOrder : [SELECT Id, qtc_EligibleForERP__c, qtc_Quote__c, qtc_Quote__r.SBQQ__Type__c, qtc_Quote__r.qtc_Legal_Document_Status__c
                                                            FROM qtc_FulfillmentOrder__c 
                                                            WHERE qtc_Quote__c IN :setQuoteIds ]){
            mapFulfillmnetOrderByQuoteId.put(thisFulfillmentOrder.qtc_Quote__c, thisFulfillmentOrder);
        }
    
        for( Id thisQuoteId : setQuoteIds){
            SBQQ__Quote__c thisQuote = mapFulfillmentOrderWrapperByQuoteId.get( thisQuoteId ).quote;
            qtc_FulfillmentOrder__c thisFulfillmentOrder = mapFulfillmnetOrderByQuoteId.get( thisQuoteId );

            String eligibleForERP = ELIGIBLE_FOR_ERP_FALSE;
            if( thisFulfillmentOrder?.qtc_EligibleForERP__c != null 
                && thisFulfillmentOrder.qtc_EligibleForERP__c > 0 ){

                eligibleForERP = ELIGIBLE_FOR_ERP_TRUE;
            }

            if( thisQuote?.SBQQ__Type__c == TYPE_AMENDMENT
                && thisFulfillmentOrder == null
                && eligibleForERP == ELIGIBLE_FOR_ERP_FALSE
                && thisQuote?.qtc_Legal_Document_Status__c == LEGAL_DOCUMENT_STATUS_COMPLETED ){
                this.listQuoteOrderEvents.add(
                    new Quote_Ordered__e(
                        qtcQuoteId__c = thisQuoteId
                    )
                );
            }
            SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(
                Id = thisQuoteId,
                qtc_EligibleForERP__c = eligibleForERP
            );
            listQuoteToUpdate.add( quoteToUpdate );
        }
        return listQuoteToUpdate;
    }

    /**
     * @description Inner Wrapper class to hold Quote Line data grouped by Product Ids and Product Options. This Inner class will be used
     *              to store aggregated values from the quote Lines.
     */
    private class QuoteLineWrapper{
        List<SBQQ__QuoteLine__c> listQuoteLines = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c referenceQuoteLine{
            get{
                if( referenceQuoteLine == null){
                    return listQuoteLines[0];
                }
                return referenceQuoteLine;
            }
            set;
        }

        Double  aggregatedQuantity = 0,
                unitListPrice;
        Id      productId,
                productOption;
        Double  amendmentAggregatedPriorQuantity = 0;
        Date    completionDateShimpentDate,
                promiseDate,
                scheduledShipDate,
                swKeyEndDate,
                swKeyStartDate;
        String  deliveryId, 
                hardwareRole, 
                mdmProductId,
                productName,
                softwareMediaSet,
                softwareReleaseNumber,
                softwareSystemName;
        Integer orderedQuantity,
                qtyToShip;

    

        Double netFulfillmentQuantity {
            get{
                return aggregatedQuantity - amendmentAggregatedPriorQuantity;
            }
            set;
        }

        Boolean isNetZero {
            get{
                if( netFulfillmentQuantity == 0){
                    return true;
                }
                return false;
            }
            set;
        }

        /**
         * @description The Constructor to instantiate this innerclass.
         * @param   thisQuoteLine   Quote Line
         */
        public QuoteLineWrapper( SBQQ__QuoteLine__c thisQuoteLine ){
            this.productId = thisQuoteLine.SBQQ__Product__c;
            this.productOption = thisQuoteLine.SBQQ__ProductOption__c;
            addLine( thisQuoteLine );
        }

        /**
         * @description Method to add a quote line to the innerclass List and aggregate values
         * @param   thisQuoteLine  QutoeLine
         */
        public void addLine( SBQQ__QuoteLine__c thisQuoteLine ){
            this.aggregatedQuantity += thisQuoteLine.SBQQ__Quantity__c;
            if( thisQuoteLine.SBQQ__PriorQuantity__c != null ){
                this.amendmentAggregatedPriorQuantity += thisQuoteLine.SBQQ__PriorQuantity__c;
            }
            if(thisQuoteLine.SBQQ__UpgradedSubscription__c == null){
                this.referenceQuoteLine = thisQuoteLine;
            }
            this.listQuoteLines.add( thisQuoteLine );
        }

        /**
         * @description Method to return an instantiated Fulfillment Order Product record
         * @param   fulfillmentOrderId  Id of the fulfillment Order
         * @return  qtc_FulfillmentOrderProduct__c  Instantiated qtc_FulfillmentOrderProduct__c record
         */
        public qtc_FulfillmentOrderProduct__c getFulfillmentOrderProduct(Id fulfillmentOrderId){
            qtc_FulfillmentOrderProduct__c fulfillmentOrderProduct = new qtc_FulfillmentOrderProduct__c(
                qtc_Product__c = this.productId,
                qtc_ProductOption__c = this.productOption,
                qtc_FulfillmentOrder__c = fulfillmentOrderId
            );
            fulfillmentOrderProduct = setFulfillmentOrderProductFields( fulfillmentOrderProduct );

            return fulfillmentOrderProduct;
        }

        /**
         * @description Method to map and set fields on the Fulfillment Order Product
         * @param   thisFullfillmentOrderProduct  Fulfillment Order Product record
         * @return  qtc_FulfillmentOrderProduct__c  qtc_FulfillmentOrderProduct__c record
         */
        public qtc_FulfillmentOrderProduct__c setFulfillmentOrderProductFields(qtc_FulfillmentOrderProduct__c thisFullfillmentOrderProduct){
            thisFullfillmentOrderProduct.qtc_Hardware_Role__c            = this.referenceQuoteLine?.qtc_Hardware_Role__c;
            thisFullfillmentOrderProduct.qtc_MDM_Product_ID__c           = this.referenceQuoteLine?.SBQQ__Product__r.PMDM_Unique_Key__c;
            thisFullfillmentOrderProduct.qtc_Exclude_from_ERP__c         = this.referenceQuoteLine?.SBQQ__Product__r.qtc_Exclude_from_ERP__c;
            if( this.referenceQuoteLine?.qtc_SW_Key_Start_Date__c != null){
                thisFullfillmentOrderProduct.qtc_SW_Key_Start_Date__c        = Date.parse( this.referenceQuoteLine?.qtc_SW_Key_Start_Date__c );
            }
            if( this.referenceQuoteLine?.qtc_SW_Key_End_Date__c != null){
                thisFullfillmentOrderProduct.qtc_SW_Key_End_Date__c          = Date.parse( this.referenceQuoteLine?.qtc_SW_Key_End_Date__c );
            }
            thisFullfillmentOrderProduct.qtc_Unit_List_Price__c          = 0;
            thisFullfillmentOrderProduct.qtc_Qty_to_Ship__c              = 0;
            // thisFullfillmentOrderProduct.qtc_Software_NOT_Ship_Qty__c    = this.referenceQuoteLine?.;
            thisFullfillmentOrderProduct.qtc_LineNumber__c               = this.referenceQuoteLine?.SBQQ__Number__c;
            thisFullfillmentOrderProduct.qtc_Software_Media_Set__c      = this.referenceQuoteLine?.qtc_Software_Media_Set__c;
            thisFullfillmentOrderProduct.qtc_Software_Release_Number__c  = this.referenceQuoteLine?.qtc_Software_Release_Number__c;
            thisFullfillmentOrderProduct.qtc_Package_ID__c               = this.referenceQuoteLine?.qtc_Required_By_Product__c;
            thisFullfillmentOrderProduct.qtc_Sub_Package_ID__c           = this.referenceQuoteLine?.qtc_Required_By_Product__c;
            thisFullfillmentOrderProduct.qtc_Software_System_Name__c     = this.referenceQuoteLine?.qtc_Software_System_Name__c;
            thisFullfillmentOrderProduct.qtc_product_family__c           = this.referenceQuoteLine?.SBQQ__ProductFamily__c;
            thisFullfillmentOrderProduct.qtc_Description__c              = this.referenceQuoteLine?.SBQQ__Description__c;
            thisFullfillmentOrderProduct.qtc_Effective_Quantity__c       = this.referenceQuoteLine?.SBQQ__EffectiveQuantity__c;
            thisFullfillmentOrderProduct.qtc_Overall_Quantity__c         = this.referenceQuoteLine?.SBQQ__Quantity__c;
            thisFullfillmentOrderProduct.qtc_Quote_Name__c               = this.referenceQuoteLine?. SBQQ__Quote__r.qtc_Quote_Name__c;
            thisFullfillmentOrderProduct.qtc_Product_Category__c         = this.referenceQuoteLine?.Product_Category__c;
            thisFullfillmentOrderProduct.qtc_Product_Type__c             = this.referenceQuoteLine?.qtc_Product_Type__c;
            return thisFullfillmentOrderProduct;
        }

      
    }

    /**
     * @description Inner Class to store Data for the Quote and to evaluate and create Fulfillment Orders and Order Products
     */
    private class FulfillmentOrderWrapper{
        SBQQ__Quote__c quote;
        FulfillmentOrderService service;
        Map<String, QuoteLineWrapper> mapQuoteLineWrappersByKey = new  Map<String, QuoteLineWrapper>();
        qtc_FO_Settings__c fulfillmentOrderCustomSetting = qtc_FO_Settings__c.getInstance();
        
        Boolean isAmendment {
            get{
                if(quote.SBQQ__Type__c == TYPE_AMENDMENT ){
                    return true;
                }
                return false;
            }
            set;
        }

        Boolean isValid {
            get{
                if( mapFulfillmentOrderProductByKey.isEmpty()){
                    return false;
                }
                return true;
            }
            set;
        }

        /**
         * @description Getter variable to instantiate a fulfillment order if an existing one is not available
         */
        qtc_FulfillmentOrder__c fulfillmentOrder{
            get{
                if( fulfillmentOrder == null){
                    fulfillmentOrder = new qtc_FulfillmentOrder__c(
                        qtc_Order_Source__c             = 'CPQ',
                        qtc_Order_Type__c               = ORDER_TYPE_HSR_RENTAL_SOURCING,
                        qtc_Sequence_Number__c          = 0,
                        qtc_Quote__c                    = quote.Id
                        
                    );
                }
                SBQQ__Quote__c referencedQuote = service.mapRequeriedQuoteById.get( quote.Id );
                fulfillmentOrder.qtc_Quote_Name__c               = quote.qtc_Quote_Name__c;
                fulfillmentOrder.qtc_Country_Code__c             = referencedQuote?.SBQQ__Account__r?.Account_Country_Code__c;
                fulfillmentOrder.qtc_MCN__c                      = referencedQuote?.SBQQ__Account__r?.Master_Customer_Number__c;
                fulfillmentOrder.qtc_Bill_To_Site__c             = referencedQuote?.qtc_Bill_To_Site__r?.Site_Number__c;
                fulfillmentOrder.qtc_Ship_To_Account__c          = referencedQuote?.qtc_Ship_To_Account__r?.Site_Number__c;
                fulfillmentOrder.qtc_DeliverToSite__c            = referencedQuote?.Deliver_To_Site__r?.Site_Number__c;
                if (referencedQuote.SBQQ__Opportunity2__r.Channel_Office__r.CDM_Account_Type__c == 'PARTNER') {
                    fulfillmentOrder.Salesperson__c          = referencedQuote?.SBQQ__Opportunity2__r.CAM__c;
                } else {
                    fulfillmentOrder.Salesperson__c          = referencedQuote?.SBQQ__SalesRep__c;
                }
                fulfillmentOrder.qtc_Invoice_Trigger__c          = referencedQuote?.SBQQ__Opportunity2__r.Invoice_Trigger__c;
                fulfillmentOrder.qtc_PO_Number__c                = quote.qtc_PO_Number__c;
                fulfillmentOrder.atc_QuickBaseProjectNumber__c   = quote.Quickbase_Project_Number__c;
                fulfillmentOrder.qtc_ERP_Quote_Type__c           = quote.qtc_ERP_Quote_Type__c;
                fulfillmentOrder.qtc_PaymentTerms__c             = quote.SBQQ__PaymentTerms__c;
                fulfillmentOrder.qtc_New_Aloha_Key_Number__c     = quote.qtc_New_Aloha_Key_Number__c;
                fulfillmentOrder.CurrencyIsoCode                 = quote.CurrencyIsoCode;
                fulfillmentOrder.qtc_CIS__c                      = fulfillmentOrderCustomSetting.qtc_CIS_QLID__c;
                fulfillmentOrder.qtc_CDP__c                      = fulfillmentOrderCustomSetting.qtc_CDP_QLID__c;
                fulfillmentOrder.qtc_Requested_Delivery_Date__c  = quote.qtc_Requested_Delivery_Date__c;
                fulfillmentOrder.qtc_Customer_PO_Date__c         = quote.Customer_PO_Date__c;
                fulfillmentOrder.qtc_Type__c                     = quote.SBQQ__Type__c;
                fulfillmentOrder.qtc_Has_Payments_Processing__c  = quote.qtc_Has_Payments_Processing__c;
                fulfillmentOrder.qtc_Payments_Type__c            = quote.qtc_Payments_Type__c;
                fulfillmentOrder.qtc_Existing_Aloha_Key_Number__c = quote.qtc_Existing_Aloha_Key_Number__c;
                fulfillmentOrder.qtc_Existing_Hosted_Enterprise_ID__c = quote.qtc_Existing_Hosted_Enterprise_ID__c;
                fulfillmentOrder.qtc_Submitted_Date__c = quote.SubmittedDate__c;
                fulfillmentOrder.qtc_Original_Quote__c          = referencedQuote?.SBQQ__OriginalQuote__c;
                fulfillmentOrder.qtc_Customer_Setup_Complete_Date__c = quote.qtc_Customer_Setup_Complete_Date__c;
                fulfillmentOrder.qtc_Order_Authorization_Accepted_Date__c= quote.qtc_Order_Authorization_Accepted_Date__c;
                return fulfillmentOrder;
            }
            set;
        }

        Map<String, qtc_FulfillmentOrderProduct__c> mapFulfillmentOrderProductByKey = new Map<String, qtc_FulfillmentOrderProduct__c>();

        /**
         * @description Constructor for this Inner Class
         * @param thisQuote     Quote record
         */
        public FulfillmentOrderWrapper(SBQQ__Quote__c thisQuote, FulfillmentOrderService service){
            this.quote = thisQuote;
            this.service = service;
        }

        /**
         * @description Method is used to add a Quote Line to the Inner class and map the Quote Line to the correct Key/QuoteLineWrapper pairng
         * @param   thisQuoteLine  Quote Line Record
         */
        public void addQuoteLine( SBQQ__QuoteLine__c thisQuoteLine ){
            if( !(thisQuoteLine.qtc_Pass_Through__c || thisQuoteLine.SBQQ__OptionLevel__c == null) ){
                String key = getKey( thisQuoteLine );
                if( this.mapQuoteLineWrappersByKey.containsKey( key )){
                    QuoteLineWrapper thisWrapper = this.mapQuoteLineWrappersByKey.get( key );
                    thisWrapper.addLine( thisQuoteLine );
                }
                else {
                    QuoteLineWrapper thisWrapper = new QuoteLineWrapper( thisQuoteLine );
                    this.mapQuoteLineWrappersByKey.put( key, thisWrapper );
                }
            }
        }

        /**
         * @description Method is to add an existing Fulfillment Order Record to the Inner class, and parse the Fulfillment
         *              Order Products to the inner class
         * @param   thisFulfillmentOrder    Existing Fulfillment Order Record
         */
        public void setFulfillmentOrder( qtc_FulfillmentOrder__c thisFulfillmentOrder ){
            this.fulfillmentOrder = thisFulfillmentOrder;
        }

        /**
         * @description Method is to add existng fulfillment order product records parsed from the subquery of the Fulfillment 
         *              Order query. The method will map the product records to a generated key derived from the Product Id and Product Option
         * @param   thisFulfillmentOrderProduct  FulfillmentOrderProduct Record
         */
        public void addFulfillmentOrderProduct( qtc_FulfillmentOrderProduct__c thisFulfillmentOrderProduct ){
            String key = getKey( thisFulfillmentOrderProduct );
            this.mapFulfillmentOrderProductByKey.put( key, thisFulfillmentOrderProduct );
        }

        /**
         * @description Method used to evaluate the Quote Lines and Fulfillment Order Products
         */
        public void processWrapper(){
            evaluateQuoteLineWrapper();
            evaluateDeletedQuoteLines();

        }

        /**
         * @description Method will process the Quote Line Wrappers and Fulliment Orders. 
         *              It will create a new FulfillmentOrderProduct if an existing one is not available.
         *              If there is an Excisting FulfillmentOrderProduct, it will set the Previous Quantity and new Quantity value
         */
        private void evaluateQuoteLineWrapper(){
            for( String key : this.mapQuoteLineWrappersByKey.keySet() ){
                QuoteLineWrapper thisQuoteLineWrapper = mapQuoteLineWrappersByKey.get( key );
                if( this.isAmendment ){
                    if( !thisQuoteLineWrapper.isNetZero ){
                        qtc_FulfillmentOrderProduct__c thisFulfillmentProduct = thisQuoteLineWrapper.getFulfillmentOrderProduct( fulfillmentOrder.Id );
                        thisFulfillmentProduct.qtc_Quantity__c = thisQuoteLineWrapper.netFulfillmentQuantity;

                        Decimal qtyToShip = thisFulfillmentProduct.qtc_Qty_To_Ship__c == null ? 0 : thisFulfillmentProduct.qtc_Qty_To_Ship__c;
                        thisFulfillmentProduct.qtc_Software_NOT_Ship_Qty__c = thisFulfillmentProduct.qtc_Quantity__c - qtyToShip;

                        this.mapFulfillmentOrderProductByKey.put( key, thisFulfillmentProduct);
                    }
                }
                else {
                    if( this.mapFulfillmentOrderProductByKey.containsKey( key ) ){
                        qtc_FulfillmentOrderProduct__c thisFulfillmentProduct = this.mapFulfillmentOrderProductByKey.get( key );
                        thisFulfillmentProduct = thisQuoteLineWrapper.setFulfillmentOrderProductFields( thisFulfillmentProduct );

                        thisFulfillmentProduct.qtc_PreviousQuantity__c = thisFulfillmentProduct.qtc_Quantity__c;
                        thisFulfillmentProduct.qtc_Quantity__c = thisQuoteLineWrapper.aggregatedQuantity;
                        
                        Decimal qtyToShip = thisFulfillmentProduct.qtc_Qty_To_Ship__c == null ? 0 : thisFulfillmentProduct.qtc_Qty_To_Ship__c;
                        thisFulfillmentProduct.qtc_Software_NOT_Ship_Qty__c = thisFulfillmentProduct.qtc_Quantity__c - qtyToShip;
                        
                        this.mapFulfillmentOrderProductByKey.put( key, thisFulfillmentProduct);
                    }
                    else {
                        qtc_FulfillmentOrderProduct__c thisFulfillmentProduct = thisQuoteLineWrapper.getFulfillmentOrderProduct( fulfillmentOrder.Id );
                        thisFulfillmentProduct.qtc_Quantity__c = thisQuoteLineWrapper.aggregatedQuantity;
                        
                        Decimal qtyToShip = thisFulfillmentProduct.qtc_Qty_To_Ship__c == null ? 0 : thisFulfillmentProduct.qtc_Qty_To_Ship__c;
                        thisFulfillmentProduct.qtc_Software_NOT_Ship_Qty__c = thisFulfillmentProduct.qtc_Quantity__c - qtyToShip;
                        
                        this.mapFulfillmentOrderProductByKey.put( key, thisFulfillmentProduct);
                    }
                }
            }
        }

        /**
         * @description Method will loop through the FulfillmentOrderProducts and checks to see if there is
         *              a QuoteLineWrapper with the associated Product Id/Product Option Key. If there is no
         *              QuoteLineWrapper with the same key, it will set the previous quantity and new Quantity 
         *              value will be 0.
         */
        private void evaluateDeletedQuoteLines(){
            for(String key : mapFulfillmentOrderProductByKey.keySet() ){
                if( !mapQuoteLineWrappersByKey.containsKey( key ) ){
                    qtc_FulfillmentOrderProduct__c thisFulfillmentProduct =  mapFulfillmentOrderProductByKey.get( key );
                    thisFulfillmentProduct.qtc_PreviousQuantity__c = thisFulfillmentProduct.qtc_Quantity__c;
                    thisFulfillmentProduct.qtc_Quantity__c = 0;
                }
            }
        }

         /**
         * @description Method will loop through the FulfillmentOrderProducts and add the fulfillmentOrder Id if missing
         */
        private void addMissingFulfillmentOrderIds(){
            for( qtc_FulfillmentOrderProduct__c thisFullfillmentProduct : mapFulfillmentOrderProductByKey.values()){
                if(thisFullfillmentProduct.qtc_FulfillmentOrder__c == null){
                    thisFullfillmentProduct.qtc_FulfillmentOrder__c = fulfillmentOrder.Id;
                }
            }
        }

        /**
         * @description this method is to get the map key of a quote line by concatenating the Product Id and Product Option
         * @param   thisQuoteLine   Quote Line record
         * @return  String          Concatenated Product Id and Product Option
         */
        private String getKey( SBQQ__QuoteLine__c thisQuoteLine){
            List<String> listIds = new List<String>{
                String.valueOf( thisQuoteLine.SBQQ__Product__c ),
                String.valueOf( thisQuoteLine.SBQQ__ProductOption__c )
            };
            return String.format('{0}:{1}', listIds);
        }
    
        /**
         * @description this method is to get the map key of a FulfillmentOrderProduct by concatenating the Product Id and Product Option
         * @param   thisFulfillmentOrderProduct     Fulfillment Order Product
         * @return  String                          Concatenated Product Id and Product Option
         */
        private String getKey( qtc_FulfillmentOrderProduct__c thisFulfillmentOrderProduct){
            List<String> listIds = new List<String>{
                String.valueOf( thisFulfillmentOrderProduct.qtc_Product__c ),
                String.valueOf( thisFulfillmentOrderProduct.qtc_ProductOption__c )
            };
            return String.format('{0}:{1}', listIds);
        }

    }
}