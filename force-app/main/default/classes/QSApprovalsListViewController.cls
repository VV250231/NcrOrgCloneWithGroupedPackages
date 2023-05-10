public class QSApprovalsListViewController {
    public List<approvalWithApproving> approvalList {get; set;}
    public static String orderByField {get;set;}
    public static String shortingOrder {get;set;}

    
    public class approvalWithApproving{
        @AuraEnabled
        public sbaa__Approval__c aprvl {get; set;}
        @AuraEnabled
        public String objectType {get; set;}
        @AuraEnabled
        public String fieldName {get; set;}
    }
    
    @AuraEnabled
    public static List<approvalWithApproving> instantiate(){
        List<approvalWithApproving> approvalList = new List<approvalWithApproving>();
        List<Group> groups = [select id from group where id in (select groupId from groupmember where userorgroupId = :userInfo.getUserId())];
        List<string> groupIds = new List<String>();
        List<string> groupIds15 = new List<String>();
        for (group g : groups)
        {
            groupIds.add((string)g.id);
            groupIds15.add(((string)g.id).left(15));
        }   
        
        List<sbaa__Approver__c> approvers = [select id from sbaa__Approver__c where sbaa__GroupId__c in :groupIds OR sbaa__GroupId__c in :groupIds15];
        if (String.isBlank(orderByField)) {
            orderByField = 'qtc_Requested_Date_Display__c';
        }
        if (String.isBlank(shortingOrder)) {
            shortingOrder = 'ASC';
        }
        List<sbaa__Approval__c> approvals = database.query(SOQLString('sbaa__Approval__c', ' ((sbaa__Approver__c in :approvers AND sbaa__AssignedTo__c = null) OR sbaa__AssignedTo__c = \''+userInfo.getUserID()+'\') AND sbaa__Archived__c = false AND sbaa__Status__c = \'Requested\'',orderByField,shortingOrder));
        approvalList = new List<approvalWithApproving>();
        List<ID> approvingIds = new List<Id>();
        for (sbaa__Approval__c aproval : approvals){
            String recordAPIName = (String)aproval.get('sbaa__RecordField__c');
            if (recordAPIName != null){ 
                try {
                    Id recordBeingApproved = (Id)aproval.get(recordAPIName);
                    string objectname = recordBeingApproved.getSObjectType().getDescribe().getName();
                    sObject s = Schema.getGlobalDescribe().get(objectname).newSObject();
                    s.id = recordBeingApproved;
                    approvalWithApproving wrapper = new approvalWithApproving();
                        wrapper.aprvl = aproval;
                        wrapper.objectType = objectName;
                        wrapper.fieldName = recordAPIName;
                    approvalList.add(wrapper);
                }
                catch (Exception e) {}  //if Approval.<sbaa__RecordField__c> is not populated, simply don't include that Approval
            }
        }
        return approvalList;
    }
    
    public QSApprovalsListViewController(){
        approvalList = instantiate();
    }
    
    public static string SOQLString(String objectName, String WhereClause, String orderByField, String shortingOrder) {
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
            //if (objectFields.get(s).getDescribe().isAccessible())
                query += ' ' + s + ', ';
        }
        
        // Strip off the last comma if it exists.
        query = query.trim().removeEnd(',');
        // Add FROM statement
        query += ' FROM ' + objectName;
        if (WhereClause != '')
            query += ' WHERE ' + WhereClause;
        if ((!String.isBlank(orderByField)) && (!String.isBlank(shortingOrder)))
            query += ' ORDER BY ' + orderByField + ' ' + shortingOrder;
        return query;
    }

    @AuraEnabled
    public static List<approvalWithApproving> shorting(String pOrderByField, String pOshortingOrder){
        try {
            orderByField = pOrderByField;
            shortingOrder = pOshortingOrder;
            return instantiate();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}