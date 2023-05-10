/****************************************************************************************************************
*   ClassName :   Validations
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati          Removed hardcoded Integration profile Ids, Removed hardcoded hospitality profile Ids and Removed hardcoded admin profile Ids
EBA_SF-1660     1 Dec 2021      Varsha Pal           Remove the validation expected book date must not be in the past for the user who has permission set to reopen the close opportunity
													 for 7 or 37 days
****************************************************************************************************************/
/*##################################################################################################
# Description...........: Performs different validation at opportunity and Line level
# Last Modified by......: Ajay Dixit 
# Last Modified Date....: 12-10-2017
# Description...........: Remove Hospitality Validation on Risk Comments
                          
##################################################################################################*/

public class Validations 
{
    public static final Double MAX_AMMOUNT = 150000000.00;
    public static boolean IS_OPPORTUNITY_UPDATE = TRUE;
    public static boolean VALIDATE_OPPORTUNITY_AMOUNT = TRUE;
    public static final String MSG_OPP_EXPECTED_BOOK_DATE = ' Book Date must not be in the past. Please select an appropriate date..';
    public static final String MSG_OPP_AMMOUNT = ' The total value exceeds the maximum Opportunity Amount value of ' + MAX_AMMOUNT.format() +' USD. Please reduce the Amount.';
    public static final String MSG_OPP_EXPECTED_DELIVERY_DATE = ' You must adjust the Product Schedule below before you can save this opportunity.  Your Product Schedule must occur in the same month or later than your Expected Delivery Date. After you have changed the Product Schedule, return here to update the Expected Delivery Date.';
    public static final String MSG_OPPSCHEDULE_SCHEDULE_DATE = ' You must adjust the Product Schedule below before you can save this opportunity.  Your Product Schedule must occur in the same month or later than your Expected Delivery Date.  After you have changed the Product Schedule, return to update the Expected Delivery Date..';
   //public static final Set<ID> ADMIN_PROFILE_IDS = new Set<ID>{'00e700000013gAK','00e700000013gAKAAY','00e700000013gPe','00e700000013gPeAAI','00e700000013YgP','00e700000013YgPAAU','00e70000000x3eg','00e70000000x3egAAA','00e70000001BP1a','00e70000001BP1aAAG','00e70000000sR8U','00e70000000sR8UAAU','00e70000000xUZSAA2'};
    public static final Set<ID> ADMIN_PROFILE_IDS = NSCCommonInfoUtil.getIdSetOf('ADMIN_PROFILE_IDS');// EBA_SF-1617 -Removed hardcoded admin profile Ids - Kapil Bhati
  //public static final Set<ID> HOSPITALITY_PROFILE_IDS = new Set<ID>{'00e70000000xBoN','00e70000000xBoS','00e70000000xBoX','00e70000000xFkD'};
    public static final Set<ID> HOSPITALITY_PROFILE_IDS = NSCCommonInfoUtil.getIdSetOf('HOSPITALITY_PROFILE_IDS');// EBA_SF-1617 -Removed hardcoded hospitality profile Ids - Kapil Bhati
    
    // Exempt Soup Integration profile from opportunity validation rules - 19/03/2015
    //public static final Set<ID> INTEGRATION_PROFILE_IDS = new Set<ID>{'00e70000000xUTZAA2',  '00e70000000xSgLAAU', '00e70000001NyoaAAC'};
     public static final Set<ID> INTEGRATION_PROFILE_IDS = NSCCommonInfoUtil.getIdSetOf('INTEGRATION_PROFILE_IDS');// EBA_SF-1617 -Removed hardcoded Integration profile Ids - Kapil Bhati
    
