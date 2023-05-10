/*
#####################################################################################################################
# Project Name..........: NSC PMDM                                                                         #
# File..................: VPScoreService.cls                                                             #
# Version...............: 1                                                                                         #
# Created by............: Ajay Dixit                                                                                #
# Created Date..........: 01-04-2018                                                                               #
# Last Modified by......: Ajay Dixit                                                                               #
# Last Modified Date....: 01-04-2018                                                                                #
# Description...........: This  functionality is targeted to test Redirect To Opp Page when user comes from QuBy.                                                                    #
#####################################################################################################################
*/
@isTest (seeAllData=true)
public class RedirectToOpp_test {
    static testMethod void RedirectToOpptest() {
        Opportunity o=   TestRecordsFactory.createSimpleOpportunity();
        Opportunity op=[Select Opportunity_Number__c from Opportunity where id=:o.id];       
        Test.StartTest();  
        PageReference pageRef1 = Page.RedirectToOpportunity;
        Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('oppno',op.Opportunity_Number__c);
        String id = ApexPages.currentPage().getParameters().get('oppno');
        System.assert(id!=null);
        RedirectToOpp ro=new RedirectToOpp();
        ro.redirect();
         ApexPages.currentPage().getParameters().put('oppno','123');
        RedirectToOpp ro1=new RedirectToOpp();
        ro1.redirect();
        Test.StopTest();   
    }
}