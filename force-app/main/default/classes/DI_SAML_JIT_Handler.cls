global class DI_SAML_JIT_Handler implements Auth.SamlJitHandler {
    private class JitException extends Exception{}
    string debug='';
    private void handleUser(boolean create, User u, Map<String, String> attributes,
        String federationIdentifier, boolean isStandard) {
        if(create && attributes.containsKey('User.Username')) {
            u.Username = attributes.get('User.Username');
        }
        if(create) {
            if(attributes.containsKey('User.FederationIdentifier')) {
                u.FederationIdentifier = attributes.get('User.FederationIdentifier');
            } else {
                u.FederationIdentifier = federationIdentifier;
            }
        }
        if(attributes.containsKey('User.Phone')) {
            u.Phone = attributes.get('User.Phone');
        }
        if(attributes.containsKey('User.Email')) {
            u.Email = attributes.get('User.Email');
        }
        if(attributes.containsKey('User.FirstName')) {
            u.FirstName = attributes.get('User.FirstName');
        }
        if(attributes.containsKey('User.LastName')) {
            u.LastName = attributes.get('User.LastName');
        }
        if(attributes.containsKey('User.Title')) {
            u.Title = attributes.get('User.Title');
        }
        if(attributes.containsKey('User.CompanyName')) {
            u.CompanyName = attributes.get('User.CompanyName');
        }
        if(attributes.containsKey('User.AboutMe')) {
            u.AboutMe = attributes.get('User.AboutMe');
        }
        if(attributes.containsKey('User.Street')) {
            u.Street = attributes.get('User.Street');
        }
        if(attributes.containsKey('User.State')) {
            u.State = attributes.get('User.State');
        }
        if(attributes.containsKey('User.City')) {
            u.City = attributes.get('User.City');
        }
        if(attributes.containsKey('User.Zip')) {
            u.PostalCode = attributes.get('User.Zip');
        }
        if(attributes.containsKey('User.Country')) {
            u.Country = attributes.get('User.Country');
        }
        if(attributes.containsKey('User.CallCenter')) {
            u.CallCenterId = attributes.get('User.CallCenter');
        }
        if(attributes.containsKey('User.Manager')) {
            u.ManagerId = attributes.get('User.Manager');
        }
        if(attributes.containsKey('User.MobilePhone')) {
            u.MobilePhone = attributes.get('User.MobilePhone');
        }
        if(attributes.containsKey('User.DelegatedApproverId')) {
            u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
        }
        if(attributes.containsKey('User.DI_Fi_Name__c')) {
            u.DI_Fi_Name__c = attributes.get('User.DI_Fi_Name__c');
            
        }
        if(attributes.containsKey('User.Di_Account__c')) {
            u.Di_Account__c = attributes.get('User.Di_Account__c');
            
        }
        if(attributes.containsKey('User.Department')) {
            u.Department = attributes.get('User.Department');
        }
        if(attributes.containsKey('User.Division')) {
            u.Division = attributes.get('User.Division');
        }
        if(attributes.containsKey('User.EmployeeNumber')) {
            u.EmployeeNumber = attributes.get('User.EmployeeNumber');
        }
        if(attributes.containsKey('User.Extension')) {
            u.Extension = attributes.get('User.Extension');
        }
        if(attributes.containsKey('User.Fax')) {
            u.Fax = attributes.get('User.Fax');
        }
        if(attributes.containsKey('User.CommunityNickname')) {
            u.CommunityNickname = attributes.get('User.CommunityNickname').substring(0, 40);
        }
        if(attributes.containsKey('User.ReceivesAdminInfoEmails')) {
            String ReceivesAdminInfoEmailsVal = attributes.get('User.ReceivesAdminInfoEmails');
            u.ReceivesAdminInfoEmails = '1'.equals(ReceivesAdminInfoEmailsVal) || Boolean.valueOf(ReceivesAdminInfoEmailsVal);
        }
        if(attributes.containsKey('User.ReceivesInfoEmails')) {
            String ReceivesInfoEmailsVal = attributes.get('User.ReceivesInfoEmails');
            u.ReceivesInfoEmails = '1'.equals(ReceivesInfoEmailsVal) || Boolean.valueOf(ReceivesInfoEmailsVal);
        }
        String uid = UserInfo.getUserId();
        User currentUser = 
            [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
        if(attributes.containsKey('User.LocaleSidKey')) {
            u.LocaleSidKey = attributes.get('User.LocaleSidKey');
        } else if(create) {
            u.LocaleSidKey = currentUser.LocaleSidKey;
        }
        if(attributes.containsKey('User.LanguageLocaleKey')) {
            u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
        } else if(create) {
            u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
        }
        if(attributes.containsKey('User.Alias')) {
            u.Alias = attributes.get('User.Alias');
        } else if(create) {
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
        } else if(create) {
            u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
        }
        if(attributes.containsKey('User.EmailEncodingKey')) {
            u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
        } else if(create) {
            u.EmailEncodingKey = currentUser.EmailEncodingKey;
        }

        /*
         * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
         * If your identity provider sends these User fields as attributes along with Contact 
         * or Account fields, you must modify the logic in this class to update either these 
         * User fields or the Contact and Account fields.
         */
        if(attributes.containsKey('User.IsActive')) {
            String IsActiveVal = attributes.get('User.IsActive');
            u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
        }
        /*if(attributes.containsKey('User.ForecastEnabled')) {
            String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
            u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
        }*/
        if(attributes.containsKey('User.ProfileId')) {
            String profileId = attributes.get('User.ProfileId');
            Profile p = [SELECT Id FROM Profile WHERE Id=:profileId];
            u.ProfileId = p.Id;
        }
        /*if(attributes.containsKey('User.UserRoleId')) {
            String userRole = attributes.get('User.UserRoleId');
            UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
            u.UserRoleId = r.Id;
        }*/

        //Handle custom fields here

        if(!create) {
            // Handle validation rules
            update(u);
        }
    }

    private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
        Contact c;
        boolean newContact = false;
        boolean updateContact = false;
        if(create) {
            if(attributes.containsKey('User.Email')) {
                //if(attributes.containsKey('Contact.Email')) {
                // String contactEmail = attributes.get('Contact.Email');
             String contactEmail =   attributes.get('User.Email');
            system.debug('contactEmail'+contactEmail);
            List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE Email=:contactEmail LIMIT 1];
            if (contacts.size()>0) {
                c = contacts[0];
                u.ContactId = c.Id;
            } else {
                c = new Contact();
                newContact = true;
            }
            
            } else {
                c = new Contact();
                newContact = true;
            }
        } else {
            if(attributes.containsKey('User.Email')) {
                //if(attributes.containsKey('Contact.Email')) {
                //String contactEmail = attributes.get('Contact.Email');
                 String contactEmail =   attributes.get('User.Email');
                String contactId = u.ContactId;
                 //system.debug('contactEmail'+contactEmail);
                 //system.debug('user.ContactId'+u.ContactId);
                c = [SELECT Id, AccountId,Email,Account.Name FROM Contact WHERE Id=:contactId];
                 system.debug('contact acc and email'+c.Account.Name+' '+c.Email+'contactid'+ c.Id);
                //if(c.Email != contactEmail) 
                {
                    c.Email = attributes.get('User.Email');
                    updateContact = true;
                }
            }
        }
        if(!newContact && c.AccountId != accountId) {
            throw new JitException('Mismatched account: ' + c.AccountId + ', ' + accountId);
        }

        if(attributes.containsKey('User.Email')) {
            //if(attributes.containsKey('Contact.Email')) {
           // c.Email = attributes.get('Contact.Email');
            c.Email = attributes.get('User.Email');
            
        }
        if(attributes.containsKey('Contact.FirstName')) {
            c.FirstName = attributes.get('Contact.FirstName');
        }
        if(attributes.containsKey('Contact.LastName')) {
            c.LastName = attributes.get('Contact.LastName');
        }
        
        if(newContact) {
            c.AccountId = accountId;
            insert(c);
            u.ContactId = c.Id;
        } else if (updateContact) {           
            update(c);
        }
    }

    private String handleAccount(boolean create, User u, Map<String, String> attributes) {
        Account a;
        boolean newAccount = false;
        if(create) {
            if(attributes.containsKey('Account.AccountNumber')) {
                String accountNumber = attributes.get('Account.AccountNumber');
                List<Account> acts = [SELECT Id FROM Account WHERE AccountNumber=:accountNumber LIMIT 1];
                if (acts.size() != 0) {
                    a = acts[0];
                } else {
                    a = new Account();
                    newAccount = true;
                }
            } else {
                if(attributes.containsKey('User.Email')) {
                    //if(attributes.containsKey('Contact.Email')) {
                    //String contactEmail = attributes.get('Contact.Email');
                     String contactEmail =   attributes.get('User.Email');
                    List<Contact> c = [SELECT AccountId FROM Contact WHERE Email=:contactEmail];
                    //If contact is not associated with any account.
                    if (c.size() != 0) {
                        String account = c[0].AccountId;
                        if (!String.isBlank(account)) {
                            a = [SELECT Id FROM Account WHERE Id=:account];
                        } else {
                            a = new Account();
                            newAccount = true;
                        }
                    } else {
                        a = new Account();
                        newAccount = true;
                    }
                    
                } else {
                    a = new Account();
                    newAccount = true;
                }
            }
        } else {
            // No operation on account if user is not being created. Only return the account.
            if(attributes.containsKey('Account.AccountNumber')) {
                String accountNumber = attributes.get('Account.AccountNumber');
                a = [SELECT Id,Name FROM Account WHERE AccountNumber=:accountNumber LIMIT 1];
                system.debug('Account'+a);
            }
        }
        
        
        if(newAccount) {
            if(attributes.containsKey('Account.Name')) {
                a.Name = attributes.get('Account.Name');
            }
            if(attributes.containsKey('Account.AccountNumber')) {
                a.AccountNumber = attributes.get('Account.AccountNumber');
            }
            insert(a);
        }
        
        return a.Id;
    }

    private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
            Try{
        if(communityId != null || portalId != null) {
             debug += 'handle Account Start';
            String account = handleAccount(create, u, attributes);
            System.debug('handle Contact Start');
            debug  +='handle Contact Start';
            handleContact(create, account, u, attributes);
            System.debug('handle user Start');
			 debug += 'handle Contact Start';
            handleUser(create, u, attributes, federationIdentifier, false);
             System.debug('handle user finish');
 			debug += 'handle user finish';
        } else {
             System.debug('inside else : handle user start');
            debug = 'inside else : handle user start';
            handleUser(create, u, attributes, federationIdentifier, true);
        }
            }
            Catch (Exception ex)
            {   
                string msg =  String.valueOf(ex.getLineNumber())+ ' LineNumber '+ ex.getMessage();
                String mailBdy = '';
                for (string entry : attributes.keySet())
                {
                    mailBdy += entry + '-' +  attributes.get(entry) + '\n';
                }
                String[] toAddresses = new String[] {
                    'SJ185091@ncr.com', 'BS250350@ncr.com','ni230017@ncr.com'
                        };
             EmailUtility.sendEmail('Idea-Exchange Login Failed '+u.FirstName+' '+u.LastName ,'Failed SAML LOGIN',msg,mailBdy + '<br/> Debug Message ' +debug , toAddresses);
            }
        }

    global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = new User();
         System.debug('inside createUser: handleJit start');
            debug = 'inside createUser: handleJit start';
        handleJit(true, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
        return u;
    }

    global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
        String federationIdentifier, Map<String, String> attributes, String assertion) {
        User u = [SELECT Id, FirstName,LastName, ContactId FROM User WHERE Id=:userId];
             System.debug('inside updateUser: handleJit start');
            debug = 'inside updateUser: handleJit start : Userid :' + u.id;
        handleJit(false, u, samlSsoProviderId, communityId, portalId,
            federationIdentifier, attributes, assertion);
    }
}