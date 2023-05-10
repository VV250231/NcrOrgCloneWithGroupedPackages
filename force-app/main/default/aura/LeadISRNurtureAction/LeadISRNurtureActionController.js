({
    /*   load_details : function(component, event, helper) {
        helper.get_progressdetails(component,event,helper);
        
    },*/
    load_details : function(component,event,helper){
        // event.getSource().get("v.value")  - works with lightning: button
        // event.currentTarget.id; : workds with button
        if(component.get("v.show_modal") == true){
            //alert(true);
            helper.get_depend_field_details(component,event,helper);
        }
    },
    show_Submit_modal : function(component,event,helper){
        helper.updateLeadRec(component,event,helper);
        
    },
    show_update_modal : function(component,event,helper){
        // event.getSource().get("v.value")  - works with lightning: button
        // event.currentTarget.id; : workds with button
        component.set("v.show_modal",!component.get("v.show_modal"));
        if(component.get("v.show_modal") == true){
            //     helper.get_field_details(component,event,helper);
            helper.get_depend_field_details(component,event,helper);
            
        }
    },
    /* ############################### record id methods ######################################## */
    onSuccess : function(component,event){	
        // below will show hide the modal
        component.set("v.show_modal",!component.get("v.show_modal"));
        //success message 
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The property's info has been updated.",
            "type": "success"
        });
        toastEvent.fire();
        
        // below will refresh the components on this page
        $A.get('e.force:refreshView').fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    onSubmit : function(component,event,helper){
        event.preventDefault();
        var fields = event.getParam('fields'); 
        fields.Return_to_Nurture_Reason__c = component.find("InputSelectSingle").get("v.value");
        //alert(component.find('cancel').get('v.value'));
        if(component.find('cancel').get('v.value')!="cancel"){
        component.find('myRecordForm').submit(fields);
        }
    },
    onLoad : function(component){
        //     component.find("status").set("v.value", 'Disqualified'); 
        
        component.find("status").set("v.value", 'Nurture'); 
        //component.find('status').set('v.value', 'Nurture');
        
    },
    onError : function(component,event){
        const payload = event.detail;
        console.log('here is payload on error :: ' +JSON.stringify(payload));
        
        component.set("v.show_modal",!component.get("v.show_modal"));
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": "Validation error on Lead ! Please update the Lead again ! ",
            "type" : 'error',
        });
        toastEvent.fire();
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordidd")
        });
        setTimeout(function(){
            editRecordEvent.fire()
        }, 2300);
    },
    show_cancel : function(component,event,helper){
   			    var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    
    },
    onSingleSelectChange : function(component,event,helper){
        var selectCmp = component.find("InputSelectSingle");
        if(selectCmp.get("v.value") != '--None--'){
            component.set("v.update_disabled",false);
        }
        else
            component.set("v.update_disabled",true);
        
        //  component.find("Return_to_Nurture_Reason__c").set("v.value", selectCmp.get("v.value")); 
    }
    
})