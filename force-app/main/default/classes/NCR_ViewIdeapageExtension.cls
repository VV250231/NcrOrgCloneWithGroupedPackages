/*
*    @description:    Controller for NCR_ViewIdeapage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 12, 2015
*/
public class NCR_ViewIdeapageExtension {
    
    /** START -- for ViewIdeaPage    **/
    public Idea currentIdea {get;set;}
    public Idea newIdea {get;set;}
    Public List<Vote> Votelst {get;set;}
    public list<Idea> ChildIdeaList{get;set;} 
    public List<IdeaComment> currentIdeaComment {get;set;}
    public Integer currentCommentsTotal {get;set;}
    public String newCommentValue {get;set;}
    public Boolean disableVote {get;set;}
    public Boolean disableFavorite {get;set;}//to delete
    public String favoriteValue {get;set;}//to delete
    public User currentUser {get;set;}
    public Boolean displayAdd {get;set;}
    public Boolean displayRemove {get;set;}
    public Boolean displayEditButton {get;set;}
    public  Integer childIdeaSize{get;set;}
    public String defaultAvatar {get;set;}  //render default avatar from admin platform
    public boolean isChild{get;set;}
    public String newUrl {get;set;}
    public String retUrl {get;set;}
    public IdeaComment newIdeaComment {get;set;}
    //hmg
    public boolean hasChild {get;set;}
    public boolean rendBack{get;set;}
    public Boolean Success = true;
    public Boolean iUser {get;set;}
    public IdeaComment latestComment {get;set;}
    public string msg{get;set;}
    /** END -- for ViewIdeaPage    **/
    
    
    
