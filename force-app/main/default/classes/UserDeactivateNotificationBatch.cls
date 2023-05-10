public class UserDeactivateNotificationBatch implements Database.Batchable<ASM_Role_Hierarchy__c>,Iterable<ASM_Role_Hierarchy__c>,Iterator<ASM_Role_Hierarchy__c> {
    public Map<Id,NCR_Employee_Detail__c> usrM = new Map<Id,NCR_Employee_Detail__c>();
    public Map<Id,List<UserDeactivateNotification.Wrap>> usrWrapM = new Map<Id,List<UserDeactivateNotification.Wrap>>();
    public Set<Id> uidSet;
    public List<ASM_Role_Hierarchy__C> roles;
    Integer counter = 0, max;
    public UserDeactivateNotificationBatch(List<ASM_Role_Hierarchy__C> roles){
        this.roles = roles;
        this.max = roles.size();
    } 
    public ASM_Role_Hierarchy__c next() {
        return roles[counter++];
    }
    public Boolean hasNext() {
        return counter < max;
    }
    public Iterator<ASM_Role_Hierarchy__c> iterator() {
        return this;
    }
    public Iterable<ASM_Role_Hierarchy__c> start(Database.BatchableContext BC){
        return this;
    }
    public void execute(Database.BatchableContext BC, List<ASM_Role_Hierarchy__c> APOCL){
        if(!APOCL.isEmpty()){
            APOC_MassUpdateAllRolesHandler.stopNotification = true;
            UserDeactivateNotification.UpdtRole(APOCL);
        }
    }
    public void finish(Database.BatchableContext BC){
        System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   

    }
}