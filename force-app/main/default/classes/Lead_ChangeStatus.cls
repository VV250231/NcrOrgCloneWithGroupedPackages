public class Lead_ChangeStatus {
    
    ApexPages.StandardSetController setCon;
    public List<Lead> selectedItems{get;set;}
    public Boolean isEditable {get;set;}
    
    public Lead_ChangeStatus(ApexPages.StandardSetController controller) {
        setCon = controller;
         selectedItems = controller.getSelected();
        if (selectedItems.size() <= 0)
		{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please select at least one lead to Update.'));
			isEditable = false;
		}
        
        else{
            isEditable = true;
        }
    }
    /* public integer getMySelectedSize() {
        return setCon.getSelected().size();
    }
    public integer getMyRecordsSize() {
        return setCon.getRecords().size();
    }*/
}