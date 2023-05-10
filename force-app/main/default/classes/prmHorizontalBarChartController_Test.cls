/* Class Name : prmHorizontalBarChartController_Test 
* Date : 19/02/20 
* Description : This Class  is used in Partner Portal for displaying Net New Customer partner revenue under 2020 Program
* DeveloperName : Deeksharth Sriwastava
*/
@isTest
public class prmHorizontalBarChartController_Test {
	 static testmethod void unitTest1(){
        Account a = PRM_TestRecordsFactory.createPartnerAccount('suffix', new Map<String,String>());
        system.runAs([Select Id from User WHERE Name = 'Soup User' LIMIT 1][0]){
            system.runas(TestRecordsFactory.getUser())
        {
            insert a; 
        }
        //insert a;
            List<Partner_Revenue__c> partnerRevenueList = PRM_TestRecordsFactory.partnerRevenueList(a.Id);
            if(partnerRevenueList.size()>0)
           insert partnerRevenueList;
           prmHorizontalBarChartController.getPartnerInfo(a.Id);
            ChannelProgram pObj = new ChannelProgram();
            pObj.Name = 'test';
            insert pObj;
            ChannelProgramLevel obj = new ChannelProgramLevel();
            obj.ProgramId = pObj.id;
            obj.Name = 'Gold';
            insert obj;
            system.assert(partnerRevenueList.size()>0);
            prmHorizontalBarChartController.getChannelPartnerInfo();
           
        }
     }
}