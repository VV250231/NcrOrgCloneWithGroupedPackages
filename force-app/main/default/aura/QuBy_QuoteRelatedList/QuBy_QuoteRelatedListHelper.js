({
    getsObjectRecords: function(component, event, helper) {
        component.set("v.arrowDirection","arrowup");
        component.set("v.isAsc",true);
        component.set("v.selectedTabsoft","QuoteNumber");
        var action = component.get("c.getRecords");
        action.setParams({
            opportunityId : component.get("v.opportunityId")            
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();                
                component.set( "v.AlldataList",retResponse.sObjectrecords ); 
                component.set( "v.total",retResponse.total );
                
                ////INITIAL LOAD////
                var data = retResponse.sObjectrecords;
                var numberOfRecord = component.get("v.pageSize");
                var opts = [];
                var totalRecords = retResponse.total;
                for( var i=0; i < numberOfRecord ; i++ ){
                    if( i < totalRecords ){
                        opts.push( data[i] );
                    }
                }
                component.set( "v.dataList",opts );
                component.set( "v.pages",Math.ceil( retResponse.total / component.get("v.pageSize") ) );                
                ////INITIAL LOAD////
                
            }else if (state === "ERROR") {
                console.log('Error');
            }
            component.set( "v.toggleSpinner",false );
        });
        $A.enqueueAction(action); 
    },      
    previousPageHelper : function(component, event, helper) {        
        var data = component.get( "v.AlldataList" );
        component.set("v.page",component.get("v.page") - 1);        
        var offset = parseInt( component.get("v.offset") ) - parseInt( component.get("v.pageSize") );
        var max_length = offset + parseInt( component.get("v.pageSize") );        
        var opts = [];
        for( var i = offset; i < max_length; i++ ){            
            opts.push( data[i] );            
        }
        component.set( "v.dataList",opts );
        component.set("v.offset",offset);
        component.set( "v.toggleSpinner",false );
    },
    nextPageHelper : function(component, event, helper) {        
        var data = component.get( "v.AlldataList" );
        component.set("v.page",component.get("v.page") + 1);
        var offset = parseInt( component.get("v.offset") ) + parseInt( component.get("v.pageSize") );
        var max_length = offset + parseInt( component.get("v.pageSize") );
        var totalRecords = component.get("v.total");
        var opts = [];
        for( var i = offset; i < max_length; i++ ){
            if( i < totalRecords ){
                opts.push( data[i] );
            }
        }
        component.set( "v.dataList",opts );        
        component.set("v.offset",offset);
        component.set( "v.toggleSpinner",false );
    },
    selectAllHelper: function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value");        
        var getAllId = component.find("Chk");        
        if( getAllId != null && getAllId != '' ){
            if ( selectedHeaderCheck === true ) {
                for ( var i = 0; i < getAllId.length; i++ ) {
                    component.find( "Chk" )[i].set( "v.value", true );                
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find( "Chk" )[i].set("v.value", false);                
                }
            }
        }
    },
    selectAllAssoHelper: function(component, event, helper) {        
        var selectedHeaderCheck = event.getSource().get("v.value");        
        var getAllId = component.find("ChkAsso");        
        if( getAllId != null && getAllId != '' ){
            if ( selectedHeaderCheck === true ) {
                for ( var i = 0; i < getAllId.length; i++ ) {
                    component.find( "ChkAsso" )[i].set( "v.value", true );                
                }
            } else {
                for (var i = 0; i < getAllId.length; i++) {
                    component.find( "ChkAsso" )[i].set("v.value", false);                
                }
            }
        }
    },
    deleteSelectedHelper: function(component, event, delId) {                
        var action = component.get("c.disAssociateQuote");                
        action.setParams({
            disQuoteId : delId,
            OpportunityID : component.get("v.opportunityId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({                        
                    "message": retResponse.Message,
                    "type":retResponse.type
                });
                toastEvent.fire();
                
            }else if (state === "ERROR") {
                console.log('Error');
            }
            this.getsObjectRecords( component );  
            component.set( "v.toggleSpinner",false );
        });        
        $A.enqueueAction(action);
    },
    availableQuoteHelper : function(component,page) {               
        component.set("v.arrowDirection","arrowup");
        component.set("v.isAsc",true);
        component.set("v.selectedTabsoft","QuoteNumber");
        
        var action = component.get("c.getAvailableQuotes");        
        action.setParams({
            opportunityId : component.get("v.opportunityId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();                
                component.set( "v.AlldataList",retResponse.sObjectrecords ); 
                component.set( "v.total",retResponse.total );
                ////INITIAL LOAD////
                var data = retResponse.sObjectrecords;
                var numberOfRecord = component.get("v.pageSize");
                var opts = [];
                var totalRecords = retResponse.total;
                for( var i=0; i < numberOfRecord ; i++ ){
                    if( i < totalRecords ){
                        opts.push( data[i] );
                    }
                }
                component.set( "v.dataList",opts );
                component.set( "v.pages",Math.ceil( retResponse.total / component.get("v.pageSize") ) );
            }else if (state === "ERROR") {
                console.log('Error');
            }
            component.set( "v.toggleSpinner",false );
        });
        $A.enqueueAction(action);        
    }, 
    associateQuoteHelper: function(component, event, QDId) {                
        var action = component.get("c.associateQuote");                
        action.setParams({
            QuoteId : QDId,
            OpportunityID : component.get("v.opportunityId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({                        
                    "message": retResponse.Message,
                    "type":retResponse.type
                });
                toastEvent.fire();                
            }else if (state === "ERROR") {
                console.log('Error');
            }
            component.set( "v.isDisAssociate",true );
            component.set( "v.isAssociate",false );
            this.getsObjectRecords( component );            
        });        
        $A.enqueueAction(action);
    },
    goBackHelper: function(component, event, helper) {
        component.set( "v.isDisAssociate",true );
        component.set( "v.isAssociate",false );
        this.getsObjectRecords( component ); 
    },
    itemPerPageHelper: function(component, event, helper) {
        component.set("v.page",1);
        component.set("v.offset",0);       
        this.getsObjectRecords( component );
    },
    searchHelper: function(component,page) {
        component.set("v.arrowDirection","arrowup");
        component.set("v.isAsc",true);
        component.set("v.selectedTabsoft","QuoteNumber");
        
        var searchString = component.get("v.searchStr");        
        if( searchString != null && searchString != '' && searchString.trim().length > 0 ){            
            var action = component.get("c.search");               
            action.setParams({
                opportunityId : component.get("v.opportunityId"),
                searchstr: searchString
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){                    
                    var retResponse = response.getReturnValue();                
                    component.set( "v.AlldataList",retResponse.sObjectrecords );                
                    component.set( "v.total",retResponse.total );
                    ////INITIAL LOAD////
                    var data = retResponse.sObjectrecords;
                    var numberOfRecord = component.get("v.pageSize");
                    var opts = [];
                    var totalRecords = retResponse.total;
                    for( var i=0; i < numberOfRecord ; i++ ){
                        if( i < totalRecords ){
                            opts.push( data[i] );
                        }
                    }
                    component.set( "v.dataList",opts );
                    component.set( "v.pages",Math.ceil( retResponse.total / component.get("v.pageSize") ) );
                    ////INITIAL LOAD////
                }else if (state === "ERROR") {
                    console.log('Error');
                }
                component.set( "v.toggleSpinner",false );
            });
            $A.enqueueAction(action);
        }else{
            component.set( "v.toggleSpinner",false );
        }
    },
    searchAssoHelper: function(component,page) {
        component.set("v.arrowDirection","arrowup");
        component.set("v.isAsc",true);
        component.set("v.selectedTabsoft","QuoteNumber");
        
        var searchString = component.get("v.searchStr");        
        if( searchString != null && searchString != '' && searchString.trim().length > 0 ){            
            var action = component.get("c.searchAvailableQuotes");
            action.setParams({
                opportunityId : component.get("v.opportunityId"),
                searchstr: searchString
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){                    
                    var retResponse = response.getReturnValue();                
                    component.set( "v.AlldataList",retResponse.sObjectrecords );                                    
                    component.set( "v.total",retResponse.total );
                    ////INITIAL LOAD////
                    var data = retResponse.sObjectrecords;
                    var numberOfRecord = component.get("v.pageSize");
                    var opts = [];
                    var totalRecords = retResponse.total;
                    for( var i=0; i < numberOfRecord ; i++ ){
                        if( i < totalRecords ){
                            opts.push( data[i] );
                        }
                    }
                    component.set( "v.dataList",opts );
                    component.set( "v.pages",Math.ceil( retResponse.total / component.get("v.pageSize") ) );
                    ////INITIAL LOAD////
                }else if (state === "ERROR") {
                    console.log('Error');
                }
                component.set( "v.toggleSpinner",false );
            });
            $A.enqueueAction(action);
        }else{
            component.set( "v.toggleSpinner",false );
        }
    },
    closeSearchModalHelper: function(component, event, helper) {
        var fromWhereWeCome = component.get( "v.fromWhereSearch" );
        if( fromWhereWeCome === 'DIS' ){
            component.set( "v.isDisAssociate",true );                    
            component.set( "v.isSearch",false );
            component.set( "v.searchStr","" );	
            this.getsObjectRecords( component );
        }else{
            component.set( "v.isAssociate",true );                    
            component.set( "v.isSearch",false );
            component.set( "v.searchStr","" );		
            this.availableQuoteHelper( component );
        }
    },
    sortColumnHelper:function(component, event, sortFieldName, asc) {
        var arr = component.get( "v.AlldataList" );        
        arr = arr.sort(function(a, b) {            
            if (asc) {
                return (a[sortFieldName] > b[sortFieldName]) ? 1 : ((a[sortFieldName] < b[sortFieldName]) ? -1 : 0);                
            } else {
                return (b[sortFieldName] > a[sortFieldName]) ? 1 : ((b[sortFieldName] < a[sortFieldName]) ? -1 : 0);
            }
        });
        component.set( "v.AlldataList",arr );
        var numberOfRecord = component.get("v.pageSize");
        var opts = [];
        for( var i=0; i < numberOfRecord ; i++ ){
            console.log( arr[i] );
            if( arr[i] != null && arr[i] != '' ){
            	opts.push( arr[i] );
            }
        }
        
        component.set( "v.dataList",opts );
        component.set( "v.toggleSpinner",false );
    },
    sortHelper: function(component, event, sortFieldName) {
        var currentDir = component.get("v.arrowDirection"); 
        if (currentDir == 'arrowdown') {
            // set the arrowDirection attribute for conditionally rendred arrow sign  
            component.set("v.arrowDirection", 'arrowup');
            // set the isAsc flag to true for sort in Assending order.  
            component.set("v.isAsc", true);
        } else {
            component.set("v.arrowDirection", 'arrowdown');
            component.set("v.isAsc", false);
        }
        // call the onLoad function for call server side method with pass sortFieldName 
        var asc = component.get("v.isAsc");
        this.sortColumnHelper(component, event, sortFieldName, asc);
    },
    
    createQuotePopup : function (component, event, helper) { 
        var recordId = component.get("v.recordId");
        console.log('recordId>>>>>>>' + recordId);
        var modalHeader; 
        var modalBody;
        var modalFooter;
        $A.createComponents([
            ["c:QuotePopupHeader",{}],
            ["c:QuotePopupContent",{opportunityId : component.get("v.opportunityId") }],
            ["c:QuotePopupFooter",{}]
        ],
                            function(components, status){
                                if (status === "SUCCESS") {
                                    modalHeader = components[0];
                                    modalBody = components[1];
                                    modalFooter = components[2];
                                    component.find('overlayLib').showCustomModal({
                                        header: modalHeader,
                                        body: modalBody, 
                                        footer: modalFooter,
                                        showCloseButton: true,
                                        cssClass: "slds-modal_medium",
                                        closeCallback: function() {
                                            

                                        }
                                    }).then(function (overlay) {
                                        console.log(overlay);
                                    });
                                }
                            }
                           );
    },
})