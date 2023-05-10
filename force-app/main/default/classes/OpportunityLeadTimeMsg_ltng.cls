/*
#####################################################################################################################
# Project Name..........: NSC Sales Central                                                                         #
# File..................: OpportunityLeadTimeMsg.cls                                                                #
# Version...............: 1                                                                                         #
# Created by............: Sunny Kumar                                                                            #
# Created Date..........: 09-05-2011                                                                                #
# Last Modified by......: Ajay Dixit                                                                            #
# Last Modified Date....: 28-07-2011                                                                                #
# Description...........: Features implemented are 1)We need to check the leadTime b/w Opportunity's book and delivery dates if we have any    # 
#                         Hardware Product in OpportunityLineItem to ensure there is sufficient window              #
#                         for complete product demand planning. 2)The warning will be displayed if the Opportunity                                                   #
#                         Amount is ZERO and no Line Items are associated with it. 3)Pre Build Order (PBO) Warnings                                                                                          #
# Last Modified by......: Sakshi Gandhi                                                                            #
# Last Modified Date....: 21-08-2015                                                                                #
# Description...........: Added a warning for deactivate products under Sales Analytics project    
# Last Modified by......: Mudasir Rashid
# Last Modified Date....: 04-02-2016
# Description...........: Commented the code from line no 289 to 294 in order to remove the warning for Retalix Accounts. 
Modification History:
Date           Dev. Name          User Story  
27-6-2016      Nagendra Singh      Opportunity Clean-up for Lightning : delete is 'prebuild order' and 'Adjustment amount'     
26 Feb 2022    Varsha Pal          #EBA_SF-1854 :CLM: Opportunity pop-up to confirm rep completed CLM documents before close/booking Opportunities
19-12-2022     Monika              EBA_SF-2491 JDK Locale impact - Upgrade API Part 5 
#####################################################################################################################
*/
public class OpportunityLeadTimeMsg_ltng {

 /*  
   All getters- setters  
 */
 public string pageId,prodctName,DataHubRefrncKey;
 //public String prodctName;
 public Datetime Enddate1;
 //public String DataHubRefrncKey;
 public static final Double MAX_HW_AMOUNT_FOR_VALUE_PROMPTER = 1000000.00; //$1m
 public static final Double MAX_SW_AMOUNT_FOR_VALUE_PROMPTER = 500000.00; //$500k
 public static final String MSG_OPP_HW_AMOUNT_MSG = ' Opportunity total Hardware value exceeds the maximum Hardware amount value of ' + MAX_HW_AMOUNT_FOR_VALUE_PROMPTER.format() +' USD. Please fill in Value Prompter before editing other parts of the Opportunity.'; 
 public static final String MSG_OPP_SW_AMOUNT_MSG = ' Opportunity total Software value exceeds the maximum Software amount value of ' + MAX_SW_AMOUNT_FOR_VALUE_PROMPTER.format() +' USD. Please fill in Value Prompter before editing other parts of the Opportunity.'; 
 public static final String MSG_OPP_HW_SW_AMOUNT_MSG = ' Opportunity total Hardware value exceeds the maximum Hardware amount value of ' + MAX_HW_AMOUNT_FOR_VALUE_PROMPTER.format() +' USD and total Software value exceeds the maximum Software amount value of ' + MAX_SW_AMOUNT_FOR_VALUE_PROMPTER.format() +' USD. Please fill in Value Prompter before editing other parts of the Opportunity.'; 
 public static final String OPP_CLOSED_MSG = 'Opportunity changes are not allowed after an opportunity has been closed. Please contact NSC Administrator using the New SF Support Case button if you need to re-open or to make changes to this opportunity.';
 public static final String T_N_T_LOB = 'T&T';
  //Changes done by Yogesh - related to Story EBA_SF-1919 
 /*public static final Set < ID > Hospitality_IDS = new Set < ID > {
  '00e70000000xBoN',
  '00e70000000xBoS',
  '00e70000000xBoX'
 };*/
 
