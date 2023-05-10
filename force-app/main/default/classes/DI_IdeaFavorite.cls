/*
##################################################################################################
# Class Name............................:DI_IdeaFavorite                                                                                                                                  
# Last Modified by......:  Monika
# Last Modified Date..:    19-12-2022
EBA_SF-2491 JDK Locale impact - Upgrade API Part 5                               
################################################################################################
*/
public class DI_IdeaFavorite {
String IdeaThemeId;

public DI_IdeaFavorite(){
   IdeaThemeId = ApexPages.CurrentPage().getParameters().get('IdeaThemeId');
   
}
public void createIdeaFvrt(){
   Di_Idea_Favorites__c obj=new Di_Idea_Favorites__c();
    obj.DI_Idea_Theme__c=((IdeaThemeId!=null)?IdeaThemeId.escapeHTML4():null);
    obj.User__c= UserInfo.getUserId();
    Insert obj;
  }
  

}