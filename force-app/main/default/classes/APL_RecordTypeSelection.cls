public class APL_RecordTypeSelection {
    
        @AuraEnabled
        public static List<RecordType> getRecordType() {           
            Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
            Map<String,Schema.RecordTypeInfo> rtMapByName = d.getRecordTypeInfosByName();
            List<RecordType> recordTypeList = new List<RecordType>();
                 
            for (RecordType rt : [SELECT Id, DeveloperName, Name, Description, IsActive, SobjectType FROM RecordType WHERE SobjectType ='Opportunity' AND IsActive = true]) {
                Schema.RecordTypeInfo recTypeSchema = rtMapByName.get(rt.Name);
                
                if(recTypeSchema.isAvailable() && (recTypeSchema.Name != 'Master')) {
                    recordTypeList.add(rt);  
                }
            }
            return recordTypeList;
            //return [SELECT Id, Name, Description, IsActive, SobjectType FROM RecordType WHERE SobjectType ='Opportunity' AND IsActive = true];
            
        } 
}