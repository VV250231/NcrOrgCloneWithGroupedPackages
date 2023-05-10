({
	availableQuoteHelper : function(component,event, helper) {               
       
        component.set("v.showSpinner", true);
        var action = component.get("c.getAvailableQuotes");        
        action.setParams({
            opportunityId : component.get("v.opportunityId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var retResponse = response.getReturnValue();                
                component.set( "v.data",retResponse.sObjectrecords );
                component.set( "v.totalNumberOfRows",retResponse.total);
                var appEvent = $A.get("e.c:quoteSelectionEvent");
                appEvent.setParams({
                    "isAvailableCount" : true,"totelRows" : retResponse.total });
                appEvent.fire();
                //component.set( "v.filteredData",retResponse.sObjectrecords );                
                this.fetchData(component).then($A.getCallback(function (data) {
                    console.log('datareturn');
                    console.log(data.length);
                    component.set('v.filteredData', data);
                    component.set("v.showSpinner", false);
                   
                }));
            }else if (state === "ERROR") {
                console.log('Error');
            }
            component.set( "v.toggleSpinner",false );
        });
        $A.enqueueAction(action);        
    },
    
    
    
    fetchData: function(component ){ 
        return new Promise($A.getCallback(function(resolve, reject) {
            var currentDatatemp = component.get('c.availableQuotesInBatches');
            var counts = component.get("v.currentCount");
            console.log('counts' + counts);
            console.log('initialRows' + component.get("v.initialRows"));
            currentDatatemp.setParams({
                opportunityId : component.get("v.opportunityId"),
                "limits": component.get("v.initialRows"),
                "offsets": counts 
            });
            currentDatatemp.setCallback(this, function(a) {
                console.log('currentDatatemp');
                console.log(a.getReturnValue());
                resolve(a.getReturnValue().sObjectrecords);
                var countstemps = component.get("v.currentCount");
                countstemps = countstemps+component.get("v.initialRows");
                component.set("v.currentCount",countstemps);
                
            });
            $A.enqueueAction(currentDatatemp);
            
            
        }));
        
    },
    
    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.filteredData");
        var reverse = sortDirection !== 'asc';
        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse))
        cmp.set("v.filteredData", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
        function(x) {return x[field]};
        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },
    associateQuots : function(component,event, helper) {
        component.set("v.showSpinner", true);
        console.log('insideassociateQuots>>>>>>>');
        var selectedQuotsId3 = component.get("v.selectedQuotsId")
        console.log('selectedQuotsId3>>>>>>>'+selectedQuotsId3);
        console.log('selectedQuotsId>>' + component.get("v.selectedQuotsId"));
        if($A.util.isEmpty(selectedQuotsId3)){
            console.log('inside empty>>>>>>>');
            var appEvent = $A.get("e.c:showQuotsError");
            appEvent.setParams({  "errorMessage" : 'Please select at least one Quote.'});
            appEvent.fire();
            component.set("v.showSpinner", false);
        }else{
            var action = component.get("c.associateQuote");        
        action.setParams({
            OpportunityID : component.get("v.opportunityId"),
            QuoteId : component.get("v.selectedQuotsId")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.showSpinner", false);
                var responseValue = response.getReturnValue();
                console.log('responseValue>>>>' + responseValue);
                if(responseValue.type == 'success'){
                    var appEvent1 = $A.get("e.c:QuoteUpdate");
                    appEvent1.fire();
                    var appEvent = $A.get("e.c:closeQuotsAssociation");
                    appEvent.setParams({  "msg" : responseValue.Message});
                    appEvent.fire();
                    console.log('appEvent>>>>' + appEvent);
                }else
                    if(responseValue.type == 'error'){
                    var appEvent = $A.get("e.c:showQuotsError");
                    appEvent.setParams({  "errorMessage" : responseValue.Message});
                    appEvent.fire();
                    console.log('appEvent>>>>' + appEvent);
                        
                    }
                
            }else if (state === "ERROR") {
                console.log('Error');
            }
            component.set( "v.toggleSpinner",false );
        });
        $A.enqueueAction(action);  
        }
              
    }
})