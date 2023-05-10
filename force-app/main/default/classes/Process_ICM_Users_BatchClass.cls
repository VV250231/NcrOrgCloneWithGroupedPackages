/**
* Class is used to Sync ICM users on daily basis.
*
* @author  Santosh Jha
* @Data   16-Sep-2021
*/


global class Process_ICM_Users_BatchClass implements Database.Batchable<sObject>,Database.Stateful{
    
    
    global integer totalCounter=0;
    global integer updateCounter=0;
    global integer failedCounter=0;
    list<string> strICMGlobalList = new List<string>();
    String errMsg = '';
   
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
 
        string query ;
        if(Test.isRunningTest()){
            query = 'select id, ICM_User__c,Quicklook_ID__c from user where Quicklook_ID__c = \'sj185091\'';
            errMsg = 'error';
        }
        else{
            query = 'select id, ICM_User__c,Quicklook_ID__c from user';
        }

                     
        list<ICM_User__c> icmList  = [Select id,Data_Load_Date__c,Quicklook_ID__c from ICM_User__c where Data_Load_Date__c =: Date.today()]; 
        totalCounter = icmList.size();
        for (ICM_User__c icmuser:icmList ) strICMGlobalList.add(icmuser.Quicklook_ID__c);
        
        if (totalCounter>0)
        {
            return Database.getQueryLocator(query);
        }
        else 
        {
            query = 'select id, ICM_User__c,Quicklook_ID__c from user limit 0';
            return Database.getQueryLocator(query);
        }
    }
    
    global void execute(Database.BatchableContext BC, List<user> scope) {
 		if (totalCounter > 0)
        {
        list<user> ulist = new list<user>();
        for ( user u : scope)
        {
            user ul = new user();
            if(u.ICM_User__c==False && strICMGlobalList.contains(u.Quicklook_ID__c)==True)
            {
                system.debug('@@@@@False'+u);
                ul.id = u.id;
                ul.ICM_User__c =  true;
                ulist.add(ul);
            }
           
            else  
            {
                if(u.ICM_User__c==True && strICMGlobalList.contains(u.Quicklook_ID__c)==False)
                { 
                system.debug('@@@@@True'+u);
                ul.id = u.id;
                ul.ICM_User__c =  false;
                ulist.add(ul);
            	}
            }
        }
        if (ulist<>null && ulist.size()>0){
            
            system.debug('@@@Updated'+ulist);
            updateCounter = ulist.size()+updateCounter;
           // system.debug('@@@@Counter'+updateCounter);
            //update ulist;
            
            Database.SaveResult[] srList = Database.update(ulist, false);
            for (Database.SaveResult sr : srList) {
                if (!sr.isSuccess()) {
                    for(Database.Error err : sr.getErrors()) {
                       
                        failedCounter=failedCounter+sr.getErrors().size(); errMsg += 'The following error has occurred.'+err.getStatusCode() + ': ' + err.getMessage()+ 'User fields that affected this error: '+ err.getFields();  

                    }
                }
            }
            
        }
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {  
        list<ICM_User__c> icmdelUser = [Select id,Quicklook_ID__c from ICM_User__c where Data_Load_Date__c =: Date.today().addDays(-3)];
         if (icmdelUser<>null && icmdelUser.size()>0){ delete icmdelUser;
         }
        
        

        //system.debug('@@@@@counter'+counter);
        String mailBdy = 'Total number of records Procecessed ==> '+totalCounter
            +'<Br/>Number of records to be updated ==> '+updateCounter
            +'<Br/>Number of record failed ==> '+failedCounter;
        string emailSubject = '';
        string emailSubHeader = '';
        string emailHeader= '';
        
        if (String.isNotEmpty(errMsg)) {
            errMsg += '<Br/><Br/> Fix the record and re-run the batch by using below command <Br/> <p style="color:blue">Process_ICM_Users_BatchClass batch = new Process_ICM_Users_BatchClass(False);<Br/>database.executebatch(batch, 200);</p>';
            
            emailHeader='Batch Job Failed';
            emailSubject = emailHeader;
            emailSubHeader = 'Batch Process Failed for below users';
            mailBdy  = mailBdy+errMsg;
        }
        else 
        {
             emailHeader='Batch Job Succeeded';
        }
            emailSubject = emailHeader+' For ICM Users';
            emailSubHeader = emailHeader+' For ICM Users';
                   
        if (totalCounter==0)
        {
            EmailUtility.sendEmail('Batch job failed ICM user','Batch job failed','Batch job failed ICM user','0 records found today please contact ICM team',(Label.BatchClassEmailNotification).split(','));  
            
        }
        else 
        {
            EmailUtility.sendEmail(emailSubject,emailHeader,emailSubHeader,mailBdy,(Label.BatchClassEmailNotification).split(',')); 
            
        }

    }
}