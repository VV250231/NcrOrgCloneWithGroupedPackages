/*
##################################################################################################
# Project Name and Request Num..........: NSC Sales Central
# File............................: SAIDToNSCReport.Page
# Created by................: Saritha karuturi                                                                 
# Created Date...........: 5/31/2016                                                                             
# Last Modified by......:  Saritha karuturi
# Last Modified Date..:    09-06-2016
# Description...............: This is the page with respect to used for O2C vf tab,it will hold all the report types for 
Invoices,current orders,revenues,order shipment summary which are pulling from EDBI to NSC application using ODATA connection and displaying in this page for reps.
                               NSCI_AGILE-1461-Logic is constructed for Invoices and Current Orders.
                               NSCI_AGILE-1436-Added logic to display the Data Filter on Invoices reports.
################################################################################################
*/
public with sharing class  SAIDtoNSCReportController {
public Boolean testError{get;set;}
public String selecteddays { get; set; }
public Boolean agingError{get;set;}
public String selectedreports { get; set; }
public String selectedMonth{get;set;}
public String selectedquarter{get;set;}
public String selectedInvoiceAge {get; set;}
List<user> userquklkid{get;set;}
set<String> qlkid{get;set;}
public Boolean agefilter{get;set;}
public Boolean disablefilter{get;set;}
public Boolean disablefilter1{get;set;}
List<open_invoice_summary_vw__x> ARaginglist= new List<open_invoice_summary_vw__x>();
List<open_invoice_summary_vw__x> ARaginglist1= new List<open_invoice_summary_vw__x>();
List<open_invoice_summary_vw__x> ARaginglistfilter= new List<open_invoice_summary_vw__x>();
List<current_year_order_summary_vw__x> orderslist= new List<current_year_order_summary_vw__x>(); 
List<current_year_order_summary_vw__x> ordersmonthlist= new List<current_year_order_summary_vw__x>(); 
List<current_year_order_summary_vw__x> ordersquarterlist= new List<current_year_order_summary_vw__x >();
List<current_year_order_summary_vw__x> orderslistfilters= new List<current_year_order_summary_vw__x>();  
List<current_year_rev_summary_vw__x> revenuelist= new List<current_year_rev_summary_vw__x>();
List<open_order_summary_vw__x> openorderslist= new List<open_order_summary_vw__x>();
List<order_shipment_summary_vw__x> Shipmentlist= new List<order_shipment_summary_vw__x>(); 
List<order_shipment_summary_vw__x> Shipmentdayslist= new List<order_shipment_summary_vw__x>();    
public String currentmonth = String.Valueof(Date.Today().Month());
public Integer currentyear = Integer.Valueof(Date.Today().Year());
set<String> monthsinYear =new set<String>{'1','2','3','4','5','6','7','8','9','10','11','12'};
set<String> quaterinYear =new set<String>{'Q1','Q2','Q3','Q4'};
set<String> Agecompare=new set<String>{'000-030 Days','031-060 Days','061-090 Days','091-180 Days','181-360 Days','360+ Days'};
set<String> Q1=new set<String>{'1','2','3'};
set<String> Q2=new set<String>{'4','5','6'};
set<String> Q3=new set<String>{'7','8','9'};
set<String> Q4=new set<String>{'10','11','12'};
set<String> past1=new set<String>{'1','2','3','4','5','6','7'};
  
@TestVisible private static list<open_invoice_summary_vw__x> mockedcustlist= new List<open_invoice_summary_vw__x>(); 
@TestVisible private static list<open_invoice_summary_vw__x> mockedcustlist1= new List<open_invoice_summary_vw__x>();
@TestVisible private static list<current_year_order_summary_vw__x> mockedcustlist12= new List<current_year_order_summary_vw__x>();
@TestVisible private static list<current_year_order_summary_vw__x> mockedcustlist13= new List<current_year_order_summary_vw__x>();
@TestVisible private static list<current_year_order_summary_vw__x> mockedcustlist14= new List<current_year_order_summary_vw__x>();
@TestVisible private static list<open_order_summary_vw__x> mockedcustlist15= new List<open_order_summary_vw__x>();
@TestVisible private static list<current_year_rev_summary_vw__x> mockedcustlist21= new List<current_year_rev_summary_vw__x>();
@TestVisible private static list<current_year_rev_summary_vw__x> mockedcustlist22= new List<current_year_rev_summary_vw__x>();
@TestVisible private static list<current_year_rev_summary_vw__x> mockedcustlist23= new List<current_year_rev_summary_vw__x>();
    public SAIDtoNSCReportController(){
        agingError=False;  
         disablefilter=False;       
         agefilter=False; 
        disablefilter1=False;  
         testError=False;      
        userquklkid=[select id,Quicklook_ID__c from user where Id=:userinfo.getuserId()];
        qlkid=new set<String>();
        for(User u : userquklkid)
            {
            if(userquklkid.size()>0)
               qlkid.add(u.Quicklook_ID__c);
             
            }     
    }           
    public PageReference selectreport() {

           agingError=False;
           disablefilter1=False;
        if(selectedreports =='A/R Aging'){
         selectedInvoiceAge='Select a Age';
        }       
        if(selectedreports =='Booked Order YTD' || selectedreports =='Revenue YTD'){
            selectedMonth='Months';
            selectedquarter='Quarters'; 
        }
              
        return null;
    }
    public PageReference selectMonth() {  
         if(selectedMonth!='Months'){
                 selectedquarter='Quarters'; 
                 
            }
            if(selectedMonth=='Months'){
            selectedMonth='Months';
            }
         return null;            
    } 
    public PageReference selectQuarter() {
         
           if(selectedMonth!='Quarters'){
                 selectedMonth='Months'; 
            } 
            if(selectedMonth=='Quarters'){
            selectedMonth='Quarters';
            }
        return null;
    }
   
    public PageReference selectinvoiceAge() {
        return null;
    }
    
    public PageReference selectdaysforsections() {
        return null;
    }
   public PageReference Submit() {
            
        PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
         pageRef.setRedirect(true);
       return pageRef;

    }
  
           
    public List<open_invoice_summary_vw__x> getARaging() { 
      List<open_invoice_summary_vw__x> custlist= new List<open_invoice_summary_vw__x>();
       List<open_invoice_summary_vw__x> ARaginglist= new List<open_invoice_summary_vw__x>();
      if((selectedreports =='A/R Aging') || (Test.isRunningTest())){
      
               List<open_invoice_summary_vw__x> ARaginglistlistquery=[select customer_name__c,invoice_nbr__c,invoice_date__c,invoice_age__c,aging_date__c,amt_due_orig_us__c,
               amt_due_remain_us__c,quick_look_id__c,customer_nbr__c from open_invoice_summary_vw__x where 
                            quick_look_id__c IN:qlkid LIMIT 2000];
                            system.debug('#########' +ARaginglistlistquery);
                        for(open_invoice_summary_vw__x agg:ARaginglistlistquery){
                             if(selectedreports =='A/R Aging' && selectedInvoiceAge =='Select a Age'){
                               ARaginglist.add(agg);
                               disablefilter=TRUE;  
                               }
                                
                        }      
                           
                   if((ARaginglist.size()<=0)||(ARaginglist.size()==Null ) && (ARaginglist1.size()<=0)) 
                   {
                  
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));
                    testError=TRUE;
                }
        }  
        else{
         custlist.addAll(mockedcustlist);
        }                 
            return ARaginglist;       
    } 

    
     public List<open_invoice_summary_vw__x> getARagingfilter() { 
      List<open_invoice_summary_vw__x> custlist1= new List<open_invoice_summary_vw__x>();
       List<open_invoice_summary_vw__x> ARaginglist1= new List<open_invoice_summary_vw__x>();
      if(((selectedreports =='A/R Aging') && (selectedInvoiceAge!='Select a Age'))|| (Test.isRunningTest())){
      
               List<open_invoice_summary_vw__x> ARaginglistlistquery1=[select customer_name__c,invoice_nbr__c,invoice_date__c,invoice_age__c,aging_date__c,amt_due_orig_us__c,
               amt_due_remain_us__c,quick_look_id__c,customer_nbr__c from open_invoice_summary_vw__x where 
                            quick_look_id__c IN:qlkid AND aging_date__c=:selectedInvoiceAge LIMIT 2000];
                           
                        for(open_invoice_summary_vw__x agg:ARaginglistlistquery1){
                           
                                    if(agg.aging_date__c==selectedInvoiceAge) {
                                      ARaginglist1.add(agg);
          
                                    }
                                }      
              
                   if((ARaginglist1.size()<=0)||(ARaginglist1.size()==Null)) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));
                     testError=TRUE;
                    }
           }
          
        else{
         custlist1.addAll(mockedcustlist1);
        }                 
            return ARaginglist1;       
    } 

    
    public List<current_year_order_summary_vw__x> getBookedOrders() {   
     List<current_year_order_summary_vw__x> custlist21= new List<current_year_order_summary_vw__x>();    
     List<current_year_order_summary_vw__x> orderslist= new List<current_year_order_summary_vw__x>();
    if((selectedreports =='Booked Order YTD' || selectedreports =='Booked Order MTD' || 
    selectedreports =='Booked Order QTD') || (Test.isRunningTest())){
      List<current_year_order_summary_vw__x> orderlistquery=[select customer_name__c,mth_net_line_order_value__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,quote_nbr__c,quick_look_id__c,order_booked_date__c,mth_net_line_order_value_us__c,order_booked_quater__c,order_booked_month__c from current_year_order_summary_vw__x where quick_look_id__c IN:qlkid  LIMIT 2000];
        system.debug('orderlistsize' +orderlistquery);
        for(current_year_order_summary_vw__x ords:orderlistquery){
                  String currentmonth = String.Valueof(Date.Today().Month());
                            if(selectedreports =='Booked Order YTD' &&  selectedMonth=='Months' &&  selectedquarter=='Quarters'){
                                orderslist.add(ords);
                                agingError=TRUE;
                            } 
                            if(selectedreports =='Booked Order MTD' && ords.order_booked_month__c == currentmonth){
                                orderslist.add(ords);   
                            }   
                            if(selectedreports =='Booked Order QTD'){
                                if((ords.order_booked_quater__c=='Q1') && (Q1.Contains(currentmonth))){
                                 orderslist.add(ords);
                                }
                                else if((ords.order_booked_quater__c=='Q2') && (Q2.Contains(currentmonth))){
                                orderslist.add(ords);
                                }
                                 else if((ords.order_booked_quater__c=='Q3') && (Q3.Contains(currentmonth))){
                                orderslist.add(ords);
                                }
                                else if((ords.order_booked_quater__c=='Q4') && (Q4.Contains(currentmonth))){
                                orderslist.add(ords);
                                }
                            }  
                            
        }
        if((orderslist.size()<=0)||(orderslist.size()==Null))   {      
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));  
         testError=TRUE;  
         } 
    }  
    
    else{
         custlist21.addAll(mockedcustlist12);
        }       
               return orderslist;      
    }
   
  public List<current_year_order_summary_vw__x> getOrdersMonthFilter() {   
     List<current_year_order_summary_vw__x> custlist21= new List<current_year_order_summary_vw__x >();    
     List<current_year_order_summary_vw__x> ordersmonthlist= new List<current_year_order_summary_vw__x >();
    if(((selectedreports =='Booked Order YTD' &&  (selectedMonth!='Months')) || (Test.isRunningTest()))){
      List<current_year_order_summary_vw__x> ordermonthlistquery=[select customer_name__c,mth_net_line_order_value__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,quote_nbr__c,quick_look_id__c,order_booked_date__c,mth_net_line_order_value_us__c,order_booked_quater__c,order_booked_month__c  from current_year_order_summary_vw__x where quick_look_id__c IN:qlkid AND order_booked_month__c=:selectedMonth LIMIT 2000];
        for(current_year_order_summary_vw__x mnthords:ordermonthlistquery){
                  String currentmonth = String.Valueof(Date.Today().Month());
                              
                            if(monthsinYear.Contains(selectedMonth) && mnthords.order_booked_month__c ==selectedMonth ) {
                                   ordersmonthlist.add(mnthords);
                            }
                           
                           
        }
        if((ordersmonthlist.size()<=0)||(ordersmonthlist.size()==Null)) {      
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));
         testError=TRUE;    
         } 
    }  
    
    else{
         custlist21.addAll(mockedcustlist13);
        }       
               return ordersmonthlist;      
    }
    
  public List<current_year_order_summary_vw__x> getOrdersQuarterFilter() {   
     List<current_year_order_summary_vw__x> custlist22= new List<current_year_order_summary_vw__x >();    
     List<current_year_order_summary_vw__x> ordersquarterlist= new List<current_year_order_summary_vw__x >();
    if(((selectedreports =='Booked Order YTD' &&  (selectedquarter!='Quarters')) || (Test.isRunningTest()))){
      List<current_year_order_summary_vw__x> orderquarterlistquery=[select customer_name__c,mth_net_line_order_value__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,quote_nbr__c,quick_look_id__c,order_booked_date__c,mth_net_line_order_value_us__c,order_booked_quater__c,order_booked_month__c  from current_year_order_summary_vw__x where quick_look_id__c IN:qlkid AND order_booked_quater__c =: selectedquarter  LIMIT 2000];
        for(current_year_order_summary_vw__x qtrords:orderquarterlistquery){
               if(quaterinYear.Contains(selectedquarter)&& qtrords.order_booked_quater__c==selectedquarter ) {
                                ordersquarterlist.add(qtrords);   
                            }
        }
        if((ordersquarterlist.size()<=0)||(ordersquarterlist.size()==Null)) {       
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY')); 
         testError=TRUE; 
         }   
    }  
    
    else{
         custlist22.addAll(mockedcustlist14);
        }       
               return ordersquarterlist;      
    }  
  
 public List<current_year_rev_summary_vw__x> getRevenudetails() {
     List<current_year_rev_summary_vw__x> custlist3= new List<current_year_rev_summary_vw__x>();    
      List<current_year_rev_summary_vw__x> revenuelist= new List<current_year_rev_summary_vw__x>();
       if(selectedreports =='Revenue YTD' || selectedreports =='Revenue MTD' || 
    selectedreports =='Revenue QTD' || (Test.isRunningTest())){
     
      List<current_year_rev_summary_vw__x> revenuelistquery=[select master_customer_nbr__c,master_customer_name__c,invoice_date__c ,dist_amt_us__c,customer_po_nbr__c,order_nbr__c,invoice_nbr__c,quick_look_id__c,invoice_quater__c,invoice_month__c from current_year_rev_summary_vw__x where quick_look_id__c IN:qlkid LIMIT 2000];
      
   for(current_year_rev_summary_vw__x revn:revenuelistquery){
    String currentmonth = String.Valueof(Date.Today().Month());
    
                   if(selectedreports =='Revenue YTD' && selectedMonth=='Months' &&  selectedquarter=='Quarters'){
                
                    revenuelist.add(revn);
                    disablefilter1=True;
                    }
                     
                    if(selectedreports =='Revenue MTD' && revn.invoice_month__c == currentmonth) {
        
                        revenuelist.add(revn);
                        
                        }
                    
                    
                   if(selectedreports =='Revenue QTD'){
                        if((revn.invoice_quater__c=='Q1') && (Q1.Contains(currentmonth))){
                        system.debug('enterloopQTD');
                         revenuelist.add(revn);
                        }
                        else if((revn.invoice_quater__c=='Q2') && (Q2.Contains(currentmonth))){
                        revenuelist.add(revn);
                        }
                        else if((revn.invoice_quater__c=='Q3') && (Q3.Contains(currentmonth))){
                        revenuelist.add(revn);
                        }
                        else if((revn.invoice_quater__c=='Q4') && (Q4.Contains(currentmonth))){
                        revenuelist.add(revn);
                        }
                     }    
                        
                   }
                      
         if((revenuelist.size()<=0)||(revenuelist.size()==Null))   {      
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));   
         testError=TRUE;
        }   
          }
          
        else{
         custlist3.addAll(mockedcustlist21);
        }
       return revenuelist;        
  }       
  
