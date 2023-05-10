public class CPQValidMSQuoteForProposal {
    
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String LEGAL_DOC_STATUS_COMPLETED = 'Completed';
    private static final String QUOTE_TYPE_AMENDEMENT = 'Amendment';
    private static final Integer traverseToRootLimit = 1;

	@InvocableMethod(label= 'Get Proposal Quote')
    public static List<Integer> getQulifiedQuotesForProposal(List<String> qId) {
 		String quoteID = qId.get(0);
        List<SBQQ__Quote__c> qualifiedQuotes = new List<SBQQ__Quote__c>();
        List<Integer> returnObj = new List<Integer>();
        Set<Id> parentQuoteIds = new Set<Id>();

        // start
        SBQQ__Quote__c quoteRec = getQuoteDetailById(quoteId);
        
        Boolean msChild = (quoteRec.qtc_Multi_Site__c && quoteRec.qtc_Multi_Site_Relationship__c == 'Child');
        Boolean msOrigenalParent = (quoteRec.qtc_Multi_Site__c && quoteRec.qtc_Multi_Site_Relationship__c == 'Parent' && quoteRec.SBQQ__Type__c != QUOTE_TYPE_AMENDEMENT);
        Boolean msAmendedParent = (quoteRec.qtc_Multi_Site__c && quoteRec.qtc_Multi_Site_Relationship__c == 'Parent' && quoteRec.SBQQ__Type__c == QUOTE_TYPE_AMENDEMENT);
        
        // If Quote is child simply validate and return the result.
        if (msChild ==true && isQualifyForPF(quoteRec)) {
            
            qualifiedQuotes.add(quoteRec);
  
        } else if (msOrigenalParent == true) {
        // If Quote is parent and new quote. validate and return the result with child quotes.
            if (isQualifyForPF(quoteRec)) {
                qualifiedQuotes.add(quoteRec);
            }
            parentQuoteIds.add(quoteRec.Id);
            for (SBQQ__Quote__c q: getQualifiedChildQuotesForPF(parentQuoteIds)) {
                qualifiedQuotes.add(q);
            }
        // If quote is Amendment traverse to origenal quotes to find child quotes. Parent quote will not be
        // qualified.
        } else if (msAmendedParent) {

            parentQuoteIds.add(quoteRec.Id);
            // get Origneal Quote Ids
            for(SBQQ__Quote__c q : getOrginalQuoteList(quoteRec)) {
                parentQuoteIds.add(q.Id);
            }

            for (SBQQ__Quote__c q: getQualifiedChildQuotesForPF(parentQuoteIds)) {
                qualifiedQuotes.add(q);
            }
        }    
        returnObj.add(qualifiedQuotes.size()); 
        return returnObj;
    }

    

    public static List<SBQQ__Quote__c> getOrginalQuoteList(SBQQ__Quote__c quoteRec) {
        List<SBQQ__Quote__c> quoteLst = new List<SBQQ__Quote__c>();
        Integer level = 1;
        Boolean pointingToRootQuote = String.isBlank(quoteRec.qtc_Original_Quote_Number__c) 
                    || quoteRec.SBQQ__Type__c != QUOTE_TYPE_AMENDEMENT;

        while (!String.isBlank(quoteRec.qtc_Original_Quote_Number__c)
                && level <= traverseToRootLimit && !pointingToRootQuote) 
        {
            quoteRec = getQuoteDetailByName(quoteRec.qtc_Original_Quote_Number__c);
            if (quoteRec != null) {
                quoteLst.add(quoteRec);
                pointingToRootQuote = String.isBlank(quoteRec.qtc_Original_Quote_Number__c) 
                        || quoteRec.SBQQ__Type__c != QUOTE_TYPE_AMENDEMENT;
                
            } 
            level ++;
        }

        return quoteLst;
    }

    public static SBQQ__Quote__c getQuoteDetailById(String quoteId) {
        List<SBQQ__Quote__c> quoteLst = 
                [ SELECT Id,Name, qtc_Multi_Site__c,qtc_Multi_Site_Parent_Quote__c, qtc_Multi_Site_Relationship__c,
                         qtc_Original_Quote_Number__c, SBQQ__Status__c,qtc_Multi_Site_Type__c, 
                         qtc_Legal_Document_Status__c,SBQQ__Primary__c,qtc_Cancelled__c,
                         SBQQ__Type__c
                FROM SBQQ__Quote__c
                WHERE Id =: quoteId
                LIMIT 1 ];
        if (!quoteLst.isEmpty()) {
            return quoteLst[0];
        } else {
            return null;
        }
    }

    public static SBQQ__Quote__c getQuoteDetailByName(String quoteName) {
        List<SBQQ__Quote__c> quoteLst = 
                [ SELECT Id, Name, qtc_Multi_Site__c,qtc_Multi_Site_Parent_Quote__c, qtc_Multi_Site_Relationship__c,
                         qtc_Original_Quote_Number__c, SBQQ__Status__c,qtc_Multi_Site_Type__c, 
                         qtc_Legal_Document_Status__c,SBQQ__Primary__c,qtc_Cancelled__c,
                         SBQQ__Type__c
                FROM SBQQ__Quote__c
                WHERE Name =: quoteName
                LIMIT 1 ];
        if (!quoteLst.isEmpty()) {
            return quoteLst[0];
        } else {
            return null;
        }
    }

    public static Boolean isQualifyForPF(SBQQ__Quote__c q) {
        if ( q != null) {
            Boolean approved     = (q.SBQQ__Status__c == QUOTE_STATUS_APPROVED);
            Boolean unsigned     = (q.qtc_Legal_Document_Status__c != LEGAL_DOC_STATUS_COMPLETED);
            Boolean notCancelled = (q.qtc_Cancelled__c == FALSE);
            Boolean notAmendent  = (q.SBQQ__Type__c != QUOTE_TYPE_AMENDEMENT);
            
            return (q.SBQQ__Primary__c && approved && unsigned && notCancelled && notAmendent);
        } else {
            return false;
        }

    }

    public static List<SBQQ__Quote__c> getQualifiedChildQuotesForPF(Set<Id> parentQuoteIds) {
        return [SELECT Id, Name, SBQQ__Status__c, qtc_Multi_Site_Relationship__c, 
                       qtc_Legal_Document_Status__c, SBQQ__Primary__c, qtc_Cancelled__c,
                       SBQQ__Type__c
                FROM SBQQ__Quote__c
                WHERE qtc_Multi_Site_Parent_Quote__c IN: parentQuoteIds AND
                      SBQQ__Status__c =: QUOTE_STATUS_APPROVED AND
                      qtc_Legal_Document_Status__c !=: LEGAL_DOC_STATUS_COMPLETED AND
                      SBQQ__Primary__c = TRUE AND
                      qtc_Cancelled__c = FALSE AND
                      SBQQ__Type__c !=: QUOTE_TYPE_AMENDEMENT
                LIMIT 1
               ];
    }
 
}