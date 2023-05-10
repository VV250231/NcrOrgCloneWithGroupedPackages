({
    // function call on component Load
    doInit: function(component, event, helper){
        console.log('==== DoInit ====');  	
        var checkDistributor = component.get("c.knowIfDistributorOrNot");
        
        checkDistributor.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                if(JSON.stringify(response.getReturnValue()) == 'true'){
                    component.set("v.isADisitributor", true);
                }else{
                    component.set("v.isADisitributor", false);
                }
            }                             
        });
        $A.enqueueAction(checkDistributor); 
        
        var action = component.get("c.getEditDetails");
        console.log('==== Deal Registration Id ==== : ',component.get("v.DealRegistrationId"));
        
        action.setParams({ "recId" : component.get("v.DealRegistrationId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                
                console.log("==== Deal Registration Info ==== ",response.getReturnValue());
                component.set("v.ObjDealRegistration", response.getReturnValue().objDR);
                component.set("v.dealRegistrationTypes", response.getReturnValue().dealRegistrationType);
                component.set("v.countries", response.getReturnValue().country);
                component.set("v.oppStageProbability", response.getReturnValue().probability);
                //component.set("v.primarySolutions", response.getReturnValue().primarySolution);
                //component.set("v.secondarySolutions", response.getReturnValue().secondarySolution);
                component.set("v.distributorList",response.getReturnValue().distributors);
                component.set("v.contactInCC",response.getReturnValue().contactNames);
                console.log("======",response.getReturnValue().contactNames);
                component.set("v.accountTheater",response.getReturnValue().accountTheater);
                component.set("v.accountRegion",response.getReturnValue().accountRegion);
                component.set("v.accountDetail",response.getReturnValue().actDetail);                
                component.set("v.partnerIndustryList",response.getReturnValue().partnerIndustry);
                component.set("v.selectedIndustry",response.getReturnValue().objDR.Partner_Industry__c);
                //component.set("v.extensionPeriod", response.getReturnValue().extensionPeriod);
                component.set("v.isFinance", response.getReturnValue().isFIN);                
                component.set("v.depnedentFieldMap",response.getReturnValue().mapPartnerIndustryToPS);
                component.set("v.depnedentFieldMap2",response.getReturnValue().mapPartnerIndustryToSS);
                
                //Adding Servicing Details               
                component.set("v.servicingAccounts", response.getReturnValue().servicingAccount);
                component.set("v.serviceOptions", response.getReturnValue().serviceOption);
                component.set("v.servicingThisAccounts", response.getReturnValue().servicingThisAccount);                
                component.set("v.serviceFieldFalg",response.getReturnValue().objDR.Are_you_servicing_this_Account__c);
                
                // Code added by deeksharth to Add TAM...
                console.log("TAM DATA",response.getReturnValue().getTAM);
                var result = response.getReturnValue().getTAM;
                var arrayMapKeys = [];
                for(var key in result){
                    arrayMapKeys.push({key: key, value: result[key]});
                }
                if(arrayMapKeys.length>0){
                    component.set("v.picklistValuesTAM",arrayMapKeys);
                }
                var pIndustry = response.getReturnValue().objDR.Partner_Industry__c;
                if(pIndustry =='Financial' && component.get("v.accountRegion")=='NAMER CFI'){
                    component.set("v.isTAMMandatory",true);
                }else{
                    component.set("v.isTAMMandatory",false);
                }
                
                if(response.getReturnValue().objDR.No_which_Service_option__c == 'Competitor'){
                    console.log("Competitor ++++++");
                    component.set("v.competitorFieldFalg",true);
                }
                
                // Let DOM state catch up.
                window.setTimeout(
                    $A.getCallback( function() {
                        // Now set our preferred value
                        //component.find("a_opt").set("v.value", accounts[4].Id);
                        component.find("Probability_Score").set("v.value",response.getReturnValue().objDR.Probability_Score__c);
                    }));
                
                if(response.getReturnValue().objDR.Distributor__c == null)
                    component.find("selectDistributor").set("v.value",'--None--');
                else 
                    component.find("selectDistributor").set("v.value",response.getReturnValue().objDR.Distributor__c);
                
                
                if(response.getReturnValue().partnerIndustry.length == 1)
                {
                    component.find("selectPartnerIndustry").set("v.value",response.getReturnValue().partnerIndustry[0]);
                }
                else
                {
                    if(response.getReturnValue().objDR.Partner_Industry__c == null)
                        component.find("selectPartnerIndustry").set("v.value",'--None--');
                    else
                    {
                        //component.find("selectPartnerIndustry").set("v.value",response.getReturnValue().objDR.Partner_Industry__c);
                        
                        var optPartnerIndustry = [];
                        var cPartnerIndustry = response.getReturnValue().partnerIndustry;
                        
                        for (var i = 0; i < cPartnerIndustry.length; i++) {
                            //alert(cPartnerIndustry[i] + '=====' +  response.getReturnValue().objDR.Partner_Industry__c);
                            if(cPartnerIndustry[i] === response.getReturnValue().objDR.Partner_Industry__c){
                                optPartnerIndustry.push({
                                    class: "optionClass",
                                    label: cPartnerIndustry[i],
                                    value: cPartnerIndustry[i],
                                    selected: "true" 
                                });
                            }
                            else{
                                optPartnerIndustry.push({
                                    class: "optionClass",
                                    label: cPartnerIndustry[i],
                                    value: cPartnerIndustry[i]
                                });
                            } 
                        }
                        
                        component.find("selectPartnerIndustry").set("v.options", optPartnerIndustry);
                    }
                    
                }
                
                if(response.getReturnValue().partnerIndustry.length == 1)
                {
                    var valPI = response.getReturnValue().partnerIndustry[0];
                    component.find("selectPartnerIndustry").set("v.value", valPI);
                    
                    var depnedentFieldMap = component.get("v.depnedentFieldMap");
                    var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
                    var ListOfDependentFields = depnedentFieldMap[valPI];
                    var ListOfDependentFields2 = depnedentFieldMap2[valPI];
                    
                    helper.fetchDepValues(component, ListOfDependentFields);  
                    
                    helper.fetchDepValues2(component, ListOfDependentFields2); 
                }
                else if(response.getReturnValue().partnerIndustry.length > 1 && response.getReturnValue().objDR.Partner_Industry__c == null)
                {
                    //component.find("selectPartnerIndustry").set("v.value",'--None--');
                    
                    component.set("v.primarySolutions", ['--None--']);
                    component.find("selectPrimarySolutions").set("v.value", '--None--');
                    
                    component.set("v.secondarySolutions", ['--None--']);
                    component.find("selectSecondarySolutions").set("v.value", '--None--');
                }
                    else if(response.getReturnValue().partnerIndustry.length > 1 && response.getReturnValue().objDR.Partner_Industry__c != null)
                    {
                        var valPI = response.getReturnValue().objDR.Partner_Industry__c;
                        //component.find("selectPartnerIndustry").set("v.value", valPI);
                        
                        var depnedentFieldMap = component.get("v.depnedentFieldMap");
                        var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
                        var ListOfDependentFields = depnedentFieldMap[valPI];
                        var ListOfDependentFields2 = depnedentFieldMap2[valPI];
                        
                        helper.fetchDepValues(component, ListOfDependentFields);  
                        
                        helper.fetchDepValues2(component, ListOfDependentFields2); 
                    }
                
                /* Start Set selected Contact Name IN CC */
                var optConCC = [];
                var conCCName = response.getReturnValue().contactNames;
                
                for (var i = 0; i < conCCName.length; i++) {
                    
                    if(response.getReturnValue().objDR.Contact_in_CC__c != null && conCCName[i] === response.getReturnValue().objDR.Contact_in_CC__r.Name){
                        
                        optConCC.push({
                            class: "optionClass",
                            label: conCCName[i],
                            value: conCCName[i],
                            selected: "true" 
                        });
                    }
                    else{
                        optConCC.push({
                            class: "optionClass",
                            label: conCCName[i],
                            value: conCCName[i]
                        });
                    } 
                }
                
                component.find("selectCC").set("v.options", optConCC);
                /* End Set selected Contact Name IN CC */
                
                /* Start Set selected extension Period */
                var optEP = [];
                var exName = response.getReturnValue().extensionPeriod;
                
                for (var i = 0; i < exName.length; i++) {
                    
                    if(exName[i] === response.getReturnValue().objDR.Extension_Period__c){
                        optEP.push({
                            class: "optionClass",
                            label: exName[i],
                            value: exName[i],
                            selected: "true" 
                        });
                    }
                    else{
                        optEP.push({
                            class: "optionClass",
                            label: exName[i],
                            value: exName[i]
                        });
                    } 
                }
                if(response.getReturnValue().objDR.Status__c === 'Approved')
                    //component.find("selectExtensionPeriod").set("v.options", optEP);
                    /* End Set selected extension Period */
                    
                    /* Start Set selected Registration_Type__c */
                    var optDrTypes = [];
                var drTypes = response.getReturnValue().dealRegistrationType;
                component.set("v.selectedDealRegType",response.getReturnValue().objDR.Special_Bid_Registration_Type__c);
                
                /* End Set selected Registration_Type__c */
                
                /* Start Set selected Country__c */
                var optCountry = [];
                var countryNames = response.getReturnValue().country;
                /*if (countryNames != undefined && countryNames.length > 0){
                    optCountry.push({
                        class: "optionClass",
                        label: "-- None --",
                        value: ""
                    });
                }*/
                for (var i = 0; i < countryNames.length; i++) {
                    
                    if(countryNames[i] === response.getReturnValue().objDR.Country__c){
                        optCountry.push({
                            class: "optionClass",
                            label: countryNames[i],
                            value: countryNames[i],
                            selected: "true" 
                        });
                    }
                    else{
                        optCountry.push({
                            class: "optionClass",
                            label: countryNames[i],
                            value: countryNames[i]
                        });
                    } 
                }
                component.find("selectCountries").set("v.options", optCountry);
                /* End Set selected Country__c*/
                
                /* Start Set selected Primary_Solution__c */
                var optPS = [];
                var ps = component.get("v.primarySolutions");
                
                /*if (ps != undefined && ps.length > 0){
                    optPS.push({
                        class: "optionClass",
                        label: "-- None --",
                        value: ""
                    });
                }*/
                for (var i = 0; i < ps.length; i++) {
                    
                    if(ps[i] === response.getReturnValue().objDR.Primary_Solution__c){
                        optPS.push({
                            class: "optionClass",
                            label: ps[i],
                            value: ps[i],
                            selected: "true" 
                        });
                        
                    }
                    else{
                        optPS.push({
                            class: "optionClass",
                            label: ps[i],
                            value: ps[i]
                        });
                        
                    } 
                }
                
                component.find("selectPrimarySolutions").set("v.options", optPS);
                /* End Set selected Primary_Solution__c */
                
                /* Start Set selected Secondary_Solution__c */
                var optSS = [];
                var ss = component.get("v.secondarySolutions");
                /*if (ss != undefined && ss.length > 0){
                    optSS.push({
                        class: "optionClass",
                        label: "-- None --",
                        value: ""
                    });
                }*/
                for (var i = 0; i < ss.length; i++) {
                    
                    if(ss[i] === response.getReturnValue().objDR.Secondary_Solution__c){
                        optSS.push({
                            class: "optionClass",
                            label: ss[i],
                            value: ss[i],
                            selected: "true" 
                        });
                    }
                    else{
                        optSS.push({
                            class: "optionClass",
                            label: ss[i],
                            value: ss[i]
                        });
                    } 
                }
                component.find("selectSecondarySolutions").set("v.options", optSS);
                /* End Set selected Secondary_Solution__c*/
                
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
            //alert(JSON.stringify( response.getReturnValue()));
            if (state === "SUCCESS") {
                component.set("v.projectedOpportunityValue", result[0].Projected_Opportunity_Value__c );  
                component.set("v.dealWithMonthlyRecurringRev", result[0].Deal_with_Monthly_Recurring_Rev__c);  
                //  alert(component.get("v.accountTheater"));
                if(helper.isValidate(component, event, helper))
                {
                    
                    var action = component.get("c.saveDealRegistration");
                    var extensionValue = null;
                    var var_county;
                    if (component.find("selectPartnerIndustry").get("v.value") == 'Hospitality') {
                        var_county = component.find("county").get("v.value");
                    }
                    
                    /*if(component.get("v.ObjDealRegistration").Status__c === 'Approved')
            {
                extensionValue = component.find("selectExtensionPeriod").get("v.value");
               
            }*/ 
                    component.get("v.ObjDealRegistration").Probability_Score__c = component.find("Probability_Score").get("v.value");
                    action.setParams({ "objDR" : component.get("v.ObjDealRegistration"), 
                                      "dealRegistrationType" : component.find("selectDealRegistrationTypes").get("v.value"), 
                                      "country" : component.find("selectCountries").get("v.value"),
                                      "primarySolution" : component.find("selectPrimarySolutions").get("v.value"), 
                                      "secondarySolution" : component.find("selectSecondarySolutions").get("v.value"),
                                      "extValue" : '--None--',
                                      "distributor" : component.find("selectDistributor").get("v.value"),
                                      "partnerIndustry" : component.find("selectPartnerIndustry").get("v.value"),
                                      "contactCC": component.find("selectCC").get("v.value"),
                                      "county": var_county
                                     });
                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            //component.set("v.drId", response.getReturnValue());
                            console.log(response.getReturnValue());
                            component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue(),"backFrom" : "Edit"}).fire();
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
    
    openDetail : function(component, event, helper) {
        var evt = component.getEvent("EditCancelRequestEvt");
        evt.setParam("IsDistributor", component.get("v.isADisitributor"));
        evt.fire();
    },
    onControllerFieldChange: function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); // get selected controller field value
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        var depnedentFieldMap2 = component.get("v.depnedentFieldMap2");
        var optSolutions = [];
        component.find("selectPrimarySolutions").set("v.options", optSolutions);
        component.find("selectSecondarySolutions").set("v.options", optSolutions);
        
        if (controllerValueKey != '--None--') 
        {
            //code added by deeksharth for adding TAM field in IPT..
            if(controllerValueKey =='Financial' && component.get("v.accountRegion")=='NAMER CFI'){
                component.set("v.isTAMMandatory", true);
            }else{
                component.set("v.isTAMMandatory",false);
                if( component.find("addTAM")){
                    component.find("addTAM").set("v.errors",null);
                }
            }
            //Code end here..
            component.find("selectPrimarySolutions").set("v.value", '--None--');
            component.find("selectSecondarySolutions").set("v.value", '--None--');
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