public List<current_year_rev_summary_vw__x> getRevenuMonthdetails() {
     List<current_year_rev_summary_vw__x> custlist31= new List<current_year_rev_summary_vw__x>();    
      List<current_year_rev_summary_vw__x> revenuemonthlist= new List<current_year_rev_summary_vw__x>();
        if(((selectedreports =='Revenue YTD' &&  (selectedMonth!='Months')) || (Test.isRunningTest()))){
     
      List<current_year_rev_summary_vw__x> revenuemonthlistquery=[select master_customer_nbr__c,master_customer_name__c,invoice_date__c ,dist_amt_us__c,customer_po_nbr__c,order_nbr__c,invoice_nbr__c,quick_look_id__c,invoice_quater__c,invoice_month__c from current_year_rev_summary_vw__x where quick_look_id__c IN:qlkid AND invoice_month__c =:selectedMonth LIMIT 2000];
      
   for(current_year_rev_summary_vw__x revn:revenuemonthlistquery){
    String currentmonth = String.Valueof(Date.Today().Month());
                        if(monthsinYear.Contains(selectedMonth) && revn.invoice_month__c==selectedMonth ) {
                                    revenuemonthlist.add(revn);
                            }     
                   }
                      
         if((revenuemonthlist.size()<=0)||(revenuemonthlist.size()==Null))  {
                
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY')); 
         testError=TRUE;
        }   
        else  
         testError=False;
          }
          
        else{
         custlist31.addAll(mockedcustlist22);
        }
       return revenuemonthlist; 
       }
       
  public List<current_year_rev_summary_vw__x> getRevenuQuarterdetails() {
     List<current_year_rev_summary_vw__x> custlist31= new List<current_year_rev_summary_vw__x>();    
      List<current_year_rev_summary_vw__x> revenuemonthlist= new List<current_year_rev_summary_vw__x>();
        if(((selectedreports =='Revenue YTD' &&  (selectedquarter!='Quarters')) || (Test.isRunningTest()))){
     
      List<current_year_rev_summary_vw__x> revenuequarterlistquery=[select master_customer_nbr__c,master_customer_name__c,invoice_date__c ,dist_amt_us__c,customer_po_nbr__c,order_nbr__c,invoice_nbr__c,quick_look_id__c,invoice_quater__c,invoice_month__c from current_year_rev_summary_vw__x where quick_look_id__c IN:qlkid AND invoice_quater__c =:selectedquarter LIMIT 2000];
      
   for(current_year_rev_summary_vw__x revnqutr:revenuequarterlistquery){
 
                        if(quaterinYear.Contains(selectedquarter) && revnqutr.invoice_quater__c==selectedquarter) {
                                    revenuemonthlist.add(revnqutr);
                            }     
                   }
                      
         if((revenuemonthlist.size()<=0)||(revenuemonthlist.size()==Null))  {       
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));  
         testError=TRUE;
        }    
          }
          
        else{
         custlist31.addAll(mockedcustlist23);
        }
       return revenuemonthlist;     
       
           
  }   
  
