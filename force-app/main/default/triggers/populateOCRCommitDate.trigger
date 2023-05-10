/****************************************************************************************************************
*   TriggerName :   populateOCRCommitDate
*   Description :   
*   Author      :   
*   Version     :   Initial
# Modification History.: 
Story No#         Date            DevName                Description
EBA_SF-1788     02 Feb 2022     Kapil Bhati         Removed hardcoded account Ids

****************************************************************************************************************/
trigger populateOCRCommitDate on OCR_Commit__c (before insert,before update) {
    Set<String> k = new Set<String>();
    for(OCR_Commit__c c:trigger.new){
    k.add(c.unique_key__c);
    }
    
    List<Ocr_calender__c> ocr = [Select Date__c,unique_key__c from Ocr_calender__c where unique_key__c IN :k];
        Map<String, Date> ocrMap = new Map<String, Date>();

    for(Ocr_calender__c o:ocr){
        ocrMap.put(o.unique_key__c,o.date__c);
    }
    for(OCR_Commit__c c:trigger.new){
        c.date__c = ocrMap.get(c.unique_key__c);
        if(c.Industry__c == 'GS:FS')
        //c.Account_Test__c = '0017000001W8eir';
        c.Account_Test__c =NSCCommonInfoUtil.getIdOf('IRON_FOR_OCR_COMMIT_DON_T_DELETE');   // EBA_SF-1788  Removed hardcoded account Ids- Modified by Kapil Bhati 
        if(c.Industry__c == 'GS:Retail')
      //  c.Account_Test__c = '0017000001QQu1C';
        c.Account_Test__c =NSCCommonInfoUtil.getIdOf('IRON_OCR_COMMIT_RETAIL_DON_T_DELETE'); // EBA_SF-1788  Removed hardcoded account Ids- Modified by Kapil Bhati 
        if(c.Industry__c == 'GS:Hosp')
       // c.Account_Test__c = '0017000000bEhaK';
        c.Account_Test__c =NSCCommonInfoUtil.getIdOf('Empost_Courier'); // EBA_SF-1788  Removed hardcoded account Ids- Modified by Kapil Bhati 
        if(c.Industry__c == 'TNT:Sales')
       // c.Account_Test__c = '0010g00001XiFy7';
        c.Account_Test__c =NSCCommonInfoUtil.getIdOf('VODAFONE_LTD_IRAQ'); // EBA_SF-1788  Removed hardcoded account Ids- Modified by Kapil Bhati 
    }
}