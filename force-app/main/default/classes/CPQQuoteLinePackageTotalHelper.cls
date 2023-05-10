/**************************************
Author ...............: Ashokkumar, Satish
Modified Date.........: 23-DEC-2020
Description...........: RollUp child lines, list and net price at parent level.

***************************************/
public class CPQQuoteLinePackageTotalHelper {

    public static String safeString(String val){
        String returnVal = '';
        if (val != null){
            returnVal = val;
        }
        return returnVal;
    }
    
    public static Decimal safeDecimal(Decimal val){
        Decimal returnVal = 0;
        if (val != null){
            returnVal = val;
        }
        return returnVal;
    }
    
    //called from  handleBeforeUpdate.qtcQuoteTriggerHandler
    public static void handleBeforeUpdate(List<SBQQ__Quote__c> listTriggerNew){
        try {
            List<SBQQ__QuoteLine__c> qlToSave = new List<SBQQ__QuoteLine__c>();
            Map<Id,SBQQ__Quote__c> idToQuoteMap = new Map<Id,SBQQ__Quote__c>();
            
            List<SBQQ__Quote__c> quoteList=[Select id,SBQQ__Type__c,qtc_AmendSubtotal__c,
                                            (select Id,Name,SBQQ__Quote__r.SBQQ__Type__c,SBQQ__RequiredBy__r.Name,qtc_Group_ID__c,Product_Type__c,qtc_List_Price_Display__c,qtc_Net_Price_Display__c,qtc_NetUnitAmend__c,qtc_Component_List_Term_Price__c,qtc_Component_Net_Term_Price__c,qtc_Pass_Through__c from SBQQ__LineItems__r WHERE qtc_Pass_Through__c = FALSE AND SBQQ__ChargeType__c = 'Recurring' ) from SBQQ__Quote__c where id in:listTriggerNew ];
            for(SBQQ__Quote__c quoteObj : quoteList) {
                idToQuoteMap.put(quoteObj.Id,quoteObj);
                quoteObj.qtc_AmendSubtotal__c = 0;
                if(quoteObj.SBQQ__LineItems__r.size() > 0){
                    calculatePackageAndSubPackageTotals(quoteObj,qlToSave);
                }
            }
            if (qlToSave.size()>0){
                
                SBQQ.TriggerControl.disable();
                Database.update(qlToSave);  
                for (SBQQ__Quote__c q : listTriggerNew) {
                    if (idToQuoteMap.containsKey(q.Id) && idToQuoteMap.get(q.id) != null) {
                        q.qtc_AmendSubtotal__c = safeDecimal(idToQuoteMap.get(q.id).qtc_AmendSubtotal__c);
                    }
                }
            }
        }catch(Exception e){
            System.debug('Error in bundle component price rollup1: ' + e.getMessage());
            System.debug('Error in bundle component price rollup2: ' + e.getStackTraceString());
        } finally {
            SBQQ.TriggerControl.enable(); 
        }
    }
    class QuoteLineComponent{
        public Decimal componentListPriceTotal { get; set; }
        public Decimal componentNetPriceTotal { get; set; }
        public Decimal compAmendNetPrice { get; set; }
        public List<SBQQ__QuoteLine__c> quoteLines { get; set; }
        public QuoteLineComponent(){
            quoteLines = new List<SBQQ__QuoteLine__c>();
        }
        public void add(SBQQ__QuoteLine__c qLine){
            quoteLines.add(qLine);
        }
    }
    
