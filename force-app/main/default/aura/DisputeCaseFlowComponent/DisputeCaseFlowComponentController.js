({
    doInit : function(component, event, helper) { 
        
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state; // state holds any query params
        var base64Context = state.inContextOfRef;
        var action = component.get("c.getUserAccessForDispute");
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                console.log(JSON.stringify(response.getReturnValue()));
                if(response.getReturnValue()){
                    var recordTypeId = component.get("v.pageReference").state.recordTypeId;
                    
                    if(component.get("v.pageReference").state.recordTypeId == '0124u000000pET3AAM'){
                        //alert(1);
                        component.set("v.isModalOpen",true);
                        var flow = component.find("flowData");
                        var inputVariables = [
                            {
                                name : 'RecordTypeId',
                                type : 'String',
                                value : recordTypeId
                            }
                        ];
                        
                        flow.startFlow("DisputeCaseFlow",inputVariables);
                        
                    }
                    
                    
                    else if((typeof component.get("v.pageReference").state.recordTypeId != 'undefined') &&  (component.get("v.pageReference").state.recordTypeId == '0124u000000pET3AAM')){
                        //alert(2); 
                        component.set("v.isModalOpen",true);
                        var flow = component.find("flowData");
                        var inputVariables = [
                            {
                                name : 'RecordTypeId',
                                type : 'String',
                                value : recordTypeId
                            }
                        ];  
                        
                        flow.startFlow("DisputeCaseFlow",inputVariables);
                    }
                        else if((typeof component.get("v.pageReference").state.recordTypeId != 'undefined') &&  (component.get("v.pageReference").state.recordTypeId == $A.get("$Label.c.VOC_Record_Type_ID"))){
                            //alert(3);
                            if(base64Context!==undefined){
                                if (base64Context.startsWith("1\.")) {
                                    base64Context = base64Context.substring(2);
                                }
                                var addressableContext = JSON.parse(window.atob(base64Context));
                                component.set("v.recordId", addressableContext.attributes.recordId);
                            }
                            var recId =component.get("v.recordId");
                            if(typeof recId == 'undefined'){
                                recId='';
                            }
                            component.set("v.HeaderText","New Customer Success Team Case");       
                            component.set("v.isModalOpen",true);
                            var flow = component.find("flowData");
                            var inputVariables = [
                                {
                                    name : 'RecordTypeId',
                                    type : 'String',
                                    value : $A.get("$Label.c.VOC_Record_Type_ID")
                                },
                                {
                                    name : 'RecId',
                                    type : 'String',
                                    value : recId
                                }
                            ];  
                            
                            flow.startFlow("New_Customer_Case_From_Community",inputVariables);
                            
                        }
                            else if((typeof component.get("v.pageReference").state.recordTypeId == 'undefined') &&  (response.getReturnValue() == $A.get("$Label.c.VOC_Record_Type_ID"))){
                                //alert(4);  
                                if(base64Context!==undefined){
                                    if (base64Context.startsWith("1\.")) {
                                        base64Context = base64Context.substring(2);
                                    }
                                    var addressableContext = JSON.parse(window.atob(base64Context));
                                    component.set("v.recordId", addressableContext.attributes.recordId);
                                }
                                var recId =component.get("v.recordId");
                                if(typeof recId == 'undefined'){
                                    recId='';
                                }
                                component.set("v.HeaderText","New Customer Success Team Case");
                                component.set("v.isModalOpen",true);
                                var flow = component.find("flowData");
                                var inputVariables = [
                                    {
                                        name : 'RecordTypeId',
                                        type : 'String',
                                        value : response.getReturnValue()
                                    },
                                    {
                                        name : 'RecId',
                                        type : 'String',
                                        value : recId
                                    }
                                ];  
                                
                                flow.startFlow("New_Customer_Case_From_Community",inputVariables);
                                
                            }
                                else if((typeof component.get("v.pageReference").state.recordTypeId == 'undefined') &&  (response.getReturnValue() == '0124u000000pET3AAM')){
                                    
                                    component.set("v.isModalOpen",true);
                                    var flow = component.find("flowData");
                                    var inputVariables = [
                                        {
                                            name : 'RecordTypeId',
                                            type : 'String',
                                            value : recordTypeId
                                        }
                                    ];  
                                    
                                    flow.startFlow("DisputeCaseFlow",inputVariables);
                                    
                                }
                    //Lines of code added for Case Intake Flow
                                    else if( recordTypeId == '0124u000000HtiHAAS' || response.getReturnValue() == '0124u000000HtiHAAS'){
                                        console.log('1.')
                                        if(base64Context!==undefined){
                                            if (base64Context.startsWith("1\.")) {
                                                base64Context = base64Context.substring(2);
                                            }
                                            var addressableContext = JSON.parse(window.atob(base64Context));
                                            component.set("v.recordId", addressableContext.attributes.recordId);
                                        }
                                        var recId =component.get("v.recordId");
                                        console.log('2.')
                                        component.set("v.HeaderText","Case Intake Flow");
                                        component.set("v.isModalOpen",true);
                                        var flow = component.find("flowData");
                                        if(recId != null){
                                            var inputVariables = [
                                                {
                                                    name : 'recordId',
                                                    type : 'String',
                                                    value : recId
                                                }
                                            ];  
                                            flow.startFlow("Hospitality_Case_Intake_Flow",inputVariables);
                                        }
                                        else{
                                            flow.startFlow("Hospitality_Case_Intake_Flow");
                                        }
                                       
                                    }
                    
                    
                    
                    
                    
                                        else{
                                            component.set("v.isModalOpen",false);
                                            var theEvent = $A.get("e.force:createRecord");
                                            theEvent.setParams({
                                                "entityApiName":"Case",
                                                "recordTypeId": component.get("v.pageReference").state.recordTypeId
                                            });
                                            theEvent.fire();
                                            $A.get("e.force:closeQuickAction").fire();
                                            
                                        }
                    
                }
                else{
                    // alert();
                }
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
        
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
        $A.get("e.force:closeQuickAction").fire();
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Case"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
        //alert();
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        //Add your code to call apex method or do some processing
        component.set("v.isModalOpen", false);
    },
})