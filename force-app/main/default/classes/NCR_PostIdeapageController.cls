/*
*    @description:    Controller for NCR_PostIdeapage.
*    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
*    @createdDate     August 13, 2015
*/
public class NCR_PostIdeapageController {
  
  /** START -- for PostIdeaPage2    **/ 
  public String selectedPostIdeaLineOfBusiness {get;set;}    //render selected line of business for post idea 
  public String selectedPostIdeaCategory {get;set;}          //render selected category for post idea
  public String selectedPostIdeaDevice {get;set;}            //render selected device for post idea
  public String ideaTitle{get;set;}                    //render idea title
  public String ideaBodyValue {get;set;}                     //render idea body
  public Boolean disablePostButton {get;set;}                //render Post Idea button
  public string testBody{get;set;}
  public List<Idea> similarIdeasList {get;set;}
    
  public Idea newIdea {
  get {
    if (newIdea == null)
      newIdea = new Idea();
      return newIdea;
    }
    set;
  }
  Private final Idea idea;    
  /** END -- for PostIdeaPage2  **/
  
  /* public NCR_PostIdeapageController(){
  } commented empty block statement */
  public NCR_PostIdeapageController(ApexPages.StandardController stdController) {
  similarIdeasList = new List<Idea>();
  //newIdea = new Idea();
  this.idea = (Idea)stdController.getRecord();
    disablePostButton = true;
  }
    
      
  /**
   *    @description:    get line of business values.
   *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
   */
  public List<SelectOption> getLineOfBusinessValues() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', 'Select a Line of Business'));   
    Schema.Describefieldresult result = Schema.sObjectType.Idea.fields.Di_Idea_Line_of_Business__c;
    result = result.getSObjectField().getDescribe();            
    List<Schema.PicklistEntry> ple = result.getPicklistValues();                
    for ( Schema.PicklistEntry f : ple) {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
    } 
    options.sort();
    return options;
  }
    
        
  /*
  *    @description:    get device values.
  *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
  */
  public List<SelectOption> getDeviceValues() {
    List<SelectOption> options = new List<SelectOption>();
    if (selectedPostIdeaLineOfBusiness != 'Platform Solutions' || selectedPostIdeaLineOfBusiness == null) {
      options.add(new SelectOption('Online', 'Online'));
      options.add(new SelectOption('Mobile', 'Mobile'));
    }
    options.sort();
    return options;
  }
    

  /*
   *    @description:    get category values.
   *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
   */
  public List<SelectOption> getCategoryValues() {
    List<SelectOption> options = new List<SelectOption>();    
    if (selectedPostIdeaLineOfBusiness == 'Business Banking') {
      options.add(new SelectOption('ACH and Wires', 'ACH and Wires'));
      options.add(new SelectOption('Entitlements', 'Entitlements'));
     options.add(new SelectOption('General Business Banking', 'General Business Banking'));
      options.add(new SelectOption('Third Party Product Integration', 'Third Party Product Integration'));
        //new addition
      options.add(new SelectOption('Customer Support', 'Customer Support'));
        options.add(new SelectOption('Remote Deposit', 'Remote Deposit'));
        options.add(new SelectOption('Reporting', 'Reporting'));
        options.add(new SelectOption('Alerts', 'Alerts'));
        options.add(new SelectOption('Positive Pay', 'Positive Pay'));
        options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
        //Commented  due to EBA_SF-1438
      //options.add(new SelectOption('Deposit Accounts', 'Deposit Accounts'));
      //options.add(new SelectOption('Other Accounts', 'Other Accounts'));
    } else if (selectedPostIdeaLineOfBusiness == 'Consumer Relationship') {
        options.add(new SelectOption('Promotion Suite', 'Promotion Suite'));
         options.add(new SelectOption('Purchase Rewards', 'Purchase Rewards'));
        options.add(new SelectOption('Web Center', 'Web Center'));
         options.add(new SelectOption('Client Services Developed ', 'Client Services Developed '));
        //EBA_SF-1438
        //options.add(new SelectOption('Online Account Opening', 'Online Account Opening'));
        //options.add(new SelectOption('Other', 'Other'));
    } else if (selectedPostIdeaLineOfBusiness == 'Money Movement') {
        options.add(new SelectOption('General Payments', 'General Payments'));
        options.add(new SelectOption('Bill Pay', 'Bill Pay'));
        options.add(new SelectOption('External Funds Transfer', 'External Funds Transfer'));
        //New addition EBA_SF-1438
        options.add(new SelectOption('Person to Person Payments', 'Person to Person Payments'));
        options.add(new SelectOption('Internal Transfers', 'Internal Transfers'));
        options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
        //EBA_SF-1438
        //options.add(new SelectOption('Pop Money', 'Pop Money'));
    } else if (selectedPostIdeaLineOfBusiness == 'Platform Solutions') {
        options.add(new SelectOption('General Admin Platform', 'General Admin Platform'));
        //options.add(new SelectOption('End User Support', 'End User Support'));
        // new adition 	EBA_SF-1438
        options.add(new SelectOption('Admin User Support', 'Admin User Support'));
        options.add(new SelectOption('Branding and Flexibility', 'Branding and Flexibility'));
        options.add(new SelectOption('Data & Reporting', 'Data & Reporting'));
        options.add(new SelectOption('SSO and API Solutions', 'SSO and API Solutions'));
        options.add(new SelectOption('Interfaces', 'Interfaces'));
        options.add(new SelectOption('Security & Authentication', 'Security & Authentication'));
        options.add(new SelectOption('Idea Exchange', 'Idea Exchange'));
        options.add(new SelectOption('Alerts & Communication', 'Alerts & Communication'));
        options.add(new SelectOption('Account Opening', 'Account Opening'));
        options.add(new SelectOption('Registration', 'Registration'));
        options.add(new SelectOption('Web/Direct Connect', 'Web/Direct Connect'));
        options.add(new SelectOption('Digital Communication - Chat, Messaging, Chatbot ', 'Digital Communication - Chat, Messaging, Chatbot '));
        options.add(new SelectOption('Online Forms', 'Online Forms'));
        options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
       // options.add(new SelectOption('Admin Platform User Management and Security', 'Admin Platform User Management and Security'));
        //options.add(new SelectOption('Reporting', 'Reporting'));
        //options.add(new SelectOption('Create Your Own/SSO and API Integration', 'Create Your Own/SSO and API Integration'));
       // options.add(new SelectOption('Security', 'Security'));
        //options.add(new SelectOption('Other', 'Other'));
    } else if (selectedPostIdeaLineOfBusiness == 'Retail Banking') {
     //VALUES updates EBA_SF-1438
        options.add(new SelectOption('Alerts & Communication', 'Alerts & Communication'));
        options.add(new SelectOption('User Profile Settings', 'User Profile Settings'));     
        options.add(new SelectOption('Check/Deposit Imaging', 'Check/Deposit Imaging'));
        options.add(new SelectOption('Customer Support', 'Customer Support'));
        options.add(new SelectOption('General Retail Banking', 'General Retail Banking'));
        options.add(new SelectOption('Money Management', 'Money Management'));
        options.add(new SelectOption('Online Statements', 'Online Statements'));
        options.add(new SelectOption('Remote Deposit', 'Remote Deposit'));
        options.add(new SelectOption('Shared Access', 'Shared Access'));
        options.add(new SelectOption('Card Management', 'Card Management'));
        options.add(new SelectOption('Financial Wellness', 'Financial Wellness'));
        options.add(new SelectOption('Client Services Developed Solutions', 'Client Services Developed Solutions'));
    }           
    options.sort();
    return options;
  }
        
    
  /*
   *    @description:    action for posting new idea.
   *    @author:         Sharee Ingatan(sharee.ingatan@cloudsherpas.com)
   */
  public pageReference postNewIdea() {
    checkAllFieldsonTitle();
    Idea createnewIdea = new Idea();
    Community ideaComm = [SELECT id FROM Community WHERE Name = 'IdeaExchange' LIMIT 1];
    createnewIdea.CommunityId = ideaComm.id;
    createnewIdea.Status = 'Under Point Threshold';

    //attachment
    createnewIdea.AttachmentBody = newIdea.AttachmentBody;
    createnewIdea.AttachmentName = newIdea.AttachmentName;
    createnewIdea.AttachmentContentType = newIdea.AttachmentContentType;
    
    String errormsg = 'Select a ';
    if (ideaTitle == null || ideaTitle == '') {
      errormsg = errormsg + 'Title';
    }
            
    if (String.isBlank(newIdea.Body)) {
      if (errormsg.length() >= 10) {
        errormsg = errormsg + ' and Description';
      } else {
          errormsg = errormsg + 'Description';
      }
    }
            
    if (selectedPostIdeaLineOfBusiness == null || selectedPostIdeaLineOfBusiness == '') {
      if (errormsg.length() >= 10) {
        errormsg = errormsg + ' and Roadmap category';
      } else {
        errormsg = errormsg + 'Roadmap category';
      }
    }
    
    if (selectedPostIdeaDevice == null || selectedPostIdeaDevice == '') {
      if (selectedPostIdeaLineOfBusiness != 'Platform Solutions') {
        if (errormsg.length() >= 10) {
          errormsg = errormsg + ' and Device/Channel';
        } else {
          errormsg = errormsg + 'Device/Channel';
        }
      }
    }
            
    if (selectedPostIdeaCategory == null || selectedPostIdeaCategory == '') {
      if(errormsg.length() >= 10) {
        errormsg = errormsg + ' and Solution';
      } else {
        errormsg = errormsg + 'Solution';
      }
    }
            
    errormsg = errormsg + '.';
            
    if ((ideaTitle == null || ideaTitle == '') || (String.isBlank(newIdea.Body)) || (selectedPostIdeaLineOfBusiness == null || selectedPostIdeaLineOfBusiness == '') || (selectedPostIdeaCategory == null || selectedPostIdeaCategory == '') || ((selectedPostIdeaLineOfBusiness != 'Platform Solutions') && (selectedPostIdeaDevice == null || selectedPostIdeaDevice == ''))) {
      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, errormsg));
    } else {
      createnewIdea.Title = ideaTitle;
      createnewIdea.Body = newIdea.Body;
      createnewIdea.Di_Idea_Line_of_Business__c = selectedPostIdeaLineOfBusiness;
      createnewIdea.Di_Idea_Category__c = selectedPostIdeaCategory;
      if (selectedPostIdeaLineOfBusiness != 'Platform Solutions') {
        createnewIdea.Di_Idea_Channel__c = selectedPostIdeaDevice;
      }             
      try {
        insert createnewIdea;
        PageReference gotorecord = new PageReference('/apex/NCR_ViewIdeaPage?id=' + createnewIdea.id);
        gotorecord.setRedirect(true);
        return gotorecord;
      }
      catch (DmlException e) {
        if (!(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'))) {
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getMessage()));
        }
      }
                   
    }    
    return null;
  }
        
  
  /**
   * When user start typing idea title in title input box we show some existing similer ideas as hint.
   *
   */
  public void searchTitle() {
    similarIdeasList.clear();   
        
    List<List<sObject>> searchResultList = new List<List<sObject>>();
          
    if (ideaTitle.length() > 2) {
      searchResultList = [FIND : ideaTitle IN ALL FIELDS RETURNING idea(id,title, Di_Idea_Category__c,Di_Idea_Channel__c,Di_Idea_Line_of_Business__c, VoteTotal)];
      if (searchResultList.size() > 0) {
        similarIdeasList.addAll((List<Idea>) searchResultList[0]);
      }
    }
  }
    
    public void validateButton() {
        //ideaBodyValue = newIdea.Body;
        if(selectedPostIdeaLineOfBusiness == 'Platform Solutions') {
            if(selectedPostIdeaCategory != null) {
                //if(newIdea.Title==null && newIdea.Body==null) {
                    //disablePostButton = true;
                //} else {
                    disablePostButton = false;
                //}
            } else {
                //if(newIdea.Title==null && newIdea.Body==null) {
                    disablePostButton = true;
                //} else {
                  //  disablePostButton = false;
                //}
            }
       } else if(selectedPostIdeaLineOfBusiness != 'Platform Solutions') {
            if(selectedPostIdeaCategory != null && selectedPostIdeaDevice != null) {
                //if(newIdea.Title==null && newIdea.Body==null) {
                //    disablePostButton = true;
                //} else if(newIdea.Title!=null && newIdea.Body!=null) {
                    disablePostButton = false;
                //}
            } else if(selectedPostIdeaCategory != null || selectedPostIdeaDevice != null) {
                //if(newIdea.Title==null && newIdea.Body==null) {
                    disablePostButton = true;
                //} else if(newIdea.Title!=null && newIdea.Body!=null) {
                  //  disablePostButton = true;
                //}
            }
       }
    }    
    
    public void checkAllFieldsonTitle() {
        if(newIdea.Title != null) {
            if(newIdea.Body == null) {
                disablePostButton = true;
            } else {
                disablePostButton = false;
            }
            
            if(selectedPostIdeaLineOfBusiness != null) {
                if(selectedPostIdeaLineOfBusiness == 'Platform Solutions') {
                    if(selectedPostIdeaCategory != null) {
                        disablePostButton = false;
                    } else {
                        disablePostButton = true;
                    }
                } else if(selectedPostIdeaLineOfBusiness != 'Platform Solutions') {
                    if(selectedPostIdeaCategory != null && selectedPostIdeaDevice != null) {
                        disablePostButton = false;
                    } else if(selectedPostIdeaCategory != null || selectedPostIdeaDevice != null) {
                        disablePostButton = true;
                    }
                }
            } else {    //else if newIdea.Body == null
                disablePostButton = true;
            }
        } else {    //else if newIdea.Title == null
            disablePostButton = true;
        }
    }
    

    
    public void checkDescription() {
        if(newIdea.Body != null) {
            validateButton();
        } else {
            disablePostButton = true;
        }
    }

    /** END -- for PostIdeaPage2  **/
}