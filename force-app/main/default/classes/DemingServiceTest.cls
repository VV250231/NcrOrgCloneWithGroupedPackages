@isTest
private class DemingServiceTest {
    
    @testSetup static void setup() {
        Account acc=TestRecordsFactory.createAccount(); 
        User u=TestRecordsFactory.getUser(); 
        AccountTeamMember ateam=createAccountTeamMember(acc.Id,u.Id);
        
        NCR_Employee_Detail__c ncrEmp = new NCR_Employee_Detail__c(User_Name__c = 'Test Record 1', Quicklook_ID__c = 'sa185043', Global_ID__c = '14200124419-20110', Manager_Global_ID__c = '201100', inActive__c = true, job_family__c = 'SLS - Pre Sales Engineer');
        insert ncrEmp;
        
        Sales_Org_Temp__c  sotemp =new Sales_Org_Temp__c();
        sotemp.Name = 'Test';
        sotemp.Sales_Org_Code__c = '201100959';
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
                                                      Order_Number_with_Country_Code__c = '5412913US', Order_Number__c = '5412913', Customer_Country_Code__c = 'US',Order_Value_in_Thousand__c='10.23450',Quote_Number__c='123'); 
        
        insert orderHeader;  
        orderHeader.Order_Value_in_Thousand__c='20.23450';
        Update orderHeader;
        
