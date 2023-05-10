({
    isValidate : function(component, event, helper)
    {
        var numberRegex = /^\d*\.?\d*$/;
        component.set("v.isExpenseError", false);
        component.set("v.isExpenseNumberValidationError", false);
        
        var submitREcord = true ; 
        if(!component.find("Activity_Name").get("v.value"))
        {
            component.find("Activity_Name").set("v.errors",[{message:"Please Enter Activity Name (max 72 characters): "}]);
            submitREcord = false ;
        }
        else{
            component.find("Activity_Name").set("v.errors",null);
        }
        
        if(component.get("v.activityValue") == '---None---')
        {
            component.find("selectActivity").set("v.errors",[{message:"Please select Activity Type: "}]);
            submitREcord = false ;
        }
        else{
            component.find("selectActivity").set("v.errors", null);
        }
        
        if(!component.find("Activity_Description").get("v.value"))
        {
            component.find("Activity_Description").set("v.errors",[{message:"Please Enter Activity Description: "}]);
            submitREcord = false ;
        }
        else{
            component.find("Activity_Description").set("v.errors",null);
        }
        
        
        if(!component.find("Activity_Date").get("v.value"))
        {
            component.find("Activity_Date").set("v.errors",[{message:"Please Select Activity Start Date: "}]);
            submitREcord = false ;
        }
        else
        {
            var date1 = new Date();
            var date2 = new Date(component.find("Activity_Date").get("v.value"));
            var timeDiff = Math.abs(date2.getTime() - date1.getTime());
            var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
            if(date2 < date1)
            {
                component.find("Activity_Date").set("v.errors",[{message:"Activity start date must be greater than Today, Please select a valid Start Date:"}]);
                submitREcord = false ;
            }
            else if(diffDays <= 30)
            {
                component.find("Activity_Date").set("v.errors",[{message:"Activity start date must be greater than 30 days, Please select a valid Start Date:"}]);
                submitREcord = false ;            
            }
                else
                    component.find("Activity_Date").set("v.errors",null);
        }
        
        if(!component.find("End_Date").get("v.value"))
        {
            component.find("End_Date").set("v.errors",[{message:"Please Select Activity End Date: "}]);
            submitREcord = false ;
        }
        else
        {
            var date1 = new Date(component.find("End_Date").get("v.value"));
            var date2 = new Date(component.find("Activity_Date").get("v.value"));
            
            if(date1 < date2)
            {
                component.find("End_Date").set("v.errors",[{message:"Activity End date must be greater than Start Date, Please select a valid Start Date:"}]);
                submitREcord = false ;
            }
            else   
                component.find("End_Date").set("v.errors",null);
        }
        
        if(component.get("v.activityValue") != '---None---') {
            
            if(component.find("selectActivity").get("v.value") == 'E-marketing Digital Campaign' || component.find("selectActivity").get("v.value") == 'Event - Customer Briefing Center (CBC) Visit' || component.find("selectActivity").get("v.value") == 'Event – Webinar') {
                
                /*
                if((!component.find("Estimated_New_Leads").get("v.value")) && (!component.find("Estimated_Existing_Leads").get("v.value")) && (!component.find("Estimated_Opportunity").get("v.value")) ){
                    submitREcord = false ;
                    $A.util.removeClass(component.find("fp_error"), "slds-hide");
                    $A.util.addClass(component.find("fp_error"), "slds-show");
                } else {
                    $A.util.removeClass(component.find("fp_error"), "slds-show");
                    $A.util.addClass(component.find("fp_error"), "slds-hide");
                }*/
                
                if (component.find("Estimated_New_Leads").get("v.value")) {
                    if(!component.find("Estimated_New_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_New_Leads").set("v.errors",null);
                    }
                }
                
                if (component.find("Estimated_Existing_Leads").get("v.value")) {
                    if(!component.find("Estimated_Existing_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Existing_Leads").set("v.errors",null);
                    }
                }                
                
                if (component.find("Estimated_Opportunity").get("v.value")){
                    if(!component.find("Estimated_Opportunity").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Opportunity").set("v.errors",null);
                    }
                }
                
            } else if (component.find("selectActivity").get("v.value") == 'E-marketing - Video') {
                /*
                if((!component.find("Estimated_New_Leads").get("v.value")) && (!component.find("Estimated_Existing_Leads").get("v.value")) && (!component.find("Estimated_Interactions").get("v.value")) ){
                    submitREcord = false ;
                    $A.util.removeClass(component.find("fp_error"), "slds-hide");
                    $A.util.addClass(component.find("fp_error"), "slds-show");
                } else {
                    $A.util.removeClass(component.find("fp_error"), "slds-show");
                    $A.util.addClass(component.find("fp_error"), "slds-hide");
                }*/
                
                if(component.find("Estimated_New_Leads").get("v.value")) {
                    if(!component.find("Estimated_New_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_New_Leads").set("v.errors",null);
                    }
                }
                
                if(component.find("Estimated_Existing_Leads").get("v.value")) {
                    if(!component.find("Estimated_Existing_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Existing_Leads").set("v.errors",null);
                    }    
                }
                
                if(component.find("Estimated_Interactions").get("v.value")) {
                    if(!component.find("Estimated_Interactions").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Interactions").set("v.errors",null);
                    }
                }
            } else if(component.find("selectActivity").get("v.value") == 'Event - Campaign in a box' || component.find("selectActivity").get("v.value") == 'Event - Tradeshow in a box including event' || component.find("selectActivity").get("v.value") == 'Sales Program - Telesales/Telemarketing' || component.find("selectActivity").get("v.value") == 'Event – Partner Seminar / Roadshow' || component.find("selectActivity").get("v.value") == 'Event – Training') {
                /*
                if((!component.find("Estimated_New_Leads").get("v.value")) && (!component.find("Estimated_Existing_Leads").get("v.value")) && (!component.find("Estimated_Opportunity").get("v.value")) && (!component.find("Estimated_Interactions").get("v.value"))){
                    submitREcord = false ;
                    $A.util.removeClass(component.find("fp_error"), "slds-hide");
                    $A.util.addClass(component.find("fp_error"), "slds-show");
                } else {
                    $A.util.removeClass(component.find("fp_error"), "slds-show");
                    $A.util.addClass(component.find("fp_error"), "slds-hide");
                }*/
                
                if(!component.find("Estimated_New_Leads").get("v.value")){
                    if(!component.find("Estimated_New_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_New_Leads").set("v.errors",null);
                    }
                }
                
                if(!component.find("Estimated_Existing_Leads").get("v.value")) {
                    if(!component.find("Estimated_Existing_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Existing_Leads").set("v.errors",null);
                    }
                }
                
                if(!component.find("Estimated_Interactions").get("v.value")) {
                    if(!component.find("Estimated_Interactions").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Interactions").set("v.errors",null);
                    }
                }
                
                if(!component.find("Estimated_Opportunity").get("v.value")) {
                    if(!component.find("Estimated_Opportunity").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Opportunity").set("v.errors",null);
                    }
                }
            } else if(component.find("selectActivity").get("v.value") == 'NCR defined Sales Program – Funded Head Count Distributor Only') {
                
                if((!component.find("Business_Plan").get("v.value"))){
                    component.find("Business_Plan").set("v.errors",[{message:"Please Enter value: "}]);
                    submitREcord = false ;
                    //$A.util.removeClass(component.find("fp_error"), "slds-show");
                    //$A.util.addClass(component.find("fp_error"), "slds-hide");
                } else {
                    component.find("Business_Plan").set("v.errors",null);
                    //$A.util.removeClass(component.find("fp_error"), "slds-show");
                    //$A.util.addClass(component.find("fp_error"), "slds-hide");
                }
            } else if (component.find("selectActivity").get("v.value") == 'Sales Program - Incentive') {
                /*
                if((!component.find("Estimated_New_Leads").get("v.value")) && (!component.find("Estimated_Opportunity").get("v.value")) ){
                    submitREcord = false ;
                    $A.util.removeClass(component.find("fp_error"), "slds-hide");
                    $A.util.addClass(component.find("fp_error"), "slds-show");
                } else {
                    $A.util.removeClass(component.find("fp_error"), "slds-show");
                    $A.util.addClass(component.find("fp_error"), "slds-hide");
                }*/
                
                if(!component.find("Estimated_New_Leads").get("v.value")) {
                    if(!component.find("Estimated_New_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_New_Leads").set("v.errors",null);
                    }
                }
                
                if(!component.find("Estimated_Opportunity").get("v.value")) {
                    if(!component.find("Estimated_Opportunity").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Opportunity").set("v.errors",null);
                    }	
                }
            } else if (component.find("selectActivity").get("v.value") == 'Search Engine Marketing/Social Media/PR') {
                /*
                if((!component.find("Estimated_New_Leads").get("v.value")) && (!component.find("Estimated_Interactions").get("v.value")) ){
                    submitREcord = false ;
                    $A.util.removeClass(component.find("fp_error"), "slds-hide");
                    $A.util.addClass(component.find("fp_error"), "slds-show");
                } else {
                    $A.util.removeClass(component.find("fp_error"), "slds-show");
                    $A.util.addClass(component.find("fp_error"), "slds-hide");
                }*/
                
                if(!component.find("Estimated_New_Leads").get("v.value")){
                    if(!component.find("Estimated_New_Leads").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_New_Leads").set("v.errors",null);
                    }
                }
                
                if(!component.find("Estimated_Interactions").get("v.value")){
                    if(!component.find("Estimated_Interactions").get("v.value").match(numberRegex))
                    {
                        component.find("Estimated_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                        submitREcord = false ;
                    } else {
                        component.find("Estimated_Interactions").set("v.errors",null);
                    }
                }
            }
        }
        
        /* Start Validate Expense Table*/ 
        
        var RowItemList = component.get("v.requestExpenseList");
        for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) 
        {
            if($A.util.isEmpty(RowItemList[indexVar].Actvity__c) || $A.util.isEmpty(RowItemList[indexVar].Estimated_Cost__c))
            {
                submitREcord = false ;
                component.set("v.isExpenseError", true);
            }
            
            if(!$A.util.isEmpty(RowItemList[indexVar].Estimated_Cost__c))
            {
                if(!RowItemList[indexVar].Estimated_Cost__c.match(numberRegex))
                {
                    submitREcord = false ;
                    component.set("v.isExpenseNumberValidationError", true);
                }
            }
        }
        
        /* End Validate Expense Table */
        return submitREcord;
    },
    saveRequest: function(component, event, helper) 
    {
        var action = component.get("c.saveMDFDetail"); 
        action.setParams({ "lstExpense" : component.get("v.requestExpenseList"), 
                          "objRequest" : component.get("v.request"), 
                          "strActivity" : component.find("selectActivity").get("v.value"), 
                          "strVendors" : component.find("selectVendor").get("v.value")});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                //component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue()}).fire();
                //component.getEvent("DetailRequestEvt").setParams({"mdfRecordId" : response.getReturnValue(),"backFrom" : "New"}).fire(); 
                
                $A.get("e.force:navigateToURL").setParams({ 
                    "url": "/mdf-detail?mid=" + response.getReturnValue()
                }).fire();
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                //alert(errors);
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        $A.enqueueAction(action);   
    },
    createObjectData: function(component, event) {
        // get the requestExpenseList from component and add(push) New Object to List  
        var RowItemList = component.get("v.requestExpenseList");
        
        RowItemList.push({
            'sobjectType': 'MDF_Expense_Detail__c',
            'Actvity__c': '',
            'Estimated_Cost__c': ''
        });
        // set the updated list to attribute (requestExpenseList) again    
        component.set("v.requestExpenseList", RowItemList);
        
        component.set("v.expenseListSize", RowItemList.length);
    },
    
    clearAllErrorMessages : function(component, event)
    {
        if(component.find("selectActivity").get("v.value") == 'E-marketing Digital Campaign' || component.find("selectActivity").get("v.value") == 'Event - Customer Briefing Center (CBC) Visit' || component.find("selectActivity").get("v.value") == 'Event – Webinar') {
            
            component.find("Estimated_New_Leads").set("v.value",null);
            component.find("Estimated_New_Leads").set("v.errors",null);
            component.find("Estimated_Existing_Leads").set("v.value",null);
            component.find("Estimated_Existing_Leads").set("v.errors",null);
            component.find("Estimated_Opportunity").set("v.value",null);
            component.find("Estimated_Opportunity").set("v.errors",null);
            
        } else if (component.find("selectActivity").get("v.value") == 'E-marketing - Video') {
            
            component.find("Estimated_New_Leads").set("v.value",null);
            component.find("Estimated_New_Leads").set("v.errors",null);
            component.find("Estimated_Existing_Leads").set("v.value",null);
            component.find("Estimated_Existing_Leads").set("v.errors",null);
            component.find("Estimated_Interactions").set("v.value",null);
            component.find("Estimated_Interactions").set("v.errors",null);
            
        } else if(component.find("selectActivity").get("v.value") == 'Event - Campaign in a box' || component.find("selectActivity").get("v.value") == 'Event - Tradeshow in a box including event' || component.find("selectActivity").get("v.value") == 'Sales Program - Telesales/Telemarketing' || component.find("selectActivity").get("v.value") == 'Event – Partner Seminar / Roadshow' || component.find("selectActivity").get("v.value") == 'Event – Training') {
            
            component.find("Estimated_New_Leads").set("v.value",null);
            component.find("Estimated_New_Leads").set("v.errors",null);
            component.find("Estimated_Existing_Leads").set("v.value",null);
            component.find("Estimated_Existing_Leads").set("v.errors",null);
            component.find("Estimated_Interactions").set("v.value",null);
            component.find("Estimated_Interactions").set("v.errors",null);
            component.find("Estimated_Opportunity").set("v.value",null);
            component.find("Estimated_Opportunity").set("v.errors",null);
            
        } else if(component.find("selectActivity").get("v.value") == 'NCR defined Sales Program – Funded Head Count Distributor Only') {
            
            component.find("Business_Plan").set("v.value",null);
            component.find("Business_Plan").set("v.errors",null);
            
            
        } else if (component.find("selectActivity").get("v.value") == 'Sales Program - Incentive') {
            
            component.find("Estimated_New_Leads").set("v.value",null);
            component.find("Estimated_New_Leads").set("v.errors",null);
            component.find("Estimated_Opportunity").set("v.value",null);
            component.find("Estimated_Opportunity").set("v.errors",null);
            
            
        } else if (component.find("selectActivity").get("v.value") == 'Search Engine Marketing/Social Media/PR') {
            component.find("Estimated_New_Leads").set("v.value",null);
            component.find("Estimated_New_Leads").set("v.errors",null);
            component.find("Estimated_Interactions").set("v.value",null);
            component.find("Estimated_Interactions").set("v.errors",null);
            
            
        }
        
    }
})