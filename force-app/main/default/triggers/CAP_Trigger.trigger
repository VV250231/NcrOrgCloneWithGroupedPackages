trigger CAP_Trigger on CAP_Form__c (before insert, after insert, before update, after update) {
    
  //  if(Lead_Recursion_Validate.isFirstTime){
  //      Lead_Recursion_Validate.isFirstTime = false;
        if(Trigger.isBefore){
            CAP_Helper_Class.sub_dispatcher(Trigger.new,Trigger.isInsert,Trigger.isUpdate);
        }
  //  }
    
}