public without sharing class NCR_SendDailyIdeaSummaryCon {
    
    public List<Idea> ideasCreatedToday {get;set;}
    public List<IdeaWrapper> ideaWrapperList {get;set;}

    public String newLine {
        get { return '\r\n'; }
        set;
    }
    
    public NCR_SendDailyIdeaSummaryCon() {
        ideaWrapperList = new List<ideaWrapper>();
      
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        if (netWorks.size() > 0) {
            List<Community> zones = [SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1];
            system.debug('###'+zones ); 
            if(zones.size() > 0) {
                if( !isMonday() ) {
                    ideasCreatedToday = [SELECT Id,CommunityId, Title, Body, NumComments, VoteTotal, Fi_Domain__c, CreatedById, CreatedBy.Name,CreatedBy.AccountId,FI_Name__c FROM Idea WHERE DAY_ONLY(convertTimezone(CreatedDate)) =: system.Today()];
                    system.debug('***'+ideasCreatedToday);}
                else {
                    ideasCreatedToday = [SELECT Id,CommunityId, Title, Body, NumComments, VoteTotal, Fi_Domain__c, CreatedById, CreatedBy.Name,CreatedBy.AccountId,FI_Name__c FROM Idea WHERE DAY_ONLY(convertTimezone(CreatedDate)) = LAST_N_DAYS:3];
                    system.debug('$$$'+ideasCreatedToday);}
                if (ideasCreatedToday.size() > 0) {
                    // Find FI Names of the creator of the Ideas
                    Set<Id> ideaCreatorsFIIds = new Set<Id>();
                    for (Idea ideaRec : ideasCreatedToday) {
                        if (ideaRec.CreatedBy.AccountId != null)
                          ideaCreatorsFIIds.add(ideaRec.CreatedBy.AccountId);
                    }                 
                    
                    Map<Id,Account> idToAccountMap = new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN : ideaCreatorsFIIds]);
                    
                    for(Idea ideaRec : ideasCreatedToday) {
                      if (ideaRec.CommunityId == zones[0].Id)
                          ideaWrapperList.add(new ideaWrapper(ideaRec,idToAccountMap.get(ideaRec.CreatedBy.AccountId) != null?idToAccountMap.get(ideaRec.CreatedBy.AccountId).Name:null));
                    }
                }               
            } 
      } 
    }
  
    public class IdeaWrapper {
        public Idea idea {get;set;}
        public String ideaFiName {get;set;}
        public String IdeaBody {get;set;}
        
        public IdeaWrapper (Idea idea, String fiName) {
            this.idea = idea;
            this.ideaFiName = fiName;
            if (idea.Body != null)
              this.IdeaBody = (idea.Body.stripHtmlTags().abbreviate(200)).normalizeSpace();
        }
        
    }
    
    //Method is use to return "True" if its Monday else return "False"
    public boolean isMonday( ){
        integer numberDays = date.valueof ( system.now() ).daysBetween( date.valueof( system.now() ).toStartofWeek() );     
        if ( numberDays == 1 )
            return true;
        else
            return false;   
    }
    
}