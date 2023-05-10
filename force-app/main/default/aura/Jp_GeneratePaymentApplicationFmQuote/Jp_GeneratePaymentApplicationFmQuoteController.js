({
    init : function(component, event, helper) {
        var action = component.get("c.valQteInfo"); 
        action.setParams({ QteId : component.get("v.recordId") }); 
        component.set("v.showSpinner",true);
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {                
                component.set("v.QteWrapper",response.getReturnValue());
                if(response.getReturnValue().Qte){
                     helper.GetRelatedContact(component,response.getReturnValue().Qte.SBQQ__Account__c);
                }
                var listofQtObj = [];
                if(response.getReturnValue().MultiQtePaymentSites){
                    for(var objVar of response.getReturnValue().MultiQtePaymentSites){
                        if(objVar.Account_Sites__c != null){
                            var sobj = {
                                SiteName:objVar.Account_Sites__r.Name,
                                SiteId:objVar.Account_Sites__r.Site_Number__c
                            }
                            listofQtObj.push(sobj);
                        }
                    }
                    if(listofQtObj.length > 0){
                        component.set("v.isMultisiteQuote",true);
                    }
                }
                
               component.set('v.multiSiteDataColumns', [
                   {label: 'Site Id', fieldName: 'SiteId', type: 'text'},
                   {label: 'Site Name', fieldName: 'SiteName', type: 'text'}
                ]); 
                component.set('v.multiQPaymentSiteData',listofQtObj);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                            component.set("v.isError",true);
                            component.set("v.errorMessage",errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        }); 
        
        $A.enqueueAction(action); 
    },
    handleSubmit: function(component, event, helper) {     
        var action = component.get("c.sndApplFmQte");
        action.setParams({ QteId : component.get("v.recordId") }); 
        component.set("v.showSpinner",true);
        action.setCallback(this, function(response) {
            component.set("v.showSpinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.response",response.getReturnValue());
                    var jsonRes = JSON.parse(response.getReturnValue());
                    if(!jsonRes.exceptionFlag){
                        var listofQtObj = [];
                        for(var obj of jsonRes.siteResultLst){
                            var sobj = {
                                siteNumber:obj.siteNumber,
                                SiteName:obj.siteName,
                                Status:obj.status,
                                StatusMsg:obj.statusMessage
                            }
                            listofQtObj.push(sobj);
                        }
                        component.set('v.MultiSiteResponseColumns', [
                            {label: 'Site Number', fieldName: 'siteNumber', type: 'text'},
                            {label: 'Site Name', fieldName: 'SiteName', type: 'text'},
                            {label: 'Status', fieldName: 'Status', type: 'text'},
                            {label: 'Status Message', fieldName: 'StatusMsg', type: 'text'}
                        ]); 
                        component.set('v.MultiSiteResponse',listofQtObj);
                    }else{
                        var toastEvent2 = $A.get("e.force:showToast");
                        toastEvent2.setParams({
                            "title": "Payments Application Failure.!",
                            "message": jsonRes.exceptionMessage,
                            "type": 'error',
                            "mode": 'sticky'
                        });
                        toastEvent2.fire();  
                    }
                /*}else{
                    var toastEvent = $A.get("e.force:showToast");
                    var res=response.getReturnValue().toUpperCase();
                    if (res.indexOf('PARTIAL') > -1) {
                        toastEvent.setParams({
                            "title": "Partially Successful.!",
                            "message": res,
                            "type": 'warning',
                            "mode": 'sticky'
                        });
                        toastEvent.fire();  
                    }else  if (res.indexOf('FAIL') > -1) {
                        toastEvent.setParams({
                            "title": "Payments Application Failure.!",
                            "message": res,
                            "type": 'error',
                            "mode": 'sticky'
                        });
                        toastEvent.fire(); 
                    } else {
                        toastEvent.setParams({
                            "title": "Payments Application Successfully Sent.",
                            "message": res,
                            "type": 'success',
                            "mode": 'dismissable'
                        });
                        toastEvent.fire();
                    }
                } */
            }
            else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                    var toastEvent1 = $A.get("e.force:showToast");
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    toastEvent1.setParams({
                        "title": "Server Failure.!",
                        "message": errors[0].message,
                        "type": 'error',
                        "mode": 'sticky'
                    });
                    toastEvent1.fire();
                }
            //Close Modal:
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire(); 
        });
        
        $A.enqueueAction(action);
        
    },
    
    cancel: function(component, event, helper) {     
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleAssigneChange:function(component, event, helper){
       var selectedOptionValue = event.getParam("value"); 
        //alert("Option selected with value: '" + selectedOptionValue + "'");
        component.set("v.ToggleConDetls",true);
        var action = component.get("c.SavePaymtAsigneOnQte");
        var Options = [];
        action.setParams({
            "ConId":event.getParam("value"),
            "qid":component.get("v.recordId")
            
       });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var Msg='';
            if (state === "SUCCESS") {
				//alert('Success'+response.getReturnValue()); 
                component.set("v.ConDetails",response.getReturnValue());
                //alert(JSON.stringify(component.get("v.Quote")));
                 //component.set("v.ToggleConDetls",false);
                if(!response.getReturnValue().Phone){
                    Msg='Phone Number is missing for selected Contact'
                    component.set("v.ToggleConDetls",false);
                }
                
                else if(!response.getReturnValue().Email){
                    Msg='Email is missing for selected Contact'
                    component.set("v.ToggleConDetls",false);
                }
                
                if(Msg){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                         mode: 'sticky',
                        type:'error',
                        message: 'This is a required message',
                        messageTemplate: `${Msg} See it {1}!`,
                        messageTemplateData: ['Salesforce', {
                            //url: `/lightning/r/Contact/${response.getReturnValue().Id}`+'/', 
                            url:'/'+response.getReturnValue().Id,
                            label: 'here',
                            }
                        ]
                    });
                    toastEvent.fire();
                }
                else{
					 component.set("v.ToggleConDetls",false);
                }   
           }
            else{
                
            }
        }); 
        $A.enqueueAction(action);
    }
    
})