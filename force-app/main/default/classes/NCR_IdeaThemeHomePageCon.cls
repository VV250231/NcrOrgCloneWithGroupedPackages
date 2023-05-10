/**************************************
Author ...............: 
Date Created .........:
Last Modified By .....: Santosh Jha
Last Modified Date ...: 15 -FEb 2022

Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Santosh Jha                    EBA_SF-1701 -Technical Debt - Apex SOQL injection - Part 1
19-12-2022                 Monika                         EBA_SF-2491 JDK Locale impact - Upgrade API Part 5  
                                                   
***************************************/

public class NCR_IdeaThemeHomePageCon {
    public List<SelectOption> themeCategory {get;set;}
    public List<SelectOption> themeStatus   {get;set;}
    
    public String selectedCategory {get;set;}
    public String selectedStatus   {get;set;}
    
    private List<IdeaTheme> themes;
    
    public NCR_IdeaThemeHomePageCon() {
        // Creating theme category options
        themeCategory = new List<SelectOption>();
        themeCategory.add( new SelectOption('All','All Categories'));
        themeCategory.addAll(getPickListValues(Schema.getGlobalDescribe().get('IdeaTheme').newSObject(),'DI_Category__c'));
        
        // Creating theme status options
        themeStatus = new List<SelectOption>();
        themeStatus.addAll(getPickListValues(Schema.getGlobalDescribe().get('IdeaTheme').newSObject(),'Status'));
        
        // Making default selection
        selectedStatus = 'Accepting Ideas';
        selectedCategory = 'All';

    }
    
    
    public List<IdeaTheme> getThemes() {
        themes = new List<IdeaTheme>();
        String query = 'SELECT Id, Title, Status, DI_Category__c,Description, (SELECT Id, Title, Body FROM Ideas ORDER BY CreatedDate LIMIT 2) FROM IdeaTheme WHERE Status =:'+'selectedStatus';
        if (selectedCategory != 'All')
            query += ' AND DI_Category__c =: selectedCategory';
        query +=' ORDER BY CreatedDate DESC';
        query += ' LIMIT 1000';
        themes = (List<IdeaTheme>) Database.query(String.escapeSingleQuotes(query));
        return themes;
    }
    
    // changing the category
    public PageReference changeCategory() {
        String catVal = ApexPages.currentPage().getParameters().get('category').escapeHTML4();
        selectedCategory = catVal;
        PageReference pr = Page.NCR_IdeaThemeHomePage;
        pr.setRedirect(false);
        return pr;
    }
    
