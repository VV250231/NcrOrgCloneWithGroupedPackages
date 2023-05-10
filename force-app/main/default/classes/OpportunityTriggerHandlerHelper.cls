public class OpportunityTriggerHandlerHelper{
   
   /****************************************************************************************************************
    * Author        :   Nagendra
    * Param         :   null
    * Return        :   Boolean
    * Description   :   returns true if user has ligthning permission and not admin
    ****************************************************************************************************************/
   public  boolean hasPermission(){
        Boolean hasPermission = false;
        NSCCommonInfoUtil NSC_Util;
        set<string> AdminProfile  = new set<string>();
        
        /*List<ProfileExcludeFromValidation__c> mcs = ProfileExcludeFromValidation__c.getall().values();
        
        for(ProfileExcludeFromValidation__c p : mcs ){
            AdminProfile.add(p.Profile_id__c);
        }*/
        List<All_profie_list_config__c> mcs = All_profie_list_config__c.getall().values();
        for(All_profie_list_config__c p : mcs ){
            if(p.Profile_exclude_from_QuBy_trigger__c){
                AdminProfile.add(p.Profile_id__c);
            }            
        }
        if( NSCCommonInfoUtil.getInstance().userHasLightningPermission(Userinfo.getUserId()) && !AdminProfile.Contains( userInfo.getProfileId() ) ){
            hasPermission =true;
            return hasPermission;   
        }else{
            hasPermission = false;
            return hasPermission;
        }
      //return hasPermission;  
   }
   /****************************************************************************************************************
    * Author        :   Nagendra
    * Param         :   Set of OppId,newOpportunityList
    * Return        :   Boolean
    * Description   :   Validate Opportunity - part of QuBy_OpportunityTrigger_BFR trigger
    ****************************************************************************************************************/
   public void QouteValidationOnOpportunityClose(Set <Id> OppsClosed,List<Opportunity> newOpportunityList){
    List <QuBy_Detail__c> ackQts = new List<QuBy_Detail__c>();
      ackQts = [ Select Opportunity__r.id, Annuity_Quote_Status__c , Solution_Quote_Status__c from QuBy_Detail__c where Opportunity__r.id in : OppsClosed and Opportunity__c != null ];
            for( Opportunity o: newOpportunityList ){
                if( oppsClosed.contains( o.id ) ){
                    Boolean hasQuotes = false;
                    Boolean hasAckQuotes = false;
                    
                    for( QuBy_Detail__c qd : ackQts ){
                        if( qd.Opportunity__r.id == o.id ){
                            hasQuotes=true;
                            
                            if( ( qd.Annuity_Quote_Status__c != null && qd.Annuity_Quote_Status__c.toUpperCase()== 'PROCESSING' ) ||  ( qd.Solution_Quote_Status__c != null && qd.Solution_Quote_Status__c.toUpperCase() == 'PROCESSING' ) || ( qd.Annuity_Quote_Status__c != null && qd.Annuity_Quote_Status__c.toUpperCase()== 'ACKNOWLEDGED' ) || ( qd.Solution_Quote_Status__c != null && qd.Solution_Quote_Status__c.toUpperCase() == 'ACKNOWLEDGED' ) )  {
                                hasAckQuotes=true;  
                            }
                        }
                    }
                    if( hasQuotes ){
                        if( !hasAckQuotes ){
                            
                            o.addError( system.label.OppTrgrHndlHlp1 ); // There Should be atleast one QuoteBuilder Quote in Submitted state before you can Close Book Opportunity
                        }
                    }else{
                        if(o.IsQuoteCreatedInOtherSystem__c!=null && o.IsQuoteCreatedInOtherSystem__c.toUpperCase()== 'NO' ){
                            o.addError( system.label.OppTrgrHndlHlp2 );// If You have not created Quote in system other than QuoteBuilder, There Should be atleast one QuoteBuilder Quote in Submitted state before you can Close Book Opportunity
                        }else{
                            o.IsQuoteCreatedInOtherSystem__c.addError( system.label.OppTrgrHndlHlp3 );// Please confirm if you have created a quote in a system other than QuoteBuilder.
                            
                        }
                    }       
                    
                }
            }
    }
    /****************************************************************************************************************
    * Author        :  Original Trigger logic written by Mudasir, refactored by Nagendra.
    * Param         :   map of Date and OCR calender - Map<Date, OCR_Calender__c>
    * Return        :   
    * Description   :   populates the Book Date fields on the Opportunity.These fields are used in OCR extraction. - part of QuBy_OpportunityTrigger_BFR trigger
    ****************************************************************************************************************/
     public void PopulateOCRBookDateFields(List<Opportunity> newOpportunityList,Map<Date, OCR_Calender__c> ocrDateCalendarMap) {
        List<String> mnths = new List<String>{'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct','Nov', 'Dec'};
        Map<Date, OCR_Calender__c> OCRCalendarMap = new Map<Date, OCR_Calender__c>();
        
        if(!ocrDateCalendarMap.isEmpty()) {
        List<OCR_Calender__c> ocrCalendarList = [select Id,Date__c,Year__c,Quarter__c,Quarter_Week_Number__c,Month__c,Month_Week_Number__c,Year_Week_Number__c from OCR_Calender__c where Date__c IN:ocrDateCalendarMap.keySet()];
         
        for(OCR_Calender__c ocr :ocrCalendarList) {
            if(ocrDateCalendarMap.containsKey(ocr.Date__c)) {
                OCRCalendarMap.put(ocr.Date__c, ocr);
            }
        }
        
        for(Opportunity opp :newOpportunityList) {
            if(opp.IsClosed) {
                Date actualCloseDate = opp.Actual_Close_Date__c != null ? opp.Actual_Close_Date__c : (opp.CloseDate != null ? opp.CloseDate : null);
                OCR_Calender__c C1 = (OCRCalendarMap.get(actualCloseDate) != null) ? OCRCalendarMap.get(actualCloseDate) : null;
                
                if(C1 != null) {
    
                    opp.Book_Quarter__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c;
                    opp.Book_Month__c = C1.Month__c;
                    if(C1.Quarter_Week_Number__c<=9){
                    opp.Book_Quarter_Week__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c + ' ' + '0' + C1.Quarter_Week_Number__c;
                    }else{
                    opp.Book_Quarter_Week__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c + ' ' + C1.Quarter_Week_Number__c;
                    }
                    opp.Book_Year_Week__c = C1.Year_Week_Number__c;
                    opp.Book_Month_Week__c=C1.Month_Week_Number__c;
                } else {
                    
                    if(actualCloseDate != null && actualCloseDate.year() > Date.today().year()) {
                        integer qtNbr = Integer.valueOf(Math.ceil((Double)actualCloseDate.month()/3));        
                        opp.Book_Quarter__c = actualCloseDate.year() + ' Q' + qtNbr;
                        opp.Book_Month__c = actualCloseDate.year() + ' ' + mnths.get(actualCloseDate.month()-1);    
                        opp.Book_Quarter_Week__c = actualCloseDate.year() + ' Q' + qtNbr + ' ' + String.valueOf(getQtrWkNbr(actualCloseDate, qtNbr)).leftPad(2,'0');
                        opp.Book_Month_Week__c = (actualCloseDate.toStartOfMonth().daysBetween(actualCloseDate)/7) + 1;
                        opp.Book_Year_Week__c = getYrWkNbr(actualCloseDate) ;                                                                 
                    }
                       
                }
                
            } else {
                    Date closeDate = opp.CloseDate;
                    OCR_Calender__c C1 =  (OCRCalendarMap.get(opp.CloseDate)  != null) ? OCRCalendarMap.get(opp.CloseDate) : null;
                    
                    if(C1 != null) {
                    
                        opp.Book_Quarter__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c;
                        opp.Book_Month__c = C1.Month__c;
                        if(C1.Quarter_Week_Number__c<=9){
                        opp.Book_Quarter_Week__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c + ' ' + '0' + C1.Quarter_Week_Number__c;
                        }else{
                        opp.Book_Quarter_Week__c=C1.Year__c + ' ' + 'Q' + C1.Quarter__c + ' ' + C1.Quarter_Week_Number__c;
                        }
                        opp.Book_Month_Week__c=C1.Month_Week_Number__c;
                        opp.Book_Year_Week__c = C1.Year_Week_Number__c;
                    } else {
                        if(closeDate != null && closeDate.year() > Date.today().year()) {
                            integer qtNbr = Integer.valueOf(Math.ceil((Double)closeDate.month()/3));                           
                            opp.Book_Quarter__c = closeDate.year() + ' Q' + qtNbr;
                            opp.Book_Month__c = closeDate.year() + ' ' + mnths.get(closeDate.month()-1);   
                            opp.Book_Quarter_Week__c = closeDate.year() + ' Q' + qtNbr + ' ' + String.valueOf(getQtrWkNbr(closeDate, qtNbr)).leftPad(2,'0');
                            opp.Book_Month_Week__c = (closeDate.toStartOfMonth().daysBetween(closeDate)/7) + 1;                              
                            opp.Book_Year_Week__c = getYrWkNbr(closeDate) ;                                                            
                        }
                    
                    }
                    
               }
          }
       }
    }
    
    public integer getQtrWkNbr(Date d, integer qtr) {
    	integer qtWkNbr = (((Date.newInstance(d.year(), getQtrMnth(qtr), 1)).daysBetween(d)/7) + 1);
        if(qtWkNbr > 13) qtWkNbr = 13;  
        return qtWkNbr;
    }
    
     public integer getYrWkNbr(Date d) {
    	integer yrWkNbr = (((Date.newInstance(d.year(), 1, 1)).daysBetween(d)/7) + 1);
        if(yrWkNbr > 52) yrWkNbr = 52;  
        return yrWkNbr;
    }
    public integer getQtrMnth(integer qtr) {
        integer mnth = 1;
    	switch on qtr {
            when 1 {mnth = 1;}	
            when 2 {mnth = 4;}
            when 3 {mnth = 7;}
            when 4 {mnth = 10;}   
        }
        return mnth;
    }
    
    
}