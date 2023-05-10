public without sharing class PRM_DealRegistrationProgressBar {
    @AuraEnabled
    public static List<String> getStatusBar(){
        List<String> pVList= new List<String>();
        Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
        for( Schema.PicklistEntry pV : f.getPicklistValues()){
            pVList.add(pV.getLabel());
        }     
        return pVList;
    }
    
    @AuraEnabled
    public static String getStageName(String recId)
    {
        Opportunity objOpp =  [Select Id, Name, StageName,RecordType.name
                               from Opportunity where Id =: recId ];
        return objOpp.StageName+','+objOpp.RecordType.name;
    }
    
    
}