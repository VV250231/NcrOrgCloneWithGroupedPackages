@isTest(SeeAllData=true)
global class NSCProvisioning_Mocks {

	global class execute_pttBindingQSPort_Success implements WebServiceMock { 
        global void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) { 
        	NSCProvisioning.OpportunityResponseType mockResponse = 
        		new NSCProvisioning.OpportunityResponseType(); 
        		
        	mockResponse.Status = 'Success'; 
        	mockResponse.Message = 'Successful mock test. Congrats!';
        	
        	// Note: 'mockResponse' is the mock object we just created. 
        	// 		 'response' is passed in to this method as an arg
        	response.put('response_x', mockResponse); 
        }
	}
    
}