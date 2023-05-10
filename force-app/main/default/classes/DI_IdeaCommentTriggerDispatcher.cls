public class DI_IdeaCommentTriggerDispatcher extends  TriggerHandlerBase{
    private static DI_IdeaCommentTriggerHandler ideaCommentHdlr;  
    
    public override void beforeInsert() {
        ideaCommentHdlr = (ideaCommentHdlr != null) ? ideaCommentHdlr : new DI_IdeaCommentTriggerHandler();
        List<IdeaComment> newIdeaCommentLst = (List<IdeaComment>)Trigger.new;
        ideaCommentHdlr.ValidateIdeaCommentText(newIdeaCommentLst);
    }

    public override void afterInsert() {
        ideaCommentHdlr = (ideaCommentHdlr != null) ? ideaCommentHdlr : new DI_IdeaCommentTriggerHandler();
        List<IdeaComment> newIdeaCommentLst = (List<IdeaComment>)Trigger.new;
        ideaCommentHdlr.IdeaReceivedComments(newIdeaCommentLst);
        // Increse product manager comment count by one.
        NCR_IdeaCommentCount.IdeaCommentInsert(Trigger.new);
    }

    
    public override void beforeUpdate() {
        ideaCommentHdlr = (ideaCommentHdlr != null) ? ideaCommentHdlr : new DI_IdeaCommentTriggerHandler();
        List<IdeaComment> newIdeaCommentLst = (List<IdeaComment>)Trigger.new;
        ideaCommentHdlr.ValidateIdeaCommentText(newIdeaCommentLst);
    }

    public override void afterUpdate() {
        ideaCommentHdlr = (ideaCommentHdlr != null) ? ideaCommentHdlr : new DI_IdeaCommentTriggerHandler();
        List<IdeaComment> newIdeaCommentLst = (List<IdeaComment>)Trigger.new;
        ideaCommentHdlr.IdeaReceivedComments(newIdeaCommentLst);
    }

    public override void afterDelete() {
        ideaCommentHdlr = (ideaCommentHdlr != null) ? ideaCommentHdlr : new DI_IdeaCommentTriggerHandler();         
        List<IdeaComment> oldIdeaCommentLst = (List<IdeaComment>)Trigger.old;
        // Decrease product manager comment count by one.
        NCR_IdeaCommentCount.IdeaCommentDelete(oldIdeaCommentLst);    
     }
}