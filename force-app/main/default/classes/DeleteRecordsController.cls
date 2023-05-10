public class DeleteRecordsController {

    public class DataWrapper
    {
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public String condition;
        @AuraEnabled
        public String NoOfDays;
        @AuraEnabled
        public Integer batchSize;
        @AuraEnabled
        public String recordLimit;
        @AuraEnabled
        public Boolean systemLevel;
        @AuraEnabled
        public Boolean deleteUnshared;
        @AuraEnabled
        public Boolean partialDelete;
        @AuraEnabled
        public Boolean isSchedule;
    }
    
    @AuraEnabled
    public static String executeDeletion(String userInput, String cronExp)
    {
        try
        {
            DataWrapper dataWrapper=(DataWrapper)JSON.deserialize(userInput,DataWrapper.class);
            BatchUtil bat=new BatchUtil();
            bat.setObject(dataWrapper.objectName);
            bat.setIsSchedule(dataWrapper.isSchedule);
            bat.setcondition(dataWrapper.condition);
            bat.setNoOfDays(dataWrapper.condition);
            bat.setBatchSize(dataWrapper.batchSize);
            bat.setLimit(dataWrapper.recordLimit);
            bat.runAtSystemLevel(dataWrapper.systemLevel);
            bat.setAllOrNone(!dataWrapper.partialDelete);
            bat.setWithSharing(!dataWrapper.deleteUnshared); 
            bat.setCronExp(cronExp);
            bat.executeBatch(); return 'SUCCESS';
        }catch(Exception e)
        {
            return e.getMessage();
        }
    }
}