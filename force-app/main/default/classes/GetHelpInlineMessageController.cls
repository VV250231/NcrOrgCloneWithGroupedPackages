public with sharing class GetHelpInlineMessageController 
{
    public Boolean isDisplayAttachment {get;set;}
    
    public GetHelpInlineMessageController(ApexPages.StandardController stdController)
    {
        isDisplayAttachment = false; 
        System.debug('-------------------stdController.getId()---------------'+stdController.getId());
        List<Attachment__c> lstAttachment = [Select Id, CreatedDate from Attachment__c where Case__c =: stdController.getId() order by CreatedDate desc limit 1];
        
        System.debug('---------------lstAttachment------------'+lstAttachment);
        if(!lstAttachment.isEmpty())
        {
            System.debug('---------------(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())------------'+(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime()));
            System.debug('---------------(Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000----'+((Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000));
            Decimal sec = (Datetime.now().getTime() - lstAttachment[0].CreatedDate.getTime())/ 1000;
            
            isDisplayAttachment = sec <= 6.0;
        }                   
    }
    
}