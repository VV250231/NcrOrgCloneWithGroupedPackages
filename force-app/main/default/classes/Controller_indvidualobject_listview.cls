/*
* Test Class Name : Controller_indvidualobject_listview_Test
*/

public class Controller_indvidualobject_listview {
    
    
    @AuraEnabled
    public static List<Individual> getalldetails(String searchkey)
    {  
        return [Select Id, Name,Owner.Name,BirthDate,HasOptedOutProcessing,ShouldForget,SendIndividualData from Individual] ;
        
    }
}