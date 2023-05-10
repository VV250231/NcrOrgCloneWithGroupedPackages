@isTest
public class DisputeCaseFlowComponentControllerTest {
    @isTest static  void DisputeCaseFlowComponentControllerTest(){ 
        DisputeCaseFlowComponentController.getListViews();
        User u =[Select id from User where User_profile__c='Financial CSM' and isactive=true limit 1];
        system.assert(u.id!=null);
        System.runAs(u){
            DisputeCaseFlowComponentController.getUserAccessForDispute();
        }
    }
}