global class ScheduleDelete_PMDM_RequestLog implements Schedulable{
    
   global void execute(System.SchedulableContext sc){
       Delete_PMDM_RequestLog DeleteLogObj =  new Delete_PMDM_RequestLog();
       database.ExecuteBatch(DeleteLogObj);
   }
}