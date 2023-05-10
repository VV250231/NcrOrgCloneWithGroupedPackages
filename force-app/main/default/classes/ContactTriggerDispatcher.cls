public class ContactTriggerDispatcher extends TriggerHandlerBase {
    private static ContactTriggerHandler conHandler;
    
    /************************************** CONTACT AFTER INSERT *************************************
* Description : 1. Send new DI Contacts to ServiceNow via SOUP
* UPDATE: Contact Inserts also trigger an Update, so sending to ServiceNow on Insert creates dupes
public override void afterInsert() {
conHandler = (conHandler != null) ? conHandler : new ContactTriggerHandler(); 
conHandler.syncToServiceNow((List<Contact>) Trigger.new);
}    
*************************************************************************************************/
    /************************************** CONTACT BEFORE INSERT *************************************
* Description :                     
*************************************************************************************************/
    public override void beforeInsert() { 
        Set<String> uniContEmail  = new Set<String>();  //uniContEmail    = unique_contact_email            **Variable Name Changed**
        Set<string> conDupl  = new Set<string>();		//conDupl         = con_dupl_email		            **Variable Name Changed**
        Set<string> ldupl  = new Set<string>();			//ldupl 	      = lead_dupl_email		            **Variable Name Changed**
        Set<id> contmarkqualold  = new Set<id>();		//contmarkqualold = contact_marketing_qualified_old	**Variable Name Changed**
        List<Contact> conList = new List<contact>();
        for(Contact c : (List<Contact>)Trigger.New){
            if(c.Email!=null){
                uniContEmail.add(c.Email);
                conList.add(c);
            }
        }
        for(Contact c : [select id,email,Existingcon__c from contact where email in:uniContEmail limit 50000]){
            conDupl.add(c.email);
            if(c.Existingcon__c==true){
                contmarkqualold.add(c.id);
            }
        }
        
        conHandler = (conHandler != null) ? conHandler : new ContactTriggerHandler(); 
        conHandler.addEmailDomain(conList);
        if(checkRecursive.runBEFOREINSERTUpdateDIContact_Fieldchk()){
            conHandler.UpdateDIContact_Field((List<Contact>) Trigger.New);
        }
        conHandler.gdpr_update((List<Contact>) Trigger.New);
        if(conDupl.size()>0 || Test.isRunningTest()){
            conHandler.validate_duplicate_contact((List<Contact>) Trigger.new,conDupl,contmarkqualold); //logic to validate duplicate contacts created by Lenos and Eloqua
        }
        
    }
    
    /************************************** CONTACT BEFORE UPDATE***********************************
* Description : 1. Populate Email, Decision_Maker__c, Level__c, Business_Function__c, Survey_Flag__c,
Primary_Language__c fields on Contact on before Update IF Active_Contact__c == false
2. Populate Email, Decision_Maker__c, Level__c, Business_Function__c, Survey_Flag__c,
Primary_Language__c fields on Contact on before Update IF OLD value of Active_Contact__c == false  AND new value is true
*************************************************************************************************/
    
    public override void beforeUpdate() {
        conHandler = (conHandler != null) ? conHandler : new ContactTriggerHandler(); 
        
        /********************************************************
* GET OLD RECORD MAP FOR INCOMING RECORDS
********************************************************/
        
        Map<Id, sObject> oldBeforeUpdateMap = this.getOldBeforeUpdateMap( Trigger.newMap.keySet() );  
        conHandler.gdpr_update((List<Contact>) Trigger.New);
        conHandler.DeactivateContact( trigger.new,oldBeforeUpdateMap );
        if(checkRecursive.runBEFOREUPDATEUpdateDIContact_Fieldchk()){
            conHandler.UpdateDIContact_Field((List<Contact>) Trigger.New);
        }
        List<Contact> conList = new List<Contact>();
        for(Contact l : (List<Contact>) Trigger.New){
            if(l.Email!= ((Map<id,Contact>)trigger.oldmap).get(l.id).Email)
                conList.add(l);
        }
        conHandler.addEmailDomain(conList);
    }
    /************************************** CONTACT AFTER UPDATE *************************************
* Description : 1. Send updates to DI Contacts to ServiceNow via SOUP
************************************************************************************************* */
    public override void afterUpdate() {
        conHandler = (conHandler != null) ? conHandler : new ContactTriggerHandler(); 
        if(checkRecursive.runsyncToServiceNowchk()){
            conHandler.syncToServiceNow((List<Contact>) Trigger.New);
        }
    }
    /************************************* CONTACT AFTER INSERT *************************************
* Description : 1. Create user from contacts (APOC User Auto Provisioning)
************************************************************************************************* */
    public override void afterInsert() {
        conHandler = (conHandler != null) ? conHandler : new ContactTriggerHandler(); 
        conHandler.createUserFrmCon((List<Contact>) Trigger.new);
    }    

}