public class DI_IdeaTriggerDispatcher extends  TriggerHandlerBase{
    private static DI_IdeaTriggerHandler ideaHdlr;  
    /*Before Insert*/
    public override void beforeInsert() {
        ideaHdlr = (ideaHdlr != null) ? ideaHdlr : new DI_IdeaTriggerHandler();
        List<Idea> newIdeaLst = (List<Idea>)Trigger.new;
        ideaHdlr.ValidateIdeaText(newIdeaLst);
        ideaHdlr.fillInternalMapping(newIdeaLst);
        ideaHdlr.DI_UpdateFields(newIdeaLst);
    }

    /* After Insert*/
    public override void afterInsert() {
        ideaHdlr = (ideaHdlr != null) ? ideaHdlr : new DI_IdeaTriggerHandler();
        List<Idea > newIdeaLst = (List<Idea>)Trigger.new;
        ideaHdlr.subscriptionMail(newIdeaLst);
    }

    /*Before Update*/
    public override void beforeUpdate() {
        ideaHdlr = (ideaHdlr != null) ? ideaHdlr : new DI_IdeaTriggerHandler();
        List<Idea> newIdeaLst = (List<Idea>)Trigger.new;
        ideaHdlr.ValidateIdeaText(newIdeaLst);
        ideaHdlr.updateProdMangEmail(newIdeaLst);
        ideaHdlr.DI_UpdateFields(newIdeaLst);
        ideaHdlr.ideaStatusChange(newIdeaLst);
    }

    /*After Update*/
    public override void afterUpdate() {
        ideaHdlr = (ideaHdlr != null) ? ideaHdlr : new DI_IdeaTriggerHandler();
        ideaHdlr.createIdeaHistory((Map<id,Idea>) Trigger.oldMap,(Map<id,Idea>) Trigger.newMap);
    }
}