/****************************************************************************************************************
*   ClassName :   VOCSAMLHandler
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati          Removed hardcoded Banking Customer Profile id
****************************************************************************************************************/
global class VOCSAMLHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}

    ////-- New user creation when user not found
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,String federationIdentifier, Map<String, String> attributes, String assertion) {
        
        User u = new User();
        try{
            u = executionlogicForContact(True,u,federationIdentifier, attributes);
            if(!Test.isRunningTest()) insert u;
            
            // Get MCNs from MyNCR
            Get_McnFromMyncrServices.makeGetCallout(federationIdentifier,attributes.get('User.Email'), u.contactId,u.AccountId);
            
        }catch(exception e){ throw new JitException(e.getmessage() + Attributes +' User Name:'+ federationIdentifier );
        }
        System.debug('u'+ u);
        System.debug('u'+ u.profileId);
        return u;
        
    }
    
    /* Method When user found with the federationIdentifier. Salesforce passs the context to us here  */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        try{
            User u = [SELECT Id, FirstName,isActive, ContactId,Profile.Name, AccountId ,FederationIdentifier FROM User WHERE Id=:userId];
            validationForUpdate(u , samlSsoProviderId, communityId, portalId,federationIdentifier,  attributes, assertion);
            System.debug('username'+ attributes.get('User.Username'));
            System.debug('uEmail'+ attributes.get('User.Email'));
            System.debug('u'+ u.ContactId);
            System.debug('@account'+ u.AccountId);
            System.debug('federationIdentifier'+ federationIdentifier);
            Get_McnFromMyncrServices.makeGetCallout(federationIdentifier,attributes.get('User.Email'), u.ContactId,u.AccountId);
           }catch(exception e){ throw new JitException(e.getmessage() + Attributes +' User Name:'+ federationIdentifier ); }             
     }
    

    /* Basic  user Check  --- Checks done --> 1. User Profile 2. User Active 3. User Contact Linked or not */      
    private void validationForUpdate(User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion){
        
        //Check done for correct Profile 
        List<User> userList = [SELECT Id, FirstName,isActive,ContactId,Profile.Name, AccountId FROM User WHERE Id=:u.id And Profile.name IN ('Banking Customer')];
       
       // "Ist check :If user exist with correct profile"
       
       IF(userList != null && !userList.isEmpty()){
       
       // "IInd Check : user  is not active AND CONTACT lINKED"
            IF(userList[0].IsActive && userList[0].ContactId == null ){throw new JitException('User is matched in system and Active but dont have contact ID  linked'+ attributes +' User Name:'+ federationIdentifier ); }  
           ELSE IF(userList[0].IsActive && userList[0].ContactId != null ){ 
               System.debug('User Matched with Contact and User in Salesforce');
                //////////// Perfect scenario //////////
            }
          ELSE  IF(!userList[0].IsActive && userList[0].ContactId != null ){ 
               userList[0].IsActive = true;
               update userList[0]; 
            }
            ELSE{
            System.debug(userList[0].IsActive +'hi'+ userList[0].ContactId );
                // Cannot create the new user and activate  it. Salesforce allows 
                   throw new JitException('User is Not Active but matched from the MyNCR' );
            }
        }
        Else{
        // Do Nothing in case of no Profile match. Let the exception occur.
          throw new JitException('User is not linked to correct Banking profile!' );
         
       }
    }
     
    /*
    
        Contact Level validations
        1. Contact exist with the userName from AD
            a. NO  --> Search MCN 
                MCN found -- 1 MCN found - create contact and attach with  Account with MCN found
                          --- multiple MCN -- Create contact and attach with dummy account
                          --- Not found  
    
    */
    private USer executionlogicForContact(Boolean Iscreate,User userObj, String federationIdentifier, Map<String, String> attributes){
        User u;
        
        List<Contact> conList =[Select Id , Name , Web_Portal_Login__c, AccountId, Account.Master_Customer_number__c,FirstName, LastName from Contact Where Web_Portal_Login__c=: federationIdentifier ];
         System.debug('conList'+conList );
        List<Account> acts = new List<Account>();       
        Boolean ContactFound = false;
        //"Contact is greater than one"
        IF(conlist.size()> 1) {
        // Attach to the exact contact
        for(Contact con : conlist){
         If(con.Web_Portal_Login__c.equals(federationIdentifier)){
             //Check the Account ID;
                Id AccountId = conlist[0].AccountId;
                u = userCreation(IsCreate,conlist[0].Id, AccountId,  u,  attributes, federationIdentifier);
            
            ContactFound = true;
         break;
         }
         
       }
           IF(!ContactFound ) throw new JitException('User Not found with the userName:' + federationIdentifier + 'And While searching  More than one contact was found with the userName but was not an exact match' );   
        }
        //"Contact is one "
        Else IF( conlist.size()== 0){
        // Create the contact and attach to The correct Account 
            String MCN = attributes.get('MCN');
            IF(MCN != null) {
                acts = [SELECT Id,Active_Account__c FROM Account WHERE Master_Customer_Number__c =: MCN AND Active_Account__c= true];
                
                //--> If 1 Account found on basis of MCN //---- Attach to that Accomunt
                IF( acts.size() == 1) {
                    Id accid = acts[0].id ;
                    u= createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                } 
                
                ELSE{
                  //  --> If  No account or multiple Account Found //--- create the case and attach to dummy Account
                        IF(!acts.isEmpty()){
                            Id accid = attachtoDummyAccount(federationIdentifier, attributes);
                            u = createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                       }ELSE{
                            Id accid = attachtoDummyAccount(federationIdentifier, attributes);
                            u = createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                       }
                }   
            }Else{
            //attach the contact to dummy Account
                Id accid = attachtoDummyAccount(federationIdentifier,attributes);
                u = createContactAndUserForUpdate(Iscreate,userobj,accid ,federationIdentifier,attributes );
                            
            }
                    
        }   
            // "Contact does not exist"
        ELSE IF (conlist.size()== 1){
        // update and attach to contact
        ///Segregation of Insert and Update
            IF(!isCreate) { userObj.contactId = conlist[0].Id; update userObj; u = userOBj;
            }Else{
                //Check the Account ID;
                Id AccountId = conlist[0].AccountId;
                u = userCreation(IsCreate,conlist[0].Id, AccountId,  u,  attributes, federationIdentifier);
            }
        }
        return u;
     }
     
     private Id attachtoDummyAccount(String federationIdentifier, Map<String, String> attributes){
       Id accId;
       Account dummyAcc = fetchDummyAccDetails();
        If(dummyAcc != null) { accId = dummyAcc.id; } 
         else {
        }
        return accId;
     }
    
    public User createContactAndUserForUpdate(Boolean IsCreate,User uObj,Id  AccID ,String federationIdentifier, Map<String, String> attributes){
        User u;
        Contact con = new Contact();
        System.debug('attributes'+ attributes);
        if(attributes.containsKey('Contact.Email'))
            con.Email = attributes.get('Contact.Email');
        if(attributes.containsKey('firstname'))con.FirstName = attributes.get('firstname');
        if(attributes.containsKey('Contact.LastName'))
            con.LastName = attributes.get('Contact.LastName');
        if(attributes.containsKey('telephoneNumber'))
            con.Phone = attributes.get('telephoneNumber');
               
        List<RecordType> recTypes = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'CustomerContact' AND SobjectType = 'Contact' AND IsActive = true];
        if(recTypes.size() > 0)
            con.RecordTypeId = recTypes[0].Id;
        con.AccountId = AccID;
        con.Web_Portal_Login__c = federationIdentifier;
        con.Portal_User__c = true;
       
        try {
           insert(con);
            
            //Segregation of Insert and update
           IF(!isCreate) { uObj.contactId = con.Id; update uObj; u = uObj;}
            Else{
                //Check the Account ID;
                 u= userCreation(IsCreate,con.Id, AccID ,  u,  attributes, federationIdentifier);
            }

            } catch (Exception ex) {
              system.debug('Ex'+ex);
            }
            
            return u;  
    }
    
      
      //Fetch the dummy Account
        Account demoAct;
       private Account fetchDummyAccDetails(){
          if (demoAct == null) {
              List<Account> tempList = [SELECT Id FROM Account WHERE Name='Sales Academy Test Account' LIMIT 1];
              if (tempList.size() == 0) {
                  return null;
              }
              demoAct = tempList[0];
          }
          
        return  demoAct;
      }
      
      private User userCreation(boolean IsCreate,Id ContactId,Id AccountId, User u, Map<String, String> attributes,String federationIdentifier){
        u = new User();
           u.Quicklook_ID__c = federationIdentifier; 
          // u.ProfileId = '00e4u000001elNL'; //Banking Customer Profile
          //EBA_SF-1617 Removed hardcoded Banking Customer Profile id - Change done by - Kapil Bhati
           u.ProfileId = NSCCommonInfoUtil.getIdOf('Banking_Customer_Profile_Id'); //Banking Customer Profile
                          
          
        System.debug('ContactId'+ ContactId);
        u.contactId = ContactId;
        u.Do_Not_Deactivate__c = true;
        
        u.Username = attributes.get('User.Email');
        u.FederationIdentifier = federationIdentifier;
        
        if(attributes.containsKey('User.Email')) {
          u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('firstname')) { u.FirstName = attributes.get('firstname'); }
        if(attributes.containsKey('User.LastName')) { 
          u.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('telephoneNumber')) {
          u.Phone = attributes.get('telephoneNumber');
        }
        if(attributes.containsKey('User.Country')) {
          u.Country = attributes.get('User.Country');
        }
                
        String uid = UserInfo.getUserId();
        User currentUser = [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        if(attributes.containsKey('User.LocaleSidKey')) {
          u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if(attributes.containsKey('User.LanguageLocaleKey')) {
          u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if(attributes.containsKey('User.Alias')) {
          u.Alias = attributes.get('User.Alias');
        } else {
            String alias = '';
            if(u.FirstName == null) {
              alias = u.LastName;
            } else { alias = u.FirstName.charAt(0) + u.LastName; }
            if(alias.length() > 5) { alias = alias.substring(0, 5);}
            u.Alias = alias;
        }
        if(attributes.containsKey('User.TimeZoneSidKey')) {
          u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
        } else if(Iscreate) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if(attributes.containsKey('User.EmailEncodingKey')) {
          u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if(Iscreate) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }
        
        return u;
    }
}