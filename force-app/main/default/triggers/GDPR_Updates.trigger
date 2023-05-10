/*
* Test Class Name : Controller_indvidualobject_listview_Test
*/
trigger GDPR_Updates on Individual (before insert,before update) {

     if(Trigger.IsInsert){ 
      GDPR_Updates_helperclass.generate_autonumber_insert(Trigger.new);
     }
     
     if(Trigger.IsUpdate){ 
     GDPR_Updates_helperclass.generate_autonumber_update(Trigger.new,Trigger.oldMap);
     }
}