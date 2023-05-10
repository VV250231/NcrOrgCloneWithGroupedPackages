public class synchUSMOnOppLinkQueueable implements Queueable,DataBase.AllowsCallouts  {
    
    List<Id> OppToProcess= new List<Id>(); 
    String msg,nscSysId='';
    
    public synchUSMOnOppLinkQueueable( List<Id> OppList){
           
            OppToProcess.addAll(OppList);
     }
     
    public void execute(QueueableContext context){ 
        usmCallHandler.synchUSMOnOppLink(OppToProcess);
    }
}