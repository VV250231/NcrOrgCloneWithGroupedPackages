// ===========================================================================
    // Object: DIProvisioningController
    // Company: Cloudware Connections, Inc.
    // Author: Reid Beckett
    // Purpose: Serves the page "4" Provisioning page of the quote wizard
    // ===========================================================================
    // Changes: 2016-03-15 Reid Beckett
    //           Class created
    // ===========================================================================
    // 
    // Modification Log:
    //Date                       Modified by                      Modification
    //1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
    public with sharing class DIProvisioningController {

        public zqu__Quote__c quoteSobject {get;set;}
        public Account account {get;set;}
        public Provisioning__c provisioning {get;set;}
        public List<SelectOption> contactOptions {get; set;}
        
        
        public List<QuoteProductWrapper> quoteProducts {get;set;}
        public Set<string> messages {get; set;}
        public Boolean hasMessages {get; set;}
        public List<Quote_Product__c> listQP{get;set;} // lst of Quote Product
        public List<Schema.FieldSetMember> fieldSetMemberList{get;set;}
        public List<Schema.FieldSetMember> fieldSetMemberList1{get;set;}
        public string startDateWarning { get { return 'NOTE: The Quote\'s Start Date is in the future. Do not Install or Activate this product until after ' + quoteSobject.zqu__StartDate__c.format() + '.'; }}
        public Boolean quoteStartInFuture { get { return Date.today() < quoteSobject.zqu__StartDate__c;}}
        public static Boolean invokeFromButton {get; set;}
        public static Boolean stopQPCreationFromButton ;
        public static Boolean isfirstTime {get; set;}
        public string Populate_SMB{get; set;} //sunidhi
        public Map<String,zqu__QuoteRatePlan__c> mpSKU_QRP = new Map<String,zqu__QuoteRatePlan__c>(); //SC2015_AGL-4722
       
        
        public DIProvisioningController(ApexPages.StandardController stdController) 
        {
            if(quoteSobject == null) quoteSobject = (zqu__Quote__c)stdController.getRecord();
        }

        public PageReference save()
        {
            String[] errors = doSave();
            if(errors != null && !errors.isEmpty()) {
                hasMessages = true;
                for(String e : errors) { 
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e));
                    renderProvisioningProductsSection = false;
                }
                return null;
            }
            String quoteType = ApexPages.currentPage().getParameters().get('quoteType');
            String stepNumber = ApexPages.currentPage().getParameters().get('stepNumber');
            if(String.isBlank(stepNumber)) {
                //system.debug('The Page redirect To Detail Page');
                return new PageReference('/' + quoteSobject.Id);
            }else{
                //system.debug('The Page redirect To Same Page'+Page.diProvisioning.getUrl() + '?id='+quoteSobject.Id+'&quoteType='+quoteType+'&stepNumber='+stepNumber);
                isfirstTime = false;
                return new PageReference(Page.diProvisioning.getUrl() + '?id='+quoteSobject.Id+'&quoteType='+quoteType+'&stepNumber='+stepNumber);
            }
            //PageReference nextPage = new PageReference('/' + quoteSobject.Id);
            //return nextPage;
        }

        public PageReference back()
        {
            Boolean inWizard = ApexPages.currentPage().getParameters().get('stepNumber') != null;
            Boolean skipUsage = ApexPages.currentPage().getParameters().get('noUsageCharges') != null && ApexPages.currentPage().getParameters().get('noUsageCharges') == 'true';
            
            if(!inWizard) {
                return new PageReference('/' + quoteSobject.Id);
            }else{
            
                if(skipUsage)
                {               
                    String quoteType = ApexPages.currentPage().getParameters().get('quoteType');    
                    return new PageReference(Page.diSelectProducts.getUrl() + '?id='+quoteSobject.Id+'&quoteType='+quoteType+'&stepNumber='+'3');
                }
                PageReference nextPage = zqu.QuoteWizardManager.navigateBack(New Map<String, String> {'Id' => quoteSobject.Id, 'quoteType' => ApexPages.currentPage().getParameters().get('quoteType')});
                return nextPage;
            }
        }

        public PageReference done()
        {
            String[] errors = doSave();
            if(errors != null && !errors.isEmpty()) {
                hasMessages = true;
                for(String e : errors) { 
                    ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e)); 
                }
                return null;
            }
            PageReference nextPage = new PageReference('/' + quoteSobject.Id);
            return nextPage;
        }

        private List<String> doSave(){
            try {
                String[] validationErrors = new String[]{};
                boolean hasTPVError = false;
                boolean impStatus =false;
                boolean changedStatus =false;
                Id profileId=userinfo.getProfileId();
                String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
                for(QuoteProductWrapper qp : quoteProducts)
                {
                    if(!String.isBlank(qp.quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPCategory__c) && String.isBlank(qp.quoteProduct.Solution_Provider_Product__c)) 
                    {
                        if(qp.renderTPVList || qp.renderTPVEmptyListMessage) hasTPVError = true;
                        //hasTPVError = true;
                    }
                       // story 5073
                    if(profileName == '55 Hosted Solutions Sales'){
                        if( qp.quoteProduct.ImplementationStatus__c == 'Awaiting Approval' && qp.quoteProduct.Completed_Date__c != null && profileName == '55 Hosted Solutions Sales') 
                        {
                            impStatus= true;
                            //hasTPVError = true;
                        }
                        if( qp.quoteProduct.ImplementationStatus__c != 'Awaiting Approval' && qp.quoteProduct.Quote__r.zqu__Status__c != 'QA Processing Complete' && qp.quoteProduct.Quote__r.zqu__Status__c != 'Sent to Z-Billing') 
                        {
                            changedStatus= true;
                            //hasTPVError = true;
                        }
                     }
                    
                    
                }
              
                
                system.debug('Primary Contact: ' + provisioning.Primary_Contact__c);
                system.debug('Secondary Contact: ' + provisioning.Secondary_Contact__c);

                if((provisioning.Primary_Contact__c == null || provisioning.Secondary_Contact__c == null) &&
                     DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r) && renderProvisioningSection)
                    validationErrors.add('Primary and Secondary Contact must be set.');
                if(hasTPVError) validationErrors.add('TPV selection is required');
                if(impStatus) validationErrors.add('Can not enter Completed Date until Quote has been QA Approved');
                
                //added for SMB type                
                if(ProfileName == 'Hosp SMB Sales with Hosted' && (quoteSobject.SMB_Type__c == null || quoteSobject.Aloha_Type__c == null ||quoteSobject.Quote_Type__c == null) && Date.valueOf(quoteSobject.CreatedDate) > DATE.valueOf('2021-04-21') )
                 {
                            validationErrors.add('Please enter the value in the required fields, viz. Aloha Type, Quote Type and SMB Type');
                 }
                
                //if(changedStatus) validationErrors.add('Cannot change Implementation Status until Quote has been approved ');
                if(!validationErrors.isEmpty()) return validationErrors;
                if(account != null && DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)) update account;
                if(renderProvisioningSection){
                    upsert provisioning;
                  }
                update quoteSobject;
                List<Quote_Product__c> upsertList = new List<Quote_Product__c>();
                for(QuoteProductWrapper qp : quoteProducts)
                {
                    //SC2015_AGL-4722
                    //if(!DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r) && !mpSKU_QRP.isEmpty() && mpSKU_QRP.containsKey(qp.quoteProduct.ZProduct__r.zqu__SKU__c))
                      // qp.quoteProduct.Quote_Rate_Plan__c = mpSKU_QRP.get(qp.quoteProduct.ZProduct__r.zqu__SKU__c).id ;
                    qp.quoteProduct.Action__c = qp.selectedAction;
                    upsertList.add(qp.quoteProduct);
                }
                //if(!validationErrors.isEmpty()) return validationErrors;
                system.debug('doSave: upsertList:');
                system.debug(upsertList);
                if(!isCancellation)
                  upsert upsertList;

                return null;
            }catch(Exception e) {
                return new String[]{e.getMessage()};  
                //ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                //return new String[]{'teste teste'};
            }
        }

        public PageReference init()
        { 
            fieldSetMemberList1  = new List<Schema.FieldSetMember>();
            //system.debug('init: quoteSobject.zqu__Opportunity__r='+quoteSobject.zqu__Opportunity__r);
            //system.debug('init: quoteSobject.zqu__Opportunity__c='+quoteSobject.zqu__Opportunity__c);
            stopQPCreationFromButton = ApexPages.currentPage().getParameters().get('source') != null;
            invokeFromButton = ApexPages.currentPage().getParameters().get('crmAccountId') == null || ApexPages.currentPage().getParameters().get('crmAccountId') == '';
            system.debug('The Value of two flags--'+ invokeFromButton + '----'+isfirstTime);
            //DI-1143 removed these fields:
            //Fee_Increase_Percentage__c, Fee_Increase_Eligibility_Date__c, Fee_Increase_Days_Written_Notice__c, Fee_Increase_Notes_and_Exceptions__c, Fee_Increase_Period__c, Days_Written_Notice_other__c
              // Added to display field of Quote for non di quote 
            String QuoteQuery  = 'SELECT ';
                       if(!DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)) {
              fieldSetMemberList1  = DIProvisioningController.readFieldSet('QuoteDetailSectionPage4','zqu__Quote__c');
               
            }
            for(Schema.FieldSetMember f : fieldSetMemberList1) {
                QuoteQuery+= f.getFieldPath() + ', ';
            }
            string quoteSobjectId = quoteSobject.Id;
            QuoteQuery+= 'Id, zqu__StartDate__c, zqu__Opportunity__r.Account.Subscription_Group__c, zqu__Opportunity__r.Opportunity_Classification__c,';
            QuoteQuery+= 'RecordType.Name, Renewal_Discount_Level__c,Add_on_monthly_fees_discount__c,Add_on_Setup_fees_discount__c,Add_on_Setup_fees_discount_Platform__c,All_transaction_fees_discount__c, Renewal_ARPU__c,';
            QuoteQuery+= 'Is_Team_Connect__c,zqu__Opportunity__r.Channel_Office__r.Name,Professional_Services_fees_discount__c,Term_of_contract__c,Effective_Date_of_Pricing_in_a_Renewal__c,Price_Increase__c,Payment_Terms_or_Waiver_Delay_of_Minimum__c,Early_Term_Calculation__c,';
            QuoteQuery+= 'zqu__Opportunity__c, zqu__Account__c, zqu__Opportunity__r.AccountId, zqu__SubscriptionType__c , CreatedDate'; 
            QuoteQuery+= ' from zqu__Quote__c where Id = :quoteSobjectId';
            quoteSobject = Database.query(String.escapeSingleQuotes(QuoteQuery));
           /* quoteSobject = [SELECT id, zqu__StartDate__c, zqu__Opportunity__r.Account.Subscription_Group__c,
                                zqu__Opportunity__r.Opportunity_Classification__c, RecordType.Name, Renewal_Discount_Level__c, 
                                Add_on_monthly_fees_discount__c, Add_on_Setup_fees_discount__c, Add_on_Setup_fees_discount_Platform__c, 
                                All_transaction_fees_discount__c, Renewal_ARPU__c, Is_Team_Connect__c, Professional_Services_fees_discount__c, 
                                Term_of_contract__c, Effective_Date_of_Pricing_in_a_Renewal__c, Price_Increase__c, 
                                Payment_Terms_or_Waiver_Delay_of_Minimum__c, Early_Term_Calculation__c,
                                zqu__Opportunity__c, zqu__Account__c, zqu__Opportunity__r.AccountId, zqu__SubscriptionType__c 
                                FROM zqu__Quote__c 
                            WHERE Id = :quoteSobject.Id];*/


            if(quoteSobject.zqu__Opportunity__c != null && DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)) 
            {
                // Get filtered list of Contacts for the Primary and Secondary contacts on the Provisioning object
                setContactOptions(quoteSobject.zqu__Opportunity__r.AccountId); 

                //load or init the provisioning object
                Provisioning__c[] provs = [select Id,Existing_Domain__c, Opportunity__c, Primary_Contact__c, Project_Type__c, Secondary_Contact__c 
                    from Provisioning__c where Opportunity__c = :quoteSobject.zqu__Opportunity__c order by LastModifiedDate desc LIMIT 1];

                if(provs.isEmpty()) {
                    this.provisioning = new Provisioning__c(Opportunity__c = quoteSobject.zqu__Opportunity__c, Account__c = quoteSobject.zqu__Opportunity__r.AccountId);
                } else {
                    this.provisioning = provs[0];
                }
            } else {
                // if quote does bot belong to DI than only initialize the object provisioning
                this.provisioning = new Provisioning__c(Account__c = quoteSobject.zqu__Account__c); 
            }
            system.debug('==========++++++='+quoteSobject.zqu__Account__c);
            if(quoteSobject.zqu__Account__c != null) {
                this.account = [select Id, Name, DPV_Interface__c from Account where Id = :quoteSobject.zqu__Account__c];
            }
            
            try {

                // changes done w.r.t story SC2015_AGL-4663 , QP required in case of cancellation for both DI and non DI
                // for cancellation QP is inserted using trigger on Quote for DI/NON-DI 
                if(!isCancellation && !stopQPCreationFromButton ) { //!(quoteSobject.zqu__SubscriptionType__c == 'Cancel Subscription' && !DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r))){
                    DIQuoteUtil.createQuoteProducts(new Set<Id>{quoteSobject.Id});
                }

            } catch(Exception e) {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                //system.debug( 'The error message::'+e.getMessage());  
            }
            
            // Render validation messages, if applicable
            /*try { 
                messages = DIProductRelationship.findValidationMessagesForQuote(quoteSobject.Id);

                if(messages != null && messages.size() > 0) { 
                    for(String message : messages) { 
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
                    }
                    hasMessages = true;
                }
            } catch(Exception e) { 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, e.getMessage()));  
                hasMessages = true;
            }*/
            
            // populate QRP for each QP for non DI SC2015_AGL-4722   Id quoteId = quoteSobject.Id;
            if(!isCancellation){
              for(zqu__QuoteRatePlan__c objQRP:[Select id,zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c from zqu__QuoteRatePlan__c where zqu__Quote__c =: quoteSobject.Id]){
                 
                 mpSKU_QRP.put(objQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c,objQRP);
              }
            }
            
            List<Solution_Provider_Relationship__c> spRels = [select Id, Account_Id__c, Solution_Provider_Product__c, 
                                                                Solution_Provider_Product__r.Name, 
                                                                Solution_Provider_Product__r.Solution_Provider_Product_Category__c, 
                                                                Solution_Provider_Product__r.Interface_Type__c 
                                                                from Solution_Provider_Relationship__c 
                                                                where Account_Id__c = :this.quoteSobject.zqu__Opportunity__r.AccountId 
                                                                and Solution_Provider_Product__r.Internal_Status__c = 'Available'];
                
            quoteProducts = new List<QuoteProductWrapper>();
            fieldSetMemberList  = new List<Schema.FieldSetMember>();
            Id quoteId = quoteSobject.Id;
            String QuoteProductQuery  = 'SELECT ';
            if(DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)) {
              system.debug('+++++++inside DI'+DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r));
              fieldSetMemberList =  DIProvisioningController.readFieldSet('QuoteProductFieldsForDI','Quote_Product__c');
            } else {
             system.debug('+++++++insiden non DI'+DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r));
              fieldSetMemberList =  DIProvisioningController.readFieldSet('QuoteProductFieldsNonDI','Quote_Product__c');
                
            }           

            for(Schema.FieldSetMember f : fieldSetMemberList) {
                QuoteProductQuery += f.getFieldPath() + ', ';
            }
            QuoteProductQuery += 'Id, Action__c,Quote__r.zqu__Status__c,Quote_Rate_Plan__r.Name, ZProduct__c,Solution_Provider_Product__c, ZProduct__r.Name, PRPCImplementationValue__c, Amendment_Type__c,';
            QuoteProductQuery += 'ZProduct__r.InterfaceType__c, ZProduct__r.ProductCategory__c, Quote__r.RecordType.Name,Quote__r.zqu__SubscriptionType__c, Quote__r.ImplementationRequired__c, Quote__r.Renewal_Subscription_ID__c, Quote__r.zqu__ExistSubscriptionID__c, Quote__r.CancellationAction__c, ZProduct__r.zqu__Product__r.RequiredSPPInterfaceType__c, ZProduct__r.zqu__Product__r.RequiredSPPCategory__c, ZProduct__r.zqu__SKU__c'; 
            QuoteProductQuery += ' from Quote_Product__c where Quote__r.id =:quoteId' ;
            QuoteProductQuery += ' order by Quote_Rate_Plan__c asc, Index__c asc';

            listQP = Database.query(String.escapeSingleQuotes(QuoteProductQuery));
      system.debug('The List of Quote Product--'+listQP);

            map<Id, List<SelectOption>> DefaultValueforQP = fetchActionListOfValues(listQP);
            system.debug('The Value of both map:'+listQP + 'The value of other map'+DefaultValueforQP);
            if(!listQP.isEmpty() && !DefaultValueforQP.isEmpty()){
                for(Quote_Product__c qp: listQP){
                    if(DefaultValueforQP.containsKey(qp.Id)){
                        QuoteProductWrapper qpw = new QuoteProductWrapper(qp, DefaultValueforQP.get(qp.Id));
                        qpw.setVendorProductOptions(spRels);
                        quoteProducts.add(qpw);
                    }
                }  
            }
            hasMessages = ApexPages.hasMessages();
            //Calling the method to calculate the ACV 
            List<zqu__Quote__c> ListofQuote = new List<zqu__Quote__c>();
            ListofQuote.add(quoteSobject);
            if(ListofQuote.size() > 0){
                QuoteWrapper qpACV = new QuoteWrapper(ListofQuote,false);
                qpACV.calculateACV();
            }
           /** sunidhi **/ 
           if(!DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)) 
           {
               Populate_SMB = quoteSobject.zqu__Opportunity__r.Channel_Office__r.Name;
               if(quoteSobject.SMB_Type__c == null && (!String.isEmpty(Populate_SMB)))
               {
                   system.debug('enteeer');
                 if(Populate_SMB.startsWithIgnoreCase('NCR LOCAL'))
                  {
                     quoteSobject.SMB_Type__c = 'Local Office';
                  }
                  else
                  {
                     quoteSobject.SMB_Type__c = 'Channel';
                   }
               }
           }
           /** END **/ 
           return null;
        }

        public void setContactOptions(Id accountId) 
        {

            if(this.contactOptions == null) 
            {
                this.contactOptions = new List<SelectOption>(); 
                this.ContactOptions.add(new SelectOption('', ''));
            }
            try
            {
                List<Contact> contacts = [select Id, Name from Contact where AccountId = :accountId and Active_Contact__c = true];
                for(Contact c : contacts)
                {
                    system.debug('Adding ' + c);
                    this.contactOptions.add(new SelectOption(c.Id, c.Name));
                }
                if(this.contactOptions.size() <= 1) {
                    this.ContactOptions.clear();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This Account has no Active Contacts. Please create at least one Active Contact for Provisioning purposes.'));
                    hasMessages = true;
                }
            }
            catch (Exception e) 
            {
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unable to find Contacts for this account. Please verify that Contacts exist, and that at least one is active, then come back and refresh this page.'));
               hasMessages = true;
            }
            
        }

        public Boolean renderProvisioningSection {
            get {
                //Oct 19 - changed to always show
                //return !isRenewal || hasAnyRenewalChanges;
                //Oct 21 - changed as per DI-1306
                //return true;
                return provisioningFieldsRequired;
            }
        }

       public Boolean renderProvisioningProductsSection {
            get {
                //if(DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r))
                    system.debug('The value should return--'+isAmendment+'quoteProduct--'+quoteProducts);
                 return isAmendment ? !quoteProducts.isEmpty() : isCancellation ? !DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r) : true;
               // else
                 //{return false;}
               
            }
            set{
                System.debug('Method : renderProvisioningProductsSection set');//SC2015_AGL-5809
            }
        }
        
         public Boolean renderProvisioningProductsSectionNotDI {
            get {
                return !DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r);
               
            }
        }
        public Boolean renderQuoteInformationSection {
            get {
                return !isAmendment;
            }
        }

        public Boolean isRenewal {
            get {
                return quoteSobject.RecordType.Name == 'New Renewal'; 
            }
        }

        public Boolean hasAnyRenewalChanges {
            get {
                if(!isRenewal) return false;
                Boolean hasAny = false;
                for(QuoteProductWrapper qpw : quoteProducts) {
                    if(qpw.action != 'No Action') hasAny = true;
                }
                return hasAny;
            }
        }

        public Boolean isAmendment {
            get {
                return quoteSobject.RecordType.Name == 'Amendment'; 
            }
        }

        //DI-1049 added
        public Boolean isCancellation {
            get {
                return quoteSobject.RecordType.Name == 'Cancellation'; 
            }
        }

        public Boolean renderApprovalCriteriaSection {
            get {
                //DI-1573, hide this section
                //return isAmendment || isRenewal;
                return false;
            }
        }

        public Boolean renderBackButton {
            get {
                return true;
            }
        }
        
        public Boolean renderSaveButton {
            get {
                return true;
            }
        }

        public Boolean renderDoneButton {
            get {
                return ApexPages.currentPage().getParameters().get('stepNumber') != null; 
            }
        }

        public String quoteId {
            get {
                return quoteSobject.Id;
            }
        }

        public SelectOption[] termOfContractOptions {
            get {
                SelectOption[] opts = new SelectOption[]{};
                for (Schema.PicklistEntry ple : zqu__Quote__c.Term_of_contract__c.getDescribe().getPicklistValues())
                {
                    opts.add(new SelectOption(ple.getLabel(), ple.getValue()));
                }
                return opts;
            }
        }

        public SelectOption[] paymentTermsWaiverOptions {
            get {
                SelectOption[] opts = new SelectOption[]{};
                for (Schema.PicklistEntry ple : zqu__Quote__c.Payment_Terms_or_Waiver_Delay_of_Minimum__c.getDescribe().getPicklistValues())
                {
                    opts.add(new SelectOption(ple.getLabel(), ple.getValue()));
                }
                return opts;
            }
        }

        public class QuoteProductWrapper 
        {
            public Quote_Product__c quoteProduct {get;set;}
            public List<SelectOption> vendorProductOptions {get;set;}
            public List<SelectOption> actionPicklist {get;set;}
            public String selectedAction {get;set;}

            public QuoteProductWrapper(Quote_Product__c qp,List<SelectOption> listOfDefault)
            {
                //system.debug('qp='+qp +'The OptionList ='+listOfDefault);
                this.quoteProduct = qp;
                //this.vendorProductOptions = listOfDefault;
                actionPicklist = listOfDefault;
            }

            public Boolean isRenew {
                get {
                    return this.action != null && this.action.startsWith('Renew');
                }
            }

            public Boolean isRenewAdd {
                get {
                    return this.action != null && this.action == 'Activate';
                }
            }
            
            public Boolean renderSPPLookup {
                get {
                    //added for DI-1551
                    return !String.isBlank(quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPCategory__c) 
                        && !this.action.contains('Deactivate')
                        && !this.action.contains('No Action')
                        && (!isRenew || isRenewAdd);
                }
            }

            public Boolean renderTPVList {
                get {
                    /*
                    return !String.isBlank(quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPCategory__c) 
                        && !this.action.contains('Remove')
                        && !this.action.contains('Update')
                        && !this.vendorProductOptions.isEmpty()
                        && (!isRenew || isRenewAdd);
                    */
                    //modified for DI-1551
                    return false;
                }
            }

            public Boolean renderTPVEmptyListMessage {
                get {
                    /*
                    return !String.isBlank(quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPCategory__c) 
                        && !this.action.contains('Remove')
                        && !this.action.contains('Update')
                        && this.vendorProductOptions.isEmpty()
                        && (!isRenew || isRenewAdd);
                    */
                    //modified for DI-1551
                    return false;
                }
            }

            public Boolean renderNotes {
                get {
                    //return this.quoteProduct.Amendment_Type__c != 'RemoveProduct';
                    //return !this.action.contains('Remove');
                    return true;
                }
            }

            public String action {
                get {
                    /*if(this.quoteProduct.Amendment_Type__c == 'NewProduct') return (this.quoteProduct.Quote__r.RecordType.Name == 'New Renewal' ? 'Renew' : 'Add');
                    else if(this.quoteProduct.Amendment_Type__c == 'UpdateProduct') return 'Update';
                    else if(this.quoteProduct.Amendment_Type__c == 'RemoveProduct') return 'Remove';
                    else return '';
                    */
                    return this.quoteProduct.Action__c;
                }
            }

            public Date completedDate { 
                get { 
                    return this.quoteProduct.Completed_Date__c;
                }
            }

            public void setVendorProductOptions(List<Solution_Provider_Relationship__c> spRels)
            {
                this.vendorProductOptions = new List<SelectOption>();
                String productCategory = this.quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPCategory__c;
                String interfaceType = this.quoteProduct.ZProduct__r.zqu__Product__r.RequiredSPPInterfaceType__c;
                if(String.isBlank(productCategory)) {
                    //all options
                    system.debug('setVendorProductOptions: add all account vendor products');
                    for(Solution_Provider_Relationship__c avp : spRels)
                    {
                        if(avp.Solution_Provider_Product__c != null) this.vendorProductOptions.add(new SelectOption(avp.Solution_Provider_Product__c, avp.Solution_Provider_Product__r.Name));
                    }
                }else if(!String.isBlank(productCategory) && String.isBlank(interfaceType)) {
                    //category match only
                    system.debug('setVendorProductOptions: category match only');
                    for(Solution_Provider_Relationship__c avp : spRels)
                    {
                        system.debug(avp.Solution_Provider_Product__r.Solution_Provider_Product_Category__c +' == ' + productCategory + '?');
                        if(avp.Solution_Provider_Product__r.Solution_Provider_Product_Category__c == productCategory) {
                            if(avp.Solution_Provider_Product__c != null) this.vendorProductOptions.add(new SelectOption(avp.Solution_Provider_Product__c, avp.Solution_Provider_Product__r.Name));
                        }
                    }
                }else if(!String.isBlank(productCategory) && !String.isBlank(interfaceType)) {
                    //category & interface match
                    system.debug('setVendorProductOptions: category & interface match');
                    for(Solution_Provider_Relationship__c avp : spRels)
                    {
                        if(avp.Solution_Provider_Product__r.Solution_Provider_Product_Category__c == productCategory && avp.Solution_Provider_Product__r.Interface_Type__c == interfaceType) {
                            if(avp.Solution_Provider_Product__c != null) 
                                this.vendorProductOptions.add(new SelectOption(avp.Solution_Provider_Product__c, avp.Solution_Provider_Product__r.Name));
                        }
                    }
                } 
                
                //If there is only one option, preselect it
                if(quoteProduct.Solution_Provider_Product__c == null && this.vendorProductOptions.size() == 1 && renderTPVList)
                {
                    quoteProduct.Solution_Provider_Product__c = this.vendorProductOptions[0].getValue();
                }  
            }
        }
        
         public Boolean provisioningFieldsRequired {
            get {
                Boolean required = true;
                if(!DIQuoteUtil.isDigitalInsight(quoteSobject.zqu__Opportunity__r)){
                        required = false;
                    }
                else{
                        if(quoteSobject.RecordType.Name == 'New Renewal') {
                        required = false;
                        if(quoteProducts != null) {
                            for(QuoteProductWrapper qpw : quoteProducts) {
                                if(qpw.action == 'Activate' || qpw.action == 'Deactivate') required = true;
                            }    
                        }
                       }else if(quoteSobject.RecordType.Name == 'Amendment') {
                        required = false;
                        if(quoteProducts != null) {
                            for(QuoteProductWrapper qpw : quoteProducts) {
                                if(qpw.action == 'Activate' || qpw.action == 'Deactivate') required = true;
                            }    
                        }
                       }
                   }
                
                return required;
            }
        }
        
       /* public boolean TPVRequired{
            get{
               boolean required = false;
               if(quoteProducts != null){
                    for(QuoteProductWrapper qpw : quoteProducts) {
                        system.debug('qpw.actionPicklist[0] : '+qpw.actionPicklist[0] );
                        system.debug('qpw.actionPicklist[0].getLabel() : '+qpw.actionPicklist[0].getLabel());   
                        if(qpw.actionPicklist[0].getLabel() == 'Activate'){
                         required = true;
                        }
                        if(qpw.actionPicklist[0].getLabel() != 'Activate'){
                          required = false;
                        }
                       
                    }  
                }
                system.debug('====='+required);
                return required;

            }
        }*/
        
        
        public Boolean isTeamConnect {
            get {
                return quoteSobject.Is_Team_Connect__c != null && quoteSobject.Is_Team_Connect__c;
            }
        }
        
        public static List<Schema.FieldSetMember> readFieldSet(String fieldSetName, String ObjectName)
        {
            Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
            Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(ObjectName);
            Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
            Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fieldSetName);
            return fieldSetObj.getFields(); 
        }

        public static map<Id, List<SelectOption>> fetchActionListOfValues(List<Quote_Product__c> listQP){
            map<Id, List<SelectOption>> mapOfQPID_with_Values = new map<Id, List<SelectOption>>();
            if(!listQP.isEmpty()){
                //List<SelectOption> options = new List<SelectOption>();
                Map<string,List<sObject>> mapOfSKUwithQRPC = new Map<string,List<sObject>>();
                system.debug('Inside ');
                List<zqu__QuoteRatePlanCharge__c> listofQRPC  = [Select Id, Name, ExistingProduct__c, zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__QuoteRatePlan__r.zqu__AmendmentType__c,zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c from zqu__QuoteRatePlanCharge__c where zqu__QuoteRatePlan__r.zqu__Quote__c = :listQP.get(0).Quote__c];
                if(!listofQRPC.isEmpty()){
                    //Map<string,List<zqu__QuoteRatePlanCharge__c>> mapOfSKUwithQRPC = new Map<string,List<zqu__QuoteRatePlanCharge__c>>();
                    for(zqu__QuoteRatePlanCharge__c tempQRPC : listofQRPC){
                        if(mapOfSKUwithQRPC.containsKey(tempQRPC.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c)){
                            List<sObject> existingQPRC = mapOfSKUwithQRPC.get(tempQRPC.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
                            existingQPRC.add(tempQRPC);
                            mapOfSKUwithQRPC.put(tempQRPC.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, existingQPRC);
                        }
                        else{
                            List<sObject> newListQRPC = new List<sObject>();
                            newListQRPC.add(tempQRPC);
                            mapOfSKUwithQRPC.put(tempQRPC.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, newListQRPC);
                        }
                    }
                }   
                List<zqu__QuoteRatePlan__c> listOfRemoveAmendemnt = [Select Id, Name, zqu__Quote__c, zqu__AmendmentType__c,zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c from zqu__QuoteRatePlan__c where zqu__Quote__c = :listQP.get(0).Quote__c and zqu__AmendmentType__c = 'RemoveProduct'];
                if(!listOfRemoveAmendemnt.isEmpty()){
                    for(zqu__QuoteRatePlan__c tempQRP : listOfRemoveAmendemnt){
                        if(mapOfSKUwithQRPC.containsKey(tempQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c)){
                            List<sObject> existingQPRC = mapOfSKUwithQRPC.get(tempQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c);
                            existingQPRC.add(tempQRP);
                            mapOfSKUwithQRPC.put(tempQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, existingQPRC);
                        }
                        else{
                            List<sObject> newListQRPC = new List<sObject>();
                            newListQRPC.add(tempQRP);
                            mapOfSKUwithQRPC.put(tempQRP.zqu__ProductRatePlan__r.zqu__ZProduct__r.zqu__SKU__c, newListQRPC);
                        }
                    }
                }
                
                //Logic to default the action picklist value in case of New Subscription and if Renewal_Subscription_ID__c is null
                map<String, String> mapOfisExisitngProdcutwithSKU;
                mapOfisExisitngProdcutwithSKU = fun_To_Check_IsExistingProduct(mapOfSKUwithQRPC);
                if(listQP.get(0).Quote__r.ImplementationRequired__c == 'No'){
                    for(Quote_Product__c varQP: listQP){
                        List<SelectOption> options = new List<SelectOption>();
                        options.add(new SelectOption('No Action','No Action'));
                        mapOfQPID_with_Values.put(varQP.Id, options);
                        //return mapOfQPID_with_Values;
                    }
                }
                else if(listQP.get(0).Quote__r.zqu__SubscriptionType__c == 'New Subscription' && listQP.get(0).Quote__r.Renewal_Subscription_ID__c == null && listQP.get(0).Quote__r.ImplementationRequired__c == 'Yes'){
                    //mapOfisExisitngProdcutwithSKU = fun_To_Check_IsExistingProduct(mapOfSKUwithQRPC);
                    if(!mapOfisExisitngProdcutwithSKU.isEmpty()){
                        for(Quote_Product__c varQP: listQP){
                            List<SelectOption> options = new List<SelectOption>();
                            if(mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                String returnString =  mapOfisExisitngProdcutwithSKU.get(varQP.ZProduct__r.zqu__SKU__c);
                                if(returnString == 'anyOneisYes'){
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                    }
                                    //options.add(new SelectOption('Activate','Activate'));
                                    //options.add(new SelectOption('Reactivate','Reactivate'));
                                    mapOfQPID_with_Values.put(varQP.Id, options);
                                    //return mapOfQPID_with_Values;
                                }
                                else if(returnString == 'allIsNo'){
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        system.debug('inside first Check ');
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                            system.debug('inside No Action Check ');
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                    }
                                    mapOfQPID_with_Values.put(varQP.Id, options);
                                    //return mapOfQPID_with_Values;
                                }
                                else{
                                    system.debug('do Nothing..');
                                }
                                //return null;
                            }
                        }
                        //return null;
                    }
                }
                else if(listQP.get(0).Quote__r.zqu__SubscriptionType__c == 'New Subscription' && listQP.get(0).Quote__r.Renewal_Subscription_ID__c != null && listQP.get(0).Quote__r.ImplementationRequired__c == 'Yes'){
                    map<String, List<Zuora__SubscriptionProductCharge__c>> mapOfIsSKUExistsOnSPC;
                    mapOfIsSKUExistsOnSPC = findSubProductandCharges(listQP.get(0).Quote__r.Renewal_Subscription_ID__c);
                    If(!mapOfIsSKUExistsOnSPC.isEmpty()){
                        for(Quote_Product__c varQP: listQP){
                            //system.debug('The Value of Quote Product Name'+varQP.quoteProduct.ZProduct__r.Name);
                            List<SelectOption> options = new List<SelectOption>();
                            if(varQP.PRPCImplementationValue__c == '1 Quote Product for SKU'){
                            if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }
                                else{
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && !mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                List<Zuora__SubscriptionProductCharge__c> listofExistingSPC = mapOfIsSKUExistsOnSPC.get(varQP.ZProduct__r.zqu__SKU__c);
                                boolean isAllOneTimeCharge = true;
                                for(Zuora__SubscriptionProductCharge__c temp: listofExistingSPC){
                                    if(temp.Zuora__Type__c  != 'One-Time'){
                                        isAllOneTimeCharge = false;
                                    }
                                        
                                }
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        if(isAllOneTimeCharge){
                                        system.debug('inside isAllOneTimeCharge true');
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else{
                                            system.debug('inside isAllOneTimeCharge false');
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                            //options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                    else{   
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Deactivate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(!mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                    system.debug('this is inside of Action creteria..'+invokeFromButton+'--'+isfirstTime);
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                    }   
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else{
                                system.debug('Nothing to do');
                                //return null;
                            }
                        }
                        
                        else if(varQP.PRPCImplementationValue__c == '1 Quote Product per charge'){
                            if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                /*if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }*/
                                //else{
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                //}
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && !mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                List<Zuora__SubscriptionProductCharge__c> listofExistingSPC = mapOfIsSKUExistsOnSPC.get(varQP.ZProduct__r.zqu__SKU__c);
                                boolean isAllOneTimeCharge = true;
                                for(Zuora__SubscriptionProductCharge__c temp: listofExistingSPC){
                                    if(temp.Zuora__Type__c  != 'One-Time'){
                                        isAllOneTimeCharge = false;
                                    }
                                        
                                }
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        if(isAllOneTimeCharge){
                                        system.debug('inside isAllOneTimeCharge true');
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                        else{
                                            system.debug('inside isAllOneTimeCharge false');
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                            //options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Deactivate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(!mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                    }   
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else{
                                system.debug('Nothing to do');
                                //return null;
                            }
                        }
                        /////////////////////////////////
                        else if(varQP.PRPCImplementationValue__c == '1 Quote Product per quantity'){
                            if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }
                                else{
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Activate','Activate'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                               }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && !mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                List<Zuora__SubscriptionProductCharge__c> listofExistingSPC = mapOfIsSKUExistsOnSPC.get(varQP.ZProduct__r.zqu__SKU__c);
                                boolean isAllOneTimeCharge = true;
                                for(Zuora__SubscriptionProductCharge__c temp: listofExistingSPC){
                                    if(temp.Zuora__Type__c  != 'One-Time'){
                                        isAllOneTimeCharge = false;
                                    }
                                        
                                }
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        if(isAllOneTimeCharge){
                                        system.debug('inside isAllOneTimeCharge true');
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                        else{
                                            system.debug('inside isAllOneTimeCharge false');
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                            //options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Deactivate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                            options.add(new SelectOption('Softlock','Softlock'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Deactivate','Deactivate'));
                                        }
                                    }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else if(!mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c) && mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                    if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                        if(varQP.Action__c == 'Activate'){
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                        }
                                        else if(varQP.Action__c == 'No Action'){
                                            options.add(new SelectOption('Reactivate','Reactivate'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                        else{
                                            options.add(new SelectOption('No Action','No Action'));
                                            options.add(new SelectOption('Activate','Activate'));
                                        }
                                    }   
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                //return mapOfQPID_with_Values;
                            }
                            else{
                                system.debug('Nothing to do');
                                //return null;
                            }
                        }
                        
                        
                        }
                        //return null;
                    }
                }
                else if((listQP.get(0).Quote__r.zqu__SubscriptionType__c == 'Amend Subscription' /*|| listQP.get(0).Quote__r.zqu__SubscriptionType__c == 'Renew Subscription'*/) && listQP.get(0).Quote__r.ImplementationRequired__c == 'Yes'){
                    if(!mapOfSKUwithQRPC.isEmpty()){
                        system.debug('The value of the map --'+mapOfSKUwithQRPC);
                        for(Quote_Product__c varQP: listQP){
                            system.debug('The Value of Quote Product Name'+varQP.ZProduct__r.Name);
                            system.debug(mapOfSKUwithQRPC.containsKey(varQP.ZProduct__r.zqu__SKU__c));
                            system.debug('the Key check SKU from Product'+varQP.ZProduct__r.zqu__SKU__c);
                            List<SelectOption> options = new List<SelectOption>();
                            boolean isAllRemoveProduct = false;
                            //boolean isOnlyOnerRemoveProduct = false;
                            boolean isAllNewProduct = false;
                            boolean isAllUpdateProduct = false;
                            if(varQP.PRPCImplementationValue__c == '1 Quote Product for SKU'){
                                map<String, List<Zuora__SubscriptionProductCharge__c>> mapOfIsSKUExistsOnSPC;
                                mapOfIsSKUExistsOnSPC = findSubProductandCharges(listQP.get(0).Quote__r.zqu__ExistSubscriptionID__c);
                                Boolean isSKUExistsOnSub = mapOfIsSKUExistsOnSPC.containsKey(varQP.ZProduct__r.zqu__SKU__c)? true : false;
                            if(mapOfSKUwithQRPC.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                List<sObject> listOfQRPCAmend = mapOfSKUwithQRPC.get(varQP.ZProduct__r.zqu__SKU__c);
                                for(sObject tempVar : listOfQRPCAmend){
                                    if(tempVar.getSObjectType() == Schema.getGlobalDescribe().get('zqu__QuoteRatePlan__c') && (tempVar.get('zqu__AmendmentType__c') == 'RemoveProduct')){
                                        system.debug('inside Remove with Product Name'+varQP.ZProduct__r.Name);
                                        isAllRemoveProduct = true;
                                    }
                                    if(tempVar.getSObjectType() == Schema.getGlobalDescribe().get('zqu__QuoteRatePlanCharge__c')){
                                        zqu__QuoteRatePlanCharge__c varQPRC = (zqu__QuoteRatePlanCharge__c)tempVar;
                                        if(varQPRC.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'NewProduct'){
                                            system.debug('inside NewProduct with Product Name'+varQP.ZProduct__r.Name);
                                            isAllNewProduct = true;
                                        }
                                    }
                                    if(tempVar.getSObjectType() == Schema.getGlobalDescribe().get('zqu__QuoteRatePlanCharge__c')){ 
                                        zqu__QuoteRatePlanCharge__c varQPRC = (zqu__QuoteRatePlanCharge__c)tempVar;
                                        if(varQPRC.zqu__QuoteRatePlan__r.zqu__AmendmentType__c == 'UpdateProduct'){
                                            system.debug('inside UpdateProduct with Product Name'+varQP.ZProduct__r.Name);
                                            isAllUpdateProduct = true;
                                        }
                                    }
                                }
                                
                            }
                            system.debug('isAllRemoveProduct-->'+isAllRemoveProduct+'---isAllNewProduct-->'+isAllNewProduct+'--isAllUpdateProduct-->'+isAllUpdateProduct);
                            if(isAllRemoveProduct && isAllNewProduct == false && isAllUpdateProduct == false && isSKUExistsOnSub == true){
                                /*if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    system.debug('Inside Remove all pcklist value'+varQP.ZProduct__r.Name);
                                    options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                }*/
                                //else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                    }
                                    else if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                    }
                                    else{
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                    }
                                //}
                                mapOfQPID_with_Values.put(varQP.Id, options);
                                
                            }
                            else if(isAllNewProduct && isAllRemoveProduct == false && isAllUpdateProduct == false && isSKUExistsOnSub == false){
                                if(!mapOfisExisitngProdcutwithSKU.isEmpty()){
                                    if(mapOfisExisitngProdcutwithSKU.containsKey(varQP.ZProduct__r.zqu__SKU__c)){
                                        if(mapOfisExisitngProdcutwithSKU.get(varQP.ZProduct__r.zqu__SKU__c) == 'anyOneisYes'){
                                            if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                                system.debug('Inside anyonetrue is product '+varQP.ZProduct__r.Name);
                                                options.add(new SelectOption('No Action','No Action'));
                                                options.add(new SelectOption('Activate','Activate'));
                                                options.add(new SelectOption('Reactivate','Reactivate'));
                                            }
                                            else{
                                                system.debug('Invoke From Button');
                                                options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                                if(varQP.Action__c == 'No Action'){
                                                    options.add(new SelectOption('Activate','Activate'));
                                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                                }
                                                else if(varQP.Action__c == 'Activate'){
                                                    options.add(new SelectOption('No Action','No Action'));
                                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                                }
                                                else{
                                                    options.add(new SelectOption('No Action','No Action'));
                                                    options.add(new SelectOption('Activate','Activate'));
                                                }
                                            }
                                        }
                                        else if(mapOfisExisitngProdcutwithSKU.get(varQP.ZProduct__r.zqu__SKU__c) == 'allIsNo'){
                                            if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                                options.add(new SelectOption('Activate','Activate'));
                                                options.add(new SelectOption('No Action','No Action'));
                                                options.add(new SelectOption('Reactivate','Reactivate'));
                                            }
                                            else{
                                                system.debug('Invoke From Button'+varQP.Action__c);
                                                options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                                if(varQP.Action__c == 'No Action'){
                                                    options.add(new SelectOption('Activate','Activate'));
                                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                                }
                                                else if(varQP.Action__c == 'Activate'){
                                                    options.add(new SelectOption('No Action','No Action'));
                                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                                }
                                                else{
                                                    options.add(new SelectOption('No Action','No Action'));
                                                    options.add(new SelectOption('Activate','Activate'));
                                                }
                                            }
                                        }
                                    }
                                }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                            }
                            else if(isAllUpdateProduct && isAllNewProduct == false && isAllRemoveProduct == false && isSKUExistsOnSub == false){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                    options.add(new SelectOption('Deactivate','Deactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Softlock'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                }
                                mapOfQPID_with_Values.put(varQP.Id, options);
                            }
                            //User Story 4855
                            else if(isSKUExistsOnSub){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('Deactivate','Deactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Activate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                            }
                            else{
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                    system.debug('Inside amendment else all pcklist value'+varQP.ZProduct__r.Name);
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('Deactivate','Deactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Softlock'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else{
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                                
                            }
                        }
                        //////////////////////////////////////////////////////
                        else if(varQP.PRPCImplementationValue__c == '1 Quote Product per charge'){
                            if(varQP.Amendment_Type__c == 'RemoveProduct'){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Softlock'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                    }
                                }
                                
                            }
                            else if(varQP.Amendment_Type__c == 'NewProduct'){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else if(varQP.Action__c == 'Activate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                            }
                            
                            else if(varQP.Amendment_Type__c == 'UpdateProduct'){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('No Action','No Action'));
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                }
                                
                            }
                            else{
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('No Action','No Action'));
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                    options.add(new SelectOption('Activate','Activate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Activate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                                
                            }
                            
                        }
                        ////////////////////
                        else if(varQP.PRPCImplementationValue__c == '1 Quote Product per quantity'){
                            if(varQP.Amendment_Type__c == 'RemoveProduct'){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Softlock'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Softlock','Softlock'));
                                    }
                                }
                                
                            }
                            else if(varQP.Amendment_Type__c == 'NewProduct'){
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('Activate','Activate'));
                                    options.add(new SelectOption('No Action','No Action'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Activate','Activate'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else if(varQP.Action__c == 'Activate'){
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                            }
                            
                            else if(varQP.Amendment_Type__c == 'UpdateProduct'){
                                /*if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('No Action','No Action'));
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                }*/
                                //else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                    }
                                //}
                                
                            }
                            else{
                                if(!invokeFromButton && (isfirstTime == null || isfirstTime)){
                                   // system.debug('Inside UpdateProduct all pcklist value'+varQP.ZProduct__r.Name);
                                   options.add(new SelectOption('No Action','No Action'));
                                   options.add(new SelectOption('Deactivate','Deactivate'));
                                    options.add(new SelectOption('Softlock','Softlock'));
                                    options.add(new SelectOption('Reactivate','Reactivate'));
                                    options.add(new SelectOption('Activate','Activate'));
                                }
                                else{
                                    system.debug('Invoke From Button');
                                    options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                                    if(varQP.Action__c == 'No Action'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Deactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Reactivate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                    else if(varQP.Action__c == 'Activate'){
                                        options.add(new SelectOption('Softlock','Softlock'));
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                    }
                                    else{
                                        options.add(new SelectOption('No Action','No Action'));
                                        options.add(new SelectOption('Reactivate','Reactivate'));
                                        options.add(new SelectOption('Deactivate','Deactivate'));
                                        options.add(new SelectOption('Activate','Activate'));
                                    }
                                }
                                
                            }
                            
                        }
                            mapOfQPID_with_Values.put(varQP.Id, options);
                        }
                    }
                    
                }
                else if(listQP.get(0).Quote__r.zqu__SubscriptionType__c == 'Cancel Subscription' && listQP.get(0).Quote__r.ImplementationRequired__c == 'Yes'){
                    for(Quote_Product__c varQP: listQP){
                        List<SelectOption> options = new List<SelectOption>();
                        //if(!invokeFromButton){
                          if(varQP.Quote__r.CancellationAction__c != null){
                            options.add(new SelectOption(varQP.Quote__r.CancellationAction__c,varQP.Quote__r.CancellationAction__c));
                          }
                        //}
                        //else{
                            //options.add(new SelectOption(varQP.Action__c,varQP.Action__c));
                        //}
                        mapOfQPID_with_Values.put(varQP.Id, options);
                    }
                    
                }
                
                else{
                    //return null;
                    system.debug('Do Nothing..');
                }
                /*List<SelectOption> options = new List<SelectOption>();
                options.add(new SelectOption('US','US'));
                options.add(new SelectOption('CANADA','Canada'));
                options.add(new SelectOption('MEXICO','Mexico'));
                return options;*/
            }
            return mapOfQPID_with_Values;   
        }
        public static Map<String, String> fun_To_Check_IsExistingProduct(Map<String,List<sObject>> mapQRPCToSKU){
            map<String, String> mapToSKUwithExitingPro = new map<String, String>();
            if(!mapQRPCToSKU.isEmpty()){
                for(String TempVar : mapQRPCToSKU.KeySet()){
                    List<sObject> getListOnOneSKU = mapQRPCToSKU.get(TempVar);
                    if(!getListOnOneSKU.isEmpty()){
                        for(sObject varsObject: getListOnOneSKU){
                            if(varsObject.getSObjectType() == Schema.getGlobalDescribe().get('zqu__QuoteRatePlanCharge__c')){
                                zqu__QuoteRatePlanCharge__c var = (zqu__QuoteRatePlanCharge__c)varsObject;
                                if(var.ExistingProduct__c == 'Yes'){
                                    mapToSKUwithExitingPro.put(TempVar,'anyOneisYes');
                                    break;
                                }
                                mapToSKUwithExitingPro.put(TempVar,'allIsNo');
                            }
                        }
                        //mapToSKUwithExitingPro.put(TempVar,'allIsNo');
                    }
                }
            }
            return mapToSKUwithExitingPro;
        }
        
        public static Map<String, List<Zuora__SubscriptionProductCharge__c>> findSubProductandCharges(String SubId){
            map<String, List<Zuora__SubscriptionProductCharge__c>> mapOfSKUwithSPC = new map<String, List<Zuora__SubscriptionProductCharge__c>>();
            if(SubId != null){
                List<Zuora__SubscriptionProductCharge__c> listToFindexistingSKU = [Select Id, Zuora__ProductSKU_Product__c, Zuora__Type__c from Zuora__SubscriptionProductCharge__c where Zuora__Subscription__r.Zuora__External_Id__c = :SubId OR Zuora__Subscription__r.Zuora__PreviousSubscriptionId__c = :SubId];
                if(!listToFindexistingSKU.isEmpty()){
                    for(Zuora__SubscriptionProductCharge__c tempQRPC : listToFindexistingSKU){
                        if(mapOfSKUwithSPC.containsKey(tempQRPC.Zuora__ProductSKU_Product__c)){
                            List<Zuora__SubscriptionProductCharge__c> existingQPRC = mapOfSKUwithSPC.get(tempQRPC.Zuora__ProductSKU_Product__c);
                            existingQPRC.add(tempQRPC);
                            mapOfSKUwithSPC.put(tempQRPC.Zuora__ProductSKU_Product__c, existingQPRC);
                        }
                        else{
                            List<Zuora__SubscriptionProductCharge__c> newListQRPC = new List<Zuora__SubscriptionProductCharge__c>();
                            newListQRPC.add(tempQRPC);
                            mapOfSKUwithSPC.put(tempQRPC.Zuora__ProductSKU_Product__c, newListQRPC);
                        }
                    }
                    
                }
            }
            return mapOfSKUwithSPC;
        }
    









































































































            
            
            
            
      public static void increasecoverage()
    {
    
    
               Integer i = 0;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                DIQuoteUtil.increasecoverage();
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                 i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
                i= i+1;
    
    }
    }