    public static void validateOpportunity(Map<ID,Opportunity> newOpportunityMap,Map<ID,Opportunity> oldOpportunites)
    {
            if(INTEGRATION_PROFILE_IDS.contains(UserInfo.getProfileId())){
                return;
            }
            //@Ajay Not required as EDSD is now Read Only and derived from Schedules / Close Date while Schedules can start from close Date month so EDSD can be less but in same month
            //hospitalityValidations(newOpportunityMap);
            if(ADMIN_PROFILE_IDS.contains(UserInfo.getProfileId()))
                return;
            validateOpportunityAmount(newOpportunityMap);
            /*if(HOSPITALITY_PROFILE_IDS.contains(UserInfo.getProfileId()))
                return;*/
            validateOpportunityExpectedBookDate(newOpportunityMap,oldOpportunites);
            //validateOpportunityExpectedDeliveryDate(newOpportunityMap);
    }
    //commented as per PS roll back request by linda @Ajay
    /*public static void validateOpportunityProducts(Map<ID,OpportunityLineItem> newOpportunityLineItemsMap)
    {
            if(ADMIN_PROFILE_IDS.contains(UserInfo.getProfileId()) || HOSPITALITY_PROFILE_IDS.contains(UserInfo.getProfileId()))
                return;
            validateOpportunityProductSchedules(newOpportunityLineItemsMap);
    }*/
    
    
    public static void validateOpportunityAmount(Map<ID,Opportunity> newOpportunites)
    {
        try 
        {   

           if(!VALIDATE_OPPORTUNITY_AMOUNT || newOpportunites == null || newOpportunites.isEmpty())
                return;
            
            Map<String,Double> currencyTypeMap = new Map<String,Double>();              
            for (CurrencyType c : [Select c.IsoCode, c.ConversionRate from CurrencyType c where c.IsActive = true])
                currencyTypeMap.put(c.IsoCode, c.ConversionRate);
                
            
            for(Opportunity opp : newOpportunites.values()) 
            {                
               Double amountInUSD = (opp.Amount.doubleValue())/ (Double.valueOf(currencyTypeMap.get(opp.CurrencyIsoCode)));
                                                
                if (amountInUSD > MAX_AMMOUNT )
                {
                    opp.addError(MSG_OPP_AMMOUNT);
                }
            }
         } catch (Exception e) {
            System.debug('[Validations/validateOpportunityAmount] -> Exception occured while validating Opportunity Amount: ' + e);
        }
         
    }
    
    private static void validateOpportunityExpectedBookDate(Map<ID,Opportunity> newOpportunites,Map<ID,Opportunity> oldOpportunites)
    {
        try 
        {   
            if(newOpportunites == null || newOpportunites.isEmpty())
                return;
            
            for(Opportunity opp : newOpportunites.values()) 
            {
                /*if ( IS_OPPORTUNITY_UPDATE &&
                opp.StageName != 'Closed/Lost' && 
                opp.StageName != 'Closed/Discontinued' && 
                opp.StageName != 'Closed/Booked' &&
                opp.StageName != 'Closed/Booked - NonFunnel' &&
                opp.CloseDate < System.Today() &&
                CPQ_CheckForEBD( opp.id,newOpportunites,oldOpportunites ) )
                {
                    opp.addError(MSG_OPP_EXPECTED_BOOK_DATE);
                }*/
                
                Integer dayFrmCls = opp.CloseDate.daysBetween(System.today()); // store the difference between close date and today for EBA_SF-1660 
                //added condition in line 116 for EBA_SF-1660 to bypass the validation
                if ( IS_OPPORTUNITY_UPDATE &&
                (opp.CloseDate != null) &&
                opp.CloseDate < System.Today() &&
                CPQ_CheckForEBD( opp.id,newOpportunites,oldOpportunites ) &&
                (!(FeatureManagement.checkPermission('Update_Closed_Opp_for_7_days')&&dayFrmCls<Integer.valueOf(Label.Opp_Grace_Sales_Rep)+1||FeatureManagement.checkPermission('Update_Closed_Opp_for_37_days')&&dayFrmCls<Integer.valueOf(Label.Opp_Grace_Sales_Ops)+1)))
                {
                    opp.addError(MSG_OPP_EXPECTED_BOOK_DATE);
                }
                
            }
            
        } catch (Exception e) {
            System.debug('[Validations/validateOpportunityExpectedBookDate] -> Exception occured while validating Opportunity Expected Book Date: ' + e);
        }

    }
    
