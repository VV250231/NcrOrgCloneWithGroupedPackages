//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class AutocreatedRegHandler1575289304186 implements Auth.SamlJitHandler {
    private class JitException extends Exception{}    
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
        BPM_User_Provisioning__c customObj = BPM_User_Provisioning__c.getValues('Default User Provisioning Account');
        Account acc = [Select Id FROM Account Where Master_Customer_Number__c =: customObj.Master_Customer_Number__c];
        String cEmail = federationIdentifier+'@ncr.com';
        if([Select Id FROM Contact where Email =: cEmail].size() < 1){
            try{
                BPMCommunityUserCreationHandler.isSSOUser = true;
                NCR_Employee_Detail__c employeObj = [Select Id, User_Name__c FROM NCR_Employee_Detail__c where Quicklook_ID__c =: federationIdentifier];
                Contact con =  new Contact(accountId = acc.Id, LastName = employeObj.User_Name__c, Email = federationIdentifier+'@ncr.com', IsBPMCommunityUser__c = true, Quicklook_ID__c = federationIdentifier);
                insert con;        
            }catch(Exception ex){
                System.debug('Exception occured while user provisioning:'+federationIdentifier);
            }
            u = [Select Id, Email, lastname FROM USer WHere Quicklook_ID__c =: federationIdentifier];
        }else{
            Contact con = [Select Id, accountId, FirstName, LastName, Email, Quicklook_ID__c FROM Contact where Email =: cEmail LIMIT 1];
            if(con.accountId == null){
                con.accountId = acc.Id;
            }
            if(con.Quicklook_ID__c == null){
                con.Quicklook_ID__c = federationIdentifier;
            }
            update con;
            
            Profile pf = [select id, Name from profile where name='BPM Partner Community User'];
            User usr = new User(contactId = con.Id, username = con.Email, lastname = con.LastName, email = con.Email,
                                    IsActive=true, alias = con.Quicklook_ID__c.toLowerCase(), Quicklook_ID__c = con.Quicklook_ID__c.toLowerCase(),
                                    profileid = pf.Id, emailencodingkey='UTF-8', languagelocalekey = 'en_US',localesidkey = 'en_US', 
                                    timezonesidkey = 'America/Los_Angeles', IsBPMUser__c = true, FederationIdentifier = con.Quicklook_ID__c.toLowerCase());
            usr.firstname = (usr.FirstName != null ? usr.FirstName : null);
            insert usr;
            u = usr;
        }
        return u;
    }
    
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId, String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id,IsActive,IsBPMUser__c,usertype,user_profile__c FROM User where Quicklook_ID__c =: federationIdentifier];
        PermissionSet pset = [SELECT Id from PermissionSet where name ='BPM_Community'];
        if(u.IsActive&&u.usertype=='Standard'){
            if([SELECT AssigneeId from PermissionSetAssignment where PermissionSetId =: pset.ID AND AssigneeId =: userId].size() < 1){
                insert new PermissionSetAssignment(PermissionSetId = pset.Id, AssigneeId = userId);    
            }
            u.IsBPMUser__c = true;
            update u;
        }else if(u.User_Profile__c=='BPM Partner Community User'){
        	u.IsBPMUser__c = true;
            update u; 
        }
        else{
            throw new JITException('Already user exist for '+federationIdentifier+ ' with chatter free profile or user is inactive');
        }       
    }
}