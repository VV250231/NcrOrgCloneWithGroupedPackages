public class VisitDataOpp {
    public VisitDataOpp(ApexPages.StandardController controller){
         System.debug('Base'); // No need to remove debug, this is needed to avoid empty block statement   
    }
    public PageReference requestBriefing(){
         string myId = ApexPages.CurrentPage().getParameters().get('id');
         string AccountId = [select id,accountId From Opportunity where id=:myId ].accountId;
         system.debug('myId>>>>>>>' + myId);
         PageReference pageRef = new PageReference('/apex/briefingedge__VisitData?id='+AccountId);
         return pageRef;
         
    }

}