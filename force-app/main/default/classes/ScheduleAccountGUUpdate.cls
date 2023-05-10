public class ScheduleAccountGUUpdate implements Schedulable  {
	public void execute (SchedulableContext sc) {   
       UpdateAccountGlobalUltimate guUpdate = new UpdateAccountGlobalUltimate(sc.getTriggerId());
       guUpdate.processRelation();                    
    }
}