public class AsyncNotifier implements Queueable {
    String mailHdr, mailSubHdr, mailSub, mailBdy;
    List<String> rcpnts = new List<String>();
    
    public AsyncNotifier(String mailHdr, String mailSubHdr, String mailSub, String mailBdy, List<String> rcpnts) {
        this.mailHdr = mailHdr;
        this.mailSubHdr = mailSubHdr;
        this.mailSub = mailSub;
        this.mailBdy = mailBdy;        
    	this.rcpnts.addAll(rcpnts);   
    } 
    
	public void execute(QueueableContext context) {
    	System.debug(mailBdy); 
		EmailUtility.sendEmail(mailSub,mailHdr,mailSubHdr,mailBdy,rcpnts); 
    }
}