public class createCustomerGoal {
  @AuraEnabled
    public static void saveCustGoals( String SalesSurveyid,List<SalesSurveyCustomerGoal__c> NewCustomerGoalList){
    // List<Sales_Survey_Contact__c> SSCustGoalListInsert = New List <Sales_Survey_Contact__c>();
     List<SalesSurveyCustomerGoal__c> NewcustGoaltoBeinsert = New List<SalesSurveyCustomerGoal__c>();
        system.debug('------'+NewCustomerGoalList);
         system.debug('------'+SalesSurveyid);
         if(NewCustomerGoalList.size()>0){
            for(SalesSurveyCustomerGoal__c obj1 : NewCustomerGoalList){
                 SalesSurveyCustomerGoal__c ssc = new SalesSurveyCustomerGoal__c();
                 ssc.Sales_Survey__c  = SalesSurveyid;
                 ssc.Name = obj1.Name;
                 ssc.Details__c = obj1.Details__c;
                 ssc.Aligned_Solution__c = obj1.Aligned_Solution__c;
                 NewcustGoaltoBeinsert.add(ssc);
            }
         }
            if(NewcustGoaltoBeinsert.size() > 0){
            insert NewcustGoaltoBeinsert;
        }
    }
      @AuraEnabled
     public static List<SalesSurveyCustomerGoal__c> getAllSalesSurveyCustomerGoals(String SalesSurveyid){
         system.debug('-----'+SalesSurveyid);
        return [select Id,Name,Sales_Survey__c,Details__c,Aligned_Solution__c from SalesSurveyCustomerGoal__c where Sales_Survey__c =:SalesSurveyid];
    }
}