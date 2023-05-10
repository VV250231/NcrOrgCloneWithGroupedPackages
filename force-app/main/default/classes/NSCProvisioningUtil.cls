public class NSCProvisioningUtil {

    public class ProvisioningException extends Exception {}

    // Used by the trigger to avoid firing twice after workflow rules 
    // update fields on the quote
    public static boolean AlreadyFired = false;

    @future(callout=true)
    public static void AsyncSendToProvisioning(string quoteId) { 
        NSCProvisioning.OpportunityResponseType response = new NSCProvisioning.OpportunityResponseType();
        NSCProvisioning.execute_pttBindingQSPort port = new NSCProvisioning.execute_pttBindingQSPort(); 

        NSCProvisioning.Detail_element detail = NSCProvisioningUtil.GetDetailFromQuote(quoteId); 
        NSCProvisioning.Header_element header = new NSCProvisioning.Header_element();

        if(detail == null) throw new NSCProvisioningUtil.ProvisioningException('Unable to find details for Quote'); 

        // Handle credentials
        SOUP_Credential__mdt metaCreds = [select Username__c, Password__c from SOUP_Credential__mdt]; 
        if(metaCreds == null) throw new NSCProvisioningUtil.ProvisioningException('SOUP Credentials are not found. Please ' + 
                                                                                        'ensure the SOUP_Provisioning Custom Setting exists ' + 
                                                                                        'and try again.'); 
        string creds = metaCreds.Username__c + ':' + metaCreds.Password__c;
        Blob b = Blob.valueOf(creds); 
        string encodedCreds = EncodingUtil.base64Encode(b); 
        port.inputHttpHeaders_x = new Map<string,string>();
        port.inputHttpHeaders_x.put('Authorization', 'Basic ' + encodedCreds); 

        header.Sender = new NSCProvisioning.Sender_element(); 
        header.Target = new NSCProvisioning.Target_element(); 
        
        header.Sender.Description = 'Provisioning call from NSC for DI';
        header.Sender.CallingServiceName = 'NSC'; 
        header.Sender.ID = new NSCProvisioning.ID_element();
        header.RequestABMID = null; 
        
        header.Target.ServiceName = 'NSCOpportunity'; 
        
        system.debug('\n\nSending Provisioning Request: \n\n' + JSON.serializePretty(detail)); 
        
        // Perform the callout
        response = port.execute(header, detail); 

        system.debug('\n\nReceived Response from SOUP: \n' + JSON.serializePretty(response));
        
    }


















    /**
    *   @description This is the main method to use when building a Provisioning request for SOUP.
    *   @param quoteId The Salesforce Quote Id
    *   @return A fully-built Detail_element object ready to be sent to SOUP
    */ 
    public static NSCProvisioning.Detail_element GetDetailFromQuote(string quoteId) { 
        
        // Our return object
        NSCProvisioning.Detail_element details = new NSCProvisioning.Detail_element(); 
        
        zqu__Quote__c quote = [Select zqu__SubscriptionType__c from zqu__Quote__c where Id = :quoteId]; 

        system.debug('\n\nProvisioning a quote of type: ' + quote.zqu__SubscriptionType__c);

        // Various queries to round up some of the required data 
        Account acc = [select Id, Name, Interface_Type__c from Account 
                                    where Id in (select zqu__Account__c from zqu__Quote__c 
                                            where id = :quoteId)];
        
        Opportunity opp = null; 
        Provisioning__c provisioningData = null;

        //if(quote != null && quote.zqu__SubscriptionType__c != 'Cancel Subscription')  
        //{ 
            opp = [select Id, Description, Proposal_Date__c, Expected_Delivery_Date__c, Owner.FirstName, Owner.LastName, Owner.Title, Owner.Department, Owner.QuickLook_Id__c from Opportunity 
                                    where Id in (select zqu__Opportunity__c from zqu__quote__c 
                                            where Id = :quoteId)];
            try { 
                provisioningData = [select Existing_Domain__c, Primary_Contact__c,
                                                Secondary_Contact__c, Project_Type__c 
                                                from Provisioning__c
                                                where Opportunity__c = :opp.Id
                                                Order By CreatedDate desc
                                                LIMIT 1];
            } 
            catch(System.QueryException ex) { 
                throw new ProvisioningException('Error looking up Provisioning data. Please ensure a related Provisioning__c record exists and then try again.');
            }
        /*}
        else { 
            opp = new Opportunity(); 
            opp.Description = 'Cancellation Opp'; 
            opp.Proposal_Date__c = Date.Today(); 
            opp.Expected_Delivery_Date__c = Date.Today(); 
            // Do not set up provisioning data here since it won't exist
        }*/ // All Quotes, even cancellations, should have Opps now. 
        
                                            
                                                                
        // Build out the complex objects
        details.Company                 = GetCompanyDetailForQuote(quoteId);
        details.Quote                   = GetQuoteDetailForQuote(quoteId, opp.Expected_Delivery_Date__c, quote.zqu__SubscriptionType__c);
        // Cancellation quotes don't have provisioning data
        if(provisioningData != null) { 
            details.PrimaryContact          = GetContactDetail(provisioningData.Primary_Contact__c, 'Primary'); 
            details.SecondaryContact        = GetContactDetail(provisioningData.Secondary_Contact__c, 'Secondary');
            details.ProjectType             = provisioningData.Project_Type__c;
            details.ExistingDomain          = provisioningData.Existing_Domain__c; 
            details.Quote.ExistingDomain    = provisioningData.Existing_Domain__c; 
        }

        // Set the scalars
        details.ProposaldeliveredOn     = opp.Proposal_Date__c;
        details.ContractMonths          = 0; // TODO - Revisit. May need this value, but Contracts DNE, so removing to power through initial E2E SAT testing
        details.DPVinterface            = acc.Interface_Type__c; // Still on the TBD list. Interface Type may suffice.
        details.ProcessingType          = acc.Interface_Type__c;
        details.Status                  = 'Won'; 
        details.UseSalesHandoffPlan     = false; 
        //details.ContractDeliveredOn; -- Deemed unnecessary

        // Hand_Off_Recipient based on Territory is not used. Pivotal code will default to Current Salesperson
        // which is actually the Regional Sales Manager (see the GetCompanyDetail method for RSM assignment).
        //details.Territory                 = ''; // Territory assignment is not used. 
        details.RegionalSalesManager                = new NSCProvisioning.ContactType();
        details.RegionalSalesManager.FirstName      = opp.Owner.FirstName; 
        details.RegionalSalesManager.LastName       = opp.Owner.LastName; 
        details.RegionalSalesManager.JobPosition    = opp.Owner.Title;
        details.RegionalSalesManager.Department     = opp.Owner.Department;
        details.RegionalSalesManager.QLID           = opp.Owner.Quicklook_ID__c;

        // Details now ready to submit to SOUP
        return details;
    }
    
    
    
    /************************************************************/
    /******************** HELPER METHODS ************************/
    /************************************************************/
    
    /** 
    * @description Builds a CompanyType object with an Address, Account Manager, Billing Rep, DPV with sub objects, 
    * phone, and Sales Project Manager associated. 
    * @param quoteId The Salesforce Quote Id associated with the Account to be used
    * @return A fully-built NSCProvisioning.CompanyType object to be sent to SOUP
    */
    public static NSCProvisioning.CompanyType GetCompanyDetailForQuote(string quoteId)
    {
        // Return object
        NSCProvisioning.CompanyType company                 = new NSCProvisioning.CompanyType();

        // Sub-objects to populate
        NSCProvisioning.AddressType address                 = new NSCProvisioning.AddressType();
        NSCProvisioning.ContactType accountManager          = new NSCProvisioning.ContactType();
        NSCProvisioning.ContactType billingRepresentative   = null; //new NSCProvisioning.ContactType(); // Deemed Unnecessary
        NSCProvisioning.VendorType  DPV                     = new NSCProvisioning.VendorType();
        NSCProvisioning.PhoneType   phone                   = new NSCProvisioning.PhoneType();
        NSCProvisioning.ContactType salesProjectManager     = new NSCProvisioning.ContactType();
        
        // Try to get as much as we can out of one query...  
        Account account = [select id
        , Name
        , AccountNumber
        , OwnerId
        , BillingStreet
        , BillingCity
        , BillingCountry
        , BillingState
        , BillingPostalCode
        , ShippingStreet
        , ShippingCity
        , ShippingCountry
        , ShippingState
        , ShippingPostalCode
        , Phone
        , Fax
        , DPV_Provider__c
        , DPV_Software__c
        , DI_Customer__c
        , Service_Bureau__c
        , NCUA__c
        , FDIC__c
        , Type
        , Master_Customer_Number__c
        , Salesperson__c
        , Tier__c
        , FI_Type__c
            // Account Team
        , (select Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, CreatedDate, CreatedById, LastModifiedDate, 
                    LastModifiedById, SystemModstamp, IsDeleted From AccountTeamMembers)
            // zqu__Accounts__r is actually a relationship to zqu__Quote__c
        , (select zqu__ZuoraAccountID__c from zqu__Accounts__r order by createddate desc limit 1)
        //, (select Zuora__AccountNumber__c, Zuora__External_Id__c from Zuora__R00N40000001kyLcEAI__r where BillToFlag__c = 'Yes' order by CreatedDate desc)
        from Account
        where Id in (select zqu__Account__c from zqu__Quote__c where id = :quoteId)];

        // As of the ERP Project, multiple billing accounts with bill-to = 'yes' could make this lookup fail at the account level. 
        // Moving this to the Quote level (I hope) will be more accurate. Otherwise we link Quote -> Account -> Billing Account and there's
        // no way to determine which Bill-To Billing Account we want to link with... not to mention we may be using the Ship To account in certain
        // scenarios (resellers, odd holding company situations, etc)
        zqu__Quote__c q = [select id, zqu__ZuoraAccountID__c, zqu__Zuora_Account_Number__c from zqu__Quote__c where id = :quoteId];
        company.SCA_AccountNumber       = q.zqu__Zuora_Account_Number__c;
        company.SCA_InternalAccountID   = q.zqu__ZuoraAccountID__c; 
            

        // Not sure which address we'll be using, so check Billing
        // but fall back to Shipping if necessary
        if (account.BillingStreet != null) 
        {
            address.Address1    = account.BillingStreet;
            address.Address2    = '';
            address.City        = account.BillingCity;
            address.State       = account.BillingState;
            address.Zip         = account.BillingPostalCode;
            address.Country     = 'US';
            address.Type_x      = 'Billing';
        }
        else if (account.ShippingStreet != null) 
        {
            address.Address1    = account.ShippingStreet;
            address.Address2    = '';
            address.City        = account.ShippingCity;
            address.State       = account.ShippingState;
            address.Zip         = account.ShippingPostalCode;
            address.Country     = 'US';
            address.Type_x      = 'Shipping';
        }
        
        // Account owner lookup
        User owner = [select id, Quicklook_Id__c, firstname, lastname, street, city, state, postalcode, phone, fax, extension, email  
                        from User where Id = :account.OwnerId];

        // Opportunity Owner is the Sales Project Manager
        Opportunity opp = [select OwnerId from Opportunity 
                            where Id in (select zqu__Opportunity__c from zqu__Quote__c where Id = :quoteId) LIMIT 1]; 
                        
        // Sales Project Manager
        User spm = [select id, QuickLook_Id__c, firstname, lastname, street, city, state, postalcode, phone, fax, extension, email  
                        from User where Id = :account.OwnerId];
        

        // EMPLOYEES! (which are sent as Contacts, but DIIG will sort it out)
        // Billing Rep employee - Deemed unnecessary
        accountManager.Address = new List<NSCProvisioning.AddressType>();
        accountManager.Address.Add(new NSCProvisioning.AddressType());
        accountManager.Address[0].Address1  = owner.street;
        accountManager.Address[0].Address2  = '';
        accountManager.Address[0].City      = owner.city; 
        accountManager.Address[0].State     = owner.state;
        accountManager.Address[0].Zip       = owner.postalcode;
        accountManager.Phone                = new NSCProvisioning.PhoneType();
        accountManager.Phone.Work           = owner.phone;
        accountManager.Phone.Extension      = owner.extension;
        accountManager.Phone.Fax            = owner.fax; 
        accountManager.FirstName            = owner.firstname;
        accountManager.LastName             = owner.lastname; 
        accountManager.EmailURI             = owner.email;
        accountManager.QLID                 = owner.Quicklook_ID__c;
        salesProjectManager.Phone   = new NSCProvisioning.PhoneType(); 
        salesProjectManager.Address = new List<NSCProvisioning.AddressType>();
        salesProjectManager.Address.Add(new NSCProvisioning.AddressType());
        salesProjectManager.Address[0].Address1 = spm.street;
        salesProjectManager.Address[0].Address2 = '';
        salesProjectManager.Address[0].City     = spm.city; 
        salesProjectManager.Address[0].State    = spm.state;
        salesProjectManager.Address[0].Zip      = spm.postalcode;
        salesProjectManager.Phone.Work      = spm.phone;
        salesProjectManager.Phone.Extension = spm.extension;
        salesProjectManager.Phone.Fax       = spm.fax; 
        salesProjectManager.FirstName   = spm.firstname;
        salesProjectManager.LastName    = spm.lastname; 
        salesProjectManager.EmailURI    = spm.email;
        salesProjectManager.QLID        = spm.Quicklook_ID__c;
        
        if (account.DPV_Provider__c == null || account.DPV_Software__c == null) { 
            throw new ProvisioningException('Error looking up DPV Details. Please ensure the DPV Provider ' + 
                                            'and DPV Software values are set on the Account and try again.');
        }
        

        // DPV is a bit complex, so we'll clean it up by making it its own method
        company.DPV = GetVendorDetails(account.DPV_Provider__c, account.DPV_Software__c);

        if(account.Service_Bureau__c != null) { 
            company.ServiceBureau = GetVendorDetails(account.Service_Bureau__c, account.DPV_Software__c);
        }
        
        // The only two phone types we can possibly have, afaik
        phone.Work = account.Phone;
        phone.Fax = account.Fax;

        // Scalar types (yes, including SupportTeam, and CRM_ID. These will be looked up
        // on the DIIG side in the Employee Feed or in Pivotal, as necessary.)
        //company.SupportTeam           = ''; // Per Chris Embry and Keith Hartshorn this is no longer required
        //company.TS_Engineer           = ''; // Per Sheila this is not something the business even *wants* anymore
        company.DI_Number               = account.DI_Customer__c;
        company.CompanyName             = account.Name;
        company.Tier                    = (account.Tier__c != null ? Integer.valueOf(account.Tier__c) : null);
        company.Type_x                  = (account.Fi_Type__c != null ? account.FI_Type__c.replace(' ', '') : null); 
        company.MasterCustomerNumber    = account.Master_Customer_Number__c;
        /*
        -- As of the ERP project, multiple Bill-To sites can exist, which makes any lookup from the account level unreliable.
        -- Switching to Quote-level lookups instead. 
        company.SCA_AccountNumber       = account.Zuora__R00N40000001kyLcEAI__r[0].Zuora__AccountNumber__c; // Sketchy relationship name
        company.SCA_InternalAccountID   = account.zqu__Accounts__r[0].zqu__ZuoraAccountID__c;
        */
        company.NCUAID                  = account.NCUA__c;
        company.FDICNumber              = account.FDIC__c;
        company.Address                 = address; 
        company.Phone                   = phone; 
        company.AccountManager          = accountManager;
        company.SalesProjectManager     = salesProjectManager;
        company.CRM_ID                  = account.Id;
        


        return company; 
    }
    
    
    /** 
    * @description Returns a NSCProvisioning.ContactType object for the given contact. 
    * @param contactId The Salesforce Id for the Contact to look up
    * @param contactType Either 'Primary' or 'Secondary'
    * @return A fully-built NSCProvisioning.ContactType object to be sent to SOUP
    */
    public static NSCProvisioning.ContactType GetContactDetail(string contactId, string contactType)
    {
            NSCProvisioning.ContactType contact = new NSCProvisioning.ContactType(); 
            Contact c = [select firstname, lastname, department, title, Phone, MobilePhone, Fax, Ext__c,
                                MailingStreet, MailingCity, MailingState, MailingPostalCode,
                                OtherStreet, OtherCity, OtherState, OtherPostalCode, OtherCountry,
                                MailingCountry, Email 
                            from Contact where id = :contactId];

            contact.ID                  = contactId; 
            contact.Type_x              = contactType;
            contact.FirstName           = c.FirstName;
            contact.LastName            = c.LastName;
            contact.Department          = c.Department;
            contact.JobPosition         = c.Title;
            contact.EmailURI            = c.Email;
            contact.Phone               = new NSCProvisioning.PhoneType();
            contact.Phone.Mobile        = c.MobilePhone;
            contact.Phone.Extension     = c.Ext__c;
            contact.Phone.Work          = c.Phone;
            contact.Phone.Fax           = c.Fax; 

            contact.Address             = new NSCProvisioning.AddressType[]{}; 
            NSCProvisioning.AddressType addr = new NSCProvisioning.AddressType();

            if(String.isNotEmpty(c.MailingStreet)) 
            { 
                addr.Address1   = c.MailingStreet;
                addr.Address2   = '';
                addr.City       = c.MailingCity;
                addr.State      = c.MailingState;
                addr.Zip        = c.MailingPostalCode;
                addr.Country    = 'US'; //c.MailingCountry;
                addr.Type_x     = 'Mailing';
            }
            else if(String.isNotEmpty(c.OtherStreet))
            {
                addr.Address1   = c.OtherStreet;
                addr.Address2   = '';
                addr.City       = c.OtherCity;
                addr.State      = c.OtherState;
                addr.Zip        = c.OtherPostalCode;
                addr.Country    = 'US'; //c.MailingCountry;
                addr.Type_x     = 'Mailing';
            }

            if(String.isNotEmpty(addr.Address1)) { 
                // Add address to the list
                contact.Address.add(addr); 
            }
            
            return contact; 
    }

    /** 
    * @description Returns a fully-built (including all sub objects) NSCProvisioning.QuoteType object. This includes
    * Quote Products and Features as well as all vendor data and sub objects related to the Vendor object. 
    * Features are intentionally de-duped. Quote Products are not so that quantities can be transformed into
    * duplicates on the Pivotal side. 
    * @param quoteId            The Salesforce Id for the Quote being sent to SOUP
    * @param anticipatedLive    The Expected Delivery date from the Opportunity Record
    * @param subType            The Subscription Type (e.g.: Cancel Subscription, New Subscription, Amend Subscription, Renew Subscription)
    * @return A fully-build NSCProvisioning.QuoteType object that can be sent to SOUP 
    */
    public static NSCProvisioning.QuoteType GetQuoteDetailForQuote(string quoteId, Date anticipatedLive, string subType) { 
        zqu__Quote__c quoteRecord = [select Id
                                            ,Name
                                            ,CreatedDate
                                            ,(Select zqu__ProductRatePlanZuoraId__c, zqu__QuoteProductName__c From zqu__Quote_Rate_Plans__r)
                                     from zqu__Quote__c where Id = :quoteId];

        NSCProvisioning.QuoteType quote = new NSCProvisioning.QuoteType();
        quote.ID                        = quoteRecord.Id; 
        quote.ContractsHandoffDate      = Date.Today(); // This is set to DateTime.Today() in the ASR code, so it doesn't matter
        quote.Description               = quoteRecord.Name;
        quote.ExistingDomain            = ''; // This comes from the Provisioning Data record, not the Quote
        quote.Notes                     = AggregateNotes(quoteId); // Aggregating all notes for the Quote into a single string.
        quote.QuoteType                 = subType;
        quote.PrimaryQuote              = true;
        // QuoteDate is set to DateTime.Today in the ASR code, so this likely won't show up
        quote.QuoteDate                 = Date.newInstance(quoteRecord.CreatedDate.year(), quoteRecord.CreatedDate.month(), quoteRecord.CreatedDate.day());
        quote.SalesAnticipatedLive      = anticipatedLive;
        quote.SalesContractSigned       = Date.Today(); // Per sheila, not needed/used.
        quote.QuoteProducts             = new NSCProvisioning.QuoteProductType[]{}; 

        List<Quote_Product__c> products = [select Id, Notes__c, Solution_Provider_Product__c, ZProduct__c, 
                                                ZProduct__r.Name, ZProduct__r.InterfaceType__c, 
                                                ZProduct__r.ProductCategory__c, Amendment_Type__c, 
                                                ZProduct__r.zqu__ZuoraId__c, Action__c
                                            from Quote_Product__c 
                                            where Quote__c = :quoteId
                                            and (Action__c = /*'Add'*/'Activate' or 
                                                 Action__c = /*'Remove'*/'Deactivate' or
                                                 //Action__c = 'Renew Add' or 
                                                 Action__c = /*'Renew Remove'*/'Deactivate')];

        
        if(subType != 'Cancel Subscription' && (products == null || products.size() == 0)) { 
            throw new ProvisioningException('\n*************PROVISIONING CANCELLED*************\n' + 
                                            'This quote has no Add, Remove, Renew Add, or Renew Remove products ' + 
                                            'so it will not be sent to Pivotal for Provisioning');
        }
		//Fix SOQL Query inside for loop - Code Start
        Set<Id> solutionProductSet = new Set<Id>();
        for(Quote_Product__c product : products) {
            if(product.Solution_Provider_Product__c != null){
                solutionProductSet.add(product.Solution_Provider_Product__c);
            }
        }
        Map<Id,Solution_Provider_Product__c> vendorProductsMap = new Map<Id,Solution_Provider_Product__c>();
        for(Solution_Provider_Product__c vendorProduct :[select Certification_Date__c, Comments__c, Hosting_Type__c, Interface_Type__c, 
                                                         Internal_Status__c, Product_Manager__c, Name, Solution_Provider_Id__c, 
                                                         Software_Support_Type__c, Solution_Provider_Product_Category__c 
                                                         from Solution_Provider_Product__c where id In :solutionProductSet]){
                                                             vendorProductsMap.put(vendorProduct.Id,vendorProduct);   
                                                         }
        
		//Code End
        // Quote_Product__c records are only created when the user presses the "Done" button
        // Handle the quote products and the TPV products
        for(Quote_Product__c product : products) {
            NSCProvisioning.QuoteProductType qp = new NSCProvisioning.QuoteProductType(); 
            // qp.NetBookingCalculated; -- Deemed unnecessary. Users will look in EDW instead
            // qp.ProductContractValue; -- Deemed unnecessary. Users will look in EDW instead
            // qp.TrainingParticipants; -- Deemed unnecessary.
            qp.ID                       = product.Id; 
            qp.Notes                    = product.Notes__c;
            qp.ZProductID               = product.ZProduct__r.zqu__ZuoraId__c;
            qp.ReferenceDeactivate      = (product.Amendment_Type__c == 'RemoveProduct' || product.Action__c == /*'Remove'*/'Deactivate' || product.Action__c == /*'Renew Remove'*/'Deactivate'); // Set to true for deactivations.
            // Set to a ZProduct Id (which DIIG will translate) for deactivations.
            qp.ReferenceProjectProduct  = ((product.Amendment_Type__c == 'RemoveProduct' || product.Action__c == /*'Remove'*/'Deactivate' || product.Action__c == /*'Renew Remove'*/'Deactivate') ? product.ZProduct__c : null); 
            qp.Vendor                   = new NSCProvisioning.VendorType[]{};
            
            // Reasoning -> http://star.ncr.com/browse/DI_QI_AGIL-1829
            qp.UniqueProductId          = product.Id;

            // The product should have a TPV associated, which means we need to pass
            // both the Solution Provider Product (aka Vendor Product) *and* the 
            // Solution Provider itself in case it does not exist in the target system (Pivotal, for now).
            // The Vendor Product will be associated with this Vendor. See below. 
            if(product.Solution_Provider_Product__c != null) { 

                // Query for this vendor product -- most of this should be unnecessary now that we're 
                // gathering this data view the GetVendorDetails call below. Only Solution_Provider_Id__c 
                // sould be required.
               /* Solution_Provider_Product__c vendorProduct = 
                    [select Certification_Date__c, Comments__c, Hosting_Type__c, Interface_Type__c, 
                            Internal_Status__c, Product_Manager__c, Name, Solution_Provider_Id__c, 
                            Software_Support_Type__c, Solution_Provider_Product_Category__c 
                     from Solution_Provider_Product__c where id = :product.Solution_Provider_Product__c];
					*/
                Solution_Provider_Product__c vendorProduct;
                if(vendorProductsMap.containsKey(product.Solution_Provider_Product__c)){
                    vendorProduct = vendorProductsMap.get(product.Solution_Provider_Product__c);   
                }
                // Get the full vendor detail and the appropriate tpv product and contacts
                if(vendorProduct != null){
                    qp.Vendor.Add(GetVendorDetails(vendorProduct.Solution_Provider_Id__c, product.Solution_Provider_Product__c)); 
                }
            }
            

            quote.QuoteProducts.add(qp); 
            qp = null;
        }
        

        // REMOVED -- This is added to Quote_Product__c in duplicates instead. No need for this code. 
        // Quantities may need to be split into multiples 
        //List<zqu__QuoteRatePlan__c> plansWithQuantities = DuplicatesForQuote(quoteId); 

        // If we find quantities, convert them into duplicate records for Provisioning
        /*
        if(plansWithQuantities != null && plansWithQuantities.size() > 0) {
            // E.g.: Qty 6 -> 6 instances of a product
            DuplicateProducts(quote, plansWithQuantities); 
        }
        */


        
        
        
        /* TEST: We're going to stop looking at what shouldn't be, and only add on what should be at the end. 

        // Features are added to a different table and are queried by ID only. We need to ensure that features for these "invalid" products
        // don't end up sent to provisioning without their parent products. 
        List<Quote_Product__c> invalidProducts  = 
                                            [select Id, ZProduct__c, ZProduct__r.Name, ZProduct__r.InterfaceType__c, 
                                                ZProduct__r.zqu__ZuoraId__c
                                            from Quote_Product__c 
                                            where Quote__c = :quoteId
                                            and (Action__c = 'Update' or
                                                 Action__c = 'Renew Update' or
                                                 Action__c = 'Renew Unchanged')];
        
        system.debug('Found unusable products on the quote: ' + JSON.serializePretty(invalidProducts)); 
        

        // All features on the quote, including ones for Renewal Products that don't need to be sent to provisioning
        Set<zqu__QuoteProductFeature__c> features = [select zqu__FeatureZuoraId__c, zqu__FeatureName__c 
                                                        from zqu__QuoteProductFeature__c 
                                                        where zqu__Quote__c = :quoteId]; 
        
        system.debug('All features on the quote: ' + JSON.serializePretty(features)); 

        // Grab the list of Zuora Feature Ids so we can use this and the invalidProducts list above to remove features
        // before they go to provisioning. 
        Set<string> featureZuoraIds = new Set<string>(); 
        for(zqu__QuoteProductFeature__c feature : features) { 
            featureZuoraIds.add(feature.zqu__FeatureZuoraId__c); 
        }
        
        List<zqu__ZFeature__c> featureCatalog = [select id from zqu__ZFeature__c where zqu__ZuoraId__c in :featureZuoraIds]; 
        
        // Make an explicit list of ZProduct IDs for the query below
        List<Id> invalidProductIds = new List<Id>(); 
        for(Quote_Product__c invalidProduct : invalidProducts) { 
            invalidProductIds.add(invalidProduct.ZProduct__c);
        }
        
        // Use the invalid products id list and the included features to limit the list of products whose features should be removed
        List<zqu__ZProductFeature__c> productFeatures = [select Id, zqu__ZProduct__c, zqu__ZFeature__c 
                                                         from zqu__ZProductFeature__c 
                                                         where zqu__ZFeature__c in :featureCatalog
                                                         and zqu__ZProduct__c in :invalidProductIds];
        
        List<Id> productFeatureIds = new List<Id>(); 
        for(zqu__ZProductFeature__c f : productFeatures) { 
            productFeatureIds.add(f.zqu__ZFeature__c); 
        }        
        system.debug('Found parent products for quote features: ' + JSON.serializePretty(productFeatures)); 

        // Now find that limited list of features
        List<zqu__ZFeature__c> featuresToRemove = [select zqu__ZuoraId__c from zqu__ZFeature__c where Id in :productFeatureIds]; 
        system.debug('Found features to remove: ' + JSON.serializePretty(featuresToRemove));
        
        // Remove one feature per Id. Duplicates here are ok because they may be an overlap between two Products. 
        // E.g.: Add IB (set of features) and Remove Mobile Suite (different but overlapping set of features). In this
        //       case we wouldn't want to remove all features, because removing all features for Mobile Suite would also
        //       remove some features from IB, which we want to keep. 
        for(zqu__ZFeature__c remove : featuresToRemove) { 
            for (Integer i = 0; i < features.size(); i++) { 
                if(features[i].zqu__FeatureZuoraId__c == remove.zqu__ZuoraId__c) { 
                    features.remove(i); 
                    break; 
                }
            }
        }
        
        system.debug('Feature list after removal: ' + JSON.serializePretty(features)); 
        
        */
        
        // Find all the Products on the quote that we should add features for
        List<Id> zProductIds = new List<Id>(); 
        for(Quote_Product__c p : products) {
            if(p.Action__c == 'Activate'/*'Add' || p.Action__c == 'Renew Add'*/) {
                zProductIds.add(p.ZProduct__c);
            }
        }

        system.debug('Finding features for product Ids: ' + JSON.serializePretty(zProductIds));
        
        // ProductFeature ties everything together, so let's query that to determine which features should be included
        List<zqu__ZProductFeature__c> allFeatures = [select zqu__zFeature__c, zqu__ZProductFeatureFullName__c 
                                                     from zqu__ZProductFeature__c 
                                                     where zqu__ZProduct__c in :zProductIds];
        
        system.debug('Found features for products: ' + JSON.serializePretty(allFeatures)); 
                
        // Build a unique list so we can query zqu__ZFeature__c for the actual Zuora Ids that we need
        Set<Id> validFeatureIds = new Set<Id>(); 
        for(zqu__ZProductFeature__c f : allFeatures) {
            validFeatureIds.add(f.zqu__zFeature__c); 
        }
        
        // We need this additional query to get the Zuora IDs for the features. The ones in zqu__ZProductFeature__c aren't for Features.
        List<zqu__ZFeature__c> zFeatures = [select Id, zqu__ZuoraId__c, Name
                                            from zqu__ZFeature__c 
                                            where id in :validFeatureIds]; 
        
        system.debug('Final feature list with Zuora Ids:\n' + JSON.serializePretty(zFeatures));
        
        
        // Add Features so they look like Products. Proper mapping occurs in DIIG using the Zuora Id.
        // Duplicates at this point are not sent. 
        for(zqu__ZFeature__c feature : zFeatures) { 
            NSCProvisioning.QuoteProductType p = new NSCProvisioning.QuoteProductType(); 
            p.Id = feature.Id; 
            p.ZProductID = feature.zqu__ZuoraId__c;
            //boolean exists = false; 
            //for(NSCProvisioning.QuoteProductType existingProduct : quote.QuoteProducts) 
            //{ 
            //    if(existingProduct.ZProductId == p.ZProductID) { 
            //        exists = true; 
            //    }
            //}
            // If we make it through that loop without finding an existing feature, add it as a product
            //if(!exists) { 
                quote.QuoteProducts.add(p); 
            //}
        }


        if(subType == 'Cancel Subscription') { 
            NSCProvisioning.QuoteProductType qp = new NSCProvisioning.QuoteProductType(); 
            qp.Id = 'deactivateall'; 
            qp.Notes = 'This is a full-site deactivation (aka "Cancel Subscription" in Zuora). No real products are added.';
            qp.ReferenceDeactivate = true; 
            quote.QuoteProducts.add(qp); 
        }

        return quote;
    }
    
    /** 
    * @description Returns a NSCProvisioning.VendorType with a Vendor Product associated. This can be used for 
    * a Third Party Vendor (TPV), Data Processing Vendor (DPV), or a Service Bureau. 
    * @param vendorId The Salesforce Id for the Vendor
    * @param vendorProductId The Salesforce Id for the Vendor Product. NOTE: SOUP doesn't accept 
    *        products for Service Bureaus, so to quickly work around this the calling code will send
    *        any vendor product Id that's handy. 
    * @return A fully-built NSCProvisioning.VendorType object to send to SOUP 
    */
    public static NSCProvisioning.VendorType GetVendorDetails(string vendorId, string vendorProductId) { 
        // Return object
        NSCProvisioning.VendorType vendor = new NSCProvisioning.VendorType(); 

        // Composing objects
        NSCProvisioning.AddressType address                 = new NSCProvisioning.AddressType();
        NSCProvisioning.ContactType defaultAddOnSalesRep    = new NSCProvisioning.ContactType();
        NSCProvisioning.ContactType defaultCRM              = new NSCProvisioning.ContactType();
        NSCProvisioning.PhoneType phone                     = new NSCProvisioning.PhoneType();
        NSCProvisioning.VendorProductType vendorProduct     = new NSCProvisioning.VendorProductType();
        NSCProvisioning.VendorContactType vendorContact     = new NSCProvisioning.VendorContactType();

        // Find the vendor
        Solution_Provider__c vendorRecord = [select 
        s.Id
        , s.Parent_Solution_Provider_Id__c
        , s.Name
        , s.Solution_Provider_Number__c
        , s.Category__c
        , s.Address_1__c 
        , s.Address_2__c
        , s.City__c
        , s.State__c
        , s.Zip__c
        , s.Country__c
        , s.Phone__c
        , s.Fax__c
        , s.Website__c
        , (select Id, Address_1__c, Address_2__c, Cell__c, Country__c, City__c, Contact_Notes__c, 
                    Email__c, Extension__c, Fax__c, First_Name__c, Inactive__c, Job_Title__c, 
                    Last_Name__c, Phone__c, State__c, Zip__c, Key_Contact__c from Solution_Provider_Contact__r) 
        From Solution_Provider__c s
        where Id = :vendorId];
        
        phone.Work  = vendorRecord.Phone__c; 
        phone.Fax   = vendorRecord.Fax__c;

        address.Address1    = vendorRecord.Address_1__c; 
        address.Address2    = vendorRecord.Address_2__c; 
        address.City        = vendorRecord.City__c;
        address.State       = vendorRecord.State__c;
        address.Country     = 'US'; //vendorRecord.Country__c;
        address.State       = vendorRecord.State__c;
        address.Zip         = vendorRecord.Zip__c; 

        // Find the vendor products
        Solution_Provider_Product__c vp =  [select name
                                                    , Id
                                                    , Certification_Date__c
                                                    , Comments__c
                                                    , Hosting_Type__c
                                                    , Interface_Type__c
                                                    , Internal_Status__c
                                                    , Product_Manager__c
                                                    , Software_Support_Type__c
                                                    , Product_Type__c 
                                                    , (select Id, Available__c, Middleware__c, Interface_name__c from Solution_Provider_Product_Interfaces__r)
                                                    from Solution_Provider_Product__c where Id = :vendorProductId];
                                                    
        
        vendorProduct.SolutionProviderProductID     = vp.Id;
        vendorProduct.CertificationDate             = vp.Certification_Date__c;
        vendorProduct.Comments                      = vp.Comments__c;
        vendorProduct.FeeDetail                     = ''; // Field removed from NSC on 4/1 -- Not displayed in Pivotal UI
        vendorProduct.FeeStructure                  = ''; // Field removed from NSC on 4/1 -- Not displayed in Pivotal UI
        vendorProduct.HostingType                   = vp.Hosting_Type__c;
        vendorProduct.InterfaceType                 = vp.Interface_Type__c ;
        vendorProduct.InternalStatus                = vp.Internal_Status__c;
        vendorProduct.ProductName                   = vp.Name;
        vendorProduct.SoftwareSupport               = vp.Software_Support_Type__c; 
        vendorProduct.VendorProductType             = vp.Product_Type__c;

        // The account may have an interface associated. If so, we'll add it to Pivotal
        if(vp.Solution_Provider_Product_Interfaces__r.size() > 0)
        {
            vendorProduct.VendorProductInterface                    = new NSCProvisioning.VendorProductInterfaceType(); 
            vendorProduct.VendorProductInterface.Name               = vp.Solution_Provider_Product_Interfaces__r[0].Interface_name__c; // e.g. 'Online', 'Hybrid', or 'Batch'
            vendorProduct.VendorProductInterface.Available          = vp.Solution_Provider_Product_Interfaces__r[0].Available__c; 
            vendorProduct.VendorProductInterface.Middleware         = vp.Solution_Provider_Product_Interfaces__r[0].Middleware__c; 
        }

        // Vendor Product needs a Product Manager contact
        NSCProvisioning.ContactType productManager = new NSCProvisioning.ContactType();
        productManager.FirstName = vp.Product_Manager__c.split(' ')[0]; 
        productManager.LastName  = vp.Product_Manager__c.split(' ')[1]; 
        /* Sadly, this is not a relationship but a plain-text field. Cross your fingers!
        * Also, DIIG only accepts First/Last name, so there's no need to send more on employee records. 
        productManager.EmailURI = productManager.FirstName + '.' + productManager.LastName + '@ncr.com'; 
        productManager.Phone = new NSCProvisioning.PhoneType();
        productManager.Phone.Mobile = vendorProductManager.Cell__c;
        productManager.Phone.Work = vendorProductManager.Phone__c; 
        productManager.JobPosition = vendorProductManager.Job_Title__c;
        productManager.Address = new NSCProvisioning.AddressType[]{}; 
        productManager.Address[0] = new NSCProvisioning.AddressType(); 
        productManager.Address[0].Address1 = vendorProductManager.Address_1__c;
        productManager.Address[0].Address2 = vendorProductManager.Address_2__c;
        productManager.Address[0].City = vendorProductManager.City__c;
        productManager.Address[0].State = vendorProductManager.City__c;
        productManager.Address[0].Zip = vendorProductManager.Zip__c;
        */
        vendorProduct.ProductManager = productManager; 
        
        // There may be many here. SOUP Contract only allows for one.
        if(vendorRecord.Solution_Provider_Contact__r.size() > 0) { 
            Solution_Provider_Contact__c contact            = vendorRecord.Solution_Provider_Contact__r[0];
            vendorContact.SolutionProviderContactID         = contact.Id; 
            vendorContact.Inactive                          = contact.Inactive__c;
            vendorContact.KeyContact                        = contact.Key_Contact__c;
            vendorContact.ContactDetails                    = new NSCProvisioning.ContactType();
            vendorContact.ContactDetails.Type_x             = 'tbd';
            vendorContact.ContactDetails.FirstName          = contact.First_Name__c;
            vendorContact.ContactDetails.LastName           = contact.Last_Name__c;
            vendorContact.ContactDetails.Department         = ''; // Not in SFDC 
            vendorContact.ContactDetails.JobPosition        = contact.Job_Title__c;
            vendorContact.ContactDetails.EmailURI           = contact.Email__c;
            vendorContact.ContactDetails.Phone              = new NSCProvisioning.PhoneType();
            vendorContact.ContactDetails.Phone.Mobile       = contact.Cell__c; 
            vendorContact.ContactDetails.Phone.Fax          = contact.Fax__c; 
            vendorContact.ContactDetails.Phone.Extension    = contact.Extension__c; 
            vendorContact.ContactDetails.Phone.Work         = contact.Phone__c; 
            // Handle address array
            vendorContact.ContactDetails.Address            = new NSCProvisioning.AddressType[]{};
            NSCProvisioning.AddressType addr                = new NSCProvisioning.AddressType(); 
            addr.Address1   = contact.Address_1__c;
            addr.Address2   = contact.Address_2__c;
            addr.City       = contact.City__c;
            addr.State      = contact.State__c;
            addr.Zip        = contact.Zip__c;
            addr.Country    = 'US'; //contact.Country__c;
            addr.Type_x     = 'Billing';
            vendorContact.ContactDetails.Address.add(addr);
        }
        
        

        // Bring it all together
        vendor.Category                     = vendorRecord.Category__c;
        //vendor.DefaultSupportTeam         = ''; // Per Chris Embry and Keith Hartshorn this is no longer needed
        vendor.VendorName                   = vendorRecord.Name;
        vendor.VendorNumber                 = vendorRecord.Solution_Provider_Number__c;
        vendor.VendorWebsiteURL             = vendorRecord.Website__c;
        vendor.VendorProducts               = vendorProduct;
        vendor.vendorContacts               = vendorContact;
        vendor.Phone                        = phone;
        vendor.Address                      = address;
        vendor.SolutionProviderID           = vendorRecord.Id; 
        vendor.ParentSolutionProviderID     = vendorRecord.Parent_Solution_Provider_Id__c; 

        return vendor; 
    }


    // Zuora uses Quantities, Pivotal uses Multiple line items to represent quantities.
    // This method helps identify rate plans with quantities so that the products can be
    // properly broken into Dupes before sending along to Pivotal
    /*** THIS WAS MOVED TO PROVISIONING'S QUOTE_PRODUCT__C OBJECT
    public static List<zqu__QuoteRatePlan__c> DuplicatesForQuote(string quoteId) { 
        List<zqu__QuoteRatePlan__c> plans = 
            [Select Id, Name, zqu__ProductRatePlanZuoraId__c, zqu__QuoteProductName__c, zqu__QuoteRatePlanZuoraId__c, 
                    zqu__Quote__c,  zqu__Parent__c, zqu__ProductRatePlan__c, zqu__Product__c, zqu__ProductRatePlan__r.zqu__Product__c, zqu__QuoteRatePlanFullName__c, 
                    zqu__Product__r.Id, (Select Id, zqu__Quantity__c from zqu__Quote_Rate_Plan_Charges__r where zqu__Quantity__c > 1) 
                    from zqu__QuoteRatePlan__c where zqu__Quote__c = :quoteId order by name];

        List<zqu__QuoteRatePlan__c> hasDuplicates = new List<zqu__QuoteRatePlan__c>(); 
        for(zqu__QuoteRatePlan__c plan : plans) { 
            system.debug('Product: ' + plan.zqu__ProductRatePlan__r.zqu__Product__c);
            if(plan.zqu__Quote_Rate_Plan_Charges__r.size() > 0) 
            { 
                for(zqu__QuoteRatePlanCharge__c charge : plan.zqu__Quote_Rate_Plan_Charges__r) { 
                    if (charge.zqu__Quantity__c > 1) { 
                        hasDuplicates.add(plan); 
                    }
                }
            }
        }
        system.debug('Found ' + hasDuplicates.size() + ' plans with duplicates'); 
        system.debug(JSON.serializePretty(hasDuplicates)); 

        return hasDuplicates; 
    }
    
    public static NSCProvisioning.QuoteType DuplicateProducts(NSCProvisioning.QuoteType quote, List<zqu__QuoteRatePlan__c> duplicatePlans)  
    {
        // For each rate plan that has a quantity...
        for(zqu__QuoteRatePlan__c ratePlan : duplicatePlans) { 
            // ...Look for a Quote Product in our already-built collection...
            for(NSCProvisioning.QuoteProductType product : quote.QuoteProducts) { 
                // ... and find the product that was on the Quote. 
                system.debug('Comparing ' + product.ZProductID + ' to ' + ratePlan.zqu__ProductRatePlan__r.zqu__Product__c);
                if(product.ZProductId == ratePlan.zqu__ProductRatePlan__r.zqu__Product__c) { 
                    // Find all the charges for the rate plan we're looking at to determine quantity
                    for(zqu__QuoteRatePlanCharge__c charge : ratePlan.zqu__Quote_Rate_Plan_Charges__r)
                    {
                        // Add copies of the product
                        for(Integer i = 0; i < charge.zqu__Quantity__c; i++) { 
                            quote.QuoteProducts.add(product); 
                        }
                    }
                }
            }
        }
        return quote;
    }
    */

    /**
    * @description Aggregates all notes for a given parent into a list of 
    * notes in the format: 
    * 
    * ----------------------------------------
    * Title: <title from table>
    * ----------------------------------------
    * Body: <body from table> 
    * <Optionally multiline>
    * <Optionally multiline>
    * ----------------------------------------
    * Modified: <date from table>
    * ----------------------------------------
    * <newline> 
    * <newline> 
    * <newline> 
    * <newline> 
    * @param parentId The Salesforce Id of the object whose notes should be aggregated
    * @return A string with the format shown above
    */
    public static string AggregateNotes(string parentId) { 
        String notes = ''; 
        String divider = '----------------------------------------';
        List<Note> entries = [select Title, Body, LastModifiedDate from Note where ParentId = :parentId order by LastModifiedDate desc]; 
        
        if(entries == null || entries.size() == 0) return notes; 
        
        for(Note note : entries) { 
            if(note.Body != null) note.Body = note.Body.remove('\r'); 
            notes += divider + '\nTitle: ' + note.Title + '\n' + divider + '\nBody: ' + note.Body + '\n' + divider + 
            '\nModified: ' + note.LastModifiedDate.format() + '\n' + divider + '\n\n\n\n'; 
        }
        
        return notes;
    }
}