public with sharing class PRM_EquipmentPaginationCon {
    
    @AuraEnabled
    public static List<Equipment_Declaration__c> getEquipments(String selectedView, String orderBy, String order) {
        List<Equipment_Declaration__c> equipments = new List<Equipment_Declaration__c>();
         
        String queryStr = 'SELECT Id, Name, Active_Unit__c, Class__c, Customer_Name__c, Installation_City__c, Installation_State_Province__c, CreatedDate, CreatedBy.Name FROM Equipment_Declaration__c ';
        if (selectedView == 'All Equipment') { 
                          queryStr = queryStr + ' ORDER BY ' + orderBy+' '+ order;
        } else if (selectedView == 'Active Equipment') {
            queryStr = queryStr+ ' WHERE  Active_Unit__c = true '+ ' ORDER BY ' + orderBy+ ' '+order;
        } else if (selectedView == 'Inactive Equipment') {
            queryStr = queryStr+ ' WHERE  Active_Unit__c = false ' + ' ORDER BY ' + orderBy+ ' '+order;
        } else if (selectedView == 'Recently Viewed') {
            queryStr = queryStr+ ' WHERE LastViewedDate != NULL ' + ' ORDER BY LastViewedDate DESC';
        }
        
        system.debug(queryStr);
        equipments = (List<Equipment_Declaration__c>)Database.query(String.escapeSingleQuotes(queryStr));
        return equipments;
    }
}