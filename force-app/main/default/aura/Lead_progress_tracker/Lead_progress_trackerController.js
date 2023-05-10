({
    load_details : function(component, event, helper) {
        helper.get_progressdetails(component,event,helper);
        
    },
    show_Submit_modal : function(component,event,helper){
        if(component.get("v.modaldetials[0]")=='Nurture'){
            helper.updateLeadRec(component,event,helper);
        }
        else if(component.get("v.modaldetials[0]")=='Disqualified'){
            helper.updateLeadRec(component,event,helper);
        }
    },
    show_update_modal : function(component,event,helper){
        // event.getSource().get("v.value")  - works with lightning: button
        // event.currentTarget.id; : workds with button
        component.set("v.show_modal",!component.get("v.show_modal"));
        if(component.get("v.show_modal") == true){
            helper.get_field_details(component,event,helper);
            helper.get_depend_field_details(component,event,helper);
            if(event.currentTarget.value){
                
                if(event.currentTarget.value == 'nurt'){
                    component.set("v.modaldetials[0]",'Nurture');
                }
                if(event.currentTarget.value == 'disq'){
                    component.set("v.modaldetials[0]",'Disqualified');
                }
                
            }
            var action = component.get('c.onSingleSelectChange');
       		$A.enqueueAction(action);
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
    },
    onSubmit : function(component,event,helper){
        event.preventDefault();
        var fields = event.getParam('fields'); 
        if(component.get("v.modaldetials[0]")=='Nurture'){
            fields.Return_to_Nurture_Reason__c = component.find("InputSelectSingle").get("v.value");
        }
        else if(component.get("v.modaldetials[0]")=='Disqualified'){
            fields.Disqualified_Reason__c = component.find("InputSelectSingle").get("v.value");
        }
        component.find('myRecordForm').submit(fields);
     },
    onLoad : function(component){
        if(component.get("v.modaldetials[0]")=='Nurture'){
            component.find("status").set("v.value", 'Disqualified'); 
            component.find("status").set("v.value", 'Nurture'); 
            //component.find('status').set('v.value', 'Nurture');
        }
        else if(component.get("v.modaldetials[0]")=='Disqualified'){
            component.find("status").set("v.value", 'Nurture');
            component.find('status').set('v.value', 'Disqualified');
        }
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