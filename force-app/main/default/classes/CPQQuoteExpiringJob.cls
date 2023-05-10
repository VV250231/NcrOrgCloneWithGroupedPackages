/********************
* Class Name: CPQQuoteExpiringJob
* Description: This class resposible to expire quote and fullfillment orders based on conditions
* Created By: Dharmendra Kumar Pandey
* Created Date: 11-AUG-2022
* 
* Srno       Date            Description
* 1       11-AUG-2022     SFCPQBLG-959
* 
* *******************************************/
public class CPQQuoteExpiringJob implements Database.Batchable<sObject>,Database.Stateful {
    public Integer successCounter = 0;
    public Integer failureCounter = 0; 
    public List<String> errorslist = new List<String>();
    public integer totalSizeRecords=0;
    public DateTime StartTime;
    public DateTime EndTime;
    public String qrtTestOnly;
    public String quoteToUpdates;
    public Database.QueryLocator start( Database.BatchableContext BC ) {
        StartTime = System.now();
        String qry = 'SELECT Id, Name, SBQQ__Account__c, ApprovalStatus__c, CreatedDate,SBQQ__ExpirationDate__c, LastModifiedDate, qtc_Legal_Document_Status__c,'+
            'qtc_Multi_Site__c, qtc_Multi_Site_Relationship__c, qtc_Multi_Site_Type__c,SBQQ__Opportunity2__c, qtc_Order_Authorization_Accepted_Date__c,'+
            'qtc_Order_Authorization_Sent_Date__c, SBQQ__Ordered__c, Overall_Order_Auth_Status__c,Overall_Order_Status__c, Payments_Approval__c, SBQQ__Primary__c,'+
            'SBQQ__PrimaryContact__c, SBQQ__SalesRep__c, qtc_Payments_Only_Quote__c,SBQQ__Status__c, qtc_Status_of_all_Applications__c, SBQQ__Type__c,'+
            'SBQQ__Account__r.Master_Customer_Number__c, SBQQ__Opportunity2__r.CPQ__c,SBQQ__Opportunity2__r.StageName, SBQQ__SalesRep__r.Name,qtc_Interchange_Payments_Approval_Status__c,'+
            'SBQQ__SalesRep__r.Username,SBQQ__PrimaryContact__r.Name '+
            'FROM SBQQ__Quote__c WHERE SBQQ__ExpirationDate__c <= TODAY '+
            'AND SBQQ__Status__c != \'Expired\' '+
            'AND SBQQ__Ordered__c = false '+
            'AND (NOT qtc_Legal_Document_Status__c LIKE \'Completed%\') '+
            'AND (qtc_Status_of_all_Applications__c  != \'ApprovedAndBoarded\') '+
            'AND SBQQ__Opportunity2__r.CPQ__c = true '+
            'order by CreatedDate DESC';
  /*
        'AND ((SBQQ__Ordered__c = false '+
            'AND (NOT qtc_Legal_Document_Status__c LIKE \'Completed%\') '+
            'AND (qtc_Payments_Only_Quote__c = \'No\' '+
            'OR (qtc_Multi_Site_Type__c IN (\'AE+PP\', \'AE Only\') AND qtc_Multi_Site_Relationship__c = \'Child\'))) ' +
            'OR ((NOT qtc_Status_of_all_Applications__c  like \'Approved%\') '+
            'AND (qtc_Payments_Only_Quote__c = \'Yes\' OR (qtc_Multi_Site_Type__c IN (\'AE+PP\') AND qtc_Multi_Site_Relationship__c = \'Parent\') OR qtc_Multi_Site_Type__c=\'PP Only\'))) '+
            'AND SBQQ__Opportunity2__r.CPQ__c = true '+
            'order by CreatedDate DESC ';
*/
        system.debug(qry);
        qrtTestOnly = qry;
        return Database.getQueryLocator( qry );
    }
    
    
    public void execute( Database.BatchableContext BC, List< SBQQ__Quote__c > scope ) {
        Map<Id,SBQQ__Quote__c> quoteListToUpdate = new Map<Id,SBQQ__Quote__c>();
        List<Id> paRecallIds = new List<Id>();
        
        Set<Id> resultIds = (new Map<Id,SObject>(scope)).keySet();
        Set<Id> notExpQte = new Set<Id>();
        for(NCR_Payments_Site__c pSite: [Select Quote__r.Id,NCR_Payments_Application_Status__c from NCR_Payments_Site__c where NCR_Payments_Application_Status__c='ApprovedAndBoarded'
                                                   AND Quote__r.Id IN: resultIds]){
                notExpQte.add(pSite.Quote__r.Id);
                                                           
        }

        for ( SBQQ__Quote__c quote : scope ) {
            if(!notExpQte.contains(quote.id)){
                quote.SBQQ__status__c = 'Expired';
                quote.ApprovalStatus__c = null;
                quoteListToUpdate.put(quote.id, quote);
                quoteToUpdates = quoteToUpdates +', '+quote.Name;
                try {
                    SBAA.ApprovalAPI.recall(quote.Id, SBAA__Approval__c.Quote__c);
                    // Payment interchange plus approval recall
                    if(quote.qtc_Interchange_Payments_Approval_Status__c=='Approved' || quote.qtc_Interchange_Payments_Approval_Status__c =='Pending'){
                        paRecallIds.add(quote.Payments_Approval__c);
                    }
                } catch(Exception ex){
                    quoteToUpdates = quoteToUpdates +'<Br/> Quote#'+quote.Name+' Recall Failed:'+ ex.getMessage();  
                }
            }
        }
        
        // payment recall
        List<qtc_PaymentsApproval__c> qtcPALst = [Select Id, qtc_ApprovalAction__c from qtc_PaymentsApproval__c where Id IN :paRecallIds];
        for(qtc_PaymentsApproval__c qpa : qtcPALst){
            qpa.qtc_ApprovalAction__c = 'Recall';
        }
        if(qtcPALst.size()>0){
            List<Database.SaveResult> updatePA = database.update(qtcPALst,false);
        }
        
        //Approval reset
        List<sbaa__Approval__c> aprList = [SELECT id, Quote__r.Name, sbaa__Archived__c, sbaa__Status__c,lastmodifieddate  FROM sbaa__Approval__c WHERE Quote__c IN :quoteListToUpdate.keyset() AND sbaa__Archived__c=false];
        for(sbaa__Approval__c apr : aprList){
            apr.sbaa__Archived__c= true;
            //apr.sbaa__Status__c = 'Recalled';
        }           
        if(aprList.size()>0) {
            List<Database.SaveResult> updateApr = database.update(aprList,false);
        }
        
        List<qtc_FulfillmentOrder__c> fmOrdLst = [SELECT Id, Name, qtc_ActualDeliveryDate__c,qtc_ERP_Order_Number__c, qtc_ERP_Order_Status__c, Order_Interface_Status__c,
                                                  qtc_Quote__c, qtc_Quote_Number__c, qtc_QuoteOrdered__c
                                                  FROM qtc_FulfillmentOrder__c WHERE qtc_Quote__c IN :quoteListToUpdate.keyset()];
        
        System.debug('quoteListToUpdate'+quoteListToUpdate.size());
        totalSizeRecords += scope.size();
        System.debug('totalSizeRecords'+totalSizeRecords);
        List<Database.SaveResult> updateResults = new List<Database.SaveResult>();
        try {
            SBQQ.TriggerControl.disable();
            updateResults = database.update(quoteListToUpdate.values(),false);
        } finally {
            SBQQ.TriggerControl.enable(); 
        }
        
        for(qtc_FulfillmentOrder__c fmOrd: fmOrdLst){
            fmOrd.Order_Interface_Status__c='Quote Expired';
        }
        
        List<Database.SaveResult> fmupdateResults = database.update(fmOrdLst,false);
        
        for(Integer i=0;i<updateResults.size();i++){
            if (updateResults.get(i).isSuccess()){
                updateResults.get(i).getId();
                successCounter++;
                System.debug('successCounter'+successCounter);
            }else if (!updateResults.get(i).isSuccess()){
                // DML operation failed
                Database.Error error = updateResults.get(i).getErrors().get(0);
                failureCounter++;
                String failedDML = error.getMessage();
                errorslist.add(quoteListToUpdate.values().get(i).Id+': Failed because of'+failedDML);
                system.debug('Failed ID'+quoteListToUpdate.values().get(i).Id);
            }
        } 
    }
    
