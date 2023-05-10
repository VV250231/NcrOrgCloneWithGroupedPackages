@isTest 
private class SynkCSM_To_CADDTest {
    static testMethod void Method1() {
        /* CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
TargetObjectIdEmial.UserID__c='0050g000006HbDe';
TargetObjectIdEmial.Name='Do Not Reply User For CADD';
insert TargetObjectIdEmial;*/
        UserRole role = [Select Id, Name FROM UserRole LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = '04 NSC UI Administrator' Limit 1];
        User u2 = new User();
        u2.Username = 'sysAdmin@ncr.com';
        u2.UserRole= role ;
        u2.ProfileId = adminProfile.Id;
        u2.Alias = 'admin123';
        u2.Email = 'sm245977@gmail.com';
        u2.EmailEncodingKey = 'UTF-8';
        u2.LastName = 'systemAdmin';
        u2.CommunityNickname = 'adminUser';
        u2.TimeZoneSidKey = 'America/Los_Angeles';
        u2.LocaleSidKey = 'en_US';
        u2.LanguageLocaleKey = 'en_US';
        u2.FederationIdentifier = 'admin333';
        u2.Quicklook_ID__c = 'admin330';
        insert u2;
          system.assert(u2.Id!=null);
        Account a = TestRecordsFactory.createAccount('7392826','FINANCIAL:BANKING MAJOR','INDIA');
        
        Deming__c DemObj1= new Deming__c();
        DemObj1.Order_Id__c='47593451';                                      //Select id,Order_Number__c,Order_Line_Id__c from ERP_Orders_Backlog__c          208395648
        //DemObj1.SalesPerson_Global_Id__c='14200124419-201100959';           //Select id,Global_ID__c,Quicklook_ID__c,InActive__c from NCR_Employee_Detail__c  41477033784-20110098
        DemObj1.SalesOrdCode__c='201100959';                               //Select id,Sales_Org_Code__c,Hierarchy_2__c from Sales_Org_Temp__c
        DemObj1.Customer_No__c='8511908';
        DemObj1.Order_number__c='5340549';
        DemObj1.Customer_Country_code__c= 'US'; //Select id,Name,Master_Customer_Number__c,Owner.Email from Account  8533019PH
        DemObj1.Max_Promise_Date__c=System.today();
        DemObj1.EditShareWithUser__c=u2.id;
        DemObj1.RelatedAccount__c=a.id;
        Insert DemObj1;
        
        AccountTeamMember atm = new AccountTeamMember();
        atm.AccountId=a.id;
        atm.UserId=u2.id;
        atm.TeamMemberRole='Customer Success Manager';
        atm.AccountAccessLevel='Read';
        insert atm;  
        
        atm.TeamMemberRole='Account Manager';
        update atm;
        atm.TeamMemberRole='Customer Success Manager';
        update atm;
        Delete atm; 
        
        AccountTeamMember atm1 = new AccountTeamMember();
        atm1.AccountId=a.id;
        atm1.UserId=u2.id;
        atm1.TeamMemberRole='Implementation Coordinator';
        atm1.AccountAccessLevel='Read';
        
        insert atm1;  
        
        atm1.TeamMemberRole='Account Manager';
        update atm1;
        atm1.TeamMemberRole='Customer Success Manager';
        update atm1;
        Delete atm1;
        system.assertEquals(atm1.TeamMemberRole,'Customer Success Manager');
       
      
    }
    
}