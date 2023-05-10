public class MarketoAcquisitionDateHelper {
    public static String MarketoUserIDLabel = System.Label.Marketo_Us;
    public static id MarketoUserId = MarketoUserIDLabel;
    public static void populateDate(List<Case> caseList){
        List<Case> caseUpdatedList = new List<Case>();        
        for(Case coseObj : caseList){
            Case caseObjList = new Case();
            if(coseObj.mkto71_Acquisition_Date__c ==null){
                caseObjList.id = coseObj.id;
                caseObjList.mkto71_Acquisition_Date__c = coseObj.Createddate;
                caseObjList.Origin ='Forms';
                if(coseObj.CreatedById == MarketoUserId){
                    caseUpdatedList.add(caseObjList);
                }
            }
        }
        if(!caseUpdatedList.isEmpty())
            update caseUpdatedList;
    }
}