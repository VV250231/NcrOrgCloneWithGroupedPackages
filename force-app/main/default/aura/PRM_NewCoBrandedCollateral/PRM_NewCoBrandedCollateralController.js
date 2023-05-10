({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getPicklistValues");
      	component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            component.set("v.campaignNames", a.getReturnValue().lstCampaignName);
           	component.set("v.requestingDocuments", a.getReturnValue().lstRequestingDocument);
            component.set("v.Spinner", false);
        })
        
        $A.enqueueAction(action);
    },
    
     cancel : function(component, event, helper) {
         
         $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/co-branded-collateral-listview"
                }).fire();
     },
    
    cSaveCoBranded : function(component, event, helper) {
         
		component.set("v.Spinner", true); 
        var action = component.get("c.saveCoBranded");
        action.setParams({
            "objCBC" : component.get("v.objCoBranded")
        })
      
        action.setCallback(this,function(a){
            component.set("v.Spinner", false); 
            //alert(a.getReturnValue());
             $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/co-branded-collateral-record?coid=" + a.getReturnValue()
                }).fire();
        })
        
        $A.enqueueAction(action);
     },
})