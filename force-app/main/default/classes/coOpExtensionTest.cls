@isTest
public class coOpExtensionTest {

    public static testmethod void testCoOpExtension() {
         Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
        system.runAs(TestRecordsFactory.getUser()){
            insert act;
        }
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        
        system.runAs(u){
        //Account acc = createAccount();
        //insert acc;
        //Contact con = createContact(acc.id);
        //insert con;
        //user u = createUser(con.Id);
        //insert u;
         
        //system.runAs(u) {
            // Insert Co-Op Request
            Co_Op__c coOpReq = new Co_Op__c();
            coOpReq.Activity_Name__c = 'Co Op Req';
            coOpReq.Activity_Start_Date__c = System.today();
            coOpReq.Activity_End_Date__c = System.today();
            insert coOpReq;
            
            Co_Op_Supporting_Document__c obj = new Co_Op_Supporting_Document__c ();
            ApexPages.StandardController sc = new ApexPages.StandardController(obj );
            PageReference pageRef = Page.co_op_supporting_document;
            pageRef.getParameters().put('coOpid', String.valueOf(coOpReq.Id));
            Test.setCurrentPage(pageRef);
            
            coOpExtension controller = new coOpExtension(sc);
            controller.saveSupportingDoc();
            controller.att.Name = 'Test';
            controller.att.Body = Blob.valueOf('Test');
            PageReference pgObj  = controller.saveSupportingDoc();
            System.assert(pgObj!=null);
        }
    
    }
    public static testmethod void testCoOpExtension2() {
         Account act = PRM_TestRecordsFactory.createPartnerAccount('test',null);
         system.runAs(TestRecordsFactory.getUser()){
              insert act;
         }
        Contact con = PRM_TestRecordsFactory.createPartnerContact(act.Id, 'test', null);
        insert con;
        User u = PRM_TestRecordsFactory.createPartnerUser(con.Id, 'test', null);
        insert u;
        
        system.runAs(u){ {
            // Insert Co-Op Request
            Co_Op__c coOpReq = new Co_Op__c();
            coOpReq.Activity_Name__c = 'Co Op Req';
            coOpReq.Activity_Start_Date__c = System.today();
            coOpReq.Activity_End_Date__c = System.today();
            insert coOpReq;
            
            Co_Op_Supporting_Document__c obj = new Co_Op_Supporting_Document__c ();
            ApexPages.StandardController sc = new ApexPages.StandardController(obj );
            PageReference pageRef = Page.co_op_supporting_document;
            pageRef.getParameters().put('coOpid', String.valueOf('test'));
            Test.setCurrentPage(pageRef);
            
            coOpExtension controller = new coOpExtension(sc);
            controller.saveSupportingDoc();
            controller.att.Name = 'Test';
            controller.att.Body = Blob.valueOf('Test');
            PageReference pgObj = controller.saveSupportingDoc();
            System.assert(pgObj==null);
        }
    }
    }
}