        ERP_Orders_Backlog__c erpOrder = new ERP_Orders_Backlog__c(Order_Number__c = orderHeader.Order_Number__c, Country_Code__c = 'US', Order_Line_Id__c = 'Line1234', Master_Customer_Number__c = acc.Master_Customer_Number__c);
        insert erpOrder;  
        
    }
    
    
    
    static testMethod void myTest2() {
        
        CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
        TargetObjectIdEmial.UserID__c=NSCCommonInfoUtil.getIdOf('AtmPrcsUserId');
        TargetObjectIdEmial.Name='Do Not Reply User For CADD';
        insert TargetObjectIdEmial;
        Account acc = [SELECT Id, Name,Account_Country_Code__c, Master_Customer_Number__c,Owner.Email,Owner.Quicklook_ID__c FROM Account LIMIT 1];
        
        Sales_Org_Temp__c sotemp  = [SELECT Id,Sales_Org_Code__c,Hierarchy_2__c FROM Sales_Org_Temp__c LIMIT 1];
        
        NCR_Employee_Detail__c ncrEmp = [SELECT Id, Name, Global_ID__c,Quicklook_ID__c,InActive__c FROM NCR_Employee_Detail__c LIMIT 1];
        
        EDBI_Order__c orderHeader = [SELECT Id, Order_Number_with_Country_Code__c FROM EDBI_Order__c LIMIT 1];
        
        ERP_Orders_Backlog__c erpOrder = [SELECT Id,Order_Number__c,Order_Line_Id__c FROM ERP_Orders_Backlog__c LIMIT 1];
        
        ERP_Orders_Backlog__c erpOrder1 = new ERP_Orders_Backlog__c( Country_Code__c = 'US', Order_Line_Id__c = 'Lin1234', Master_Customer_Number__c = '23423');
        insert erpOrder1; 
        
        DemingService.DemingRequest dr1 = createDemingRecord(acc, erpOrder,  sotemp, ncrEmp.Global_ID__c);
        DemingService.DemingRequest dr3 = createDemingRecord(acc, erpOrder1,  sotemp, ncrEmp.Global_ID__c);
        DemingService.DemingRequest dr2 = createDemingRecord(acc, erpOrder,  sotemp, 'Test');
        DemingService.DemingRequest dr = new DemingService.DemingRequest(); 
        dr.threshold='1234';
         dr.orderNo='1234';
         dr.orderId='1234';
        Deming__c DemObj= new Deming__c();
        DemObj.Order_Id__c='47593451';                                       //Select id,Order_Number__c,Order_Line_Id__c from ERP_Orders_Backlog__c          208395648
        DemObj.SalesPerson_Global_Id__c='14200124419-201100959';             //Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c  41477033784-20110098
        DemObj.SalesOrdCode__c='201100959';                                //Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c
        DemObj.Customer_No__c='8511908';
        DemObj.Order_number__c='5340549';
        DemObj.Customer_Country_code__c= 'US'; //Select id,Name,Master_Customer_Number__c,Owner.Email from Account  8533019PH
        DemObj.Max_Promise_Date__c=System.today();
        DemObj.RDD__c=System.today().adddays(-1);
        
        //DemObj.CADD_Owner__c='Test@gmail.com';
        //DemObj.Customer_Delivery_Partner_Email__c='Testw@gmail.com';
        Test.StartTest();
        insert DemObj;
        User u = [SELECT Id, Name, Email, Quicklook_ID__c FROM USER LIMIT 1];
        
        DemObj.Cadd_Status__c='Approved';
        DemObj.Ncr_Associate__c = u.Id;
        DemObj.Max_Promise_Date__c=System.today();
        DemObj.IsSalespersonFound__c=true;
        DemObj.RDD__c=System.today().adddays(-1);
        
        DemObj.Customer_Name__c='Test Customer';
        DemObj.Acceptance_time__c=system.today().addDays(2);
        update DemObj;
        DemObj.Max_Promise_Date__c=System.today().addDays(2);
        DemObj.Cadd_Status__c='Rejected';
        update DemObj;
        
        Deming__c DemObj1= new Deming__c();
        DemObj1.Order_Id__c='47593451';                                      //Select id,Order_Number__c,Order_Line_Id__c from ERP_Orders_Backlog__c          208395648
        //  DemObj1.SalesPerson_Global_Id__c='14200124419-201100959';             //Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c  41477033784-20110098
        DemObj1.SalesOrdCode__c='201100959';                                //Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c
        DemObj1.Customer_No__c='8511908';
        DemObj1.Order_number__c='5340549';
        DemObj1.Customer_Country_code__c= 'US'; //Select id,Name,Master_Customer_Number__c,Owner.Email from Account  8533019PH
        DemObj1.Max_Promise_Date__c=System.today();
        DemObj1.RDD__c=System.today().adddays(-1);
        //DemObj1.CADD_Owner__c='Test@gmail.com';
        //DemObj1.Customer_Delivery_Partner_Email__c='Testw@gmail.com';
        Insert DemObj1;
        Test.StopTest();
       
        object resultObj = DemingService.DemingRequestInfo(dr1 );
        System.assert(resultObj!=null);
        CADD_Management_History__c cdObj = [select id from CADD_Management_History__c where Order_Id__c='Line1234' limit 1 ];
        System.assert(cdObj.id!=null);
        DemingService.DemingRequestInfo(dr2); 
        DemingService.DemingRequestInfo(dr3); 
        DemingService.DemingRequestInfo(null); 
        DemingService.DemingRequestInfo(dr); 
    }   
    
    
    static testMethod void myTest() {
        CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
        TargetObjectIdEmial.UserID__c=NSCCommonInfoUtil.getIdOf('AtmPrcsUserId');
        TargetObjectIdEmial.Name='Do Not Reply User For CADD';
        insert TargetObjectIdEmial;
        Account acc = [SELECT Id, Name,Account_Country_Code__c, Master_Customer_Number__c,Owner.Email,Owner.Quicklook_ID__c FROM Account LIMIT 1];
        
        Sales_Org_Temp__c sotemp  = [SELECT Id,Sales_Org_Code__c,Hierarchy_2__c FROM Sales_Org_Temp__c LIMIT 1];
        
        NCR_Employee_Detail__c ncrEmp = [SELECT Id, Name, Global_ID__c,Quicklook_ID__c,InActive__c FROM NCR_Employee_Detail__c LIMIT 1];
        
        EDBI_Order__c orderHeader = [SELECT Id, Order_Number_with_Country_Code__c FROM EDBI_Order__c LIMIT 1];
        
        ERP_Orders_Backlog__c erpOrder = [SELECT Id,Order_Number__c,Order_Line_Id__c FROM ERP_Orders_Backlog__c LIMIT 1];
        
        //DemingService.DemingRequestInfo(createDemingRecord(acc, erpOrder,  sotemp, ncrEmp.Global_ID__c));
        Deming__c DemObj= new Deming__c();
        DemObj.Order_Id__c='47593451';                                      //Select id,Order_Number__c,Order_Line_Id__c from ERP_Orders_Backlog__c          208395648
        DemObj.SalesPerson_Global_Id__c='14200124419-201100959';             //Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c  41477033784-20110098
        DemObj.SalesOrdCode__c='201100959';                                //Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c
        DemObj.Customer_No__c='8511908';
        DemObj.Order_number__c='5340549';
        DemObj.Customer_Country_code__c= 'US'; //Select id,Name,Master_Customer_Number__c,Owner.Email from Account  8533019PH
        DemObj.Max_Promise_Date__c=System.today();
        DemObj.RDD__c=System.today().adddays(-1);
        //DemObj.CADD_Owner__c='Test@gmail.com';
        //DemObj.Customer_Delivery_Partner_Email__c='Testw@gmail.com';
        system.debug('DemObj---------------------------------------'+DemObj);
        insert DemObj;
        Deming__c dm = [SELECT Id FROM Deming__c LIMIT 1];
        dm.Cadd_Status__c='Approved';
        dm.IsSalespersonFound__c = false;
        dm.Is_Account_Manager__c = true;
        dm.RDD__c=System.today().adddays(1);
        update dm;
        Deming__c dmObj = [select id,Is_Account_Manager__c from deming__c where id=:dm.id];
        DemingEmailServiceClass.CreateShareRecord(UserInfo.getUserId(),'Edit', dm.id);
        System.assert(dmObj.Is_Account_Manager__c == true);
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
        dr.RDD = Date.today().addDays(-1);
        dr.maxPromiseDate = Date.today();
        dr.maxScheduledShipDate = Date.today();
        dr.maxScheduledArrivalDate = Date.today();
        dr.CDPName = 'Test Partner';
        dr.CDPGlobalId = 'PRTGID12345';
        dr.CISName = 'CIS User';
        dr.CISGlobalId = 'CISGID12345';
        dr.reasonCode = 'Customer Request';
        dr.customerIndustry = 'Test Hierarchy';
        dr.partyNumber = 'East1234';
        dr.salesOrdCode = sotemp.Sales_Org_Code__c;
        
        //insert dr;
        return dr;
    }
    public static AccountTeamMember createAccountTeamMember(Id accId, Id userId) {
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = accId, UserId = userId, TeamMemberRole = 'Customer Success Manager');
        insert accTeamMember;
        return accTeamMember;
    }
    
}