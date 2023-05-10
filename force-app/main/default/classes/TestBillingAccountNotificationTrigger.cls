@isTest(SeeallData = true)
public class TestBillingAccountNotificationTrigger {
    
    static testmethod void Test() { 
         Profile pf= [Select Id from profile where Name='Soup Integration']; 
        System.assert(pf.Id!=null);
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
        User uu=new User(firstname = 'ABC', 
                         lastName = 'XYZ', 
                         email = uniqueName + '@test' + orgId + '.org', 
                         Username = uniqueName + '@test' + orgId + '.org', 
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         Quicklook_ID__c= '57665765',
                         ProfileId = pf.Id
                        );   
        insert uu; 
        System.assert(uu.Id!=null);
        system.assertEquals('ABC',uu.firstname);
        system.assertNotEquals('ISO-8859-9',uu.EmailEncodingKey);
        System.runAs(uu){
        
        Account a = new Account();
        a.Name = 'Test';
        a.Subscription_Group__c = 'Digital Insight';
        insert a;
        System.assert(a.Id!=null);
        system.assertEquals('Test',a.Name);
        system.assertNotEquals('Digital',a.Subscription_Group__c);
            
        Zuora__CustomerAccount__c acc = new Zuora__CustomerAccount__c();
        acc.Zuora__Account__c = a.Id;
        
        insert acc; 
        System.assert(acc.Id!=null);    
        }
    }
}