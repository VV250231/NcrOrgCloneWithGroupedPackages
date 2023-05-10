/*
##################################################################################################
# Class Name............................: SellingStageControllerTest                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
@IsTest
public class SellingStageControllerTest{
    
    static testmethod void testsellingstage() {
        /*No_Attach_Code_Profiles__c noAttache = new No_Attach_Code_Profiles__c();
        noAttache.Name = 'Record1';
        //noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        noAttache.Included_Payments_Profile__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        insert noAttache;*/
        
        
        All_profie_config__c noAttache = new All_profie_config__c();
        noAttache.Name = 'No Attach Codes Profiles';
        //noAttache.Include_HWM_SWM_Profiles__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        noAttache.Profile_Name__c = 'HOSP SMB Sales,04 NSC UI Administrator';
        insert noAttache;
        
        System.assertNotEquals(noAttache, null,'All profile config not be null');


        
        Prod_Reason_Required__c  rsnReq = new Prod_Reason_Required__c();
        rsnReq.Name='Payments Related';
        rsnReq.On__c=true;
        rsnReq.Prod_Included__c='Aloha POS, Mobile Pay';
        insert rsnReq;
        
        Opportunity opt=new Opportunity(
            Name='TestOpp' ,
            Stagename='Closed/Lost',
            Lose_to_a_Competitor__c='Yes',
            Primary_Loss_Reason__c='Price Sensitivity',
            How_important_was_Price_in_the_Decision__c='Not At All',
            Are_we_the_Incumbent__c='No',
            Primary_Product_Type__c='Hw',
            Secondary_Product_Type__c='SW',
            What_was_the_closest_competitor_price__c=10,
            Closed_Lost_Comments__c='test',
            
            CloseDate=system.today()+6,
            You_have_not_selected_any_TS_HWM_or_SW__c = 'Self-maintainer/installer'
        );
        insert opt; 
        Opportunity opt1=new Opportunity(
            Name='TestOpp' ,
            Stagename='Closed/Booked',
            IsQuoteCreatedInOtherSystem__c='YES',
            Key_Criteria__c='Quality',
            Price_Variance__c='NCR above 5%',
            CloseDate=system.today()+6,
            You_have_not_selected_any_TS_HWM_or_SW__c = 'Self-maintainer/installer'
        );
        insert opt1;
        
        
        
        
        
        SellingStageController.getTypeFromOpp(opt.id);
        SellingStageController.contractDateAvl(opt.id);
        SellingStageController.getpickvalDR(opt.id);
        SellingStageController.getOpts();
        //SellingStageController.updateOpportunity(opt.id,'SAVE','stageVal');
        SellingStageController.UpdateOpportunityRecordNewCL(opt);
        SellingStageController.UpdateOpportunityRecordNewCB(opt1,false);
        SellingStageController.UpdateOpportunityRecordNewCB(opt1,true);
        SellingStageController.getIsdisabled();
        SellingStageController.getReasonForHwandSW();
        
        
        
    }
    
    static testmethod void test2(){
        Opportunity opp5 = TestRecordsFactory.createSimpleOpportunity();
        opportunity opp6 = [select id,RecordType.Name from opportunity where Id =:opp5.Id];
        System.assertNotEquals(opp6, null,'opportunity should not be null');
        system.debug('opp6'+opp6.recordType.Name);
        SellingStageController.UpdateOpportunityRecordNewCB(opp6,true);
        
        
    }
    static testmethod void test3(){
        All_profie_list_config__c st = new All_profie_list_config__c();
        st.Name = 'No Attach Codes Profiles';
        st.name = 'test';
        st.QuBy_LTNG_ProfileCheck__c = true;
        insert st;
        System.assertNotEquals(st, null,'all profile should not be null');
        SellingStageController.getIsdisabled();
        
        
    }
       
    
}