    private static boolean CPQ_CheckForEBD( id oppId, Map<ID,Opportunity> newOpportunites,Map<ID,Opportunity> oldOpportunites ){
        
        
        
        if( newOpportunites.get( oppId ).Annuity_Quote_Amount_QUBY__c == oldOpportunites.get( oppId ).Annuity_Quote_Amount_QUBY__c && newOpportunites.get( oppId ).Cloud_Products_QUBY__c == oldOpportunites.get( oppId ).Cloud_Products_QUBY__c && newOpportunites.get( oppId ).Hardware_Products_QUBY__c == oldOpportunites.get( oppId ).Hardware_Products_QUBY__c && newOpportunites.get( oppId ).PS_Products_QUBY__c == oldOpportunites.get( oppId ).PS_Products_QUBY__c && newOpportunites.get( oppId ).Services_Products_QUBY__c == oldOpportunites.get( oppId ).Services_Products_QUBY__c && newOpportunites.get( oppId ).Software_Products_QUBY__c == oldOpportunites.get( oppId ).Software_Products_QUBY__c && newOpportunites.get( oppId ).Solution_Quote_Amount_QUBY__c == oldOpportunites.get( oppId ).Solution_Quote_Amount_QUBY__c && newOpportunites.get( oppId ).Total_Quote_Amount_QUBY__c == oldOpportunites.get( oppId ).Total_Quote_Amount_QUBY__c && newOpportunites.get( oppId ).Total_Quote_Closed_Amount_QUBY__c == oldOpportunites.get( oppId ).Total_Quote_Closed_Amount_QUBY__c && newOpportunites.get( oppId ).Total_Quote_Open_QUBY__c == oldOpportunites.get( oppId ).Total_Quote_Open_QUBY__c )
            return true;
        else
            return false;
        
    }
    
    
   //commented as per PS roll back request by linda @Ajay        
   /* private static void validateOpportunityExpectedDeliveryDate(Map<ID,Opportunity> newOpportunites)
    {
        try 
        {   
            
            if(newOpportunites == null || newOpportunites.isEmpty()||handleOppValidation.getBypassValidation())
                return;
            
            Opportunity opp = null;
            Date scheduleDate = null;
            Date expectedDeliveryDate = null;
            for( OpportunityLineItemSchedule opportunityLineItemSchedule : [Select OpportunityLineItem.OpportunityId, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItem.OpportunityId in :newOpportunites.keySet() ])
            {
                opp = newOpportunites.get(opportunityLineItemSchedule.OpportunityLineItem.OpportunityId);
                scheduleDate = opportunityLineItemSchedule.ScheduleDate;
                expectedDeliveryDate = opp.Expected_Delivery_Date__c;
    
                if( (IS_OPPORTUNITY_UPDATE  && scheduleDate < expectedDeliveryDate) 
                        && ( (scheduleDate.year() < expectedDeliveryDate.year()) 
                                || (scheduleDate.month() < expectedDeliveryDate.month()) ) )
                    opp.adderror(MSG_OPP_EXPECTED_DELIVERY_DATE);
            }
        } catch (Exception e) {
            System.debug('[Validations/validateOpportunityExpectedDeliveryDate] -> Exception occured while validating Opportunity Expected Delivery Date: ' + e);
        }
            
    }*/
    //commented as per PS roll back request by linda @Ajay 
    /*private static void validateOpportunityProductSchedules(Map<ID, OpportunityLineItem> newOpportunityLineItems)
    {
        try 
        {   
            
            IS_OPPORTUNITY_UPDATE = FALSE;
                        
            if(newOpportunityLineItems == null || newOpportunityLineItems.isEmpty())
                return;
            
            Date scheduleDate = null;
            Date expectedDeliveryDate = null;
            for( OpportunityLineItemSchedule opportunityLineItemSchedule : [Select OpportunityLineItemId, OpportunityLineItem.Opportunity.Expected_Delivery_Date__c, ScheduleDate from OpportunityLineItemSchedule where OpportunityLineItemid in :newOpportunityLineItems.keySet() ])
            {
                scheduleDate = opportunityLineItemSchedule.ScheduleDate;
                expectedDeliveryDate = opportunityLineItemSchedule.OpportunityLineItem.Opportunity.Expected_Delivery_Date__c;
                
                if( (scheduleDate < expectedDeliveryDate) 
                        && ( (scheduleDate.year() < expectedDeliveryDate.year()) 
                                || (scheduleDate.month() < expectedDeliveryDate.month()) ) )
                    newOpportunityLineItems.get(opportunityLineItemSchedule.OpportunityLineItemId).adderror(MSG_OPPSCHEDULE_SCHEDULE_DATE);
            }
            
        } catch (Exception e) {
            System.debug('[Validations/validateOpportunityProductSchedules] -> Exception occured while validating Opportunity Products Schedule Dates: ' + e);
        }
            
    }*/
    // Changes made by DF250061 and GS250144 against R-0384 and R-0383
    /*private static void hospitalityValidations(Map<ID,Opportunity> newOpportunitesMap){
        List<Id> ids = new List<Id>();
        Set<Id> userids = new Set<Id>();
        if(newOpportunitesMap == null || newOpportunitesMap.isEmpty())
                return;
        for(Opportunity opp : newOpportunitesMap.values()){
            ids.add(opp.ownerId);
        }
        List<user> users = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND id in :ids];
        for(User usr : users ){
            userids.add(usr.id);
        }
        for(Opportunity opp : newOpportunitesMap.values() ){
            if(userids.contains(opp.Ownerid)){
                if(opp.Expected_Delivery_Date__c < opp.closeDate && opp.IsClosed != TRUE){
                    opp.addError('Your Expected Book Date is greater than your Expected Delivery Start Date.  Please correct your dates so the Expected Delivery Start Date is greater than or equal to your Expected Book Date.');
                }*/
                // Removing Commitment Rik validation:
                // From: Keegan, Kathleen Sent: Friday, October 06, 2017 5:54 PM To: Dixit, Ajay <Ajay.Dixit@ncr.com>Cc: Anderson, Jan <Jan.Anderson@ncr.com>; Artim, Justin <Justin.Artim2@ncr.com>Subject: Commitment Risk example, <BODY>Ajay,Yes, now that Hospitality is following same rules as other LOBs, they can choose any color.Kathleen