    public NCR_ViewIdeapageExtension(ApexPages.StandardController controller) {
        rendBack = false;
        newIdeaComment = new IdeaComment();
        //get returl
        retUrl='/apex/';
        msg = '';
        if((ApexPages.currentPage().getParameters().get('pge') !=null)){
            retUrl = retUrl + ApexPages.currentPage().getParameters().get('pge').escapeHTML4();            
            rendBack = true;
        }
        if((ApexPages.currentPage().getParameters().get('rtid') !=null)){
            retUrl = retUrl + '?id='+ApexPages.currentPage().getParameters().get('rtid').escapeHTML4();            
            rendBack = true;
        }
        if((ApexPages.currentPage().getParameters().get('SelectTab') !=null)){
            retUrl = retUrl + '?SelectTab=' + ApexPages.currentPage().getParameters().get('SelectTab').escapeHTML4();            
            
        }
         if(!string.isblank(ApexPages.currentPage().getParameters().get('gb')))
         {
             retUrl = retUrl +'?pge='+ApexPages.currentPage().getParameters().get('gb').escapeHTML4();
         }
         if(!string.isblank(ApexPages.currentPage().getParameters().get('cat')))
         {
             retUrl = retUrl +'&cat='+ApexPages.currentPage().getParameters().get('cat').escapeHTML4();
             
         }
         if(!string.isblank(ApexPages.currentPage().getParameters().get('line')))
         {
             retUrl = retUrl +'&line='+ApexPages.currentPage().getParameters().get('line').escapeHTML4();
             
         }
         if(!string.isblank(ApexPages.currentPage().getParameters().get('stat')))
         {
             retUrl = retUrl +'&stat='+ApexPages.currentPage().getParameters().get('stat').escapeHTML4();
             
         }
         
         if(!string.isblank(ApexPages.currentPage().getParameters().get('mb')))
         {
             retUrl = retUrl +'&tb='+ApexPages.currentPage().getParameters().get('mb').escapeHTML4();
         }
         if(!string.isblank(ApexPages.currentPage().getParameters().get('gl')))
         {
             retUrl = retUrl +'&pge='+ApexPages.currentPage().getParameters().get('gl').escapeHTML4();
         }
         
         if(!string.isblank(ApexPages.currentPage().getParameters().get('ml')))
         {
             retUrl = retUrl +'&selectedTab='+ApexPages.currentPage().getParameters().get('ml').escapeHTML4();
         }
        if((ApexPages.currentPage().getParameters().get('pNum') !=null && ApexPages.currentPage().getParameters().get('pNum') !='')){
            retUrl = retUrl +'&pNum=' +ApexPages.currentPage().getParameters().get('pNum').escapeHTML4();            
        }
        if(ApexPages.currentPage().getParameters().get('searchItemVal') != null && ApexPages.currentPage().getParameters().get('searchItemVal') != '' && ApexPages.currentPage().getParameters().get('searchItemVal') != ' ') {
            retUrl = retUrl +'&searchItemVal=' + ApexPages.currentPage().getParameters().get('searchItemVal').escapeHTML4();    
        }
        if((ApexPages.currentPage().getParameters().get('thId') !=null)){
            retUrl = retUrl +'NCR_ThemeDetail?id=' + ApexPages.currentPage().getParameters().get('thId').escapeHTML4();            
            rendBack = true;
        }
        if(ApexPages.currentPage().getParameters().get('msg') != null){
            if(ApexPages.currentPage().getParameters().get('msg') == 'Upload Failed'){
               msg = ApexPages.currentPage().getParameters().get('msg');
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Upload Failed.'));
            }
        }
        
        newUrl = 'https://aplogin.digitalinsight.com';
        //end of get url
        /** START -- for ViewIdeaPage    **/        
        hasChild = false;
        isChild = false;
        currentUser = [SELECT id FROM User WHERE id =: UserInfo.getUserId()];
        currentIdea = [SELECT ParentIdea.Title, CreatedBy.SmallPhotoUrl, ParentIdeaId,IsMerged,AttachmentContentType, Di_Idea_DI_Release_Date__c, Di_Idea_DI_Release_Number__c, id, Body, Title, CreatedById, CreatedBy.Name, Di_Idea_Featured_Image__c, VoteTotal, Di_Idea_Line_of_Business__c, Di_Idea_Channel__c, Di_Idea_Category__c, CreatedDate, CreatedBy.pics__c, CreatedBy.FullPhotoURL, Status, AttachmentBody,CreatedBy.Title, AttachmentName, CreatedBy.DI_Fi_Name__c FROM Idea WHERE id =: ApexPages.currentPage().getParameters().get('id')];
           
           Votelst =new List<Vote>([select id,CreatedBy.Name,CreatedBy.pics__c,ParentId,CreatedBy.CompanyName,CreatedBy.Username,CreatedBy.ProfileId,CreatedBy.DI_FI_Name__c from Vote where ParentId =:ApexPages.currentPage().getParameters().get('id')]);
           
        //get the Child ideas to be displayed in Idea Details
        ChildIdeaList = [Select ID,Title From Idea where ParentIdeaID =: ApexPages.currentPage().getParameters().get('id')]; 
        if(ChildIdeaList.size() > 0){
            hasChild = true;
            ChildIdeaSize = ChildIdeaList.size();
        }
        if(currentIdea.isMerged && currentIdea.ParentIdeaID == null){
            isChild = true;
        }
        currentIdeaComment = [SELECT id, CreatedBy.UserType, CommentBody, IdeaId, CreatorFullPhotoUrl, CreatedBy.pics__c, CreatedBy.Name, CreatedById, CreatedDate, CreatedBy.FullPhotoURL, CreatedBy.Profile.Name,Createdby.Title,CreatedBy.DI_Fi_Name__c FROM IdeaComment WHERE IdeaId =: ApexPages.currentPage().getParameters().get('id') ORDER BY CreatedDate ASC];
        
        if(currentIdeaComment.size() > 0) {
            currentCommentsTotal = [SELECT count() FROM IdeaComment WHERE IdeaId =: ApexPages.currentPage().getParameters().get('id')];
            
            Boolean isInternalUser;
            Set<id> internalUsersList = new Set<Id>();
            for(IdeaComment ic : currentIdeaComment) {
                if(ic.CreatedBy.UserType == 'Standard') {
                    isInternalUser = true;
                    internalUsersList.add(ic.id);
                }
            }
            if(isInternalUser == true) {
                iUser = true;
                latestComment = [
                   SELECT 
                       id, CreatedBy.UserType, CommentBody, IdeaId, CreatorFullPhotoUrl, 
                       CreatedBy.pics__c, CreatedBy.Name, CreatedById, CreatedDate, CreatedBy.FullPhotoURL, 
                       CreatedBy.Profile.Name,Createdby.Title,CreatedBy.DI_Fi_Name__c 
                    FROM 
                       IdeaComment WHERE IdeaId =: ApexPages.currentPage().getParameters().get('id') 
                       AND CreatedBy.UserType = 'Standard' 
                    ORDER BY CreatedDate DESC LIMIT 1
                ];
            } else {
                iUser = false;
            }
        } else {
            currentCommentsTotal = 0;
        }
        
        if(getmyVotesList().size() >0 || getaccountvote().size()>0) {
            disableVote = true;
        } else {
            disableVote = false;
        }
        ideaTitleNew = currentIdea.Title;
                
        displayforEdit = false;
        displayforView = true;
        if(currentIdea.createdById == currentUser.id) {
            displayAdd = false;
            displayRemove = false;
            displayEditButton = true;
        } else {
            if(getMyFavoriteIdea().size() > 0) {
                displayAdd = false;
                displayRemove = true;
                displayEditButton = false;
            } else {
                displayAdd = true;
                displayRemove = false;
                displayEditButton = false;
            }
        }    
        
        //get default avatar
        SiteLink__c sl = [SELECT Name, Link__c FROM SiteLink__c WHERE Name = '/profilephoto/005/T' LIMIT 1];
        defaultAvatar = sl.Link__c + sl.Name;    
        /** END -- for ViewIdeaPage    **/
    }
        
