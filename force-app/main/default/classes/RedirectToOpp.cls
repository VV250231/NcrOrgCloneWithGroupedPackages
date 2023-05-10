public class RedirectToOpp {
    public string message {get;set;}
public PageReference redirect() {
    String oppno=ApexPages.currentPage().getParameters().get('oppno');
    List<Opportunity> opp=[Select id from Opportunity where Opportunity_Number__c=:oppno];
    string url;
    if(opp.size()>0){
        url='/one/one.app#/sObject/'+opp.get(0).id+'/view';
        return new PageReference(url);
    }else{
        message='Opportunity was not found with this Opportunity Number';
        return null;
    }
    //return url;
    //return new PageReference('/one/one.app#/sObject/0067000000pNlb5AAC/view');
}
}