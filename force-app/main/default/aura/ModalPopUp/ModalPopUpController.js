(
    {
    doInit : function(component, event, helper) {
        var action = component.get("c.getPopUpAvailablity");
         console.log('hi');
       var selected = component.find("InputSelectSingle").get("v.value");
          
        action.setParams({
            "recordId": component.get("v.recordId")
            
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var rValue = response.getReturnValue();
                console.log(rValue);
               if(rValue =='Diagnose' || rValue =='Portal' || rValue =='DiagnosePortal'){
                    component.set("v.showModalB",'Y');  
                   component.set("v.showModalA",'N'); 
                   if(rValue.includes('Diagnose'))
                   		component.set("v.showModalD",'Y');
                    if(rValue.includes('Portal'))
                   		component.set("v.showModalC",'Y');
               }
                if(rValue =='RejectEngineer'){
                    component.set("v.showModalA",'Y');  
                    component.set("v.showModalB",'N');
                }
                if(rValue =='DealReg'){
                    component.set("v.showModalDeal",'Y');  
                  
                }
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
        
        
    },
    


    

redirect :  function(component, event, helper) {
    var action = component.get("c.fetchUrl");
       
        action.setParams({
            "processId": component.get("v.recordId")
            
        });
console.log('I am there');
    
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rValue = response.getReturnValue();
                console.log(rValue);
                var navEvt = $A.get("e.force:navigateToSObject");
        				
       			 navEvt.setParams({
           			 "recordId": rValue,
                     

        		});
       			 navEvt.fire();
        		
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
     }, 
        
     
        
engineerToContactConversion : function(component, event, helper) {
    var action = component.get("c.engineerToContact");
       
        action.setParams({
            "recordId" : component.get("v.recordId"),
            "engineerId": component.get("v.engineerId"),
            "portalLogin" : component.get("v.portalLogin")
         });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rValue = response.getReturnValue();
                console.log('hi'+ rValue);
                setTimeout(function(){ 
                var navEvt = $A.get("e.force:navigateToSObject");
        				
       			 navEvt.setParams({
           			 "recordId": rValue,
                     

        		});
       			 navEvt.fire();
                }, 6000);
                

            }
        });
        // Invoke the service
        $A.enqueueAction(action);
},
  
 sendMail : function(component, event, helper) {
    var action = component.get("c.sendEmail");
    
        action.setParams({
            "selectedReason" : component.find("InputSelectSingle").get("v.value"),
            "comment" : component.get("v.reason"),
             "recordId" : component.get("v.recordId")
         });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var rValue = response.getReturnValue();
                console.log('hi'+ rValue);
                setTimeout(function(){ 
                var navEvt = $A.get("e.force:navigateToSObject");
        				
       			 navEvt.setParams({
           			 "recordId": rValue,
                     

        		});
       			 navEvt.fire();
                }, 6000);
                

            }
        });
        // Invoke the service
        $A.enqueueAction(action);
},
        
         sendMailDeal : function(component, event, helper) {
          var action = component.get("c.sendEmailDealReg");
    
        action.setParams({
            "selectedReason" : component.find("InputSelectSingleDeal").get("v.value"),
            "recordId" : component.get("v.recordId")
         });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            var state = response.getState();
           
            if (state === "SUCCESS") {
                var rValue = response.getReturnValue();
                console.log('hi'+ rValue);
                setTimeout(function(){ 
                var navEvt = $A.get("e.force:navigateToSObject");
        				
       			 navEvt.setParams({
           			 "recordId": rValue,
                     

        		});
       			 navEvt.fire();
                }, 6000);
                

            }
        });
        // Invoke the service
        $A.enqueueAction(action);
},
        
        getOther:function(component, event, helper){
            if(component.find("InputSelectSingle").get("v.value") =='Others'){
				 component.set("v.showModalE",'Y');                  
                
            }else{
                
                component.set("v.showModalE",'N'); 
            }
         
        },
  
    
showModalBox : function(component, event, helper) {
document.getElementById("backGroundSectionId").style.display = "none";
document.getElementById("newAccountSectionId").style.display = "none";
},
 
  
    
    onSingleSelectChange: function(cmp) {
         var selectCmp = cmp.find("InputSelectSingle");
         var resultCmp = cmp.find("singleResult");
         resultCmp.set("v.value", selectCmp.get("v.value"));
	 },
    
saveAccount : function(component, event, helper) {
 
var action = component.get("c.getAccountupdatedlist");
action.setParams({ "newAcc" : component.get("v.newAccount")});
 
action.setCallback(this, function(a) {
if (a.getState() === "SUCCESS") {
document.getElementById("backGroundSectionId").style.display = "none";
document.getElementById("newAccountSectionId").style.display = "none";
} else if (a.getState() === "ERROR") {
$A.log("Errors", a.getError());
}
});
 
$A.enqueueAction(action);
}
})