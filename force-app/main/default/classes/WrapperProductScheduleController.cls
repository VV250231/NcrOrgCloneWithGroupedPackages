/*
##################################################################################################
# Class Name............................:WrapperProductScheduleController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5 
                               
################################################################################################
*/
public Class WrapperProductScheduleController{
    
    //Schedule Warning starts code Date - 20110517'
    
    public static Map <Integer, String> NumToMonth = new Map <Integer, String> {
        1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'
    };
    @AuraEnabled
    public OpportunityLineItem OpportunityLineItem;
    
    @AuraEnabled
    public List<WrapperOlis> listofOppSchedule;
    
    @AuraEnabled
    public String NameofProduct; 
    
    @AuraEnabled
    public List<String> optionsWrap = new List<String>();
    
   
    
    public WrapperProductScheduleController(OpportunityLineItem OpportunityLineItemid, List<OpportunityLineItemSchedule> SchduleList ,List<String> options){
        listofOppSchedule =new List<WrapperOlis>();
        OpportunityLineItem=OpportunityLineItemid;
        NameofProduct=OpportunityLineItemid.Product2.Name;
        
        optionsWrap =options;
        system.debug('UnschldQty::::'+OpportunityLineItemid.Unscheduled_Quantity__c);
        /*for(integer i=0;i<=3;i++){
        OpportunityLineItemSchedule obj=new OpportunityLineItemSchedule();
        obj.OpportunityLineItemId=OpportunityLineItemid.id;
        obj.Quantity=OpportunityLineItemid.quantity;
        obj.Type='Quantity';
        
        }*/
        for(OpportunityLineItemSchedule olis:SchduleList){
          listofOppSchedule.add(new WrapperOlis(olis));   
        }
        
        
    }
    
    public Class WrapperOlis{
         @AuraEnabled
        public OpportunityLineItemSchedule olis= new OpportunityLineItemSchedule();
        @AuraEnabled
        public String monthYear='';
        public WrapperOlis(OpportunityLineItemSchedule olis){ 
            this.olis=olis;
            monthYear = WrapperProductScheduleController.NumToMonth.get(olis.ScheduleDate.Month()) + '-' + olis.ScheduleDate.Year();            
        }
    }
     
}