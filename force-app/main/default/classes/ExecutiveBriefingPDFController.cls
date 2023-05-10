public class ExecutiveBriefingPDFController {
    private String acctId; 
    public Decimal currYearTtlAmt{get;private set;}
    public Decimal prevYearTtlNCRSpend{get;private set;}
    public Decimal currYearTtlNCRSpend{get;private set;}
    public List<NCRSpendWrapper> NCRSpendWrapperList{get;private set;}
    public Executive_Briefing__c objEB{get;set;}
    public String AttachmentId_role {get;set;}
    // Determines whether page is rendered as a PDF or just displayed as HTML
    public String renderAs { get; set; }
    public String fname{get;set;}
    public String heatmap_base{get;set;}
    public Attachment AttachmentId_heat {get;set;} 
    public Boolean AlreadyHeatMap = false ;
    public String showheatmap { get; set; }
    public String hideheatmap { get; set; }
    public Boolean loadagain  { get; set; }
    
    public ExecutiveBriefingPDFController(ApexPages.StandardController controller){
        system.debug('<><><><><>'+ApexPages.currentPage().getParameters().get('id'));
        AttachmentId_role =[Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like '%Hirarchy%' limit 1].id; 
        /* ################################################################# */
        if(ApexPages.currentPage().getUrl().contains('isPdf')){
            showheatmap = 'display:none';
            hideheatmap = 'display:block';
            loadagain = false ;
        }
        else{
            hideheatmap = 'display:none';
            showheatmap = 'display:block';
            loadagain = true ;
        }

         /*//AttachmentId_heat = [Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like '%HeatMap%'];
        if(AttachmentId_heat != null){
            AlreadyHeatMap = true; 
            //AttachmentId_heat =[Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like '%HeatMap%' limit 1].id; 
        }
        //else  AttachmentId_heat =[Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like '%Hirarchy%' limit 1].id;
         ################################################################# */
        
        objEB = new Executive_Briefing__c();
        objEB =[select id,Company_Logo__c ,Date_Time__c,Location__c,Attire__c,News__c,Ownership__c,Name__c ,
                Account_Manager_Sales_Leader__r.Name,Account_Loyalty_Score__c,
               Meeting_Agenda__c,Meeting_Objective_1__c,Meeting_Objective_2__c,Key_Message_1__c,Key_Question_1__c,
               Highlight_Flag_1__c,Customer_Attendee1__r.Name,Customer_Attendee1__r.Title,Customer_Attendee1__r.Decision_Maker__c,
               Customer_Attendee_2__r.Name,Customer_Attendee_2__r.Title,Customer_Attendee_2__r.Decision_Maker__c,
               Customer_Attendee_3__r.Name,Customer_Attendee_3__r.Title,Customer_Attendee_3__r.Decision_Maker__c,
               Customer_Attendee_4__r.Name,Customer_Attendee_4__r.Title,Customer_Attendee_4__r.Decision_Maker__c,
               Customer_Attendee_5__r.Name,Customer_Attendee_5__r.Title,Customer_Attendee_5__r.Decision_Maker__c,
               Friend_Foe_Neutral_1__c,Friend_Foe_Neutral_2__c,Friend_Foe_Neutral_3__c,Friend_Foe_Neutral_4__c,
               Friend_Foe_Neutral_5__c,Attended_Previous_CEC_1__c,Attended_a_Previous_CEC_2__c,
               Attended_a_Previous_CEC_3__c,Attended_a_Previous_CEC_4__c,Attended_a_Previous_CEC_5__c,
               Cutsomer_Attendees_Bio_Pic_1__c,Customer_Attendees_Bios_Pic_2__c,Customer_Attendees_Bios_1__c,
               Customer_Attendees_Bios_2__c,Customer_Attendees_Bios_Pic_3__c,Customer_Attendees_Bios_Pic_4__c,
               Customer_Attendees_Bios_3__c,Customer_Attendees_Bios_4__c,Customer_Attendees_Bios_Pic_5__c,
               Customer_Attendees_Bios_5__c,Account_Summary_Image__c,Who_Are_They__c, Key_Metrics__c,Values_and_Mission__c,
               Business_Environment__c,NCR_Attendee_1__r.Name,NCR_Attendee_1__r.Title,NCR_Attendee_1_Role__c,
               NCR_Attendee_2__r.Name,NCR_Attendee_2__r.Title,NCR_Attendee_2_Role__c,Customer_Strategic_Objectives__c,
               NCR_Attendee_3__r.Name,NCR_Attendee_3__r.Title,NCR_Attendee_3_Role__c,How_NCR_Aligns__c,
               NCR_Attendee_4__r.Name,NCR_Attendee_4__r.Title,NCR_Attendee_4_Role__c,HeatMapURI__c,
               Customer_Since__c,Referenceable__c from Executive_Briefing__c where Id=: ApexPages.currentPage().getParameters().get('id') limit 1 ]; 
               getCustomerNCRSpend(objEB.Name__c);
               this.acctId = objEB.Name__c;
     }
    
    public ExecutiveBriefingPDFController() {
         acctId = ApexPages.currentPage().getParameters().get('id');
         getCustomerNCRSpend(ApexPages.currentPage().getParameters().get('id'));
    }
    
    public void getCustomerNCRSpend(String accountId) {
        NCRSpendWrapperList = new List<NCRSpendWrapper>();
        currYearTtlNCRSpend = 0;prevYearTtlNCRSpend  = 0;
        Map<String, NCRSpendWrapper> spendWrapperMap = new  Map<String, NCRSpendWrapper>();   
        Map<String, Decimal> prevYearEstWallMap = new Map<String, Decimal>();
        
        String prevYear = String.valueOf(Date.Today().year() -1);
        
        if(String.isNotBlank(accountId)) {
            List<AggregateResult> ncrSpendAggList = [SELECT Calendar_YEAR(Opportunity.closeDate) calYear, sum(Total_Price_USD__c) TotalPriceUSD, Revenue_Type__c RevenueType 
                                                            FROM OpportunityLineItem WHERE Opportunity.AccountId= :accountId
                                                            AND Opportunity.closeDate >= LAST_YEAR AND Opportunity.closeDate <= THIS_YEAR 
                                                            AND Opportunity.isClosed = TRUE AND Opportunity.isWon = TRUE
                                                             GROUP BY Calendar_YEAR(Opportunity.closeDate), Revenue_Type__c];
          
           for (EBT_Revenue_Summary__c rev : [SELECT Account__c, Revenue_Type__c, 
                                                          Year__c, Unique_Id__c,Est_Wallet_Share__c 
                                                          FROM EBT_Revenue_Summary__c
                                                          WHERE Account__c = :accountId
                                                          AND Year__c = :prevYear]) {
                                                              
                if (String.isNotBlank(rev.Revenue_Type__c) && rev.Est_Wallet_Share__c != null) {        
                    prevYearEstWallMap.put(rev.Revenue_Type__c, rev.Est_Wallet_Share__c);                                               
                }
           }
            
            
                                                 
           for(AggregateResult agg : ncrSpendAggList) {
               String RevenueType = (String) agg.get('RevenueType');
               integer calYear = (integer) agg.get('calYear');
               Decimal TotalPriceUSD = (Decimal) agg.get('TotalPriceUSD');
               
               if(String.isNotBlank(RevenueType)) {
                   NCRSpendWrapper spendWrapper = spendWrapperMap.get(RevenueType);
                   if(spendWrapper == null) {
                       spendWrapper = new NCRSpendWrapper();
                       spendWrapper.revType = RevenueType;
                       spendWrapper.prevYearWaltShare  = (prevYearEstWallMap.get(RevenueType) != null) ? (integer) prevYearEstWallMap.get(RevenueType) : null ;
                       spendWrapperMap.put(RevenueType, spendWrapper);
                   }
                   
                   if(calYear == Date.Today().year()) {
                       spendWrapper.currYearAmount = (integer) TotalPriceUSD.setScale(0);
                       currYearTtlNCRSpend += TotalPriceUSD.setScale(0);
                   } else if((calYear + 1) == Date.Today().year()) {
                       spendWrapper.prevYearAmount = (integer) TotalPriceUSD.setScale(0);
                       prevYearTtlNCRSpend += TotalPriceUSD.setScale(0);
                   }
               }
           }   
           
           NCRSpendWrapperList.addAll(spendWrapperMap.values());                                                                                             
        }
    }
    
    public List<Opportunity> getCurrYearOppLIst() {
       
        List<Opportunity> curYearOppLIst = [SELECT Id, Name, ForecastCategoryName, Converted_Opportunity_Amount__c,
                                                AccountId, CloseDate, Actual_Close_Date__c 
                                                FROM Opportunity 
                                                WHERE AccountId = :this.acctId 
                                                AND (Recordtype.Name = 'include in funnel' 
                                                OR Recordtype.Name = 'Indirect - Include in Funnel Distributor' 
                                                OR Recordtype.Name = 'Indirect - Include in Funnel Reseller') 
                                                AND CloseDate = THIS_YEAR order by CloseDate];
        
        integer totalAmount = 0;
        for(Opportunity opp : curYearOppLIst) {
            integer oppAmount = integer.valueOf((opp.Converted_Opportunity_Amount__c/1000).round());
            totalAmount += oppAmount; 
        }
        currYearTtlAmt = (Decimal.ValueOf(totalAmount)/1000).setScale(1);
        return curYearOppLIst;
    } 
    
    public class NCRSpendWrapper {
        public String revType{get;private set;}
        public integer prevYearAmount{get;private set;}
        public integer prevYearWaltShare{get;set;}
        public integer currYearAmount{get;private set;}   
    }
    
    public void saveasPDF() {
        delete [Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like'%HeatMap%' limit 1] ; 
        system.debug('file is here  :: '+heatmap_base);
        Attachment attach = new Attachment();
        attach.Body = EncodingUtil.base64Decode(heatmap_base.replaceFirst('data:image/png;base64,',''));
        attach.name = 'HeatMap';
        attach.parentId = ApexPages.currentPage().getParameters().get('id');
        //attach.contentType = '';
        insert attach;
        system.debug('attachement here is  :: '+attach.id);
       // return null ;
         
    }
}