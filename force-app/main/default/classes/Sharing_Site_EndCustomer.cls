global with sharing class Sharing_Site_EndCustomer implements Database.Batchable<sObject>
{
    Map <id, Set<id>> prtnr_ECSiteMap =new Map <id, Set<id>>();
    List<User> userListwithCpqPermission = new List<User>();
    Set < Id > ecIds = new Set < Id > ();
    Set < String > prtnrOwndMcn=new Set<string>();
    Map<String,id> prtnrOwndMcnIdMap=new Map<string, id>();
    List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();    
    global Sharing_Site_EndCustomer(){}
    global Sharing_Site_EndCustomer(Map <id, Set<id>> prtnr_ECSiteMap, List<User> userListwithCpqPermission, Set < Id > ecIds,Set < String > prtnrOwndMcn)
    {
        this.prtnr_ECSiteMap=prtnr_ECSiteMap;
        this.userListwithCpqPermission= userListwithCpqPermission;
        this.ecIds = ecIds;
        this.prtnrOwndMcn=prtnrOwndMcn;  
        //Create MCN-ID map for prtnrOwndMcn
        prtnrOwndMcnIdMap=getPO_MCN_ID_MAP(prtnrOwndMcn);
        //in case there has been no EC then still we have to add PArtnerOwned MCN and Account Ids
        for(String s:prtnrOwndMcnIdMap.keySet()){
            Id accId=prtnrOwndMcnIdMap.get(s);
            if(accid!=null && !prtnr_ECSiteMap.keySet().contains(accId)){
                prtnr_ECSiteMap.put(accId,new Set<id>{});
            }
        }
    }    
    global Database.QueryLocator start(Database.BatchableContext bc)    {
        //Returning sites related to Parent Partner Accs or End Customers
        return Database.getQueryLocator([Select id, ParentId, Parent.Master_Customer_Number__c from Account where (ParentId in :ecIds or ParentId in:prtnr_ECSiteMap.keySet()) and RecordType.Name =:Label.RT_Acc_Site and Active_Account__c=true]);
    }    
    global void execute(Database.BatchableContext BC,List<Account> scope) 
    {
        for(Account a:scope){//all sites of partner and related EC           
            if(a.parentId!=null){
                if(prtnr_ECSiteMap.keySet().contains(a.parentId)){//site belongs to partner or Partner Owned Account
                    prtnr_ECSiteMap.get(a.parentId).add(a.id);//site added to partners ec list
                }else{//site may belong to End custs
                    for(Id prtnr:prtnr_ECSiteMap.keySet()) {// iterating map
                        Set<id> ecs=prtnr_ECSiteMap.get(prtnr);//get all values of endcustomers
                        if(ecs.contains(a.parentId)){
                            ecs.add(a.id);//ec site added to end customer set for that partner
                        }
                    }
                }  
            } 
        }// FM-EC1,Ec2,S1, I3-Ec1-s1
        //Create MCN-ID map for prtnrOwndMcn
        Map<String,id> prtnrOwndMcnIdMap=getPO_MCN_ID_MAP(prtnrOwndMcn);
        
        for(User upl : userListwithCpqPermission)
        { 
            //users Partner Owned Account
            Set<Id> usrPOAIDSet=getPOAIdSet(upl,prtnrOwndMcnIdMap);
            for(Id prtnr:prtnr_ECSiteMap.keySet()) {  
                //TODO remove break as we have to also add Account Team basd on Partner Owned Account field
                if (upl.AccountId==prtnr || usrPOAIDSet.contains(prtnr)){
                    //Create team Member for Partner Acc, Partner Acc, site and their related End customer and Sites
                    accountTeamMemberList.addAll(createTeamMmbr(prtnr_ECSiteMap.get(prtnr), upl.id)) ;
                    if(usrPOAIDSet.size()==0)
                        break;
                }
            }
            // add Partner and Partner Owned Account and create its team members
            usrPOAIDSet.add(upl.AccountId);
            accountTeamMemberList.addAll(createTeamMmbr(usrPOAIDSet, upl.id)) ;           
        }  
        //To Do Compare existing AccountTeamMember to delete extra account teammembers due to Partner Owned account Field changes
        if (accountTeamMemberList.size() > 0)
        {            
            insert accountTeamMemberList;
        }        
    }
    
    public List<AccountTeamMember> createTeamMmbr(Set<id> ids, id usrId){
        List<AccountTeamMember> atmL=new List<AccountTeamMember>();
        for(Id accId:ids){
            if(accId!=null){
                AccountTeamMember Teammemberad=new AccountTeamMember();
                Teammemberad.AccountId=AccId;
                Teammemberad.UserId=usrId ;
                Teammemberad.TeamMemberRole = Label.ATM_Role_CP;
                Teammemberad.AccountAccessLevel = 'Edit'; 
                atmL.add(Teammemberad);   
            }            
        }        
        return atmL;
    }
    public Map<String,id> getPO_MCN_ID_MAP(Set < String > prtnrOwndMcn){
        Map<String,id> prtnrOwndMcnIdMap=new Map<String,id>();
        for(Account a:[Select id, Master_Customer_Number__c from Account where Master_Customer_Number__c in :prtnrOwndMcn]){
            prtnrOwndMcnIdMap.put(a.Master_Customer_Number__c,a.id);           
        }
        return prtnrOwndMcnIdMap;
    }
    global Set<ID> getPOAIdSet(User u, Map<String,id>prtnrOwndMcnIdMap){
        Set<id> usrPOAIDSet=new Set<id>();
        Set<String> usrPOA=new Set<String>(); 
        if(!String.isEmpty(u.Partner_Owned_Accounts__c)){
            usrPOA.addAll(u.Partner_Owned_Accounts__c.replaceAll( '\\s+', '').split(','));
            for(String s:usrPOA){
                usrPOAIDSet.add(prtnrOwndMcnIdMap.get(s));
            }   
        }
        
        return usrPOAIDSet;
    }
    global void finish(Database.BatchableContext BC) 
    {         
    }
}