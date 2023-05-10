({
    doInit : function(component, event, helper) {
        var action = component.get("c.isDisabled");
        component.set( "v.toggleSpinner",true );        
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){                
                var retResponse = response.getReturnValue();                
                if( retResponse == true ){
                    component.set("v.disabled",retResponse);
                    component.set( "v.toggleSpinner",false );                    
                }else{
                    component.set("v.isDisAssociate",true);
                    helper.getsObjectRecords(component); 
                }
                
            }else if (state === "ERROR") {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
       
    },
    previousPage : function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        helper.previousPageHelper(component, event, helper);
    },
    nextPage : function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        helper.nextPageHelper(component, event, helper);
    },
    selectAll: function(component, event, helper) {
        helper.selectAllHelper(component, event, helper);
    },
    selectAllAsso: function(component, event, helper) {
        helper.selectAllAssoHelper(component, event, helper);
    },
    disAssociateQuoteJS: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        var delId = [];
        var getAllId = [];
        getAllId = component.find("Chk");        
        
        if( getAllId != null && getAllId != '' ){
            if( getAllId.length == null ){
                if ( getAllId.get( "v.value" ) == true ) {
                    delId.push( getAllId.get( "v.text" ) );
                }
            }else{
                for ( var i = 0; i < getAllId.length; i++ ) {                    
                    if ( getAllId[i].get( "v.value" ) == true ) {
                        console.log( '::::delIdB::::' + delId );
                        delId.push( getAllId[i].get( "v.text" ) );
                        console.log( '::::delIdA::::' + delId );
                    }
                }
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "There is no quote to disassociate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
        }
        
        
        if( delId.length > 0 ){
            helper.deleteSelectedHelper(component, event, delId);            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "Please select atleast one quote to disassociate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
        }  
        
    },
    availableQuoteJS: function(component, event, helper) {
        helper.createQuotePopup(component, event, helper);
        /*component.set( "v.toggleSpinner",true );
        component.set( "v.isDisAssociate",false );
        component.set( "v.isAssociate",true );        
        helper.availableQuoteHelper(component);*/ 
        
    },
    AssociateQuoteJS: function(component, event, helper) {
        /* PREVIOUS CODE
        component.set( "v.toggleSpinner",true );
        var QDId = [];
        var getAllId = component.find("ChkAsso");
        for ( var i = 0; i < getAllId.length; i++ ) {
            if ( getAllId[i].get( "v.value" ) == true ) {
                QDId.push( getAllId[i].get( "v.text" ) );
            }
        }
        if( QDId.length > 0 ){
            helper.associateQuoteHelper(component, event, QDId);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "Please select atleast one quote to Associate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
        } 
        */
        component.set( "v.toggleSpinner",true );
        var QDId = [];
        var getAllId = [];
        getAllId = component.find("ChkAsso");
        
        if( getAllId != null && getAllId != '' ){
            if( getAllId.length == null ){
                if ( getAllId.get( "v.value" ) == true ) {
                    QDId.push( getAllId.get( "v.text" ) );
                }
            }else{
                for ( var i = 0; i < getAllId.length; i++ ) {                    
                    if ( getAllId[i].get( "v.value" ) == true ) {                        
                        QDId.push( getAllId[i].get( "v.text" ) );                        
                    }
                }
            }
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "There is no quote to Associate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
        }
        
        if( QDId.length > 0 ){
            helper.associateQuoteHelper(component, event, QDId);            
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "Please select atleast one quote to Associate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
        }
    },
    
    goBack: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        helper.goBackHelper(component, event, helper);
    },
    itemPerPage: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        helper.itemPerPageHelper(component, event, helper);
    },
    searchJS: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        component.set( "v.isDisAssociate",false );                    
        component.set( "v.isSearch",true );  
        component.set( "v.fromWhereSearch","DIS" );  
        helper.searchHelper(component);
    },
    searchJSAsson: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        component.set( "v.isAssociate",false );                    
        component.set( "v.isSearch",true );  
        component.set( "v.fromWhereSearch","ASSO" );
        helper.searchAssoHelper(component);
    },
    closeSearchModal: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        helper.closeSearchModalHelper(component, event, helper);
    },
    SearchAsso: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        var QDId = [];
        var getAllId = component.find("ChkSer");
        if( getAllId != null && getAllId != '' ){
            for ( var i = 0; i < getAllId.length; i++ ) {
                if ( getAllId[i].get( "v.value" ) == true ) {
                    QDId.push( getAllId[i].get( "v.text" ) );
                }
            }
            if( QDId.length > 0 ){
                helper.associateQuoteHelper(component, event, QDId);
                component.set( "v.searchStr","" );
                helper.closeSearchModalHelper(component, event, helper);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({                        
                    "message": "Please select atleast one quote to Associate.",
                    "type":"info"
                });
                toastEvent.fire();
                component.set( "v.toggleSpinner",false );
                component.set( "v.searchStr","" );	
                helper.closeSearchModalHelper(component, event, helper);
            } 
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "There is no quote to Associate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
            component.set( "v.searchStr","" );	
            helper.closeSearchModalHelper(component, event, helper);
        }
    },
    SearchDiss: function(component, event, helper) {
        component.set( "v.toggleSpinner",true );
        var delId = [];
        var getAllId = component.find("ChkSer");
        if( getAllId != null && getAllId != '' ){
            for ( var i = 0; i < getAllId.length; i++ ) {
                if ( getAllId[i].get( "v.value" ) == true ) {
                    delId.push( getAllId[i].get( "v.text" ) );
                }
            }
            if( delId.length > 0 ){
                helper.deleteSelectedHelper(component, event, delId);     
                component.set( "v.searchStr","" );	
                helper.closeSearchModalHelper(component, event, helper);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({                        
                    "message": "Please select atleast one quote to disassociate.",
                    "type":"info"
                });
                toastEvent.fire();
                component.set( "v.toggleSpinner",false );
                component.set( "v.searchStr","" );	
                helper.closeSearchModalHelper(component, event, helper);
            }  
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({                        
                "message": "There is no quote to disassociate.",
                "type":"info"
            });
            toastEvent.fire();
            component.set( "v.toggleSpinner",false );
            component.set( "v.searchStr","" );	
            helper.closeSearchModalHelper(component, event, helper);
        }
    },
    sortColumn: function(component, event, helper) {    
        component.set( "v.toggleSpinner",true );
        var prop = event.currentTarget.id;
        component.set("v.selectedTabsoft", prop);
        helper.sortHelper(component, event, prop);        
    },
    QBRedirect: function(component, event, helper) {
        var quoteNo = event.currentTarget.id;
        var oppId = component.get("v.opportunityId");
        /*
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/apex/Quote_Builder_Redirect?qno='+quoteNo+'&opportunityId='+oppId
        });
        urlEvent.fire();
        */
        var url1="/apex/qb_landing_page?qno="+quoteNo+"&opportunityId="+oppId;
        window.open(url1,'_blank'); 
    },
    handleQuotseUpdate : function(component, event, helper) {
		helper.getsObjectRecords(component); 
	}
})