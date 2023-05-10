@IsTest
public class EDBI_Order_TEST {
    static testMethod void myTest(){
        
        Account acc = TestRecordsFactory.createAccount('7392826','FINANCIAL:BANKING MAJOR','INDIA');
        createAccountTeamMember(acc.id,getUser());
        createAccountTeamMember(acc.id,TestRecordsFactory.getUser().id);
        
        Deming__C demObj=new Deming__C();
        demObj.Order_Id__c='5321';
        demObj.Order_Number__c='1662159';
        demObj.Customer_Country_code__c ='US';
        //demObj.Order_Nbr_with_Country_Code__c='1662159US';
        demObj.Order_Nbr_with_Country_CodeExtrnal__c='1662159US';
        demObj.Cadd_Status__c='Approved';
        //insert demObj;
        
        Opportunity Opp = new Opportunity();                               
        Opp.Name='Test';
        Opp.StageName='Prospecting';
        Opp.CloseDate=System.today();
        insert Opp;
        
        EDBI_Order__c edbiorder  = new EDBI_Order__c ();
        edbiorder.Order_Number_with_Country_Code__c='1662159US';
        edbiorder.Order_Number__c='1662159';
        edbiorder.Opportunity__C=Opp.Id;
        insert edbiorder;
        
        EDBI_Order__c edbiObj = [select id,Country_Code_With_Master_Customer_Nbr__c,Account_Lookup__c from EDBI_Order__c where id =:edbiorder.id];
        // Country_Code_With_Master_Customer_Nbr__c should be equal to Account_Lookup__c
        System.assert(edbiObj.Account_Lookup__c==null);
        edbiorder.Backlog_Orders_Status__c='cancelled';
        edbiorder.FUA_Site_Name__c='test'; 
        edbiorder.fua_site_nbr__c ='123';
        edbiorder.Order_Status__c ='cancelled';
        edbiorder.ship_to_site_name__c ='testShip';
        edbiorder.ship_to_site_nbr__c ='1321';
        update edbiorder;
        List<Deming__c> DemObjTOInsert= new List<Deming__c>();
        DemObjTOInsert.add(demObj);
        
        Deming__c dem= new Deming__c();
        dem.Order_Id__c='123';
        dem.Order_Number__c='123';
        dem.Include_In_Process__c=false;
        dem.EditShareWithUser__c=getUser();
        dem.Customer_Name__c='TestCustomer';
        dem.Customer_No__c='7392826';
        dem.Reason_Code__c='Supply';
        dem.Cadd_Owner__c='abc@test.com';
        dem.Max_Promise_Date__c=Date.today();
        dem.RDD__c=Date.today().addDays(1);
        dem.IsSalespersonFound__c=true;
        User u1=TestRecordsFactory.getUser();
        dem.EditShareWithUserSpFound__c=u1.Id;
        dem.Customer_Delivery_Partner_Email__c='ab1c@abc.com';
        dem.RelatedAccount__c=Acc.id;
        dem.Max_Promise_Date__c=system.today();
        dem.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        dem.RDD__c=system.today().addDAYS(-2);
        dem.Cadd_Status__c='Rejected';
        DemObjTOInsert.add(dem);
        
        Deming__c dem1= new Deming__c();
        dem1.Order_Id__c='234';
        dem1.Order_Number__c='234';
        dem1.Include_In_Process__c=false;
        dem1.EditShareWithUser__c=getUser();
        dem1.Customer_No__c='7392826';
        dem1.Reason_Code__c='Supply';
        dem1.Cadd_Owner__c='abc@test.com';
        dem1.Max_Promise_Date__c=Date.today();
        dem1.RDD__c=Date.today().addDays(-1);
        dem1.IsSalespersonFound__c=true;
        User u2=TestRecordsFactory.getUser();
        // dem1.EditShareWithUserSpFound__c=u2.ID;
        dem1.Customer_Delivery_Partner_Email__c='a1bc@abc.com';
        dem1.Customer_Name__c='Tes1tCustomer';
        dem1.Customer_No__c='7392826';
        dem1.RelatedAccount__c=Acc.id;
        dem1.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        dem1.Max_Promise_Date__c=system.today();
        dem1.RDD__c=system.today().addDAYS(2);
        
        DemObjTOInsert.add(dem1);
        insert DemObjTOInsert;
        
    }
    static testMethod void runUnitTest(){
        Test.startTest();
        
        
        Account acc=new Account();
        acc=TestRecordsFactory.createAccount();
        User u2 = TestRecordsFactory.getUser();
        System.runAs(u2){ 
            acc.Country_with_Master_customer_Number__c ='123454';  
            update acc;
        }
        Competitors__c comp=new Competitors__c ();
        comp=TestRecordsFactory.createCompetitor();
        
        Sales_Org__c  so=new Sales_Org__c();
        so=TestRecordsFactory.createSalesOrg();
        
        Sales_Org_Temp__c stObj  = new Sales_Org_Temp__c(Sales_Org_Code__c ='123456789');
        insert stObj;
        Opportunity opp = new Opportunity();
        opp=TestRecordsFactory.createSimpleOpportunity(acc);
        opp = [Select Id, Opportunity_Number__c from Opportunity where Id= :opp.Id Limit 1]; 
        
        QuBy_Detail__c QD1 = new QuBy_Detail__c();
        QD1.Name = 'TEST Quote';
        QD1.Quote_Number__c = '123';
        QD1.Country_Code__c = 'US';
        QD1.MCN__C = '25721';
        QD1.Quicklook_ID__c = 'ms250942';
        QD1.Solution_Quote_Amount__c=11000;
        QD1.CurrencyIsoCode='USD';
        QD1.Solution_Quote_Status__c='Acknowledged';
        QD1.Description__c = 'TEST NAME';
        QD1.Opportunity_No__c = opp.Opportunity_Number__c ;
        
        
        QuBy_Detail__c QD2 = new QuBy_Detail__c();
        QD2.Name = 'TEST Quote';
        QD2.Quote_Number__c = '1234';
        QD2.Country_Code__c = 'US';
        QD2.MCN__C = '25721';
        QD2.Quicklook_ID__c = 'ms250942';
        QD2.Solution_Quote_Amount__c=11000;
        QD2.CurrencyIsoCode='USD';
        QD2.Solution_Quote_Status__c='Acknowledged';
        QD2.Description__c = 'TEST NAME';
        QD2.Opportunity_No__c = opp.Opportunity_Number__c ;
        
        List<QuBy_Detail__c> QDList = new List<QuBy_Detail__c>{QD1, QD2};
            insert QDList;
        Test.stopTest();
        
        EDBI_Order__c o = new EDBI_Order__c( Master_Customer_Number__c = 'Test123', Order_Number__c = '1234',Anaplan_Opportunity_Number__c='1234',
                                            Customer_Country_Code__c = 'US', Quote_Number__c ='123',Opportunity__c =opp.Id,Sales_Org_Code__c = '123456789',Country_Code_With_Master_Customer_Nbr__c='123454' );
        insert o;
        
        o.Quote_Number__c  = '1234'; 
        o.Anaplan_Opportunity_Number__c ='1233';
        update o;
        QuBy_Detail__c qdObj = [select Opportunity_No__c from  QuBy_Detail__c where id =:QD2.id];
        // QuBy Detail Opportunity_No__c should be equal to EDBI Order Anaplan Opportunity Number
        System.assert(qdObj.Opportunity_No__c=='1233');
    }
    static testMethod void myTest1(){
        Test.startTest();
        QuBy_Detail__c QD1 = new QuBy_Detail__c();
        QD1.Name = 'TEST Quote';
        QD1.Quote_Number__c = '123';
        QD1.Country_Code__c = 'US';
        QD1.MCN__C = '25721';
        QD1.Quicklook_ID__c = 'ms250942';
        QD1.Solution_Quote_Amount__c=11000;
        QD1.CurrencyIsoCode='USD';
        QD1.Solution_Quote_Status__c='Acknowledged';
        QD1.Description__c = 'TEST NAME';
        
        List<QuBy_Detail__c> QDList = new List<QuBy_Detail__c>{QD1};
            insert QDList;
        
        EDBI_Order__c o = new EDBI_Order__c( Master_Customer_Number__c = 'Test123', 
                                            Customer_Country_Code__c = 'US',Order_Number__c='12345',Quote_Number__c ='123',Anaplan_Opportunity_Number__c = '123456789');
        insert o;
        
        o.Anaplan_Opportunity_Number__c = '212121211';
        update o; 
        QuBy_Detail__c qbObj =[select Opportunity_No__c from QuBy_Detail__c where id=:QDList[0].id];
        System.assert(qbObj.Opportunity_No__c!=null);
        List<QuBy_Detail__c> UpdateQBList = new List<QuBy_Detail__c>();
        for(QuBy_Detail__c qb : QDList ){
            qb.Opportunity_No__c = o.Anaplan_Opportunity_Number__c;
            
            UpdateQBList.add(qb);
        }
        
        update UpdateQBList; 
        Test.stopTest();                  
    }
    Public Static String getUser()
    {
        
        User Usr = [Select Id,Name from User where quicklook_id__c='ad250024' limit 1];
        System.debug('usrname'+usr.name);
        String s= String.valueOf(Usr.id);
        return s.substring(0, 15);
        //return usr.id;
    }
    public static AccountTeamMember createAccountTeamMember(Id accId, Id userId) {
        AccountTeamMember accTeamMember = new AccountTeamMember(AccountId = accId, UserId = userId, TeamMemberRole = 'Customer Success Manager');
        insert accTeamMember;
        return accTeamMember;
    }
}