public class DisputeCaseFlowComponentController {
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'Case' and Name='Dispute Queue' limit 1];
        // Perform isAccessible() check here
        return listviews;
    }
    
    @AuraEnabled
    Public static List<String> getUserAccessForDispute(){
        List<String> recordTypeNameList = new List<String>();
        Schema.DescribeSObjectResult R = Case.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : RT ){
            if(recordType.isAvailable()){ 
                /** Check if the recordtype is visible for the current user or not. **/
                if(recordType.Name == 'Dispute') {
                    recordTypeNameList.add(recordType.getRecordTypeId());
                    /** Collect the record type name in list. **/
                } 
                else if(recordType.Name == 'Customer Success Team Case') {
                    recordTypeNameList.add(recordType.getRecordTypeId());
                    /** Collect the record type name in list. **/
                }
                //added for hospitality support 
                else if(recordType.Name == 'Hospitality Support') {
                    recordTypeNameList.add(recordType.getRecordTypeId());
                    /** Collect the record type name in list. **/
                }
            }
            
        }
        return recordTypeNameList;
    }
}