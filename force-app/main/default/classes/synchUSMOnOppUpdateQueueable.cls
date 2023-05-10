public class synchUSMOnOppUpdateQueueable implements Queueable, Database.AllowsCallouts {
     
     List <ID> OppToProcess= new List<Id>(); 
     String msg='Successfully Engaged Salesforce Opportunity with USM'; 
    
     public synchUSMOnOppUpdateQueueable( List<Id> OppList){
           
            OppToProcess.addAll(OppList);
     }
    
     public void execute(QueueableContext context){
         usmCallHandler.synchUSMOnOppUpdate(OppToProcess);
     }
}