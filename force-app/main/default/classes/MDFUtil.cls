global class MDFUtil {
  webservice static String cancelMDFRequest(String requestId) {
  	
  	// First check either user is having the permission to cancel the request or not, if not gave him error message.
  	
  	// Find Permission Set Ids who has the permission to Cancel the request.
  	Set<String> permissionSetAPIs = new Set<String>();
  	permissionSetAPIs.add('Channel_Operation_Team');
  	
  	Set<Id> permissionSetIds = new Set<Id>();
  	
  	for (PermissionSet pSet : [SELECT Id, Name FROM PermissionSet WHERE Name IN: permissionSetAPIs]) {
  	  permissionSetIds.add(pSet.Id);
  	}
  	
  	List<PermissionSetAssignment> pSetAssList = [SELECT AssigneeId, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId=: UserInfo.getUserId() AND PermissionSetId IN: permissionSetIds];
  	
  	if (! (pSetAssList.size() > 0)) {
  	  return 'No_Permission';
  	}
  	
    List<SFDC_MDF__c> MDFRequestList = [SELECT Id, Status__c FROM SFDC_MDF__c WHERE Id =: requestId LIMIT 1];
    
    if (MDFRequestList.size() > 0) {
      SFDC_MDF__c mdfRequest = MDFRequestList[0];
      if (mdfRequest.Status__c == 'Cancelled'){
      	return 'already_cancelled';
      }
      mdfRequest.Status__c = 'Cancelled';
      Database.SaveResult result = DataBase.update(mdfRequest);
      if (result.isSuccess()) {
      	return 'true';
      } else {
          return 'false';
      }
    }
    return 'error';
  }
}