 public static final Set < ID > Hospitality_IDS = NSCCommonInfoUtil.getIdSetOf('SchedulerClass_HospId'); // Used same metadata in SchedulerClass 
//End Changes
 /*  
     CustomValidationContoller will work on page Load for a particular Opportunity.
 */
@AuraEnabled
    public static List<opportunity> getOppDetails(String oppId){
        List<Opportunity> opps= [select id,Industry__c from opportunity where id =:oppId Limit 1];
        return opps;
    }
    
 @AuraEnabled
 public static string getNotification(Id OpportunityId) {

  Opportunity CurntOpp1;
  String message = '';
  CurntOpp1 = [Select id,Industry__c,Account.Interface_Source__c, RecordType.name, Amount, CurrencyIsoCode, Name, Expected_Delivery_Date__c, CloseDate, /*Solution_Portfolio__c,*/ ForecastCategoryName, User_Modified_Date__c, OwnerId, RecordTypeId,
   IsClosed from Opportunity where Id = : OpportunityId
  ];
//removed retalix_oracle_id__c,Retalix_SF_ID__c from query due to EBA_SF-688
 
  try {

   integer oppLeadTime = null;
   integer countMsg = 1;
   String war;
   
   if (!CurntOpp1.IsClosed) { // if opporurnity is not closed
    
       
       list<OpportunityLineitem> OLI = [select id, Product2ID, OpportunityID, Product2.Name, Product2.End_Date__c from OpportunityLineitem where OpportunityId = : CurntOpp1.id AND Product2.End_Date__c <> null];
       for (OpportunityLineItem OL: OLI) {
        String prodctName = OL.Product2.Name;
        String msg = 'This Opportunity has <b> ' + prodctName + ' </b> product which is scheduled to be deactivated on <b> ' + (OL.product2.End_Date__c.format('MM/dd/YYYY'));
      // P-360 Initial Change- Ravikant, New_DHR_key__r no longer available
           /* if (OL.Product2.New_DHR_key__c <> null) {
         msg = msg + ' </b> and is being replaced by <b> ' + OL.Product2.New_DHR_key__r.name + ' </b>.Please take necessary action.';
        } else {*/
         msg = msg + ' </b>.Please take necessary action.';
        //}
        if (message.length() > 0) {
         message = message + '<BR/><b>Warning ' + countMsg + ': </b>' + msg;
         countMsg++;
        } else {
         message = '<B>Warning ' + countMsg + ': </B>' + msg;
         countMsg++;
        }
    
        //System.debug('HiHiHi' + message);
       }
      // if(CurntOpp1.stagename=='Offering')
      
       oppLeadTime = null;
    
       //Querying Current Opportunity details 
       //Added 2 new fields  and  ForecastCategoryName for requirement "Pre Build Order (PBO) Warnings".     
       CurntOpp1 = [Select id, Account.Interface_Source__c, RecordType.name, Amount, CurrencyIsoCode, Name, Expected_Delivery_Date__c, CloseDate, /*Solution_Portfolio__c,*/ ForecastCategoryName, User_Modified_Date__c, OwnerId, RecordTypeId, IsClosed, Hardware_Products__c, Software_Products__c, Account_LOB__c,CLM_Sales_Acknowledgment__c,stagename,CPQ__c from Opportunity where Id = : CurntOpp1.Id];
    // Retalix_SF_ID__c, Retalix_Oracle_ID__c DUE TO EBA_SF-688
       /*          CHANGES MADE BY DARSHAN SINGH FARSWAN (DF250061)
        IT DISPLAYS POP-UP FOR 53 PROFILE IF SCHEDULE DOES NOT MATCH WITH EXPECTED DELIVERY DATE
        Dated : October 10, 2013
     
       List<OpportunityLineItemSchedule> productsss = [Select id, scheduleDate, OpportunityLineItem.PricebookEntry.Name from OpportunityLineItemSchedule where OpportunitylineItem.Opportunity.id = : CurntOpp1.id];
       if (productsss != null && productsss.size() > 0) {
        Date EDD = CurntOpp1.Expected_Delivery_Date__c;
        Date a = Date.newInstance(EDD.year(), EDD.month(), 1);
        Date unscheduled_date = Date.newInstance(3000, 1, 1);
        List < user > users = [SELECT id, profileId, License_Entitlement__c from User where id = : CurntOpp1.ownerId limit 1];
        if (users[0].profileId == '00e70000000xFkD') {
         for (OpportunityLineItemSchedule p: productsss) {
          if (p.scheduleDate != a && p.scheduleDate != unscheduled_date) {
           war = 'The Product Schedule month or year does not match the Expected Delivery Date month or year. Please update the value for ' + p.OpportunityLineItem.PricebookEntry.Name + ' [' + p.scheduleDate.month() + '/' + p.scheduleDate.year() + ']';
          }
         }
        }
       }
       CHANGES MADE BY DARSHAN SINGH FARSWAN (DF250061)
                IT DISPLAYS A WARNING IF AMOUNT IS ZERO AND NO OPPORTUNITIES ARE ASSOCIATED WITH THE PRODUCT
                Dated : June 08, 2011
    */
                
                List<OpportunityLineItem> OLI_associated = [Select Id from OpportunityLineItem where OpportunityId =: CurntOpp1.Id];
                if(OLI_associated.size()==0 && CurntOpp1.Amount==0 ){
                     //Changes done by Yogesh - related to Story EBA_SF-1919
                    Id grupId = NSCCommonInfoUtil.getIdOf('OpportunityLeadTimeMsg_GroupId');
                    String requestType='';
                    String instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
                    Profile p = [SELECT id, Name from Profile where id = :UserInfo.getProfileId() limit 1].get(0);
                    if(p.Name.StartsWith('2')){ requestType = grupId+'=Global%20Sales%20%2D%20Indirect&';}
                    
                    else if (p.Name.StartsWith('30')||p.Name.StartsWith('31')||p.Name.StartsWith('33')){requestType = grupId+'=Global%20Sales%20%2D%20Direct&';}
                    
                    else if (p.Name.StartsWith('35')||p.Name.StartsWith('36')||p.Name.StartsWith('37')){requestType = grupId+'=Consumables%20%2D%20NAMER&';}
                    
                    else if (p.Name.StartsWith('5')){ requestType = grupId+'=Hospitality&';}
                    
                    requestType += 'retURL=%2F'+CurntOpp1.id;
                    
                    message =  '<b>Warning '+countMsg+': </b>The Opportunity Amount is set to ZERO as no Products are associated with the Opportunity. If this opportunity was created in error, please raise a request using New SF Support Case.';
                    countMsg++;
                }
                
                 //End Changes done on Yogesh - related to Story EBA_SF-1919
               String valPrmMsg = validateValuePrompter(CurntOpp1);
               if (String.isNotEmpty(valPrmMsg)) {
                   valPrmMsg  = '<b>Warning '+ countMsg +': </b>' + valPrmMsg;
                   countMsg++;
                   if(message.length() > 0){
                        message =  message +'<BR/>'+ valPrmMsg;
                    }
                    else{ message = valPrmMsg; }                                        
               }
                
               
                // Changes for requirement "Pre Build Order (PBO) Warnings".
               /* if( CurntOpp1.ForecastCategoryName=='Upside'||CurntOpp1.ForecastCategoryName=='Pipeline'){                
                    List <OpportunityFieldHistory> forecastCategory=[Select OpportunityId,createddate, Field, OldValue, NewValue FROM OpportunityFieldHistory where opportunityid =: CurntOpp1.Id and Field='ForecastCategoryName' and  createdDate =: CurntOpp1.User_Modified_Date__c];               
                    if(forecastCategory.size()>0 && forecastCategory.get(0).oldvalue=='Commit'){
                        //system.debug('@@@@@@@'+forecastCategory);
                        //system.debug('#############'+forecastCategory.get(0).oldvalue);
                        if(message .length()>0){
                            message =  message +'<BR/><b>Warning '+countMsg+': </b>A Pre-Build Order (PBO) is associated with this opportunity.  For the PBO to be processed, the opportunity must remain in the Commit Forecast Category.  If any changes are required regarding the PBO, contact your Demand Planner immediately.';
                            countMsg++;
                        }
                        else{
                            message = '<b>Warning '+countMsg+': </b>A Pre-Build Order (PBO) is associated with this opportunity.  For the PBO to be processed, the opportunity must remain in the Commit Forecast Category.  If any changes are required regarding the PBO, contact your Demand Planner immediately.';
                            countMsg++;
                        }
                        
                    }
                    else {   
                    if(message.length()>0){
                        message =  message +'<BR/><b>Warning '+countMsg+': </b>For a Pre-Build Order (PBO) to be associated with this opportunity, the opportunity must be in the Commit Forecast Category.';
                        countMsg++;
                        }
                        else{
                        message = '<b>Warning '+countMsg+': </b>For a Pre-Build Order (PBO) to be associated with this opportunity, the opportunity must be in the Commit Forecast Category.';
                        countMsg++;
                        }                    
                       
                    }
                    
                 }*/
                 
                    
                
                // Changes for requirement "Pre Build Order (PBO) Warnings".
                //ApexPages.Message warningMsg1 = new ApexPages.Message(ApexPages.Severity.WARNING, Message1);
                //ApexPages.addMessage(warningMsg1);
                //Changes made to exclude HSR Profiles
                //P-360 initial changes- Ravikant, Lead Time functionality not applicable 
                /*if(!Hospitality_IDS.contains(UserInfo.getProfileId())){
                   /if(CurntOpp1.Solution_Portfolio__c != 'Consumables' 
                        &&/ //P360 Initial Change - Ahad
                    if(CurntOpp1.Expected_Delivery_Date__c != null 
                        && CurntOpp1.CloseDate != null){      
        
                        //Lead time is the difference Between the EBD & EDD dates.
                        oppLeadTime = CurntOpp1.CloseDate.daysBetween(CurntOpp1.Expected_Delivery_Date__c); 
                        
                        // Get hardware products associated with this Opportunity
                        List<OpportunityLineItem> Oli_list = [  Select PricebookEntryId, 
                                                                PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name, 
                                                                PricebookEntry.Product2.Product_Category__c 
                                                                From OpportunityLineItem 
                                                                where PricebookEntry.Product2.Product_Category__c = 'HW'
                                                                and OpportunityId =: CurntOpp1.Id
                                                            ];
                                                              
                                                                            
                        // Code for new criteria on Lead time message to check schedule date before warning                
                                                            
                        List<OpportunityLineItemSchedule> Olis_list = [  Select OpportunityLineItemId,id,quantity, scheduleDate
                                                                From OpportunityLineItemSchedule 
                                                                where OpportunityLineItemId in :Oli_list order by OpportunityLineItemId ASC, scheduleDate  ASC                                                     
                                                            ];
                                                            
                        
                        Map<ID, Integer> oppLeadTime_Map = new Map<ID, Integer>();                                     
                        Integer i=1;  
                        // Populate map with line item id and day between book date and latest scheduledate
                        if(Olis_list != null && Olis_list.size()>0) {                         
                            for(OpportunityLineItemSchedule olis: Olis_list ) {                     
                                    if(i==1)
                                    oppLeadTime_Map.put(olis.OpportunityLineItemId,CurntOpp1.CloseDate.daysBetween(date.newInstance(olis.scheduleDate.Year(), olis.scheduleDate.Month(),CurntOpp1.Expected_Delivery_Date__c.Day())));
                                
                                    if(i<Olis_list.size()&& olis.OpportunityLineItemId!=Olis_list.get(i).OpportunityLineItemId){
                                            oppLeadTime_Map.put(Olis_list.get(i).OpportunityLineItemId, CurntOpp1.CloseDate.daysBetween(date.newInstance(Olis_list.get(i).scheduleDate.Year(), Olis_list.get(i).scheduleDate.Month(),CurntOpp1.Expected_Delivery_Date__c.Day())));
                                    }
                                    i++;
                                }                                     
                        }                                        
                                                            
                        
                        if(Oli_list != null && Oli_list.size()>0) {
                            
                            //Fetch currently used advocated solutions
                            Set<String> advocatedSolutions = new Set<String>(); 
                            for(OpportunityLineItem oliTemp: Oli_list ) {
                                advocatedSolutions.add(oliTemp.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
                            }
                            
                            Map<String, Double> advSol_LeadTime_Map = new Map<String, Double>();
                            List<Advocated_Solution__c> advSol_leadTime = [Select Name, Lead_Time__c From Advocated_Solution__c where Name in :advocatedSolutions];
                            for(Advocated_Solution__c leadTimeInfo: advSol_leadTime){
                                advSol_LeadTime_Map.put(leadTimeInfo.Name, leadTimeInfo.Lead_Time__c);
                            }
                            
                            //System.debug(advSol_LeadTime_Map);
                            String message1 = '<b>Warning '+countMsg+': </b>The interval between the Expected Book Date and Product Schedule is shorter than the current lead time for HW products. Extend your Product Schedule for Hardware or contact your Demand Planner to manage the delivery risk.';
                            countMsg++;
                            Double productLeadTime = null; 
                            for(OpportunityLineItem oliTemp: Oli_list ){
                                productLeadTime = advSol_LeadTime_Map.get(oliTemp.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
                                if(productLeadTime != null && oppLeadTime < productLeadTime){
                                    if(oppLeadTime_Map.get(oliTemp.id)<productLeadTime){
                                        if(message.length()>0){
                                            message =  message +'<BR/>'+message1;
                                        }
                                        else{
                                            message = message1;
                                        }                                 
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }*/
                
    /*          CHANGES MADE BY DARSHAN SINGH FARSWAN (DF250061)
                FOR USERS WITH LOB or LICENSE ENTITLEMENT = 'HOSPITALITY', WARNING MESSAGE SHOULD BE DISPLAYED IF Expected Delivery Date > 730 Days out of Today
                Dated : April 25, 2013
                
    
    
                
                List<user> users = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND id = :CurntOpp1.OwnerId];
                
                
                if(users.size()>=1 && CurntOpp1.Expected_Delivery_Date__c < CurntOpp1.closeDate && CurntOpp1.isClosed == FALSE){
                    if(message.length()>0){
                        message =  message +'<BR/><b>Warning '+countMsg+': </b>The Expected Book Date is greater than your Expected Delivery Date.  Please correct your dates so the Expected Delivery Date is greater than or equal to your Expected Book Date.';
                        countMsg++;
                    }
                    else{
                        message = '<b>Warning '+countMsg+': </b>The Expected Book Date is greater than your Expected Delivery Date.  Please correct your dates so the Expected Delivery Date is greater than or equal to your Expected Book Date.';
                        countMsg++;
                    }
                }
                if((users.size()>1 || users != NULL) && CurntOpp1.RecordTypeId == '012700000001PoZ' && Integer.ValueOf(System.Today().daysBetween(CurntOpp1.Expected_Delivery_Date__c)) > 730){
                    if(message.length()>0){
                        message =  message +'<BR/><b>Warning '+countMsg+': </b>Your Expected Delivery Date is currently entered for 2 years out. If this is incorrect please correct the Expected Delivery Date.';
                        countMsg++;
                    }
                    else{
                        message = '<b>Warning '+countMsg+': </b>Your Expected Delivery Date is currently entered for 2 years out. If this is incorrect please correct the Expected Delivery Date.';
                        countMsg++;
                    }
                }*/
                //Changes made by Malkonda Reddy
            // EBA_SF-1854 starts ---added for #EBA_SF-1854 - to give warning continuously if CLM_Sales_Acknowledgment__c is false and opportunity is non-cpq
       if(!CurntOpp1.CLM_Sales_Acknowledgment__c&&!CurntOpp1.CPQ__c)
       {
           List <String> oppStages = new List<String>();
           for(PicklistEntry value: Opportunity.StageName.getDescribe().getPicklistValues()) { //it will fetch all the Stages of Opportunity
               oppStages.add(value.getValue());
           }
           //added for #EBA_SF-1854 to check if the opportunity stages are greater than or equal to offering
           if(oppStages.indexOf(System.Label.Stage_Offering) <= oppStages.indexOf(CurntOpp1.StageName) && CurntOpp1.id !='Payments & Network'){
               //String msg1 =;//<b>Warning {0} : </b>'You have not acknowledged the required CLM process.
               if (message.length() > 0) {
                  // message = message + '<BR/><b>Warning ' + countMsg + ': </b>' + msg1;
                   message = message +'<br/>'+ String.format(System.Label.CLM_Msg,new List<String>{String.valueof(countMsg)});
                   countMsg++;
               } else {
                   message =  String.format(System.Label.CLM_Msg, new List<String>{''});
                   countMsg++;
               }
           }
       }       
       // EBA_SF-1854 ends
       } else {
            if(message.length() > 0) { message =  message + '<BR/><b>Warning '+ countMsg +': </b>' + OPP_CLOSED_MSG; }
            
           else{ message = '<b>Warning '+ countMsg +': </b>' + OPP_CLOSED_MSG; }
           
           countMsg++;  
       }  
        
            
            if(message.length()>0){
                if(message.indexOf('Warning')==message.lastIndexOf('Warning')){
                    message=message.replace('1:',':');
                }
                
            }


  } catch (Exception e) {
    System.debug('Error'+e.getMessage());
  }
  return message;
 }
 