    /*
    Steps followed:- 
        1- Make a map of GroupID and RequiredById as key and value as list of lines have same GroupID and RequiredByID.
        2- Iterate Map and rollup lines qtc_list_display_price and qtc_net_display_price if quote's type is quote else qtc_unit_amend_price.
        3- Set rolled up value at component_price where GroupId and line’s ID is equals to Map#1 key GroupId and RequiredByID respectively.
        4- Rollup component_price of package and sub-package type lines and add into parent lines where GroupID and LineID is equals to Line's GroupId and RequiredByID
     */   
    public static void calculatePackageAndSubPackageTotals(SBQQ__Quote__c quote,List<SBQQ__QuoteLine__c> qlToSave) {
        List<SBQQ__QuoteLine__c> quoteLines= quote.SBQQ__LineItems__r;
        Map<String, QuoteLineComponent> qLComponentsMap = new Map<String, QuoteLineComponent>();
        Map<String, SBQQ__QuoteLine__c> qLMap = new Map<String, SBQQ__QuoteLine__c>();

        //create a List of QuoteLines by Group ID, RequiredByID and add it to the Map:quoteLinesComponent
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){ 
            // if requiredByID null, it mean bundle parent line
            qLMap.put(quoteLine.ID,quoteLine);
            qLMap.put(quoteLine.qtc_Group_ID__c+':'+quoteLine.ID,quoteLine);
            if (isPackageOrSubpackge(quoteLine)){
                qlToSave.add(quoteLine);
            }
            
            if (quoteLine.qtc_Group_ID__c != null && quoteLine.SBQQ__RequiredBy__r.ID != null){
                QuoteLineComponent component = qLComponentsMap.get(quoteLine.qtc_Group_ID__c+':'+quoteLine.SBQQ__RequiredBy__r.ID);
                //if array for the Group ID+RequiredBy doesn't exist, create one and add to the map
                if (component == null){
                    component = new QuoteLineComponent();
                    qLComponentsMap.put(quoteLine.qtc_Group_ID__c+':'+quoteLine.SBQQ__RequiredBy__r.ID, component);
                }
                component.add(quoteLine);
            }
        }
        
        //now iterate quote lines for each components
        for (String compKey : qLComponentsMap.keySet()) {
            QuoteLineComponent qlComponent = qLComponentsMap.get(compKey);
            calculateComponentTotal(quote,qlComponent,qLMap.get(compKey));
        }
   
        // adding subpackage component price into package line
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            if (isPackageOrSubpackge(quoteLine)){
                if(quoteLine.SBQQ__RequiredBy__r!=null){
                    SBQQ__QuoteLine__c parentLine = qlMap.get(quoteLine.SBQQ__RequiredBy__r.ID);
                    if(quoteLine.qtc_Group_ID__c == parentLine.qtc_Group_ID__c){
                        parentLine.qtc_Component_List_Term_Price__c=parentLine.qtc_Component_List_Term_Price__c+safeDecimal(quoteLine.qtc_Component_List_Term_Price__c);
                        parentLine.qtc_Component_Net_Term_Price__c=parentLine.qtc_Component_Net_Term_Price__c+safeDecimal(quoteLine.qtc_Component_Net_Term_Price__c);
                    }
                    if(safeString(quote.SBQQ__Type__c).equals('Amendment')){
                    	parentLine.qtc_CompAmendNetPrice__c += safeDecimal(quoteLine.qtc_Component_Net_Term_Price__c);
                    }
                }
            }
            // populating amendSubTotal at quote level
            if(safeString(quote.SBQQ__Type__c).equals('Amendment')){
                quote.qtc_AmendSubtotal__c += safeDecimal(quoteLine.qtc_NetUnitAmend__c);
            }
        }
        
    }

    public static void calculateComponentTotal(SBQQ__Quote__c quote, QuoteLineComponent qlComp,SBQQ__QuoteLine__c parentLine){
        Double componentListTotal = 0.0;
        Double componentNetTotal = 0.0;
        //add prices from PID and SID lines
        for(SBQQ__QuoteLine__c quoteLine : qlComp.quoteLines){ 
            if(!quoteLine.qtc_Pass_Through__c) {
                if(safeString(quote.SBQQ__Type__c).equals('Amendment')){
                     componentListTotal = 0.0;
                     componentNetTotal += safeDecimal(quoteLine.qtc_NetUnitAmend__c);
                } else {
                    componentListTotal += safeDecimal(quoteLine.qtc_List_Price_Display__c);
                    componentNetTotal += safeDecimal(quoteLine.qtc_Net_Price_Display__c);
                }
            }
        }
     
        if(parentLine!=null){
            System.debug('parentLine.name--'+parentLine.qtc_Group_ID__c+':'+parentLine.ID);
            parentLine.qtc_Component_List_Term_Price__c = componentListTotal;
            parentLine.qtc_Component_Net_Term_Price__c = componentNetTotal;
            
            // setting only at package line
            if(parentLine.SBQQ__RequiredBy__c == null && safeString(quote.SBQQ__Type__c).equals('Amendment')){
                parentLine.qtc_CompAmendNetPrice__c = safeDecimal(componentNetTotal);
            }
        }
        
    }
    
    public static boolean isPackageOrSubpackge(SBQQ__QuoteLine__c quoteLine){
        String productRecordType = safeString(quoteLine.Product_Type__c);
        if ((productRecordType.equalsIgnoreCase('Package')) || (productRecordType.equalsIgnoreCase('Sub-Package'))){
            return true;
        }else{
            return false;
        }
    }
}