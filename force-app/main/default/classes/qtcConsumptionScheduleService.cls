/*
*   @author ATG
*   @description Service class to calcualte Consumption Rates of a given Quantity and Product and will reference the Connected Paymetns No Payments Consummption Schedule
*/

public with sharing class qtcConsumptionScheduleService {
    public String   SCHEDULE_TYPE_RANGE = 'Range',
                    SCHEDULE_TYPE_SLAB = 'Slab',
                    SCHEDULE_PRICING_METHOD_PERUNIT = 'PerUnit',
                    SCHEDULE_PRICING_METHOD_FLATFEE = 'FlatFee';
    public Set<Id>  setProductIds;
    public Map<Id, ConsumptionSchedule> mapConsumptionScheduleById;
    Map<Id, ProductConsumptionSchedule> mapProductConsumptionScheduleByProductId;

     /**
     * @description Constructor method to instantiate this rate service class
     * @param   setProductId  Set of Product Ids that will be referenced
     */
    public qtcConsumptionScheduleService(Set<Id> setProductId) {
        this.setProductIds = setProductId;
        queryProductConsumptionSchedule();
        queryConsumptionSchedule();
    }

      /**
     * @description Method will query for Product Consumption Schedules, filtered on the input product ids and when isActive and F&F Rating is true
     */
    private void queryProductConsumptionSchedule(){
        Map<Id, ProductConsumptionSchedule> thisMapProductConsumptionScheduleByProductId = new Map<Id, ProductConsumptionSchedule>();
        for(ProductConsumptionSchedule thisProductConsumptionSchedule : [   SELECT Id, ProductId, ConsumptionScheduleId 
                                                                        FROM ProductConsumptionSchedule 
                                                                        WHERE ProductId IN : this.setProductIds
                                                                        AND ConsumptionSchedule.IsActive = true
                                                                        AND ConsumptionSchedule.qtc_F_F_Rating__c = true]){
            thisMapProductConsumptionScheduleByProductId.put(thisProductConsumptionSchedule.ProductId, thisProductConsumptionSchedule);
        }
        this.mapProductConsumptionScheduleByProductId = thisMapProductConsumptionScheduleByProductId;
    }
    /**
     * @description Method will query for Consumption Schedules and it's related Consumption Rate
     */
    private void queryConsumptionSchedule(){
        Set<Id> setConsumptionScheduleIds = ApexUtils.pluckIdSet( this.mapProductConsumptionScheduleByProductId.values(), ProductConsumptionSchedule.ConsumptionScheduleId);

        this.mapConsumptionScheduleById = new Map<Id, ConsumptionSchedule>(
            [   SELECT Id, Type,
                    (   SELECT Id, LowerBound, UpperBound, Price, ConsumptionScheduleId, PricingMethod
                        FROM ConsumptionRates
                        ORDER BY ProcessingOrder ASC)
                FROM ConsumptionSchedule
                WHERE Id IN : setConsumptionScheduleIds ]
        );
    }

    /**
     * @description Public method to get the rate given a quantity and Product Id
     * @param   thisQuantity            Quanity used to be calculated
     * @param   thisProductId           Id of the product that will be refernced
     * @return  Calculated total of the rate
     */
    public Decimal getRateByProduct( Integer thisQuantity, Id thisProductId){
        if( this.mapProductConsumptionScheduleByProductId.containsKey( thisProductId )){
            ProductConsumptionSchedule thisProductConsumptionSchedule = this.mapProductConsumptionScheduleByProductId.get( thisProductId );
            Id thisConsumptionScheduleId = thisProductConsumptionSchedule.ConsumptionScheduleId;
            return getRate(thisQuantity, thisConsumptionScheduleId);
        }
        else {
            return 0;
        }
    }

    /**
     * @description private method to get the rate given a quantity and the Consumption Schedule Id
     * @param   thisQuantity            Quanity used to be calculated
     * @param   consumptionScheduleId   Id of the Consumption Schedule that will be refernced
     * @return  Calculated total of the rate
     */
    private Decimal getRate( Integer thisQuantity, Id consumptionScheduleId ){
        if(mapConsumptionScheduleById.containsKey( consumptionScheduleId )){
            ConsumptionSchedule thisConsumptionSchedule = mapConsumptionScheduleById.get( consumptionScheduleId );
            if( thisConsumptionSchedule?.Type == SCHEDULE_TYPE_RANGE ){
                return calculateRangeRate(thisQuantity, thisConsumptionSchedule);
            }
            else if( thisConsumptionSchedule?.Type == SCHEDULE_TYPE_SLAB ) {
                return calculateSlabRate(thisQuantity, thisConsumptionSchedule);
            }
        }
        return 0;
        
    }

     /**
     * @description Method to calcute the Rate if the Consumption Schedule is of type "Range"
     * @param   thisQuantity            Quanity used to be calculated
     * @param   consumptionScheduleId   Id of the Consumption Schedule that will be refernced
     * @return  Calculated total of the rate
     */
    private Decimal calculateRangeRate(Integer thisQuantity, ConsumptionSchedule thisConsumptionSchedule){
        Decimal total = 0;
        for( ConsumptionRate thisConsumptionRate : thisConsumptionSchedule.ConsumptionRates ){
            if( thisQuantity >= thisConsumptionRate.LowerBound 
                && (    thisQuantity < thisConsumptionRate.UpperBound 
                        || thisConsumptionRate.UpperBound == null)){

                if(thisConsumptionRate.PricingMethod == SCHEDULE_PRICING_METHOD_PERUNIT ){

                    total = thisQuantity * thisConsumptionRate.Price;
                }
                else { //Flat fee rate

                    total = thisConsumptionRate.Price;
                }
                break;
            }
        }

        return total;
    }

    /**
     * @description Method to calcute the Rate if the Consumption Schedule is of type "Slab"
     * @param   thisQuantity            Quanity used to be calculated
     * @param   consumptionScheduleId   Id of the Consumption Schedule that will be refernced
     * @return  Calculated total of the rate
     */
    private Decimal calculateSlabRate(Integer thisQuantity, ConsumptionSchedule thisConsumptionSchedule){
        Decimal quantityCount = thisQuantity;
        Decimal lastSlabTo = 1;
        Decimal total = 0;
        for( ConsumptionRate thisConsumptionRate : thisConsumptionSchedule.ConsumptionRates ){
            if( thisConsumptionRate.UpperBound != null && quantityCount > thisConsumptionRate.UpperBound - lastSlabTo ){
                if(thisConsumptionRate.PricingMethod == SCHEDULE_PRICING_METHOD_PERUNIT ){
                    total +=  (thisConsumptionRate.UpperBound - lastSlabTo ) * thisConsumptionRate.Price;
                }
                else { // Flat fee pricing method
                    total += thisConsumptionRate.Price;
                }
            }
            else {
                if(thisConsumptionRate.PricingMethod == SCHEDULE_PRICING_METHOD_PERUNIT ){
                    total += quantityCount * thisConsumptionRate.Price;
                }
                else { // Flat fee pricing method
                    total += thisConsumptionRate.Price;
                }
                quantityCount = 0;
                break;
            }
            quantityCount -= thisConsumptionRate.UpperBound - lastSlabTo;
            lastSlabTo = thisConsumptionRate.UpperBound;
        }

        return total;
    }
}