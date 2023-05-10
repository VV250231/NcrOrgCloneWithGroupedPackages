// ===========================================================================
// Object: DIGoBackPlugin
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Implementation of IGoBackPlugin for DI story 1475
// ===========================================================================
// Changes: 2016-12-06 Reid Beckett
//           Class created
// ===========================================================================
public class DIGoBackPlugin implements zqu.PropertyComponentController.IGoBackPlugin 
{
    public PageReference goBack (SObject record, zqu.PropertyComponentController.ParentController parentController) {
        system.debug('DIGoBackPlugin:goBack:start');
        system.debug('DIGoBackPlugin:goBack:record='+record);
        Map<String, String> urlParams = new Map<String, String>();
        if(ApexPages.currentPage().getParameters().get('oppId') != null){
            urlParams.put('oppId', ApexPages.currentPage().getParameters().get('oppId'));
        }
        if(ApexPages.currentPage().getParameters().get('crmAccountId') != null){
            urlParams.put('crmAccountId', ApexPages.currentPage().getParameters().get('crmAccountId'));
        }
        if(ApexPages.currentPage().getParameters().get('billingAccountId') != null){
            urlParams.put('billingAccountId', ApexPages.currentPage().getParameters().get('billingAccountId'));
        }
        if(ApexPages.currentPage().getParameters().get('retUrl') != null){
            urlParams.put('retUrl', ApexPages.currentPage().getParameters().get('retUrl'));
        }

        if(record != null && ((zqu__Quote__c)record).RecordTypeId == Schema.SObjectType.zqu__Quote__c.getRecordTypeInfosByName().get('New Renewal').getRecordTypeId()) {
            system.debug('DIGoBackPlugin:goBack:it is a renewal');
            Id quoteId = ApexPages.currentPage().getParameters().get('id');
            if(!String.isBlank(quoteId)) {
                try {
                    delete new zqu__Quote__c(Id = quoteId);
                }catch(Exception e){
                    system.debug('failed to delete quote:'+e.getMessage()+'\n'+e.getStackTraceString());
                }
            }
            ApexPages.currentPage().getParameters().remove('id');
            
        }
        system.debug('DIGoBackPlugin:goBack:urlParams='+urlParams);
        return zqu.QuoteWizardManager.navigateBack(urlParams);
    }
}