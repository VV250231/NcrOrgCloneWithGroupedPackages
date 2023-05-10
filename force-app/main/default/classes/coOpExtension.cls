/*
*********************************************************
Apex Class Name    : coOpExtension
Test Class Name    : coOpExtensionTest
Created Date       : 3/15/2017 11:24 AM
@author            : Shiv Mahla
Modification Log:
Date                       Modified by                      Modification
1/18/2022 3:58 AM          Simran Grewal                    EBA_SF-1734 -Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3 
                                                   
*********************************************************
*/
public class coOpExtension {
    public String coOpId {get;set;}
    public Attachment att {get;set;}
    public Co_Op_Supporting_Document__c supportingDoc {get;set;}
    //public Map<String,String> params {get;set;}
    String retUrl;
    
    public coOpExtension(ApexPages.StandardController sc) {
        att = new Attachment();
        supportingDoc = new Co_Op_Supporting_Document__c();
        //EBA_SF-1734-Technical Debt - Security- Apex Class -ApexXSSFromURLParam Part 3
       // coOpId  = ApexPages.currentPage().getParameters().get('coOpid');
        coOpId = String.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('coOpid'));
        //retUrl = ApexPages.currentPage().getParameters().get('retURL');
        //List<String> temp = retUrl.split('/');
        //if (temp.size() > 0)
           //coOpId =  temp[temp.size()-1];
    }
    
    public PageReference saveSupportingDoc() {
        if (att.Body == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,'Please choose a file to attach.'));
            return null;
        }
        Savepoint sp = Database.setSavepoint();
        PageReference pageRef = Page.ipt_co_op_view;
        pageRef.getParameters().put('id',coOpId);
        try {
            // Insert attachment
            att.ParentId = coOpId;
            insert att;
            // Insert Supporting Doc record
            supportingDoc.Name = att.Name;
            supportingDoc.Attachment_Id__c = att.Id;
            supportingDoc.Co_Op_Request__c = coOpId;
            insert supportingDoc;
            
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Error,ex.getMessage()));
            return null;
        }
        return pageRef;
    }

}