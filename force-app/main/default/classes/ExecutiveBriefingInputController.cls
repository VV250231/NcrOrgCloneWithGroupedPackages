public without sharing class ExecutiveBriefingInputController {
    private ApexPages.StandardController sc;
    private String acctId;
    Public String UserHirarchy{get;set;}
    public Decimal currYearTtlAmt{get;private set;}
    public Decimal prevYearTtlNCRSpend{get;private set;}
    public Decimal currYearTtlNCRSpend{get;private set;}
    public List<NCRSpendWrapper> NCRSpendWrapperList{get;private set;}
    public Contact con1{get;set;}
    public Contact con2{get;set;}
    public Contact con3{get;set;}
    public Contact con4{get;set;}
    public Contact con5{get;set;}
    public List<WrapperAddMore> listCustomerAttendee{get;set;}
    public  List<Contact> AllRelatedContact{get;set;}
    Public List<String> Avilablecontact{get;set;}
    public map<id,contact> mpRelatedContact;
    public String usr_Title_1 {get; set;} 
    public String usr_Title_2 {get; set;} 
    public String usr_Title_3{get; set;} 
    public String usr_Title_4 {get; set;}
    
    public String Friend_Foe_1 {get; set;}  
    public String Friend_Foe_2 {get; set;} 
    public String Friend_Foe_3{get; set;} 
    public String Friend_Foe_4{get; set;}
    public String Friend_Foe_5{get; set;}
    Boolean EditCall=false;
    public Executive_Briefing__c objEB{get;set;}
    public string strImageBlob {get;set;}
    Set<String> AlreadySelected  = new Set<String>();
    public ExecutiveBriefingInputController(ApexPages.StandardController controller){
        this.sc = controller;
        strImageBlob=''; 
        UserHirarchy='';
        objEB = new Executive_Briefing__c();
        Avilablecontact = new List<String>();
        AllRelatedContact = new list<Contact>();
        //system.debug('*****'+ApexPages.currentPage().getParameters().get('id'));
        //system.debug('%%%%'+controller.getRecord().get('id'));
        Executive_Briefing__c EB = new Executive_Briefing__c();
        String execBrId;
        //Changes done by Yogesh - EBA_SF-1732
      /*  if(ApexPages.currentPage().getParameters().get('id').startsWith('001')){
           acctId =  ApexPages.currentPage().getParameters().get('id');*/
           
        if(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')).startsWith('001')){
           acctId =  String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
            //End Chnages by Yogesh
           SetNCRAttendee();
        }else{
          EB =[select id,Name__c,UserHirarchy__c,Customer_Attendee1__c,Customer_Attendee_2__c,Customer_Attendee_3__c,Customer_Attendee_4__c,Customer_Attendee_5__c,
               Friend_Foe_Neutral_1__c,Friend_Foe_Neutral_2__c,Friend_Foe_Neutral_3__c,Friend_Foe_Neutral_4__c,Friend_Foe_Neutral_5__c,
               Attended_Previous_CEC_1__c,Attended_a_Previous_CEC_2__c,Attended_a_Previous_CEC_3__c,Attended_a_Previous_CEC_4__c,Attended_a_Previous_CEC_5__c,
               NCR_Attendee_1__r.Title,NCR_Attendee_2__r.Title,NCR_Attendee_3__r.Title,NCR_Attendee_4__r.Title from Executive_Briefing__c where id =: String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'))]; 
           acctId = EB.Name__c;
           usr_Title_1 = EB.NCR_Attendee_1__r.Title;
           usr_Title_2 = EB.NCR_Attendee_2__r.Title;
           usr_Title_3 = EB.NCR_Attendee_3__r.Title;
           usr_Title_4 = EB.NCR_Attendee_4__r.Title;
          
           
        }
         
        //System.debug('listCustomerAttendee'+listCustomerAttendee);
        
        AllRelatedContact = [Select Id,Name,FirstName,Title,Decision_Maker__c From Contact where accountId=:acctId limit 5];
        listCustomerAttendee = new List<WrapperAddMore>(); 
         
        if(EB.id !=null){
            //System.debug('edit edit'+EditCall);
            EditCall =true;
           PreparelistCustomerAttendee(EB,AllRelatedContact); 
           execBrId = EB.Id;
        }else{
            listCustomerAttendee.add(new WrapperAddMore());
        }
        //System.debug('AllRelatedContact'+AllRelatedContact);
        
        
        
        getCustomerNCRSpend(acctId, execBrId);
    }
    
    public ExecutiveBriefingInputController() {
         if(String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id')).startsWith('001')){
           acctId =  String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('id'));
         }else{
            acctId =[select Name__c from Executive_Briefing__c where id =: ApexPages.currentPage().getParameters().get('id')].Name__c; 
         } 
         //UserHirarchy=acctId.UserHirarchy__c;
         getCustomerNCRSpend(acctId, null);
      
    }

    public void getCustomerNCRSpend(String accountId, String execBrId) {
        NCRSpendWrapperList = new List<NCRSpendWrapper>();
        currYearTtlNCRSpend = 0;prevYearTtlNCRSpend  = 0;
        Map<String, NCRSpendWrapper> spendWrpMap = new  Map<String, NCRSpendWrapper>();   
        Map<String, Decimal> prevYearEstWallMap = new Map<String, Decimal>();
        
        String prevYear = String.valueOf(Date.Today().year() -1);
        
        if(String.isNotBlank(accountId)) {
            List<AggregateResult> ncrSpendAggLst = [SELECT Calendar_YEAR(Opportunity.closeDate) calYear, sum(Total_Price_USD__c) TotalPriceUSD, Revenue_Type__c RevenueType 
                                                            FROM OpportunityLineItem WHERE Opportunity.AccountId= :accountId
                                                            AND Opportunity.closeDate >= LAST_YEAR AND Opportunity.closeDate <= THIS_YEAR 
                                                            AND Opportunity.isClosed = TRUE AND Opportunity.isWon = TRUE
                                                             GROUP BY Calendar_YEAR(Opportunity.closeDate), Revenue_Type__c];
          
           if(String.isNotBlank(execBrId)) {
               for (EBT_Revenue_Summary__c rev : [SELECT Executive_Briefing__c, Revenue_Type__c, 
                                                              Year__c, Unique_Id__c,Est_Wallet_Share__c 
                                                              FROM EBT_Revenue_Summary__c
                                                              WHERE Executive_Briefing__c = :execBrId
                                                              AND Year__c = :prevYear]) {
                                                                  
                    if (String.isNotBlank(rev.Revenue_Type__c) && rev.Est_Wallet_Share__c != null) {        
                        prevYearEstWallMap.put(rev.Revenue_Type__c, rev.Est_Wallet_Share__c);                                               
                    }
               }
           }
            
            
                                                 
           for(AggregateResult agg : ncrSpendAggLst) {
               String RevType = (String) agg.get('RevenueType');
               integer calYear = (integer) agg.get('calYear');
               Decimal TtlPriceUSD = (Decimal) agg.get('TotalPriceUSD');
               
               if(String.isNotBlank(RevType)) {
                   NCRSpendWrapper spendWrp = spendWrpMap.get(RevType);
                   if(spendWrp == null) {
                       spendWrp = new NCRSpendWrapper();
                       spendWrp.revType = RevType;
                       spendWrp.prevYearWaltShare  = (prevYearEstWallMap.get(RevType) != null) ? (integer) prevYearEstWallMap.get(RevType) : null ;
                       spendWrpMap.put(RevType, spendWrp);
                   }
                   
                   if(calYear == Date.Today().year()) {
                       spendWrp.currYearAmount = (integer) TtlPriceUSD.setScale(0);
                       currYearTtlNCRSpend += TtlPriceUSD.setScale(0);
                   } else if((calYear + 1) == Date.Today().year()) {
                       spendWrp.prevYearAmount = (integer) TtlPriceUSD.setScale(0);
                       prevYearTtlNCRSpend += TtlPriceUSD.setScale(0);
                   }
               }
           }   
           
           NCRSpendWrapperList.addAll(spendWrpMap.values());                                                                                             
        }
    }
    
    public List<Opportunity> getCurrYearOppLIst() {       
        List<Opportunity> curYearOppLst = [SELECT Id, Name, ForecastCategoryName, Converted_Opportunity_Amount__c,
                                                AccountId, CloseDate, Actual_Close_Date__c 
                                                FROM Opportunity 
                                                WHERE AccountId = :this.acctId 
                                                AND (Recordtype.Name = 'include in funnel' 
                                                OR Recordtype.Name = 'Indirect - Include in Funnel Distributor' 
                                                OR Recordtype.Name = 'Indirect - Include in Funnel Reseller') 
                                                AND CloseDate = THIS_YEAR order by CloseDate];
        
        integer ttlAmt = 0;
        for(Opportunity opp : curYearOppLst) {
            integer oppAmt = integer.valueOf((opp.Converted_Opportunity_Amount__c/1000).round());
            ttlAmt += oppAmt; 
        }
        currYearTtlAmt = (Decimal.ValueOf(ttlAmt)/1000).setScale(1);
        return curYearOppLst;
    } 
    
   
    
    
    public class NCRSpendWrapper {
        public String revType{get;private set;}
        public integer prevYearAmount{get;private set;}
        public integer prevYearWaltShare{get;set;}
        public integer currYearAmount{get;private set;}   
    }
    
    
    public class WrapperAddMore{
        public String ConId{get;set;}
        public String SelectedFriendFoe{get;set;}
        public String AttendedPreviousCEC{get;set;}
        public contact selectedConInfo{get;set;}
        Public Boolean IsUserAllRedaySelected{
           get;set;
        }
        Public List<SelectOption> AttendiesList{get;set;}
        public WrapperAddMore(){
            selectedConInfo = new contact(); 
            AttendiesList= new List<Selectoption>(); 
        }
            
    }
    Public void AddMore(){
    
        if(listCustomerAttendee.size() <6){
           WrapperAddMore WrpObj= new WrapperAddMore();
           WrpObj.AttendiesList.add(new selectOption('None', '- None -'));
           for(Contact con : AllRelatedContact){
               WrpObj.AttendiesList.add(new selectOption(con.id,con.Name));
           }
           listCustomerAttendee.add(WrpObj);
           
        }   
    }
     public List<Selectoption> getContactName(){
         List<SelectOption> opts = new List<SelectOption>();
         opts.add(new SelectOption('None', '- None -'));
         //system.debug('Check for Dublicate Contact');
         for(Contact con:AllRelatedContact){
                opts.add(new selectOption(con.id,con.Name));
                Avilablecontact.add(con.Name);
            }
         return opts;
     }
    public PageReference ContactDetail(){
 
       Set <string>conflictID=new Set <string>();
        //system.debug('@@'+listCustomerAttendee);
        AlreadySelected.clear();
        if(listCustomerAttendee.size()>0){
 
             for(WrapperAddMore wa:listCustomerAttendee){
 
                 if(wa.ConId != 'None' && wa.ConId != null && AlreadySelected.contains(wa.ConId) ){
 
                     apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR,wa.selectedConInfo.Name+' is already selected.'));
                     conflictid.add(wa.ConId);                 }
                 
                 AlreadySelected.add(wa.ConId);
            }
              
        }
        //system.debug('@@'+AlreadySelected);
        
                for(WrapperAddMore wa:listCustomerAttendee){
                 if( conflictId.contains(wa.ConId)){
                     apexpages.addmessage(new apexpages.message(ApexPages.severity.ERROR,'This Contact is already selected.'));
                     wa.IsUserAllRedaySelected=true;  
                 }
                 else{
                 wa.IsUserAllRedaySelected=false;  
                 }
                    
                 AlreadySelected.add(wa.ConId);
 
            }
              
 
        if(conflictId.size()>0){
          return null;
        }
        //system.debug('Going to execute wrapper');
        Integer i=0;
              
 
        for(WrapperAddMore wa:listCustomerAttendee){
            //System.debug('after selection'+wa.ConId+'######');
            
            //wa.IsUserAllRedaySelected=false;  
            if(wa.ConId !=null && String.isNotBlank(wa.ConId) && wa.ConId != 'None'){
                //AlreadySelected.add(wa.ConId);
                for(Contact obj:AllRelatedContact){
                    
                    if(obj.id == wa.ConId){
                        System.debug('after selection'+obj.Title);
                        wa.selectedConInfo = obj;
                        if(i==0){
                            con1 = obj;
                            Friend_Foe_1 = wa.SelectedFriendFoe;
                        }
                         
                        else if(i==1){
                            con2 = obj;
                            Friend_Foe_2 = wa.SelectedFriendFoe;
                        }
                         
                        else if(i==2){
                             con3 = obj;
                             Friend_Foe_3 = wa.SelectedFriendFoe;
                        }
                        
                        else if(i==3){
                             con4 = obj;
                            Friend_Foe_4 = wa.SelectedFriendFoe;
                        }
                        
                        else if(i==4){
                            con5 = obj;
                            Friend_Foe_5 = wa.SelectedFriendFoe;
                        }
                         
                    }   
                }    
            }
            i++;
        }
        //system.debug('con1'+con1);
        //system.debug('final'+listCustomerAttendee);
        return null;
    }
    public void retrieveTitle1() {
        
        if(objEB.NCR_Attendee_1__c != null )
            this.usr_Title_1 = [SELECT Title FROM User WHERE Id = :objEB.NCR_Attendee_1__c].Title;
        else
            this.usr_Title_1 = '' ;
        if(EditCall){
             Executive_Briefing__c EB =(Executive_Briefing__c) sc.getRecord();
             if(EB.NCR_Attendee_1__c != null )
                this.usr_Title_1 = [SELECT Title FROM User WHERE Id = :EB.NCR_Attendee_1__c].Title;
            else
                this.usr_Title_1 = '' ;
        }
    }
    
    public void retrieveTitle2() {
      
        if(objEB.NCR_Attendee_2__c != null )
            this.usr_Title_2 = [SELECT Title FROM User WHERE Id = :objEB.NCR_Attendee_2__c].Title ;
         else
            this.usr_Title_2 = '' ;
        if(EditCall){
             Executive_Briefing__c EB =(Executive_Briefing__c) sc.getRecord();
             if(EB.NCR_Attendee_2__c != null )
                this.usr_Title_2 = [SELECT Title FROM User WHERE Id = :EB.NCR_Attendee_2__c].Title;
            else
                this.usr_Title_2 = '' ;
        }
    }
    
    public void retrieveTitle3() {
        
        if(objEB.NCR_Attendee_3__c != null )
            this.usr_Title_3 = [SELECT Title FROM User WHERE Id = :objEB.NCR_Attendee_3__c].Title ;
         else
            this.usr_Title_3 = '' ;
        if(EditCall){
            Executive_Briefing__c EB =(Executive_Briefing__c) sc.getRecord();
            if(EB.NCR_Attendee_3__c != null )
                this.usr_Title_3 = [SELECT Title FROM User WHERE Id = :EB.NCR_Attendee_3__c].Title ;
             else
                this.usr_Title_3 = '' ;
        }
    }
    
    public void retrieveTitle4() {
      
        if(objEB.NCR_Attendee_4__c != null )
            this.usr_Title_4 = [SELECT Title FROM User WHERE Id = :objEB.NCR_Attendee_4__c].Title ;
         else
            this.usr_Title_4 = '' ;
        if(EditCall){
            Executive_Briefing__c EB =(Executive_Briefing__c) sc.getRecord();
            if(EB.NCR_Attendee_4__c != null )
                this.usr_Title_4 = [SELECT Title FROM User WHERE Id = :EB.NCR_Attendee_4__c].Title ;
             else
                this.usr_Title_4 = '' ;
        }
    }
    
     public PageReference saveExecBrfng() {
        List<EBT_Revenue_Summary__c> revSummLst = new List<EBT_Revenue_Summary__c>();
         String prevYear = String.valueOf(Date.Today().year() -1);
        
        for(NCRSpendWrapper wrap : NCRSpendWrapperList) {
            revSummLst.add(new EBT_Revenue_Summary__c(Account__c = this.acctId, Revenue_Type__c = wrap.revType, 
                                Year__c = prevYear, Est_Wallet_Share__c = wrap.prevYearWaltShare, 
                                Unique_Id__c = this.acctId + '-' + prevYear + '-' + wrap.revType));                           
        }
        
        if (!revSummLst.isEmpty()) {
            upsert revSummLst Unique_Id__c;
        }
         
         if(objEB != null) {
             objEB.Name__c = this.acctId;
         Integer index=0;
         for(WrapperAddMore wa:listCustomerAttendee){
             if(wa.ConId !=null && String.isNotBlank(wa.ConId) && wa.ConId != 'None'){
                 if(index==0){
                     objEB.Customer_Attendee1__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objEB.Friend_Foe_Neutral_1__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objEB.Attended_Previous_CEC_1__c = wa.AttendedPreviousCEC;
                 }
                 if(index==1){
                     objEB.Customer_Attendee_2__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                      objEB.Friend_Foe_Neutral_2__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                        objEB.Attended_a_Previous_CEC_2__c = wa.AttendedPreviousCEC;
                 }
                 if(index==2){
                     objEB.Customer_Attendee_3__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objEB.Friend_Foe_Neutral_3__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objEB.Attended_a_Previous_CEC_3__c = wa.AttendedPreviousCEC;
                 }
                 if(index==3){
                     objEB.Customer_Attendee_4__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objEB.Friend_Foe_Neutral_4__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objEB.Attended_a_Previous_CEC_4__c = wa.AttendedPreviousCEC;
                 }
                 if(index==4){
                     objEB.Customer_Attendee_5__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                          objEB.Friend_Foe_Neutral_5__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                           objEB.Attended_a_Previous_CEC_5__c = wa.AttendedPreviousCEC;
                 }
                     
             }
             index++;
         }
             
             objEB.UserHirarchy__c=UserHirarchy;
             if(objEB.Id != null) {
                 update objEB;  
                 //system.debug('updated objEB'+objEB);
             }
                
                
             else{
                 insert objEB;
                 //system.debug('Inserted objEB'+objEB);
             } 
             
            if(objEB.Id != null) {
                this.saveNCRSpend(objEB.Id);
            } 
             
         }
        
      Attachment[] attDel = [Select Id From Attachment where ParentId = :objEB.Id];
      Delete attDel;
         
       if(objEB.Id != null){
             
        Attachment myAtt  = new Attachment();
        //system.debug('<><><><><>'+strImageBlob.replaceFirst('data:image/png;base64,',''));
        //system.debug('<><><><><>:::'+UserHirarchy); 
        myAtt.Body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
        myAtt.Name = 'Hirarchy.png';
        myAtt.ParentId = objEB.Id; 
        myAtt.contentType = 'Test.png'; 
        insert myAtt;  
             
        }
         
        PageReference dtlPage = sc.view();  
        PageReference returnPage = new PageReference(dtlPage.getUrl());
        return dtlPage; 
    }
    public PageReference save() {
        PageReference dtlPage = sc.save();
        if(sc.getId() != null) saveNCRSpend(sc.getId());
        this.UpdateCustomerAttendee(sc.getId());
        
        if (dtlPage != null) {
            // Construct URL of edit page or whatever other page you want
            PageReference edtPage = new PageReference(dtlPage.getUrl() + '/e');
            return edtPage;
        } else {
            return dtlPage;
        }
    }
    
    public void saveNCRSpend(Id ebId) {
        //System.debug('ebId>>>' + ebId);
        
        if(ebId != null) {
            List<EBT_Revenue_Summary__c> revSummLst = new List<EBT_Revenue_Summary__c>();
            String prevYear = String.valueOf(Date.Today().year() -1);
                    
            for(NCRSpendWrapper wrap : NCRSpendWrapperList) {
                revSummLst.add(new EBT_Revenue_Summary__c(Executive_Briefing__c = ebId, Revenue_Type__c = wrap.revType, 
                                    Year__c = prevYear, Est_Wallet_Share__c = wrap.prevYearWaltShare, 
                                    Unique_Id__c = ebId  + '-' + prevYear + '-' + wrap.revType));                           
            }
            
            //System.debug('revSummList>>' + revSummList);
            
            if (!revSummLst.isEmpty()) {
                upsert revSummLst Unique_Id__c;
            }
        }    
    }
    
    public void PreparelistCustomerAttendee(Executive_Briefing__c EB,List<Contact> AllRelatedContact){
        map<Id,Contact> mpContact = new map<Id,Contact>();
        for(Contact obj:AllRelatedContact){
           mpContact.put(obj.id,obj); 
        }
        if(EB.Customer_Attendee1__c !=null){
            WrapperAddMore wa = new WrapperAddMore();
            if(mpContact.containskey(EB.Customer_Attendee1__c)){
                wa.selectedConInfo = mpContact.get(EB.Customer_Attendee1__c);
                con1 = mpContact.get(EB.Customer_Attendee1__c);
            }
            wa.conId = EB.Customer_Attendee1__c;
            wa.SelectedFriendFoe= EB.Friend_Foe_Neutral_1__c;
            wa.AttendedPreviousCEC= EB.Attended_Previous_CEC_1__c;
            listCustomerAttendee.add(wa);
            Friend_Foe_1 = EB.Friend_Foe_Neutral_1__c;
        }
        if(EB.Customer_Attendee_2__c !=null){
            WrapperAddMore wa = new WrapperAddMore();
            if(mpContact.containskey(EB.Customer_Attendee_2__c)){
                wa.selectedConInfo = mpContact.get(EB.Customer_Attendee_2__c);
                con2 = mpContact.get(EB.Customer_Attendee_2__c);
            }
            wa.conId = EB.Customer_Attendee_2__c;
            wa.SelectedFriendFoe= EB.Friend_Foe_Neutral_2__c;
            wa.AttendedPreviousCEC= EB.Attended_a_Previous_CEC_2__c;
            Friend_Foe_2 = EB.Friend_Foe_Neutral_2__c;
            listCustomerAttendee.add(wa);
        }
        if(EB.Customer_Attendee_3__c !=null){
            WrapperAddMore wa = new WrapperAddMore();
            if(mpContact.containskey(EB.Customer_Attendee_3__c)){
                wa.selectedConInfo = mpContact.get(EB.Customer_Attendee_3__c);
                con3 = mpContact.get(EB.Customer_Attendee_3__c);
            }
            wa.conId = EB.Customer_Attendee_3__c;
            wa.SelectedFriendFoe= EB.Friend_Foe_Neutral_3__c;
            wa.AttendedPreviousCEC= EB.Attended_a_Previous_CEC_3__c;
            listCustomerAttendee.add(wa);
            Friend_Foe_3 = EB.Friend_Foe_Neutral_3__c;
        }
        if(EB.Customer_Attendee_4__c !=null){
            WrapperAddMore wa = new WrapperAddMore();
            if(mpContact.containskey(EB.Customer_Attendee_4__c)){
                wa.selectedConInfo = mpContact.get(EB.Customer_Attendee_4__c);
                con4 = mpContact.get(EB.Customer_Attendee_4__c);
            }
            wa.conId = EB.Customer_Attendee_4__c;
            wa.SelectedFriendFoe= EB.Friend_Foe_Neutral_4__c;
            wa.AttendedPreviousCEC= EB.Attended_a_Previous_CEC_4__c;
            listCustomerAttendee.add(wa);
             Friend_Foe_4 = EB.Friend_Foe_Neutral_4__c;
        }
        if(EB.Customer_Attendee_5__c !=null){
            WrapperAddMore wa = new WrapperAddMore();
            if(mpContact.containskey(EB.Customer_Attendee_5__c)){
                wa.selectedConInfo = mpContact.get(EB.Customer_Attendee_5__c);
                con5 = mpContact.get(EB.Customer_Attendee_5__c);
            }
            wa.conId = EB.Customer_Attendee_5__c;
            wa.SelectedFriendFoe= EB.Friend_Foe_Neutral_5__c;
            wa.AttendedPreviousCEC= EB.Attended_a_Previous_CEC_5__c;
            listCustomerAttendee.add(wa);
            Friend_Foe_5 = EB.Friend_Foe_Neutral_5__c;
        }
    }
    public void UpdateCustomerAttendee(Id EbId){
        Executive_Briefing__c objUpdEB = new Executive_Briefing__c(Id=EbId);
        Integer index=0;
        objUpdEB.UserHirarchy__c=UserHirarchy;
         for(WrapperAddMore wa:listCustomerAttendee){
             if(wa.ConId !=null && String.isNotBlank(wa.ConId) && wa.ConId != 'None'){
                 if(index==0){
                     objUpdEB.Customer_Attendee1__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objUpdEB.Friend_Foe_Neutral_1__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objUpdEB.Attended_Previous_CEC_1__c = wa.AttendedPreviousCEC;
                 }
                 if(index==1){
                     objUpdEB.Customer_Attendee_2__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                      objUpdEB.Friend_Foe_Neutral_2__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                       objUpdEB.Attended_a_Previous_CEC_2__c = wa.AttendedPreviousCEC;
                 }
                 if(index==2){
                     objUpdEB.Customer_Attendee_3__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objUpdEB.Friend_Foe_Neutral_3__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objUpdEB.Attended_a_Previous_CEC_3__c = wa.AttendedPreviousCEC;
                 }
                 if(index==3){
                     objUpdEB.Customer_Attendee_4__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                         objUpdEB.Friend_Foe_Neutral_4__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                         objUpdEB.Attended_a_Previous_CEC_4__c = wa.AttendedPreviousCEC;
                 }
                 if(index==4){
                     objUpdEB.Customer_Attendee_5__c = wa.ConId;
                     if(wa.SelectedFriendFoe !=null && String.isNotBlank(wa.SelectedFriendFoe) && wa.SelectedFriendFoe != 'None')
                          objUpdEB.Friend_Foe_Neutral_5__c = wa.SelectedFriendFoe;
                     if(wa.AttendedPreviousCEC !=null && String.isNotBlank(wa.AttendedPreviousCEC) )
                           objUpdEB.Attended_a_Previous_CEC_5__c = wa.AttendedPreviousCEC;
                 }
                     
             }
             index++;
         }
        
      Attachment[] attDel = [Select  Id From Attachment where ParentId = :objUpdEB.Id and Name like '%Hirarchy%'];
      Delete attDel;
         
       if(objUpdEB.Id != null){
             
        Attachment myAtt  = new Attachment();
        //system.debug('<><><><><>'+strImageBlob.replaceFirst('data:image/png;base64,',''));
        //system.debug('<><><><><>:::'+UserHirarchy); 
        myAtt.Body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
        myAtt.Name = 'Hirarchy.png';
        myAtt.ParentId = objUpdEB.Id; 
        myAtt.contentType = 'Test.png'; 
        insert myAtt;  
             
        }
        
        update objUpdEB;
    }
    
    
    
     
    public void SaveHirarchy()
    { 
        //system.debug('>>>>');
        //system.debug('HirarchyArray'+UserHirarchy);
        Attachment myAtt = new Attachment();
        //system.debug('<><><><><>'+strImageBlob.replaceFirst('data:image/png;base64,',''));
        myAtt.Body = EncodingUtil.base64Decode(strImageBlob.replaceFirst('data:image/png;base64,',''));
        myAtt.Name = 'Hirarchy.png';
        //myAttachment.ParentId = 'a0x1b000000OHvtAAG'; 
        myAtt.contentType = 'Executive_Briefing.png'; 
        //system.debug('myAttachment'+myAttachment); 
        //insert myAttachment;    
    }
    public void SetNCRAttendee(){
       Account acc = [Select id ,ownerid,owner.Title from Account where Id =:sc.getId() ]; 
       usr_Title_1 = acc.owner.Title;
       objEB.NCR_Attendee_1__c = acc.ownerid;
    }    
}