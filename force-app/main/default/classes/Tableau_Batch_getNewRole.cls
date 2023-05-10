global class Tableau_Batch_getNewRole implements Database.Batchable<sobject>,Database.Stateful {
    
    global string m_tp = 'sk250817@ncr.com' ;
    global string m_sub = 'Tableau Scripter  : Step 1 started ';
    global string m_body;
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String Query = 'Select id from UserRole '+ (Test.isRunningTest() ?' LIMIT 1':'');
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext bc,List<UserRole> UserRole_List){
        
        List<TableauSubRoleIDs__c> subRole_List = new List<TableauSubRoleIDs__c>();
        List<Tableau__c> userSet_List = new List<Tableau__c>();
        Set<id> roleIdSet = new Set<id>();
        Set<id> subRole_set= new Set<id>();
        Set<id> userSet_set= new Set<id>();
        
        for(TableauSubRoleIDs__c ts : [select id,RoleID__c from TableauSubRoleIDs__c] ){
            subRole_set.add(ts.RoleID__c);
        }
        
        for(Tableau__c ts : [select id,RoleID__c from Tableau__c] ){
            UserSet_set.add(ts.RoleID__c);
        }
        
        for(UserRole ur : UserRole_List){
            roleIdSet.add(ur.id);
        }
        
        for(id d : roleIdSet){
            if(!subRole_set.contains(d)){
                TableauSubRoleIDs__c st = new TableauSubRoleIDs__c();
                st.RoleID__c = d ;
                subRole_List.add(st);
            }
            if(!userSet_set.contains(d)){
                Tableau__c ut = new Tableau__c();
                ut.RoleID__c = d ; 
                userSet_List.add(ut);
            }
        }
        m_body = 'Total records inserted in Tableau SubRole ID  : '+subRole_List.size() + 
            '<br> </br>  Total records inserted in Tableau User Set : '+userSet_List.size()+
            '<br> </br> Date Time Executed : '+ Date.today() ;
        
        try{
            if(subRole_List.size()>0){
                insert subRole_List;
                
            }
            if(userSet_List.size()>0){
                insert userSet_List;
            }
        }
        catch(exception e){
            m_body =m_body + '<br> </br> if any, exceptions :: '+e; 
        }
        
    }
    
    global void finish(Database.BatchableContext bc){
        if(!test.isRunningTest())
            Tableau_Scheduler.sendemail(m_tp,m_sub,m_body,2);
    }
    
}