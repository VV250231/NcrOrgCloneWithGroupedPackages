public class NCR_ViewInternalCommentExtension {

public list<Di_Idea_Internal_Comments__c> comments = new list<Di_Idea_Internal_Comments__c>();
public Idea idea1 = new Idea();
public Idea idea2 = new Idea();
public String newCommentValue {get;set;}

    public NCR_ViewInternalCommentExtension(ApexPages.StandardController controller) {
    idea1 = (Idea)controller.getRecord();
    }

    public idea getidea2()
    {
    idea2 = [select id, title from idea where id =: idea1.id];
    return idea2;
    }
    public list<Di_Idea_Internal_Comments__c> getcomments(){
    comments = [select id, Di_Idea_IdeaId__c , Di_Idea_CreatorSmallPhotoUrl__c , Di_Idea_CreatorName__c , Di_Idea_CreatorFullPhotoUrl__c , Di_Idea_CommentBody__c , Di_Idea_CommunityId__c , CreatedByid , CreatedBy.name , Name , CreatedDate , LastModifiedByid , LastModifiedBy.name , Ownerid from Di_Idea_Internal_Comments__c where Di_Idea_IdeaId__c =: idea1.id Order By CreatedDate desc];
    if(comments.size()==0)
    {
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'No Internal Comments.'));
    return null;
    }
    else
    {
    return comments;
    }
    }
    
    public pageReference insertComment() {
        if(newCommentValue.length() > 0) {
            Di_Idea_Internal_Comments__c newIdeaComment = new Di_Idea_Internal_Comments__c();
            newIdeaComment.Di_Idea_IdeaId__c = idea1.id;
            newIdeaComment.Di_Idea_CommentBody__c = newCommentValue;
            insert newIdeaComment;
            system.debug('newIdeaComment = ' + newIdeaComment);
            PageReference gotorecord = new PageReference('/apex/NCR_ViewInternalComment?id=' + idea1.id);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter a value.'));
            return null;
        }
    }
    
    public pageReference ideaDetail(){
    pageReference p = new pageReference('/ideas/viewIdea.apexp?id='+idea1.id);    
    return p;
    }
    
}