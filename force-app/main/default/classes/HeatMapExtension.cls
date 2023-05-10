public class HeatMapExtension {
    public string HeatMapId {get;set;}
    
    /*Public HeatMapExtension(){
        
    } commented empty block */
    Public HeatMapExtension(ApexPages.StandardController controller){
         HeatMapId=[Select id from Attachment where ParentId =:ApexPages.currentPage().getParameters().get('id') AND name like '%HeatMap%' limit 1][0].id;
    }   
}