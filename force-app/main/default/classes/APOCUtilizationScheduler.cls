global class APOCUtilizationScheduler implements schedulable
{
    global void execute(SchedulableContext sc)
    {
    	APOCUtilizationDataEntry b = new APOCUtilizationDataEntry();
      	database.executebatch(b);
    }
}