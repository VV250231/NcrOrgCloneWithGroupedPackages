({
    doInit : function(component, event, helper) {
        console.log("Method : doInt");
        var action = component.get("c.getOpportunityDetail");
        var oppID = component.get("v.recordId");
        action.setParams({ "oppId" : component.get("v.OpportunityId")});    
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                console.log("Opportunity Information : ",response.getReturnValue());
                var OpportunityInfo = response.getReturnValue();
                if(OpportunityInfo.Id != null && OpportunityInfo.CAM_TAM_Confirm_Net_New_Customer__c ==false && OpportunityInfo.Net_New_Customer__c == true ){
                    console.log("Opportunity ID"+OpportunityInfo.Id);
                    component.set("v.popShow",true);
                    console.log("Show error : ",component.get("v.popShow"));
                }
            }else{
                console.log("ERROR");
            }
        });
        $A.enqueueAction(action);
        
        
    },
    
    confirmNetNewCustomer : function(component, event, helper){
        console.log("Method : confrimNetNewCustomer");
        var action = component.get("c.setConfrimNetNewCustomer");
        var oppID = component.get("v.recordId");
        action.setParams({ 
            "oppId" : oppID, 
            "netNewCustomerConfirm":"true"
        });    
        action.setCallback(this,function(response){
            if(response.getState() === "SUCCESS"){
                console.log("Opportunity Information : ",response.getReturnValue());
                component.set("v.popShow",false);
                console.log("Show error : ",component.get("v.popShow"));
            }else{
                console.log("ERROR");
            }
        });
        $A.enqueueAction(action);
    }
})