//Only add events where you have processing.
trigger LeadTrigger on Lead (before insert, after insert, before update, after update) {
    TriggerControl TC = new TriggerControl(); 
    System.debug('calling lead controll'+TC.RunTrigger('LeadTrigger'));
    if(TC.RunTrigger('LeadTrigger')){
        System.debug('Run LeadTrigger Triggers ');
      new LeadTriggerDispatcher().run();
       //  if(Trigger.IsBefore){
       //   Groom_Lead_Records.groom_sprint15(Trigger.New);
       //  }
    }else{
        System.debug('Skip LeadTrigger Triggers ');  
    }
}