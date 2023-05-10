({
    editRecord : function(component, event, helper) {
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": component.get("v.recordId")
        });
        editRecordEvent.fire();
    },
     //Skip Required Field for Kedell Reed Changes
    loginUser : function(component, event, helper) {
       var action = component.get("c.isKendleReedLogin");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               component.set("v.isKendellReed",response.getReturnValue());
            }
            
        });
        $A.enqueueAction(action); 
    },
    //End Skip Required Field for Kedell Reed Changes
    getPermissionAssigenment: function(component, event, helper){
         var action = component.get("c.getUserIdPermissionSet");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.havePermissionSetAccess", response.getReturnValue());
            }
            else if (state === "INCOMPLETE") {
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
     getTicketType:function(component,event ,Event_Value){
        component.set("v.selectedEventName", Event_Value);
         
        var action = component.get("c.getTicketType");
        action.setParams({ Event_Selected :  Event_Value});
        action.setCallback(this, function(response) {
            var state = response.getState();
            var Type=[];
            if (state === "SUCCESS") {

                var map=response.getReturnValue();
                component.set("v.TicketType_And_NoOfTicketAvilable",map);
                
                
                Type = [{ value: "None", label: "None"}];  
                        Object.keys(map).forEach(function(key) {
                         Type.push({value:key, label:key});   
                        });
                console.log('Type'+Type);
                if(Type.length > 1){
                    component.set("v.TicketType",[]);
                    component.set("v.TicketType",Type);
                	component.set("v.TicketType_And_NoOfTicketAvilable",map);
                   
                }
                    
                    
                else{
                    component.set("v.TicketType",[]);
                    Type = [{ value: "None", label: "None"}];
                    component.set("v.TicketType",Type);
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "No Ticket Avilable for this Event Name and Date.", 
                        "type": "error"
                    });
                    toastEvent.fire();
                    
                }      
   			
           }                               
            else if (state === "INCOMPLETE") {
                alert('Incomplete');
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Something went wrong please contact Admin.",
                            "type": "error" 
                        });
                        toastEvent.fire();
                    }
                } else {
                   var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Unknown Error.",
                            "type": "error" 
                        });
                        toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);

    },
    getTicketTypeMap:function(component,event,selEvtName){
        
        var action= component.get("c.getTicketType");
        action.setParams({ Event_Selected :  selEvtName});
        action.setCallback(this,function(response){
            var state= response.getState();
              $A.log(response);
            if(state == "SUCCESS"){
                //component.set("v.Accounts",response.getReturnValue());
                //alert(selEvtName);
                var map=response.getReturnValue();
                component.set("v.TicketType_And_NoOfTicketAvilable",map);
               console.log('ticket type map'+JSON.stringify(map)); 
            }
        });
        $A.enqueueAction(action);
    },
    getNoOfPassesAvailble : function(component,event,selEvtName){
        var action= component.get("c.getParkingPasses");
        action.setParams({ Event_Selected :  selEvtName});
        action.setCallback(this,function(response){
            var state= response.getState();
              var passList=[];
            console.log('parking response'+response.getReturnValue());
            if(state == "SUCCESS"){
                if(response.getReturnValue()>0){
                    
                    for(var i=0;i<=response.getReturnValue();i++){
                        passList.push({label:i,value:i,selected:false});
                    } 
                }
                component.set("v.AvailableParkingPasses",passList);
                component.set("v.SelectedParkingPasses",0);
                
            }
        });
        $A.enqueueAction(action);
    },
    getNoOfPassesAvailbleEditMode : function(component,event,selEvtName){
         
        var action= component.get("c.getEditModeParkingPasses");
        action.setParams({ RecordId :  component.get("v.recordId"),
                          Event_Selected : selEvtName
                         });
        action.setCallback(this,function(response){
            var state= response.getState();
            if(state == "SUCCESS"){
                 var passList=[];
                console.log('parking pass'+response.getReturnValue()[0]);
                if(response.getReturnValue()){
                    var SelectedPass =response.getReturnValue()[0].NumberOfParkingPasses;
                    console.log('parking pass'+response.getReturnValue()[0].NumberOfParkingPasses);
                    console.log('Total parking pass'+parseInt(response.getReturnValue()[0].TotalNumberOfPasses));
                    //component.set("v.SelectedParkingPass",response.getReturnValue().NumberOfParkingPasses);
                    for(var i=0;i<=parseInt(response.getReturnValue()[0].TotalNumberOfPasses);i++){
                       console.log(SelectedPass==i+'  '+i); 
                        if(SelectedPass == i){
                         passList.push({label:i,value:i,selected:true});
                        }     
                      else
                          passList.push({label:i,value:i,selected:false});
                    } 
                }
                component.set("v.AvailableParkingPasses",passList);
                if(!SelectedPass){
                  component.set("v.SelectedParkingPasses",SelectedPass);  
                }else{
                    //component.set("v.SelectedParkingPasses",0);
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    GetSelectedContactOnEdit: function(cmp,Event,RecordId){
        
        if(cmp.get("v.recordId") !== undefined && cmp.get("v.recordId") !== null && cmp.get("v.recordId") !== ' '){
         
        var Obj=[];  
        var action = cmp.get("c.GetSelectedContact");
        action.setParams({ RecordId : cmp.get("v.recordId")  });

        
        action.setCallback(this, function(response) {
            var state = response.getState(); 
            if (state === "SUCCESS") {
                 
                //console.log(response.getReturnValue().length);
				//cmp.get("v.selectedContactLookUpRecords",response.getReturnValue());
                
                console.log(response.getReturnValue());
                for(var i=0;i<response.getReturnValue().length;i++){
                    //alert(response.getReturnValue()[i]);
                    Obj.push(response.getReturnValue()[i]);
                    
                }	
                cmp.set("v.selectedContactLookUpRecords",Obj);
                cmp.set("v.selectedContactLookUpRecordsTemp",Obj);
                
                 var myEvent = $A.get("e.c:RenderLookUp");
                 myEvent.setParams({"param": "It works!"});
                 myEvent.fire();
                
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
	},
    GetSelectedOpportunityOnEdit:function(cmp,Event,RecordId){
        if(cmp.get("v.recordId") !== undefined && cmp.get("v.recordId") !== null && cmp.get("v.recordId") !== ' '){
        
        var Obj=[];  
        var action = cmp.get("c.GetSelectedOpportunity");
        action.setParams({ RecordId : cmp.get("v.recordId")  });

        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                 
                //console.log(response.getReturnValue().length);
				//cmp.get("v.selectedContactLookUpRecords",response.getReturnValue());
                
                console.log(response.getReturnValue());
                for(var i=0;i<response.getReturnValue().length;i++){
                    //alert(response.getReturnValue()[i]);
                    Obj.push(response.getReturnValue()[i]);
                    //selectedContactLookUpRecords.push(response.getReturnValue()[i]);
                }	
                cmp.set("v.selectedContactLookUpRecords_Opp",Obj);
                cmp.set("v.selectedContactLookUpRecords_OppTemp",Obj);
                 var myEvent = $A.get("e.c:RenderLookUp");
                 myEvent.setParams({"param": "It works!"});
                 myEvent.fire();
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
    },
    proceedtoCreateRecordHelper:function(component,event){
     	
        var SelectedTicketType=component.get("v.SelectedTicketType");
        var TicketRequested= component.get("v.TicketRequested");
         var evtTyp = component.find("selectItem").get("v.value"); 
        var ticketRequestRecord = $A.get("e.force:createRecord");
            
            // New TICKET REQUEST creation for Kendall Reed
            if(component.get("v.havePermissionSetAccess") == true){
               //TicketObj.push({Event_Typ__c:evtTyp,Event_Name_Date__c:component.get("v.selectedEventName"),No_of_Tickets_Requested__c:TicketRequested,Name:evtTyp + ' - ' + component.get("v.selectedEventName"),Ticket_Type__c:'Admin Assigned',Approval_Status__c:'Approved',Number_of_Parking_Passes_Available__c: component.get("v.SelectedParkingPasses"),Ticket_Typ__c : SelectedTicketType});
               
               /* ticketRequestRecord.setParams({
                    "entityApiName": "Ticket_Request__c",
                    'recordTypeId' : '0120g000000YUA7AAO',
                    "defaultFieldValues": {
                        'Event_Typ__c' : evtTyp,
                        'Event_Name_Date__c' : component.get("v.selectedEventName"),
                        'No_of_Tickets_Requested__c': component.get("v.avalbleTickets"),
                        'Name': evtTyp + ' - ' + component.get("v.selectedEventName"),
                        'Ticket_Type__c': 'Admin Assigned',
                        'Approval_Status__c' : 'Approved',
                        'Number_of_Parking_Passes_Available__c' : component.get("v.SelectedParkingPasses"),
                        'Ticket_Typ__c' : SelectedTicketType,
                        'Phone_Number__c' : component.get("v.PhoneNo"),
                        'Other_Employee_Reps_Attending__c' :component.get("v.ListAttende"),
                        'Additional_Info__c' : component.get("v.Reason")
                    }
                }); */
                
                //commented to redirect to standard page
                var TicketRequestvalue=component.get("v.TicketRequest");
                TicketRequestvalue.Event_Typ__c=evtTyp;
                TicketRequestvalue.Event_Name_Date__c=component.get("v.selectedEventName");
                TicketRequestvalue.No_of_Tickets_Requested__c= component.get("v.TicketRequested");
                TicketRequestvalue.Name=evtTyp + ' - ' + component.get("v.selectedEventName");
                TicketRequestvalue.Ticket_Type__c='Admin Assigned';
                TicketRequestvalue.Approval_Status__c='Approved';
                TicketRequestvalue.Number_of_Parking_Passes_Available__c= component.get("v.SelectedParkingPasses");
                TicketRequestvalue.Ticket_Typ__c=SelectedTicketType; 
                TicketRequestvalue.Phone_Number__c=component.get("v.PhoneNo");
                //TicketRequestvalue.Other_Employee_Reps_Attending__c=component.get("v.ListAttende");
                TicketRequestvalue.Additional_Info__c=component.get("v.Reason");
                TicketRequestvalue.Related_Account__c=component.get("v.TicketRequest.Related_Account__c"); 
                TicketRequestvalue.Ticket_Request_Event__c=component.get("v.SelectedEventId");
                //TicketRequestvalue.recordTypeId = '0120g000000YUA7AAO';
                
                
                var action = component.get("c.processToCreateRecord");
                action.setParams({ TcktObj : TicketRequestvalue });
        
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": response.getReturnValue(),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        
                        if(component.get("v.skipRequiredField") == false){
                            var myEvent = $A.get("e.c:TcktRqstMultipleContact");
                            myEvent.setParams({"TcktId": response.getReturnValue()});
                            myEvent.fire();
                        }
                        
        			    else{
                               var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": response.getReturnValue(),
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                         }
                        
                    }
                    else if (state === "INCOMPLETE") {
                         
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
        
                // optionally set storable, abortable, background flag here
        
                // A client-side action could cause multiple events, 
                // which could trigger other events and 
                // other server-side action calls.
                // $A.enqueueAction adds the server-side action to the queue.
                $A.enqueueAction(action);     
            }
            else {
              
                
                // New TICKET REQUEST creation for standard user
                /*ticketRequestRecord.setParams({
                    "entityApiName": "Ticket_Request__c",
                    'recordTypeId' : '0120g000000YUA8AAO',
                    "defaultFieldValues": {
                        'Event_Typ__c' : evtTyp,
                        'Event_Name_Date__c' : component.get("v.selectedEventName"),
                        'No_of_Tickets_Requested__c': TicketRequested,
                        'Name': evtTyp + ' - ' + component.get("v.selectedEventName"),
                        'Ticket_Type__c': 'User Assigned',
                        'Number_of_Parking_Passes_Available__c' : component.get("v.SelectedParkingPasses"),
                        'Ticket_Typ__c' : SelectedTicketType, 
                        'Phone_Number__c' : component.get("v.PhoneNo"), 
                        'Other_Employee_Reps_Attending__c' : component.get("v.ListAttende"),
                        'Additional_Info__c' : component.get("v.Reason")
                    }
                });*/
                
                
                //console.log('usingfind'+component.find("newParkingPassReq").get("v.value"));
                //TicketObj.push({Event_Typ__c:evtTyp,Event_Name_Date__c:component.get("v.selectedEventName"),No_of_Tickets_Requested__c:TicketRequested,Name:evtTyp + ' - ' + component.get("v.selectedEventName"),Ticket_Type__c:'Admin Assigned',Approval_Status__c:'Approved',Number_of_Parking_Passes_Available__c: component.get("v.SelectedParkingPasses"),Ticket_Typ__c : SelectedTicketType});
                
                var TicketRequestvalue=component.get("v.TicketRequest");
                TicketRequestvalue.Event_Typ__c=evtTyp;
                TicketRequestvalue.Event_Name_Date__c=component.get("v.selectedEventName");
                TicketRequestvalue.No_of_Tickets_Requested__c=TicketRequested;
                TicketRequestvalue.Name=evtTyp + ' - ' + component.get("v.selectedEventName");
                TicketRequestvalue.Ticket_Type__c='User Assigned';
                //TicketRequestvalue.Approval_Status__c='Approved';
                TicketRequestvalue.Number_of_Parking_Passes_Available__c= component.get("v.SelectedParkingPasses");
                TicketRequestvalue.Ticket_Typ__c=SelectedTicketType; 
                TicketRequestvalue.Phone_Number__c=component.get("v.PhoneNo");
                //TicketRequestvalue.Other_Employee_Reps_Attending__c=component.get("v.ListAttende");
                TicketRequestvalue.Additional_Info__c=component.get("v.Reason");
                TicketRequestvalue.Related_Account__c=component.get("v.TicketRequest.Related_Account__c");
                TicketRequestvalue.Ticket_Request_Event__c=component.get("v.SelectedEventId");
                //TicketRequestvalue.recordTypeId = '0120g000000YUA7AAO';
                
                
                var action = component.get("c.processToCreateRecord");
                action.setParams({ TcktObj : TicketRequestvalue });
        
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('state>>>' + state);
                    if (state === "SUCCESS") {
                        console.log('response>>>' + response.getReturnValue());
                        /*var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": response.getReturnValue(),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();*/
                       
                       if(component.get("v.skipRequiredField") == false){
                            var myEvent = $A.get("e.c:TcktRqstMultipleContact");
                            myEvent.setParams({"TcktId": response.getReturnValue()});
                            myEvent.fire();
                        }
                        
                        else{
                               var navEvt = $A.get("e.force:navigateToSObject");
                                navEvt.setParams({
                                    "recordId": response.getReturnValue(),
                                    "slideDevName": "detail"
                                });
                                navEvt.fire();
                         }
                    }
                    else if (state === "INCOMPLETE") {
                        
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
        
                // optionally set storable, abortable, background flag here
                // A client-side action could cause multiple events, 
                // which could trigger other events and 
                // other server-side action calls.
                // $A.enqueueAction adds the server-side action to the queue.
                $A.enqueueAction(action);       
                }
                   //ticketRequestRecord.fire();
	  },
    //get currently user logged in - phone
    getUserPhone : function(component, event, helper) {
       var action = component.get("c.getPhoneNumber");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue()!=null){
               		component.set("v.PhoneNo",response.getReturnValue());
                    component.set("v.isPhoneDisabled",true);
                }
                else{
                    component.set("v.isPhoneDisabled",false);
                }
                    
            }
            
        });
        $A.enqueueAction(action); 
    },
})