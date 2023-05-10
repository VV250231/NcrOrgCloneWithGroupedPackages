({
    doInit : function(component, event, helper) {        
        var leaddata=component.get('v.caseRecord.Chat_User_Email__c');
        if(leaddata != null){
            var action=component.get('c.searchExistingLead');
            action.setParams({
                leademail:leaddata,
            });
            var contactaction=component.get('c.searchExistingContact');
            contactaction.setParams({
                contactemail:leaddata,
            });
            console.log('=----leaddata-------------------------',leaddata);
            action.setCallback(this,function(response){
                var state= response.getState();
                if(state==='SUCCESS'){
                    var responeValues=response.getReturnValue();   
                    console.log('=-----------------------------',responeValues);
                    if (responeValues.length >0){
                        component.set('v.hasError',true);
                        component.set("v.hasErrorLead", true);
                        component.set("v.hasLeadErrorMsg", true);
                        component.set("v.hasLeadError", true);
                        let button = component.find('Confirm');
                        button.set('v.disabled',true); 
                    }
                }
                else{
                    var errors= response.getError();
                    console.log ('Errors',errors);
                }
            },'ALL');
            contactaction.setCallback(this,function(response){
                var state= response.getState();
                if(state==='SUCCESS'){
                    var responeValues=response.getReturnValue();   
                    console.log('@@@@Contact=-----------------------------',responeValues.length);
                    if (responeValues.length >0){
                        component.set('v.hasError',true);
                        component.set("v.hasErrorCon", true);
                        component.set("v.hasContactErrorMsg", true);                        
                        component.set("v.hasContactError", true);
                        let button = component.find('Confirm');
                        button.set('v.disabled',true); 
                    }
                }
                else{
                    var errors= response.getError();
                    console.log ('Errors',errors);
                }
            },'ALL');
            $A.enqueueAction(action);
            $A.enqueueAction(contactaction);
        }
    },
    
    //Confirm 
    handleConfirm : function(component, event, helper) {
        //Find lightning flow from component
        component.get("v.assignmentRuleCheck");
        var flow = component.find("CreateLeadFlow");
        
        //var caseRecord = component.get("v.caseRecord");
        
        console.log('@@@'+component.get('v.caseRecord.Origin'));
        //Put input variable values 
        var Validerrors ="";        
        if(component.get("v.caseRecord.Chat_User_Country__c") == null){
            Validerrors+="Country, ";
        }
        if(component.get("v.caseRecord.Chat_User_Company__c") == null){
            Validerrors+="Company, ";
        }
        if(component.get("v.caseRecord.Chat_User_Email__c") == null){
            Validerrors+="Email, ";
        }
        //if(component.get("v.caseRecord.Chat_User_First_Name__c") == null){
        //  Validerrors+="First Name, ";
        //}
        if(component.get("v.caseRecord.Chat_User_Industry__c") == null){
            Validerrors+="Industry, ";
        }
        if(component.get("v.caseRecord.Chat_User_Last_Name__c") == null){
            Validerrors+="Last Name, ";
        }
        if(component.get("v.caseRecord.Chat_User_Source__c") == null){
            Validerrors+="Lead Source, ";
        }
        if(component.get("v.caseRecord.Chat_User_Type__c") == null){
            Validerrors+="Lead Type ";
        }
        if(component.get("v.caseRecord.Origin") == null){
            Validerrors+="Origin, ";
        }
        if(Validerrors != ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Error- In order to convert the case to a lead, please ensure you have the following fields populated - ",
                message: Validerrors,
                type: "error"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire(); 
        }
        var inputVariables = [
            {
                name : "caseid",
                type : "String",
                value : component.get("v.recordId")
            },
            {
                name : "CaseOrigin",
                type : "String",
                value : component.get("v.caseRecord.Origin")
            },
            {
                name : "ChatUserCompany",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Company__c")
            },
            {
                name : "ChatUserCountry",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Country__c")
            },
            {
                name : "ChatUserEmail",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Email__c")
            },
            {
                name : "ChatUserFirstName",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_First_Name__c") == null ? " " : component.get("v.caseRecord.Chat_User_First_Name__c")
            },
            {
                name : "ChatUserPhoneNo",
                type : "String",
                // value : component.get("v.caseRecord.Chat_User_Phone__c")
                value : component.get("v.caseRecord.Chat_User_Phone__c") == null ? " " : component.get("v.caseRecord.Chat_User_Phone__c")
                
            },    
            {
                name : "ChatUserIndustry",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Industry__c")
            },
            {
                name : "ChatUserLastName",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Last_Name__c")
            },
            {
                name : "ChatUserSource",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Source__c")
            },{
                name : "ChatUserType",
                type : "String",
                value : component.get("v.caseRecord.Chat_User_Type__c")
            },
            {
                name : "CampaignName",
                type : "String",
                //value : component.get("v.caseRecord.Campaign_Name__c")
                value : component.get("v.caseRecord.Campaign_Name__c") == null ? " " : component.get("v.caseRecord.Campaign_Name__c")
            },
            {
                name : "CampaignCode",
                type : "String",
                //value : component.get("v.caseRecord.Campaign_Code__c")
                value : component.get("v.caseRecord.Campaign_Code__c") == null ? " " : component.get("v.caseRecord.Campaign_Code__c")
            },
            {
                name : "CampaignType",
                type : "String",
                //value : component.get("v.caseRecord.Campaign_Type__c")
                value : component.get("v.caseRecord.Campaign_Type__c") == null ? " " : component.get("v.caseRecord.Campaign_Type__c")
            },
            {
                name : "CampaignStatus",
                type : "String",
                // value : component.get("v.caseRecord.Campaign_Status__c")
                value : component.get("v.caseRecord.Campaign_Status__c") == null ? " " : component.get("v.caseRecord.Campaign_Status__c")
            },
            {
                name : "CampaignStartDate",
                type : "String",
                value : component.get("v.caseRecord.Campaign_Start_Date__c") == null ? " " : component.get("v.caseRecord.Campaign_Start_Date__c")
                
                
            },
            {
                name : "CampaignEndDate",
                type : "String",
                value : component.get("v.caseRecord.Campaign_End_Date__c") == null ? " " : component.get("v.caseRecord.Campaign_End_Date__c")
            },
            
            {
                name : "FormPosition",
                type : "String",
                value : component.get("v.caseRecord.Position__c") == null ? " " : component.get("v.caseRecord.Position__c")
                
            },
            {
                name : "FormNumberOfLocation",
                type : "String",
                // value : component.get("v.caseRecord.Number_of_Locations__c")
                value : component.get("v.caseRecord.Number_of_Locations__c") == null ? " " : component.get("v.caseRecord.Number_of_Locations__c")
                
            },
            {
                name : "FormYearInBusiness",
                type : "String",
                //  value : component.get("v.caseRecord.Years_In_Business__c")
                value : component.get("v.caseRecord.Years_In_Business__c") == null ? " " : component.get("v.caseRecord.Years_In_Business__c")
                
            },
            {
                name : "Timing",
                type : "String",
                // value : component.get("v.caseRecord.Timing__c")
                value : component.get("v.caseRecord.Timing__c") == null ? " " : component.get("v.caseRecord.Timing__c")
                
            },
            {
                name : "FormCompanyAnnualSales",
                type : "String",
                //   value : component.get("v.caseRecord.Company_Annual_Sales__c")
                value : component.get("v.caseRecord.Company_Annual_Sales__c") == null ? " " : component.get("v.caseRecord.Company_Annual_Sales__c")
                
            },
            {
                name : "FormNoOfEmployees",
                type : "String",
                //  value : component.get("v.caseRecord.Number_of_Employees__c")
                value : component.get("v.caseRecord.Number_of_Employees__c") == null ? " " : component.get("v.caseRecord.Number_of_Employees__c")
                
            },
            {
                name :"caseCreatedDate",
                type :"String",
                value : component.get("v.caseRecord.CreatedDate__c")== null ? "" : component.get("v.caseRecord.CreatedDate__c")
            },
            {
                name : "State_Province",
                type : "String",
                //  value : component.get("v.caseRecord.State_Province__c")
                value : component.get("v.caseRecord.State_Province__c") == null ? " " : component.get("v.caseRecord.State_Province__c")
                
            },
            {
                name : "ZiporPostalCode",
                type : "String",
                //  value : component.get("v.caseRecord.Zip_Or_Postal_Code__c") == null ? " " : component.get("v.caseRecord.Zip_Or_Postal_Code__c")
                value : component.get("v.caseRecord.Zip_Or_Postal_Code__c") == null ? " " : component.get("v.caseRecord.Zip_Or_Postal_Code__c")
                
            },
            {
                name : "City",
                type : "String",
                // value : component.get("v.caseRecord.City__c")
                value : component.get("v.caseRecord.City__c") == null ? " " : component.get("v.caseRecord.City__c")
                
            },
            {
                name : "Title",
                type : "String",
                value : component.get("v.caseRecord.Title__c") == null ? " " : component.get("v.caseRecord.Title__c")
            },
            {
                name : "BusinessFunction",
                type : "String",
                value : component.get("v.caseRecord.Business_Function__c") == null ? " " : component.get("v.caseRecord.Business_Function__c")
            },{
                name : "AgentNotes",
                type : "String",
                value : component.get("v.caseRecord.Agent_Notes__c") == null ? " " : component.get("v.caseRecord.Agent_Notes__c")
            },
            //New Changes Refgarding Mrketo Related 
            // Done By Yogesh Sigh
            // Start Changes 
            {
                name :"mkto_AcquisitionDate",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Acquisition_Date__c")== null ? " " : component.get("v.caseRecord.mkto71_Acquisition_Date__c")
                
            },
            {
                name :"mkto_AcquisitionProgram",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Acquisition_Program__c")== null ? " " : component.get("v.caseRecord.mkto71_Acquisition_Program__c")
                
            },
            {
                name :"mkto_AcquisitionProgramId",
                type : "Number",
                value : component.get("v.caseRecord.mkto71_Acquisition_Program_Id__c")
            },
            {
                name :"mkto_Score",
                type : "Number",
                value : component.get("v.caseRecord.mkto71_Lead_Score__c")
            },
            {
                name :"mkto_InferredCity",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_City__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_City__c")
                
            },
            {
                name :"mkto_InferedCompany",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_Company__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_Company__c")
                
            },
            {
                name :"mkto_InferedCountry",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_Country__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_Country__c")
                
            },
            {
                name :"mkto_InferedMatroPolatianArea",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_Metropolitan_Area__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_Metropolitan_Area__c")
                
            },
            {
                name :"mkto_InferedPhoneArea",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_Phone_Area_Code__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_Phone_Area_Code__c")
                
            },
            {
                name :"mkto_InferredPostalCode",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_Postal_Code__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_Postal_Code__c")
                
            },
            {
                name :"mkto_InferredStateRegion",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Inferred_State_Region__c")== null ? " " : component.get("v.caseRecord.mkto71_Inferred_State_Region__c")
                
            },
            {
                name :"mkto_OriginalReferrer",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Original_Referrer__c")== null ? " " : component.get("v.caseRecord.mkto71_Original_Referrer__c")
                
            },
            {
                name :"mkto_OriginalSearchEngine",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Original_Search_Engine__c")== null ? " " : component.get("v.caseRecord.mkto71_Original_Search_Engine__c")
                
            },
            {
                name :"mkto_OriginalSearchPhrase",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Original_Search_Phrase__c")== null ? " " : component.get("v.caseRecord.mkto71_Original_Search_Phrase__c")
                
            },
            {
                name :"mkto_OriginalSourceInfo",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Original_Source_Info__c")== null ? " " : component.get("v.caseRecord.mkto71_Original_Source_Info__c")
                
            },
            {
                name :"mkto_OriginalSourceType",
                type : "String",
                value : component.get("v.caseRecord.mkto71_Original_Source_Type__c")== null ? " " : component.get("v.caseRecord.mkto71_Original_Source_Type__c")
                
            },
            {
                name : "SubIndustry",
                type : "String",
                value : component.get("v.caseRecord.Sub_Industry__c") == null ? " " : component.get("v.caseRecord.Sub_Industry__c")
                
            },
            {
                name : "mkto_GCLID",
                type : "String",
                value : component.get("v.caseRecord.GCLID__c") == null ? " " : component.get("v.caseRecord.GCLID__c")
            },
            //Mapping case's lead assignment rule checkbox to lead's checkbox
            {
                name: "LeadAssignmentRule",
                type: "Boolean",
                value: component.get("v.assignmentRuleCheck") 
            },
            //End Changes
            
            //Sub Lead Source field added as a part of story 2293 by Stuti
            {
                name : "SubLeadSource",
                type : "String",
                value : component.get("v.caseRecord.Sub_Lead_Source__c") == null ? " " : component.get("v.caseRecord.Sub_Lead_Source__c")
            }
            //End
            
        ];
        //Reference flow's Unique Name
        if(Validerrors == ""){
            flow.startFlow("Case_to_Lead_Converison", inputVariables);
        }
        
    },
    
    //Close the quick action
    handleClose : function(component, event, helper) {
        // $A.get("e.force:closeQuickAction").fire();
        var value = component.get("v.showModel")
        var eve = $A.get("e.c:EventCaseToLeadConversion");
        eve.setParams({
            "handleCancelButton" : value
        });  
        eve.fire();
    },
    closeModal:function(component,event,helper){  
        var showModal = component.get('v.showModal');
        component.set('v.showModal', !showModal);
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open'); 
    },
    
    //Flow Status Change
    statusChange : function (component, event, helper) {
        //Check Flow Status
        if (event.getParam('status') === "FINISHED_SCREEN" || event.getParam('status') === "FINISHED") {
            let button = component.find('Confirm');
            button.set('v.disabled',true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: "Success!",
                message: "Lead created successfully!",
                type: "success"
            });
            toastEvent.fire();
            $A.get("e.force:closeQuickAction").fire();
            $A.get('e.force:refreshView').fire();
        } 
        else if (event.getParam('status') === "ERROR") {
            let button = component.find('Confirm');
            button.set('v.disabled',true);
            //component.set("v.hasError", true);
            
        }
    }
})