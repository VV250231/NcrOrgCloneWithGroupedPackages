/**
* Class is used to clean obsolete Credit Detail on daily basis.
*
* @author  Ajay Dixit
* @Data   2020-04-28
*/
global class Credit_Detail_Clean implements Database.Batchable<sObject>,Database.Stateful {
    private Integer hours=24;
    global Boolean clean; 
    global Integer successCounter = 0;
    global Integer failureCounter = 0; 
    global String Status = '';
    Exception[] errorslist = new Exception[0];
    global integer totalSizeRecords=0;
    public Credit_Detail_Clean(Boolean cleanup) {
        this.clean = cleanup;       
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        if(clean){
            DateTime currentDate = DateTime.Now().addHours(-hours); 
            system.debug('***@@@@'+currentDate);
            return DataBase.getQueryLocator([Select Id, LastModifiedDate From Credit_Detail_Break_Up__c where LastModifiedDate<:currentDate]);
        }else{
            return DataBase.getQueryLocator([Select id From Credit_Detail__c]); 
        }        
    }
    global void execute(Database.BatchableContext BC,List<sObject> scope) {
        try {
            system.debug('***@@@'+scope);
            if(clean){
                
                List <Credit_Detail_Break_Up__c> deleteCreditBreakup=new  List <Credit_Detail_Break_Up__c>();
                deleteCreditBreakup=(List <Credit_Detail_Break_Up__c>) scope;
                system.debug('***$$$'+deleteCreditBreakup);
                if (scope.size() > 0 && ! TEST.isRunningTest()) {               
                    Delete deleteCreditBreakup;
                }   
            }else{
                totalSizeRecords+=scope.size();
                //Map<Id, Id> accountOwnerIdToNSCAdminIdMap = new Map<Id,Id>();
                //User nscAdminUser = [Select Id FROM User where name = 'NSC Admin'];
                User nscAdminUser = [Select Id FROM User where Quicklook_ID__c = 'NSCAdmin'];
                //get all credit breakup in scope
                //SELECT Aging_31_60__c,Aging_31__c,Aging_61_90__c,Aging_91_180__c,Aging_181_360__c,Aging_360__c,Classification_Invoice_Type__c,Customer_Balance__c,Industry__c,Not_Due_1_360_Days__c,Not_Due_360_Days__c,On_Hold__c,Risk_Level__c,Unique_ID__c FROM Credit_Detail_Break_Up__c
                List <Credit_Detail__c> rollupCreditList=new  List <Credit_Detail__c>();
                List <Credit_Detail__c> CreditDetail=[SELECT Account__r.OwnerId, Account__r.Owner.IsActive, Account__r.Owner.Profile.Name, (SELECT Aging_31_60__c,Aging_31__c,Aging_61_90__c,Aging_91_180__c,Aging_181_360__c,Aging_360__c,Classification_Invoice_Type__c,Customer_Balance__c,Industry__c,Not_Due_1_360_Days__c,Not_Due_360_Days__c,Past_due_000_to_030_days__c,Past_due_031_to_045_days__c,Past_due_046_to_060_days__c,Past_due_061_to_75_days__c,Past_due_76_to_90_days__c,Past_due_90_plus_days__c,On_Hold__c,Risk_Level__c,Unique_ID__c,Collector_Name__c FROM Credit_Detail_Break_Ups__r), Customer_Balance__c,Not_Due_1_360_Days__c,Not_Due_360_Days__c,On_Hold__c,Risk_Level__c,Unique_ID__c,X1_30_Days_Late__c,X31_60_Days_Late__c,X61_90_Days_Late__c,X91_180_Days_Late__c,X181_360_Days_Late__c,X361_Days_Late__c, Assigned_Collector__c FROM Credit_Detail__c WHERE Id = :scope];
                //Added Collector_Name__c,Assigned_Collector__c in query - EBA_SF-828
                for(Credit_Detail__c cd:CreditDetail){
                    Credit_Detail__c cdn=new Credit_Detail__c();
                    cdn.id=cd.id;
                    //Reset Values
                    /*********************** Credit Detail Owner Assignment ****************************/
                    if(cd.Account__r.Owner.IsActive == false || cd.Account__r.Owner.Profile.Name == 'Read Only'){
                        cdn.OwnerId = nscAdminUser.Id;
                    }else{
                        cdn.OwnerId = cd.Account__r.OwnerId;
                    }
                    
                    cdn.Customer_Balance__c=0;
                    cdn.X1_30_Days_Late__c=0;
                    cdn.X31_60_Days_Late__c=0;
                    cdn.X61_90_Days_Late__c=0;
                    cdn.X91_180_Days_Late__c=0;
                    cdn.X181_360_Days_Late__c=0;
                    cdn.X361_Days_Late__c=0;
                    cdn.Not_Due_1_360_Days__c=0;
                    cdn.Not_Due_360_Days__c=0;
                    cdn.Past_due_000_to_030_days__c=0;
                    cdn.Past_due_031_to_045_days__c=0;
                    cdn.Past_due_046_to_060_days__c=0;
                    cdn.Past_due_061_to_75_days__c=0;
                    cdn.Past_due_76_to_90_days__c=0;
                    cdn.Past_due_90_plus_days__c=0;
                    cdn.Risk_Level__c='';
                    cdn.On_Hold__c='NO';
                    system.debug('***### cd'+cd);
                    system.debug('***###'+cd.Credit_Detail_Break_Ups__r.size());
                       //EBA_SF-828
                        String AR_collector = '';
                    for(Credit_Detail_Break_Up__c cdb:cd.Credit_Detail_Break_Ups__r){
                        if(cdb.Customer_Balance__c != null){
                            cdn.Customer_Balance__c=cdn.Customer_Balance__c+cdb.Customer_Balance__c;
                            cdn.X1_30_Days_Late__c=cdn.X1_30_Days_Late__c+cdb.Aging_31__c;
                            cdn.X31_60_Days_Late__c=cdn.X31_60_Days_Late__c+cdb.Aging_31_60__c;
                            cdn.X61_90_Days_Late__c=cdn.X61_90_Days_Late__c+cdb.Aging_61_90__c;
                            cdn.X91_180_Days_Late__c=cdn.X91_180_Days_Late__c+cdb.Aging_91_180__c;
                            cdn.X181_360_Days_Late__c=cdn.X181_360_Days_Late__c+cdb.Aging_181_360__c;
                            cdn.X361_Days_Late__c=cdn.X361_Days_Late__c+cdb.Aging_360__c;
                            cdn.Not_Due_1_360_Days__c=cdn.Not_Due_1_360_Days__c+cdb.Not_Due_1_360_Days__c;
                            cdn.Not_Due_360_Days__c=cdn.Not_Due_360_Days__c+cdb.Not_Due_360_Days__c;
                            cdn.Past_due_000_to_030_days__c = cdn.Past_due_000_to_030_days__c+cdb.Past_due_000_to_030_days__c;
                            cdn.Past_due_031_to_045_days__c=cdn.Past_due_031_to_045_days__c+cdb.Past_due_031_to_045_days__c;
                            cdn.Past_due_046_to_060_days__c=cdn.Past_due_046_to_060_days__c+cdb.Past_due_046_to_060_days__c;
                            cdn.Past_due_061_to_75_days__c=cdn.Past_due_061_to_75_days__c+cdb.Past_due_061_to_75_days__c;
                            cdn.Past_due_76_to_90_days__c=cdn.Past_due_76_to_90_days__c+cdb.Past_due_76_to_90_days__c;
                            cdn.Past_due_90_plus_days__c=cdn.Past_due_90_plus_days__c+cdb.Past_due_90_plus_days__c;
                            cdn.Risk_Level__c=cdb.Risk_Level__c;
                            cdn.On_Hold__c=cdb.On_Hold__c;
                            //EBA_SF-828
                            if( String.isBlank(AR_collector)){
                                AR_collector = cdb.Collector_Name__c;
                            }
                        }
                        
                    }
                    //EBA_SF-828
                    cdn.Assigned_Collector__c = AR_collector;
                    rollupCreditList.add(cdn);
                    
                }
                
                update rollupCreditList;
                successCounter++;
                
            }
            
            
        } catch (Exception e) {
            failureCounter++;
            errorslist.add(e);
            
        }
    }
    global void finish(Database.BatchableContext BC) {
        if(clean){
            Credit_Detail_Clean rollup = new Credit_Detail_Clean(false);
            ID batchprocessid = Database.executeBatch(rollup);
        }
        
        else
        {
            string emailBodytoReplaced = 'Total number of records ==> '+totalSizeRecords
                +'<Br/>Number of batch completed ==> '+successCounter
                +'<Br/>Number of batch failed ==> '+failureCounter;
            
            string emailHeader='';
            
            if(failureCounter==0)
            {
                emailHeader='Batch Job Succeeded';
            } 
            else 
            {
                emailHeader='Batch Job Failed'; 
                emailBodytoReplaced += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue">Credit_Detail_Clean batch = new Credit_Detail_Clean(False);<Br/>database.executebatch(batch, 200);</p>';
                integer n=1;
                for(Exception e : errorslist) 
                {  
                    emailBodytoReplaced += n+'.'+' '+'Exception Occured:' + e.getMessage() + '<Br/>' + e.getStackTraceString()+'<Br/>';
                    n++;
                    
                }
            }
            
            string emailSubject = emailHeader+' For Credit Detail Cleanup';
            string emailSubHeader = emailHeader+' For Credit Detail Cleanup';
            EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
            String EmailBody=template.HtmlValue;
            
            CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,(Label.BatchClassEmailNotification).split(',')); 
        }
    }
}