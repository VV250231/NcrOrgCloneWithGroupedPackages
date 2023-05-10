global class NCR_URL {
	
    public String InstanceURL {
        get {
            return System.URL.getSalesforceBaseURL().toExternalForm();
        }
        set;
    } 
    
}