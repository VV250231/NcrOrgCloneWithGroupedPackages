/*
##################################################################################################
# Class Name............................:ValuePrompterControllerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@isTest
private class ValuePrompterControllerTest{
    
    static testMethod void myTest() {
        Account acc=TestRecordsFactory.createAccount();
        Competitors__c comp=TestRecordsFactory.createCompetitor();
        Sales_Org__c  so=TestRecordsFactory.createSalesOrg();
        Opportunity opp = TestRecordsFactory.createSimpleOpportunity(acc);
        
        Value_Prompter__c vp = TestRecordsFactory.createValuePrompterFromOpp(opp);
        ValuePrompterController.getOppValuePrompter(opp.id);
        
        vp = new Value_Prompter__c(Id = vp.Id, Business_Issue__c = '', Problem__c = '', Opportunity_Id__c = opp.Id, Opportunity__c = opp.Id); 
        ValuePrompterController.saveValuePrompter(vp, opp.id);
        ValuePrompterController.checkValuePrompterAccess(opp.id, vp.Id);
        ValuePrompterController.emailMeValPrompter(vp);
        ValuePrompterController.submitValPrmForApproval(vp.Id);
        ValuePrompterController.recallApprovalRequest(vp.Id);
        
        Test.startTest();
        opp.Industry__c = 'Retail';
        update opp;
        vp.Has_the_Business_Value_been_quantified__c = true;
        vp.Do_prospect_agreed_potential_buss_value__c = true;
        vp.Access_to_the_Power_Person__c = true;
        vp.Has_Plan_confirmed_with_customer__c = true;
        vp.Have_we_developed_an_eVP__c = true;
        vp.Are_Top_Risk_Identify_if_they_Occur_CMR__c = true;
        vp.Can_it_be_related_to_Revenue_or_Profit__c = true;
        vp.Is_prospect_req_any_unique_or_diff_sol__c = true;
        update vp;
        system.assertEquals(vp.Have_we_developed_an_eVP__c , true);
        
        Test.stopTest();
        
    }
}