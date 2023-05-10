public class AccountRelationshipHandler implements Queueable
{
    Private Map<id,List<id>> relPrtnrECMap;
    Private Boolean isDelete=false;
    public AccountRelationshipHandler(Map<id,List<id>> relPrtnrECMap, Boolean isDelete) {
        this.relPrtnrECMap = relPrtnrECMap;
        this.isDelete=isDelete;
    }
    public void execute(QueueableContext context) {       
        Set<id> relatedPrtnerECWithCPQUser=new Set<id>(); // This var will hold actual endcustomer to be shared after validating if users exist and will be used for identifying sites
        Set<id> finalSharedAccAndSiteIds=new Set<id>();
        Set<id> finalPartnerUserIds=new Set<id>();
        Map<id,Set<id>> relPrtnrECMapFinal=new Map<id,Set<id>>();
        List <User> cpqPrtnrUsrL = [SELECT id,AccountId,Partner_Owned_Accounts__c, UserType,ContactId,Username FROM User WHERE CPQ_Pilot__c=true and AccountId !=null and isActive=True];
        Set < String > prtnrOwndMcn = new Set < String > (); 
        for(User u : cpqPrtnrUsrL)
        {
            if(u.Partner_Owned_Accounts__c!=null)
            prtnrOwndMcn.addAll((u.Partner_Owned_Accounts__c.replaceAll( '\\s+', '')).split(','));
        }
        Sharing_Site_EndCustomer sse=new Sharing_Site_EndCustomer();
        Map<String,id> prtnrOwndMcnIdMap=sse.getPO_MCN_ID_MAP(prtnrOwndMcn);
        List<AccountTeamMember> atmL = new List<AccountTeamMember>();
        //Filter relPrtnrECMap to create new map only when related Partner user is present
        if(!cpqPrtnrUsrL.isEmpty()){
            for(User u : cpqPrtnrUsrL)
            {
                Set<Id> usrPOAIDSet=sse.getPOAIdSet(u, prtnrOwndMcnIdMap);                
                for(Id i:relPrtnrECMap.keySet()){
                    if(i==u.AccountId || usrPOAIDSet.contains(i) ) {
                        relatedPrtnerECWithCPQUser.addAll(relPrtnrECMap.get(i));//Ec1,Ec2
                        Set<id> relatedEC=relPrtnrECMapFinal.get(i);
                        if(relatedEC!=null){
                            relatedEC.addAll(relPrtnrECMap.get(i));
                        }else{
                            relPrtnrECMapFinal.put(i,new Set<id>(relPrtnrECMap.get(i)));//FM,EC1-EC2|I3-EC1
                        }    
                    }
                }        
                
            }
            //Getting All EC Account and their Sites
            List<Account> sharedAccAndSite=[Select id, ParentID from Account where id in: relatedPrtnerECWithCPQUser OR ParentId in :relatedPrtnerECWithCPQUser];//Ec1,EC2,S1-S4        if(!contactlistwithCpqPermission.isEmpty()){
            for(Id prtnrId:relPrtnrECMapFinal.keySet())  {//fm,i3
                for(Account ec : sharedAccAndSite)//ec1,ec2, ec1s1, ec2s2, ec1s3
                {                    
                    for(User u : cpqPrtnrUsrL)//fmc1,i3c
                    { 
                        Set<Id> usrPOAIDSet=sse.getPOAIdSet(u, prtnrOwndMcnIdMap);
                        if ((u.AccountId==prtnrId || usrPOAIDSet.contains(prtnrId)) && (relPrtnrECMapFinal.get(prtnrId).contains(ec.id) ||(ec.ParentID!=null && relPrtnrECMapFinal.get(prtnrId).contains(ec.ParentID))))
                        {    
                            atmL.addAll(sse.createTeamMmbr(new Set<id>{ec.id}, u.id));
                            finalPartnerUserIds.add(u.id);
                            finalSharedAccAndSiteIds.add(ec.id);
                        }
                    }
                }
            }
            if (!atmL.isEmpty())
            {
                if(isDelete){
                   deleteTeamMembers(atmL, finalSharedAccAndSiteIds,finalPartnerUserIds );
                }else{
                    insert atmL;   
                }
            }
        } 
    } 
     public void deleteTeamMembers(List<AccountTeamMember> atmToBeDeleted, Set<Id> sharedAccAndSiteId, Set <id> partnerUserIds)
    {
        List <AccountTeamMember> tobeDeleted=new List<AccountTeamMember>();        
        List <AccountTeamMember> petentialATMDeletion=[Select id, AccountID, UserID from AccountTeamMember where AccountId in:sharedAccAndSiteId and UserID in :partnerUserIds and TeamMemberRole =:Label.ATM_Role_CP];
        for(AccountTeamMember atm:petentialATMDeletion){
            for(AccountTeamMember patm:atmToBeDeleted){
                if(patm.UserId==atm.userId && patm.AccountId==atm.AccountID){
                    tobeDeleted.add(atm) ;
                    break;
                }
            }
        }
        System.debug('tobeDeleted');
        if(tobeDeleted.size()>0)
            Delete tobeDeleted;
    }
}