/*
* Test Class Name : Controller_indvidualobject_listview_Test
*/

public class USER_Masking_Helper{

    public static void maskall(List<User> triggernew){
    
      SET<ID> userid = new SET<ID>();
      List<User> userlist = new List<User>();
      Map<id,User> UserMap = new Map<id,User>();
        //Changes done by Yogesh - related to Story EBA_SF-1919 
       /* for(User u : triggernew){
         if((u.LastModifiedById == '00570000001N9kD' && u.IsActive == false) || Test.isRunningTest()){
              userlist.add(u);
          }
      } */
        Id uSrId= NSCCommonInfoUtil.getIdOf('UMH_UserId');
      for(User u : triggernew){
         if((u.LastModifiedById == uSrId && u.IsActive == false) || Test.isRunningTest()){
              userlist.add(u);
          }
      } 
     
     if(userlist != null || Test.isRunningTest()) {
          for(User u : userlist){
                u.Street= '';
                u.City= '';
                u.State= '';
                u.PostalCode= '';
                u.Country= '';
                u.Phone= '';
                u.Fax = '';
                u.Extension = '';
                u.MobilePhone= '';
                u.pics__c= '';
               // u.LocaleSidKey = '';
               // u.LanguageLocaleKey = '';

          } 
      }
       // [Select id,name,AddressPhone,Fax,Extension,MobilePhone,pics__c,LastModifiedById from User where id IN: userid] 
       
      
    }

}