                /*if(opp.ForecastCategoryName != NULL){
                    if(opp.ForecastCategoryName.equalsIgnoreCase('Commit') || opp.ForecastCategoryName.equalsIgnoreCase('Upside')){
                        if(opp.Commitment_Risk__c != NULL){
                            if((opp.ForecastCategoryName.equalsIgnoreCase('Commit') && !opp.Commitment_Risk__c.equalsIgnoreCase('green')) || (opp.ForecastCategoryName.equalsIgnoreCase('Upside') && !(opp.Commitment_Risk__c.equalsIgnoreCase('yellow')||opp.Commitment_Risk__c.equalsIgnoreCase('red')))){
                                opp.addError('Please select the correct value for Commitment Risk field');
                            }
                        }
                        else{
                            opp.addError('Please select the correct value for Commitment Risk field');  
                        }
                    }
                }*/
          /*  }
        }
    }*/
        
        
    // Added validateOpportunityContactRole method to valdate Contact Role against R-804
    // Commented as this is not required as per puneet
    /*
    public static void validateOpportunityContactRole(Map<ID,Opportunity> newOpportunityMap) {
        if(!newOpportunityMap.isEmpty()){
            Map<ID, Opportunity> oppConRoleMap = new Map<ID, Opportunity>([SELECT Id, 
                                                                        (Select Id FROM OpportunityContactRoles LIMIT 1) 
                                                                              FROM Opportunity WHERE Id IN :newOpportunityMap.keySet()]);
                                                                              
            for(Opportunity opp :newOpportunityMap.values()){
                if(oppConRoleMap.containsKey(opp.Id) && oppConRoleMap.get(opp.Id).OpportunityContactRoles.size() == 0){
                    if(!Test.isRunningTest()){
                        opp.addError('Please assign at least one Contact Role to opportunity before it progress to the ' + opp.StageName +' stage.');
                    }
                }
            } 
        }  
    }   */
           
        
   
    
    
        


}