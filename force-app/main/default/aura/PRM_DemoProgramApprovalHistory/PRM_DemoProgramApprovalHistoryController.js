({
	   
    doInit : function(component, event, helper) {
        
        helper.getApprovalHistory(component);
    },
    
    closeDocModal: function(component, event, helper) {
      
      	component.set("v.isRejection", false);
       	component.set("v.isApprovalWithoutUpdateRecord", false);
        component.set("v.isApprovalWithUpdateRecord", false);
   	},
   
    openRejectionModal: function(component, event, helper) {
      
      	component.set("v.isRejection", true);
        var opts = [];
		var reasons = component.get("v.rejectionReasons");
       	for (var i = 0; i < reasons.length; i++) {
            opts.push({
                class: "optionClass",
                label: reasons[i],
                value: reasons[i]
            });
        }
        component.find("SelectRejectionReasons").set("v.options", opts);
       	
   	},
    
    
    openApprovalModal: function(component, event, helper) {
        if(component.get("v.objDP").Approval_Step__c == 'Submitted to Dundee Financial Pricing Analyst' || 
           component.get("v.objDP").Approval_Step__c == 'Submitted to European Finance Manager')
        {
            component.set("v.isApprovalWithUpdateRecord", true);
        }
        else
        {
      		component.set("v.isApprovalWithoutUpdateRecord", true);
        }
    },
    
    doApproveRecrodWithoutUpdate : function(component, event, helper) {
        
        var action = component.get("c.approveDemoProgram"); 
       action.setParams({
            "objDemoProgram" : component.get("v.objDP"),
            "comment" : component.get("v.strComment"),       
            "recId":component.get("v.recordId"),
            "workItemId":component.get("v.processInstanceWorkitemId"),
            "isUpdate" : false
        });
        action.setCallback(this, function(a) {

           var result = a.getReturnValue();
           if(result == 'Approved')
           {
               component.set("v.isApprovalWithoutUpdateRecord", false);
               $A.get('e.force:refreshView').fire();
           }
                    
        });
        $A.enqueueAction(action);
       
    },
    doRejectRecord : function(component, event, helper) {
        
        var action = component.get("c.rejectDemoProgram"); 
        action.setParams({
            "comment" : component.get("v.strComment"),
            "strReason":component.find("SelectRejectionReasons").get("v.value"),            
            "recId":component.get("v.recordId"),
            "workItemId":component.get("v.processInstanceWorkitemId")
        });
        action.setCallback(this, function(a) {

           var result = a.getReturnValue();
            
           if(result == 'Rejected')
           {
               component.set("v.isRejection", false);
               $A.get('e.force:refreshView').fire();
           }
          
        });
        $A.enqueueAction(action);
    },
    
    isRefreshed: function(component, event, helper) {
        location.reload();
    },
	handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);
    },
    
     doApproveRecrodWitUpdate: function(component, event, helper) {
         var numberRegex = /^\d*\.?\d*$/;
         var submitREcord = true ;
         //alert(component.find("Demo_Price").get("v.value"));
         
        if(!component.find("Demo_Price").get("v.value"))
         {
              submitREcord = true ;
         }
       	else {
            if(!component.find("Demo_Price").get("v.value").match(numberRegex))
            {
                component.find("Demo_Price").set("v.errors",[{message:"Please Enter number only: "}]);
                submitREcord = false ;
            }
            else
            {
               component.find("Demo_Price").set("v.errors",null);
            }
        }
         
        if(submitREcord)
     		helper.uploadHelper(component, event);
    },
})