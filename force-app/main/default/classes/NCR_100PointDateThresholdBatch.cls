public class NCR_100PointDateThresholdBatch implements Database.Batchable<sObject>, schedulable{

    String query;

    public Database.querylocator start(Database.BatchableContext BC){
        integer total = 100;
        query = 'SELECT date__c, Status,VoteScore,VoteTotal FROM Idea Where VoteTotal >= :total';
        if(Test.isRunningTest()){
            query  += ' LIMIT 10';
        }
        system.debug('rquery ---- '+database.query(query));
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<idea> scope){
        system.debug('in execute-----');
        list<idea> upDateIdea = new list<idea>();
        for(idea ide : scope){
            system.debug('VoteTotal-----'+ide.VoteTotal);
            if(ide.VoteTotal >= 100 &&(ide.date__c == NULL)){
                ide.date__c = system.today();
                upDateIdea.add(ide);
            }
            
        }
        update upDateIdea;
        system.debug('upDateIdea : '+upDateIdea);
        
        
    }
    
    public void finish(Database.BatchableContext BC){
        // start keepalive again in 5 mins
           // Datetime sysTime = System.now().addSeconds( 300 );      
           // String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
            //System.schedule( 'SelfSchedule ' + sysTime, chronExpression, new NCR_100PointDateThresholdBatch() );
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :bc.getJobId()];
        System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));    
    }
    
    public void execute(SchedulableContext ctx) {
        NCR_100PointDateThresholdBatch obj = new NCR_100PointDateThresholdBatch();
        database.executeBatch(obj);
    }  


}