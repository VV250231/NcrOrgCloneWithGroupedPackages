@isTest
public class GetHelpInlineMessageControllerTest 
{
    static testmethod void submitOpptyForApprovalPage()
    {
    	List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp')); 
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        System.runas(TestRecordsFactory.getuser()){
        	insert accounts;
        }
        Contact con = new Contact(LastName ='testCon', AccountId = accounts[0].Id, email='r@ncr.com');
        insert con;
        case c = new case();
        c.Status ='new';
        c.Subject='General';
        c.contactId = con.id;
        insert c;
        
        Attachment__c objAttachment = new Attachment__c();
        objAttachment.Case__c = c.Id;
        insert objAttachment;
        
     	GetHelpInlineMessageController controller = new GetHelpInlineMessageController(new ApexPages.StandardController(c));
        system.assert(controller!=null);
	}

}