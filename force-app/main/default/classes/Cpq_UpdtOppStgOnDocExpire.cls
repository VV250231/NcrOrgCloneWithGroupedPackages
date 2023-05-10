public class Cpq_UpdtOppStgOnDocExpire implements Database.Batchable<sObject>,Database.Stateful {
    public Integer successCounter = 0;
    public Integer failureCounter = 0; 
    public List<String> errorslist = new List<String>();
    public integer totalSizeRecords=0;
  	public DateTime StartTime;
    public DateTime EndTime;
    
    public Database.QueryLocator start( Database.BatchableContext BC ) {
        StartTime = System.now();
        DateTime backTime =StartTime.AddDays(-150);
 		/*       
    	String query ='SELECT Id,Quote__r.SBQQ__Opportunity2__r.Name,Quote__r.SBQQ__Opportunity2__r.Id,Quote__r.SBQQ__Opportunity2__r.Primary_Loss_Reason__c,Quote__r.SBQQ__Opportunity2__r.StageName '+
            'FROM Customer_Document__c ' +
            'WHERE Document_Type__c = \'AE Order Form\' '+
            'AND Quote__r.SBQQ__Opportunity2__r.CPQ__c = TRUE AND Quote__r.SBQQ__Opportunity2__r.IsClosed=false '+ 
            'AND Quote__r.SBQQ__Opportunity2__r.CloseDate <'+System.Now().format('yyyy-MM-dd')+    
            ' AND Document_Sent_Date__c <'+currentTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'z\''); 
        system.debug(query);
	    */
        String qry = 'Select id,Name,SBQQ__Primary__c,SBQQ__Status__c,SBQQ__ExpirationDate__c,SBQQ__Type__c,SBQQ__Opportunity2__r.Name,SBQQ__Opportunity2__r.Id,SBQQ__Opportunity2__r.Primary_Loss_Reason__c,'+
            'SBQQ__Opportunity2__r.StageName from SBQQ__Quote__c '+ 
			'where SBQQ__Primary__c = true AND SBQQ__Status__c =\'Expired\' AND (SBQQ__ExpirationDate__c < '+backTime.format('yyyy-MM-dd') + ' OR SBQQ__Type__c= \'Amendment\') '+ 
			' AND SBQQ__Opportunity2__r.CPQ__c = TRUE AND SBQQ__Opportunity2__r.IsClosed=false AND SBQQ__Opportunity2__r.CloseDate  <'+System.Now().format('yyyy-MM-dd');
			system.debug(qry);
        	return Database.getQueryLocator( qry );
    }
    
    
    public void execute( Database.BatchableContext BC, List< SBQQ__Quote__c > scope ) {
        CheckRecursive.cpqSpclHdlg=true;  
        Map<Id,Opportunity> OppListToUpdate = new Map<Id,Opportunity>();
        for ( SBQQ__Quote__c quote : scope ) {
            Opportunity opp = new Opportunity(); 
            opp.Id=quote.SBQQ__Opportunity2__r.Id;
            opp.Primary_Loss_Reason__c = 'Quote Expired';
            opp.StageName ='Closed/Lost';
            opp.qtc_auto_closedlost__c = true;
            OppListToUpdate.put(Opp.id, Opp);
        }
        System.debug('OppListToUpdate'+OppListToUpdate.size());
        totalSizeRecords += scope.size();
        System.debug('totalSizeRecords'+totalSizeRecords);
        List<Database.SaveResult> updateResults = database.update(OppListToUpdate.values(),false);
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
                errorslist.add(OppListToUpdate.values().get(i).Id+': Failed because of'+failedDML);
                system.debug('Failed ID'+OppListToUpdate.values().get(i).Id);
            }
    	} 
    }
    
    public void finish( Database.BatchableContext BC ) {
        EndTime = System.now();
        string emailBodytoReplaced = 'Total number of records ==> '+totalSizeRecords
            +'<Br/>Number of records succeeded ==> '+successCounter
            +'<Br/>Number of records failed ==> '+failureCounter
            +'<Br/>Start Time ==> '+StartTime
            +'<Br/>End Time ==> '+EndTime;
        System.debug('Total Count'+totalSizeRecords);
        System.debug( 'Failure Count :'+failureCounter);
        System.debug( 'Sucess Count :'+successCounter);
        
        string emailHeader='';
        if(failureCounter==0) {
            emailHeader='Batch Job Succeeded';
        } else {
            emailHeader='Batch Job Failed'; 
            emailBodytoReplaced += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue"><Br/>database.executebatch(new Cpq_UpdtOppStgOnDocExpire(), 200);</p>';
            integer n=1;
            for(String e : errorslist) {  
                emailBodytoReplaced += n+'.'+e;
                n++;
            }
        }
        
        string emailSubject = emailHeader+' For Opportunity stage update on CPQ Quote Expire';
        string emailSubHeader = emailHeader+' For Opportunity stage update on CPQ Quote Expire';
        EmailTemplate template = [Select id, Body, HtmlValue, Subject from EmailTemplate where name = 'NCR Standard'];
        String EmailBody=template.HtmlValue;
        
        CommonUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,emailBodytoReplaced,EmailBody,(Label.BatchJobEmailNotificationList).split(','));
    }
    
}