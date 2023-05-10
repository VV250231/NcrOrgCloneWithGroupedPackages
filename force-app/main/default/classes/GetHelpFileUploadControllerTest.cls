@isTest
public class GetHelpFileUploadControllerTest 
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
        
        GetHelpFileUploadController.saveChunk(c.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', '');
        
        Attachment oAttachment = new Attachment();
        Blob b = Blob.valueOf('Test Data');
        oAttachment.parentId = c.Id;
        oAttachment.Name = 'Test Attachment for Parent';
        oAttachment.Body = b;
        insert oAttachment;
        Id i =GetHelpFileUploadController.saveChunk(c.Id, 'Test', EncodingUtil.urlDecode('Testing', 'UTF-8'), 'txt', oAttachment.Id);
        System.assert(i!=null);
    }

}