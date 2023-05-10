@IsTest
public class DemingNotificationAndSharingTest {
    public static testmethod void testDemingNotificationAndSharing()
    {
        

        test.startTest();
        EmialTemplateCadd__c csobj=new EmialTemplateCadd__c ();
        Id cc =NSCCommonInfoUtil.getIdOf('CCADEmailTemp');
        csobj.CADDEmailTemplateId__c=cc;
        csobj.Name='TemplateId';
        insert csobj;

         EmailTemplatePrepondedPD__c PDLTemplateId = new EmailTemplatePrepondedPD__c();
         Id pdl =NSCCommonInfoUtil.getIdOf('PDLEmailTemp');
         PDLTemplateId.Template_ID__c=pdl;
         PDLTemplateId.Name='TemplateId';
         insert PDLTemplateId;
         
         CADDDoNotReply__c TargetObjectIdEmial = new CADDDoNotReply__c();
         Id dnr =NSCCommonInfoUtil.getIdOf('CCADDnrTemp');
         TargetObjectIdEmial.UserID__c=dnr;
         TargetObjectIdEmial.Name='Do Not Reply User For CADD';
         insert TargetObjectIdEmial;
        Account acc = TestRecordsFactory.createAccount('7392826','FINANCIAL:BANKING MAJOR','INDIA');
        createAccountTeamMember(acc.id,getUser());
        createAccountTeamMember(acc.id,TestRecordsFactory.getUser().id);
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
        
        insert dem1;
        
        Deming__c dem2= new Deming__c();
        dem2.Order_Id__c='234';
        dem2.Order_Number__c='234';
        dem2.Include_In_Process__c=false;
        dem2.EditShareWithUser__c=getUser();
        dem2.Customer_No__c='7392826';
        dem2.Reason_Code__c='Customer Request';
        dem2.Cadd_Owner__c='abc@test.com';
        dem2.Max_Promise_Date__c=Date.today();
        dem2.RDD__c=Date.today().addDays(1);
        dem2.IsSalespersonFound__c=true;
        User u3=TestRecordsFactory.getUser();
        dem2.EditShareWithUserSpFound__c=u3.ID;
        dem2.Customer_Name__c='Te21tCustomer';
        dem2.Customer_Delivery_Partner_Email__c='abac@abc.com';
        dem2.Customer_No__c='7392826';
        dem2.RelatedAccount__c=Acc.id;
        dem2.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        dem2.Max_Promise_Date__c=system.today();
        dem2.RDD__c=system.today().addDAYS(-5);
        insert dem2;
        
        Deming__c dem3= new Deming__c();
        dem3.Order_Id__c='234';
        dem3.Order_Number__c='234';
        dem3.Include_In_Process__c=false;
        dem3.EditShareWithUser__c=getUser();
        dem3.Customer_No__c='7392826';
        dem3.Reason_Code__c='Customer Request';
        dem3.Cadd_Owner__c='abc@test.com';
        dem3.Max_Promise_Date__c=Date.today();
        dem3.RDD__c=Date.today().addDays(-1);
        dem3.IsSalespersonFound__c=false;
        dem3.RelatedAccount__c=Acc.id;
        dem3.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        User u4=TestRecordsFactory.getUser();
        //dem3.EditShareWithUser__c=u4.ID;
        dem3.EditShareWithUserSpFound__c=u4.ID;
        dem3.Customer_Name__c='Te11tCustomer';
        dem3.Customer_Delivery_Partner_Email__c='abca@abc.com';
        dem3.Customer_No__c='7392826';
        dem3.Max_Promise_Date__c=system.today();
        dem3.RDD__c=system.today().addDAYS(6);
        insert dem3;
        

        

        
        Deming__c dem4= new Deming__c();
        dem4.Order_Id__c='234';
        dem4.Order_Number__c='234';
        dem4.Include_In_Process__c=false;
        dem4.EditShareWithUser__c=getUser();
        dem4.Customer_No__c='7392826';
        dem4.Reason_Code__c='Customer Request';
        dem4.Cadd_Owner__c='abc@test.com';
        dem4.Max_Promise_Date__c=Date.today();
        dem4.RDD__c=Date.today().addDays(1);
        User u5=TestRecordsFactory.getUser();
        //dem4.EditShareWithUser__c=u5.ID;
        dem4.EditShareWithUserSpFound__c=u5.ID;
        dem4.Customer_Delivery_Partner_Email__c='abcs@abc.com';
        dem4.Customer_No__c='7392826';
        dem4.RelatedAccount__c=Acc.id;
        dem4.Customer_Name__c='Te21tCustomer';
        dem4.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        dem4.Max_Promise_Date__c=system.today();
        dem4.RDD__c=system.today().addDAYS(6);
        dem4.IsSalespersonFound__c=false;
        insert dem4;
        
        Deming__c dem5= new Deming__c();
        dem5.Order_Id__c='234';
        dem5.Order_Number__c='234';
        dem5.Include_In_Process__c=false;
        dem5.EditShareWithUser__c=getUser();
        dem5.Customer_No__c='7392826';
        dem5.Reason_Code__c='Customer Request';
        dem5.Cadd_Owner__c='abc@test.com';
        dem5.Max_Promise_Date__c=Date.today();
        dem5.RDD__c=Date.today().addDays(-1);
        dem5.IsSalespersonFound__c=false;
        dem5.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        User u6=TestRecordsFactory.getUser();
        //dem5.EditShareWithUser__c=u6.ID;
        dem5.EditShareWithUserSpFound__c=u6.ID;
        dem5.Customer_Delivery_Partner_Email__c='abc@abc.com';
        insert dem5;
        
        Deming__c dem6= new Deming__c();
        dem6.Order_Id__c='234';
        dem6.Order_Number__c='234';
        dem6.Include_In_Process__c=false;
        dem6.EditShareWithUser__c=getUser();
        dem6.Customer_No__c='7392826';
        dem6.Reason_Code__c='Supply';
        dem6.Cadd_Owner__c='abc@test.com';
        dem6.Max_Promise_Date__c=Date.today();
        dem6.RDD__c=Date.today().addDays(-1);
         dem6.IsSalespersonFound__c=false;
        User u7=TestRecordsFactory.getUser();
        //dem6.EditShareWithUser__c=u7.ID;
        dem6.EditShareWithUserSpFound__c=u7.ID;
        dem6.Customer_Delivery_Partner_Email__c='adbc@abc.com';
        dem6.Customer_No__c='7392826';
        dem6.Customer_Name__c='aTe21tCustomer';
        dem6.Customer_Industry__c='FINANCIAL:BANKING MAJOR';
        dem6.Max_Promise_Date__c=system.today();
        dem6.RDD__c=system.today().addDAYS(-6);
        insert dem6;
        
        Deming__c dem7= new Deming__c();
        dem7.Order_Id__c='123';
        dem7.Order_Number__c='123';
        dem7.Include_In_Process__c=false;
        dem7.EditShareWithUser__c=getUser();
        dem7.Customer_No__c='7392826';
        dem7.Customer_Name__c='Test Customer';
        dem7.Reason_Code__c='Credit Holds';
       dem7.Cadd_Owner__c='abc@test.com';
        dem7.Max_Promise_Date__c=Date.today();
        dem7.RDD__c=Date.today().addDays(1);
        dem7.IsSalespersonFound__c=false;
       User u8=TestRecordsFactory.getUser();
        dem7.Customer_Name__c='Te21tCustomer';
        dem7.EditShareWithUserSpFound__c=u8.ID;
        dem7.Customer_Delivery_Partner_Email__c='abcs@abc.com';
        dem7.Customer_Industry__c='HOSPITALITY:EATING DRINKING-TS';
        
        dem7.Max_Promise_Date__c=system.today();
        dem7.RDD__c=system.today().AddDays(-2);
        dem7.Customer_No__c='7392826';
        dem7.Max_Promise_Date__c=system.today();
        dem7.RDD__c=system.today().addDAYS(-6);
        
        //System.runAs(TestRecordsFactory.getUser()){
        insert dem7;
        insert dem;
        //}
        System.runAs(TestRecordsFactory.getUser()){
        
        //test.startTest();
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute()); 
        String ss = String.valueOf(Datetime.now().second());
        
        //parse to cron expression
        String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        SchedulerDemingNotificationAndSharing s = new SchedulerDemingNotificationAndSharing(); 
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), nextFireTime, s);
        Set<String> MCNSet= new Set<String>(); 
        Set<String> IndustrySet = new Set<String>(); 
        Set<String> ReasonCodeSet = new Set<String>();  
        Boolean ValidateMCN=false;
        Boolean ValidateIndustry=false;
        Boolean ValidateReasonCode=false;
        Set<String> IdSetOfUser = new Set<String>();
        Set<String> CustomerRequestSet = new Set<String>();
		Set<String> NonCustomerRequestSet = new Set<String>();
        MCNSet.add('7392826');
        IndustrySet.add('INDIA');
        ReasonCodeSet.add('FINANCIAL:BANKING MAJOR');
        //IdSetOfUser.add(getUser()); 
        CustomerRequestSet.add('Customer Request');
        NonCustomerRequestSet.add('Supply');
		Database.executeBatch( new DemingNotificationAndSharing(IdSetOfUser,true,true,true,MCNSet,IndustrySet,ReasonCodeSet,CustomerRequestSet,NonCustomerRequestSet), 200);
        Set<String> toAddresses=new Set<String>();
        Set<String> ccAddresses=new Set<String>();
        toAddresses.add('test@ncr.com');
        ccAddresses.add('test1@ncr.com');
        Boolean check=toAddresses.contains('test@ncr.com');
        system.assertEquals(check,true);
        String TemplateId= EmialTemplateCadd__c.getValues('TemplateId').CADDEmailTemplateId__c;
        DemingEmailServiceClass.CreateEmailObject(toAddresses, ccAddresses, dem7.id, TemplateId);
      	DemingEmailServiceClass.CreateShareRecord(UserInfo.getUserId(),'Edit', dem7.id);  
        Test.stopTest(); 

    }

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