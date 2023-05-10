public class QONB_DashboardController {
    
    @AuraEnabled
    public static List<statusDashboardWrapper> getAccount(){
        Set<Id> TeamMemberAccountId = new Set<Id>();
        Set<String> QuickLooks = new Set<String>();
        map<String,String> mpQuicklookTOName = new map<String,String>();
        
        List<AccountTeamMember> lstAccTeamMember = [ SELECT id,AccountId From AccountTeamMember where UserId =: UserInfo.getUserId() ];
        for(AccountTeamMember accTeam :lstAccTeamMember){
           TeamMemberAccountId.add(accTeam.AccountId);
        }
        System.debug('TeamMemberAccountId'+TeamMemberAccountId);
         list<Account> lstacc = new list<Account>();
         DATE d1 = date.today();
         Date d2 = d1.addMonths(-18);
         
         Integer d3 = d2.daysBetween(d1);
         lstacc = [ SELECT id,Master_Customer_Number__c,Name,(select id,Quote_Number__c,Opportunity_No__c,Opportunity__c,Opportunity__r.Amount,Annuity_Quote_Status__c,
                                    Total_Quote_Amount__c,QuickLook_ID__c,Solution_Modification_Date__c,LastModifieddate,Solution_Quote_Status__c,Financial_Call_Off__c,
                                    Return_Reason__c,Return_Comment__c,Organization_Action_Owner__c,Order_Not_Booked_Reason_Status__c,
                                    Order_Not_Booked_Pending_Reason__c
                                    from All_QuBy_Quotes_Acc__r where (Solution_Modification_Date__c  >= :d2 OR Annuity_Modification_Date__c >:d2)  ORDER BY Solution_Modification_Date__c DESC) 
                                    From Account 
                                    where (ownerid =: UserInfo.getUserId()) OR (id In :TeamMemberAccountId)];
         system.debug('lstacc123'+lstacc);
        
         //Sorting logic
         List<SortingUtils.SortingWrapper> results = new List<SortingUtils.SortingWrapper>();
         for(Account acc :  lstacc) {
            results.add(new SortingUtils.SortingWrapper(acc));    
        } 
        lstacc.clear();
        system.debug('Before sorting'+results);
        results.sort();
        system.debug('afetr sorting'+results);
        for(SortingUtils.SortingWrapper wp:results){
            lstacc.add(wp.objAcc);
            system.debug(wp.objAcc);
        }
        //End sorting logic
        
        
        
        //Prepare Quick Look id to User Name map
        for(Account acc:lstacc){
            for(QuBy_Detail__c QuByQuote :  acc.All_QuBy_Quotes_Acc__r ){
                QuickLooks.add(QuByQuote.QuickLook_ID__c);
            }
        }
        System.debug('@@@: '+QuickLooks);
        for(NCR_Employee_Detail__c emp:[select id,Quicklook_ID__c,User_Name__c from NCR_Employee_Detail__c where Quicklook_ID__c in: QuickLooks]){
           mpQuicklookTOName.put(emp.Quicklook_ID__c,emp.User_Name__c); 
        }
        
        //End of Prepare Quick Look id to User Name map
        
       //Prepare Wrapper Data
       List<statusDashboardWrapper> lstDashboardWp = new  List<statusDashboardWrapper>();
        
        for(Account acc:lstacc){
             statusDashboardWrapper sDW = new statusDashboardWrapper();
            Integer countAwaiting_Approvals =0;
            Integer countInProgress = 0;
            Integer Import_Issue =0;
            Integer Config_Error =0;
            Integer Incorrect_Submission =0;
            Integer Missing_Documentations =0;
			Integer None_OrderFieldsNull =0;
            Integer DUPLICATE_QUOTE =0;
            Integer LACK_OF_INFORMATION=0;
            Integer PROCESSED = 0;
            Integer REJECTED = 0;
            Integer WIP=0;
            Integer ACKNOWLEDGED=0;
            Integer CUSTOMER =0;
            Integer OTHER =0;
            Integer UNABLE_TO_PROCEED =0;
            Integer CUSTOMER_CREDIT_HOLD=0;
            
            sDW.AccountId = acc.Id;
            sDW.AccountName = acc.Name+ ' - ' + acc.Master_Customer_Number__c;
            sDW.QuotesInProcess = new list<WrapperQuotes>();
            sDW.OrderSubmittedToBOC = new List<WrapperQuotes>();
            sDW.OrderReturnedToSales = new List<WrapperQuotes>();
			
			List<QuBy_Detail__c> InProgressQuotes = new List<QuBy_Detail__c>();
			List<QuBy_Detail__c> ApprovalRequiredQuotes = new List<QuBy_Detail__c>();
            for(QuBy_Detail__c QuByQuote :  acc.All_QuBy_Quotes_Acc__r ){
                   if(QuByQuote.Solution_Quote_Status__c =='In Progress'
                  ||QuByQuote.Solution_Quote_Status__c =='Approval Required' ){
                      
                   if(QuByQuote.Solution_Quote_Status__c =='Approval Required')   
                       countAwaiting_Approvals =  countAwaiting_Approvals+1;
                    else if(QuByQuote.Solution_Quote_Status__c =='In Progress')
                        countInProgress = countInProgress+1;
                        
                      WrapperQuotes wq= new WrapperQuotes();
                      wq.QuoteNo =QuByQuote.Quote_Number__c;
                      if(QuByQuote.QuickLook_ID__c !=null && mpQuicklookTOName.containsKey(QuByQuote.QuickLook_ID__c)){
                          wq.Owner = mpQuicklookTOName.get(QuByQuote.QuickLook_ID__c); 
                      }else{
                           wq.Owner ='';
                      }
                     
                      wq.OpportunityNumber = QuByQuote.Opportunity_No__c;
                      wq.OpportunityValue = QuByQuote.Opportunity__r.Amount;
                      wq.QuoteTotal = QuByQuote.Total_Quote_Amount__c;
                      Date myDate = date.newinstance(QuByQuote.Solution_Modification_Date__c.year(), QuByQuote.Solution_Modification_Date__c.month(), QuByQuote.Solution_Modification_Date__c.day());
                      wq.DateModified = myDate;
                      wq.HW_SW_Status = QuByQuote.Solution_Quote_Status__c;
                      wq.Main_SupportStatus = QuByQuote.Annuity_Quote_Status__c;
                      wq.FinancialCallOff =   QuByQuote.Financial_Call_Off__c;
                      
                      sDW.QuotesInProcess.add(wq);   
                }
                //Second Category
                //sDW.OrderSubmittedToBOC = new List<WrapperQuotes>();
                //
                System.debug('@@@: '+QuByQuote.Solution_Quote_Status__c);
                if(QuByQuote.Solution_Quote_Status__c =='Processing'){
					
					if(QuByQuote.Order_Not_Booked_Pending_Reason__c ==null 
					   && QuByQuote.Order_Not_Booked_Reason_Status__c ==null
					   && QuByQuote.Organization_Action_Owner__c == null){
						None_OrderFieldsNull = None_OrderFieldsNull+1;
					}
                     
                    if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'IMPORT ISSUE'){
                        Import_Issue =Import_Issue+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'Config Error'){
                        Config_Error = Config_Error+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'INCORRECT SUBMISSION'){
                        Incorrect_Submission =Incorrect_Submission+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'DUPLICATE QUOTE'){
                        DUPLICATE_QUOTE =DUPLICATE_QUOTE+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'LACK OF INFORMATION'){
                        LACK_OF_INFORMATION =LACK_OF_INFORMATION+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'PROCESSED'){
                        PROCESSED =PROCESSED+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'REJECTED'){
                        REJECTED =REJECTED+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'WIP'){
                        WIP =WIP+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'ACKNOWLEDGED STILL SHOWING OPEN'){
                        ACKNOWLEDGED =ACKNOWLEDGED+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'CUSTOMER'){
                        CUSTOMER =CUSTOMER+1;
                    }
                    else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'OTHER'){
                        OTHER =OTHER+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'SALESPERSON NAME MISSING UNABLE TO PROCEED'){
                        UNABLE_TO_PROCEED =UNABLE_TO_PROCEED+1;
                    }else if(QuByQuote.Order_Not_Booked_Reason_Status__c == 'CUSTOMER CREDIT HOLD'){
                        CUSTOMER_CREDIT_HOLD =CUSTOMER_CREDIT_HOLD+1;
                    }
                    
                      WrapperQuotes wq= new WrapperQuotes();
                      wq.QuoteNo =QuByQuote.Quote_Number__c;
                      if(QuByQuote.QuickLook_ID__c !=null && mpQuicklookTOName.containsKey(QuByQuote.QuickLook_ID__c)){
                          wq.Owner = mpQuicklookTOName.get(QuByQuote.QuickLook_ID__c); 
                      }else{
                           wq.Owner ='';
                      }
                      wq.OpportunityNumber = QuByQuote.Opportunity_No__c;
                      wq.OpportunityValue = QuByQuote.Opportunity__r.Amount;
                      wq.QuoteTotal = QuByQuote.Total_Quote_Amount__c;
                      Date myDate = date.newinstance(QuByQuote.Solution_Modification_Date__c.year(), QuByQuote.Solution_Modification_Date__c.month(), QuByQuote.Solution_Modification_Date__c.day());
                      wq.DateModified = myDate;
                      wq.Status = QuByQuote.Order_Not_Booked_Reason_Status__c;
                      wq.ActionOwner = QuByQuote.Organization_Action_Owner__c;
                      wq.PendingReason = QuByQuote.Order_Not_Booked_Pending_Reason__c;
                      wq.FinancialCallOff =   QuByQuote.Financial_Call_Off__c;
                      
                      sDW.OrderSubmittedToBOC.add(wq);   
                }
                //Third Category
                //sDW.OrderReturnedToSales = new List<WrapperQuotes>();
                if(QuByQuote.Solution_Quote_Status__c =='Returned'){
                         Missing_Documentations = Missing_Documentations+1;
                    
                      WrapperQuotes wq= new WrapperQuotes();
                      wq.QuoteNo =QuByQuote.Quote_Number__c;
                      if(QuByQuote.QuickLook_ID__c !=null && mpQuicklookTOName.containsKey(QuByQuote.QuickLook_ID__c)){
                          wq.Owner = mpQuicklookTOName.get(QuByQuote.QuickLook_ID__c); 
                      }else{
                           wq.Owner ='';
                      }
                      wq.OpportunityNumber = QuByQuote.Opportunity_No__c;
                      wq.OpportunityValue = QuByQuote.Opportunity__r.Amount;
                      wq.QuoteTotal = QuByQuote.Total_Quote_Amount__c;
                      Date myDate = date.newinstance(QuByQuote.Solution_Modification_Date__c.year(), QuByQuote.Solution_Modification_Date__c.month(), QuByQuote.Solution_Modification_Date__c.day());
                      wq.DateModified = myDate;
                      wq.ReturnComment = QuByQuote.Return_Comment__c;
                      wq.ReturnReason = QuByQuote.Return_Reason__c;
                      wq.FinancialCallOff =   QuByQuote.Financial_Call_Off__c;
                      
                      sDW.OrderReturnedToSales.add(wq);   
                }  
            }
			//Sort Quotes for First Category
			/* InProgressQuotes.addAll(ApprovalRequiredQuotes);
			 for(QuBy_Detail__c QuByQuote: InProgressQuotes){
				 WrapperQuotes wq= new WrapperQuotes();
                      wq.QuoteNo =QuByQuote.Quote_Number__c;
                      if(QuByQuote.QuickLook_ID__c !=null && mpQuicklookTOName.containsKey(QuByQuote.QuickLook_ID__c)){
                          wq.Owner = mpQuicklookTOName.get(QuByQuote.QuickLook_ID__c); 
                      }else{
                           wq.Owner ='';
                      }
                     
                      wq.OpportunityNumber = QuByQuote.Opportunity_No__c;
                      wq.OpportunityValue = QuByQuote.Opportunity__r.Amount;
                      wq.QuoteTotal = QuByQuote.Total_Quote_Amount__c;
                      Date myDate = date.newinstance(QuByQuote.Solution_Modification_Date__c.year(), QuByQuote.Solution_Modification_Date__c.month(), QuByQuote.Solution_Modification_Date__c.day());
                      wq.DateModified = myDate;
                      wq.HW_SW_Status = QuByQuote.Solution_Quote_Status__c;
                      wq.Main_SupportStatus = QuByQuote.Annuity_Quote_Status__c;
                      wq.FinancialCallOff =   QuByQuote.Financial_Call_Off__c;
                      
                      sDW.QuotesInProcess.add(wq);
			 }*/
			
			//End
            //Make Dynamic 
			  sDW.NotBookedReasons = new list<WrapperReason>();
                    if(Import_Issue >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'Import Issue';
						 wr.NumberOfQuotes = Import_Issue;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(CUSTOMER_CREDIT_HOLD >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'CUSTOMER CREDIT HOLD';
						 wr.NumberOfQuotes = CUSTOMER_CREDIT_HOLD;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(Config_Error >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'Config Error';
						 wr.NumberOfQuotes = Config_Error;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(Incorrect_Submission >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'Incorrect Submission';
						 wr.NumberOfQuotes = Incorrect_Submission;
						 sDW.NotBookedReasons.add(wr);
					 }
					 
					 if(DUPLICATE_QUOTE >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'DUPLICATE QUOTE';
						 wr.NumberOfQuotes = DUPLICATE_QUOTE;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(LACK_OF_INFORMATION >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'LACK OF INFORMATION';
						 wr.NumberOfQuotes = LACK_OF_INFORMATION;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(PROCESSED >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'PROCESSED';
						 wr.NumberOfQuotes = PROCESSED;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(REJECTED >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'REJECTED';
						 wr.NumberOfQuotes = REJECTED;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(WIP >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'WIP';
						 wr.NumberOfQuotes = WIP;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(ACKNOWLEDGED >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'ACKNOWLEDGED STILL SHOWING OPEN';
						 wr.NumberOfQuotes = ACKNOWLEDGED;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(CUSTOMER >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'CUSTOMER';
						 wr.NumberOfQuotes = CUSTOMER;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(OTHER >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'OTHER';
						 wr.NumberOfQuotes = OTHER;
						 sDW.NotBookedReasons.add(wr);
					 }
					 if(UNABLE_TO_PROCEED >0){
						WrapperReason wr = new WrapperReason();
 						 wr.ReasonName = 'SALESPERSON NAME MISSING UNABLE TO PROCEED';
						 wr.NumberOfQuotes = UNABLE_TO_PROCEED;
						 sDW.NotBookedReasons.add(wr);
					 }
            
		    //End of Dynamic
                sDW.Awaiting_Approvals=countAwaiting_Approvals;
                sDW.InProgress = countInProgress;
                sDW.Config_Error=Config_Error;
                sDW.Import_Issue=Import_Issue;
                sDW.Incorrect_Submission = Incorrect_Submission;
                sDW.Missing_Documentations=Missing_Documentations;
				sDW.None_OrderFieldsNull = None_OrderFieldsNull;
                lstDashboardWp.add(sDW);
                system.debug('*****'+sDW);
            
            
            system.debug('lstDashboardWp'+lstDashboardWp);
           system.debug('lstacc'+acc.All_QuBy_Quotes_Acc__r.size()); 
        }
        
        
        return lstDashboardWp;
    }
    
    @AuraEnabled
    public static statusDashboardWrapper getstatusDashboardCount( string accountId ){
        statusDashboardWrapper SDW = new statusDashboardWrapper();
        if( accountId != null ){
            //DO YOUR QUERY HERE and populate the value;
            SDW.Awaiting_Approvals = 15; // i.e [ SELECT COUNT() FROM ACCOUNT WHERE ID =: accountId AND ...  ]
            SDW.Import_Issue = 10; // i.e [ SELECT COUNT() FROM ACCOUNT WHERE ID =: accountId AND ...  ]
            SDW.Config_Error = 2;  // i.e [ SELECT COUNT() FROM ACCOUNT WHERE ID =: accountId AND ...  ]
            SDW.Incorrect_Submission = 3; // i.e [ SELECT COUNT() FROM ACCOUNT WHERE ID =: accountId AND ...  ]
            SDW.Missing_Documentations = 5; // i.e [ SELECT COUNT() FROM ACCOUNT WHERE ID =: accountId AND ...  ]
        }
        return SDW;
    }
    
    public class statusDashboardWrapper{
        @AuraEnabled
         Public String AccountName;
        
        @AuraEnabled
         Public String AccountId;
        
        @AuraEnabled 
        public integer Awaiting_Approvals;
        
        @AuraEnabled 
        public integer InProgress;
        
        @AuraEnabled
        public integer Import_Issue;
        
        @AuraEnabled
        public integer Config_Error;
        
        @AuraEnabled
        public integer Incorrect_Submission;
        
        @AuraEnabled
        public integer Missing_Documentations;
		
		@AuraEnabled
        public integer None_OrderFieldsNull;
        
        @AuraEnabled
        public List<WrapperReason> NotBookedReasons;
        
        @AuraEnabled
        public List<WrapperQuotes> QuotesInProcess;
        
        @AuraEnabled
        public List<WrapperQuotes> OrderSubmittedToBOC;
        
        @AuraEnabled
        public List<WrapperQuotes> OrderReturnedToSales;
    }
    public class WrapperReason{
        @AuraEnabled
        public String ReasonName;
        
        @AuraEnabled
        public integer NumberOfQuotes;
        
       
    }
    public class WrapperQuotes{	
        @AuraEnabled
        public string QuoteNo{get;set;}
        @AuraEnabled
        public string Owner{get;set;}
        @AuraEnabled
        public String OpportunityNumber{get;set;}
        @AuraEnabled
        public Decimal OpportunityValue{get;set;}
        @AuraEnabled
        public Decimal QuoteTotal{get;set;}
         @AuraEnabled
        public date DateModified{get;set;}
        @AuraEnabled
        public String HW_SW_Status{get;set;}
        @AuraEnabled
        public String Main_SupportStatus{get;set;}
        @AuraEnabled
        public integer OrderTotal{get;set;}
         @AuraEnabled
        public string ActionOwner{get;set;}
        @AuraEnabled
        public String Status{get;set;}
        @AuraEnabled
        public String PendingReason{get;set;}
        @AuraEnabled
        public String ReturnReason{get;set;}
        @AuraEnabled
        public String ReturnComment{get;set;}
        @AuraEnabled
        public String FinancialCallOff{get;set;}
    }
}