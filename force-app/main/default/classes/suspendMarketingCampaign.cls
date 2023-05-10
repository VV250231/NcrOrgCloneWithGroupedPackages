public class suspendMarketingCampaign{
	Account acc;
	public suspendMarketingCampaign(ApexPages.StandardController stdController) {
		this.acc= (Account)stdController.getRecord();
	}
/*
* Created: Initial Development
* Description : Called to populate All user ids to fetch accounts having owner id = these ids.
*/ 
	public PageReference suspendCampaigns(){
		try{
			List <Contact> contactList = [Select id, Suspend_Marketing_Campaigns__c from contact where Accountid=:acc.id and Suspend_Marketing_Campaigns__c = FALSE];
            List <Contact> contactListTemp=new List <Contact> ();

			if(contactList!=null && contactList.size()>0){
				for(Contact contct: contactList){
					contct.Suspend_Marketing_Campaigns__c = true;
                    contactListTemp.add(contct);
				}
                if(contactListTemp.size()>0) {
                 update contactListTemp;   
                }              
			}
			}catch(Exception e){
				ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.FATAL, 'There was some issue while performing the operation. Please contact the administrator.'));
				return(null);
			}
			String baseURL = URL.getSalesforceBaseUrl().toExternalForm(); 
			PageReference pageRef = new PageReference(baseURL+'/'+acc.id);
			return (pageRef);
	}
}