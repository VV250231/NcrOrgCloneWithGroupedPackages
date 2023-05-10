public class BatchUtil {
    public class BatchUtilException extends Exception {}
    
    private Integer batchSize=200;
    private String recordLimit;
   	private String objectName;
    private String condition;
    private String NoOfDays;
    private Boolean systemLevel=true;
    private Boolean userLevel=false;
    private Boolean withSharing=true;
    private Boolean withoutSharing=false;
    private Boolean allOrNone=false;
    private String CronExprn;
    private Boolean isSchedule;
    
    public void setBatchSize(Integer batchSize)
    {
        this.batchSize=batchSize;
    }
    public void setObject(String objectName)
    {
        this.objectName=objectName;
    }
    public void setCondition(String condition)
    {
        this.condition=condition;
    }
     public void setNoOfDays(String NoOfDays)
    {
        this.NoOfDays=NoOfDays;
    }
    public void runAtSystemLevel(Boolean param)
    {
        systemLevel=param;
        if(!param) userLevel=true;
        else
            userLevel=false;
    }
    public void runAtUserLevel(Boolean param)
    {
        userLevel=param;
        if(!param) systemLevel=true;
        else 
            systemLevel=false;
    }
    public void setWithSharing(Boolean param)
    {
        withSharing=param;
        if(!param) withoutSharing=true;
        else
            withoutSharing=false;
    }
    public void setWithoutSharing(Boolean param)
    {
        withoutSharing=param;
        if(!param)
            withSharing=true;
        else
            withSharing=false;
    }
    public void setLimit(String recordLimit)
    {
        this.recordLimit=recordLimit;
    }
    public void setAllOrNone(Boolean allOrNone)
    {
        this.allOrNone=allOrNone;
    }
    public void setIsSchedule(Boolean isSchedule)
    {
        this.isSchedule=isSchedule;
    }
    public void setCronExp(String CronExprn)
    {
        this.CronExprn=CronExprn;
    }
    public void executeBatch()
    {
        String query='Select id from ';
        if(String.isBlank(objectName))
        {
            throw new BatchUtilException('Object API name is missing.Please provide the object name for record deletion.');
        }
        else
        {
            System.debug('@@@: '+objectName.toLowerCase());
            System.debug('@@@: '+Schema.getGlobalDescribe().get(objectName.toLowerCase()));
            if(Schema.getGlobalDescribe().get(objectName.toLowerCase())==null)
            {
             //throw new BatchUtilException('Object not found.Please make sure that you are providing the correct API name.');   
            }
                
            query+=objectName +' Where '; // Select id from case 
        }
        if(String.isNotBlank(condition))
            //This returns records that created N days before NoOfDays
            //query+=' where CreatedDate < LAST_N_DAYS:'+condition; // Select id from case where CreatedDate < LAST_N_DAYS:30 
              query+=condition;
            
        if(String.isNotBlank(recordLimit))
            query+=' LIMIT '+ recordLimit; // Select id from case where LastModifiedDate < LAST_N_DAYS:2  Limit 10
        if(userLevel)
        {
            if(!this.checkPermissions())
            {
                throw new BatchUtilException('User does not have sufficient permissions.');
            }
        }
        if(withSharing){
            system.debug('Query: '+query);
            if(!isSchedule){
                Database.executeBatch(new RecordDeletionWithSharing(query,allOrNone),batchSize);
            }
            else{
                this.scheduleJob(CronExprn,getUUID(),'withSharing',query,allOrNone);
            }
        }
            
        if(withoutSharing){
           system.debug('Query: '+query);
            if(!isSchedule){
                Database.executeBatch(new RecordDeletionWithoutSharing(query,allOrNone),batchSize);     
            }
             else{
                this.scheduleJob(CronExprn, getUUID(),'withoutSharing',query,allOrNone);
            }
              
        }
                  
    }
    private Boolean checkPermissions()
    {
        if(Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().isAccessible())
        {
            if(Schema.getGlobalDescribe().get(objectName.toLowerCase()).getDescribe().isDeletable())
                return true;
            else
                return false;
        }
        else
            return false;
    }
    public static void emailService(AsyncApexJob jobResult)
    {
        String emailId=UserInfo.getUserEmail();
        Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{emailId});
        mail.setSubject('Deletion of records completed');
        EmailTemplate emailTemplate = [SELECT Id, HtmlValue, Name, DeveloperName, IsActive FROM EmailTemplate WHERE IsActive = true AND DeveloperName = 'Data_CleanUp_Job_Scheduler'];
        
        String htmlBody = emailTemplate.HtmlValue;
        htmlBody = htmlBody.replace('#SchedulerName', UserInfo.getName());
        htmlBody = htmlBody.replace('#Status', jobResult.Status);
        htmlBody = htmlBody.replace('#TotalJobItems',  String.valueOf(jobResult.TotalJobItems));
        htmlBody = htmlBody.replace('#JobItemsProcessed',  String.valueOf(jobResult.JobItemsProcessed));
        htmlBody = htmlBody.replace('#NumberOfErrors',  String.valueOf(jobResult.NumberOfErrors));
        if(jobResult.ExtendedStatus!=null)
            htmlBody = htmlBody.replace('#failure', String.valueOf(jobResult.ExtendedStatus));
        else
            htmlBody = htmlBody.replace('#failure', 'None');
        
        mail.setHtmlBody(htmlBody);
        if(!Test.isRunningTest())
            Messaging.sendEmail(new List<Messaging.Email>{mail});
    }
    
         public static String getUUID()
    {
        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        system.debug(guid);
        return guid;
    }
    
    public Boolean scheduleJob(String cronString, String cronJobName, String SharingType, String query, Boolean allOrNone) {
        try {
            
            Data_Clean_up_Utility_Logs__c dc= new Data_Clean_up_Utility_Logs__c();
            dc.Job_Name__c=cronJobName;
            dc.Status__c='Scheduled';
            dc.Query_Executed__c=query; 
            if(dc !=null)
                insert dc;
            
            if(SharingType=='withSharing'){
                RecordDeletionWithSharingSchedule scheduler = new RecordDeletionWithSharingSchedule(query,allOrNone);
                System.schedule(cronJobName, cronString, scheduler); 
            }
            else if(SharingType=='withoutSharing'){
                RecordDeletionWithOutSharingSchedule scheduler = new RecordDeletionWithOutSharingSchedule(query,allOrNone);
                System.schedule(cronJobName, cronString, scheduler);
            }
            return true;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return false;
        }
    }


}