    public void finish( Database.BatchableContext BC ) {
        EndTime = System.now();
        string emailBodytoReplaced = 'Total number of records ==> '+totalSizeRecords
            +'<Br/>Number of records succeeded ==> '+successCounter
            +'<Br/>Number of records failed ==> '+failureCounter
            +'<Br/>Start Time ==> '+StartTime
            +'<Br/>End Time ==> '+EndTime
            +'<Br/>Query ==> <Br/>'+ qrtTestOnly
            +'<Br/>Quotes ==> <Br/>'+ quoteToUpdates;
        System.debug('Total Count'+totalSizeRecords);
        System.debug( 'Failure Count :'+failureCounter);
        System.debug( 'Sucess Count :'+successCounter);
        
        string emailHeader='';
        if(failureCounter==0) {
            emailHeader='CPQ Quote Expiring Batch Job Succeeded';
        } else {
            emailHeader='CPQ Quote Expiring Batch Job Failed'; 
            emailBodytoReplaced += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue"><Br/>database.executebatch(new CPQQuoteExpiringJob(), 5);</p>';
            integer n=1;
            for(String e : errorslist) {  
                emailBodytoReplaced += n+'.'+e;
                n++;
            }
        }
        
        string emailSubject = emailHeader+' For CPQ Quote Expiring Job';
        string emailSubHeader = emailHeader+' For CPQ Quote Expiring Job';
        EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
        String EmailBody=template.HtmlValue;
        
        CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,(Label.BatchJobEmailNotificationList).split(','));
    }
    
}