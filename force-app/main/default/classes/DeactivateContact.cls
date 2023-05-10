public with sharing class DeactivateContact {

public contact contact1 = new contact();
public contact contact2 = new contact();

    public DeactivateContact(ApexPages.StandardController controller) {
    contact2 = (Contact)controller.getRecord();
    }


    public PageReference doDeactivateContact()
    {
    PageReference p = new PageReference('/'+contact2.id);
    p.setredirect(true);
    contact1 = [select id , Active_Contact__c from contact where id=: contact2.id];
    contact1.Active_Contact__c = false;
    try{
    update contact1;
    return p;
    }
    
    catch(exception e)
    {
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'ERROR OCCURED OR YOU DO NOT PERMISSION TO PERFORM THIS ACTIVITY');
    ApexPages.addMessage(myMsg);
    return null;
    }
    }

}