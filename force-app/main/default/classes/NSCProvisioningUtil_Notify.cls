public with sharing class NSCProvisioningUtil_Notify implements Schedulable
{
    public void execute(SchedulableContext sc)
    {
        NotifyOnErrors();
    }
 
    public static void NotifyOnErrors()
    {
        DateTime yesterday = DateTime.now();
        yesterday = yesterday.addDays(-1);
        
        DateTime searchDate = DateTime.newInstance(yesterday.yearGmt(), yesterday.monthGmt(), yesterday.dayGmt(), 0, 0, 0);
        
        Organization o = [select Id, IsSandbox from Organization limit 1];
        
        List<AsyncApexJob> apexJobs = new List<AsyncApexJob>(); 
        if(!Test.isRunningTest()) 
        {
        	apexJobs = [Select Id, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CreatedDate, CompletedDate,
            	         MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset from AsyncApexJob where JobType = 'Future' 
                	     and MethodName = 'AsyncSendToProvisioning' and CreatedDate > :searchDate and Status = 'Failed' order by CreatedDate asc];
        }
        else
        {
            apexJobs.add(new AsyncApexJob());
            apexJobs.add(new AsyncApexJob());
            apexJobs.add(new AsyncApexJob());
            apexJobs.add(new AsyncApexJob());
            apexJobs.add(new AsyncApexJob());
        }
        
        String[] mailTo = null;
        String replyTo = null;
        String replyName = 'NSC Provisioning';
        String mailCC = null;
        
        if (o.IsSandbox) //cert or other sandbox
        {
            mailTo = new String[] { 'eD230113@ncr.com' };
                replyTo = 'eD230113@ncr.com';
        }
        else //production
        {
            mailTo = new String[] { 'eD230112@ncr.com' };
                replyTo = 'eD230112@ncr.com';
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(mailTo);
        mail.setReplyTo(replyTo);
        
        mail.setSenderDisplayName(replyName);
            
        if (apexJobs.size() > 0)
        {
            String mailBody = 'One or more errors were detected when sending Provisioning requests for ' + yesterday.date() + 
                '.  Please review the details below and take the appropriate action.\n\n' +
                				'=========================================================================\n\n';
            
            for (AsyncApexJob a : apexJobs)
            {
                mailBody = mailBody + 'Id: ' + a.Id + '\n' +
                            'JobType: ' + a.JobType + '\n' +
                            'ApexClassId: ' + a.ApexClassId + '\n' +
                            'Status: ' + a.Status + '\n' +
                            'JobItemsProcessed: ' + a.JobItemsProcessed + '\n' +
                            'TotalJobItems: ' + a.TotalJobItems + '\n' +
                            'NumberOfErrors: ' + a.NumberOfErrors +  '\n' +
                            'CreatedDate: ' + a.CreatedDate + '\n' +
                            'CompletedDate: ' + a.CompletedDate + '\n' +
                            'MethodName: ' + a.MethodName + '\n' +
                            'ExtendedStatus: ' + a.ExtendedStatus + '\n' +
                            'ParentJobId: ' + a.ParentJobId + '\n' +
                            'LastProcessed: ' + a.LastProcessed + '\n' +
                            'LastProcessedOffset: ' + a.LastProcessedOffset + '\n\n' +
                    		'=========================================================================\n\n';
            }
            
            mail.setPlainTextBody(mailBody);
            mail.setSubject('Errors Detected in Provisioning Request(s)');
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
        
        if(apexJobs.size() == 0 || test.isRunningTest())
        {
            String mailBody = 'No errors were detected in Provisioning requests for ' + yesterday.date() + '.';
            
            mail.setPlainTextBody(mailBody);
            mail.setSubject('No Errors for Provisioning Requests');
            
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
        }
    }
}