 private static String validateValuePrompter(Opportunity currentOpp) {
      Map<String,Double> currencyTypeMap = new Map<String,Double>();            
      for (CurrencyType c : [Select c.IsoCode, c.ConversionRate from CurrencyType c where c.IsActive = true])
          currencyTypeMap.put(c.IsoCode, c.ConversionRate);
      
      String errMsg = '';
      
      if (currentOpp != null && currentOpp.Account_LOB__c != T_N_T_LOB) {
          Decimal HWAmountInUSD = 0;
          Decimal SWAmountInUSD = 0;
          
          
          if (currentOpp.Hardware_Products__c != null && currentOpp.Hardware_Products__c > 0) 
              HWAmountInUSD = currentOpp.Hardware_Products__c/ (Decimal.valueOf(currencyTypeMap.get(currentOpp.CurrencyIsoCode)));
          
          if (currentOpp.Software_Products__c != null && currentOpp.Software_Products__c > 0) 
              SWAmountInUSD = currentOpp.Software_Products__c/ (Decimal.valueOf(currencyTypeMap.get(currentOpp.CurrencyIsoCode)));
          
          if ((HWAmountInUSD >= MAX_HW_AMOUNT_FOR_VALUE_PROMPTER) && (getValuePrompter(currentOpp) == null)) {
              errMsg = MSG_OPP_HW_AMOUNT_MSG;    
          } 
          
          if((SWAmountInUSD >= MAX_SW_AMOUNT_FOR_VALUE_PROMPTER) && (getValuePrompter(currentOpp) == null)) {
              errMsg = String.isNotBlank(errMsg) ? MSG_OPP_HW_SW_AMOUNT_MSG : MSG_OPP_SW_AMOUNT_MSG; 
          }
      }  
      return errMsg;
    }
    
    private static Value_Prompter__c getValuePrompter(Opportunity currentOpp) {
        List<Value_Prompter__c> valPrm = [SELECT Id, Opportunity__c FROM Value_Prompter__c WHERE Opportunity__c = :currentOpp.Id and Is_Qualified_Prospect__c = true LIMIT 1];
        return valPrm.isEmpty() ? null : valPrm.get(0);
    }

}