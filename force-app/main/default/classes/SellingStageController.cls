/*Date           Dev. Name          User Story  
26 Feb 2022    Varsha Pal          #EBA_SF-1854 :CLM: Opportunity pop-up to confirm rep completed CLM documents before close/booking Opportunities
18 July 2022   Stuti Srivastava    #CSI_SF-424  :CLM Warning Message
19-12-2022     Monika              EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
#################################################################################################################################*/
public class SellingStageController {
    
    @AuraEnabled   
    public static Opportunity getTypeFromOpp(string recordId)
    {
        //added CLM_Sales_Acknowledgment__c for EBA_SF-1854
        //added Industry__c field as the part of Cardtronics Salesforce Integration Enhancement CSI_SF-424
        
        Opportunity opp = [select CPQ__c,Name, RecordType.Name, StageName, isClosed,You_have_not_selected_any_TS_HWM_or_SW__c,
                           (Select id,Name,Product_Category__c,Product2.Service_Offer_Category__c from OpportunityLineItems), Price_Variance__c, 
                           Key_Criteria__c, Lose_to_a_Competitor__c, Are_we_the_Incumbent__c, How_important_was_Price_in_the_Decision__c, 
                           What_was_the_closest_competitor_price__c, Closed_Lost_Comments__c,CLM_Sales_Acknowledgment__c,Industry__c, CATM_Record__c from Opportunity Where Id = :recordId limit 1];
        return opp;
    }
    
    
    
    @AuraEnabled  
    public static List<WrapperDiscontinueReason> getpickvalDR(string recordId)     
    {   
        String SelectedDiscontinueReason='';
        if(String.isNotBlank(recordId))
            SelectedDiscontinueReason = [select id,Discontinued_Reasons__c from Opportunity Where Id = :recordId].Discontinued_Reasons__c;    
        
        List<WrapperDiscontinueReason> options = new List<WrapperDiscontinueReason>();
        
        Schema.DescribeFieldResult fieldResult = opportunity.Discontinued_Reasons__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry f : ple) { 
            if(f.getLabel() == SelectedDiscontinueReason){
                options.add(new WrapperDiscontinueReason(f.getLabel(),True));
            }
            else{
                options.add(new WrapperDiscontinueReason(f.getLabel(),False));
            }
        }       
        return options; 
    }  
    // EBA_SF-1854 added a new isclosed flag to check if we need to closed/booked the opportunity or just updating the fields coming from aura components
    @AuraEnabled
    public Static String UpdateOpportunityRecordNewCB(Opportunity opp, Boolean isClosed) 
    {      
        if(isClosed){
            if((opp.RecordType.Name!='Include in Funnel' && opp.RecordType.Name!='Indirect - Include in Funnel Reseller' && opp.RecordType.Name != 'Indirect - Include in Funnel Distributor')){
                opp.StageName='Closed/Booked - NonFunnel';
            }else{
                opp.StageName='Closed/Booked'; 
            }
        }
        try{
            update opp;  
            
        }catch(Exception e){
            return ('Error:'+e.getMessage());
            
        }
        return 'Success';
    }
    @AuraEnabled
    public Static String UpdateOpportunityRecordNewCL(Opportunity opp) 
    {          
        
        opp.StageName='Closed/Lost'; 
        
        
        try{
            update opp;  
            
        }catch(Exception e){
            return ('Error:'+e.getMessage());
            
        }
        return 'Success';
    }
    
    
    
  /*  
    @AuraEnabled
    public Static String UpdateOpportunityRecordNew(String id,String multiplevalue,string selectedprice,string DisContReason, String QtConfirmation, String stg1, String Reason) 
    { 
        Opportunity opp=new Opportunity();
        if(String.isNotBlank(id)){
            opp=[SELECT id,name,StageName, recordType.Name from Opportunity where Id=:id];
        }        
        if(stg1 == 'Closed/Discontinued'){             
            if(String.isNotBlank(DisContReason))    
                opp.Discontinued_Reasons__c=DisContReason;            
        }        
        else{
            if(String.isNotBlank(Reason)){
                opp.You_have_not_selected_any_TS_HWM_or_SW__c=Reason; 
            }
            
            if(String.isNotBlank(multiplevalue))
                opp.Key_Criteria__c=multiplevalue;
            
            if(String.isNotBlank(selectedprice)) 
                opp.Price_Variance__c=selectedprice;
            
            if(String.isNotBlank(QtConfirmation)) 
                opp.IsQuoteCreatedInOtherSystem__c=QtConfirmation; 
            if(stg1=='Closed/Booked' && (opp.RecordType.Name!='Include in Funnel' && opp.RecordType.Name!='Indirect - Include in Funnel Reseller' && opp.RecordType.Name != 'Indirect - Include in Funnel Distributor')){
                stg1='Closed/Booked - NonFunnel';
            }
        }
        opp.StageName=stg1;
        try{
            update opp;  
            
        }catch(Exception e){
            system.debug('ERROR###:'+ e.getMessage());
            return ('Error:'+e.getMessage());
            
        }
        return 'Success';
    }
    
    */
    //Return true : If Current profile available in Custom Setting
    //Return False : If Current profile not available in Custom Setting
    @AuraEnabled    
    public static boolean getIsdisabled(){   
        /*if( QuBy_LTNG_ProfileCheck__c.getValues( userInfo.getProfileId() ) == null )
            return false; 
        else
            return true;*/
         set<string> st  = new set<string>();
        List<All_profie_list_config__c> mcs = All_profie_list_config__c.getall().values();
        for(All_profie_list_config__c p : mcs ){
            if(p.QuBy_LTNG_ProfileCheck__c == true){
                st.add(p.Profile_id__c);
            }            
        } 
        if(! st.Contains( userInfo.getProfileId() )){
            return false;
        }else{
            return true;
        }        
    }  
    
    @AuraEnabled 
    public Static List<String> getReasonForHwandSW(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.You_have_not_selected_any_TS_HWM_or_SW__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel()); 
        }     
        return pickListValuesList;
    }
    @AuraEnabled
    public static Map<String,  List<String>> getOpts() { 
        
        //Fetching field picklist values
        Schema.sObjectType sobject_type = Opportunity.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        Map<String, List<String>> picklistfieldmap=new Map<String, List<String>>();
        Set<String> techFields=new Set<string>();
        
        for(String s:field_map.keySet()){
            try{
                List<Schema.PicklistEntry> pick_list_values = field_map.get(s).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                List <String> pklistval=new List <String>();
                for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list            
                    pklistval.add(a.getLabel()); //add the value and label to our final list
                }
                if(pklistval.size()>0){
                    picklistfieldmap.put(s,pklistval);                
                    
                }
                
            }catch(Exception e){
                throw new AuraHandledException(e.getMessage());
            } 
        }
        return picklistfieldmap;
    }
     @AuraEnabled
    public static Date contractDateAvl(string recordId) { 
         Boolean isContractDateReq = false;
        Date cntDate=null;
         for(Opportunity oppp:[select Payments_Contract_End_Date__c from Opportunity where id=:recordId limit 1]){
            if(oppp.Payments_Contract_End_Date__c == null){
                isContractDateReq = true;
            }   
             else{
               cntDate= oppp.Payments_Contract_End_Date__c; 
             }
        }
                return cntDate;
    }
  
    
}