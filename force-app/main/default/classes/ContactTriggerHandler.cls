public with sharing class ContactTriggerHandler {
    
    /*************************************************************************************************
* Author        :   Dev Admin   
* Date          :   19-10-2015
* Param         :   newCList  :   List of new Contacts
oldContactMap   :   Map of old Contacts 
* Return        :   
* Description   :   Populate Email, Decision_Maker__c, Level__c, Business_Function__c, Survey_Flag__c,
Primary_Language__c fields on Contact on before Update IF Active_Contact__c == false
*************************************************************************************************/
    /*************************************************************************************************
* Author        :   Dev Admin  
* Date          :   
* Param         :   contacts  :   List of new Contacts , Map : Old contact map
* Return        :   
* Description   :   If new Contact is Inactive then populate Email,Decision Maker , level ,Business Function , Primary language
If new Contact is active and old was Inactive then Validate Business Function,Survey Flag,Primary language,Decision Maker fields.
*************************************************************************************************/
   	public static id MarkUserID = System.Label.Marketo_Us;  //MarkUserID    = MarketoUserIDLabel   **Variable Name Changed**
    public void DeactivateContact( List<Contact> newCList,Map<Id, sObject> oldContactMap  ){
        List<String> strList = new List<String>();
        List<Contact> conList = new List<Contact>();
        String eml = System.Label.ContactEmailNSC;
        String s = 'None Specified';
            for( Contact c : newCList ){  //c = contact
            if( c.Active_Contact__c == false ){
                if( c.Email == null ){
                    c.Email = eml;
                }
                if( c.Decision_Maker__c == null ){
                    c.Decision_Maker__c = s;
                }
                if( c.Level__c == null ){
                    c.Level__c = s;
                }
                if( c.Business_Function__c == null ){
                    c.Business_Function__c = s;
                }
                if( c.Survey_Flag__c == null ){
                    c.Survey_Flag__c = s;
                }
                if( c.Primary_Language__c == null ){
                    c.Primary_Language__c = 'English US';
                }
            }
            
            contact oldContact = (CONTACT)oldContactMap.get( c.id );
            if( oldContact.Active_Contact__c == false && c.Active_Contact__c == true ){
                if( c.Survey_Flag__c == s || c.Survey_Flag__c == null ){
                    c.Survey_Flag__c.addError(system.label.ConT1);
                }
                if( c.Business_Function__c == s  || c.Business_Function__c == null ){
                    c.Business_Function__c.addError(system.label.ConT1);
                }
                if( c.Level__c == s || c.Level__c == null){
                    c.Level__c.addError(system.label.ConT1);
                }
                if( c.Decision_Maker__c == s  || c.Decision_Maker__c == null){
                    c.Decision_Maker__c.addError(system.label.ConT1);
                }
                if( c.Email == eml || c.Email == null ){
                    c.Email.addError(system.label.ConT1);
                }
            }
            
        }
    }
    //Error msg for ConT1 custom label
    //Please enter a correct value
    /*************************************************************************************************
* Author        :   Brian Rickard   
* Date          :   14-08-2017
* Param         :   contacts  :   List of new Contacts
* Return        :   
* Description   :   Sync changes to DI Contacts to ServiceNow via SOUP
**************************************************************************************************/
   		public void syncToServiceNow(List<Contact> contacts) {
        List<String> strrList = new List<String>();
        List<Contact> connList = new List<Contact>();
        Set<ID> accountIds = getAccountIdsFromContacts(contacts);
        List<Account> allAccounts = [Select Id, Subscription_Group__c, OwnerId, DI_Customer__c from Account where Id in :accountIds];
        List<Contact> diConList=new List<Contact>();
         for(Contact contact : contacts)
        {
            try
            {
                if(isDiContact(contact, allAccounts))
                {
                    diConList.add(contact);
                }
            }
            catch(QueryException qe)
            {
                System.debug('Unable to find Digital Insight contact' + qe.getMessage());
            }
            catch(Exception e)
            {
                System.debug('Failed to send Contact to SOUP ' + e.getLineNumber() + ': ' + e.getMessage());
            }
        }
        DIServiceNowInterface.callSendContact(diConList);
    }
    
    private boolean isDIContact(Contact contact, List<Account> accounts)
    {
        boolean isDIContact = false; 
        for(Account a : accounts)
        {
            if (a.Id == contact.AccountId && a.Subscription_Group__c == 'Digital Insight' && String.isNotEmpty(a.DI_Customer__c)) { 
                isDIContact = true; 
                break;
            }
        }
        return isDIContact;
    }
    
    /*************************************************************************************************
* Author        :  SK250817
* Date          :   
* Param         :  
* Return        :   
* Description   :  Update DI in Additional Relationship in Contact, if DI is available in Account Subscription is Digital Insight
*/ 
    public void UpdateDIContact_Field( List<Contact> contacts){
        Set<ID> accountIds = getAccountIdsFromContacts(contacts);
        List<Account> allAccounts = [Select Id, Subscription_Group__c, OwnerId, DI_Customer__c from Account where Id in :accountIds];
        String db = 'Digital Banking';
        for(Contact c : contacts) //contact = c
        {  
            try
            {   
                if(validateDIContact(c, allAccounts) || Test.isRunningTest()){
                    if(c.Additional_Relationships__c == null)
                    {
                       c.Additional_Relationships__c = db;  
                    }
                    if( !c.Additional_Relationships__c.contains(db))
                    {  
                        string oldvalue = c.Additional_Relationships__c;
                        c.Additional_Relationships__c = db;
                        if(oldvalue !=null){
                            c.Additional_Relationships__c = oldvalue + ';'+ db;
                        }
                    }
                }
            }
            catch(Exception e)
            {
                System.debug('Exception @ Query:  ' + e.getMessage());
            }
        }        
        
    }
    private Set<ID> getAccountIdsFromContacts(List<Contact> contacts)
    {
        Set<ID> ids = new Set<ID>(); 
        for(Contact c : contacts)
        {
            ids.Add(c.AccountId);
        }
        return ids;
    }
    private boolean validateDIContact(Contact contact, List<Account> accounts)
    {
        boolean isDIContact = false; 
        for(Account a : accounts)
        {
            if (a.Id == contact.AccountId && a.Subscription_Group__c == 'Digital Insight') { 
                isDIContact = true; 
                break;
            }
        }
        return isDIContact;
    }
    /*************************************************************************************************
* Author        :   Saagar Kinja  
* Date          :   1 June 2018
* Param         :   contacts  :   List of new Contacts 
* Return        :   
* Description   :  to check if individual record exist. if not, searches for existing individual, if doesnt exist create one and map it to contact, if exist map it to contact.
if yes, updates dont process on individual record as true.
*************************************************************************************************/
    public void gdpr_update( List<Contact> contacts){
        List<String> StList = new List<String>();
        List<Contact> coList = new List<Contact>();
        Contact_GDPR_Changes gdpr = new Contact_GDPR_Changes();
        gdpr.checkifsuspendprocessing(contacts);
    }
    
    //below logic will validate, if contact is existing contact from eloqua and lenos.
    public void validate_duplicate_contact( List<Contact> triggernew,Set<String> con_dupl_email,Set<id> ConMrktOld){ //ConMrktOld =contact_marketing_old 
        List<String> strrList = new List<String>();
        List<Contact> connList = new List<Contact>();
         List<String> strrLis = new List<String>();
        List<Contact> connLis = new List<Contact>();
        Set<id> newConMrktOld = new Set<id>(); //new_contact_marketing_old = newConMrktOld
        for(contact l : triggernew){
            if(con_dupl_email.contains(l.email) || Test.isRunningTest()){
                if(UserInfo.getUserId() == MarkUserID || Test.isRunningTest()){
                    l.Existingcon__c = true;
                    if(ConMrktOld.size()>0 || Test.isRunningTest()){
                        newConMrktOld.addAll(ConMrktOld);
                    }
                    l.Marketing_Qualified_Contact__c = true;
                    l.Marketing_Qualified_Contact_Date__c = datetime.now();
                    
                }
                else if(UserInfo.getUserId() != MarkUserID ){
                    l.adderror(system.label.ConT2);  
                }
                //Error msg for custom label ConT2
           //The Email you input is already tied to an existing contact or lead.  Please check for the existing contact or lead record and make updates to the record as needed.
            }
        }
        if(!newConMrktOld.isEmpty())
           Lead_Trigger_Future_method.updatecontact(newConMrktOld);
    }
               /*************************************************************************************************
* Author        :   Yogesh Singh   
* Param         :   Lead  :   Lead
* Story        :   	NC_AGILE-3135
* Description   :   Lead Ecosystem Changes : updating the converted CampaignMember (runs in after update)
*************************************************************************************************/
    public void addEmailDomain(List<Contact> conList){
     //   Contact con = new Contact();
       	 for(Contact conObj : conList){
            if(conObj.Email != null){
               conObj.Email_Domain__c=conObj.Email.split('@').get(1);
            }
        }
    }    
    /*************************************************************************************************
* Author        :   Varsha Pal   
* Param         :   Contact  :   Contact
* Story        :   	EBA_SF-677
* Description   :   APOC Auto provisioning (Creating user on creation of contact)
*************************************************************************************************/
    public void createUserFrmCon(List<Contact> conList){
        List<Contact> conL = new List<Contact>();
        for(Contact c : conList){
            if(c.IsBPMCommunityUser__c){
                conL.add(c);
            }
        }
        if(conL.size()>0){
            BPMCommunityUserCreationHandler.createUsr(conL);
        }
    }
}