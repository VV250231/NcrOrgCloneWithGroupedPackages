trigger UserTrigger on User (before insert, after insert, before update, after update) {
    TriggerControl TC = new TriggerControl(); 
    if(TC.RunTrigger('UserTrigger')){
        System.debug('Run UserTrigger Triggers ');
        new UserTriggerDispatcher().run();
    }else{
        System.debug('Skip UserTrigger Triggers ');  
    }
}