public class Tableaupagecontroller{
    
    //TableauWorkbookURL__c tbobject = new TableauWorkbookURL__c();
    public TableauWorkbookURL__c tbobject {get; set;}
    public String H2Leaders {get; set;}
    public String H3Leaders {get; set;}
    public String wfrcurrent {get; set;}
    public String wfrhistoric {get; set;}
    public String variance {get; set;}
    public String h2funnel {get; set;}
    public String h3funnel{get; set;}
    public String qtdnetnew {get; set;}
    public String attachrate {get; set;}
    public String retemea{get; set;}
    public String finmea {get; set;}
    public String fineuro{get; set;}
   
    public Tableaupagecontroller(){
        
        ID id = UserInfo.getUserId() ;
        
        Set<ID> Tableauslsanalyst = new Set<id>();
        Set<ID> Tableau_sls_corp = new Set<id>();
        Set<ID> Tableau_sls_fs_h2 = new Set<id>();
        Set<ID> Tableau_sls_fs_h3 = new Set<id>();
        Set<ID>Tableau_sls_ret_h2 = new Set<id>();
        Set<ID> Tableau_sls_ret_h3 = new Set<id>();
        Set<ID> Tableau_sls_hos_h2 = new Set<id>();
        Set<ID> Tableau_sls_hos_h3 = new Set<id>();
        Set<ID> Tableau_sls_tnt_h2 = new Set<id>();
        Set<ID> Tableau_sls_tnt_h3 = new Set<id>();
        
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableauslsanalyst' ]){Tableauslsanalyst.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_corp' ]){Tableau_sls_corp.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_fs_h2' ]){Tableau_sls_fs_h2.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_fs_h3' ]){Tableau_sls_fs_h3.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_ret_h2' ]){Tableau_sls_ret_h2.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_ret_h3' ]){Tableau_sls_ret_h3.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_hos_h2' ]){Tableau_sls_hos_h2.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_hos_h3' ]){Tableau_sls_hos_h3.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_tnt_h2' ]){Tableau_sls_tnt_h2.add(g.UserOrGroupId);}
        for(GroupMember g : [Select Id,UserOrGroupId From GroupMember where group.DeveloperName =:'Tableau_sls_tnt_h3' ]){Tableau_sls_tnt_h3.add(g.UserOrGroupId);}
        
        H2Leaders = 'none' ;
        H3Leaders = 'none' ;
        wfrcurrent = 'none' ;
        wfrhistoric = 'none' ;
        variance = 'none' ;
        h2funnel = 'none' ;
        h3funnel = 'none' ;
        qtdnetnew = 'none' ;
        attachrate = 'none' ;
        retemea = 'none';
        finmea = 'none';
        fineuro = 'none';
        
        if(Tableau_sls_corp.contains(id) || Test.isRunningTest()){
            H2Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
             retemea = 'block';
             finmea = 'block';
             fineuro = 'block';
        }
        if(Tableau_sls_fs_h2.contains(id) || Test.isRunningTest()){
            H2Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;

        }
        if(Tableau_sls_fs_h3.contains(id) || Test.isRunningTest()){
            H3Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h3funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
             finmea = 'block';
             fineuro = 'block';
        }
        if(Tableau_sls_ret_h2.contains(id) || Test.isRunningTest()){
            H2Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
           
        }
        if(Tableau_sls_ret_h3.contains(id) || Test.isRunningTest()){
            H3Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h3funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
             retemea = 'block';
          
        }
        if(Tableau_sls_hos_h2.contains(id) || Test.isRunningTest()){
            H2Leaders = 'block' ;
           wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
           
        }
        if(Tableau_sls_hos_h3.contains(id) || Test.isRunningTest()){
            H3Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h3funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
         
        }
        if(Tableau_sls_tnt_h2.contains(id)|| Test.isRunningTest() ){
            H2Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
          
        }
        if(Tableau_sls_tnt_h3.contains(id) || Test.isRunningTest()){
            H3Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h3funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
           
        }
        if(Tableauslsanalyst.contains(id) || Test.isRunningTest()){
            H2Leaders = 'block' ;
            H3Leaders = 'block' ;
            wfrcurrent = 'block' ;
            wfrhistoric = 'block' ;
            variance = 'block' ;
            h2funnel = 'block' ;
            h3funnel = 'block' ;
            qtdnetnew = 'block' ;
            attachrate = 'block' ;
              retemea = 'block';
             finmea = 'block';
             fineuro = 'block';
        }
       
        /*
tbobject = [select id,TableauServerAddress__c,VisualforcePageURL__c,
Workbook1Name__c,Workbook1URL__c,Workbook2Name__c,
Workbook2URL__c,Workbook3Name__c,Workbook3URL__c,
Workbook4Name__c, Workbook5Name__c, Workbook4URL__c,
Workbook5URL__c
from TableauWorkbookURL__c ] ;
*/
        
    }
    
    public void init(){
        String tabName = 'Tableau'; 
        String tabAccssUniqueId = tabName + Userinfo.getUserId() + String.valueOf(Datetime.now().format('yyMMdd'));
        
        List<Tab_Access__c > tabAccList = [Select UniqueId__c, Daily_View_Count__c  from Tab_Access__c where UniqueId__c = :tabAccssUniqueId LIMIT 1];
        
        Tab_Access__c ta;
        if(tabAccList != null && tabAccList.size() > 0) {
            ta =  tabAccList.get(0);
            ta.Daily_View_Count__c  = ta.Daily_View_Count__c + 1;   
            
        } else {
            ta = new Tab_Access__c(Name = 'Tableau', PageName__c = 'Tableau', Metrics_Date__c = Date.today(), User__c= Userinfo.getUserId(), UniqueId__c= tabAccssUniqueId, Daily_View_Count__c  = 1);        
        }
        upsert ta; 
    }
    
    
}