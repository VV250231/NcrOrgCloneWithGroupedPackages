/*
##################################################################################################
# Class Name............................:MultiselectControllerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
public class MultiselectControllerTest
{
    public static testMethod void myTest()
    {   
        Account acc=new Account(); 
        Contact con=new Contact();
        con=TestRecordsFactory.createContact(acc);
        acc=TestRecordsFactory.createAccount();
        Opportunity opp=new Opportunity();
        opp=TestRecordsFactory.createSimpleOpportunity(acc);
        List<String> optionList = MultiselectController.getpickval_key_criteria();
        System.assert(optionList.size()>0);
        MultiselectController.NewGetPicklistValue(opp.id);
        ActiveContactController.getContactActivation(con.id);
        OpportunityProductController.getOpportunity(opp.id);
        opp.Key_Criteria__c ='Business Benefits	';
        update opp;
        MultiselectController.NewGetPicklistValue(opp.id);
    }
    
}