({
    doInit : function (component,event,helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id")
        component.set("v.currentUserId",userId);
        var action = component.get("c.HasSalesforceMapPermission");
        action.setParams({ currentUserId : component.get("v.currentUserId") });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var responeValues=response.getReturnValue();
            if (state === "SUCCESS") {
                if(responeValues==true){
                component.set("v.isOpen", true);
                var flow = component.find("DisplayPrivacyOnLoginFlow");
                flow.startFlow("Display_Privacy_On_Login");   	 
                }
                else{
                  component.set("v.isOpen", false);  
                }
                
            }
            else if (state === "INCOMPLETE") {
                component.set("v.isOpen", false);
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
 
    },
    
    verifyButtonPressed: function(component, event, helper) {
        var buttonSource = event.getSource().get('v.value'); 
        if(buttonSource=='Agree')
            component.set("v.isAgreeButtonPressed", true); 
        else
            component.set("v.isDisAgreeButtonPressed", true); 
    },
    
    recordUpdated : function(component, event, helper) {
        if (component.get('v.runmodalonce')==true) {
            component.set("v.runmodalonce", false);
            helper.saveUser(component, event, helper);
            component.set("v.isOpen", false);
        }
    } ,
    
    closeModal:function(component,event,helper){  
        component.set("v.isOpen", false);
    },
    
})