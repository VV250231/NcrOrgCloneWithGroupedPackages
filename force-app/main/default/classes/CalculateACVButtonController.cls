public class CalculateACVButtonController {
    
    private zqu__Quote__c quote; 
    private List<zqu__Quote__c > lstQ= new List<zqu__Quote__c >();
    public CalculateACVButtonController(ApexPages.StandardController stdController) 
    {
        this.quote = (zqu__Quote__c)stdController.getRecord(); 
        this.quote = [select id, name, zqu__Account__c from zqu__Quote__c where id = :this.quote.Id];
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Calculating ACV...'));
    }
    
    public PageReference calculateACV() { 
        try 
        {
          lstQ.add(this.quote); // for bulkyfy story SC2015_AGL-4827
          QuoteWrapper wrapper = new QuoteWrapper(lstQ,true); 
          wrapper.calculateACV(); 
            return redirect(); 
        }
        catch(Exception ex) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getLineNumber() + ': ' + ex.getMessage()));
            system.debug('***ERR: ' + ex.getLineNumber() + ': ' + ex.getMessage() + '. Stack Trace:\n' + ex.getStackTraceString()); 
            return null;
        }
    }
    
    public PageReference redirect() { 
      PageReference pageRef = new PageReference('/' + quote.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

}