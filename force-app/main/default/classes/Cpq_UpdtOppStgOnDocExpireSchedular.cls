Global class Cpq_UpdtOppStgOnDocExpireSchedular implements Schedulable {
    global void execute(SchedulableContext sc){

        // added by dharmendra SFCPQBLG-959
        CPQQuoteExpiringJob qc = new CPQQuoteExpiringJob();
        database.executebatch(qc,5);
      
    }
    
   /* {
        Cpq_UpdtOppStgOnDocExpireSchedular batch = new Cpq_UpdtOppStgOnDocExpireSchedular();
        string jobName = 'Cpq_UpdtOppStgOnDocExpire';
        //String cron = '0 0 10 ? * *';
String cron = '0 0 10 * * ?';
        system.schedule(jobName, cron, batch);
    }*/
}