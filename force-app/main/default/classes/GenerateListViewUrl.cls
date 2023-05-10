public class GenerateListViewUrl {
   public  Map<String,String> PrefixList = PrefixList();
     Public Map<String,String> PrefixList(){
           Map<String,String> PrefixList = new Map<String,String>{};
           Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
           for(String sObj : gd.keySet()){
               Schema.DescribeSObjectResult r =  gd.get(sObj).getDescribe();
               PrefixList.put(r.getName(), r.getKeyPrefix());
           }
           return PrefixList;
       } 
       Public String ListViewURL(String ObjectName,String ListViewLabel){
           String ListViewURL;
           String ListViewId;
           String q = 'SELECT Name FROM '+ ObjectName +' LIMIT 1';
           ApexPages.StandardSetController ACC = new ApexPages.StandardSetController(Database.getQueryLocator(q));
           List<SelectOption> ListViews = ACC.getListViewOptions();
           for(SelectOption w : ListViews ){
               if(w.getLabel()==ListViewLabel){
                   ListViewId = w.getValue().left(15);
                   ListViewURL='/'+PrefixList.get(ObjectName)+'?fcf='+ListViewId;
               }
           }
           return ListViewURL;
       }
      
}