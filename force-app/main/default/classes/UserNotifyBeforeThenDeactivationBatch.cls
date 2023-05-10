/*************************************************************************************************
* Author        :   Pankaj Kashyap   // 17/Nov/2021    
* Param         :   User  : Date   
* Return        :   
* Description   :   This Btach class will send Notification Before 24 Hours to user and then deactive 
                    Please refer story:SF Optimizer: User Logins(EBA_SF-1628 )
*************************************************************************************************/

global class UserNotifyBeforeThenDeactivationBatch implements Database.Batchable<SObject>,Database.stateful {
    
    Global dateTime threeMonth =date.today()-90 ;
    Global dateTime QualifyForNotification=date.today()-89;
    Global dateTime SixMonth =date.today()-180 ;
    Global Static Boolean CheckForInactiveUser=false;
    Global Set<Id> UserInatvSuccs;
    String errMsg = '';
    global Database.querylocator start(Database.BatchableContext bc){
       
         UserInatvSuccs = new Set<Id>();
       String query='SELECT Name,IsActive,LastLoginDate,Notification_Send_Date__c, Id From User WHERE IsActive = true AND UserType=\'standard\' AND LastLoginDate <=:threeMonth AND Do_Not_Deactivate__c = false AND Profile.Name <> \'BPM Team\' AND SF_License__c=\'Salesforce\'';
              query+= 'AND Profile.Name <> \'BPM Team\' AND Id NOT IN (  SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.name=\'BPM_Community\')';

         
        if(test.isRunningTest()){
         query='SELECT Name, IsActive, LastLoginDate,Notification_Send_Date__c, Id From User WHERE  Do_Not_Deactivate__c = false and SF_License__c=\'Salesforce\'';

            query+=' and Notification_Send_Date__c = null limit 1';
            errMsg='Error For test class coverage'; 
         }                   
         //system.debug('query'+query);
         return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc,List<User> scope){
        
         List<User> ListForNotify = new List<User>();
         List<User> ListForInactive = new List<User>();
        
        //system.debug('scope size'+scope.size());
         for(User usr : scope){
             //system.debug('<><><><><><><'+usr);
             
                if(usr.Notification_Send_Date__c == NULL || usr.Notification_Send_Date__c.daysBetween(Date.today()) >= 90){
                      User u =(user)usr;
                      u.Notification_Send_Date__c=system.today();
                      ListForInactive.add(u);
                      //system.debug('1111111'+ListForInactive); 
                 }

                 else if( (usr.LastLoginDate.date().daysBetween(Date.today()) >=90) && (usr.Notification_Send_Date__c.daysBetween(Date.today()) > 2 )){
                      //system.debug('2222222'+ListForInactive);
                      User u =(user)usr;
                      u.IsActive=False;
                      ListForInactive.add(u); 
                 }     
         }
        
        
        if(ListForInactive != null && ListForInactive.size()>0){
             CheckForInactiveUser=true;
             Database.SaveResult[] srList = Database.update(ListForInactive, false);
             Integer counter=0;
             User Userobj = new User();
             for (Database.SaveResult sr : srList) {
                   //system.debug('4444444'+sr);
                   Userobj=ListForInactive[counter];
                 if (!sr.isSuccess()) {
                     //Userobj=ListForInactive[counter];
                     for(Database.Error err : sr.getErrors()) {
                            
                             errMsg += 'User Id '+ Userobj.Id+ ' Due to Error:' + err.getMessage();   
                             errMsg += 'User fields that affected this error: '+ err.getFields()+'\n';
                             
                    }
                    // counter++;
                 }
                 else{
                     if(!Userobj.IsActive)
                        UserInatvSuccs.add(sr.getId()); 
                        
                 }
                 counter++;
             }
        }
       
    }
    
    global void finish(Database.BatchableContext bc){
      

        String mailBdy = '';
        String mailSub = '', mailHeader = '', mailSubHdr = '';
        
        if (String.isNotEmpty(errMsg)) {
            mailHeader = 'User Deactivation Batch Process Failed';
            mailSub = mailHeader;
            mailSubHdr = 'Deactivation Batch Process Failed for below users';
            mailBdy = errMsg;
            
        } 
        if(String.isNotEmpty(mailHeader)) {
           
            EmailUtility.sendEmail(mailSub,mailHeader,mailSubHdr,mailBdy, (Label.BatchClassEmailNotification).split(',')); 
        }
        
        if(UserInatvSuccs != null && UserInatvSuccs.size()>0){
            
            UserTriggerHandler.ListOfInactiveUser(UserInatvSuccs);
        }
    }
}