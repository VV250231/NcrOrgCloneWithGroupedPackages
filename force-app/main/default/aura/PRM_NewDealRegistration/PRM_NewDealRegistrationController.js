({
    // function call on component Load
    doInit: function(component, event, helper) 
    {  
        var action = component.get("c.getPicklistValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state >>',response.getState());
            if (state === "SUCCESS") {
                component.set("v.dealRegistrationTypes", response.getReturnValue().dealRegistrationType);
                component.set("v.countries", response.getReturnValue().country);
                component.set("v.oppStageProbability", response.getReturnValue().probability);
                
                /*component.set("v.primarySolutions", response.getReturnValue().primarySolution);
                component.set("v.secondarySolutions", response.getReturnValue().secondarySolution);
                */
                component.set("v.isFinance", response.getReturnValue().isFIN);
                component.set("v.distributorList",response.getReturnValue().distributors);
                component.set("v.contactInCC",response.getReturnValue().contactNames);
                component.set("v.accountTheater",response.getReturnValue().accountTheater);
                component.set("v.accountRegion",response.getReturnValue().accountRegion);
                component.set("v.accountDetail",response.getReturnValue().actDetail);
                console.log(response.getReturnValue().actDetail);
                console.log("Account region  >>",response.getReturnValue().accountRegion);
                console.log("====Account Details==\n\t",response.getReturnValue().accountTheater);
                //alert( component.get("v.accountDetail").Account_Country_Code__c);
                component.set("v.partnerIndustryList",response.getReturnValue().partnerIndustry);
                
                //component.find("selectDealRegistrationTypes").set("v.value", response.getReturnValue().dealRegistrationType);
                component.find("selectDealRegistrationTypes").set("v.value", '--None--');
                component.find("selectCountries").set("v.value", '--None--');
                component.find("selectPrimarySolutions").set("v.value", '--None--');
                component.find("selectSecondarySolutions").set("v.value", '--None--');
                component.find("selectDistributor").set("v.value",'--None--');
                component.find("selectCC").set("v.value",'--None--');
                
                //Adding Servicing Details               
                component.set("v.servicingAccounts", response.getReturnValue().servicingAccount);
                component.set("v.serviceOptions", response.getReturnValue().serviceOption);
                component.set("v.servicingThisAccounts", response.getReturnValue().servicingThisAccount);
                
                component.set("v.depnedentFieldMap",response.getReturnValue().mapPartnerIndustryToPS);
                component.set("v.depnedentFieldMap2",response.getReturnValue().mapPartnerIndustryToSS);
                
                // Code added by deeksharth to Add TAM...
                var result = response.getReturnValue().getTAM;
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                if(arrayMapKeys.length>0){
                    component.set("v.picklistValuesTAM",arrayMapKeys);
                }else{
                    console.log("No data found please connect to CAM");
                }
                // Deeksharth Code end here
                
                //alert(response.getReturnValue().partnerIndustry.length + '----' + response.getReturnValue().partnerIndustry[0]);
                if(response.getReturnValue().partnerIndustry.length == 1)
                {
                    var valPI = response.getReturnValue().partnerIndustry[0];
                    component.find("selectPartnerIndustry").set("v.value", valPI);
                    //alert(valPI);
                    
                    var depnedentFieldMap = component.get("v.depnedentFieldMap");
                    var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
                    var ListOfDependentFields = depnedentFieldMap[valPI];
                    var ListOfDependentFields2 = depnedentFieldMap2[valPI];
                    
                    helper.fetchDepValues(component, ListOfDependentFields);  
                    
                    helper.fetchDepValues2(component, ListOfDependentFields2); 
                }
                else
                {
                    component.find("selectPartnerIndustry").set("v.value",'--None--');
                    
                    component.set("v.primarySolutions", ['--None--']);
                    component.find("selectPrimarySolutions").set("v.value", '--None--');
                    
                    component.set("v.secondarySolutions", ['--None--']);
                    component.find("selectSecondarySolutions").set("v.value", '--None--');
                }
                
                /* Start Set selected Registration_Type__c 
                var optDrTypes = [];
                var drTypes = response.getReturnValue().dealRegistrationType;
                
                for (var i = 0; i < drTypes.length; i++) {
                    
                    if(drTypes[i] === 'New Request'){
                        optDrTypes.push({
                            class: "optionClass",
                            label: drTypes[i],
                            value: drTypes[i],
                            selected: "true" 
                        });
                    }
                    
                }
                component.find("selectDealRegistrationTypes").set("v.options", optDrTypes);*/
                
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
        
        // by call this helper function  
        //helper.createObjectData(component, event);
    },
    saveDealRegistrationController : function(component, event, helper) 
    {      
     var actiondl = component.get("c.DealRegistration");
     actiondl.setParams({ "Industry" :component.find("selectPartnerIndustry").get("v.value"),
                         "Accounttheater" : component.get("v.accountTheater")
                        });
     actiondl.setCallback(this, function(response){
         var state = response.getState();
         var result=response.getReturnValue();
         // alert(component.get("v.accountTheater"));
         //alert(component.get("v.selectedIndustry"));
         // alert(JSON.stringify(result));
         if (state === "SUCCESS") {
             component.set("v.projectedOpportunityValue", result[0].Projected_Opportunity_Value__c );  
             component.set("v.dealWithMonthlyRecurringRev", result[0].Deal_with_Monthly_Recurring_Rev__c); 
             if(helper.isValidate(component, event, helper))
             {
                 var action = component.get("c.saveDealRegistration");
                 var var_county;
                 if (component.find("selectPartnerIndustry").get("v.value") == 'Hospitality') {
                     var_county = component.find("county").get("v.value");
                 }
                 
                 component.get("v.ObjDealRegistration").Probability_Score__c = component.find("Probability_Score").get("v.value");
                 console.log(component.get("v.ObjDealRegistration"));
                 action.setParams({ "objDR" : component.get("v.ObjDealRegistration"), 
                                   "dealRegistrationType" : component.find("selectDealRegistrationTypes").get("v.value"), 
                                   "country" : component.find("selectCountries").get("v.value"),
                                   "primarySolution" : component.find("selectPrimarySolutions").get("v.value"), 
                                   "secondarySolution" : component.find("selectSecondarySolutions").get("v.value"),
                                   "distributor" : component.find("selectDistributor").get("v.value"),
                                   "partnerIndustry": component.find("selectPartnerIndustry").get("v.value"),
                                   "contactCC": component.find("selectCC").get("v.value"),
                                   "county": var_county});
                 
                 action.setCallback(this, function(response) {
                     var state = response.getState();
                     if (state === "SUCCESS") {
                         component.set("v.drId", response.getReturnValue());
                         //alert(response.getReturnValue());
                         component.set("v.isNew", false);
                         component.set("v.isDetail", true);
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
             }
             else
             {	
                 var toastEvent = $A.get("e.force:showToast");
                 toastEvent.setParams({
                     "title": "Error:",  
                     "type": "error",
                     "message": "Review the errors on this page."
                 });
                 toastEvent.fire();
             }
         }
     });
     $A.enqueueAction(actiondl);     
     
    },
    cancel : function(component, event, helper) {
        
        $A.get("e.force:navigateToURL").setParams({ 
            "url": "/dr-list-view" 
        }).fire();
        
    }, /*
    onChangeType : function(component, event, helper) {
        
        
        component.set("v.dealTypeName", component.find("selectDealRegistrationTypes").get("v.value"));
        if(component.find("selectDealRegistrationTypes").get("v.value") == 'Update previously approved Deal Registration')
        {
     		var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Information",  
                        "type": "info",
                        "message": "Please search for the existing request, make updates or ask for an extension"
                    });
            toastEvent.fire();
        }
    },*/
    
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
        if (controllerValueKey != '--None--') 
        {	
            if(controllerValueKey =='Financial' && component.get("v.accountRegion")=='NAMER CFI'){
                component.set("v.isTAMMandatory", true);
            }else{
                component.set("v.isTAMMandatory", false);
                if(component.find("addTAM")){
                    component.find("addTAM").set("v.errors",null);
                } 
            }
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            helper.fetchDepValues(component, ListOfDependentFields);  
            
            var ListOfDependentFields2 = depnedentFieldMap2[controllerValueKey];
            helper.fetchDepValues2(component, ListOfDependentFields2);  
        } 
        else 
        {
            component.set("v.primarySolutions", ['--None--']);
            component.find("selectPrimarySolutions").set("v.value", '--None--');
            
            component.set("v.secondarySolutions", ['--None--']);
            component.find("selectSecondarySolutions").set("v.value", '--None--');
        }
    },
    onServicingThisAccountChange : function(component, event, helper){
        
        component.set("v.ObjDealRegistration.Yes_how_many_units_are_you_servicing__c",null);
        component.set("v.ObjDealRegistration.No_which_Service_option__c",null);
        component.set("v.ObjDealRegistration.If_a_competitor_which_one__c",null);
    },
    
    onSelectServiceOptionChange : function(component, event, helper){
        component.set("v.ObjDealRegistration.If_a_competitor_which_one__c",null);
    }
    
})