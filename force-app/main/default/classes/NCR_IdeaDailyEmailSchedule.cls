global class NCR_IdeaDailyEmailSchedule implements Schedulable {
    global void execute(SchedulableContext SC) {
        NCR_IdeaDailyEmailBatch batchInstance = new NCR_IdeaDailyEmailBatch();
		Database.executeBatch(batchInstance);
    }
}