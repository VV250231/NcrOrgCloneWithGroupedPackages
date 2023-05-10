public with sharing class sf1ContactExt {

    public sf1ContactExt(ApexPages.StandardController controller) {
        Map<String, String> paramMap = ApexPages.currentPage().getParameters();
        //System.debug('para'  + paramMap);
        
    }

    public PageReference redirectToContact() {
        PageReference pg = new PageReference('/003/e');
        return pg;
    }
}