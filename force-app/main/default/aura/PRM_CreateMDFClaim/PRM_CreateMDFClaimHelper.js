({
    isValidate : function(component, event, helper)
    {
        
        var numberRegex = /^\d*\.?\d*$/;
        component.set("v.isExpenseError", false);
        component.set("v.isExpenseNumberValidationError", false);
        
        var submitREcord = true ; 
        var activityName =  component.get("v.mdfRequest.Activity_Type__c");
        //alert(activityName);
        helper.clearAllErrorMessages(component, event, activityName);
        
        
        if(activityName == 'E-marketing Digital Campaign' || activityName == 'Event - Customer Briefing Center (CBC) Visit' || activityName == 'Event – Webinar') {
            /*
            if((!component.find("Actual_New_Leads").get("v.value")) && (!component.find("Actual_Existing_Leads").get("v.value")) && (!component.find("Actual_Opportunity").get("v.value")) ){
                submitREcord = false ;
                $A.util.removeClass(component.find("fp_error"), "slds-hide");
                $A.util.addClass(component.find("fp_error"), "slds-show");
            } else {
                $A.util.removeClass(component.find("fp_error"), "slds-show");
                $A.util.addClass(component.find("fp_error"), "slds-hide");
            }*/
            
            if (component.find("Actual_New_Leads").get("v.value")) {
                if(!component.find("Actual_New_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_New_Leads").set("v.errors",null);
                }
            }
            
            if (component.find("Actual_Existing_Leads").get("v.value")) {
                if(!component.find("Actual_Existing_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Existing_Leads").set("v.errors",null);
                }
            }                
            
            if (component.find("Actual_Opportunity").get("v.value")){
                if(!component.find("Actual_Opportunity").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Opportunity").set("v.errors",null);
                }
            }
            
        } else if (activityName == 'E-marketing - Video') {
            /*if((!component.find("Actual_New_Leads").get("v.value")) && (!component.find("Actual_Existing_Leads").get("v.value")) && (!component.find("Actual_Interactions").get("v.value")) ){
                submitREcord = false ;
                $A.util.removeClass(component.find("fp_error"), "slds-hide");
                $A.util.addClass(component.find("fp_error"), "slds-show");
            } else {
                $A.util.removeClass(component.find("fp_error"), "slds-show");
                $A.util.addClass(component.find("fp_error"), "slds-hide");
            }*/
            
            if(component.find("Actual_New_Leads").get("v.value")) {
                if(!component.find("Actual_New_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_New_Leads").set("v.errors",null);
                }
            }
            
            if(component.find("Actual_Existing_Leads").get("v.value")) {
                if(!component.find("Actual_Existing_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Existing_Leads").set("v.errors",null);
                }    
            }
            
            if(component.find("Actual_Interactions").get("v.value")) {
                if(!component.find("Actual_Interactions").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Interactions").set("v.errors",null);
                }
            }
        } else if(activityName == 'Event - Campaign in a box' || activityName == 'Event - Tradeshow in a box including event' || activityName == 'Sales Program - Telesales/Telemarketing' || activityName == 'Event – Partner Seminar / Roadshow' || activityName == 'Event – Training') {
            /*if((!component.find("Actual_New_Leads").get("v.value")) && (!component.find("Actual_Existing_Leads").get("v.value")) && (!component.find("Actual_Opportunity").get("v.value")) && (!component.find("Actual_Interactions").get("v.value"))){
                submitREcord = false ;
                $A.util.removeClass(component.find("fp_error"), "slds-hide");
                $A.util.addClass(component.find("fp_error"), "slds-show");
            } else {
                $A.util.removeClass(component.find("fp_error"), "slds-show");
                $A.util.addClass(component.find("fp_error"), "slds-hide");
            }*/
            
            if(!component.find("Actual_New_Leads").get("v.value")){
                if(!component.find("Actual_New_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_New_Leads").set("v.errors",null);
                }
            }
            
            if(!component.find("Actual_Existing_Leads").get("v.value")) {
                if(!component.find("Actual_Existing_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Existing_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Existing_Leads").set("v.errors",null);
                }
            }
            
            if(!component.find("Actual_Interactions").get("v.value")) {
                if(!component.find("Actual_Interactions").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Interactions").set("v.errors",null);
                }
            }
            
            if(!component.find("Actual_Opportunity").get("v.value")) {
                if(!component.find("Actual_Opportunity").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Opportunity").set("v.errors",null);
                }
            }
        } else if (activityName == 'Sales Program - Incentive') {
            /*if((!component.find("Actual_New_Leads").get("v.value")) && (!component.find("Actual_Opportunity").get("v.value")) ){
                submitREcord = false ;
                $A.util.removeClass(component.find("fp_error"), "slds-hide");
                $A.util.addClass(component.find("fp_error"), "slds-show");
            } else {
                $A.util.removeClass(component.find("fp_error"), "slds-show");
                $A.util.addClass(component.find("fp_error"), "slds-hide");
            }*/
            
            if(!component.find("Actual_New_Leads").get("v.value")) {
                if(!component.find("Actual_New_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_New_Leads").set("v.errors",null);
                }
            }
            
            if(!component.find("Actual_Opportunity").get("v.value")) {
                if(!component.find("Actual_Opportunity").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Opportunity").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Opportunity").set("v.errors",null);
                }	
            }
        } else if (activityName == 'Search Engine Marketing/Social Media/PR') {
            /*if((!component.find("Actual_New_Leads").get("v.value")) && (!component.find("Actual_Interactions").get("v.value")) ){
                submitREcord = false ;
                $A.util.removeClass(component.find("fp_error"), "slds-hide");
                $A.util.addClass(component.find("fp_error"), "slds-show");
            } else {
                $A.util.removeClass(component.find("fp_error"), "slds-show");
                $A.util.addClass(component.find("fp_error"), "slds-hide");
            }*/
            
            if(!component.find("Actual_New_Leads").get("v.value")){
                if(!component.find("Actual_New_Leads").get("v.value").match(numberRegex))
                {
                    component.find("Actual_New_Leads").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_New_Leads").set("v.errors",null);
                }
            }
            
            if(!component.find("Actual_Interactions").get("v.value")){
                if(!component.find("Actual_Interactions").get("v.value").match(numberRegex))
                {
                    component.find("Actual_Interactions").set("v.errors",[{message:"Please Enter number only: "}]);
                    submitREcord = false ;
                } else {
                    component.find("Actual_Interactions").set("v.errors",null);
                }
            }
        }
        
        
        /* Start Validate Expense Table*/ 
        var RowItemList = component.get("v.expenseList");
        for (var indexVar = 0; indexVar < RowItemList.length; indexVar++) {
            //alert('----indexVar-'+indexVar);
            if($A.util.isEmpty(RowItemList[indexVar].Actual_Cost__c))
            {
                submitREcord = false ;
                component.set("v.isExpenseError", true);
            }
            if(!$A.util.isEmpty(RowItemList[indexVar].Actual_Cost__c))
            {
                var eCost = RowItemList[indexVar].Actual_Cost__c + '';
                //alert('-------------RowItemList[indexVar].Actual_Cost__c-----'+ eCost.match(numberRegex));
                if(!eCost.match(numberRegex))
                {
                    submitREcord = false ;
                    component.set("v.isExpenseNumberValidationError", true);
                }
            }
            
        }
        
        /* End Validate Expense Table */
        //alert('------submitREcord------'+submitREcord);
        return submitREcord;
    },
    
    clearAllErrorMessages : function(component, event, activityName) {   
        if(activityName == 'E-marketing Digital Campaign' || activityName == 'Event - Customer Briefing Center (CBC) Visit' || activityName == 'Event – Webinar') {
            
            //component.find("Actual_New_Leads").set("v.value",null);
            component.find("Actual_New_Leads").set("v.errors",null);
            //component.find("Actual_Existing_Leads").set("v.value",null);
            component.find("Actual_Existing_Leads").set("v.errors",null);
            //component.find("Actual_Opportunity").set("v.value",null);
            component.find("Actual_Opportunity").set("v.errors",null);
            
        } else if (activityName == 'E-marketing - Video') {
            
            //component.find("Actual_New_Leads").set("v.value",null);
            component.find("Actual_New_Leads").set("v.errors",null);
            //component.find("Actual_Existing_Leads").set("v.value",null);
            component.find("Actual_Existing_Leads").set("v.errors",null);
            //component.find("Actual_Interactions").set("v.value",null);
            component.find("Actual_Interactions").set("v.errors",null);
            
        } else if(activityName == 'Event - Campaign in a box' || activityName == 'Event - Tradeshow in a box including event' || activityName == 'Sales Program - Telesales/Telemarketing' || activityName == 'Event – Partner Seminar / Roadshow' || activityName == 'Event – Training') {
            
            //component.find("Actual_New_Leads").set("v.value",null);
            component.find("Actual_New_Leads").set("v.errors",null);
            //component.find("Actual_Existing_Leads").set("v.value",null);
            component.find("Actual_Existing_Leads").set("v.errors",null);
            //component.find("Actual_Interactions").set("v.value",null);
            component.find("Actual_Interactions").set("v.errors",null);
            //component.find("Actual_Opportunity").set("v.value",null);
            component.find("Actual_Opportunity").set("v.errors",null);
            
        } else if (activityName == 'Sales Program - Incentive') {
            
            //component.find("Actual_New_Leads").set("v.value",null);
            component.find("Actual_New_Leads").set("v.errors",null);
            //component.find("Actual_Opportunity").set("v.value",null);
            component.find("Actual_Opportunity").set("v.errors",null);
            
            
        } else if (activityName == 'Search Engine Marketing/Social Media/PR') {
            //component.find("Actual_New_Leads").set("v.value",null);
            component.find("Actual_New_Leads").set("v.errors",null);
            //component.find("Actual_Interactions").set("v.value",null);
            component.find("Actual_Interactions").set("v.errors",null);
            
            
        }
    }
})