/*
##################################################################################################
# Class Name............................:SchedulerClass.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public class SchedulerClass {
    //public static final Set<ID> Hospitality_IDS = new Set<ID>{'00e70000000xBoN','00e70000000xBoS','00e70000000xBoX'};
    public static final Set<ID> Hospitality_IDS = NSCCommonInfoUtil.getIdSetOf('SchedulerClass_HospId'); // Used same metadata in OpportunityLeadTimeMsg_ltng
        
    @AuraEnabled      
        public static Map<String, opportunity> getOpportunity(String rdId) {
            Map<String, opportunity> mpOppDetail = new Map<String, opportunity>();
            String admin04;
            
         	//Changes done by Yogesh - related to Story EBA_SF-1918
            Set<Id> profileIds = NSCCommonInfoUtil.getIdSetOf('Admn_Profle_Id'); // Used same metadata in fetchOpportunityDetail Class
            Set<Id> NonAdmnprofileIds = NSCCommonInfoUtil.getIdSetOf('Non_Admn_Profle_Id'); // Used same metadata in fetchOpportunityDetail Class
            
            /* if(userInfo.getProfileId()=='00e70000000x3egAAA' || userInfo.getProfileId()=='00e70000000x3eg'){
admin04='Admin';
}
else if(userInfo.getProfileId()== '00e700000013gPe'|| userInfo.getProfileId()=='00e700000013gPeAAI'
||userInfo.getProfileId() =='00e70000000sR8U' || userInfo.getProfileId()=='00e70000000sR8UAAU'){
admin04='Other Admin';
}*/
            if(profileIds.Contains(userInfo.getProfileId())){
                admin04='Admin';
            }
            else if(NonAdmnprofileIds.contains(userInfo.getProfileId())){
                admin04='Other Admin';
            }
            else{
                admin04='Non Admin';
            }
            // End Changes by Yogesh
            Opportunity Opp= [ SELECT Id, Name,IsClosed,/*Solution_Portfolio__c,- P360 Initial Change - Ahad*/ Expected_Delivery_Date__c, Amount, CurrencyIsoCode FROM Opportunity  
                              WHERE Id =:rdId]; 
            mpOppDetail.put(admin04,Opp);
            return (mpOppDetail);
        }   
    @AuraEnabled      
    public static List<String> validateOppForWarning(String rdId) {
        List<String> warningMsgs=new List<String>();
        //@@ Ahad validate unscheduled HW
        List<OpportunityLineItem > opportunityOlItems = new List<OpportunityLineItem >();
        opportunityOlItems = [Select Id FROM OpportunityLineItem where OpportunityId = :rdId and Product2.Product_Category__c = 'Hardware' and Unscheduled_Quantity__c >0 and HasSchedule=true];
        //commented by saritha NC_AGILE-320
        /*if(opportunityOlItems !=null && opportunityOlItems.Size()>0){
warningMsgs.add('Unscheduled HW products are omitted from the demand plan and may impact customer delivery.  Enter a product schedule or contact your Demand Planner to manage the delivery risk.')  ;
}*/
        //End Saritha
        //@@ Ahad validate Amount 
        Opportunity opp=[SELECT Id, Name,/*Solution_Portfolio__c,- P360 Initial Change - Ahad*/ Expected_Delivery_Date__c, CloseDate, Amount, CurrencyIsoCode FROM Opportunity  
                         WHERE Id =:rdId] ;
        //commented by saritha NC_AGILE-320
        /*Map<String,Double> currencyTypeMap=new Map<String,Double>();
for (CurrencyType c : [Select c.IsoCode, c.ConversionRate from CurrencyType c where c.IsActive = true])
currencyTypeMap.put(c.IsoCode, c.ConversionRate);        
Double amountInUSD = (opp.Amount.doubleValue())/ (Double.valueOf(currencyTypeMap.get(opp.CurrencyIsoCode)));
if(amountInUSD>10000000.00){
warningMsgs.add('This opportunity amount exceeds $10M.')  ;

}*/
        //End Saritha
        // @@Ahad  validate Lead time
        try{
            
            //Opportunity opportunityWarning = [Select Id, CloseDate, Expected_Delivery_Date__c, Solution_Portfolio__c, Pricebook2Id, CurrencyIsoCode,Amount, Name, ownerId from Opportunity where Id = :pseOpportunity.Id];
            
            //Changes made by DF250061 on 24/09/2011 starts here
            //Changes made to exclude HSR Profiles 20120327
            if(!HOSPITALITY_IDS.contains(UserInfo.getProfileId())){
                /*if(opp.Solution_Portfolio__c != 'Consumables' && - P360 Initial Change - Ahad*/
                if(opp.Expected_Delivery_Date__c != null && opp.CloseDate != null){
                    //Lead time is the difference Between the EBD & EDD dates.
                    Integer oppLeadTime = opp.CloseDate.daysBetween(opp.Expected_Delivery_Date__c); 
                    List<OpportunityLineItem> Oli_list = [Select PricebookEntryId, 
                                                          //PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name, 
                                                          PricebookEntry.Product2.Product_Category__c 
                                                          From OpportunityLineItem 
                                                          where PricebookEntry.Product2.Product_Category__c = 'Hardware'
                                                          and OpportunityId =: opp.Id
                                                         ];
                    
                    // Code for new criteria on Lead time message to check schedule date before warning                
                    List<OpportunityLineItemSchedule> Olis_list = [  Select OpportunityLineItemId,id,quantity, scheduleDate
                                                                   From OpportunityLineItemSchedule 
                                                                   where OpportunityLineItemId in :Oli_list order by OpportunityLineItemId ASC, scheduleDate  ASC                                                     
                                                                  ]; 
                    Map<ID, Integer> oppLeadTime_Map = new Map<ID, Integer>();                                      
                    Id Previous = null;
                    // Populate map with line item id and day between book date and latest scheduledate
                    if(Olis_list != null && Olis_list.size()>0) {                         
                        for(OpportunityLineItemSchedule olis: Olis_list ) {                     
                            if(previous != olis.OpportunityLineItemId){
                                oppLeadTime_Map.put(olis.OpportunityLineItemId,opp.CloseDate.daysBetween(date.newInstance(olis.scheduleDate.Year(), olis.scheduleDate.Month(),opp.Expected_Delivery_Date__c.Day())));
                                previous = olis.OpportunityLineItemId;
                            }       
                        }                                     
                    }
                    //Empty If statement was commented
                    //if(Oli_list != null && Oli_list.size()>0) {
                    //Fetch currently used advocated solutions
                    /* p360 Ravikant : advocatedSolutions is no more use
* Set<String> advocatedSolutions = new Set<String>(); 
for(OpportunityLineItem oli: Oli_list ) {
advocatedSolutions.add(oli.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
}*/
                    //Query and create a map of currently used adocated solution with lead time.
                    ////P-360 initial changes- Ravikant, Lead Time functionality not applicable 
                    /*Map<String, Double> advSol_LeadTime_Map = new Map<String, Double>();
List<Advocated_Solution__c> advSol_leadTime = [Select Name, Lead_Time__c From Advocated_Solution__c where Name in :advocatedSolutions];
for(Advocated_Solution__c leadTimeInfo: advSol_leadTime){
advSol_LeadTime_Map.put(leadTimeInfo.Name, leadTimeInfo.Lead_Time__c);
}

System.debug(advSol_LeadTime_Map);
String message = 'The interval between the Expected Book Date and Product Schedule is shorter than the current lead time for HW products. Extend your Product Schedule for Hardware or contact your Demand Planner to manage the delivery risk.';
Double productLeadTime = null; 
for(OpportunityLineItem oli: Oli_list ){
productLeadTime = advSol_LeadTime_Map.get(oli.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
if(productLeadTime != null && oppLeadTime < productLeadTime){
if(oppLeadTime_Map.get(oli.id)<productLeadTime){
warningMsgs.add(message)  ;                              
break;
}
}
}*/
                    //}
                }
            }   
            
            
        } catch (Exception e) {
            System.debug('[ProductScheduleExtensions/showWarning] -> Exception occured while processing the warning message : ' + e);
        }
        return warningMsgs;
    }
    
    @AuraEnabled
    public static List<WrapperFavorite> getProducts() {
        List<WrapperFavorite> prodList =new List<WrapperFavorite>();
        List<Product2> products = [select id, name from product2 Limit 2];
        for(Product2 prod: products) {
            WrapperFavorite sw= new WrapperFavorite();
            sw.ProductId = prod.id;
            sw.selected = false;
            prodList.add(sw);
        }
        system.debug('HiHi'+prodList);
        
        return prodList;
    }
    
    @Auraenabled
    public static List<WrapperProductScheduleController> ScheduleCalculateWrapper(String OppotunityId){
        boolean Previously = true; 
        
        return ProductScheduleController.ScheduleCalculateWrapper(OppotunityId,Previously);
    }
    @AuraEnabled    
    public Static String SaveManegeSchedule1(String JsonString){
        System.debug('JsonString'+JsonString);
        String isSuccess = ProductScheduleController.SaveManegeSchedule(JsonString);
        return isSuccess;
    }
    @Auraenabled
    public static List<WrapperProductScheduleController> DeleteOLI1( Id[] ProductId,String OppotunityId){
        System.debug('*****Product Selected'+ProductId);
        list<OpportunityLineItem> lstDelete = new list<OpportunityLineItem>(); 
        set<id> ProductsId = new set<id>();
        for(Id wp: ProductId){ 
            ProductsId.add(wp);
        }
        for(Id i:ProductsId){
            OpportunityLineItem obj = new OpportunityLineItem(Id= i);
            lstDelete.add(obj);
        }
        Database.DeleteResult[] drList = Database.delete(lstDelete, false);      
        // Iterate through each returned result
        for(Database.DeleteResult dr : drList) {
            if (dr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted OLI with ID: ' + dr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : dr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('OLI fields that affected this error: ' + err.getFields());
                }
            }
        }
        return SchedulerClass.ScheduleCalculateWrapper(OppotunityId);  
    }
    @AuraEnabled    
    public Static String SubmitManegeSchedule1(String JsonStringSubmit){
        System.debug('Nagendra >>>>>JsonStringSubmit'+JsonStringSubmit);
        String isSuccess = ProductScheduleController.SubmitManegeSchedule(JsonStringSubmit);
        system.debug('isSuccess'+isSuccess);
        return isSuccess; 
    }
}