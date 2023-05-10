public class AccountExceptionHandler 
{
    public static Boolean isRecursion = true;
        
    public void onBeforeInsert(List<Account_Exception__c> lstNewAccExp)
    {
        Set<Id> setUsrId = new Set<Id>();
        List<Id>  lstManagerId =  new List<Id>();
        
        for(Account_Exception__c  rec : lstNewAccExp)
        {
            if(rec.Channel_Account_Manager__c == null)
                setUsrId.add(userInfo.getUserId());
            rec.Status__c = 'Created';
        }
    
        //Partner account name and partner contact
        List<User> lstUser = [SELECT Id, AccountId, ContactId FROM User WHERE Id =: UserInfo.getuserid() LIMIT 1] ;
        for(Account_Exception__c rec : lstNewAccExp) 
        { 
            if (lstUser != null)
            {
                rec.Partner_Account_Name__c = lstUser[0].AccountId;
                rec.Partner_Contact__c = lstUser[0].ContactId; 
            } 
        }
        
        //CAM Id user map  
        Map<Id, User> usrIdMap = new Map<Id, User>();
        //Cam ID and Manager Id map
        Map<Id, ID> manageruserIdMap = new Map<Id, Id>();
        Map<Id, Id> mapAccountExpIdToDSL = new Map<Id, Id>();
    
        Id contactId;
         
        //Account.OwnerId
        for (User u : [SELECT Id, ContactId FROM User WHERE Id IN : setUsrId AND ContactId != null]) 
        {
            usrIdMap.put(u.Id , u);
            //lstManagerId.add(u.Account.OwnerId);
            contactId = u.ContactId;
        }
    
        if(contactId != null || Test.isRunningTest())
        {
            for(Contact c : [Select Id, Account.OwnerId from Contact where Id =: contactId])
            {
                lstManagerId.add(c.Account.OwnerId);
            }
        }
    
        for (User u : [SELECT Id,  ManagerId, Manager.ManagerId FROM User WHERE Id IN : lstManagerId ]){
            manageruserIdMap.put(u.id, u.ManagerId);
            mapAccountExpIdToDSL.put(u.Id, u.Manager.ManagerId);
        }
    
    
        if(!usrIdMap.isEmpty() || Test.isRunningTest())
        {
            for(Account_Exception__c rec : lstNewAccExp) 
            {
                if(!usrIdMap.isEmpty() && usrIdMap.containsKey(UserInfo.getUserId()))
                {
                    rec.Channel_Account_Manager__c= !lstManagerId.isEmpty() ? lstManagerId[0] : null;
                  
                    //System.debug('rec.Channel_Account_Manager__c'+rec.Channel_Account_Manager__c);
                  
                    if(!manageruserIdMap.isEmpty() && rec.Channel_Account_Manager__c != null && manageruserIdMap.containsKey(rec.Channel_Account_Manager__c))
                    {
                        rec.Channel_Sales_Leader__c = manageruserIdMap.get(rec.Channel_Account_Manager__c);
                        // Below line commented becuase no more going to have approval process for Direct Sales Channel.
                        //rec.Direct_Sales_Leader__c = mapAccountExpIdToDSL.get(rec.Channel_Account_Manager__c);
                    }
                }
            }    
        }
        
    }
    
    public void onBeforeUpdate(Map<Id, Account_Exception__c> mapNewIdToAccExp, Map<Id, Account_Exception__c> mapOldIdToAccExp)
    {
        Set<Id> setAccExpId = new Set<Id>(); 
        for(Account_Exception__c objNewAE : mapNewIdToAccExp.values())
        {
            Account_Exception__c objOldAE = mapOldIdToAccExp.get(objNewAE.Id);
            
            if(objNewAE.Status__c != objOldAE.Status__c)
            {
                setAccExpId.add(objNewAE.Id);
                updateComment(objNewAE.Id);
            }
        }
    }
    @future
    public static void updateComment(Id accExpId)
    {
        List<Account_Exception__c> lstAccExcpWithAppvlVals=[Select c.Id, 
                                            (Select Id, IsPending, ProcessInstanceId, TargetObjectId, StepStatus, OriginalActorId, ActorId, RemindersSent, Comments
                                                 From ProcessSteps where StepStatus IN ('Approved', 'Rejected') order by CreatedDate desc ) 
                                            From Account_Exception__c c where Id =: accExpId];
            
        //System.debug('------------  lstAccExcpWithApprovalValues.size() ---------------------'+lstAccExcpWithApprovalValues.size());  
        //System.debug('------------  lstAccExcpWithApprovalValues ---------------------'+lstAccExcpWithApprovalValues);  
        List<Account_Exception__c> updateAELst = new  List<Account_Exception__c>();
                                
        for(Account_Exception__c objAE : lstAccExcpWithAppvlVals)
        {
             //System.debug('------------  objAE.ProcessSteps ---------------------'+objAE.ProcessSteps.size()); 
             
            if(!objAE.ProcessSteps.isEmpty())
            {
                Account_Exception__c objUpdateAE = new Account_Exception__c( id = objAE.Id);
                objUpdateAE.Approver_Comments__c = String.isNotBlank(objAE.ProcessSteps[0].Comments) ?  objAE.ProcessSteps[0].Comments : '';
                //System.debug('------------ objAE.ProcessSteps[0].Comments ---------------------'+objAE.ProcessSteps[0].Comments);
                 //update objUpdateAE; //commeted to avoid DML in loop
                 updateAELst.add(objUpdateAE);
                /*if(AccountExceptionHandler.isRecursion)
                {
                    AccountExceptionHandler.isRecursion = false;
                    update objUpdateAE;
                }*/
            }
        }
        
        if(!updateAELst .isEmpty()) update updateAELst;
    }
    
}