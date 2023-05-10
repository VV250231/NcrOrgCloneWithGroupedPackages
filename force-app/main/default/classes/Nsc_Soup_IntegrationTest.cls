@isTest
private class Nsc_Soup_IntegrationTest {
    
    
    static testMethod void myTest() {
        User u = [SELECT Id, Name, Email, Quicklook_ID__c FROM USER LIMIT 1];
        
        CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
        TargetObjectIdEmial.UserID__c=u.Id;
        TargetObjectIdEmial.Name='Do Not Reply User For CADD';
        insert TargetObjectIdEmial;
        
        Account acc = [SELECT Id, Name,Account_Country_Code__c, Master_Customer_Number__c,Owner.Email,Owner.Quicklook_ID__c FROM Account LIMIT 1];
        
        Sales_Org_Temp__c sotemp  = [SELECT Id,Sales_Org_Code__c,Hierarchy_2__c FROM Sales_Org_Temp__c LIMIT 1];
        
        NCR_Employee_Detail__c ncrEmp = [SELECT Id, Name, Global_ID__c,Quicklook_ID__c,InActive__c FROM NCR_Employee_Detail__c LIMIT 1];
        
        EDBI_Order__c orderHeader = [SELECT Id, Order_Number_with_Country_Code__c FROM EDBI_Order__c LIMIT 1];
        
        ERP_Orders_Backlog__c erpOrder = [SELECT Id,Order_Number__c,Order_Line_Id__c FROM ERP_Orders_Backlog__c LIMIT 1];
        
        DemingService.DemingRequestInfo(createDemingRecord(acc, erpOrder,  sotemp, ncrEmp.Global_ID__c));
        
        Deming__c dm = [SELECT Id FROM Deming__c LIMIT 1];
        
        dm.Customer_Contact_Name__c = 'Test';
        dm.Cadd_Status__c='Rejected';
        dm.Ncr_Associate__c = u.Id;
        update dm;
        
        Nsc_Soup_Integration.synchLOS_OM(new List<Id>{dm.Id});
        list<Deming__c> demList = Nsc_Soup_Integration.generateData();
        System.assert(demList.size()==0);
    }  
    
    
    @testSetup static void setup() {
        Account acc=TestRecordsFactory.createAccount(); 
        
        NCR_Employee_Detail__c ncrEmp = new NCR_Employee_Detail__c(User_Name__c = 'Test Record 1', Quicklook_ID__c = 'test1234', Global_ID__c = '123456789', Manager_Global_ID__c = '231453671', inActive__c = false, job_family__c = 'SLS - Pre Sales Engineer');
        insert ncrEmp;
        
        Sales_Org_Temp__c  sotemp =new Sales_Org_Temp__c();
        sotemp.Name = 'Test';
        sotemp.Sales_Org_Code__c = NSCCommonInfoUtil.getIdOf('sales_org_temp');
        sotemp.Corporate_Name__c  = 'Test';
        sotemp.Functional_Group__c = 'Test';
        sotemp.Org_Code_Country_Code__c = 'US';
        sotemp.RoR_Update_Date__c = system.today();
        sotemp.Is_Active_in_RoR__c = true;
        sotemp.solution_Portfolio__c = 'RT';
        sotemp.Hierarchy_1__c = 'Test Hierarchy';
        sotemp.Hierarchy_2__c = 'GS:FS';
        sotemp.Hierarchy_3__c = 'Test Hierarchy';
        sotemp.Hierarchy_4__c = 'Test Hierarchy';
        sotemp.Hierarchy_5__c = 'Test Hierarchy';
        sotemp.Hierarchy_6__c = 'Test Hierarchy';
        sotemp.Hierarchy_7__c = 'Test Hierarchy';
        sotemp.Hierarchy_8__c = 'Test Hierarchy';
        sotemp.Hierarchy_9__c = 'Test Hierarchy';
        sotemp.Hierarchy_10__c = 'Test Hierarchy';
        insert sotemp;  
        
        EDBI_Order__c orderHeader = new EDBI_Order__c(Master_Customer_Number__c = acc.Master_Customer_Number__c ,Customer_Name__c = acc.Name,
                                                      Sales_Org_Code__c = sotemp.Sales_Org_Code__c ,Order_Date__c = Date.today(),Enterprise_ID__c = 'EE_127286',
                                                      Order_Number_with_Country_Code__c = '5412913US', Order_Number__c = '5412913', Customer_Country_Code__c = 'US'); 
        
        insert orderHeader;  
        
        ERP_Orders_Backlog__c erpOrder = new ERP_Orders_Backlog__c(Order_Number__c = orderHeader.Order_Number__c, Country_Code__c = 'US', Order_Line_Id__c = 'Line1234', Master_Customer_Number__c = acc.Master_Customer_Number__c);
        insert erpOrder;     
        
        Profile stdProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        TestRecordsFactory.createUsers(stdProfile.Id, 'LeadTest', 1);
        
    }
    
    
    static DemingService.DemingRequest createDemingRecord(Account acc, ERP_Orders_Backlog__c erpOrder,  Sales_Org_Temp__c sotemp, String SPGlobalId) {    
        
        
        DemingService.DemingRequest dr = new DemingService.DemingRequest();
        dr.orderNo = erpOrder.Order_Number__c;
        dr.orderId = erpOrder.Order_Line_Id__c;
        dr.customerName = acc.Name;
        dr.customerNo = acc.Master_Customer_Number__c;
        dr.customerCountryCode = acc.Account_Country_Code__c;
        dr.site = 'TEST, 1234';
        dr.shipToLocation = 'TEST';
        dr.deliveryToLocation = 'TEST';
        dr.deliveryToAddress1 = 'TEST, 1234';
        dr.salesPersonName = 'Test';
        dr.salesPersonGlobalId = SPGlobalId;
        dr.RDD = Date.today();
        dr.maxPromiseDate = Date.today();
        dr.maxScheduledShipDate = Date.today();
        dr.maxScheduledArrivalDate = Date.today();
        dr.CDPName = 'Test Partner';
        dr.CDPGlobalId = 'PRTGID12345';
        
        dr.CISName = 'CIS User';
        dr.CISGlobalId = 'CISGID12345';
        
        dr.reasonCode = '002';
        dr.customerIndustry = 'Test Hierarchy';
        dr.partyNumber = 'East1234';
        dr.salesOrdCode = sotemp.Sales_Org_Code__c;
        
        return dr;
    }
}