({
    doInit : function(component, event, helper) {
        var opts = [{ value: "None", label: "None" }];
        var eventTypeNameMap = new Map();
        var eventNameEventMap = new Map();
        var selEvtName;
        var eventNameIdMap = new Map();
        helper.getPermissionAssigenment(component, event, helper);
         helper.getUserPhone(component, event, helper);
        //Skip Required Field for Kedell Reed Changes
        helper.loginUser(component, event, helper);
        //End of Skip Required Field for Kedell Reed Changes 
      
        //On None Selection in Event Type, setting none in Event Name & Date
        var SelectedNoneEventTyp = []; 
        SelectedNoneEventTyp.push({value:'None', label:'None'});
        component.set("v.SetNoneOnEventName", SelectedNoneEventTyp);
        // On None Selection in Event Type and Event Name, setting none in Tickets
        
        //calling server side method to get Event type and Event name		
        var action = component.get("c.getEventNameandDate");
        action.setCallback(this, function(a) {
            if(a.getState() == "SUCCESS") {
                //helper.GetSelectedContactOnEdit(component,Event,component.get("v.recordId"));
                //helper.GetSelectedOpportunityOnEdit(component,Event,component.get("v.recordId"));
                var eventList = a.getReturnValue(); 
                
                for(var i=0; i<eventList.length; i++) {
                    
                    var temparr = eventTypeNameMap.get(eventList[i].Event_Type__c);
                    if($A.util.isUndefinedOrNull(temparr)) { 
                        temparr = [{ value: "None", label: "None"}];  
                        eventTypeNameMap.set(eventList[i].Event_Type__c, temparr); 
                        opts.push({value:eventList[i].Event_Type__c, label:eventList[i].Event_Type__c}) ;
                        //alert(eventList[i].Event_Type__c);
                        eventNameIdMap.set(eventList[i].Event_Name_Date__c,eventList[i].Id);
                    }
                    temparr.push({value:eventList[i].Event_Name_Date__c, label:eventList[i].Event_Name_Date__c}) ;
                    eventNameEventMap.set(eventList[i].Event_Name_Date__c, eventList[i].Id);
                    //console.log(eventNameEventMap);
                    
            	}
                
                component.set("v.eventType", opts);  
                component.set("v.EventTypeAndNameMap", eventTypeNameMap); 
                component.set("v.EventNameIdMap",eventNameEventMap);
                
            }
        }); $A.enqueueAction(action);
         
        // if record exists:: Edit case starts
        if(component.get("v.recordId") !== undefined && component.get("v.recordId") !== null && component.get("v.recordId") !== ' '){
            var action = component.get("c.getSelectedValue");
            action.setParams({ RdId : component.get("v.recordId") });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var statusFieldValue = response.getReturnValue()[0].Approval_Status__c;
                
                    //alert(response.getReturnValue()[0].Phone_Number__c);
                    component.set("v.PhoneNo",response.getReturnValue()[0].Phone_Number__c);
                    component.set("v.Reason",response.getReturnValue()[0].Additional_Info__c);
                    component.set("v.ListAttende",response.getReturnValue()[0].Other_Employee_Reps_Attending__c);
                    
                    //Validation to check if record is submitted or Approved :: Starts
                    if(statusFieldValue == 'Approved' || statusFieldValue == 'Submitted'){
                        component.set("v.disabled", true);
                        component.set("v.disabledNoTckt", true);
                        component.set("v.disabledonEdit", true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "This record is submitted/approved, you cannot edit it now. If you want to make changes. Please contact to Kendall Reed <kr185076@ncr.com>.",
                            "type": "error"
                        });
                        toastEvent.fire();
                    } //Validation to check if record is submitted or Approved :: Ends
                    else{
                        //setting event type
                        var selEvtType = response.getReturnValue()[0].Event_Typ__c;
                        var selectedEvtTypOpt =  {value: selEvtType, label: selEvtType};                    
                        for (var i = 0; i < opts.length; i++) {
                            if(opts[i].value == selEvtType){
                                opts.splice(i,1);
                            }
                        }
                        opts.splice(0, 0, selectedEvtTypOpt);
                        component.set("v.eventTypeonEdit", opts);
                        
                        // Setting event Name
                        selEvtName = response.getReturnValue()[0].Event_Name_Date__c;
                        var selectedEvtNameOpt =  {value: selEvtName, label: selEvtName};
                        var eventNameOpts = [];
                        console.log(eventTypeNameMap);
                        if(!$A.util.isUndefinedOrNull( eventTypeNameMap.get(selEvtType)) && (selEvtType != 'None')) {
                         	 eventNameOpts = eventTypeNameMap.get(selEvtType).slice();
                        }
                        
                        for (var i = 0; i < eventNameOpts.length; i++) {
                            if(eventNameOpts[i].value == selEvtName){
                                eventNameOpts.splice(i,1);
                            }
                        }
                        eventNameOpts.splice(0, 0, selectedEvtNameOpt);
                        component.set("v.eventNameonEdit", eventNameOpts);
                        
                        // display ticket type
                        var selTcktType = response.getReturnValue()[0].Ticket_Typ__c;
                        var selTcktTypeOpt =  {value: selTcktType, label: selTcktType};
                        var tckTypeOpts = [{ value: "None", label: "None" }];
                        var tcktUnavl = false;
                        var avlblTickets = 0;
                        
                        
                        if(!$A.util.isUndefinedOrNull(eventNameEventMap) && (selEvtName != 'None')) {
                         	var tcktEvent = eventNameEventMap.get(selEvtName);
                            console.log(tcktEvent);
                            //alert(tcktEvent.VVIP_Tickets_Available__c);
                            if(!$A.util.isUndefinedOrNull(tcktEvent)) {
                                if(parseInt(tcktEvent.VVIP_Tickets_Available__c) > 0) 
                                    tckTypeOpts.push({value : 'Club', label : 'Club'}) 
                                 if(parseInt(tcktEvent.Suite_Tickets_Available__c) > 0)
                                    tckTypeOpts.push({value : 'Suite', label : 'Suite'})  
                                 if(parseInt(tcktEvent.Lower_Level_Tickets_Available__c) > 0) 
                                    tckTypeOpts.push({value : 'Lower Level', label : 'Lower Level'}) 
                                    
                                if(selTcktType == 'Club') {
                                	if(parseInt(tcktEvent.VVIP_Tickets_Available__c) <= 0 ) 
                                        tcktUnavl = true;
                                    else 
                                        avlblTickets = parseInt(tcktEvent.VVIP_Tickets_Available__c);
                                }
                                
                                if(selTcktType == 'Suite') {
                                	if(parseInt(tcktEvent.Suite_Tickets_Available__c) <= 0 ) 
                                        tcktUnavl = true;
                                    else 
                                        avlblTickets = parseInt(tcktEvent.Suite_Tickets_Available__c);
                                }
                                
                                if(selTcktType == 'Lower Level') {
                                	if(parseInt(tcktEvent.Lower_Level_Tickets_Available__c) <= 0 ) 
                                        tcktUnavl = true;
                                    else 
                                        avlblTickets = parseInt(tcktEvent.Lower_Level_Tickets_Available__c);
                                }
   
                            } 
                        }
                        
                        for (var i = 0; i < tckTypeOpts.length; i++) {
                            if(tckTypeOpts[i].value == selTcktType){
                                tckTypeOpts.splice(i,1);
                            }
                        }
                        tckTypeOpts.splice(0, 0, selTcktTypeOpt);
                        console.log(tckTypeOpts);
                        
                        // set already selected ticket type on edit
                        component.set("v.TicketType", tckTypeOpts);
                        component.set("v.SelectedTicketType", selTcktType); 
                        
                        // display no of available tickets
                        if(tcktUnavl) {
                        	component.set("v.disabledNoTckt",true);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error!",
                                "message": "All the tickets for the selected event and ticket type has been booked.",
                                "type": "error"
                            });
                            toastEvent.fire();    
                        } else {
                        	 component.set("v.disabledNoTckt",false);    
                        }
                        
                        var tcktList=[];
                        for(var i=1; i<=avlblTickets; i++){
                            tcktList.push({value:i, 
                                           label:i}) ;
                        }
                            // Setting Available Tickets
                            var selTcktReq = response.getReturnValue()[0].No_of_Tickets_Requested__c;
                            var selectedTcktReqOpt =  {value: selTcktReq, label: selTcktReq};
                            for (var j = 0; j <= tcktList.length; j++) {
                                if(tcktList[j]!=null && tcktList[j]!='' && tcktList[j]!='undefined' && tcktList[j].value == selTcktReq){
                                    tcktList.splice(j,1);
                                    break;
                                }
                            }
                            tcktList.splice(0, 0, selectedTcktReqOpt);
                        
                            // set already requested tickets on edit
                            component.set("v.avlblTicketonEdit", tcktList);                             
                            component.set("v.TicketRequested", selTcktReq); 
                            helper.getTicketTypeMap(component, event ,selEvtName); 
                            console.log('call getNoOfPassesAvailbleEditMode'+selEvtName);
                            helper.getNoOfPassesAvailbleEditMode(component, event,selEvtName );
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
            
            component.set("v.showEditModal", true);
            component.set("v.showModal", false);
        }
        //If record Exists:: Edit case Ends
        					
    },
    setPassRequested : function(component, event, helper) {
        //alert('select'+event.getSource().get("v.value"));
        component.set("v.SelectedParkingPasses",event.getSource().get("v.value"));
    },
    getEventType:function(component, event, helper) {
        
        var selectedEventType = event.getSource().get("v.value");
        //alert('selectedEventType'+selectedEventType);
        
        //alert(component.get("v.SelectedEventId"));
        component.set("v.1", selectedEventType);
        component.set("v.selectedEventName", "None");
        
        if(selectedEventType == 'None'){
            
            component.set("v.eventNames", component.get("v.SetNoneOnEventName"));
            //component.set("v.disabled", true);
			
            if(component.get("v.recordId") !== undefined && component.get("v.recordId") !== null && component.get("v.recordId") !== ' '){
                console.log('record exists');    
                component.set("v.eventNameonEdit", component.get("v.SetNoneOnEventName"));
                component.set("v.disabledNoTckt", true);
            } 
        } else {
            var eventTypeNameMap = component.get("v.EventTypeAndNameMap") 
            //alert(eventTypeNameMap);
            
            if(!$A.util.isUndefinedOrNull(eventTypeNameMap)) {
                component.set("v.eventNames", eventTypeNameMap.get(selectedEventType));
                component.set("v.eventNameonEdit", eventTypeNameMap.get(selectedEventType));
            }
        }
        
    },
    getEventName: function(component, event, helper) {
        var selectedEventName = event.getSource().get("v.value");
        
        //validation for None value in Event name:: Starts
        if(selectedEventName == 'None' || selectedEventName == ''){
            component.set("v.disabled",true);
            component.set("v.disabledNoTckt", true);
        }
        //validation for None value in Event name:: Ends
        else {
            component.set("v.disabled",false);
            
            var selectedEventName = event.getSource().get("v.value");
            
            component.set("v.selectedEventName", selectedEventName);
            //calling server side method to get the number of available tickets for selected eventname
            var action = component.get("c.getAvailableTickets");
            action.setParams({ eventName :  selectedEventName});
            
            action.setCallback(this, function(a){
                var avlblTickets = a.getReturnValue();
                //editing the existing record validation starts
                if(component.get("v.recordId") !== undefined && component.get("v.recordId") !== null && component.get("v.recordId") !== ' '){
                    if(avlblTickets <= 0 ){
                        component.set("v.disabled",true);	
                        component.set("v.disabledNoTckt",true);
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "All the tickets for the selected event has been booked.",
                            "type": "error"
                        });
                        toastEvent.fire();
                    }else{
                        component.set("v.disabledNoTckt",false);
                        component.set("v.disabled",false);
                    }
                }
                //Existing record validation ends
                //Normal record validation on creation starts
                else if(avlblTickets <= 0 ){
                    component.set("v.disabled",true);	
                    component.set("v.disabledNoTckt",true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "All the tickets for the selected event has been booked.",
                        "type": "error"
                    });
                    toastEvent.fire();
                }
                    else{
                        component.set("v.disabledNoTckt",false);
                        component.set("v.disabled",false);
                    }
                //Normal record validation on creation ends
                
                //iterating over the returned values to create the list to set in input select tickets available :: start
                var tcktList=[];
                for(var i=1; i<=avlblTickets; i++){
                    tcktList.push({value:i, 
                                   label:i}) ;
                }
                if(component.get("v.recordId") !== undefined && component.get("v.recordId") !== null 
                   && component.get("v.recordId") !== ' '){
                    component.set("v.avlblTicketonEdit", tcktList);
                    component.find("onEditTkts").set("v.value",'1');
                    
                }else{
                    component.set("v.gameTicktsAvlble", tcktList);
                    component.set("v.avalbleTickets", '1');
                    component.find("newTkts").set("v.value", '1');
                }
                
            });
            //ends
            $A.enqueueAction(action);
        } 
    },
    proceedtoCreateRecord:function(component, event, helper) {
           var evtTyp = component.find("selectItem").get("v.value"); 
           var evtName= component.find("eventSelect").get("v.value"); 
           var selevtName = component.get("v.selectedEventName");
           var TcktsAvlbl = component.find("newTkts").get("v.value");
                
           var SelectedTicketType=component.get("v.SelectedTicketType");
           var TicketRequested= component.get("v.TicketRequested"); 
           var Reason = component.get("v.Reason");
           var PhoneNo=component.get("v.PhoneNo");
           var TicketObj=[];
        
        
        if(component.get("v.isKendellReed")){ 
            if(component.get("v.skipRequiredField")){
                
                 if(evtTyp == 'None' || selevtName == 'None' || SelectedTicketType == 'None' || TicketRequested == 'None' || $A.util.isUndefinedOrNull(evtTyp) || $A.util.isUndefinedOrNull(selevtName) || $A.util.isUndefinedOrNull(SelectedTicketType) || $A.util.isUndefinedOrNull(TicketRequested) || $A.util.isUndefinedOrNull(PhoneNo) || $A.util.isUndefinedOrNull(Reason) || Reason == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!", 
                        "message": "Please select the appropriate values for all fields",
                        "type": "error" 
                    });
                    toastEvent.fire();
                } 
            
                else{
                    helper.proceedtoCreateRecordHelper(component, event); 
                }
                
            }
            
            else{
                  
                    if(component.get("v.selectedContactLookUpRecords").length == 0 || component.get("v.selectedContactLookUpRecords_Opp").length == 0   || evtTyp == 'None' || selevtName == 'None' || SelectedTicketType == 'None' || TicketRequested == 'None' || $A.util.isUndefinedOrNull(evtTyp) || $A.util.isUndefinedOrNull(selevtName) || $A.util.isUndefinedOrNull(SelectedTicketType) || $A.util.isUndefinedOrNull(TicketRequested) || $A.util.isUndefinedOrNull(PhoneNo) || $A.util.isUndefinedOrNull(Reason) || Reason == ''){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!", 
                            "message": "Please select the appropriate values for all fields",
                            "type": "error" 
                        });
                        toastEvent.fire();
                    } 
                
                else{
                    helper.proceedtoCreateRecordHelper(component, event); 
                }
            } 
           
        } 
         
        else{
                
            //alert("No isKendellReed");     
            
            if(component.get("v.selectedContactLookUpRecords").length == 0 || component.get("v.selectedContactLookUpRecords_Opp").length == 0   || evtTyp == 'None' || selevtName == 'None' || SelectedTicketType == 'None' || TicketRequested == 'None' || $A.util.isUndefinedOrNull(evtTyp) || $A.util.isUndefinedOrNull(selevtName) || $A.util.isUndefinedOrNull(SelectedTicketType) || $A.util.isUndefinedOrNull(TicketRequested) || $A.util.isUndefinedOrNull(PhoneNo) || $A.util.isUndefinedOrNull(Reason) || Reason == ''){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!", 
                        "message": "Please select the appropriate values for all fields",
                        "type": "error" 
                    });
                    toastEvent.fire();
                } 
            
            else{
                helper.proceedtoCreateRecordHelper(component, event); 
            }
        }
       
    },
    closeModal:function(component, event, helper) {
        component.set("v.showModal", false);
        var modalDiv = component.find("evtModal");
        $A.util.addClass(modalDiv,'slds-hide');
        var action = component.get("c.getListViews");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "Ticket_Request__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    getAvlblTickets:function(component, event, helper) {
        
        var map = {};
        map =component.get("v.TicketType_And_NoOfTicketAvilable");
        var opts=[];
        component.set("v.gameTicktsAvlble",[]);
        component.set("v.TicketRequested",'1'); 
        //alert(event.getSource().get("v.value"));
        component.set("v.SelectedTicketType",event.getSource().get("v.value"));
        
        if(event.getSource().get("v.value") != 'None' && map[event.getSource().get("v.value")].length > 0 ){
            if(component.get("v.showEditModal")){
                
                //component.set("v.avlblTicketonEdit", map[event.getSource().get("v.value")]); 
                for(var i=0;i<map[event.getSource().get("v.value")].length;i++){
                    opts.push({value:map[event.getSource().get("v.value")][i],label:map[event.getSource().get("v.value")][i]}) ;
                    //alert(map[event.getSource().get("v.value")][i]);
                   
                }
            	component.set("v.ToggleTicketNo",false);
                component.set("v.avlblTicketonEdit", opts); 
            }
            else{
                component.set("v.gameTicktsAvlble", map[event.getSource().get("v.value")]);  
            	component.set("v.ToggleTicketNo",false);
            }
            component.set("v.disabledNoTckt",false);
            
        }
        else{
            component.set("v.ToggleTicketNo",true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "No Ticket Avilable"+' '+ event.getSource().get("v.value") +' '+'Type',
                "type": "error"
            });
            toastEvent.fire();
            component.set("v.disabledNoTckt",true);
        }
    },
    
    saveUpdateChanges:function(component, event, helper) {
        
            var SelectedTicketType=component.get("v.SelectedTicketType");
            var TicketRequested= component.get("v.TicketRequested"); 
            
        	if(typeof(SelectedTicketType) == 'undefined' ||  SelectedTicketType == ''){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please select the appropriate values",
                "type": "error" 
            });
            toastEvent.fire();
           }  
        else{
            component.set("v.tRRecord.Number_of_Parking_Passes_Available__c",component.get("v.SelectedParkingPasses"));
            component.find("recordEditor").saveRecord($A.getCallback(function(saveResult) {
            if (saveResult.state === "SUCCESS" || saveResult.state === "DRAFT") {
                $A.get("e.force:closeQuickAction").fire()
                helper.editRecord(component, event, helper);
            } else if (saveResult.state === "INCOMPLETE") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Some technical error occured.",
                    "type": "error"
                });
                toastEvent.fire();
            } else if (saveResult.state === "ERROR") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Problem saving record, error: ' + 
                    JSON.stringify(saveResult.error),
                    "type": "error"
                });
                toastEvent.fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Unknown problem, state: ' + saveResult.state + ', error: ' + JSON.stringify(saveResult.error),
                    "type": "error"
                });
                toastEvent.fire();
            }
        }));
         }
            
        
    },
    
    getTicket_Type : function(component, event, helper) {
		var Event_Value=event.getSource().get("v.value");
        //alert(event.getSource().get("v.value"));
		component.set("v.selectedEventName", Event_Value);
        component.set("v.gameTicktsAvlble",[]);
        component.set("v.avlblTicketonEdit",[]);
        
        var Type=[];
        
        if(Event_Value != 'None'){
            helper.getTicketType(component, event ,Event_Value);
            helper.getNoOfPassesAvailble(component, event ,Event_Value);//Added by Nagendra
            component.set("v.disabledNoTckt",false);
            component.set("v.SelectedEventId",component.get("v.EventNameIdMap").get(Event_Value));
            //alert(component.get("v.SelectedEventId"));
            
        }
        else{
            Type = [{ value: "None", label: "None"}];
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": 'Please select an Event.',
                    "type": "error"
                });
                toastEvent.fire();
            
            component.set("v.disabledNoTckt",true);
            Type = [{ value: "None", label: "None"}];
            component.set("v.TicketType",[]);
            component.set("v.TicketType",Type);
            component.set("v.SelectedTicketType",'None');
        }   
    },
    setTicketRequested:function(component,event,helper){
        var Ticket_Value=event.getSource().get("v.value");
        component.set("v.TicketRequested",Ticket_Value);
    },
    handleRecordUpdated:function(component,event,helper){
        
    },
    ProcessToUpdateRecord:function(component,event,helper){
        
        var EventType=component.get("v.tRRecord.Event_Typ__c");
        var TicketType=component.get("v.tRRecord.Ticket_Typ__c");
        var EventNameandDate=component.get("v.tRRecord.Event_Name_Date__c");
        var NoOfTicketSelected=component.get("v.tRRecord.No_of_Tickets_Requested__c");
        var TicketRequestvalue=component.get("v.TicketRequest");
        var PhoneNo=component.get("v.PhoneNo");
        var Reason = component.get("v.Reason");
       
        if(Reason == '' || PhoneNo == null || typeof(TicketType) == 'undefined' ||  TicketType == '' ||  $A.util.isUndefinedOrNull(Reason)){
            
             var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Please Complete a Require Fields',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
           
        }
        
        /*
        else if((component.get("v.selectedContactLookUpRecords").length == 0 &&  component.get("v.skipRequiredField") == false) || (component.get("v.selectedContactLookUpRecords_Opp").length == 0 && component.get("v.skipRequiredField") == false)){
            //alert(component.get("v.skipRequiredField"));
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message:'Please Select Contact and Opportunity',
                    messageTemplate: 'Mode is pester ,duration is 5sec and Message is overrriden',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
        }*/
       else{
               TicketRequestvalue.Id=component.get("v.recordId");
                TicketRequestvalue.Event_Typ__c=EventType;
                TicketRequestvalue.Event_Name_Date__c=EventNameandDate;
                TicketRequestvalue.No_of_Tickets_Requested__c=NoOfTicketSelected;
                TicketRequestvalue.Name=EventType + ' - ' + EventNameandDate;
                TicketRequestvalue.Ticket_Type__c='User Assigned';
                //TicketRequestvalue.Approval_Status__c='Approved';
                TicketRequestvalue.Number_of_Parking_Passes_Available__c= component.get("v.SelectedParkingPasses");
                TicketRequestvalue.Ticket_Typ__c=TicketType; 
                TicketRequestvalue.Phone_Number__c=PhoneNo.toString();
                TicketRequestvalue.Other_Employee_Reps_Attending__c=component.get("v.ListAttende");
                TicketRequestvalue.Additional_Info__c=component.get("v.Reason");

        		var junctiontactList_Insert=[];
                var juncttionOpportunityList_Insert=[]; 
                
        		var selectedContactLookUpRecords=component.get("v.selectedContactLookUpRecords");
                var selectedContactLookUpRecords_Opp=component.get("v.selectedContactLookUpRecords_Opp");
        
                for(var i=0;i<selectedContactLookUpRecords.length;i++){
                    junctiontactList_Insert.push({'sobjectType':'Junction_Ticket_Contact__c','Related_Contact__c':selectedContactLookUpRecords[i].Id,'Related_Ticket_Request__c':component.get("v.recordId")});
                }
                
                for(var i=0;i<selectedContactLookUpRecords_Opp.length;i++){
                    juncttionOpportunityList_Insert.push({'sobjectType':'Junction_Ticket_Opportunity__c','Related_Opprtunity_to_Request__c':selectedContactLookUpRecords_Opp[i].Id,'Related_TicketRequest__c':component.get("v.recordId")});
                }
               
               var action = component.get("c.UpdateTicketRequest");
                action.setParams({
                    "TcktObj":TicketRequestvalue
                }); 
        
                action.setCallback(this,function(resp){
        
                    var state = resp.getState();
        
                    if(state === 'SUCCESS'){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    }
                    else if(state === 'ERROR'){
                        var errors = resp.getError();
                        for(var i = 0 ;i < errors.length;i++){
                            console.log(errors[i].message);
                        }
                    }
        
                });
        
                $A.enqueueAction(action); 
       }
 		
    },
    closeEditModal:function(component,event,helper){
        //component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.recordId"),
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
    }
})