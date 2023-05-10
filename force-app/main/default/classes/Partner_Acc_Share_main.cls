/**
* Class is used to clean Account Team Member and Re-Share by calling another if needed
*
* @author  Ajay Dixit
* @Data   2021-04-16
*/
global class Partner_Acc_Share_main implements Database.Batchable<sObject>,Database.Stateful {
    Map <id, Set<id>> prtnr_ECSiteMap =new Map <id, Set<id>>();
    List<User> cpqUsrL = new List<User>();
    Set < Id > ecIds = new Set < Id > ();
    Set < String > prtnrOwndMcn=new Set<string>();
    Boolean isDelete=false;
    global Partner_Acc_Share_main(Map <id, Set<id>> prtnr_ECSiteMap, List<User> cpqUsrL, Set < Id > ecIds,Set < String > prtnrOwndMcn, Boolean isDelete)
    {
        this.prtnr_ECSiteMap=prtnr_ECSiteMap;
        this.cpqUsrL= cpqUsrL;
        this.ecIds = ecIds;
        this.isDelete = isDelete; 
        this.prtnrOwndMcn=prtnrOwndMcn;
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc)     {
        //Returning sites related to Parent Partner Accs or End Customers
        Set<id> usrIds=new Set<Id>();
        for(User u:cpqUsrL){
            usrIds.add(u.id);
        }
        return Database.getQueryLocator([Select id from AccountTeamMember where UserId in :usrIds and TeamMemberRole=:Label.ATM_Role_CP]);
        
    }    
    global void execute(Database.BatchableContext BC,List<AccountTeamMember> scope) 
    {
        List<AccountTeamMember> atmL=new List<AccountTeamMember>();
        for(AccountTeamMember a:scope){//all sites of partner and related EC           
            atmL.add(a);
        }
        Delete atmL;
    }    
       
    global void finish(Database.BatchableContext BC) 
    {  
        if(isDelete==false){
            database.executeBatch(new Sharing_Site_EndCustomer(prtnr_ECSiteMap,cpqUsrL,ecIds,prtnrOwndMcn)); // Calling batch class.
        }
        
    }

}