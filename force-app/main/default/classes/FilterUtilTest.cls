@isTest
private class FilterUtilTest{

    static testMethod void myTest() {
        List<String> textOprtrList = new List<String>{'equals','not equal to','less than','greater than','less or equal','greater or equal','contains','does not contain' ,'starts with'};
       
        
        OppListViewController.FieldFilterWrapper OppNameFilter = new  OppListViewController.FieldFilterWrapper(
                                                                'Name', 'Opportunity Name', 'STRING', 'equals', 'Test1234', new List<String>(), 'edit');
        
        OppListViewController.FieldFilterWrapper StageNameFilter = new  OppListViewController.FieldFilterWrapper(
                                                                'StageName', 'Selling Stage', 'PICKLIST', 'equals', 'Test1234', new List<String>{'Analyzing'}, 'edit');                                                        
          system.assert(StageNameFilter!=null);                                                      
        for (String str : textOprtrList) {
            OppListViewController.FieldFilterWrapper fltr = OppNameFilter.clone();
            fltr.selectedOPR = str; 
            OppListViewController.evalFilter(fltr);         
        }
        
         for (String str : textOprtrList) {
            OppListViewController.FieldFilterWrapper fltr = StageNameFilter.clone();
            fltr.selectedOPR = str; 
            OppListViewController.evalFilter(fltr);         
        }
        
                                                       
    }
}