    /*
    *    @description:    get current user's votes.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Vote> getmyVotesList() {
        return[SELECT id FROM Vote WHERE ParentId =: currentIdea.id AND CreatedById =: UserInfo.getUserId()];
    }
    
    public list<vote> getaccountvote(){
        
        list<id> acid = new list<id>();
        for( user u : [select AccountId from user where id =: UserInfo.getUserId()])
        {
            acid.add(u.accountid);
        }
        list<id> cid =new list<id>();
        
        for (user c : [select id from user where AccountId in :acid])
        {
            cid.add(c.id);
            
        }
        return [select id from vote  WHERE ParentId =: currentIdea.id AND CreatedById in : cid];
    }
    /*
    *    @description:    action for voting of ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference voteUp() {
        if(getmyVotesList().size() == 0 || getaccountvote().size()==0) {
            
            Vote newVote = new Vote();
                newVote.ParentId = currentIdea.id;
                newVote.Type = 'Up';
            insert newVote;
        } else {
            Success = false;
        }
        PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeapage?id=' + currentIdea.id);
        gotorecord.getParameters().put('pge',ApexPages.currentPage().getParameters().get('pge').escapeHTML4());
        if((ApexPages.currentPage().getParameters().get('SelectTab') !=null)){
            gotorecord.getParameters().put('SelectTab',ApexPages.currentPage().getParameters().get('SelectTab').escapeHTML4());           
            
        }
        if((ApexPages.currentPage().getParameters().get('pNum') !=null && ApexPages.currentPage().getParameters().get('pNum') !='')){
            gotorecord.getParameters().put('pNum',ApexPages.currentPage().getParameters().get('pNum').escapeHTML4());             
        }
        if(ApexPages.currentPage().getParameters().get('searchItemVal') != null && ApexPages.currentPage().getParameters().get('searchItemVal') != '' && ApexPages.currentPage().getParameters().get('searchItemVal') != ' ') {
           gotorecord.getParameters().put('searchItemVal',ApexPages.currentPage().getParameters().get('searchItemVal').escapeHTML4());   
        }
        if((ApexPages.currentPage().getParameters().get('thId') !=null)){
            gotorecord.getParameters().put('thId',ApexPages.currentPage().getParameters().get('thId').escapeHTML4());
        }
        gotorecord.setRedirect(true);
        return gotorecord;
    } 
        
    /*
    *    @description:    get current user's favorite ideas.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<Di_Idea_Favorites__c> getMyFavoriteIdea() {
        return[SELECT id FROM Di_Idea_Favorites__c WHERE DI_Idea__c =: currentIdea.id AND User__c =: UserInfo.getUserId()];
    }
        
    /*
    *    @description:    action for adding idea to my favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference insertToMyFavorites() {
        if(getMyFavoriteIdea().size() == 0) {
            Di_Idea_Favorites__c fvr = new Di_Idea_Favorites__c ();
            fvr.Di_Idea__c = currentIdea.id;
            fvr.User__c = UserInfo.getUserId();
            insert fvr;
            PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeapage?id=' + currentIdea.id);
            if((ApexPages.currentPage().getParameters().get('thId') !=null)){
                gotorecord.getParameters().put('thId',ApexPages.currentPage().getParameters().get('thId').escapeHTML4());
            }
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            Success = false;
            return null;
        }
    }
        
    /*
    *    @description:    action for deleting idea to my favorites.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference deleteToMyFavorites() {
        if(getMyFavoriteIdea().size() >= 0) {
            Di_Idea_Favorites__c deleteFave = [SELECT id FROM Di_Idea_Favorites__c WHERE Di_Idea__c =: currentIdea.id AND User__c =: UserInfo.getUserId() LIMIT 1];
            delete deleteFave;
            displayAdd = true;
            displayRemove = false;
            PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeapage?id=' + currentIdea.id);
            if((ApexPages.currentPage().getParameters().get('thId') !=null)){
                gotorecord.getParameters().put('thId',ApexPages.currentPage().getParameters().get('thId').escapeHTML4());
            }
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            Success = false;
            return null;
        }
    }
        
    /*
    *    @description:    action for posting new comment.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    
    public pageReference insertComment() {
        if(newIdeaComment.CommentBody != null) {
            //IdeaComment newIdeaComment = new IdeaComment();
            newIdeaComment.IdeaId = currentIdea.id;
            //newIdeaComment.CommentBody = newCommentValue;
            insert newIdeaComment;
            system.debug('newIdeaComment = ' + newIdeaComment);
            PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeapage?id=' + currentIdea.id);
            
            if (ApexPages.currentPage().getParameters().get('pge') != null) {
              gotorecord.getParameters().put('pge',ApexPages.currentPage().getParameters().get('pge').escapeHTML4());
            }
            if((ApexPages.currentPage().getParameters().get('SelectTab') !=null)){
                gotorecord.getParameters().put('SelectTab',ApexPages.currentPage().getParameters().get('SelectTab').escapeHTML4());           
                
            }
            if((ApexPages.currentPage().getParameters().get('pNum') !=null && ApexPages.currentPage().getParameters().get('pNum') !='')){
                gotorecord.getParameters().put('pNum',ApexPages.currentPage().getParameters().get('pNum').escapeHTML4());             
            }
            if(ApexPages.currentPage().getParameters().get('searchItemVal') != null && ApexPages.currentPage().getParameters().get('searchItemVal') != '' && ApexPages.currentPage().getParameters().get('searchItemVal') != ' ') {
               gotorecord.getParameters().put('searchItemVal',ApexPages.currentPage().getParameters().get('searchItemVal').escapeHTML4());   
            }
            if((ApexPages.currentPage().getParameters().get('thId') !=null)){
                gotorecord.getParameters().put('thId',ApexPages.currentPage().getParameters().get('thId').escapeHTML4());
            }
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please enter a value.'));
            return null;
        }
    } 
    
    
    /*
    *    @description:    action for edit functionality.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public Boolean displayforEdit {get;set;}
    public Boolean displayforView {get;set;}
    public pageReference enableEditIdea() {    //not used all 
        if(currentIdea.createdById == currentUser.id) {
            displayforEdit = true;
            displayforView = false;
            displayEditButton = false;
            PageReference gotorecord = new PageReference('/apex/NCR_EditIdeapage?id=' + currentIdea.id);
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            return null;
        }
    }
    /*
    *    @description:    action for save functionality.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public String ideaTitleNew {get;set;}
    public pageReference enableSaveIdea() {
        currentIdea.Title = ideaTitleNew;
        //currentIdea.Status = ideaStatusNew;
        update currentIdea;

        displayforEdit = false;
        displayforView = true;
        displayEditButton = true;
        PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeapage?id=' + currentIdea.id);
        gotorecord.setRedirect(true);
        return gotorecord;
        //return null;
    }
    /*
    *    @description:    action for delete idea functionality.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference enableDeleteIdea() {
        delete currentIdea;
        PageReference gotorecord = new PageReference('/apex/NCR_HomePage');
        gotorecord.setRedirect(true);
        return gotorecord;
        //return null;
    }
    /*
    *    @description:    get status values.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public List<SelectOption> getStatusValues() {
           List<SelectOption> options = new List<SelectOption>();  
           Schema.DescribeFieldResult fieldResult = Idea.Status.getDescribe();
           List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();                
           for( Schema.PicklistEntry f : ple) {
              options.add(new SelectOption(f.getLabel(), f.getValue()));
           }       
           return options;
    }
    
    /*
    *    @description:    get line of business value.
    *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
    */
    public pageReference gotoViewAll() {
        String addToURL;
        if(currentIdea.Di_Idea_Category__c == 'General Business Banking' || 
            currentIdea.Di_Idea_Category__c == 'ACH and Wires' || 
            currentIdea.Di_Idea_Category__c == 'Entitlements' || 
            currentIdea.Di_Idea_Category__c == 'Third Party Product Integration' || 
            currentIdea.Di_Idea_Category__c == 'Deposit Accounts' || 
            currentIdea.Di_Idea_Category__c == 'Other Accounts') {
                addToURL = '&lob=Business%20Banking';
        } else if(currentIdea.Di_Idea_Category__c == 'Promotion Suite' || 
                    currentIdea.Di_Idea_Category__c == 'Web Center' || 
                    currentIdea.Di_Idea_Category__c == 'Purchase Rewards' || 
                    currentIdea.Di_Idea_Category__c == 'Online Account Opening' || 
                    currentIdea.Di_Idea_Category__c == 'Other') {
                addToURL = '&lob=Consumer%20Relationship';
        } else if(currentIdea.Di_Idea_Category__c == 'General Payments' || 
                    currentIdea.Di_Idea_Category__c == 'Bill Pay' || 
                    currentIdea.Di_Idea_Category__c == 'External Funds Transfer' || 
                    currentIdea.Di_Idea_Category__c == 'Pop Money') {
                addToURL = '&lob=Money%20Movement';
        } else if(currentIdea.Di_Idea_Category__c == 'General Admin Platform' || 
                    currentIdea.Di_Idea_Category__c == 'End User Support' || 
                    currentIdea.Di_Idea_Category__c == 'Branding and Flexibility' || 
                    currentIdea.Di_Idea_Category__c == 'Admin Platform User Management and Security' || 
                    currentIdea.Di_Idea_Category__c == 'Reporting' || 
                    currentIdea.Di_Idea_Category__c == 'Create Your Own/SSO and API Integration' || 
                    currentIdea.Di_Idea_Category__c == 'Interfaces' || 
                    currentIdea.Di_Idea_Category__c == 'Security' || 
                    currentIdea.Di_Idea_Category__c == 'Other' || 
                    currentIdea.Di_Idea_Category__c == 'Idea Exchange') {
                addToURL = '&lob=Platform%20Solutions';
        } else if(currentIdea.Di_Idea_Category__c == 'General Digital Banking' || 
                    currentIdea.Di_Idea_Category__c == 'Deposit Accounts' || 
                    currentIdea.Di_Idea_Category__c == 'Other Accounts' || 
                    currentIdea.Di_Idea_Category__c == 'Authentication & Settings' || 
                    currentIdea.Di_Idea_Category__c == 'FinanceWorks' || 
                    currentIdea.Di_Idea_Category__c == 'Alerts' || 
                    currentIdea.Di_Idea_Category__c == 'Transfers' || 
                    currentIdea.Di_Idea_Category__c == 'Online Statements' || 
                    currentIdea.Di_Idea_Category__c == 'Registration' || 
                    currentIdea.Di_Idea_Category__c == 'Shared Access' || 
                    currentIdea.Di_Idea_Category__c == 'Remote Deposit' || 
                    currentIdea.Di_Idea_Category__c == 'Customer Support' || 
                    currentIdea.Di_Idea_Category__c == 'Web/Direct Connect' || 
                    currentIdea.Di_Idea_Category__c == 'Check/Deposit Imaging') {
                addToURL = '&lob=Retail%20Banking';
        } else {
            addToURL = '';
        }
    
        if(currentIdea.Di_Idea_Category__c == 'Authentication & Settings') {
            String categoryReplacement = 'Authentication and Settings';
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=Authentication%20%26%20Settings' + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        } else {
            PageReference gotorecord = new PageReference('/apex/NCR_ViewAllPage?cat=' + currentIdea.Di_Idea_Category__c + addToURL + '&selectTab=AllIdeas');
            gotorecord.setRedirect(true);
            return gotorecord;
        }
    }
    
    public pageReference saveAttachment(){
        //currentIdea.AttachmentBody = newIdea.AttachmentBody;
        //currentIdea.AttachmentContentType = newIdea.AttachmentContentType;
        //currentIdea.AttachmentName = newIdea.AttachmentName;
        PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeaPage?Id=' + currentIdea.id);
        gotorecord.setRedirect(true);
        try{
            update currentIdea;
            return gotorecord;

        }catch(Exception e){

           gotorecord.getParameters().put('msg','Upload Failed');
           return gotorecord;
        }
    }

}