/*
*    @description:    Controller for NCR_EditIdeapage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     September 11, 2015
*/
public class NCR_EditIdeaPageController {
    public Idea newIdea {get;set;}

    public NCR_EditIdeaPageController(ApexPages.StandardController controller) {
        newIdea = [SELECT Di_Idea_DI_Release_Date__c, Di_Idea_DI_Release_Number__c, id, Body, Title, CreatedById, CreatedBy.Name, Di_Idea_Featured_Image__c, VoteTotal, Di_Idea_Line_of_Business__c, Di_Idea_Channel__c, Di_Idea_Category__c, CreatedDate, CreatedBy.SmallPhotoURL, CreatedBy.FullPhotoURL, Status, AttachmentBody, AttachmentName FROM Idea WHERE id =: ApexPages.currentPage().getParameters().get('id')];
    
        similarIdeasList = new List<Idea>();
    }
    
    public List<Idea> similarIdeasList {get;set;}
    public void searchTitle() { 
        similarIdeasList.clear();   
        List<String> partsList = new List<String>();    
        String myTitle = newIdea.Title;
        List<String> parts = myTitle.split(' ');
        for(String s : parts) {
            s = s + ' ';
            String s2 = s.replaceAll(' ', '%');
            if(s2.length() > 2) {
                partsList.add(s2);
            } //else {} commented empty else block
        }
        for(Idea i : [select id, Title, VoteTotal from Idea where Title like: partsList]) {
            similarIdeasList.add(i);
        }
    }
    
    public pageReference updateNewIdea() {
        update newIdea;
        PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeaPage?id=' + newIdea.id);
        gotorecord.setRedirect(true);
        return gotorecord;
    }
}