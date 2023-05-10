({
    init : function(component, event, helper) {
        
        var oppId = component.get("v.oppId");
        
        //get USM Opportunity Details
        helper.getOpportuityDetail(component, event, helper);
        //helper.getUSMOpportuityDetail(component, event, helper);
        helper.getUserDetail(component, event, helper);
    },
    validateAndSaveServiceSales : function(cmp,event, helper) {
        
        if(cmp.get("v.oppDetail.Services_Sales_Consultant__c")!="" && cmp.get("v.ssc")!="" && cmp.get("v.ssc")!=null && cmp.get("v.ssc")!=cmp.get("v.oppDetail.Services_Sales_Consultant__c")){
            cmp.set("v.ssc",cmp.get("v.oppDetail.Services_Sales_Consultant__c"));      
            helper.validateAndSaveServiceSales(cmp, event, helper); 
        }else if((cmp.get("v.ssc")=="" || cmp.get("v.ssc")==null) && (cmp.get("v.oppDetail.Services_Sales_Consultant__c")!="" && cmp.get("v.oppDetail.Services_Sales_Consultant__c")!=null)){
            cmp.set("v.ssc",cmp.get("v.oppDetail.Services_Sales_Consultant__c"));
            helper.validateAndSaveServiceSales(cmp, event, helper);
        }    },
    
    handleUSMEvent : function(component, event, helper) {
        //Validate System validation on opportunity available.
        if(component.get("v.sys_error")){
            var msg='';
            if(component.get("v.oppDetail.StageName").toUpperCase().indexOf('CLOSED')>=0){
                msg='Opportunity is Closed, You cannot Enagage Services, Use USM(ServiceNow) to Link Salesforce opportunity Or Contact Saleforce Admin.';
            }else{
                msg='Opportunity have validation Failures, Close Engage feature and update opportunity to resolve validation issue first. Contact Salesforce Admin for support.';
            }
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "ERROR!",
                "type":"warning",
                "mode":"sticky",
                "message": msg
            });
            toastEvent.fire();
        }else{
            helper.validateUSMDetail(component);
            if(!component.get("v.error")){
                console.log('validated>>>>>>>');
                var appEvent = $A.get("e.c:usm_showError");
                appEvent.setParams({ "showError" : false });
                appEvent.fire();
                var usmOppDetail = component.get("v.usmOppDetail");
                usmOppDetail.Opportunity__c = component.get("v.oppId");
                helper.showSpinner(component,event, helper);
                helper.callService(component, event, helper);
                
            }   
            
        }
    }
    
    
    
    
    
})