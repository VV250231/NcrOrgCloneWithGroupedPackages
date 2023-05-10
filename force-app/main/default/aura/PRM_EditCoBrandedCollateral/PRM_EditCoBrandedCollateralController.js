({
	 doInit : function(component, event, helper) {
        var action = component.get("c.getEditCoBrandedCollateralDetail");
        var idParam = helper.getJsonFromUrl().coid;
        //alert(idParam);
        action.setParams({
            "recId" : idParam
        })
      	component.set("v.Spinner", true);
        action.setCallback(this,function(a){
            component.set("v.campaignNames", a.getReturnValue().lstCampaignName);
           	component.set("v.requestingDocuments", a.getReturnValue().lstRequestingDocument);
            component.set("v.objCoBranded", a.getReturnValue().objCB);
            component.find("Campaign_Name").set("v.value", a.getReturnValue().objCB.Campaign_Name__c)
            component.find("Class").set("v.value", a.getReturnValue().objCB.What_kind_of_document_are_you_requesting__c)
            component.set("v.Spinner", false);
        })
        
        $A.enqueueAction(action);
    },
    
     cancel : function(component, event, helper) {
         var action = component.get("c.getEditCoBrandedCollateralDetail");
         var idParam = helper.getJsonFromUrl().coid;
         $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/co-branded-collateral-record?coid=" + idParam
                }).fire();
     },
    
    cSaveCoBranded : function(component, event, helper) {
         
		component.set("v.Spinner", true); 
        var action = component.get("c.saveEditedCoBranded");
        action.setParams({
            "objCBC" : component.get("v.objCoBranded")
        })
      
        action.setCallback(this,function(a){
            
            //alert(a.getReturnValue());
             $A.get("e.force:navigateToURL").setParams({ 
                   "url": "/co-branded-collateral-record?coid=" + a.getReturnValue()
                }).fire();
            
            component.set("v.Spinner", false); 
        })
        
        $A.enqueueAction(action);
     },
})