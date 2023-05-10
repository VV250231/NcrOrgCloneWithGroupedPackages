/*************************************************************************************************
*   ClassName :   BPMCommunityUserCreationHandler
*   Description :   
*   Author      :   
# Modification History.: 
Story No#       Date            DevName            Description
EBA_SF-1909     12-08-2022      Monika      Technical Debt - Apex sharing violation part 1 
*************************************************************************************************/
public without sharing class BPMCommunityUserCreationHandler {
    public static boolean isSSOUser = false;
    public static void createUsr(List<Contact> conL){
        List<User> userL = new List<User>();
        Set<String> qlIdS = new Set<String>();
        Map<String, User> qlUserIdM = new Map<String, User>();
        List<Contact> conQlL = new List<Contact>();
        for(Contact c : conL){
            if(c.Quicklook_ID__c!=null){
                conQlL.add(c);
            	qlIdS.add((c.Quicklook_ID__c).toLowerCase());
            }else{
                c.addError(system.label.BPM1);
            }
            //Error msg for custom label BPM1
            //Quicklook is mandatory for BPM Contact 
        }
        for(User u : [SELECT Id,Quicklook_ID__c, UserType, IsActive, LastLoginDate , user_profile__c FROM User where Quicklook_ID__c in: qlIdS]){
            qlUserIdM.put((u.Quicklook_ID__c).toLowerCase(), u);
        }
        Profile pf = [select id, Name from profile where name='BPM Partner Community User'];
        for(Contact c: conQlL){
            if(!qlUserIdM.containsKey(c.Quicklook_ID__c.toLowerCase())){
                userL.add(getConvertedUserFormContact(c,pf));
            }
            else{
                c.addError(string.format(system.label.BPM2, new List<String> {qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).user_profile__c,string.valueof(qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).LastLoginDate),string.valueof(qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).isActive)}));
            }
            //Error msg for custom label BPM2
            //Already user exist with profile '+qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).user_profile__c+' with last login date as '+qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).LastLoginDate +' and user status is '+qlUserIdM.get(c.Quicklook_ID__c.toLowerCase()).isActive);
        }
        if(isSSOUser && !userL.isEmpty()){
        	insert userL;
        }else{
        	System.enqueueJob(new UserCrtnQueue(userL));
        }
    }
    private static User getConvertedUserFormContact(Contact con,Profile pf){
        return new User(contactId = con.Id,username = con.Email,firstname = con.FirstName,lastname = con.LastName,email = con.Email,
                        IsActive=true,alias = con.Quicklook_ID__c.toLowerCase(), Quicklook_ID__c = con.Quicklook_ID__c.toLowerCase(),
                        profileid = pf.Id, emailencodingkey='UTF-8',languagelocalekey = 'en_US',localesidkey = 'en_US', 
                        timezonesidkey = 'America/Los_Angeles',IsBPMUser__c = true, FederationIdentifier = con.Quicklook_ID__c.toLowerCase(),
                       License_Entitlement__c='Partner Portal-Full',LOB__c='CROSS LOB',Area__c='Global'); 
    }
    public class UserCrtnQueue implements Queueable {
        List<User> usrLst;
        public UserCrtnQueue(List<User> usrLst) {
            this.usrLst = usrLst;
        }
        public void execute(QueueableContext context) {
            if(!usrLst.isEmpty()){
				database.insert(usrLst,false); 
                Database.executeBatch(new APOCReassignmentBatch());
            }
                    
        }
    }
}