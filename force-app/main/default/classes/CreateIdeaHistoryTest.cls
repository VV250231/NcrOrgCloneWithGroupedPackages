@isTest(seealldata=true)
public class CreateIdeaHistoryTest{

    static testmethod void test() {
        Id communityid;
        user u;
        try{
            communityid = [select id from Community where Name='IdeaExchange' limit 1].id;
        }
        catch(exception e){
            System.debug('Error: '+e.getMessage());
        }
        
        Idea i = new Idea();
              
        i.title='test';
        i.body='test';
        i.communityid=communityid;
        i.Di_Idea_Product_Manager_Name__c='Lindsey Speranza';
        i.Di_Idea_Category__c = 'ACH and Wires';
        i.Di_Idea_Channel__c = 'Online';
        i.Di_Idea_DI_Release_Date__c = '1-01-16';
        i.Di_Idea_DI_Release_Number__c = '111';
        i.Di_Idea_Due_Date__c = system.now();
        i.Di_Internal_Category_Name__c='ACH and Wires';
        i.Di_Idea_SLA_Status__c='SLA 1 Voilated';
        i.Di_Idea_Jira_Number__c='111';
        i.Di_Idea_Line_of_Business__c='Business Banking';
        insert i;
        
        i.Di_Idea_Product_Manager_Name__c='Brett Conoly';
        i.Di_Idea_Category__c = 'Alerts';
        i.Di_Idea_Channel__c = 'Mobile';
        i.Di_Idea_DI_Release_Date__c = '1-01-16';
        i.Di_Idea_DI_Release_Number__c = '123';
        i.Di_Idea_Due_Date__c = system.now()+1;
        i.Di_Idea_Featured_Flag__c = true;
        i.Di_Idea_Featured_Image__c='http://google.com';
        i.body='test1';
        i.Di_Internal_Category_Name__c='Alerts';
        i.Di_Idea_SLA_Status__c='SLA 2 Voilated';
        i.Di_Idea_Jira_Number__c='123';
        i.Di_Idea_Line_of_Business__c='Consumer Relationship';
        update i;
  
        Idea i1 =[Select id, Di_Idea_DI_Release_Number__c from Idea where Di_Idea_DI_Release_Number__c = '123'];
        System.assert(i1.id!=Null);
   }
}