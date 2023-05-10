/*
##################################################################################################
# Class Name............................:EbdEddController.cls                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
BA_SF-2491 JDK Locale impact - Upgrade API Part 5                             
################################################################################################
*/
public class EbdEddController {
    
    
    public class DateWrapper {
        @AuraEnabled
        public Map<String, Opportunity> mpOppDetail ;
        @AuraEnabled
        public Date DateTodayVal ; 
    }
    
    
    @AuraEnabled
    public static EbdEddController.DateWrapper getOppDetail(String Oppid){
        Map<String, opportunity> mpOppDetail = new Map<String, opportunity>();
        String admin04;
        //system.debug('@@'+Oppid);
        // Changes by Yogesh - Story EBA_SF-1918
        Set<Id> profileIds = NSCCommonInfoUtil.getIdSetOf('Admn_Profle_Id'); // Used same metadata in fetchOpportunityDetail Class
        Set<Id> NonAdmnprofileIds = NSCCommonInfoUtil.getIdSetOf('Non_Admn_Profle_Id'); // Used same metadata in fetchOpportunityDetail Class
        Set<Id> skip_EDB_admins = NSCCommonInfoUtil.getIdSetof('Skip_past_EBD_validate_admins'); // Changes done as part of EBA_SF-2428
            
        
        /*  if(userInfo.getProfileId()=='00e70000000x3egAAA' || userInfo.getProfileId()=='00e70000000x3eg'){
admin04='Admin';
}
else if(userInfo.getProfileId()== '00e700000013gPe'|| userInfo.getProfileId()=='00e700000013gPeAAI' ||userInfo.getProfileId() =='00e70000000sR8U' || userInfo.getProfileId()=='00e70000000sR8UAAU'){
admin04='Other Admin';
}*/
        if(skip_EDB_admins.contains(userInfo.getProfileId())){
            admin04='skip EDB admins'; //Changes done as part of EBA_SF-2428
        }
        else if(profileIds.Contains(userInfo.getProfileId())){
            admin04='Admin';
        }
        else if(NonAdmnprofileIds.contains(userInfo.getProfileId())){
            admin04='Other Admin';
        }
        else{
            admin04='Non Admin';
        }
        //End Changes by Yogesh
        Opportunity Opp = [SELECT Id, name, CloseDate, Expected_Delivery_Date__c, Amount,IsClosed
                           FROM Opportunity 
                           WHERE Id =:Oppid];
        mpOppDetail.put(admin04,Opp);
        
        
        EbdEddController.DateWrapper nObj = new EbdEddController.DateWrapper() ;
        nObj.mpOppDetail = mpOppDetail ;
        nObj.DateTodayVal = System.today() ;
        
        return (nObj);       
    }
    
    
    
    @AuraEnabled
    public static Date getLatestDate() {
        return System.today() ;
    }
    
    @AuraEnabled
    public static String saveEbdEdd(opportunity oppo)
    {
        String Msg;
        try{
            update oppo;     
            //return oppo; 
        }
        catch(DmlException e){ 
            Msg = e.getMessage();
            return Msg;
        }
        catch(Exception e){
            Msg = e.getMessage();
            return Msg;
        }
        return Msg; 
    }
    @AuraEnabled
    public static boolean ValidateScheduleDate(String OpportunityId){
        boolean HasPreviousDate =false;
        for(OpportunityLineitem oli : [select id,name,Product2.Name, Opportunity.Expected_Delivery_Date__c, OpportunityId,(Select CurrencyIsoCode,Description,IsDeleted,OpportunityLineItemId,Quantity,Revenue,ScheduleDate,Type  from OpportunityLineItemSchedules where Quantity > 0 and ScheduleDate < :GlobalVariable.unhandledQtyDate Order by ScheduleDate) from OpportunityLineItem where OpportunityId =: OpportunityId ])
        {  
            //System.debug('before oppEDD'+oli.Opportunity.Expected_Delivery_Date__c);
            if(oli.OpportunityLineItemSchedules.size()>0){
                Date EDSD = oli.Opportunity.Expected_Delivery_Date__c;
                for(OpportunityLineItemSchedule olis : oli.OpportunityLineItemSchedules){
                    Integer dy1 = olis.ScheduleDate.day();
                    Integer mon1 = olis.ScheduleDate.month();
                    Integer yr1 = olis.ScheduleDate.year();
                    Integer yr2 = EDSD.year();
                    Integer mon2=EDSD.month();
                    Date ScheduleDateOLIS = Date.newInstance(yr1,mon1,1 );
                    // System.debug('olis.ScheduleDate'+olis.ScheduleDate);
                    if((yr1 < yr2)){
                        HasPreviousDate = true; return HasPreviousDate; }  
                    else if((yr1 == yr2)  &&  (mon1 < mon2 )) {
                        HasPreviousDate = true;return HasPreviousDate; }
                    else   
                        return null;  
                }
            }  
        }
        return HasPreviousDate;
    }     
    
    
}