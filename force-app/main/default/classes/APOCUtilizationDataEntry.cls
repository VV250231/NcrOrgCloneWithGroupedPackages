global class APOCUtilizationDataEntry implements Database.Batchable<sObject>,Database.stateful
{
    public Integer totalAmtOfRecords = 0; 
    public Integer loginCount = 0;
    public Integer ReassignCount = 0;
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT ID FROM USER WHERE Isactive=true and IsBPMUser__c=true'+(Test.isRunningTest()?' LIMIT 200':'');
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        Set<Id> loginUserIdSet = new Set<Id>();
        List<ReassignDataHistory__c> reassignUserIdSet = new List<ReassignDataHistory__c>();
        for(LoginHistory his :[SELECT Id,UserId FROM LoginHistory where logintime = Yesterday and userid in:scope]){
            loginUserIdSet.add(his.UserId);
        }
        for(ReassignDataHistory__c his :[SELECT Id FROM ReassignDataHistory__c where createddate = Yesterday and createdbyid in:scope]){
            reassignUserIdSet.add(his);
        }
        totalAmtOfRecords += scope.size();
        System.debug('totalAmtOfRecords'+totalAmtOfRecords);
        loginCount += loginUserIdSet.size();
        ReassignCount += reassignUserIdSet.size();
        
    }  
    global void finish(Database.BatchableContext BC)
    {
        APOC_Utilization__c newRec = new APOC_Utilization__c(Number_Of_Users__c=totalAmtOfRecords,Daily_Login_Count__c=loginCount,Daily_Reassignment_Count__c=ReassignCount,Data_Captured_On__c=System.today()-1);
        insert newRec;
    }
}