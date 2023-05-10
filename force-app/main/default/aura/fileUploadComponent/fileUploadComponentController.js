({  
    doInit : function(component, event, helper) {  
        helper.getRecordTypeName(component, helper);    
    }, 
    uploadFile : function(component, event, helper) {
        helper.uploadFile(component, helper);
    },
    saveSolutionBL : function(component, event, helper) {
        helper.saveSolutionBL(component, helper);
    },
    saveSolutionBLwithNewVersion : function(component, event, helper) {
        helper.saveSolutionBLwithNewVersion(component, helper);
    },
    saveServicesBL : function(component, event, helper) {
        helper.saveServicesBL(component, helper);
    },
    saveServicesBLwithNewVersion: function(component, event, helper) {
        helper.saveServicesBLwithNewVersion(component, helper);
    },
    closeAlert:function(component, event, helper) {
        helper.closeAlert(component, helper);
    },
    Cancel:function(component, event, helper) {
        helper.Cancel(component, helper);
    }
    
})