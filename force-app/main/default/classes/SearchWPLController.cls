public class SearchWPLController {



    public List<contactWrapper> selectedList ;
    public PageReference grantAccessOfIncentives() {
        List<Incentive_WPL_mapping__c> imList = new List<Incentive_WPL_mapping__c>();
        System.debug('conwrList'+ conwrList);
        If(conwrList!= null && conwrList.size()> 0){
            for( contactWrapper cw : conwrList){
                If(cw.checkbox){
                    Incentive_WPL_mapping__c im = new Incentive_WPL_mapping__c();
                    im.name = cw.con.web_portal_login__c;
                    imList.add(im);
                }
            }
        }
        If(imlist != null && imlist.size() >0 )
            insert imlist;
        return null;
        
    }

    public List<contactWrapper> conwrList;
    public boolean NoRecordFlag { get; set; }
    
    public PageReference searchContact() {
        return null;
    }

    public boolean tableFlag{get;set;}
    
    public String searchString{get;set;}

 /*   public void setContactWrapper(List<contactWrapper> conwrList){
        this.conwrList = conwrList;
    } */
    public List<contactWrapper> getcontactWrapper(){ 
          conwrList = new List<contactWrapper>();
        If(searchString  != null) {
        List<contact> contactList = [Select id , name ,Web_Portal_Login__c from Contact Where  Web_Portal_Login__c =:searchString Limit 10];
           
            Try{
                If(contactList != null){
                   For(Contact c : contactList ){
                       
                   Incentive_WPL_mapping__c inceW = Incentive_WPL_mapping__c.getInstance(c.Web_Portal_Login__c );
                       If(inceW  != null) {
                          continue;
                          }
                        Else{ 
                            
                            contactWrapper cw = new contactWrapper();
                            cw.con = c;
                            cw.checkbox =false;
                            conwrList.add(cw);
                            
                            
                        }  
                   } 
                   
                
                }
             }   
            catch(exception e){
                System.debug('Exception Caught'+e.getMessage());
            }  
            
         } 
        return conwrList;
    }
   
   public class contactWrapper{
      public contact con{get;set;}
      public Boolean checkbox{get;set;}
   }

}