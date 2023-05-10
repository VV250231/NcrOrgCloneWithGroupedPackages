trigger IdeaTrigger on Idea (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
    new DI_IdeaTriggerDispatcher().run();
}