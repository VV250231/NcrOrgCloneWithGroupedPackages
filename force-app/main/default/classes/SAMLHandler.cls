/****************************************************************************************************************
*   ClassName :   SAMLHandler
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1617     30 Nov 2021     Kapil Bhati          Removed hardcoded IPT Partner Community User Profile Id
                                                     Removed hardcoded IPT Partner Community Read Only Profile Id
EBA_SF-2491     19-12-2022      Monika               JDK Locale impact - Upgrade API Part 5  
****************************************************************************************************************/
global class SAMLHandler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    
    
    ////-- USER NOT FOUND
    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        //SAMLHandlerUtil.samlAssertion = assertion;
        User u = new User();
        try{
            
            u = executionlogicForContact(True,u,federationIdentifier, attributes);
            insert u;
            System.debug('u'+ u);
            System.debug('u'+ u.profileId);
        }catch(exception e){
           throw new JitException(e.getmessage() + Attributes +' User Name:'+ federationIdentifier );
        }
        System.debug('u'+ u);
        System.debug('u'+ u.profileId);
        return u;
        
    }
    
    ///  ---- USER FOUND UPDATE SCENARIO----
    
    
    /* 
    
    Method When user found with the federationIdentifier
    Salesforce passs the context to us here 
    
    */
    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        try{
            User u = [SELECT Id, FirstName,isActive, ContactId,Profile.Name, AccountId ,FederationIdentifier FROM User WHERE Id=:userId];
            validationForUpdate(u , samlSsoProviderId, communityId, portalId,
                        federationIdentifier,  attributes, assertion);
           }catch(exception e){
           throw new JitException(e.getmessage() + Attributes +' User Name:'+ federationIdentifier );
        }             
                        
        
     }
    

    /* 

        Basic  user Check 
        --- Checks done -->
            1. User Profile 
                
            2. User Active
            3. User Contact Linked or not
            
    */      
    private void validationForUpdate(User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion){
        
        //Check done for correct Profile 
        List<User> userList = [SELECT Id, FirstName,isActive, ContactId,Profile.Name, AccountId FROM User WHERE Id=:u.id And 
        Profile.name IN ('IPT Partner Community Login User','IPT Partner Community Login User Read Only','Partner Community User','Partner Community Read Only','Hospitality SMB Partner Manager','Hospitality SMB Partner User')];
       
       // "Ist check :If user exist with correct profile"
       
       IF(userList != null && !userList.isEmpty()){
       
       // "IInd Check : user  is not active AND CONTACT lINKED"
            IF(userList[0].IsActive && userList[0].ContactId == null ){ 
               
               /*** Enable this piece for activating the further cases for Contact ***/ 
               // executionlogicForContact(false,userList[0],federationIdentifier, attributes);
               /*-- Case will never exist--*/
                   throw new JitException('User is matched in system and Active but dont have contact ID  linked'+ attributes +' User Name:'+ federationIdentifier );
           
            }  
           ELSE IF(userList[0].IsActive && userList[0].ContactId != null ){ 
               System.debug('User Matched with Contact and User in Salesforce');
                //////////// Perfect scenario //////////
                
                //-- Optional check can be done---//
              //Check if attach to correct account i.e basically MCN check
              //userContactMCNCheck();
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
          throw new JitException('User is not linked to correct IPT profile!' );
         
       }
    }
     
    /*
    
        Contact Level validations
        1. Contact exist with the userName from AD
            a. NO  --> Search MCN 
                MCN found -- 1 MCN found - create contact and attach with  Account with MCN found
                          --- multiple MCN -- Create contact and attach with dummy account and create case
                          --- Not found  
    
    */
    private USer executionlogicForContact(Boolean Iscreate,User userObj, String federationIdentifier, Map<String, String> attributes){
        User u;
        
        List<Contact> conList =[Select Id , Name , Web_Portal_Login__c, AccountId, Account.Master_Customer_number__c,FirstName, LastName from Contact Where Web_Portal_Login__c=: federationIdentifier ];
        
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
           IF(!ContactFound )
          //  createCase('More than one contact found with the same WPL. Please select one and attach',attributes,federationIdentifier);
            throw new JitException('User Not found with the userName:' + federationIdentifier + 'And While searching  More than one contact was found with the userName but was not an exact match' );
                
        }
        //"Contact is one "
        Else IF( conlist.size()== 0){
        // Create the contact and attach to The correct Account 
            String MCN = attributes.get('MCN');
            IF(MCN != null) {
                acts = [SELECT Id,IsPartner,Partnership_Status__c FROM Account WHERE Master_Customer_Number__c =: MCN AND IsPartner= true AND Partnership_Status__c ='Active'];
                
                //--> If 1 Account found on basis of MCN 
                //---- Attach to that Accomunt
                IF( acts.size() == 1) {
                    Id accid = acts[0].id ;
                    
                    u= createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                    
                } ELSE{
                  //  --> If  No account or multiple Account Found  
                    //--- create the case and attach to dummy Account
                        IF(!acts.isEmpty()){
                            Id accid = attachtoDummyAccount(federationIdentifier, attributes);
                            u = createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                            createCase(' More than one Active Partner Account exist.Please check which account to be used .',attributes,federationIdentifier);
                       }ELSE{
                            Id accid = attachtoDummyAccount(federationIdentifier, attributes);
                            u = createContactAndUserForUpdate(Iscreate,userObj,accid ,federationIdentifier,attributes );
                            createCase(' NO Active MCN found or MCN doesnot exist,IT is attached to default Account',attributes,federationIdentifier);
                       }
                }   
            }Else{
            //attach the contact to dummy Account
                Id accid = attachtoDummyAccount(federationIdentifier,attributes);
                u = createContactAndUserForUpdate(Iscreate,userobj,accid ,federationIdentifier,attributes );
                createCase('NO Account found with the same MCN. ',attributes,federationIdentifier);
                            
            }
                    
        }   
            // "Contact does not exist"
        ELSE IF (conlist.size()== 1){
        // update and attach to contact
        ///Segregation of Insert and Update
            IF(!isCreate) {
                userObj.contactId = conlist[0].Id;
                update userObj;
                u = userOBj;
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
        If(dummyAcc != null) {
            accId = dummyAcc.id;
            //createCase('Partner user account not found. User has been linked with NCR Partner Account',attributes,federationIdentifier);
        } else {
             createCase('MCN and NCR Partner dummy both account not found. User is not able to access partner community',attributes,federationIdentifier); 
        }
        return accId;
     }
    
    public User createContactAndUserForUpdate(Boolean IsCreate,User uObj,Id  AccID ,String federationIdentifier, Map<String, String> attributes){
        User u;
        Contact con = new Contact();
        if(attributes.containsKey('Contact.Email'))
            con.Email = attributes.get('Contact.Email');
        if(attributes.containsKey('firstname'))
            con.FirstName = attributes.get('firstname');
        if(attributes.containsKey('Contact.LastName'))
            con.LastName = attributes.get('Contact.LastName');
        if(attributes.containsKey('telephoneNumber'))
            con.Phone = attributes.get('telephoneNumber');
               
        List<RecordType> recTypes = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'PartnerContact'
                                             AND SobjectType = 'Contact' AND IsActive = true];
        if(recTypes.size() > 0)
            con.RecordTypeId = recTypes[0].Id;
        con.AccountId = AccID;
        con.Web_Portal_Login__c = federationIdentifier;
        con.Portal_User__c = true;
       
        try {
            insert(con);
            
            //Segregation of Insert and update
           IF(!isCreate) {
                uObj.contactId = con.Id;
                update uObj;
                u = uObj;
            }Else{
                //Check the Account ID;
                 u= userCreation(IsCreate,con.Id, AccID ,  u,  attributes, federationIdentifier);
            }
            //u = uobj
            } catch (Exception ex) {
                 createCase(ex.getMessage(),attributes,federationIdentifier);
            }
            
            return u;
                   
        
    }
    
    //Case create 
    
     private void createCase(String ErrMsg, Map<String,String> attributes, String federationIdentifier){
        
        String description='\r\n'+'User = '+ federationIdentifier;
        
        List<RecordType> RecTypes = [SELECT Id, Name FROM RecordType WHERE DeveloperName = 'IPT_Partner' AND SobjectType = 'Case' LIMIT 1];
        Case newCase = new Case();
        newCase.Type='Problem';
        newCase.Origin='IPT SSO';
        newCase.Status='New';
        newCase.Priority='High';
        
        if (RecTypes.size() > 0) {
            newCase.RecordTypeId = RecTypes[0].Id;
        }
        system.debug('***'+attributes);
        if (attributes != null) {
          for (String key : attributes.keySet()) {
            description += '\r\n'+ Key +' = ' + attributes.get(key);
          }
        }
        newCase.Description = ErrMsg+description;
        insert newCase;
      }
      
      //Fetch the dummy Account
        Account demoAct;
       private Account fetchDummyAccDetails(){
          if (demoAct == null) {
              List<Account> tempList = [SELECT Id FROM Account WHERE Name='NCR Partner Account' LIMIT 1];
              if (tempList.size() == 0) {
                  return null;
              }
              demoAct = tempList[0];
          }
          
        return  demoAct;
      }
      
      public static Boolean runningInASandbox() {
          return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
      }
      
      private User userCreation(boolean IsCreate,Id ContactId,Id AccountId, User u, Map<String, String> attributes,String federationIdentifier){
        u = new User();
           u.Quicklook_ID__c = federationIdentifier; 
        // If user is aligned with correct MCN/Account then assign 'Partner Community User' Profile to user else assign 
        // 'Partner Community User Read Only Profile'  
        Account tempAct = fetchDummyAccDetails();
        
             if (tempAct != null) {
               
                if (AccountId!= tempAct.Id) {
                  //u.ProfileId = '00e70000000k6DG'; // IPT Partner Community User Profile.
                    u.ProfileId = NSCCommonInfoUtil.getIdOf('IPT_Partner_Community_User_Profile_Id'); // IPT Partner Community User Profile. //EBA_SF-1617 - Removed hardcoded IPT Partner Community User Profile Id - Kapil Bhati
                } else {
                  //u.ProfileId = '00e70000000k6Da'; // IPT Partner Community Read Only Profile.
                    u.ProfileId = NSCCommonInfoUtil.getIdOf('IPT_Partner_Community_ReadOnly_ProfileId'); // IPT Partner Community Read Only Profile. //EBA_SF-1617 - Removed hardcoded IPT Partner Community Read Only Profile Id - Kapil Bhati
                }
            } else {
              //u.ProfileId = '00e70000000k6DG'; //IPT Partner Community User Profile.
                u.ProfileId = NSCCommonInfoUtil.getIdOf('IPT_Partner_Community_User_Profile_Id'); // IPT Partner Community User Profile. //EBA_SF-1617 - Removed hardcoded IPT Partner Community User Profile Id - Kapil Bhati
            }
        
        
        System.debug('ContactId'+ ContactId);
        u.contactId = ContactId;
        u.Do_Not_Deactivate__c = true;
        
        u.Username = federationIdentifier + '@ncr.com';
        u.FederationIdentifier = federationIdentifier;
        
        if(attributes.containsKey('User.Email')) {
          u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('firstname')) {
          u.FirstName = attributes.get('firstname');
        }
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
            } else {
                alias = u.FirstName.charAt(0) + u.LastName;
            }
            if(alias.length() > 5) {
              alias = alias.substring(0, 5);
            }
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