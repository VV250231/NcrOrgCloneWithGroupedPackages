public class IdeaHistoryExtension {
    private final Idea iddea;
    public String ideaId {get;set;}
    public List<Di_Idea_History__c> ideaHistoryList {get;set;}
    public String str {get;set;}
    public List<wrapIdeaHistory> wrapIdeaHistoryList {get; set;}
    List<wrapIdeaHistory> lstw = new List<wrapIdeaHistory>();
    public String title{get;set;}
    
    public IdeaHistoryExtension(ApexPages.StandardController stdController) {
        this.iddea = (Idea)stdController.getRecord();
        this.ideaId=System.currentPageReference().getParameters().get('id');
        str= URL.getSalesforceBaseUrl().toExternalForm();
    }
    
    public Void   getIdeaHistoryList() {    
        ideaHistoryList = [ select Di_Idea_Id__r.Title, Di_Idea_OLD_Status__c, Di_Idea_NEW_Status__c, Di_Idea_NEW_Due_Date__c,Di_Idea_OLD_Product_Manager_Name__c,Di_Idea_NEW_Product_Manager_Name__c,Di_Idea_OLD_Due_Date__c,LastModifiedDate,LastModifiedBy.Name  from Di_Idea_History__c where Di_Idea_Id__c =: ideaId and (Di_Idea_OLD_Status__c!=null or Di_Idea_OLD_Product_Manager_Name__c!=null or Di_Idea_OLD_Due_Date__c!=null) order by  Created_Date__c desc ];
        for (Di_Idea_History__c ih:ideaHistoryList){
            if(null==title){
                title = ih.Di_Idea_Id__r.Title  ;
            }
            
            if(ih.Di_Idea_OLD_Product_Manager_Name__c!=null){
                lstw.add(new wrapIdeaHistory('Product Manager',ih.Di_Idea_NEW_Product_Manager_Name__c,ih.Di_Idea_OLD_Product_Manager_Name__c,ih.LastModifiedBy.Name,String.ValueofGmt(ih.LastModifiedDate)));
                
            }
            if(ih.Di_Idea_OLD_Status__c!=null){
                lstw.add(new wrapIdeaHistory('Idea Status',ih.Di_Idea_NEW_Status__c,ih.Di_Idea_OLD_Status__c,ih.LastModifiedBy.Name,String.ValueofGmt(ih.LastModifiedDate)));
                
            }
            if(ih.Di_Idea_NEW_Due_Date__c!=null){
                lstw.add(new wrapIdeaHistory('Due Date',String.ValueofGmt(ih.Di_Idea_NEW_Due_Date__c),String.ValueofGmt(ih.Di_Idea_OLD_Due_Date__c),ih.LastModifiedBy.Name,String.ValueofGmt(ih.LastModifiedDate)));
                
            }
            
        }
        wrapIdeaHistoryList=lstw;
        
        
        
    }
    
    public PageReference back(){
        PageReference pr = new PageReference('https://ncr.my.salesforce.com/ideas/viewIdea.apexp?id='+ideaId); // google is blocked here
        pr.setRedirect(false);
        return pr;
        
    }
    public class wrapIdeaHistory {
        public String field {get; set;}
        public String newValue {get; set;}
        public String oldValue {get; set;}
        public String modifieldBy {get; set;}
        public String onDate {get; set;}
        
        
        public wrapIdeaHistory(String field, String newValue, String oldValue, String modifieldBy, String onDate ) {
            this.field=field;
            this.newValue=newValue;
            this.oldValue=oldValue;
            this.modifieldBy=modifieldBy;
            this.onDate=onDate;
            
        }
        
    }
    
    
}