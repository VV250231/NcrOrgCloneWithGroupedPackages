@isTest(SeeAllData=true)
public class DeactivateContact2Test {
    
        
    public static testMethod void testDeactivateContact2() {
    contact h = new Contact();
    h = [select id , Active_Contact__c , Decision_Maker__c , Level__c , Business_Function__c  , Survey_Flag__c  , Primary_Language__c  , Account.ownerid , email  from contact where accountid!=null and Active_Contact__c=true order by LastModifiedDate DESC limit 1];
    contact h2 = new Contact();
    h2=h.clone(false,true,false,false);
    h2.lastname='test';
        
        test.startTest();
        insert h2;
        
        ApexPages.StandardController sc = new ApexPages.standardController(h);
        DeactivateContact dc = new DeactivateContact(sc);
        dc.doDeactivateContact();
        
        
        Contact h3=h2;
        h3.Active_Contact__c=false; 
        h3.Decision_Maker__c=null; 
        h3.Level__c=null;
        h3.Business_Function__c=null;
        //h2.Survey_Flag__c=null;
        h3.Primary_Language__c=null;
        h3.email=null;
        update h3;
        Contact h4=[select id , Active_Contact__c , Decision_Maker__c , Level__c , Business_Function__c  , Survey_Flag__c  , Primary_Language__c  , Account.ownerid , email  from contact where id=:h3.id];
        System.assert(h4.Active_Contact__c == false);
        test.stopTest();
        h=[select id , Active_Contact__c , Decision_Maker__c , Level__c , Business_Function__c  , Survey_Flag__c  , Primary_Language__c  , Account.ownerid , email   from contact where id=:h2.id];
        h.Active_Contact__c=true; 
        h.Decision_Maker__c='None Specified'; 
        h.Level__c='None Specified';
        h.Business_Function__c='None Specified';
        //h2.Survey_Flag__c='None Specified';
        //h.Primary_Language__c='None Specified';
        //update h;
    }
    
    
}