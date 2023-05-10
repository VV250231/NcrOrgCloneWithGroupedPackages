@isTest
public class TicketRequestControllerTest {
    static testMethod void unitTest() {  
        Id trq =NSCCommonInfoUtil.getIdOf('userId_TicketRequest');
        User user = [select id, name, phone from user where id = :trq] ;
        
        Account acc=TestRecordsFactory.createAccount();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        Contact Con = TestRecordsFactory.createContact(acc);
        Ticket_Request_Event__c tre = TestRecordsFactory.createTicketRequestEvent();
        Ticket_Request__c tr = TestRecordsFactory.createTicketRequest(user, con, opp);
        TicketRequestController.UpdateTicketRequest(tr);
        TicketRequestController.getEventNameandDate();
        TicketRequestController.getSelectedValue(tr.id);
        List<ListView> listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Ticket_Request__c' ];
        TicketRequestController.getListViews();
        TicketRequestController.getAvailableTickets(tre.Event_Name_Date__c);
        TicketRequestController.getAvailableTicketsonEdit(tre.Event_Type__c, tre.Event_Name_Date__c);
        TicketRequestController.getUserIdPermissionSet();
        TicketRequestController.getParkingPasses(tre.Event_Name_Date__c );
        TicketRequestController.getTicketType(tre.Event_Name_Date__c);
        TicketRequestController.isKendleReedLogin();
        TicketRequestController.getEditModeParkingPasses(tr.Id, tre.Event_Name_Date__c);
        
        List<Opportunity> OppList = new List<Opportunity>();
        //reUsableMultiSelectLookupCtrl MultiLookUp= new reUsableMultiSelectLookupCtrl();
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('Test','opportunity',OppList,'Name',acc.id);
        reUsableMultiSelectLookupCtrl.fetchLookUpValues('Test','User',new List<User>{},'Name','');
        
        Opportunity opp1 = new Opportunity();
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp1.name = 'abc';
        opp1.AccountID = acc.id;
        opp1.Name = 'OppQuote Linkage Opportunity';
        opp1.type = 'Indirect Channel';
        /*opp.Solution_Portfolio__c = 'Financial Self Service'; -P360 Initial Change-Ahad */
        opp1.CURRENCYISOCODE = 'USD';
        opp1.SALES_ORG__C = TestRecordsFactory.createSalesOrg().id;
        opp1.INVOICE_TRIGGER__C = 'Shipment';
        //opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp1.PRIMARY_COMPETITOR__C = TestRecordsFactory.createCompetitor().id;
        opp1.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp1.closeDate = System.TODAY();
        opp1.stagename = 'Analyzing';
        opp1.recordTypeId = r1;
        opp1.Key_Criteria__c='Best Solution;Business Benefits;Lead Time;Performance;Price';
        opp1.EndCustomerUnknown__c = true;
        List<Opportunity> OppListToInsert= new List<Opportunity>();
        OppListToInsert.add(opp1);
        reUsableMultiSelectLookupCtrl.AddMultipleContactToTicketRequest(OppListToInsert);
        reUsableMultiSelectLookupCtrl.getRecentRecords('User', 'Name');
       TicketRequestController.getPhoneNumber();
        Ticket_Request__c tr1 = new Ticket_Request__c();
        TicketRequestController.processToCreateRecord(tr);
        string trqId = TicketRequestController.processToCreateRecord(tr1);
        System.assert(tr.id!=null);
        
    }
}