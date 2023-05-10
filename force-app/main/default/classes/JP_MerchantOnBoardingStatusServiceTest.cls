@isTest
public class JP_MerchantOnBoardingStatusServiceTest {
    @isTest
    public static void unitTest(){
        NCR_Payments_Site__c PaySite= new NCR_Payments_Site__c();
        PaySite.InfiniceptApplicationId__c='123';
        insert PaySite;
        String[] s=new String[]{'12','123'};
            JP_MerchantOnBoardingStatusService.Tids tidss;// = new JP_MerchantOnBoardingStatusService.Tids;
        //tidss.eCommerce[0]='Test';
        //tidss.InStore[0]='Test';
        
        JP_MerchantOnBoardingStatusService.upsertCase('123', '123',
                                                      '123', '123','NewPend', '12', '12', '123', '123',s,tidss, '123', '123',
                                                      'Test', 'Test','Test', 'Test','Test','Test'); 
        
        
        
    }
    @isTest
    public static void unitTest2(){
        
        String[] s=new String[]{'12','123'};
            JP_MerchantOnBoardingStatusService.Tids tidss;// = new JP_MerchantOnBoardingStatusService.Tids;
        //tidss.eCommerce[0]='Test';
        //tidss.InStore[0]='Test';
        
        JP_MerchantOnBoardingStatusService.upsertCase('123', '123',
                                                      '123', '123','NewPend', '12', '12', '123', '123',s,tidss, '123', '123',
                                                      'Test', 'Test','Test', 'Test','Test','Test'); 
        
        
        
    }
}