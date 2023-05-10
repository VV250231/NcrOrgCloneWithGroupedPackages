Public class CalculateRiskPercentageController{


  @AuraEnabled Public static String UpsertRecord(String RecordValue){
    //system.debug('1');
    Value_Prompter__c VmObj= new  Value_Prompter__c();
    //system.debug('2'); 
    String jsonStr = RecordValue;
    //system.debug('3');  
    JSONParser parser = JSON.createParser(jsonStr);
    //system.debug('4'+parser);
    while (parser.nextToken() != null) {
        // Start at the array of accounts.
        if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
            
            while (parser.nextToken() != null) {
                // Advance to the start object marker to
                //  find next account statement object.
                if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    // Read entire account object.
                    VmObj = (Value_Prompter__c )parser.readValueAs(Value_Prompter__c.class);
                   
                }
            }
        }
    }
     Upsert VmObj;
     return 'Success';
  }

}