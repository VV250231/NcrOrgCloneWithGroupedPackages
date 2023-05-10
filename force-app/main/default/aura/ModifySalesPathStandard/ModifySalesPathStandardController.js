({
    doInit : function(component, event, helper) {
        //helper.getpicklistvalueDR(component); 
        //alert('hey');
        
        component.set("v.showModalA", 'N');
        component.set("v.showModalB", 'N');
        component.set("v.confirmCLM", false);
        component.set("v.confirmQuote", false);
        component.set("v.callChild", false);
        helper.getDisableCheck(component);
        helper.getPicklistOptions(component);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getTypeFromOpp");
        var Object=[];
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var opp = response.getReturnValue();                
                component.set("v.opportunity", opp);
                //alert(JSON.stringify(component.get("v.opportunity")));
                component.set("v.QuoteConfirmation", "NONE");
                component.set("v.stage", opp.StageName);
                component.set("v.num",0);
                component.set("v.IsCPQ",opp.CPQ__c);
                //added Industry attribute as the part of CSI_SF-424 by Stuti-->
                component.set("v.OppIndustry",opp.Industry__c);
                component.set("v.isCATM",opp.CATM_Record__c);
            }
 
        });
        
        $A.enqueueAction(action);
        
    },
    reasonChanged : function(component, event){
        var action = component.get("c.contractDateAvl");
        var recordId = component.get("v.recordId");
        
        
        
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('}}}'+response.getReturnValue());
                if(response.getReturnValue()!=null ){
                    console.log('+==='+event);
                    console.log('==+'+component.get('v.opportunity.Reasons_for_no_Payment_Processing__c'));
                    console.log('_____'+component.get('v.opportunity.Payments_Contract_End_Date__c'));
                    
                    // component.set("v.ContractDateReq", false);
                    component.set("v.opportunity.Payments_Contract_End_Date__c", response.getReturnValue());
                }
                
                
            }
            
        });
        if(component.get('v.opportunity.Reasons_for_no_Payment_Processing__c').indexOf('Existing Contract (WP/NMS)')!=-1 || component.get('v.opportunity.Reasons_for_no_Payment_Processing__c').indexOf('Existing Contract (Other)')!=-1){
            console.log('yyyyyy');
            component.set("v.ContractDateReq", true);
        }
        else{
            component.set("v.ContractDateReq", false);
        }
        
        
        $A.enqueueAction(action);
    },
    redirect :  function(component, event, helper) {
        //resetting the values
        //component.set("v.QuoteConfirmation", "NONE");
        //component.set("v.confirmQuote", false);
        //component.find("qtcnf").set("v.value","NONE");
        
        component.set("v.showModalA", 'N');
        component.set("v.showModalB", 'N');
        
        
    },  
    handleNotifyEvent :  function(component, event, helper) {
        //Do what ever you want to do with changed Picklist
        var val=component.get("v.opportunity.Lose_to_a_Competitor__c");
        
        if(val=='Yes'){
            
            component.set("v.PrimaryLossReason",component.get("v.fieldMapOptionsYes"))  ;
        }else{
            component.set("v.PrimaryLossReason",component.get("v.fieldMapOptionsNo")) ;   
        }
        component.set("v.randomChange",component.get("v.randomChange")+1);
        
        
    } ,
    
    isDBCall : function(component, event, helper) {
        var n=component.get("v.num");
        component.set("v.num",n+1);
    }  ,
    
    refreshStage : function(component, event, helper) {
        //alert("hi");
        var recordId = component.get("v.recordId");
        var n=component.get("v.num"); 
        
        if(n>8){
            component.set("v.num", 6);
            var action = component.get("c.getTypeFromOpp");
            action.setParams({
                recordId: recordId
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    var opp = response.getReturnValue();
                    var stg=component.get("v.stage");                    
                    if(stg!=opp.StageName){
                        // old satge help us to bypass Query in some cases.                        
                        component.set("v.stage", opp.StageName);                     
                        
                    }
                    
                }
                
            });
            
            $A.enqueueAction(action);
        }                
    },
    redirect_quby :  function(component, event, helper) {
        /*var urlEvent = $A.get( "e.force:navigateToURL");
        urlEvent.setParams( { "url" : "/apex/Quote_Builder_Redirect?oppno="+component.get("v.recordId")}); 
        urlEvent.fire();*/
        var url1="/apex/qb_landing_page?oppno="+component.get("v.recordId");
        window.open(url1,'_blank');    
    },
    updateOpportunityRecordNew:function(component, event, helper)
    {	
        if(component.get("v.confirmQuote") && (component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")=='NONE' || component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")==null) && component.get("v.confirmCLM") && !component.get("v.opportunity.CLM_Sales_Acknowledgment__c")){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "mode":"sticky",
                "type":"error",
                "message": "Please fill all the required fields!"
            })
            toastEvent.fire();
        }
        else if(component.get("v.confirmCLM") && !component.get("v.opportunity.CLM_Sales_Acknowledgment__c")){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "mode":"sticky",
                "type":"error",
                "message": "Please check the checkbox to acknowledge!"
            })
            toastEvent.fire();
        }
            else if(component.get("v.confirmQuote") && (component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")=='NONE' || component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")==null)){            
                //component.find("qtcnf").set("v.errors", [{message:"Please Select YES OR NO"}]);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "mode":"sticky",
                    "type":"error",
                    "message": "Please Select YES OR NO For is Quote Created Other System."
                })
                toastEvent.fire();
                
            }else{
                var action = component.get("c.UpdateOpportunityRecordNewCB"); 
                
                action.setParams({
                    opp:component.get("v.opportunity"),
                    isClosed:true
                    
                });  
                // alert(JSON.stringify(component.get("v.opportunity")));
                action.setCallback(this, function(response){
                    //resetting the values
                    //component.set("v.QuoteConfirmation", "NONE");
                    //component.set("v.confirmQuote", false);
                    //component.find("qtcnf").set("v.value","NONE");
                    
                    var state = response.getReturnValue();
                    if (state == "Success") {
                        component.set("v.showModalA", 'N');
                        component.set("v.showModalB", 'N');
                        $A.get('e.force:refreshView').fire();                
                    }else{
                        component.set("v.showModalA", 'N');
                        component.set("v.showModalB", 'N');                   
                        var toastEvent = $A.get("e.force:showToast");
                        //console.log(state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[0]);
                        if (state.length>6) {
                            toastEvent.setParams({
                                "title": "Error!",
                                "mode":"sticky",
                                "type":"error",
                                "message": state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[1]
                            })
                            toastEvent.fire();
                        }
                        else {
                            toastEvent.setParams({
                                "title": "Error!",
                                "mode":"sticky",
                                "type":"error",
                                "message": "Unknown Error occured, Please retry and contact Admin if issue still persist"
                            })
                            toastEvent.fire();  
                        }
                    }
                    
                });        
                $A.enqueueAction(action); 
            }
        
        
    },
    updateOpportunityRecordNew1:function(component, event, helper)
    {	
        if(component.get("v.confirmQuote") && (component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")=='NONE' || component.get("v.opportunity.IsQuoteCreatedInOtherSystem__c")==null)){            
            //component.find("qtcnf").set("v.errors", [{message:"Please Select YES OR NO"}]);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "mode":"sticky",
                "type":"error",
                "message": "Please Select YES OR NO For is Quote Created Other System."
            })
            toastEvent.fire();
        }else{
            var action = component.get("c.UpdateOpportunityRecordNewCL");
            var val2=component.get("v.opportunity.Primary_Loss_Reason__c")
            if(val2!='Price Sensitivity'){
                component.set("v.opportunity.How_important_was_Price_in_the_Decision__c",'') ;
                component.set("v.opportunity.What_was_the_closest_competitor_price__c",'') ;
            }
            action.setParams({
                opp:component.get("v.opportunity")               
                
            });        
            action.setCallback(this, function(response){
                //resetting the values
                //component.set("v.QuoteConfirmation", "NONE");
                //component.set("v.confirmQuote", false);
                //component.find("qtcnf").set("v.value","NONE");
                
                var state = response.getReturnValue();
                if (state == "Success") {
                    component.set("v.showModalA", 'N');
                    component.set("v.showModalB", 'N');
                    $A.get('e.force:refreshView').fire();                
                }else{
                    component.set("v.showModalA", 'Y');
                    component.set("v.showModalB", 'N');                   
                    var toastEvent = $A.get("e.force:showToast");
                    console.log(state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[0]);
                    if (state.length>6) {
                        toastEvent.setParams({
                            "title": "Error!",
                            "mode":"sticky",
                            "type":"error",
                            "message": state.split("FIELD_CUSTOM_VALIDATION_EXCEPTION,")[1]
                        })
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            "title": "Error!",
                            "mode":"sticky",
                            "type":"error",
                            "message": "Unknown Error occured, Please retry and contact Admin if issue still persist"
                        })
                        toastEvent.fire();  
                    }
                }
                
            });        
            $A.enqueueAction(action); 
        }
        
        
    },
    showToastHandle : function(component, event, helper) {
        //alert(); 
        //if(event.getParam("message").toLowerCase().includes("system other than quotebuilder")){
        //alert(event.getParam("message").toLowerCase());
        if( event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("clm steps") != -1 && (component.get("v.OppIndustry")!='Payments & Network' || !component.get("v.isCATM"))){
            component.set("v.confirmCLM", true);
            component.set("v.showModalA",'Y'); 
            //alert();
            component.set("v.StageToast", 'Closed/Booked');
            
        }
        if( event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("system other than quotebuilder") != -1 ){
            
            component.set("v.showModalA",'Y'); 
            component.set("v.confirmQuote", true);
            component.set("v.StageToast", 'Closed/Booked');
            if(!component.get("v.opportunity.CLM_Sales_Acknowledgment__c") && (component.get("v.OppIndustry")!='Payments & Network' || !component.get("v.isCATM"))){
                component.set("v.confirmCLM", true);
            }else{
                component.set("v.confirmCLM", false);
            }
        }        
        //if(event.getParam("message").toLowerCase().includes("required field missing for closed booked")){
        if(event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("required field missing for closed booked") != -1 || event.getParam("message").toLowerCase().indexOf("required field 'key criteria' missing for closed booked") != -1){
            component.set("v.showModalA",'Y'); 
            component.set("v.StageToast", 'Closed/Booked');
            
        } 
        //if(event.getParam("message").toLowerCase().includes("required field missing for closed lost")){
        if(event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("required field missing for closed lost:") != -1 ){
            component.set("v.StageToast", 'Closed/Lost');            
            component.set("v.showModalB",'Y');    
        } 
        
        if(event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("reasons for not adding hwm,swm,ts or ps: you have not selected any hwm, swm, ts or ps. please provide reasons")!=-1){
            component.set("v.StageToast", 'Closed/Booked');
            component.set('v.ShowReasonCode',true); 
            //resetting value since component not updated some times
            component.set("v.opportunity.You_have_not_selected_any_TS_HWM_or_SW__c",null);
            component.set("v.showModalA",'Y');  
        }
        console.log('____event.getParam("message").toLowerCase()::'+event.getParam("message").toLowerCase());
        if(event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("reasons for not selecting ncr payments: you have not selected any ncr payment processing. please provide reasons")!=-1){
            component.set("v.StageToast", 'Closed/Booked');
            component.set('v.ShowPaymentReasonCode',true); 
            //resetting value since component not updated some times
            component.set("v.opportunity.Reasons_for_no_Payment_Processing__c",null);
            component.set("v.showModalA",'Y');  
        }
        if(event.getParam("message")!=null && event.getParam("message").toLowerCase().indexOf("payments contract end date: contract end date is required")!=-1){
            component.set("v.StageToast", 'Closed/Booked');
            component.set('v.ContractDateReq',true); 
            component.set("v.showModalA",'Y');  
        }
    },
    getQuoteConfirm : function(component, event, helper)
    {  
        console.log(component.find("qtcnf").get("v.options"));
        var QuoteConfirmation=component.find("qtcnf").get("v.value");
        console.log(QuoteConfirmation);
        component.set("v.QuoteConfirmation", QuoteConfirmation); 
    },
    openModal:function(component, event, helper) {
        var changeType = event.getParams().changeType;
        
        if (changeType === "CHANGED" && (('StageName' in event.getParams().changedFields))) {
            var newStageName = event.getParams().changedFields.StageName.value;
            var oldStageName = event.getParams().changedFields.StageName.oldValue;
            var clmCheck = component.get("v.opportunity.CLM_Sales_Acknowledgment__c");
            var cpqCheck = component.get("v.opportunity.CPQ__c"); 
            
            //added Industry check as the part of CSI_SF-424 by Stuti-->
            if(newStageName == 'Offering' && oldStageName != 'Offering' && !clmCheck && !cpqCheck && component.get("v.OppIndustry")!='Payments & Network'){
                component.set('v.openModal',true);
            }
        }
    },
    
    
})