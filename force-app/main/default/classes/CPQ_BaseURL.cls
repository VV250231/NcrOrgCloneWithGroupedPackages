global class CPQ_BaseURL {
    
    public String getSalesforceBaseUrl {
        get { return URL.getSalesforceBaseUrl().toExternalForm();} set;
    }
    
    @InvocableMethod(label='Get Base URL')
    public static List<CPQ_Urls> getBaseURL() {
        List<CPQ_Urls> urlList = new List<CPQ_Urls>();
        CPQ_Urls cpqURL = new CPQ_Urls();
        cpqURL.sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
        urlList.add(cpqURL);
        return urlList;
    }
    
    
    global class CPQ_Urls {
        @InvocableVariable
        global String sfdcBaseURL;
    }
}