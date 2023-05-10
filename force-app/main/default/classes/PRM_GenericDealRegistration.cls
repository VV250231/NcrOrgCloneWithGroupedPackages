/*
 * ClassName: PRM_GenericDealRegistration
 * Description: This class having all generic methods.
 * DeveloperName:Deeksharth Sriwastava
 * Date:24/09/19
*/
public class PRM_GenericDealRegistration {
    
	//This method return Territory Account Manager(TAM)for deal registration sprint 13,2019
    public static Map<Id,String> getTAMDetails(String actId){
        List<AccountTeamMember> actTeamMem = New List<AccountteamMember>();
        Map<Id,String> getTAMMap = new Map<Id,String>();
        if(actId != NULL){
            actTeamMem = [SELECT Account.Name,TeamMemberRole,User.Name,UserId FROM AccountTeamMember where accountId =:actId and TeamMemberRole=:'Territory Account Manager'];
            if(actTeamMem != NULL && actTeamMem.size()>0){
                for(AccountTeamMember atmember: actTeamMem){
                    if(!getTAMMap.containskey(atmember.UserId))
                        getTAMMap.put(atmember.UserId,atmember.User.Name);
                }
                return getTAMMap;
            }
        }
        return new Map<Id,String>();
    }
}