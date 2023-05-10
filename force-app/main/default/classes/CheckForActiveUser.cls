public class CheckForActiveUser {
    
        @InvocableMethod(label='Flow Invocable Method' description='This will filter out the list of User if include any incative user then will sent out only active users')
        public static List<List<User>>  FilterActiveUsers(List<String> CaddRecordId){
            
            List<List<User>> ListOfActiveUsers;
            if(String.isNotBlank(CaddRecordId[0])){ 
               ListOfActiveUsers = new List<List<User>>(); 
               Set<String> UserIdSet =  new Set<String>(); 
                for(Deming__c DemObj : [Select id,EditShareWithUser__c,ReadShareWithUser__c,EditShareWithUserSpFound__c from  deming__c where id =:CaddRecordId[0]]){
                    
                    if(String.isNotBlank(DemObj.EditShareWithUser__c)){
                        UserIdSet.add(DemObj.EditShareWithUser__c);
                    }
                    if(String.isNotBlank(DemObj.ReadShareWithUser__c)){
                        UserIdSet.add(DemObj.ReadShareWithUser__c);
                    }
                    if(String.isNotBlank(DemObj.EditShareWithUserSpFound__c)){
                        UserIdSet.add(DemObj.EditShareWithUserSpFound__c);
                    }
                } 
                List<User> UserObjs = new List<User>();
                if(UserIdSet !=null && UserIdSet.size() >0 ){
                    
                    for(User userObj : [Select id,isActive from User where Id IN : UserIdSet and isActive = true]){
                        UserObjs.add(userObj); 
                    }
                }
                if(UserObjs.Size()>0){
                    ListOfActiveUsers.add(UserObjs);
                }
                
            }
               System.debug('<><><><><>'+ListOfActiveUsers);    
               return ListOfActiveUsers; 
        }
}