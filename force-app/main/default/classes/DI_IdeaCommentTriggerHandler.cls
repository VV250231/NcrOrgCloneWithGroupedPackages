public class DI_IdeaCommentTriggerHandler {
    public void ValidateIdeaCommentText(List<IdeaComment> newList) {
        set <DI_IdeaExchange_Bad_Words__c>  words = new set <DI_IdeaExchange_Bad_Words__c>([select id , name from DI_IdeaExchange_Bad_Words__c]);
        
        for(IdeaComment ida : newList)
        {
            for(DI_IdeaExchange_Bad_Words__c word : words)
            {
                if(ida.CommentBody.equalsIgnoreCase(word.name))
                {
                    ida.addError(system.label.vl_Id_CmTest1); //Please change Comment
                }
            }
        }
    }
    
    public void IdeaReceivedComments(List<IdeaComment> newList) {
      Set<Id> ideaIds = new Set<Id>();
      Set<Id> ideaCreatorIds = new Set<Id>();
      
      
      for (IdeaComment comment: newList) {
          ideaIds.add(comment.IdeaId);
          ideaCreatorIds.add(comment.CreatedById);
      }
      
      //get the send To Addresses
      List<OrgWideEmailAddress> OrgWideEmailAddresses = new List<OrgWideEmailAddress>();
      OrgWideEmailAddresses = [SELECT Id, address FROM OrgWideEmailAddress WHERE address = 'idea.exchange@ncr.com' LIMIT 1];
      
      Map<Id,User> idToCommentCreator = new Map<Id,User>([SELECT Id,Name,Email FROM User WHERE Id IN:ideaCreatorIds]);
      
      Map<Id,Idea> idToIdea = new Map<Id,Idea>([SELECT Id, Title , Createdbyid, CreatorName , Di_Idea_Product_Manager_Name__c , Di_Idea_Product_Manager_Email__c , Di_Idea_Alt_1st_Product_Manager__c , Di_Idea_Alt_1st_Product_Manager__r.name  ,Di_Idea_Alt_1st_Product_Manager__r.Email, Di_Idea_Alt_2nd_Product_Manager__c , Di_Idea_Alt_2nd_Product_Manager__r.name ,Di_Idea_Alt_2nd_Product_Manager__r.email, Di_Idea_Alt_3rd_Product_Manager__c , Di_Idea_Alt_3rd_Product_Manager__r.name,Di_Idea_Alt_3rd_Product_Manager__r.email FROM Idea WHERE id IN: ideaIds]);
      
      // Find Product manger user records becasue on object level on Idea recoed project manager is a pick list field with PM names
      Set<String> productMangers = new Set<String>();
      for(Idea ideaRec : idToIdea.values()) {
          productMangers.add(ideaRec.Di_Idea_Product_Manager_Name__c );
      }
      
      Map<Id,User> idToUser = new Map<Id,User>([SELECT Id , Name,Email FROM User where Name IN: productMangers AND (Profile.Name ='60 DI Product Managers' OR Profile.Name ='62 DI Account Manager')]);
      Map<String,User> userNameToUser = new Map<String,User>();
      for (User u : idToUser.values()) {
          userNameToUser.put(u.Name,u);
      }
      
      
      // Get list of user who has Ideas in their favorite list
      Map<Id,List<Di_Idea_Favorites__c>> ideaIdToFavoriteFor= new Map<Id,List<Di_Idea_Favorites__c>>();
      
      for (Di_Idea_Favorites__c fav : [select id , Di_Idea__c , User__c ,User__r.name,User__r.email from Di_Idea_Favorites__c where Di_Idea__c =: ideaIds]) {        
          if (ideaIdToFavoriteFor.get(fav.Di_Idea__c) == null) {
              ideaIdToFavoriteFor.put(fav.Di_Idea__c, new List<Di_Idea_Favorites__c>());
          }
          ideaIdToFavoriteFor.get(fav.Di_Idea__c).add(fav);
      }
      
      //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
      List<NCR_EmailMessage__c> mails = new List<NCR_EmailMessage__c>();
      for (IdeaComment comment: newList) {
          if (idToIdea.get(comment.IdeaId) != NULL) {
              // Mail for Product Manager
              if (idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c !='' && userNameToUser.get(idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c) != null) {
                  String sub='Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title;
                  NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                  ncrEmail.HTML_Body__c='Hi '+ userNameToUser.get(idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c).Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange';
                  ncrEmail.Recipient1__c = userNameToUser.get(idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c).Email;
                  mails.add(ncrEmail);
                  //Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  //mail.setTargetObjectId(userNameToUser.get(idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c).Id);
                  /*if (OrgWideEmailAddresses.size() > 0) {
                      mail.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                  } */   
                  //mail.setSaveAsActivity(false);
                  //mail.setSubject('Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title);
                  //mail.sethtmlBody('Hi '+ userNameToUser.get(idToIdea.get(comment.IdeaId).Di_Idea_Product_Manager_Name__c).Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange');
                  //mails.add(mail);
              }
              
              // Mail for alternativ product managers
              if (idToIdea.get(comment.IdeaId).Di_Idea_Alt_1st_Product_Manager__c != null) {
                  String sub='Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title;
                  NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                  ncrEmail.HTML_Body__c='Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_1st_Product_Manager__r.Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange';
                  ncrEmail.Recipient1__c = idToIdea.get(comment.IdeaId).Di_Idea_Alt_1st_Product_Manager__r.Email;
                  mails.add(ncrEmail);
                  /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTargetObjectId(idToIdea.get(comment.IdeaId).Di_Idea_Alt_1st_Product_Manager__c);
                  if (OrgWideEmailAddresses.size() > 0) {
                      mail.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                  }   
                  mail.setSaveAsActivity(false);
                  mail.setSubject('Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title);
                  mail.sethtmlBody('Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_1st_Product_Manager__r.Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange');
                  mails.add(mail);*/
              }
              
              if (idToIdea.get(comment.IdeaId).Di_Idea_Alt_2nd_Product_Manager__c != null) {
                  String sub='Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title;
                  NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                  ncrEmail.HTML_Body__c='Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_2nd_Product_Manager__r.Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange';
                  ncrEmail.Recipient1__c = idToIdea.get(comment.IdeaId).Di_Idea_Alt_2nd_Product_Manager__r.Email;
                  mails.add(ncrEmail);
                  /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTargetObjectId(idToIdea.get(comment.IdeaId).Di_Idea_Alt_2nd_Product_Manager__c );
                  if (OrgWideEmailAddresses.size() > 0) {
                      mail.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                  }    
                  mail.setSaveAsActivity(false);
                  mail.setSubject('Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title);
                  mail.sethtmlBody('Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_2nd_Product_Manager__r.Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange');        
                  mails.add(mail);*/
              }
              
              if (idToIdea.get(comment.IdeaId).Di_Idea_Alt_3rd_Product_Manager__c != null) {
                  String sub='Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title;
                  NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                  ncrEmail.HTML_Body__c='Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_3rd_Product_Manager__r .Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange';
                  ncrEmail.Recipient1__c = idToIdea.get(comment.IdeaId).Di_Idea_Alt_3rd_Product_Manager__r.Email;
                  mails.add(ncrEmail);
                  /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  mail.setTargetObjectId(idToIdea.get(comment.IdeaId).Di_Idea_Alt_3rd_Product_Manager__c);
                  if (OrgWideEmailAddresses.size() > 0) {
                      mail.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                  }
                  mail.setSaveAsActivity(false);
                  mail.setSubject('Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title);
                  mail.sethtmlBody('Hi '+ idToIdea.get(comment.IdeaId).Di_Idea_Alt_3rd_Product_Manager__r .Name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange');        
                  mails.add(mail);*/
              }       
              
              // User who has idea in their favourite list
              if(ideaIdToFavoriteFor.get(comment.IdeaId) != null) {
                  for (Di_Idea_Favorites__c fav: ideaIdToFavoriteFor.get(comment.IdeaId)) {
                      String sub='Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title;
                      NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                      ncrEmail.HTML_Body__c='Hi '+ fav.User__r.name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange';
                      ncrEmail.Recipient1__c = fav.User__r.Email;
                      mails.add(ncrEmail);
                      /*Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                      mail.setTargetObjectId(fav.User__c);
                      if (OrgWideEmailAddresses.size() > 0) {
                          mail.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                      }
                      mail.setSaveAsActivity(false);
                      mail.setSubject('Re: Idea Exchange: '+ idToIdea.get(comment.IdeaId).Title);
                      mail.sethtmlBody('Hi '+ fav.User__r.name +','+'<br/><br/>'+'<b>'+ idToIdea.get(comment.IdeaId).Title + '</b>'+' has received new comments from '+idToCommentCreator.get(comment.CreatedById).Name+'<br/><br>'+comment.CommentBody+'<br/><br>'+'Regards'+'<br>'+'IdeaExchange');        
                      mails.add(mail);*/
                  }
              }
          }
      }
      
      /*if (!Test.isRunningTest()) {
          if (mails.size() > 0) {
              insert mails;
          }
      }*/
      
      
      
      /*
   * @description:    Sending notification to Ideatheme Owner, IdeaTheme Co-Owner and Fi-user(who has Ideatheme added in their favorite list) when Commented on idea.
   * @author:         Rajasekhar reddy(Rajasekhar.reddy@ncr.com)
   * @createdDate     August 09, 2016
   */   
      
      	if (ideaIds.size()>0 && ideaIds != null) {
         // List<NCR_EmailMessage__c> emails = new List<NCR_EmailMessage__c>();
          List<Idea> idalst = [select id,ideathemeId,ideatheme.DI_Owner__c,Title,ideatheme.DI_Owner__r.title,ideatheme.title,ideatheme.DI_Owner__r.Name,ideatheme.DI_Owner__r.Email, ideatheme.DI_Co_owner__r.Email,ideatheme.DI_Co_owner__r.Name,
                               ideatheme.DI_Co_owner__c,FI_Name__c from Idea where id in:ideaIds and ideathemeId != null];
          Set<Id> idthm = new Set<Id>();
          
          for(Idea obj:idalst ) {
              if(obj.ideathemeId!=null) {
                  idthm.add(obj.ideathemeId);
              }
          }
          
          
          if(idthm.size()>0 && idthm != null) {
              Map<Id,List<Di_Idea_Favorites__c>> maptheme = new Map<Id,List<Di_Idea_Favorites__c>>();
              List<Di_Idea_Favorites__c> lstyfi = [select id,name,User__c,User__r.Name,user__r.Profile.Name,User__r.Email,User__r.DI_Fi_Domain__c,DI_Idea_Theme__c,DI_Idea_Theme__r.DI_Co_owner__c,DI_Idea_Theme__r.DI_Co_owner__r.Email,DI_Idea_Theme__r.DI_Owner__r.Email,DI_Idea_Theme__r.DI_Owner__c from Di_Idea_Favorites__c where DI_Idea_Theme__c in:idthm and User__r.DI_Fi_Domain__c !=null];
              
              for (Di_Idea_Favorites__c objfv :lstyfi) {
                  if (!maptheme.containskey(objfv.DI_Idea_Theme__c)) {
                      maptheme.put(objfv.DI_Idea_Theme__c,new List<Di_Idea_Favorites__c>());
                  }
                  maptheme.get(objfv.DI_Idea_Theme__c).add(objfv);
              }
              
              //List<Messaging.SingleEmailMessage> emaillst = new  List<Messaging.SingleEmailMessage>(); 
              for (IdeaComment cmt:newList) {
                  for (Idea obj:idalst) {
                      if (cmt.ideaId==obj.Id) {
                          if (obj.ideatheme.DI_Owner__c != null) {
                              /*List<String> toList = new List<String>();
                              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                              email.setTargetObjectId(obj.ideatheme.DI_Owner__c);
                              toList.add(obj.ideatheme.DI_Owner__r.Email);
                              email.setToAddresses(toList);
                              email.setSaveAsActivity(false); 
                              email.setSubject('IdeaExchange : '+obj.ideatheme.title);
                              if (OrgWideEmailAddresses.size() > 0) {
                                  email.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                              }
                              String crntUsrName = UserInfo.getName();
                              String body = '<html><body>Hello ' + obj.ideatheme.DI_Owner__r.Name +',<br><br> '+'<b>'+obj.Title+'</b> has received new comments from '+'<b>'+crntUsrName+'</b>.This idea is posted to the Theme '+'<b>'+obj.ideatheme.title+'</b>.<br/><br/><b>'+cmt.CommentBody+'</b><br/><br/>Please login to see details.<br/><br/><a href=https://ncr.my.salesforce.com/'+obj.Id+'>https://ncr.my.salesforce.com/'+obj.Id+'</a><br/>Regards,<br/>IdeaExchange</body></html>';
                              email.sethtmlBody(body);
                              emaillst.add(email);*/
                              String sub='IdeaExchange : '+obj.ideatheme.title;
                              String crntUsrName = UserInfo.getName();
                              String body = '<html><body>Hello ' + obj.ideatheme.DI_Owner__r.Name +',<br><br> '+'<b>'+obj.Title+'</b> has received new comments from '+'<b>'+crntUsrName+'</b>.This idea is posted to the Theme '+'<b>'+obj.ideatheme.title+'</b>.<br/><br/><b>'+cmt.CommentBody+'</b><br/><br/>Please login to see details.<br/><br/><a href=https://ncr.my.salesforce.com/'+obj.Id+'>https://ncr.my.salesforce.com/'+obj.Id+'</a><br/>Regards,<br/>IdeaExchange</body></html>';
                              NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                              ncrEmail.HTML_Body__c=body;
                              ncrEmail.Recipient1__c = obj.ideatheme.DI_Owner__r.Email;
                              mails.add(ncrEmail);
                          }
                          if (obj.ideatheme.DI_Co_owner__c != null) {
                              /*List<String> toList = new List<String>();
                              Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                              email.setTargetObjectId(obj.ideatheme.DI_Co_owner__c );
                              toList.add(obj.ideatheme.DI_Co_owner__r.Email);
                              email.setToAddresses(toList);
                              email.setSaveAsActivity(false); 
                              email.setSubject('IdeaExchange : '+obj.ideatheme.title);
                              if (OrgWideEmailAddresses.size() > 0) {
                                  email.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                              }*/
                              String crntUsrName = UserInfo.getName();
                              String body = '<html><body>Hello ' + obj.ideatheme.DI_Co_owner__r.Name +',<br><br>'+'<b>'+obj.Title+'</b> has received new comments from '+'<b>'+crntUsrName+'</b>.This idea is posted to the Theme '+'<b>'+obj.ideatheme.title+'</b>.<br/><br/><b>'+cmt.CommentBody+'</b><br/><br/>Please login to see details.<br/><br/> <a href=https://ncr.my.salesforce.com/'+obj.Id+'>https://ncr.my.salesforce.com/'+obj.Id+'</a><br/>Regards,<br/>IdeaExchange</body></html>';
                              String sub='IdeaExchange : '+obj.ideatheme.title;
                              NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                              ncrEmail.HTML_Body__c=body;
                              ncrEmail.Recipient1__c = obj.ideatheme.DI_Co_owner__r.Email;
                              mails.add(ncrEmail);
                              /*email.sethtmlBody(body);
                              emaillst.add(email);*/ 
                          }
                          
                          if (maptheme.containsKey(obj.ideathemeId)) {
                              for (Di_Idea_Favorites__c fvobj:maptheme.get(obj.ideathemeId)) {
                                  /*List<String> toList = new List<String>();
                                  
                                  Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                  email.setTargetObjectId(fvobj.user__c);
                                  toList.add(fvobj.user__r.Email);
                                  email.setToAddresses(toList);
                                  email.setSaveAsActivity(false); 
                                  email.setSubject('IdeaExchange : '+obj.ideatheme.title);
                                  if (OrgWideEmailAddresses.size() > 0) {
                                      email.setOrgWideEmailAddressId(OrgWideEmailAddresses[0].Id);
                                  }*/
                                  String crntUsrName = UserInfo.getName();
                                  String strdomain = fvobj.User__r.DI_Fi_Domain__c;
                                  String fnldomail;
                                  String hrf;
                                  
                                  if (strdomain.contains('http')) {
                                      fnldomail = strdomain.Replace('http','https');
                                  }
                                  if (fvobj.user__r.Profile.Name =='61 DI Community Members') {
                                      hrf = '<a href='+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+obj.id+'>'+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+obj.id+'</a>';
                                      // hrf = '<a href=https://ncr.my.salesforce.com/'+fvobj.id+'>https://ncr.my.salesforce.com/'+fvobj.id+'</a>';
                                  }
                                  if(fvobj.user__r.Profile.Name =='60 DI Product Managers' || fvobj.user__r.Profile.Name =='62 DI Account Manager') {
                                      //  hrf = '<a href='+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+fvobj.id+'>'+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+fvobj.id+'</a>';
                                      hrf = '<a href=https://ncr.my.salesforce.com/'+obj.id+'>https://ncr.my.salesforce.com/'+obj.id+'</a>';
                                  }
                                  
                                  // String body = '<html><body>Hello ' + fvobj.User__r.Name +',<br><br> '+'<b>'+obj.Title+'</b> has received new comments from '+'<b>'+crntUsrName+'</b>.This idea is posted to the Theme '+'<b>'+obj.ideatheme.title+'</b>.<br/><br/><b>'+cmt.CommentBody+'</b><br/><br/>Please login to see details.<br/><a href=https://ncr--cert.cs45.my.salesforce.com/ideas/viewIdea.apexp?id='+obj.id+'>https://ncr--cert.cs45.my.salesforce.com/ideas/viewIdea.apexp?id='+obj.id+'</a><br/><br/><a href='+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+obj.Id+'>'+fnldomail+'/connect/group/products/idea-exchange?redirectUrl=/apex/NCR_ViewIdeapage?id='+obj.Id+'</a><br/>Regards,<br/>IdeaExchange</body></html>';
                                  String body = '<html><body>Hello ' + fvobj.User__r.Name +',<br><br> '+'<b>'+obj.Title+'</b> has received new comments from '+'<b>'+crntUsrName+'</b>.This idea is posted to the Theme '+'<b>'+obj.ideatheme.title+'</b>.<br/><br/><b>'+cmt.CommentBody+'</b><br/><br/>Please login to see details.<br/><br/>'+hrf+'<br/>Regards,<br/>IdeaExchange</body></html>';
                                  String sub='IdeaExchange : '+obj.ideatheme.title;
                                  NCR_EmailMessage__c ncrEmail = new NCR_EmailMessage__c(Email_Type__c = 'IdeaExchange', Subject__c =sub , title__c=sub); 
                                  ncrEmail.HTML_Body__c=body;
                                  ncrEmail.Recipient1__c = fvobj.user__r.Email;
                                  mails.add(ncrEmail);
                                  /*email.sethtmlBody(body);
                                  emaillst.add(email);*/ 
                              }
                              
                          } 
                          
                          //Messaging.sendEmail(emaillst);              
                      }
                  }
              } 
              
          }
      }
        if (!Test.isRunningTest()) {
            if (mails.size() > 0) {
                insert mails;
            }
        }
  }
    
}