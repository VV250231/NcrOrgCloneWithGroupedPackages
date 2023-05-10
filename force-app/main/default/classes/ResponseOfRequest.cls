global class ResponseOfRequest {
	global final static String STATUS_SUCCESS = 'SUCCESS';
	global final static String STATUS_FAILURE = 'FAILURE';
	public ResponseOfRequest(string res) {
        this.status = STATUS_SUCCESS;
		this.errorMessage = null;
		if (res != null) {
			this.status = STATUS_FAILURE;
			this.errorMessage = res;
		} 			
		
	}
	public ResponseOfRequest() {
		System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement
	}
	webservice String status {get;set;}
	webservice String errorMessage {get;set;}
}