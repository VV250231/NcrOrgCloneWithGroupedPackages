({  
    
    validateUSMDetail : function(component, field){
        component.set("v.error", false);
        if(component.get("v.isLOB")){
            this.validateRequiredFieldsCustom(component,"Parent__c",'Parent Account?');
        }
        this.validateRequiredFields(component,component.find("services_sales_consultant__c").get("v.value"),'Services Sales Consultant');
        
        this.validateRequiredFieldsCustom(component,"Any_change_in_PPM_SLA_or_geography__c",'Any change in PPM, SLA, or geography?');
        
        this.validateRequiredFieldsCustom(component,"Are_additional_services_being_requested__c",'Are additional services being requested?');
        
        this.validateRequiredFieldsCustom(component,"Are_new_hardware_products_being_added__c",'Are new hardware products being added?');
        
        this.validateRequiredFieldsCustom(component,"What_problem_is_customer_trying_to_solve__c",'What problem is customer trying to solve?');
        this.validateRequiredFieldsError(component,"Required_Bid_Completion_Date__c",'Required Bid Completion Date');
        
        if(component.get("v.isManagedService")){
            this.validateRequiredFieldsCustom(component,"Is_in_country_location_required__c",'Is in-country location required?');
            this.validateRequiredFieldsCustom(component,"Is_customer_requesting_On_Premise__c",'Is customer requesting On Premise?');
            this.validateRequiredFieldsCustom(component,"Is_customer_Direct_or_Channel__c",'Is customer Direct or Channel?');
            this.validateRequiredFieldsCustom(component,"Customer_network_connectivity_strategy__c",'Customer network connectivity strategy');
            this.validateRequiredFieldsCustom(component,"Will_NCR_provide_NCR_break_fix_Service__c",'Will NCR provide NCR break fix Service?');
            this.validateRequiredFieldsCustom(component,"What_is_the_HW_configuration__c",'What is the HW configuration?');
            this.validateRequiredFieldsCustom(component,"What_is_SW_configuration__c",'What is SW configuration?');
                    this.validateRequiredFieldsCustom(component,"SW_maintenance_required_on_end_points__c",'SW maintenance required on end points?');

        }
        if(component.find("Is_this_a_renewal_or_new_business__c").get("v.value")=='New'){
            this.validateRequiredFieldsCustom(component,"Will_this_be_added_to_existing_contract__c",'Service Scope to be added to existing Contract?');
        }
        if(!component.get("v.error")){
            this.validateFieldsType(component,component.find("Expected_Total_Service_Contract__c").get("v.value"),'Expected Total Service Contract');
        }
        if(!component.get("v.error")){
            this.validateFieldsType(component,component.find("File_Value_at_Risk__c").get("v.value"),'File value at Risk');
        }
        if(!component.get("v.error")){
            this.validateFieldsType(component,component.find("TS_SOW_Value_USD__c").get("v.value"),'TS SOW Value($USD)');
        }
        if(!component.get("v.error")){
            this.validateFieldsType(component,component.find("TS_SOW_Value_USD__c").get("v.value"),'TS SOW Value($USD)');
        }       
    },
    
    validateFieldsType : function(component, field,label){
        console.log('validateFieldsType>>>>>>>');
        if (!$A.util.isEmpty(field) && isNaN(field)){
            var appEvent = $A.get("e.c:usm_showError");
            appEvent.setParams({ "showError" : true,"fieldName" : 'Please enter value in number format:'+ label });
            appEvent.fire();
            component.set("v.error", true);
        }
    },
    validateRequiredFields : function(component,field,label){
        if ($A.util.isEmpty(field)){
            
            var appEvent = $A.get("e.c:usm_showError");
            appEvent.setParams({ "showError" : true,"fieldName" : 'Please enter required field, Review the form and enter all required fields :' + label  });
            appEvent.fire();
            component.set("v.error", true);
            
        }
    },
    
    validateRequiredFieldsError : function(component,fieldID,label){
        var field=component.find(fieldID);
        if ($A.util.isEmpty(field.get("v.value"))){
            field.set("v.errors", [{message:"Please enter required field, Review the form and enter all required fields :" + label}]);
            
            var appEvent = $A.get("e.c:usm_showError");
            appEvent.setParams({ "showError" : true,"fieldName" : 'Please enter required field, Review the form and enter all required fields :' + label  });
            appEvent.fire();
            component.set("v.error", true);
            
        }else{
            field.set("v.errors", null);  
        }
    },
    
    validateRequiredFieldsCustom : function(component,fieldID,label){
        var fieldError=component.find(fieldID+"_error");
        var field=component.find(fieldID);
        if ($A.util.isEmpty(field.get("v.value"))){
            console.log('-->empty');
            var div;
            var error='';
            if ($A.util.isEmpty(field.get("v.value"))){
                error="Required filled missing, Field cannot be blank, Please fill value: "+label;
            }else{
                error=null;
            }
            $A.createComponents([["aura:html", {
                "tag": "div",
                "body": error,
                "HTMLAttributes": {
                    "class": "slds-text-align_left, slds-text-color_error"
                }
            }]], function(component, status, errorMessage) {
                if (status === "SUCCESS") {
                    try {
                        div = component[0];
                        
                    } catch (error) {
                        console.error(error);
                    }
                }
                else
                {
                    console.log('Error from ' + component.getName() + ' ' + 'Unable to create Error component');
                }
            }
                               );
            var appEvent = $A.get("e.c:usm_showError");
            appEvent.setParams({ "showError" : true,"fieldName" : 'Please enter required field, Review the form and enter all required fields '  });
            appEvent.fire();
            component.set("v.error", true);
            fieldError.set("v.body",div);
            
        }else{
            fieldError.set("v.body",null);  
        }
        
    },
    validateAndSaveServiceSales : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var ss=cmp.get("v.oppDetail.Services_Sales_Consultant__c");
        if(ss!=null && ss.indexOf("MALFORMED_ID")==-1){
            var action = cmp.get("c.setServiceSales");
            action.setParams({ opp : cmp.get("v.oppDetail") });
            // Create a callback that is executed after 
            // the server-side action returns
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var response = response.getReturnValue();            
                    if(response.indexOf('ERROR')>-1){  
                        var appEvent = $A.get("e.c:usm_showError");
                        appEvent.setParams({ "showError" : true,"fieldName" : response  });
                        appEvent.fire();
                        cmp.set("v.error", true);
                        cmp.set("v.sys_error", true);
                    }

                }
                else if (state === "INCOMPLETE") {
                    // do something
                }
                    else if (state === "ERROR") {
                        var response = response.getReturnValue();            
                        
                        var appEvent = $A.get("e.c:usm_showError");
                        appEvent.setParams({ "showError" : true,"fieldName" :  response  });
                        appEvent.fire();
                        cmp.set("v.error", true);
                    }
            });
            $A.enqueueAction(action);  
        }
        
        
    },
    
    getUSMOpportuityDetail : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.getUSMOpportunity");
        action.setParams({ opportunityId : cmp.get("v.oppId") });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response != null){
                    console.log(JSON.stringify(response));
                    cmp.set("v.usmOppDetail",response);
                }
                
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
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    
    getOpportuityDetail : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.getOpportunity");
        action.setParams({ opportunityId : cmp.get("v.oppId") });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response != null){
                    console.log('##'+JSON.stringify(response));
                    cmp.set("v.oppDetail",response.opp);
                    if(!$A.util.isEmpty(response.opp.Services_Sales_Consultant__c)){
                        var value = [{ 
                            type: 'User', 
                            id: response.opp.Services_Sales_Consultant__r.Id, 
                            label: response.opp.Services_Sales_Consultant__r.Name, 
                        }]; 
                        cmp.find("services_sales_consultant__c").get("v.body")[0].set("v.values", value); 
                    }
                    
                    
                    //cmp.find("userId").set("v.value", response.opp.Service_Sales_Consultant_c);
                    //cmp.find("service_sales_consultant__c").get("v.body")[0].set("v.values", response.opp.Service_Sales_Consultant__c);
                    //console.log('%%'+cmp.get("v.service_sales_consultant__c"));
                    cmp.set("v.isLOB",response.isLOB);
                    cmp.set("v.isManagedService",response.isManagedService);
                    console.log('test');
                }
                
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
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    getUserDetail : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.getUserDetail");
        // Create a callback that is executed after 
        // the server-side action returns
        console.log("## user detail");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                if(response != null){
                    cmp.set("v.userQuicklook",response);
                }
                
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
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    
    saveUSMOpportuityDetail : function(cmp,event, helper,usmOppDetail ) {
        console.log("saveUSMOpportuityDetail>>>> ");
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.saveUSMOpportunity");
        action.setParams({ usmOpportunity : usmOppDetail });
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) { 
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();
                console.log("From server: " + response);
                if(response == "sucess"){ 
                    appEvent.setParams({  "msg" : response});
                    var appEvent = $A.get("e.c:closeUSMDetail");
                    appEvent.fire();
                }          
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
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
        
    },
    callService : function(cmp,event, helper) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        if(cmp.get("v.ssc")=="" || cmp.get("v.ssc")=="" ){
            this.validateAndSaveServiceSales(cmp,event, helper);
        }
        var action = cmp.get("c.callUSMService");
        action.setParams({ opp : cmp.get("v.oppDetail"),
                          usmopp : cmp.get("v.usmOppDetail"),
                          quicklook:cmp.get("v.userQuicklook")});
        
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            helper.hideSpinner(cmp,event, helper);
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                var response = response.getReturnValue();                
                var appEvent = $A.get("e.c:usm_showError");
                if(response.indexOf('ERROR')>-1){
                    appEvent.setParams({  "showError" : true,"fieldName" : response });
                    appEvent.fire();
                }else{
                    var appEvent1 = $A.get("e.c:UpdateUSMComponent");
                    appEvent1.fire();
                    var appEvent = $A.get("e.c:closeUSMDetail");
                    appEvent.setParams({  "msg" : response});
                    appEvent.fire();
                    
                    
                }
                
                
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
                            var appEvent = $A.get("e.c:usm_showError");
                            appEvent.setParams({  "showError" : true,"fieldName" : errors[0].message  });
                            appEvent.fire();
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);  
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.showSpinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.showSpinner", false);
    }
    
    
})