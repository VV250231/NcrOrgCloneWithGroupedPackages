/*
 * Created By sm250665
 * purpose : works as extension for campaign Activity standard controller
 *
 */
public class campaignActivityExt
{
     public Campaign_Activity__c campAct {get;set;}
     
     string oldStatus ;
     
     
     public campaignActivityExt(ApexPages.StandardController sc) {
    
        this.campAct = (Campaign_Activity__c) sc.getRecord();
        //Saving old status of campaign actvity.
        oldStatus =  campAct.status__c ;
     }
     
     /*
      * If user try to qualify the campaign activity record and also make the changes in other filds than this method
      * allows to save other filed info but save record with old status only. after calling this method an java script
      * is invoked on page which redirects user to new opportunity page. If user has creates opportunity successfuly
      * trigger on opportunit 'UpdateCampaignAcvity' will invoke which actully change the status to qualify.
      * @return none.
      */
     public void saveWithOldStatus()
     {
         campAct.status__c  = oldStatus ;
         
         if(campAct.Id != null)
             update campAct;
         else
             insert campAct;
     }
     
     
}