trigger IdeaCommentTrigger on IdeaComment (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new DI_IdeaCommentTriggerDispatcher().run();
}