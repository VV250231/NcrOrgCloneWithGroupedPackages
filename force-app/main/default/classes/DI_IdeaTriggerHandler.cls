public class DI_IdeaTriggerHandler {
    
    /*
     * Di_Internal_Category_Name__c,Di_Idea_Product_Manager_Name__c,Di_Idea_Product_Manager_Email__c
     * get set based on internal mapping.
     */
    public void fillInternalMapping(List<Idea> newList) {
        List <Di_Idea_Internal_Category_Map__c> iMapList = new List <Di_Idea_Internal_Category_Map__c>();
        iMapList = [select id , Di_Idea_Channel__c  , Di_Idea_Line_of_Business__c  , Di_Idea_Category__c , Di_Internal_Category_Name__c , Di_Idea_Product_Manager_Name__c  from Di_Idea_Internal_Category_Map__c];
        Map<String, String> iMapInternal = new Map<String , String>();
        Map<String, String> iMapProductMgr = new Map<String , String>();
        String key , val1 , val2 ;
        
        //CREATE MAP WITH KEY AND VALUES (CUSTOM KEY : INTERNAL_CATEGORY) AND (CUSTOM KEY : PRODUCT_MANAGER)
        for(Di_Idea_Internal_Category_Map__c iCategoryMap : iMapList) {
            key = null ; val1 = null ; val2 = null ;
            key = iCategoryMap.Di_Idea_Channel__c + iCategoryMap.Di_Idea_Line_of_Business__c + iCategoryMap.Di_Idea_Category__c ;
            val1 = iCategoryMap.Di_Internal_Category_Name__c ;
            val2 = iCategoryMap.Di_Idea_Product_Manager_Name__c ;
            iMapInternal.put(key.toUpperCase().deleteWhitespace(),val1);
            iMapProductMgr.put(key.toUpperCase().deleteWhitespace(),val2);
        }
        
        
        //FOR EVERY IDEA SUBMITTED , EVALUATE THE SELECTION >> CALCULATE THE KEY >> FETCH THE VALUE FROM PREVIOUSLY CREATED MAP >> MAKE ASSIGNATION
        for(Idea idea : newList) { 
            //if (idea.IdeaThemeId == null) {
            String s = idea.Di_Idea_Channel__c+idea.Di_Idea_Line_of_Business__c+idea.Di_Idea_Category__c;
            if(iMapInternal.get(s.toUpperCase().deleteWhitespace())==null) {
                idea.Di_Internal_Category_Name__c = 'User Error';
            } else {
                idea.Di_Internal_Category_Name__c  = iMapInternal.get(s.toUpperCase().deleteWhitespace());
            }
            if(iMapProductMgr.get(s.toUpperCase().deleteWhitespace()) == null) {
                idea.Di_Idea_Product_Manager_Name__c = 'Lindsey Speranza';
            } else {
                idea.Di_Idea_Product_Manager_Name__c = iMapProductMgr.get(s.toUpperCase().deleteWhitespace());
            } 
            
        }
        //POPULATE THE SELECTED PRODUCT MANAGERS EMAIL IN EMAIL FIELDS AND LOOKUP FIELD
        list<string> pms = new list<string>();
        
        for(idea a : newList) { 
            if (a.IdeaThemeId == null) {
                pms.add(a.Di_Idea_Product_Manager_Name__c); 
            }
        }
        list<user> pms2   =  new list<user>([select id , name , email from user where name in: pms AND Profile.Name != '61 DI Community Members' ]);
        map <string,string> usermap = new map<string,string>();
        map <string,string> usermap2 = new map<string,string>();
        for(user u : pms2) {
            usermap.put(u.name,u.email);
            usermap2.put(u.name,u.id);
        }
        for(idea i : newList) { 
            if (i.IdeaThemeId == null) {
                if(usermap.get(i.Di_Idea_Product_Manager_Name__c) == null) {
                    i.Di_Idea_Product_Manager_Email__c   = 'lindsey.speranza@digitalinsight.com';
                } else {
                    i.Di_Idea_Product_Manager_Email__c   =       usermap.get(i.Di_Idea_Product_Manager_Name__c);
                } 
            }
        }
    }
    
    /*
* Update Di_Idea_Product_Manager_Email__c when PM is changed.
*/
    public void updateProdMangEmail(List<Idea> newList) {
        list<string> pms3 = new list<string>();
        
        for(idea a : newList) {
            if (a.IdeaThemeId == null) {
                pms3.add(a.Di_Idea_Product_Manager_Name__c);
            }
        }
        list<user> pms4   =  new list<user>([select id , name , email from user where name in: pms3 AND Profile.Name != '61 DI Community Members']);
        map <string,string> usermap3 = new map<string,string>();
        map <string,string> usermap4 = new map<string,string>();
        for(user u : pms4) {
            usermap3.put(u.name,u.email);
            usermap4.put(u.name,u.id);
        }
        for(idea i : newList) { 
            if (i.IdeaThemeId == null) {
                if(usermap3.get(i.Di_Idea_Product_Manager_Name__c) == null) {
                    i.Di_Idea_Product_Manager_Email__c   = 'lindsey.speranza@digitalinsight.com';
                } else {
                    i.Di_Idea_Product_Manager_Email__c   =       usermap3.get(i.Di_Idea_Product_Manager_Name__c);
                }
            }
        }
    }
    
    public void createIdeaHistory(Map<Id,Idea> oldMap,Map<Id,Idea> newMap) {
        List<Di_Idea_History__c> ideaHistoryList = new List<Di_Idea_History__c>();
        Di_Idea_History__c NewUpdate;
        Boolean isIdeaHistoryInsert = false;
        
        if (checkRecursive.runCreateIdeaHistoryOnce()) {
            for(Idea rec: newMap.values()) {
                NewUpdate = new Di_Idea_History__c();
                isIdeaHistoryInsert = false;
                
                NewUpdate.Di_Idea_Id__c = rec.ID ;
                Idea newRec = newMap.get(rec.Id);
                Idea oldRec = oldMap.get(rec.Id);
                
                if (newRec.Di_Idea_Alt_1st_Product_Manager__c != oldRec.Di_Idea_Alt_1st_Product_Manager__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Alt_1st_Product_Manager__c = newRec.Di_Idea_Alt_1st_Product_Manager__c ;
                    NewUpdate.Di_Idea_OLD_Alt_1st_Product_Manager__c = oldRec.Di_Idea_Alt_1st_Product_Manager__c ;      
                }
                
                if (newRec.Di_Idea_Alt_2nd_Product_Manager__c != oldRec.Di_Idea_Alt_2nd_Product_Manager__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Alt_2nd_Product_Manager__c = newRec.Di_Idea_Alt_2nd_Product_Manager__c ;
                    NewUpdate.Di_Idea_OLD_Alt_2nd_Product_Manager__c = oldRec.Di_Idea_Alt_2nd_Product_Manager__c ;
                }
                
                if (newRec.Di_Idea_Alt_3rd_Product_Manager__c != oldRec.Di_Idea_Alt_3rd_Product_Manager__c ) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Alt_3rd_Product_Manager__c = newRec.Di_Idea_Alt_3rd_Product_Manager__c ;
                    NewUpdate.Di_Idea_OLD_Alt_3rd_Product_Manager__c = oldRec.Di_Idea_Alt_3rd_Product_Manager__c ;
                }
                
                if (newRec.Di_Idea_Category__c != oldRec.Di_Idea_Category__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Category__c = newRec.Di_Idea_Category__c ;
                    NewUpdate.Di_Idea_OLD_Category__c = oldRec.Di_Idea_Category__c ;
                }
                
                if (newRec.Di_Idea_Channel__c != oldRec.Di_Idea_Channel__c) {
                    NewUpdate.Di_Idea_NEW_Channel__c = newRec.Di_Idea_Channel__c ;
                    NewUpdate.Di_Idea_OLD_Channel__c = oldRec.Di_Idea_Channel__c ;
                }
                
                if (newRec.Di_Idea_DI_Release_Date__c != oldRec.Di_Idea_DI_Release_Date__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Release_Date__c = newRec.Di_Idea_DI_Release_Date__c ;
                    NewUpdate.Di_Idea_OLD_Release_Date__c = oldRec.Di_Idea_DI_Release_Date__c ;
                }
                
                if (newRec.Di_Idea_DI_Release_Number__c != oldRec.Di_Idea_DI_Release_Number__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Release_Number__c = newRec.Di_Idea_DI_Release_Number__c ;
                    NewUpdate.Di_Idea_OLD_Release_Number__c = oldRec.Di_Idea_DI_Release_Number__c ;
                }
                
                if (newRec.Di_Idea_Due_Date__c != oldRec.Di_Idea_Due_Date__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Due_Date__c = newRec.Di_Idea_Due_Date__c ;
                    NewUpdate.Di_Idea_OLD_Due_Date__c = oldRec.Di_Idea_Due_Date__c ;
                }
                
                if (newRec.Di_Idea_Featured_Flag__c != oldRec.Di_Idea_Featured_Flag__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Featured_Flag__c = newRec.Di_Idea_Featured_Flag__c ;
                    NewUpdate.Di_Idea_OLD_Featured_Flag__c = oldRec.Di_Idea_Featured_Flag__c ;
                }
                
                if (newRec.Di_Idea_Featured_Image__c != oldRec.Di_Idea_Featured_Image__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Featured_Image__c = newRec.Di_Idea_Featured_Image__c ;
                    NewUpdate.Di_Idea_OLD_Featured_Image__c = oldRec.Di_Idea_Featured_Image__c ;
                }
                
                if (oldRec.Body != newRec.Body) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_OLD_Body__c = oldRec.Body ;
                    NewUpdate.Di_Idea_NEW_Body__c = newRec.Body ;
                }
                
                if (newRec.Di_Internal_Category_Name__c != oldRec.Di_Internal_Category_Name__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Internal_Category_Name__c = newRec.Di_Internal_Category_Name__c ;
                    NewUpdate.Di_Idea_OLD_Internal_Category_Name__c = oldRec.Di_Internal_Category_Name__c ;
                }
                
                if (newRec.Di_Idea_Jira_Number__c != oldRec.Di_Idea_Jira_Number__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Jira_Number__c = newRec.Di_Idea_Jira_Number__c ;
                    NewUpdate.Di_Idea_OLD_Jira_Number__c = oldRec.Di_Idea_Jira_Number__c ;
                }
                
                if (newRec.Di_Idea_Line_of_Business__c != oldRec.Di_Idea_Line_of_Business__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Line_of_Business__c = newRec.Di_Idea_Line_of_Business__c ;
                    NewUpdate.Di_Idea_OLD_Line_of_Business__c = oldRec.Di_Idea_Line_of_Business__c ;
                }
                
                if (newRec.Di_Idea_Product_Manager_Email__c != oldRec.Di_Idea_Product_Manager_Email__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Product_Manager_Email__c = newRec.Di_Idea_Product_Manager_Email__c ;
                    NewUpdate.Di_Idea_OLD_Product_Manager_Email__c = oldRec.Di_Idea_Product_Manager_Email__c ;
                }
                
                if (newRec.Di_Idea_Product_Manager_Name__c != oldRec.Di_Idea_Product_Manager_Name__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Product_Manager_Name__c = newRec.Di_Idea_Product_Manager_Name__c ;
                    NewUpdate.Di_Idea_OLD_Product_Manager_Name__c = oldRec.Di_Idea_Product_Manager_Name__c ;
                }
                
                if (newRec.Di_Idea_SLA_Status__c != oldRec.Di_Idea_SLA_Status__c) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_SLA_Status__c = newRec.Di_Idea_SLA_Status__c ;
                    NewUpdate.Di_Idea_OLD_SLA_Status__c = oldRec.Di_Idea_SLA_Status__c ;
                }
                
                if (newRec.Status != oldRec.Status) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Status__c = newRec.Status ;
                    NewUpdate.Di_Idea_OLD_Status__c = oldRec.Status ;
                }
                
                if (newRec.Title != oldRec.Title) {
                    isIdeaHistoryInsert = true;
                    NewUpdate.Di_Idea_NEW_Title__c = newRec.Title ;
                    NewUpdate.Di_Idea_OLD_Title__c = oldRec.Title ;
                }
                
                if (isIdeaHistoryInsert) {
                    ideaHistoryList.add(NewUpdate);
                }
            }
            if (ideaHistoryList.size() > 0) {
                insert ideaHistoryList;
            }
        }
    }
    
    public void subscriptionMail(List<Idea> newList) {
        Map<string,string> IdeaMap=new Map<string,string>();
        Map<Id,user> userMap=new Map<Id,user>();
        Map<string,set<Id>> ideamapnew=new Map<string,set<Id>>();
        List<DI_IdeaSubscription__c> ideaSubscriptionList= New List<DI_IdeaSubscription__c> ();
        set<id> listforIdea=new set <id>();
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(idea ic:newList) {
            IdeaMap.put(ic.Di_Idea_Line_of_Business__c,ic.Di_Idea_Category__c);
        }
        
        if(!IdeaMap.isEmpty()) { 
            ideaSubscriptionList=[select id,DI_LineOfBusiness__c,DI_SubscriptionCategory__c,DI_UserName__c from DI_IdeaSubscription__c where (DI_LineOfBusiness__c in : IdeaMap.keyset() AND DI_SubscriptionCategory__c in :IdeaMap.values() and DI_UserName__c!=null) limit :Limits.getLimitDmlRows()];
        }
        
        
        for(idea idea:newList ) {
            listforIdea.clear();
            for(DI_IdeaSubscription__c ic:ideaSubscriptionList){
                if(ic.DI_LineOfBusiness__c==idea.Di_Idea_Line_of_Business__c && ic.DI_SubscriptionCategory__c==idea.Di_Idea_Category__c){
                    listforIdea.add(ic.DI_UserName__c);
                }
            } 
            ideamapnew.put(idea.id,listforIdea);
        }
        
        for(user user :[select id, name,DI_Fi_Domain__c,DI_Fi_Name__c from user where (id in :listforIdea and DI_Fi_Domain__c!=null) limit :Limits.getLimitDmlRows()]){
            userMap.put(user.id,user);
        }
        
        //get the send To Addresses
        List<OrgWideEmailAddress> emailAddresses = new List<OrgWideEmailAddress>();
        emailAddresses = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'idea.exchange@ncr.com']; 
        
        for (Idea ideaRec : newList) {
            if (ideamapnew.get(ideaRec.id).size()> 0) {
                for(id emailId:ideamapnew.get(ideaRec.id)){
                    if(userMap.containskey(emailId)){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(emailId);
                        if (emailAddresses.size() > 0) {
                            mail.setOrgWideEmailAddressId(emailAddresses[0].Id);
                        }    
                        mail.setSaveAsActivity(false);
                        mail.setSubject('Idea Exchange: '+ideaRec.Title);
                        String htmlBody = 'Hello '+ userMap.get(emailId).name+','+'<br/><br/>'+'A new idea has been posted to a category that you are subscribed : '+'<b>'+ ideaRec.Di_Idea_Line_of_Business__c +' , '+ideaRec.Di_Idea_Category__c+'</b>';
                        htmlBody=htmlBody+'<br/><br/>'+ideaRec.Title+'<br/><br/>'+ideaRec.Body+'<br/><br/>'+'Please login to Idea Exchange to see details, comment and vote.';
                        htmlBody = htmlBody + '<br/><br/>'+userMap.get(emailId).DI_Fi_Domain__c + '/' +'connect'+'/'+'group'+'/'+'products'+'/'+'idea-exchange'+'?'+'redirectUrl='+'/'+'apex'+'/'+'NCR_ViewIdeapage'+'?'+'id='+String.valueOf(ideaRec.Id)+'<br/><br/>'+'Regards,'+'<br>'+'Idea Exchange';                     
                        mail.sethtmlBody(htmlBody);
                        mails.add(mail);
                    }
                }
            }
        }
        
        if (mails.size() > 0) {
            try{
                Messaging.sendEmailResult[] sendTerminatedEmailResults = Messaging.sendEmail(mails);
            }
            catch(Exception e){
                System.debug('@@@Exception'+e);
            }
        }
    } 
    
    /*
*    @description   :    Updating IdeaTheme object details when selected Ideatheme lookup field in idea object.
*    @author        :    Rajasekhar reddy(Rajasekhar.reddy@ncr.com)
*    @Test Class    :    DI_UpdateFieldsTest
*/
    public void DI_UpdateFields(List<Idea> newList) {
        set<id> IdeaThemeId=new set<id>();
        for(idea i:newList)
        {
            IdeaThemeId.add(i.IdeaThemeId);
        }
        Map<id,IdeaTheme> IdeaThemeMap = new Map<id,IdeaTheme>([Select id, DI_Owner__r.name,DI_Co_owner__r.name, Status, DI_Owner__c, DI_Line_of_Business__c, DI_Category__c, DI_Co_owner__c From IdeaTheme Where id IN: IdeaThemeId]);
        Map<Id,Community> mapcmt;
        List<Network> netWorks = [SELECT Id, Name FROM NetWork WHERE Name = 'IdeaExchange' LIMIT 1];
        if (netWorks.size() > 0) {
            mapcmt = new Map<Id,Community>([SELECT Id, Name FROM Community WHERE NetworkId=: netWorks[0].Id AND Name='IdeaExchange' LIMIT 1]);
        }   
        
        for(Idea ida : newList){
            if(ida.IdeaThemeid!=null && mapcmt.containskey(ida.CommunityId))
            {
                ida.DI_Idea_Theme_Co_Owner__c=IdeaThemeMap.get(ida.IdeaThemeid).DI_Co_owner__r.name;
                ida.DI_Idea_Theme_Owner__c=IdeaThemeMap.get(ida.IdeaThemeid).DI_Owner__r.name;
                ida.DI_Idea_Theme_Status__c=IdeaThemeMap.get(ida.IdeaThemeid).Status;
                ida.Di_Idea_Line_of_Business__c =IdeaThemeMap.get(ida.IdeaThemeid).DI_Line_of_Business__c;
                ida.Di_Idea_Category__c =IdeaThemeMap.get(ida.IdeaThemeid).DI_Category__c;
                /*
when idea created with IdeaThemeId then internal category name and Status fields should be null. 
*/       
                ida.Di_Internal_Category_Name__c=null;
                ida.status=null;
            }         
        }
    }
    
    public void ValidateIdeaText(List<Idea> newList) {
        set <DI_IdeaExchange_Bad_Words__c>  words = new set <DI_IdeaExchange_Bad_Words__c>([select id , name from DI_IdeaExchange_Bad_Words__c]);
        
        for(Idea ida : newList)
        {
            for(DI_IdeaExchange_Bad_Words__c word : words)
            {
                if(ida.title.equalsIgnoreCase(word.name))
                {
                    ida.title.addError(system.label.Vld_id_txt1); //Please change Idea Title
                }
                
                if(ida.body!=null)
                {
                    if(ida.body.equalsIgnoreCase(word.name))
                    {
                        ida.body.addError(system.label.Vld_id_txt2); //Please change Idea Description
                    }
                }
            }
        }
    }
    
    public void ideaStatusChange(List<Idea> newList) {
        /*
        it can't be bulkified due to following error
        Error: Compile Error: Implementation restriction: When querying the Vote object, you must filter using the following syntax: ParentId = [single ID], Parent.Type = [single Type], Id = [single ID], or Id IN [list of ID's]. at line 3 column 20
        so we have to fire query for every record
        */
                /**
        * Last Modified By Shiv Mahla
        * Change: Changing point threshold limit to 100. earliar it was 150.
        */
      
        
        Map<id,List<Vote>> VoteListforIdea= new Map<id,List<Vote>>(); 
        List<Id> ideaIds = new List<Id>();
        
        for(Idea a : newList){
            ideaIds.add(a.id);
        }
        
        for(Id ideaId: ideaIds) {
            VoteListforIdea.put(ideaId, new Vote[0]);
        }
        
        for(Vote v: [SELECT CreatedById,CreatedDate,Id,IsDeleted,ParentId,SystemModstamp,Type FROM Vote  WHERE Parent.Type = 'idea' and ParentId in :ideaIds ]) {
            VoteListforIdea.get(v.ParentId).add(v);
        }
        
     
        for(Idea a : newList)
        {
           //list <vote> votes = [SELECT CreatedById,CreatedDate,Id,IsDeleted,ParentId,SystemModstamp,Type FROM Vote WHERE ParentId =: a.id ];
            //system.debug('>>>'+ votes.size());
            Integer count =0;
            for(Vote v :  VoteListforIdea.get(a.id))
            {
                if(v.type=='Up')
                {
                    count+=10;
                }
                else
                    if(v.type=='Down')
                {
                    count-=10;
                }
            }
            if(count>=150 && a.status=='Under Point Threshold')
            {
                a.status='Product Team Review';
            }
        }
    }
}