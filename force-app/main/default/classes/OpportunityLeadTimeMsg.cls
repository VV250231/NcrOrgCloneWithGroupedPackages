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
12-08-2022        Monika           EBA_SF-1909  Technical Debt - Apex sharing violation part 1 #  
#####################################################################################################################
*/
public with sharing class OpportunityLeadTimeMsg {
    
    /*  
      All getters- setters  
    */
    public string pageId;
    public String prodctName;
    public Datetime Enddate1;
    public String DataHubRefrncKey;
    public Opportunity currentOpportunity{get;set;}
    public integer oppLeadTime{get;set;}
    //public static final Set<ID> Hospitality_IDS = new Set<ID>{'00e70000000xBoN','00e70000000xBoS','00e70000000xBoX'};
    public integer countMsg = 1;
    //public String war{get;set;}
    Public list<OpportunityLineItem> OLI = new List<OpportunityLineItem>();
    //public boolean render{get;set;}
    //public String msg{get;set;}
        
    /*  
        CustomValidationContoller will work on page Load for a particular Opportunity.
    */
    public OpportunityLeadTimeMsg(ApexPages.StandardController controller) {
     
        this.currentOpportunity = (Opportunity)Controller.getRecord();  
      
        
        try {
        String message='';
        OLI = [select id,Product2ID,OpportunityID,Product2.Name,Product2.End_Date__c from OpportunityLineitem where OpportunityId =: currentOpportunity.id AND Product2.End_Date__c <> null];
           for(OpportunityLineItem OL : OLI){
              prodctName = OL.Product2.Name;
            String msg='This Opportunity has <b> ' + prodctName  + ' </b> product which is scheduled to be deactivated on <b> '+(OL.product2.End_Date__c.format('MM/dd/YYYY'));
            // P-360 Initial Change- Ravikant, New_DHR_key__r no longer available
             /*  if(OL.Product2.New_DHR_key__c <> null){
                msg=msg+ ' </b> and is being replaced by <b> ' + OL.Product2.New_DHR_key__r.name +' </b>.Please take necessary action.';
             }
             else{*/
             msg=msg+ ' </b>.Please take necessary action.';
            // } 
               if(message .length()>0){
                        message =  message +'<BR/><b>Warning '+countMsg+': </b>'+msg;
                        countMsg++;
                    }
                    else{
                        message = '<B>Warning '+countMsg+': </B>'+msg;                        
                        countMsg++;
                    }
             //ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.info, msg);
             //ApexPages.addMessage(errMsg);          
            
           }
          
            oppLeadTime = null; 
                 
            //Querying Current Opportunity details 
            //Added 2 new fields  and  ForecastCategoryName for requirement "Pre Build Order (PBO) Warnings".     
            currentOpportunity = [Select id, Account.Interface_Source__c,RecordType.name,Amount, CurrencyIsoCode, Name,Expected_Delivery_Date__c,CloseDate,/*Solution_Portfolio__c,*/ ForecastCategoryName, User_Modified_Date__c, OwnerId, RecordTypeId, IsClosed from Opportunity where Id=:currentOpportunity.Id];
            //Account.Retalix_SF_ID__c removed fro query due to EBA_SF-688
/*          CHANGES MADE BY DARSHAN SINGH FARSWAN (DF250061)
            IT DISPLAYS POP-UP FOR 53 PROFILE IF SCHEDULE DOES NOT MATCH WITH EXPECTED DELIVERY DATE
            Dated : October 10, 2013
*/            
          /*  List<OpportunityLineItemSchedule> productsss = [Select id, scheduleDate, OpportunityLineItem.PricebookEntry.Name from OpportunityLineItemSchedule where OpportunitylineItem.Opportunity.id = :currentOpportunity.id];
            if(productsss != null && productsss.size()>0) {                         
                Date EDD = currentOpportunity.Expected_Delivery_Date__c;
                Date a = Date.newInstance(EDD.year(), EDD.month(), 1);
                Date unscheduled_date = Date.newInstance(3000,1,1);
                List<user> users = [SELECT id, profileId, License_Entitlement__c from User where id = :currentOpportunity.ownerId limit 1];
                if(users[0].profileId == '00e70000000xFkD'){
                    for(OpportunityLineItemSchedule p: productsss ){
                        if(p.scheduleDate != a && p.scheduleDate != unscheduled_date){ 
                            war = 'The Product Schedule month or year does not match the Expected Delivery Date month or year. Please update the value for '+ p.OpportunityLineItem.PricebookEntry.Name+' ['+p.scheduleDate.month()+'/'+p.scheduleDate.year()+']';
                        }
                    }
                }                    
            }   
            
          CHANGES MADE BY DARSHAN SINGH FARSWAN (DF250061)
            IT DISPLAYS A WARNING IF AMOUNT IS ZERO AND NO OPPORTUNITIES ARE ASSOCIATED WITH THE PRODUCT
            Dated : June 08, 2011
*/
            
            List<OpportunityLineItem> OLI_associated = [Select Id from OpportunityLineItem where OpportunityId =: currentOpportunity.Id];
            if(OLI_associated.size()==0 && currentOpportunity.Amount==0 ){
                String requestType='';
                String instanceURL = URL.getSalesforceBaseUrl().toExternalForm();
                Profile p = [SELECT id, Name from Profile where id = :UserInfo.getProfileId() limit 1].get(0);
                if(p.Name.StartsWith('2')){
                    requestType = '00N70000002Gk0G=Global%20Sales%20%2D%20Indirect&';
                }
                else if (p.Name.StartsWith('30')||p.Name.StartsWith('31')||p.Name.StartsWith('33')){
                    requestType = '00N70000002Gk0G=Global%20Sales%20%2D%20Direct&';
                }
                else if (p.Name.StartsWith('35')||p.Name.StartsWith('36')||p.Name.StartsWith('37')){
                    requestType = '00N70000002Gk0G=Consumables%20%2D%20NAMER&';
                }
                else if (p.Name.StartsWith('5')){
                    requestType = '00N70000002Gk0G=Hospitality&';
                }
                requestType += 'retURL=%2F'+currentOpportunity.id;
                
                message =  '<b>Warning '+countMsg+': </b>The Opportunity Amount is set to ZERO as no Products are associated with the Opportunity. If this opportunity was created in error, please<b><a href="'+instanceURL+'/a0P/e?'+requestType+ '"target="_top">CLICK HERE</a></b>to raise the request.commented';
                //message =  '<b>Warning '+countMsg+': </b>The Opportunity Amount is set to ZERO as no Products are associated with the Opportunity. If this opportunity was created in error, please<b><a href="#" onclick="someFunction();" target="_top">CLICK HERE</a></b>to raise the request.commented';
                
                countMsg++;
            }
            
            
           
            // Changes for requirement "Pre Build Order (PBO) Warnings".
           /* if( currentOpportunity.ForecastCategoryName=='Upside'||currentOpportunity.ForecastCategoryName=='Pipeline'){                
                List <OpportunityFieldHistory> forecastCategory=[Select OpportunityId,createddate, Field, OldValue, NewValue FROM OpportunityFieldHistory where opportunityid =: currentOpportunity.Id and Field='ForecastCategoryName' and  createdDate =: currentOpportunity.User_Modified_Date__c];               
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
            /*if(!Hospitality_IDS.contains(UserInfo.getProfileId())){
               // if(currentOpportunity.Solution_Portfolio__c != 'Consumables' 
                    && ) //P360 Initial Change - Ahad
                   if(currentOpportunity.Expected_Delivery_Date__c != null 
                    && currentOpportunity.CloseDate != null){      
    
                    //Lead time is the difference Between the EBD & EDD dates.
                    oppLeadTime = currentOpportunity.CloseDate.daysBetween(currentOpportunity.Expected_Delivery_Date__c); 
                    
                    // Get hardware products associated with this Opportunity
                    List<OpportunityLineItem> Oli_list = [  Select PricebookEntryId, 
                                                            PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name, 
                                                            PricebookEntry.Product2.Product_Category__c 
                                                            From OpportunityLineItem 
                                                            where PricebookEntry.Product2.Product_Category__c = 'HW'
                                                            and OpportunityId =: currentOpportunity.Id
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
                                oppLeadTime_Map.put(olis.OpportunityLineItemId,currentOpportunity.CloseDate.daysBetween(date.newInstance(olis.scheduleDate.Year(), olis.scheduleDate.Month(),currentOpportunity.Expected_Delivery_Date__c.Day())));
                            
                                if(i<Olis_list.size()&& olis.OpportunityLineItemId!=Olis_list.get(i).OpportunityLineItemId){
                                        oppLeadTime_Map.put(Olis_list.get(i).OpportunityLineItemId, currentOpportunity.CloseDate.daysBetween(date.newInstance(Olis_list.get(i).scheduleDate.Year(), Olis_list.get(i).scheduleDate.Month(),currentOpportunity.Expected_Delivery_Date__c.Day())));
                                }
                                i++;
                            }                                     
                    }                                        
                                                        
                    
                    if(Oli_list != null && Oli_list.size()>0) {
                        
                        //Fetch currently used advocated solutions
                        Set<String> advocatedSolutions = new Set<String>(); 
                        for(OpportunityLineItem oli: Oli_list ) {
                            advocatedSolutions.add(oli.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
                        }
                        //System.debug('DARSHAN - '+advocatedSolutions);
                        //Query and create a map of currently used adocated solution with lead time.
                        Map<String, Double> advSol_LeadTime_Map = new Map<String, Double>();
                        List<Advocated_Solution__c> advSol_leadTime = [Select Name, Lead_Time__c From Advocated_Solution__c where Name in :advocatedSolutions];
                        for(Advocated_Solution__c leadTimeInfo: advSol_leadTime){
                            advSol_LeadTime_Map.put(leadTimeInfo.Name, leadTimeInfo.Lead_Time__c);
                        }
                        
                        //System.debug(advSol_LeadTime_Map);
                        String message1 = '<b>Warning '+countMsg+': </b>The interval between the Expected Book Date and Product Schedule is shorter than the current lead time for HW products. Extend your Product Schedule for Hardware or contact your Demand Planner to manage the delivery risk.';
                        countMsg++;
                        Double productLeadTime = null; 
                        for(OpportunityLineItem oli: Oli_list ){
                            productLeadTime = advSol_LeadTime_Map.get(oli.PricebookEntry.Product2.Advocated_Solution_Lookup__r.Name);
                            if(productLeadTime != null && oppLeadTime < productLeadTime){
                                if(oppLeadTime_Map.get(oli.id)<productLeadTime){
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
            
*/
//String msg;
            
            //ApexPages.Message warngMsg = new ApexPages.Message(ApexPages.Severity.INFO, msg);
            //ApexPages.addMessage(warngMsg);
            
            /*List<user> users = [SELECT id, LOB__c, License_Entitlement__c from User where (LOB__c = 'Hospitality' OR License_Entitlement__c = 'Hospitality') AND id = :currentOpportunity.OwnerId];
            
            
            if(users.size()>=1 && currentOpportunity.Expected_Delivery_Date__c < currentOpportunity.closeDate && currentOpportunity.isClosed == FALSE){
                if(message.length()>0){
                    message =  message +'<BR/><b>Warning '+countMsg+': </b>The Expected Book Date is greater than your Expected Delivery Date.  Please correct your dates so the Expected Delivery Date is greater than or equal to your Expected Book Date.';
                    countMsg++;
                }
                else{
                    message = '<b>Warning '+countMsg+': </b>The Expected Book Date is greater than your Expected Delivery Date.  Please correct your dates so the Expected Delivery Date is greater than or equal to your Expected Book Date.';
                    countMsg++;
                }
            }
            if((users.size()>1 || users != NULL) && currentOpportunity.RecordTypeId == '012700000001PoZ' && Integer.ValueOf(System.Today().daysBetween(currentOpportunity.Expected_Delivery_Date__c)) > 730){
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
           /* if((currentOpportunity.Account.Retalix_Oracle_ID__c != '' || currentOpportunity.Account.Retalix_SF_ID__c != '') && currentOpportunity.Account.Interface_Source__c == 'RTX' && currentOpportunity.RecordType.name == 'Include in Funnel')
            {
               message =  message +'<BR/><b>Warning '+countMsg+': </b>This is a legacy Retalix record and orders cannot be placed in WOT/SPOT for this Account. Refer to the<b><a href="http://wiki.ncr.com:2001/ncrwiki/index.php/Opportunity_Management#2013_NCR.2FRetalix_Cross-Selling_Opportunities" target="_blank">Interim NCR/Retalix Cross-Selling Order Process</a></b>for additional guidance.'; 
               countMsg++;  
            }    
             */             
            if(message.length()>0){
                if(message.indexOf('Warning')==message.lastIndexOf('Warning')){
                    message=message.replace('1:',':');
                }
                ApexPages.Message warningMsg = new ApexPages.Message(ApexPages.Severity.INFO, message);
                ApexPages.addMessage(warningMsg);
            }
            
        } catch(Exception ex) {
            system.debug(ex.getMessage());
        }   
    }
}