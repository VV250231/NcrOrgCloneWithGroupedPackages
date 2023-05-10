public class UserActivityLogger {
    
    @future   
    public static void logUserActivityWithFuture(String tabName) {
        logUserActivityWithoutFuture(tabName);
    }
    
    
    public static void logUserActivityWithoutFuture(String tabName) {
        if(String.isNotBlank(tabName)) {
            String tabAccssUniqueId = tabName + Userinfo.getUserId() + String.valueOf(Datetime.now().format('yyMMdd'));
            
            List<Tab_Access__c > tabAccList = [Select UniqueId__c, Daily_View_Count__c  from Tab_Access__c where UniqueId__c = :tabAccssUniqueId LIMIT 1];
            
            Tab_Access__c ta;
            if (tabAccList != null && tabAccList.size() > 0) {
                ta =  tabAccList.get(0);
                ta.Daily_View_Count__c  = ta.Daily_View_Count__c + 1;    
            } else {
                ta = new Tab_Access__c(Name = tabName, PageName__c = tabName, Metrics_Date__c = Date.today(), User__c= Userinfo.getUserId(), UniqueId__c= tabAccssUniqueId, Daily_View_Count__c  = 1);        
            }
            upsert ta UniqueId__c; 
           
            }
        }
    
    @auraEnabled
    public static void logUserActivityLtngPage(String tabName) {
        logUserActivityWithoutFuture(tabName);      
    }
    
    //monika eba_sf-975
    @AuraEnabled
    public static void logSesmicActivity(string sourceObject){
        string tabname  = 'Seismic';
        if(String.isNotBlank(sourceObject)) {
            String tabAccssUniqueId = tabName + sourceObject + Userinfo.getUserId() + String.valueOf(Datetime.now().format('yyMMdd'));
            
            List<Tab_Access__c > tabAccList = [Select UniqueId__c, Daily_View_Count__c  from Tab_Access__c where UniqueId__c = :tabAccssUniqueId LIMIT 1];
            
            Tab_Access__c ta;
            if (tabAccList != null && tabAccList.size() > 0) {
                ta =  tabAccList.get(0);
                ta.Daily_View_Count__c  = ta.Daily_View_Count__c + 1;    
            } else {
                ta = new Tab_Access__c(Name = tabName, Source_Object__c=sourceObject ,PageName__c = tabName, Metrics_Date__c = Date.today(), User__c= Userinfo.getUserId(), UniqueId__c= tabAccssUniqueId, Daily_View_Count__c  = 1);        
            }
            upsert ta UniqueId__c; 
           
            }
             
    }
    
    public static void logUserActivity(string tabName) {
        if(System.isFuture())
        { 
            logUserActivityWithoutFuture(tabName);
            
        } else {
            logUserActivityWithFuture(tabName);    
        }
    }
    
    //Added by Sushant -EBA-SF-1500 
    public static void updateCount() {
        String tabname  = 'MY Sales Compensation';
        String thisPath =  Url.getCurrentRequestUrl().getPath();
        Tab_Access__c[] views = [SELECT Id,Name,URL__c,User__c, Count__c FROM Tab_Access__c WHERE User__c=:UserInfo.getUserId() and Name=:tabname ];
        Tab_Access__c thisView = views.isEmpty() ? new Tab_Access__c(Name = tabName,User__c=UserInfo.getUserId(),Url__c=thisPath, Count__c=0) : views[0];
        thisView.Count__c++;
        upsert thisView;
    }
}