    /*
     * Find out either user already has subscribtion for the category or not.
     * 
     */
    public DI_IdeaSubscription__c getSubscription()  {
        List<DI_IdeaSubscription__c> subscriptions = new List<DI_IdeaSubscription__c>();
        subscriptions = [SELECT Id, DI_LineOfBusiness__c, DI_SubscriptionCategory__c, DI_UserName__c 
                         FROM DI_IdeaSubscription__c 
                         WHERE DI_SubscriptionCategory__c =: selectedCategory AND DI_LineOfBusiness__c = 'Theme Idea' 
                         AND DI_UserName__c =: userinfo.getuserid() LIMIT 1];
        if (subscriptions.size() > 0) {
           return subscriptions[0]; 
        }
        return null;
    }
    
    
    /*
     * Subscribe user for the particular category
     */
    public PageReference subscribe() {
        List<DI_IdeaSubscription__c> subscriptions = new List<DI_IdeaSubscription__c>();
        subscriptions = [SELECT Id, DI_LineOfBusiness__c, DI_SubscriptionCategory__c, DI_UserName__c 
                         FROM DI_IdeaSubscription__c 
                         WHERE DI_SubscriptionCategory__c =: selectedCategory AND DI_LineOfBusiness__c = 'Theme Idea' 
                         AND DI_UserName__c =: userinfo.getuserid() ];
        if (! (subscriptions.size() > 0)) {
            DI_IdeaSubscription__c newSubscription = new DI_IdeaSubscription__c();
            newSubscription.DI_LineOfBusiness__c = 'Theme Idea';
            newSubscription.DI_SubscriptionCategory__c = selectedCategory;
            newSubscription.DI_UserName__c = userinfo.getuserid();
            try {
                insert newSubscription;
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR,'Something went wrong. Please contact Admin'));
                return null;
            }
        }
        
        PageReference pr = Page.NCR_IdeaThemeHomePage;
        pr.setRedirect(false);
        return pr;
    }
    
    /*
     * Unsubscribe user for particualr category
     */
    public PageReference unSubscribe() {
        String subscriptionId = ApexPages.currentPage().getParameters().get('subscriptionId');
        List<DI_IdeaSubscription__c> subscriptions = [SELECT Id FROM DI_IdeaSubscription__c WHERE Id =: subscriptionId];
        if (subscriptions.size() > 0) {
            delete subscriptions;
        }
        PageReference pr = Page.NCR_IdeaThemeHomePage;
        pr.setRedirect(false);
        return pr;
    }
    
    
    public List<ThemeWithIdeaWrapper> themeWithIdeaWrappers {
        get {
            themeWithIdeaWrappers = new List<ThemeWithIdeaWrapper>();
            for (IdeaTheme theme: getThemes()) {
                ThemeWrapper themeWrapperObj = new ThemeWrapper(theme);
                ThemeWithIdeaWrapper obj = new ThemeWithIdeaWrapper(themeWrapperObj);
                for (Idea ideaRec : theme.Ideas) {
                    obj.ideas.add(new IdeaWrapper(ideaRec));
                }
                themeWithIdeaWrappers.add(obj);
            }
            return themeWithIdeaWrappers;
        }set;
    }
    
    /*
     * Method returns the pick list values of a pick list.
     */
  
    public List<SelectOption> getPickListValues(Sobject objectName, String fieldName) {
        List<selectOption> options = new List<selectOption>();
        Schema.SObjectType sobjectType = objectName.getSObjectType();
        Schema.DescribeSObjectResult sobjectDescribe = SObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sobjectDescribe.fields.getMap();
        List<Schema.PicklistEntry> pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pickListValues) { 
            options.add(new selectOption(a.getValue(), a.getLabel()));
        }
        return options;
    }
    

    
    /*
     * Returns subscription record if it already exist else return net instace.
     * */
    private DI_Idea_Exchange_Daily_Digest__c newThemeSubscription;
    public DI_Idea_Exchange_Daily_Digest__c getNewThemeSubscription() {
        List<DI_Idea_Exchange_Daily_Digest__c> newThemeSubsciptions = [SELECT Id, Name, DI_Subscribe_for_daily_digest__c, 
                                                                       DI_New_Theme_Alert__c, DI_User__c FROM DI_Idea_Exchange_Daily_Digest__c
                                                                       WHERE DI_User__c =: userinfo.getUserId()
                                                                      ];
        //If record found return the record
        if (newThemeSubsciptions.size() > 0) {
            newThemeSubscription = newThemeSubsciptions[0];      
        } else {
            newThemeSubscription = new DI_Idea_Exchange_Daily_Digest__c();
        }
        
        return newThemeSubscription;    
    }
    
    /*
     * Subscribing and Unsubscibe user for new theme alert.
     * */
    public PageReference processSubscription() {
        if (newThemeSubscription.Id == null) {
            newThemeSubscription.DI_User__c = userinfo.getUserId();
            insert newThemeSubscription;
        } else {
            update newThemeSubscription;
        }
        PageReference pr = Page.NCR_IdeaThemeHomePage;
        pr.setRedirect(false);
        return pr;
    }
    
    
    public class ThemeWithIdeaWrapper {
        public ThemeWrapper theme {get;set;}
        public List<IdeaWrapper> ideas {get;set;}
        public ThemeWithIdeaWrapper(ThemeWrapper theme) {
            this.theme = theme;
            ideas = new List<IdeaWrapper>();
        }
    }
    
    public class ThemeWrapper {
        public String themeId {get;set;}
        public String themeTitle {get;set;}
        public String themeCategory {get;set;}
        public String themeStatus {get;set;}
        public String themeDescription {get;set;}
        
        public themeWrapper(IdeaTheme theme){
            this.themeId = theme.Id;
            this.themeTitle = theme.Title;
            this.themeCategory = theme.DI_Category__c;
            this.themeStatus = theme.Status;
            this.themeDescription = theme.Description != null ? theme.Description.stripHtmlTags().abbreviate(150) : theme.Description;
        }
    }
    
    public class IdeaWrapper {
        public String ideaId {get;set;}
        public String ideaTitle {get;set;}
        public String ideaBody {get;set;}
        public ideaWrapper(Idea idea) {
            this.ideaId = idea.Id;
            this.ideaTitle = idea.Title;
            this.ideaBody = idea.Body != null ? idea.Body.stripHtmlTags().abbreviate(150) : idea.Body;
        }
    }
}