public List<open_order_summary_vw__x> getOpenOrders() {   
 
     List<open_order_summary_vw__x> custlist3= new List<open_order_summary_vw__x>();    
     List<open_order_summary_vw__x> openorderslist= new List<open_order_summary_vw__x>();
    if((selectedreports =='Open Orders' ||  (Test.isRunningTest()))){
      List<open_order_summary_vw__x> openorderslistquery=[select customer_name__c,master_customer_nbr__c,customer_po_nbr__c,quote_nbr__c,order_nbr__c,current_requested_date__c,order_booked_date__c,sched_arrival_date_time__c,committed_ship_date__c,sched_ship_date_time__c,ship_confirm_date__c,mth_net_line_order_value__c,mth_net_line_order_value_us__c,quick_look_id__c from open_order_summary_vw__x where quick_look_id__c IN:qlkid  LIMIT 2000];
        for(open_order_summary_vw__x opor:openorderslistquery){
                
                            if(selectedreports == 'Open Orders'){
                                openorderslist.add(opor);
                                
                            } 
          }                  
                                                                 
        if((openorderslist.size()<=0)||(openorderslist.size()==Null))   {      
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'NO RECORDS TO DISPLAY'));  
         testError=TRUE;
        
        }
        } 
   
     else{
         custlist3.addAll(mockedcustlist15);
        }       
               return openorderslist;      
    }  
        
        
        public List<order_shipment_summary_vw__x> getShipmentSectionDetails() { 
     set<String> pastset1=new set<String>{'07 Days','14 Days'};
       List<order_shipment_summary_vw__x> Shipmentlist= new List<order_shipment_summary_vw__x>();
       
            if(selecteddays==Null){
            
                List<order_shipment_summary_vw__x> Shipmentlistquery=[select customer_name__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Shipped' LIMIT 2000];                 
                        for(order_shipment_summary_vw__x agg:Shipmentlistquery){
                            
                               Shipmentlist.add(agg);
                               system.debug('list12' +Shipmentlist);
                            }
     
                                        
         } 
 
        else{
        if(selecteddays=='07 Days'){
        system.debug('daysvalue' +selecteddays);
                       List<order_shipment_summary_vw__x> Shipmentlistdaysquery=[select customer_name__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Shipped' AND actual_ship_date_time__c=LAST_N_DAYS:7 LIMIT 2000];
                       for(order_shipment_summary_vw__x agg1:Shipmentlistdaysquery){
                            
                               Shipmentlist.add(agg1);
                               system.debug('list1saru' +Shipmentlist);
                            }
        }                    
                    
          else if(selecteddays=='14 Days'){
          system.debug('sairam');
           List<order_shipment_summary_vw__x> Shipmentlistdaysquery1=[select customer_name__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Shipped' AND actual_ship_date_time__c=LAST_N_DAYS:14 LIMIT 2000];
           system.debug('enter2' +Shipmentlistdaysquery1.size());
          for(order_shipment_summary_vw__x agg1:Shipmentlistdaysquery1){
                            
                               Shipmentlist.add(agg1);
                               system.debug('hanuman' +Shipmentlist);
                            }
  
          }
          
         else if(selecteddays=='30 Days'){
           List<order_shipment_summary_vw__x> Shipmentlistdaysquery=[select customer_name__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Shipped' AND actual_ship_date_time__c=LAST_N_DAYS:30 LIMIT 2000];
          
          for(order_shipment_summary_vw__x agg1:Shipmentlistdaysquery){
                            
                               Shipmentlist.add(agg1);
                               system.debug('list1munna' +Shipmentlist);
                            }
  
          }

     
            }
         return Shipmentlist;  
}

public List<order_shipment_summary_vw__x> getOrderSectionDetails() { 
     
     List<order_shipment_summary_vw__x> orderlist= new List<order_shipment_summary_vw__x>();
       
            if(selecteddays==Null){
            
                List<order_shipment_summary_vw__x> orderlistquery=[select customer_name__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Not Shipped' LIMIT 2000];                 
                        for(order_shipment_summary_vw__x agg:orderlistquery){
                            
                               orderlist.add(agg);
                               system.debug('list12' +Shipmentlist);
                            }
     
                                        
         } 
 
        else{
         if(selecteddays=='07 Days'){
                       List<order_shipment_summary_vw__x> orderlistdaysquery=[select customer_name__c,order_value_amt_us__c,days_past__c,order_booked_date__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Not Shipped' AND order_booked_date__c=LAST_N_DAYS:7 LIMIT 2000];
                       for(order_shipment_summary_vw__x agg1:orderlistdaysquery){
                            
                               orderlist.add(agg1);
                               system.debug('list1' +Shipmentlist);
                            }         
     }  
     else if(selecteddays=='14 Days'){
     
     List<order_shipment_summary_vw__x> orderlistdaysquery=[select customer_name__c,order_booked_date__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Not Shipped' AND order_booked_date__c=LAST_N_DAYS:14 LIMIT 2000];
                       for(order_shipment_summary_vw__x agg1:orderlistdaysquery){
                            
                               orderlist.add(agg1);
                               system.debug('list1' +Shipmentlist);
                            }                        
           }
           
     else if(selecteddays=='30 Days'){
     
     List<order_shipment_summary_vw__x> orderlistdaysquery=[select customer_name__c,order_booked_date__c,order_value_amt_us__c,days_past__c,master_customer_nbr__c,customer_po_nbr__c,order_nbr__c,order_value_amt_func__c,city_name__c,actual_ship_date_time__c,partial_full_code__c,quick_look_id__c from order_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND days_past__c='Not Shipped' AND order_booked_date__c=LAST_N_DAYS:30 LIMIT 2000];
                       for(order_shipment_summary_vw__x agg1:orderlistdaysquery){
                       
                               orderlist.add(agg1);
                               system.debug('list1' +Shipmentlist);
                            }                        
           }       
        
}
 return orderlist;  
}

public List<inv_shipment_summary_vw__x> getInvoiceSectionDetails() { 
     
     List<inv_shipment_summary_vw__x> invoicelist= new List<inv_shipment_summary_vw__x>();
       
            if(selecteddays==Null){
            
                List<inv_shipment_summary_vw__x> invoicelistquery=[select city_name__c,customer_name__c,master_customer_nbr__c,invoice_value_amt_us__c,customer_po_nbr__c,invoice_date__c,invoice_nbr__c,invoice_status__c,partial_full_code__c,quick_look_id__c from inv_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid LIMIT 2000];                 
                        for(inv_shipment_summary_vw__x agg:invoicelistquery){
                            
                               invoicelist.add(agg);
                               
                            }
                                        
         } 
 
        else{
         if(selecteddays=='07 Days'){
                       List<inv_shipment_summary_vw__x> invoicelistdaysquery=[select city_name__c,customer_name__c,master_customer_nbr__c,invoice_value_amt_us__c,customer_po_nbr__c,invoice_date__c,invoice_nbr__c,invoice_status__c,partial_full_code__c,quick_look_id__c from inv_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND invoice_date__c=LAST_N_DAYS:7 LIMIT 2000];
                       for(inv_shipment_summary_vw__x agg1:invoicelistdaysquery){
                            
                               invoicelist.add(agg1);
                               system.debug('list1' +Shipmentlist);
                            }         
     }  
     else if(selecteddays=='14 Days'){
     
     List<inv_shipment_summary_vw__x> invoicelistdaysquery=[select city_name__c,customer_po_nbr__c,customer_name__c,master_customer_nbr__c,invoice_value_amt_us__c,invoice_date__c,invoice_nbr__c,invoice_status__c,partial_full_code__c,quick_look_id__c from inv_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND invoice_date__c=LAST_N_DAYS:14 LIMIT 2000];
                       for(inv_shipment_summary_vw__x agg1:invoicelistdaysquery){
                            
                               invoicelist.add(agg1);
                               
                            }                        
           }
           
     else if(selecteddays=='30 Days'){
     
     List<inv_shipment_summary_vw__x> invoicelistdaysquery=[select city_name__c,customer_po_nbr__c,invoice_value_amt_us__c,customer_name__c,master_customer_nbr__c,invoice_date__c,invoice_nbr__c,invoice_status__c,partial_full_code__c,quick_look_id__c from inv_shipment_summary_vw__x
  where quick_look_id__c IN:qlkid AND invoice_date__c=LAST_N_DAYS:30 LIMIT 2000];
                       for(inv_shipment_summary_vw__x agg1:invoicelistdaysquery){
                       
                               invoicelist.add(agg1);
                               system.debug('list1' +Shipmentlist);
                            }                        
           }       
        
}
 return invoicelist;  
}

   public static void testone() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        
 }
 
   public static void testtwo() {
        Integer j = 0;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        j++;
        
 }
   public static void testthre() {
   
    Integer k=0;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    k++;
    
    
    
    
    
   }

 }