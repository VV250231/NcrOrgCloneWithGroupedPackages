({
   onfocus : function(component,event,helper){
       $A.util.addClass(component.find("mySpinner"), "slds-show");
        var forOpen = component.find("searchRes");
            $A.util.addClass(forOpen, 'slds-is-open');
            $A.util.removeClass(forOpen, 'slds-is-close');
        // Get Default 5 Records order by createdDate DESC  
         var getInputkeyWord = '';
           helper.searchHelper(component,event,getInputkeyWord);

    },
    onblur : function(component,event,helper){       
        component.set("v.listOfSearchRecords", null );
        var forclose = component.find("searchRes");
        $A.util.addClass(forclose, 'slds-is-close');
        $A.util.removeClass(forclose, 'slds-is-open');
    },
    keyPressController : function(component, event, helper) {
       // get the search Input keyword   
         var getInputkeyWord = component.get("v.SearchKeyWord");
       // check if getInputKeyWord size id more then 0 then open the lookup result List and 
       // call the helper 
       // else close the lookup result List part.   
        if( getInputkeyWord.length > 0 ){
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
    clear :function(component,event,heplper){
         var pillTarget = component.find("lookup-pill");
         var lookUpTarget = component.find("lookupField"); 
        
         $A.util.addClass(pillTarget, 'slds-hide');
         $A.util.removeClass(pillTarget, 'slds-show');
        
         $A.util.addClass(lookUpTarget, 'slds-show');
         $A.util.removeClass(lookUpTarget, 'slds-hide');
      
         component.set("v.SearchKeyWord",null);
         component.set("v.listOfSearchRecords", null );
         component.set("v.selectedRecord", {} ); 
          var LookUp = component.getEvent("LookUpEvt");              
                LookUp.setParams({
                "Action" : component.get("v.label"),
                "ContactId" : ''
                });
         LookUp.fire();
     
    },
    
  // This function call when the end User Select any record from the result list.   
    handleComponentEvent : function(component, event, helper) {
    // get the selected Account record from the COMPONETN event 	 
       var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	   component.set("v.selectedRecord" , selectedAccountGetFromEvent); 
       
        //alert();
        
        var forclose = component.find("lookup-pill");
           $A.util.addClass(forclose, 'slds-show');
           $A.util.removeClass(forclose, 'slds-hide');
  
        var forclose = component.find("searchRes");
           $A.util.addClass(forclose, 'slds-is-close');
           $A.util.removeClass(forclose, 'slds-is-open');
        
        var lookUpTarget = component.find("lookupField");
            $A.util.addClass(lookUpTarget, 'slds-hide');
            $A.util.removeClass(lookUpTarget, 'slds-show'); 
        
            var LookUp = component.getEvent("LookUpEvt");              
                LookUp.setParams({
                "Action" : component.get("v.label"),
                "ContactId" : selectedAccountGetFromEvent.Id
                });
           LookUp.fire();
        
      
	},
    
    
    createRecord:function(component, event, helper){
         var toggleText = component.find("CreateRecordDiv");
         $A.util.removeClass(toggleText, 'slds-hide');  
         $A.util.addClass(toggleText, 'slds-show');
        
    },
    
    
    onCancel:function(component, event, helper){
         var toggleText = component.find("CreateRecordDiv");
         $A.util.removeClass(toggleText, 'slds-show');  
         $A.util.addClass(toggleText, 'slds-hide');
    },
    
     handleSuccess : function(component, event, helper) {
        component.find('notifLib').showToast({
            "variant": "success",
            "title": "Account Created",
            "message": "Record ID: " + event.getParam("id")
        });
         
        
         var LookUp = component.getEvent("LookUpEvt");              
                LookUp.setParams({
                "Action" : component.get("v.label"),
                "ContactId" : event.getParam("id")
                });
         LookUp.fire();
         
         var toggleText = component.find("CreateRecordDiv");
         $A.util.removeClass(toggleText, 'slds-show');  
         $A.util.addClass(toggleText, 'slds-hide');
         
          helper.getSelectedRecord(component, event, event.getParam("id"));
         
    },
    handleSubmit : function(cmp, event, helper) {
       	event.preventDefault(); 
        const fields = event.getParam('fields');
         //alert(fields.Email);
        if(fields.Email === '' ||  (typeof fields.Email === "undefined") || (fields.Email === null)){
            //event.preventDefault();  
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'error',
                        message: 'Email can not be blank.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
        }
        
 
         else if(fields.Email !== '' ||  (typeof fields.Email !== "undefined") (fields.Email !== null)){
        //event.preventDefault();  
        const fields = event.getParam('fields');
        //alert(fields.FirstName); 
        //alert(fields.LastName);        
        var action = cmp.get("c.checkIfContactExist");
        action.setParams({
            'ContactEmial': fields.Email,
            'ObjectName' : cmp.get("v.objectAPIName"),
            'ConPhone'  : fields.Phone,
            'BusinessFunction' : fields.Business_Function__c,
            'FirstName'  : fields.FirstName,
            'LastName'  : fields.LastName,
            'InvoiceMcn' : cmp.get("v.InvoiceAccountMcn")
          });
        
        action.setCallback(this, function(response) {
          //$A.util.removeClass(cmp.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
               var storeResponse = response.getReturnValue();
                //alert(JSON.stringify(storeResponse));
                //alert(storeResponse.Business_Function__c);
   				 var LookUp = cmp.getEvent("LookUpEvt");               
                LookUp.setParams({
                "Action" : cmp.get("v.label"),
                "ContactId" :storeResponse.Id
                });
         	 LookUp.fire();
         
         var toggleText = cmp.find("CreateRecordDiv");
         $A.util.removeClass(toggleText, 'slds-show');  
         $A.util.addClass(toggleText, 'slds-hide');
         
          helper.getSelectedRecord(cmp, event, event.getParam("id"));
                 helper.getSelectedRecord(cmp, event,storeResponse.Id);
                  
            }
            else{
                alert('error');
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
        }
               
    }
})