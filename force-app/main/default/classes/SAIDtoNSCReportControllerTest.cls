@IsTest
Public class SAIDtoNSCReportControllerTest{

static testMethod void testreports(){
User u =[select id,name,Quicklook_ID__c from User where Quicklook_ID__c='sh126812'];
 system.runAs(u)  {
 open_invoice_summary_vw__x mockedCust1 = new open_invoice_summary_vw__x(
        customer_name__c='JPMORGAN CHASE BANK Test1',
        invoice_nbr__c='6006446099',
        invoice_date__c=system.today(),
        invoice_age__c=Decimal.valueof(343),
        aging_date__c='000-030 Days',
        amt_due_orig_us__c=Decimal.valueof(132),
        amt_due_remain_us__c=Decimal.valueof(234),
        quick_look_id__c='sh126812',
        customer_nbr__c='27429' 
    );
   SAIDtoNSCReportController.mockedcustlist.add(mockedCust1);
   SAIDtoNSCReportController controller=new SAIDtoNSCReportController();
                     
   controller.selectedInvoiceAge='000-030 Days';
   controller.selectedreports ='A/R Aging';  
   controller.selectedInvoiceAge ='Select a Age';   
   controller.getARaging();
   controller.getARagingfilter();  
   controller.selectreport();
   controller.selectinvoiceAge(); 
   controller.disablefilter=true;
   controller.selectdaysforsections();
   SAIDtoNSCReportController.testone();
   SAIDtoNSCReportController.testtwo();
   SAIDtoNSCReportController.testthre();
   
        
 }        
    
   }
   
   static testMethod void testreports1(){
    User u =[select id,name,Quicklook_ID__c from User where Quicklook_ID__c='sh126812'];
   system.runas(u){
  
    current_year_order_summary_vw__x mockedCust2 = new current_year_order_summary_vw__x (
        customer_name__c='JPMORGAN CHASE BANK Test2',
        mth_net_line_order_value__c=Decimal.valueof(12),
        master_customer_nbr__c='23244',
        customer_po_nbr__c='567',
        order_nbr__c=Decimal.valueof(1362),
        quote_nbr__c='4446',
        quick_look_id__c='sh126812',
        order_booked_date__c=system.today(),    
        mth_net_line_order_value_us__c=Decimal.valueof(27428), 
        order_booked_quater__c='Q3',
        order_booked_month__c='Date.Today().Month()' 
        );
          
    SAIDtoNSCReportController.mockedcustlist14.add(mockedCust2);
    SAIDtoNSCReportController controller1=new SAIDtoNSCReportController();
        controller1.selectedreports ='Booked Order QTD';
        controller1.selectedMonth='Months';
        controller1.selectedquarter='Quarters';
        controller1.currentmonth = String.Valueof(Date.Today().Month());
        controller1.getOrdersQuarterFilter();
        controller1.getOrdersMonthFilter();
        controller1.getShipmentSectionDetails();
        controller1.selectreport();
        controller1.selectMonth();
        controller1.selectQuarter();
        controller1.getBookedOrders();
        controller1.getOpenOrders();      
    }
  }
  
  
  static testMethod void testreports4(){
  User u =[select id,name,Quicklook_ID__c from User where Quicklook_ID__c='sh126812'];
  system.runAs(u)  { 
    current_year_order_summary_vw__x mockedCust4 = new current_year_order_summary_vw__x (
        customer_name__c='JPMORGAN CHASE BANK Test2',
        mth_net_line_order_value__c=Decimal.valueof(453),
        master_customer_nbr__c='231232',
        customer_po_nbr__c='567',
        order_nbr__c=Decimal.valueof(136),
        quote_nbr__c='4442',
        quick_look_id__c='sh126812',    
        mth_net_line_order_value_us__c=Decimal.valueof(2721), 
        order_booked_quater__c='Q1',
        order_booked_month__c='Date.Today().Month()' 
        ); 
           
    SAIDtoNSCReportController.mockedcustlist13.add(mockedCust4);
    SAIDtoNSCReportController controller3 =new SAIDtoNSCReportController();
    controller3.currentmonth ='7';
    controller3.selectedreports ='Booked Order YTD';
    controller3.selectedMonth='Months';
    controller3.selectedquarter='Quarters';               
    controller3.selectreport();
    controller3.selectMonth();
    controller3.selectQuarter();
    controller3.getBookedOrders();
       
  }
}
  static testMethod void testreports5(){
  User u =[select id,name,Quicklook_ID__c from User where Quicklook_ID__c='sh126812'];
  system.runAs(u)  { 
    current_year_rev_summary_vw__x mockedCust5 = new current_year_rev_summary_vw__x(
        master_customer_name__c='JPMORGAN CHASE BANK Test5',
        dist_amt_us__c=Decimal.valueof(443),
        master_customer_nbr__c='231987',
        customer_po_nbr__c='231',
        order_nbr__c=Decimal.valueof(154),
        quick_look_id__c='sh126812',    
         invoice_date__c=system.today(),
        invoice_quater__c='Q3',
        invoice_month__c='Date.Today().Month()' 
        );    
    SAIDtoNSCReportController.mockedcustlist21.add(mockedCust5);
    SAIDtoNSCReportController controller4 =new SAIDtoNSCReportController();
                controller4.selectedreports ='Revenue MTD';
                controller4.getRevenudetails();
                controller4.getRevenuMonthdetails();
                controller4.getRevenuQuarterdetails();
                controller4.selectreport();
                controller4.selectMonth();
                controller4.selectQuarter();               
                controller4.currentmonth =String.Valueof(Date.Today().Month());  
   
  }
 }
   static testMethod void testreports6(){
   SAIDtoNSCReportController controller6 =new SAIDtoNSCReportController();
   open_order_summary_vw__x mockedCust15 = new open_order_summary_vw__x (
   customer_name__c='testcustomer',
    master_customer_nbr__c='3133',
    customer_po_nbr__c='675',
    quote_nbr__c='23124',
    order_nbr__c=Decimal.valueof(154),
    current_requested_date__c=system.today(),
    order_booked_date__c=system.today()-3,
    sched_arrival_date_time__c=system.today()+30,
    committed_ship_date__c=system.today()+3,
    sched_ship_date_time__c=system.today()+30,
    ship_confirm_date__c=system.today()+30,
    mth_net_line_order_value__c=Decimal.valueof(1544),
    mth_net_line_order_value_us__c=Decimal.valueof(6154),
    quick_look_id__c='sk185411'
  );
  
   controller6.selectedreports ='Open Orders';
   controller6.getOpenOrders();
  }
 static testMethod void testreports7(){
   SAIDtoNSCReportController controller7 =new SAIDtoNSCReportController();
       controller7.getOrderSectionDetails();
       controller7.getShipmentSectionDetails();
       controller7.getInvoiceSectionDetails();
       controller7.selecteddays='07 Days';
       
       
   }
  
   }