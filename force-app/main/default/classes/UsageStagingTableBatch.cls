/*
*   @author ATG
*   @description Batch class to evaluate and create Usage records from Usage Summaries and Usage Staging Table Records
*/
global with sharing class UsageStagingTableBatch extends ErrorLogUtil implements Database.Batchable<AggregateResult> {
    public STRING                           PRODUCT_CODE_CONNECTED_PAYMENTS     = 'S200-2001-0000',
                                            USAGE_STATUS_EXPECTING_USAGE        = 'Expecting Usage',
                                            USAGE_SUMMARY_STATUS_NEW            = 'New';
    public static final String              INVALID_MISMATCH_MESSAGE = 'The number of Usage Staging Table records does not equal the number of matching Usage Summary records';
    private Map<String, UsageBatchModel>    mapUsageBatchModelByReferenceKey    = new Map<String, UsageBatchModel>();
    private Map<String, MCNDateModel>       mapMCNDateModelByMCN                = new Map<String, MCNDateModel>();
    private List<String>                    listUsageStagingTableWhereClause    = new List<String>();
    private Set<Id>                         setProductIds                       = new Set<Id>();


    /**
     * @description Batch Start method that executes and aggregate query of Usage Staging Tables
     * @return   An Interable Aggregate Result
     */
    global Iterable<AggregateResult>  start(Database.BatchableContext BC) {

        //aggregate query group by MCN and start date month/year

        String  query  = 'SELECT Count(Id) resultCount, qtc_MasterCustomerNumber__c, CALENDAR_YEAR(qtc_SummaryStartDate__c) resultYear, ';
                query += 'CALENDAR_MONTH(qtc_SummaryStartDate__c) resultMonth ';
                query += 'FROM Usage_Staging_Table__c ';
                query += 'WHERE qtc_UsageStagingProcessed__c = false ';
                query += 'GROUP BY qtc_MasterCustomerNumber__c, CALENDAR_YEAR(qtc_SummaryStartDate__c), CALENDAR_MONTH(qtc_SummaryStartDate__c)';
        return new AggregateResultIterable(query);
    }

    /**
     * @description Batch Execute method that will evaluate and create Usage records
     */
    global void execute( Database.batchableContext info, List<sObject> scope ){
        buildAggregateResultReferenceMap( scope );

        
        if( !listUsageStagingTableWhereClause.isEmpty() ){
            for( Usage_Staging_Table__c thisUsageStagingTable : queryUsageStagingTable() ){ //update this to a query loop
                String thisReferenceKey = getReferenceKey( thisUsageStagingTable );
                 
                if(mapUsageBatchModelByReferenceKey.containsKey( thisReferenceKey )){
                    UsageBatchModel thisUsageBatchModel = mapUsageBatchModelByReferenceKey.get( thisReferenceKey );
                    thisUsageBatchModel.listUsageStagingTable.add( thisUsageStagingTable );
                }
                
            }
        }

        if( !mapMCNDateModelByMCN.isEmpty() ){
            List<blng__UsageSummary__c> listUsageSummaries  = queryUsageSummaries( mapMCNDateModelByMCN );

            for( blng__UsageSummary__c thisUsageSummary : listUsageSummaries){ //query loop
                String thisReferenceKey = getReferenceKey( thisUsageSummary );
                setProductIds.add( thisUsageSummary.blng__OrderProduct__r.Product2Id);
                if(mapUsageBatchModelByReferenceKey.containsKey( thisReferenceKey )){
                    UsageBatchModel thisUsageBatchModel = mapUsageBatchModelByReferenceKey.get( thisReferenceKey );
                    thisUsageBatchModel.mapUsageSummaryById.put( thisUsageSummary.Id, thisUsageSummary );
                    
                    this.mapUsageBatchModelByReferenceKey.put( thisReferenceKey, thisUsageBatchModel );
                }
            } 
        }

        qtcConsumptionScheduleService consumptionScheduleService = new qtcConsumptionScheduleService( setProductIds );
        Map<Id, blng__Usage__c> mapUsagesToInsertByUsageStagingTableId = new Map<Id, blng__Usage__c>();
        List<Usage_Staging_Table__c> listUsageStagingTableToUpdate = new List<Usage_Staging_Table__c>();
        for( UsageBatchModel thisUsageBatchModel : mapUsageBatchModelByReferenceKey.values() ){

            if( thisUsageBatchModel.isValid() ){
                thisUsageBatchModel.setConsumptionScheduleService( consumptionScheduleService );
                thisUsageBatchModel.evalulateAndGenerateUsageRecords();

                mapUsagesToInsertByUsageStagingTableId.putAll( thisUsageBatchModel.mapUsageRecordsToInsertByUsageStagingTableIds );
            }
            else {
                for(Usage_Staging_Table__c thisUsageStagingTable : thisUsageBatchModel.listUsageStagingTable){
                    listUsageStagingTableToUpdate.add( 
                    new Usage_Staging_Table__c(
                        Id = thisUsageStagingTable.Id,
                        qtc_BatchLog__c = INVALID_MISMATCH_MESSAGE
                    )
                );
                }
            }
        }
        try{
            insert mapUsagesToInsertByUsageStagingTableId.values();

            for( Id usageStagingTableId : mapUsagesToInsertByUsageStagingTableId.keyset()){
                blng__Usage__c thisUsage = mapUsagesToInsertByUsageStagingTableId.get( usageStagingTableId);
                listUsageStagingTableToUpdate.add( 
                    new Usage_Staging_Table__c(
                        Id = usageStagingTableId,
                        qtc_Usage__c = thisUsage.Id,
                        qtc_BatchLog__c = '',
                        qtc_UsageStagingProcessed__c = true
                    )
                );
            }

            update listUsageStagingTableToUpdate;
        }catch( DmlException ex){
            log('UsageStagingTableBatch', ex);
            commitLogs();

            for( Id usageStagingTableId : mapUsagesToInsertByUsageStagingTableId.keyset()){
                listUsageStagingTableToUpdate.add( 
                    new Usage_Staging_Table__c(
                        Id = usageStagingTableId,
                        qtc_BatchLog__c = ex.getMessage()?.left(255)
                    )
                );
            }
            update listUsageStagingTableToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC){

    }

    /**
     * @description Method will evalute the list of AggregateResults and generate reference maps. The Inner Class UsageBatchModel 
     *              will also be instantiated to group together Usage Staging Tables and Usage Summaries.
     * @param   scope   List of AggregateResults
     */
    private void buildAggregateResultReferenceMap(  List<sObject> scope ){
        for(sObject thisSobject : scope ){
            AggregateResult thisAggregateResult = (AggregateResult)thisSobject;
            UsageBatchModel thisUsageBatchModel = new UsageBatchModel( thisAggregateResult );
            String thisReferenceKey = thisUsageBatchModel.getMapKey();
            
            MCNDateModel thisMCNDateModel = mapMCNDateModelByMCN.get( thisUsageBatchModel.masterCustomerNumber);
            if(thisMCNDateModel == null){
                thisMCNDateModel = new MCNDateModel();
            }
            thisMCNDateModel.evaluateAggregateResult( thisAggregateResult );
            
            listUsageStagingTableWhereClause.add( thisUsageBatchModel.getUsageStagingTableWhereClause() );
            
            mapMCNDateModelByMCN.put( thisUsageBatchModel.masterCustomerNumber, thisMCNDateModel );
            mapUsageBatchModelByReferenceKey.put( thisReferenceKey, thisUsageBatchModel );
        }

     
    }

     /**
     * @description Query method to query for Usage Staging Tables
     * @return  List of Usage Staging Table Records
     */
    private List<Usage_Staging_Table__c> queryUsageStagingTable(){
        String usageStagingTableWhereClause = String.join( listUsageStagingTableWhereClause, ' OR ');
        String  usageStagingTableQuery  = 'SELECT Id,qtc_MasterCustomerNumber__c, qtc_SummaryStartDate__c, qtc_SummaryEndDate__c, qtc_UsageSummaryId__c, ';
                usageStagingTableQuery +=   'qtc_MatchingAttribute__c, qtc_TotalQuantity__c, qtc_MatchingId__c ';
                usageStagingTableQuery += 'FROM Usage_Staging_Table__c ';
                usageStagingTableQuery += 'WHERE qtc_UsageStagingProcessed__c = false ';
                usageStagingTableQuery += 'AND ( {0} ) ';
        String formattedQuery = String.format(usageStagingTableQuery, new List<String>{usageStagingTableWhereClause});
        return Database.query( formattedQuery );
    }

     /**
     * @description Query method to query for Usage Summaries
     * @param   mapMCNDateModelByMCN   Map of Inner Class MCNDateModel keyed by the Master Customer Number
     * @return  List of Usage Summary Records
     */
    private List<blng__UsageSummary__c> queryUsageSummaries( Map<String, MCNDateModel> mapMCNDateModelByMCN ){
        List<String> listUsageSummaryWhereClause = new List<String>();
        for( MCNDateModel thisModel : mapMCNDateModelByMCN.values() ){
            listUsageSummaryWhereClause.add( thisModel.getWhereClause() );
        }
        String usageSummaryWhereClause = String.join(listUsageSummaryWhereClause, ' OR ');

        //query field to exclude 8/2
        String  usageSummaryQuery    = 'SELECT Id, blng__Order__c, blng__Order__r.qtc_Master_Customer_Number__c, blng__SummaryStartDate__c, blng__Order__r.EndDate, ';
                usageSummaryQuery   +=      'blng__OrderItemConsumptionSchedule__c, qtc_Do_Not_Rate__c, blng__Account__c, blng__OrderProduct__c, blng__UnitOfMeasure__c, ';
                usageSummaryQuery   +=      'blng__OrderProduct__r.Product2Id, blng__MatchingAttribute__c ';
                usageSummaryQuery   += 'FROM blng__UsageSummary__c ';
                usageSummaryQuery   += 'WHERE qtc_Usage_Status__c = \'\'{0}\'\' ';
                usageSummaryQuery   += 'AND blng__OrderProduct__r.Product2.ProductCode = \'\'{1}\'\' ';
                usageSummaryQuery   += 'AND ( {2} ) '; 
                usageSummaryQuery   += 'AND blng__Status__c = \'\'{3}\'\' ';
        		usageSummaryQuery   += 'AND blng__OrderProduct__r.Order.Status = \'Activated\''; // Jesse D - add condition to restrict summaries to activated orders
        String formattedQuery = String.format(
            usageSummaryQuery, 
            new List<String>{USAGE_STATUS_EXPECTING_USAGE, 
                PRODUCT_CODE_CONNECTED_PAYMENTS, 
                usageSummaryWhereClause,
                USAGE_SUMMARY_STATUS_NEW
        });
        return Database.query( formattedQuery );
    }

     /**
     * @description Overload method to build and return a reference key for the Usage Staging Table
     * @param   thisUsageStagingTable   Usage Staging Table record that is being referneced
     * @return  A reference key to be used for Map collection keys
     */
    private String getReferenceKey( Usage_Staging_Table__c thisUsageStagingTable ){
        String thisMasterCustomerNumber = thisUsageStagingTable.qtc_MasterCustomerNumber__c;
        Integer thisYear = thisUsageStagingTable.qtc_SummaryStartDate__c?.year();
        Integer thisMonth = thisUsageStagingTable.qtc_SummaryStartDate__c?.month();
        return generateMapKey(thisMasterCustomerNumber, thisYear, thisMonth);
    }

    /**
     * @description Overload method to build and return a reference key for the Usage Summary
     * @param   thisUsageSummary   Usage Summary record that is being referneced
     * @return  A reference key to be used for Map collection keys
     */
    private String getReferenceKey( blng__UsageSummary__c thisUsageSummary ){
        String thisMasterCustomerNumber = thisUsageSummary.blng__Order__r?.qtc_Master_Customer_Number__c;
        Integer thisYear = thisUsageSummary.blng__SummaryStartDate__c.year();
        Integer thisMonth = thisUsageSummary.blng__SummaryStartDate__c.month();
        return generateMapKey(thisMasterCustomerNumber, thisYear, thisMonth);
    }

    /**
     * @description Method that will create a reference key base on input parameters
     * @param   masterCustomerNumber    Master Customer Number of the current Object
     * @param   year                    Year of the date being referenced
     * @param   month                   Month of the date being referenced
     * @return  A reference key to be used for Map collection keys
     */
    private static String generateMapKey(String masterCustomerNumber, Integer year, Integer month){
        List<String> listParam = new List<String>{ masterCustomerNumber, String.valueOf(year), String.valueOf(month)};
        return String.format('{0}-{1}-{2}', listParam);

    }

    /**
     * @description An Inner Class used to evaluate the Aggregate Results and build out a where clause for the Usage Summaries
     */
    private class MCNDateModel{
        public String masterCustomerNumber;
        Map<Integer, List<Integer>> mapListMonthsByYear = new Map<Integer, List<Integer>>();

        /**
         * @description Constructor for this Inner class, will take the month and year from the aggregate query and build a map of year and months
         * @param   thisAggregateResult   Aggregate Result that is being evaluated
         */
        public void evaluateAggregateResult( AggregateResult thisAggregateResult ){
            Integer thisYear = Integer.valueOf( thisAggregateResult.get('resultYear') );
            Integer thisMonth = Integer.valueOf( thisAggregateResult.get('resultMonth') );
            this.masterCustomerNumber = String.valueOf( thisAggregateResult.get('qtc_MasterCustomerNumber__c'));

            if( mapListMonthsByYear.containsKey(thisYear)){
                List<Integer> listMonths = mapListMonthsByYear.get( thisYear );
                if( !listMonths.contains(thisMonth) ) {
                    listMonths.add( thisMonth );
                }
                this.mapListMonthsByYear.put(thisYear, listMonths);
            }
            else {
                List<Integer> listMonths = new List<Integer>{ thisMonth };
                this.mapListMonthsByYear.put(thisYear, listMonths);
            }
        }

        /**
         * @description This method will return a where clause for this Aggregate result to be used in the Usage Summary Query
         * @return Where Clause for this Aggregate Result
         */
        public String getWhereClause(){
            List<String> listYearClause = new List<String>();

            for(Integer thisYear : mapListMonthsByYear.keySet() ){
                List<Integer> listMonths = mapListMonthsByYear.get( thisYear );
                List<String> listMonthClauseString = new List<String>();
                for( Integer thisMonth : listMonths){
                    List<String> stringMonthParameters = new List<String>{
                        String.valueOf(thisMonth) 
                    };
                    String monthClause = String.format( 'CALENDAR_MONTH(blng__SummaryStartDate__c) = {0}', stringMonthParameters);
                    listMonthClauseString.add(monthClause);
                }
    
                List<String> stringYearParameters = new List<String>{
                    String.valueOf(thisYear),
                    String.join(listMonthClauseString, ' OR ')
                };
                String yearWhereClause = String.format('( CALENDAR_YEAR(blng__SummaryStartDate__c) = {0} AND ({1}) )', stringYearParameters);
                listYearClause.add( yearWhereClause);
            }
            List<String> stringWherePrameters = new List<String>{
                this.masterCustomerNumber,
                String.join( listYearClause, ' OR ')
            };
            
            String whereClause = '( blng__Order__r.qtc_Master_Customer_Number__c = \'\'{0}\'\' AND ({1}) )';
            String formattedWhereClause = String.format( whereClause, stringWherePrameters );
            return formattedWhereClause;
        }
    }

     /**
     * @description An Inner Class used to evaluate the Usage Staging Tables and Usage Summaries grouped by starting month
     */
    private class UsageBatchModel{
        public Integer year;
        public Integer month;
        public String masterCustomerNumber;
        qtcConsumptionScheduleService consumptionScheduleService;
        public Double perUnitPriceRate;

        private Time defaultTime = Time.newInstance(12, 0, 0, 0);
        public Integer totalValidQuantity = 0;
        public List<Usage_Staging_Table__c> listUsageStagingTable = new List<Usage_Staging_Table__c>();
        public Map<Id, blng__UsageSummary__c> mapUsageSummaryById = new Map<Id, blng__UsageSummary__c>();
        Map<String, List<SBQQ__OrderItemConsumptionRate__c>> mapConsumptionRateByConsumputionScheduleId = new Map<String, List<SBQQ__OrderItemConsumptionRate__c>>();

        public List<Usage_Staging_Table__c> listUsageStagingTableToUpdate = new List<Usage_Staging_Table__c>();
        Map<Id, blng__Usage__c> mapUsageRecordsToInsertByUsageStagingTableIds= new Map<Id, blng__Usage__c>();

         /**
         * @description Constructor for this Inner class, this willt ake in an Aggregate Result and set the Year, Month, and Master Customer Number
         * @param   thisAggregateResult   Aggregate Result that is being evaluated
         */
        public UsageBatchModel( AggregateResult thisAggregateResult){
            this.year = Integer.valueOf( thisAggregateResult.get('resultYear') );
            this.month = Integer.valueOf( thisAggregateResult.get('resultMonth') );
            this.masterCustomerNumber = String.valueOf( thisAggregateResult.get('qtc_MasterCustomerNumber__c') );
        }

         /**
         * @description Constructor for this Inner class, will set the min and max start DateTime for this
         * @return      Get the Where Clause for Usage Staging Table for this Aggregate Result
         */
        public String getUsageStagingTableWhereClause(){
            List<String> listParam = new List<String>{ masterCustomerNumber, String.valueOf(year), String.valueOf(month)};
            String whereClause = String.format('( qtc_MasterCustomerNumber__c = \'\'{0}\'\' AND CALENDAR_YEAR(qtc_SummaryStartDate__c) = {1} AND CALENDAR_MONTH(qtc_SummaryStartDate__c) = {2} )', listParam);
            return whereClause;
        }

        /**
         * @description Method will evaluate teh Usage Staging Table records with its corresponding Usage Summary Records and generate a
         *              list of Usage Staging Tables to be Updated and Usage Records for insert.
         */
        public void evalulateAndGenerateUsageRecords(){
            Id thisProductId;
            for(Usage_Staging_Table__c thisUsageStagingTable : this.listUsageStagingTable){
                blng__UsageSummary__c thisUsageSummary = this.mapUsageSummaryById.get( thisUsageStagingTable.qtc_UsageSummaryId__c );
                if(thisUsageSummary == null ){
                    continue;
                }
                if( !thisUsageSummary.qtc_Do_Not_Rate__c ){
                    totalValidQuantity += Integer.valueOf(thisUsageStagingTable.qtc_TotalQuantity__c);
                    thisProductId = thisUsageSummary.blng__OrderProduct__r.Product2Id;
                }
            }

            if( totalValidQuantity == 0 ){
                perUnitPriceRate = 0;
            } else {
                perUnitPriceRate = consumptionScheduleService.getRateByProduct( totalValidQuantity, thisProductId) / totalValidQuantity;
            }

            for(Usage_Staging_Table__c thisUsageStagingTable : listUsageStagingTable){
                blng__UsageSummary__c thisUsageSummary = this.mapUsageSummaryById.get( thisUsageStagingTable.qtc_UsageSummaryId__c );
                mapUsageRecordsToInsertByUsageStagingTableIds.put(
                    thisUsageStagingTable.Id, 
                    generateUsageRecord( thisUsageStagingTable, thisUsageSummary)
                );
            }
        }

         /**
         * @description Constructor for this Inner class, will set the min and max start DateTime for this
         * @param   thisUsageStagingTable   Usage Staging Table record to be evaluated
         * @param   thisUsageSummary        Usage Summary Record to be evaluated
         * @return  Instantiated Usage record to be inserted
         */
        private blng__Usage__c generateUsageRecord( Usage_Staging_Table__c thisUsageStagingTable, blng__UsageSummary__c thisUsageSummary){
            List<SBQQ__OrderItemConsumptionRate__c> listConsumptionRates = this.mapConsumptionRateByConsumputionScheduleId?.get( thisUsageSummary.blng__OrderItemConsumptionSchedule__c);
            blng__Usage__c thisUsage = new blng__Usage__c(
                //CurrencyIsoCode = thisUsageSummary.CurrencyIsoCode,
                qtc_Master_Customer_Number__c = thisUsageStagingTable.qtc_MasterCustomerNumber__c,
                blng__MatchingId__c = thisUsageStagingTable.qtc_MatchingId__c,
                blng__StartDateTime__c = DateTime.newInstance( thisUsageStagingTable.qtc_SummaryStartDate__c, defaultTime ),
                blng__EndDateTime__c = DateTime.newInstance( thisUsageStagingTable.qtc_SummaryEndDate__c, defaultTime ),
                blng__PreratedQuantity__c = thisUsageStagingTable.qtc_TotalQuantity__c,
                
                blng__PreratedAmount__c = thisUsageSummary.qtc_Do_Not_Rate__c ? 0 : ( perUnitPriceRate * thisUsageStagingTable.qtc_TotalQuantity__c ),
                
                blng__Account__c = thisUsageSummary.blng__Account__c,
                blng__MatchingAttribute__c = thisUsageSummary.blng__MatchingAttribute__c,
                blng__Order__c = thisUsageSummary.blng__Order__c,
                blng__OrderProduct__c = thisUsageSummary.blng__OrderProduct__c,
                blng__UnitOfMeasure__c = thisUsageSummary.blng__UnitOfMeasure__c,
                blng__UsageSummary__c = thisUsageSummary.Id
            );
            return thisUsage;
        }

         /**
         * @description Sets the qtcConsumptionScheduleService service object for the inner class 
         * @param   inputConsumptionScheduleService   qtcConsumptionScheduleService service object used to calculate the
         *                                            Total rates base on the Consumption Schedule
         */
        private void setConsumptionScheduleService(qtcConsumptionScheduleService inputConsumptionScheduleService){
            this.consumptionScheduleService = inputConsumptionScheduleService;
        }

        /**
         * @description Returns the Reference Map Key for the current instance
         * @return  A reference key to be used for Map collection keys
         */
        private String getMapKey(){
            return generateMapKey( masterCustomerNumber, year, month);
        }
    

         /**
         * @description Method used to validate the current inner class instance
         * @return  Boolean value to determine if the current instance is valid
         */
        public boolean isValid(){
            boolean isValid = false;
            System.debug('list usage staging table: ' + JSON.serialize(listUsageStagingTable));
            System.debug('usage staging table size: ' + listUsageStagingTable.size());
            System.debug('map usage summary by id: ' + JSON.serialize(mapUsageSummaryById));
            System.debug('map usage summary size: ' + mapUsageSummaryById.size());
            if( !listUsageStagingTable.isEmpty() 
                && !mapUsageSummaryById.isEmpty()
                && listUsageStagingTable.size() == mapUsageSummaryById.size() ){
                
                isValid = true;
            }
            return isValid;
        }

    }

}