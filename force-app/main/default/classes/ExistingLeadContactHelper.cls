public class ExistingLeadContactHelper {
    public static Boolean isfirst = false;
    public static Boolean isfirstMarketo = true;
    public static String MarketoUserIDLabel = System.Label.Marketo_Us;
    public static id marketoUserID = MarketoUserIDLabel ;
    public static void leadAndContactWithEmail(List<Case> caseList){
        List<Case> caseUpdateList = new List<Case>();
        Map<String,Lead> leadMap = new Map<String, Lead>();
        Map<String,Contact> contactMap = new Map<String, Contact>();
        set<String> emailIdSet = new set<String>();
        Id CaseRecordTypeId = Schema.getGlobalDescribe().get(CaseStaticVariableClass.ObjectName).getDescribe().getRecordTypeInfosByName().get(CaseStaticVariableClass.MarketingRecordType).getRecordTypeId();
        for(Case caseObj : caseList){
            if(!String.isBlank(caseObj.Chat_User_Email__c)){
                emailIdSet.add(caseObj.Chat_User_Email__c);
            }
        }
        if(!emailIdSet.isEmpty()){
            for(Lead leadObj : [SELECT Id, Name, Email FROM Lead WHERE Email In : emailIdSet]){
                leadMap.put(leadObj.Email, leadObj);
            }
            for(Contact conObj : [SELECT Id, Name, Email FROM Contact WHERE Email In : emailIdSet]){
                contactMap.put(conObj.Email, conObj);
            }
            for(Case caseObj : caseList){
                Case CaseRecordObj = new Case();
                if(caseObj.RecordTypeId == CaseRecordTypeId){
                    CaseRecordObj.id = caseObj.id;
                    if(leadMap.containsKey(caseObj.Chat_User_Email__c)){
                        CaseRecordObj.LeadId__c = leadMap.get(caseObj.Chat_User_Email__c).Id;
                    }
                    if(contactMap.containsKey(caseObj.Chat_User_Email__c)){
                        CaseRecordObj.ContactId = contactMap.get(caseObj.Chat_User_Email__c).Id;
                    }
                    if(caseObj.CreatedById == marketoUserID){
                        CaseRecordObj.Eloqua_Form_Submit_Time__c = System.now();
                    //    CaseRecordObj.Origin = CaseStaticVariableClass.OriginValue;
                    }
                    caseUpdateList.add(CaseRecordObj);
                }
            }
            if(!caseUpdateList.isEmpty())
                update caseUpdateList;
        }
    }
}