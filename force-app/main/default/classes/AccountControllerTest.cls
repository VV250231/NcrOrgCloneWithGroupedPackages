/*
####################################################################################################################
# Project Name..........: NSC INNOVATIONS 2016                                                                                                                            
# File............................: AccountController.cls                                                            
# Created by................: Mudasir Rashid                                                                       
# Created Date...........: 18-09-2016                                                                                  
# Last Modified by......: Saritha Karuturi                                                                           
# Last Modified Date..: 18-09-2016 ,10-19-2016                                                                               
# Description...............: This is the test class of AccountController class. 
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
####################################################################################################################
*/

@isTest
public class AccountControllerTest{
    public static testMethod void myTest(){
        Profile p = [SELECT id from Profile WHERE Name = '04 NSC UI Administrator' Limit 1];
                
        User u = new User(alias = 'standt', email='standarduser11@ncr.com',
                    emailencodingkey='UTF-8', lastname='Testing3',Quicklook_Id__c='ValProfl', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p.Id,timezonesidkey='America/Los_Angeles',
                    username='standarduser1@.ncr.com'+System.now().getTime()+'.com');
                    
       system.runAs(u){
           RecordType rt1 = [Select id from RecordType where Name='Customer'];//0127000000011t5AAA
           Account a = new Account(      
            Account_Country_Code__c = 'EG',
            Active_Account__c = true,        
            Master_Customer_Number__c = 'TESTMCN',
            Name = 'Unit Test ' + System.now(),
            RecordTypeId = rt1.id,
            RoR_Update_Date_Time__c = System.now(),
            Industry = 'RETAIL:CHANNEL',
            account_region__c='INDIA',
            Official_Temperature__c='Green'
             );
            system.runAs(TestRecordsFactory.getUser()){ 
   				insert a;
            }
    
           Majors_Product_Matrix__c mp1=new Majors_Product_Matrix__c (
           MCN__c='TESTMCN',
           New_Competetors__c='NCR;Diebod',
           Purchased_List__c='test1',
           Not_Sold_List__c='test2;test3',
           Producttoplines__c='test1;test2;test3'
           
           );
           insert mp1;
            ToplineCompetetors__c cs1 = new ToplineCompetetors__c();
                cs1.Competetors__c='test1;test2;test4;test4';
                cs1.name='testcs1';
                
             insert cs1;
      
      
      // create new sales org object 
        Sales_Org__c s = new Sales_Org__c (name = 'test org', Is_Active_in_RoR__c = true);
        insert s;
        
        //create new competitor object 
        Competitors__c c = new Competitors__c (name = 'testing competitor');
        insert c;
        
        
        // create new Opportunity object 
        Opportunity opp = new Opportunity(); 
        Id r1 = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Include in Funnel').getRecordTypeId();//012700000001PoZ = Include in Funnel
        opp.name = 'abc';
        opp.AccountID = a.id;
        opp.Name = 'Test Opportunity';
        opp.type = 'Indirect Channel';
       // opp.Solution_Portfolio__c = 'Entertainment Self Service';
        opp.CURRENCYISOCODE = 'USD';
        opp.SALES_ORG__C = s.id;
        opp.INVOICE_TRIGGER__C='Shipment';
        opp.CUSTOMER_SERVICE_AREA__C = 'WCS - US Northeast';
        opp.PRIMARY_COMPETITOR__C = c.id;
        opp.Expected_Delivery_Date__c = System.TODAY().addDays(30);
        opp.closeDate = System.TODAY();
        opp.stagename = 'Analyzing';
        opp.recordTypeId = r1;
        insert opp;
      

           
       AccountController.getAccount( a.Id );
       AccountController.getpickval();
       AccountController.saveAccount( a );
       AccountController.getUserProfile( a.Id );
       AccountController.ShowHodeEditWindowRevenue();
       AccountController.getAcountCompetetors(a.Id);
       AccountController.getAcountPurchasedlist(a.Id);
       AccountController.getAcountNotSoldlist(a.Id);
       AccountController.getOpportunityProducts(a.Id);
       AccountController.getOpportunityClosedProducts(a.Id);
       AccountController.saveCompetetors('inputest1');
       AccountController.getLabelofAccount();
       
       
       /*CustomerSuccessController.getAccount(a.Id);
       CustomerSuccessController.getpickval(a.id);
       CustomerSuccessController.getpickval_For_Satisfaction_Temp_Level(a.id);
       CustomerSuccessController.saveAccount(a);
       CustomerSuccessController.ShowHodeEditWindow();
       CustomerSuccessController.getUserProfile(a.Id);*/
   
       }
    
    }
}