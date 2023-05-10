global class SearchAndUpdateStatus implements Database.Batchable<sObject>{
   global final String Query='select id,Status,ismerged from idea where Status!=\'Merged\' AND ismerged=true';

   global Database.QueryLocator start(Database.BatchableContext BC){

      return Database.getQueryLocator(query);

   }


   global void execute(Database.BatchableContext BC, List<sObject> scope){
    List<Idea> IdeasToUpdate = new List<Idea>();
        for(idea s :(List<Idea>) scope){
            s.Status='Merged';
            IdeasToUpdate.add(s);
        }
     
        if(!IdeasToUpdate.isEmpty()) {
            update IdeasToUpdate; //updating idea status 
        }
    }

 

   global void finish(Database.BatchableContext BC){
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
       System.debug(String.format(System.Label.BatchFinishLabel, new List<String>{String.valueOf(a.JobItemsProcessed),String.valueOf(a.NumberOfErrors), String.valueOf(a.TotalJobItems)}));
   }

}