({
    onblur : function(component,event,helper){
        // on mouse leave clear the listOfSeachRecords & hide the search result component 
        component.set("v.listOfSearchRecords", null );
        component.set("v.SearchKeyWord", '');
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onfocus : function(component,event,helper) {
        // show the spinner,show child search result component and call helper function
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        component.set("v.listOfSearchRecords", null ); 
        var forOpen = component.find("searchRes");
        $A.util.addClass(forOpen, 'slds-is-open');
        $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC 
        var getInputkeyWord = '';
        helper.searchHelper(component,event,getInputkeyWord);
    },
    
    keyPressController : function(component, event, helper) {
        $A.util.addClass(component.find("mySpinner"), "slds-show");
        // get the search Input keyword   
        var getInputkeyWord = component.get("v.SearchKeyWord");
        // check if getInputKeyWord size id more then 0 then open the lookup result List and 
        // call the helper 
        // else close the lookup result List part.   
        if(getInputkeyWord.length > 0){
            var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
            helper.searchHelper(component,event,getInputkeyWord);
        }
        else{  
            component.set("v.listOfSearchRecords", null ); 
            var forclose = component.find("searchRes");
            $A.util.addClass(forclose, 'slds-is-close');
            $A.util.removeClass(forclose, 'slds-is-open');
        }
    },
    
    // function for clear the Record Selaction 
    clear :function(component,event,helper) {
        var selectedPillId = event.getSource().get("v.name");
        var AllPillsList = component.get("v.lstSelectedRecords"); 
        
        for(var i = 0; i < AllPillsList.length; i++){
            if(AllPillsList[i].Id == selectedPillId){
                AllPillsList.splice(i, 1);
                component.set("v.lstSelectedRecords", AllPillsList);
            }  
        }
        component.set("v.SearchKeyWord",null);
        component.set("v.listOfSearchRecords", null);      
    },
    
    // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        listSelectedItems.push(selectedAccountGetFromEvent);
        component.set("v.lstSelectedRecords" , listSelectedItems); 
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open'); 
    },
    AddMultipleContact:function(component, event, helper){
        
        var value = event.getParam("TcktId");
        var objectName = component.get("v.objectAPIName");
        var listSelectedItems =  component.get("v.lstSelectedRecords");
        //alert("Received application event with param = "+ value);
        var JucntionObj=[];
        for(var i=0;i<listSelectedItems.length;i++){
            if(listSelectedItems[i].Id.toString().startsWith("003")){
                //alert('Contact');
                 JucntionObj.push({'sobjectType':'Junction_Ticket_Contact__c','Related_Contact__c':listSelectedItems[i].Id,'Related_Ticket_Request__c':value});
            }
            
            if(listSelectedItems[i].Id.toString().startsWith("006")){
                //alert('Opportunity');
                JucntionObj.push({'sobjectType':'Junction_Ticket_Opportunity__c','Related_Opprtunity_to_Request__c':listSelectedItems[i].Id,'Related_TicketRequest__c':value});
            }
        } 
        
        if(objectName.toUpperCase() == 'USER') {
        	for(var i=0;i<listSelectedItems.length;i++){
                //alert('Opportunity');
                JucntionObj.push({'sobjectType':'Related_NCR_Rep__c','NCR_Rep__c':listSelectedItems[i].Id,'Ticket_Request__c':value});
            }     
        }
        
        component.set("v.JucntionObj");
        
        var action = component.get("c.AddMultipleContactToTicketRequest");
        action.setParams({ Junction_Ticket_Contact : JucntionObj});
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                
                if (value != 'NULL'){
                    window.location.href = '/'+value ;
                    /*$A.get('e.force:refreshView').fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": value,
                        "slideDevName": "detail",
                        "isredirect":true
                    });
                    navEvt.fire();*/
                }  
                if($A.util.isUndefinedOrNull(component) || !component.isValid()) {
                    component.destroy();  
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
    handleRenderLookUp:function(component, event, helper) {
        component.set("v.SearchKeyWord",null);
        // get the selected object record from the COMPONENT event 	 
        //var listSelectedItems =  component.get("v.lstSelectedRecords");
        //var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        //listSelectedItems.push(selectedAccountGetFromEvent);
       // component.set("v.lstSelectedRecords" , listSelectedItems); 
       
        
        var forclose = component.find("lookup-pill");
        $A.util.addClass(forclose, 'slds-show');
        $A.util.removeClass(forclose, 'slds-hide');
        
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    onChildAttributeChange:function(component, event, helper) {
        var filterField =  component.get("v.filterField");
        var filterValue =  component.get("v.filterValue");
    
        component.set("v.lstSelectedRecords",[]);
        component.set("v.listOfSearchRecords",[]);
        
    }
    
})