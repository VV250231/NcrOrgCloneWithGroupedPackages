/*
#####################################################################################################################
# Project Name..........: NSC PMDM                                                                         #
# File..................: VPScoreService.cls                                                             #
# Version...............: 1                                                                                         #
# Created by............: Ajay Dixit                                                                                #
# Created Date..........: 01-04-2018                                                                               #
# Last Modified by......: Ajay Dixit                                                                               #
# Last Modified Date....: 01-04-2018                                                                                #
# Description...........: This  functionality is targeted to test Web Service Class VPScoreService.                                                                    #
#####################################################################################################################
*/
@isTest (seeAllData=true)
public class VPScoreServiceTest {
    public static testMethod void vpScoreTest() {
        List<Value_Prompter__c> vp=[Select id,Opportunity__r.Opportunity_Number__c from Value_Prompter__c limit 1];
        Opportunity o=   TestRecordsFactory.createSimpleOpportunity();
        Opportunity op=[Select Opportunity_Number__c from Opportunity where id=:o.id];
        VPScoreService.vpScoreRequest vpr=new VPScoreService.vpScoreRequest();
        if(vp.size()>0){
        String oppno=vp.get(0).Opportunity__r.Opportunity_Number__c;    
        vpr.oppNumber  = Integer.valueOf(oppno);
        }
        VPScoreService.vpScoreResponse res=VPScoreService.getVPScore(vpr);
        vpr.oppNumber  = 123;
        VPScoreService.vpScoreResponse res1=VPScoreService.getVPScore(vpr);       
        vpr.oppNumber  = Integer.valueOf(op.Opportunity_Number__c);
        VPScoreService.vpScoreResponse res3=VPScoreService.getVPScore(vpr);
        system.assert(res3!=null);
 
      
    }
}