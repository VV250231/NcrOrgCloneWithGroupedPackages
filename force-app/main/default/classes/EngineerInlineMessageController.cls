public with sharing class EngineerInlineMessageController 
{
    public Boolean isDisplayMessage {get;set;}
    
    public EngineerInlineMessageController(ApexPages.StandardController stdController)
    {
   		isDisplayMessage = false; 
        System.debug('-------------------stdController.getId()---------------'+stdController.getId());
        List<Attachment__c> lstAttachment = [Select Id, CreatedDate from Attachment__c 
        										where Engineers__c =: stdController.getId() and  Engineer_Attachment_Type__c = 'IPP Order Form' order by CreatedDate desc limit 1];
        
        System.debug('---------------lstAttachment------------'+lstAttachment);
        if(!lstAttachment.isEmpty())
        {
            System.debug('---------------(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())------------'+(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime()));
            System.debug('---------------(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000----'+((Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000));
            Decimal sec = (Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000;
            
            isDisplayMessage	 = sec <= 10.0;
        }           
    }
}