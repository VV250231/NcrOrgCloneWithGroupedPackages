public class SalesforceMapPrivacyControllerClass {
    
    @AuraEnabled
    public static Boolean HasSalesforceMapPermission(String currentUserId){
        Boolean user_has_permission = false;
        List<PermissionSetAssignment> currentUserPerSet=[SELECT Id,PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE AssigneeId = :currentUserId];
        if(currentUserPerSet!=null && !currentUserPerSet.isEmpty()){
            for ( PermissionSetAssignment psa : currentUserPerSet ) {
                if ( psa.PermissionSet.Name.equals('MapsUser')) {
                    user_has_permission = true;
                }
            }
        }
        return user_has_permission;
    }
    
    @AuraEnabled
    public static Boolean removeSalesforceMapPermission(String currentUserId){
        Boolean permissionRemoved = false;
        List<PermissionSetAssignment> removeMapsUserPerSet=[SELECT Id,PermissionSet.Name,AssigneeId FROM PermissionSetAssignment WHERE 
                                                         AssigneeId = :currentUserId AND PermissionSet.Name='MapsUser'];
        if(removeMapsUserPerSet!=null && !removeMapsUserPerSet.isEmpty()){
            Delete removeMapsUserPerSet;
            permissionRemoved= true;
        }
        return permissionRemoved;
    }
    
}