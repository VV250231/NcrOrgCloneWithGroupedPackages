({
	doInit: function(component, event, helper) {
        component.set('v.columns', [
            {label: 'Quote No.', fieldName: 'QuoteNumber', type: 'text', sortable: true},
            {label: 'Quote Name', fieldName: 'QuoteName', type: 'text',sortable: true},
            {label: 'Quote Value', fieldName: 'QuoteAmount', type: 'text',sortable: true},
            {label: 'Order No.', fieldName: 'OrderNumber', type: 'text',sortable: true},
            {label: 'Order Type.', fieldName: 'OrderType', type: 'text',sortable: true},
            {label: 'Modified Date', fieldName: 'modificationDate', type: 'date', sortable: true},
            {label: 'Solution Status', fieldName: 'SolutionQuoteStatus', type: 'text',sortable: true},
            {label: 'Annuity Status', fieldName: 'AnnuityQuoteStatus', type: 'text',sortable: true}
        ]);
        helper.availableQuoteHelper(component,event, helper);
        
        
    },
    
    loadMoreData: function (cmp, event, helper) {
        console.log('loadMoreData');
        console.log('totalNumberOfRows' + cmp.get('v.totalNumberOfRows'));
        //Display a spinner to signal that data is being loaded
        event.getSource().set("v.isLoading", true);
        //Display "Loading" when more data is being loaded
        cmp.set('v.loadMoreStatus', 'Loading');
        helper.fetchData(cmp)
            .then($A.getCallback(function (data) {
                console.log('data');
                console.log(data.length);
                if (cmp.get('v.filteredData').length >= cmp.get('v.totalNumberOfRows')) {
                    cmp.set('v.enableInfiniteLoading', false);
                    cmp.set('v.loadMoreStatus', 'No more data to load');
                     console.log('No more data to load');
                } else {
                    var currentData = cmp.get('v.filteredData');
                    console.log('currentData' + currentData.length);
                    //Appends new data to the end of the table
                    var newData = currentData.concat(data);
                    console.log('newData' + newData.length);
                    cmp.set('v.filteredData', newData);
                    cmp.set('v.loadMoreStatus', '');
                }
               event.getSource().set("v.isLoading", false);
            }));
    },
    filter: function(component, event, helper) {
        console.log('filter>>>>');
        var data = component.get("v.data"),
            term = component.get("v.filter"),
            results = data, regex;
        
            regex = new RegExp(term, "i");
            // filter checks each row, constructs new array where function returns true
            results = data.filter(row=>regex.test(row.QuoteNumber));
            console.log('results>>>>>>' + results);
             if(results.length <= 20){
                  
            component.set("v.enableInfiniteLoading", false);
             }else{
                  
                 component.set("v.enableInfiniteLoading", true);
             }
         
        component.set("v.filteredData", results);
       
    },
    // Client-side controller called by the onsort event handler
    updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        // assign the latest attribute with the sorted column fieldName and sorted direction
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    getSelectedRow : function(component, event, helper){
        console.log('updateSelectedText');
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows'+JSON.stringify(selectedRows));
        //console.log('selectedRows>>>>');
        //console.log('selectedRowsid>>>>>>>'+selectedRows[0].id);
        //component.set("v.selectedRowsCount" ,selectedRows.length );
        //console.log('selectedRows'+selectedRows.length);
        var appEvent = $A.get("e.c:quoteSelectionEvent");
        console.log('appEvent>>>' + appEvent);
        appEvent.setParams({
            "selectedRow" : selectedRows.length });
        appEvent.fire();
        console.log('appEventfire>>>' + appEvent);
        var selectedQuotsId = [];
        for( var i = 0; i<selectedRows.length; i++) {
         selectedQuotsId.push(selectedRows[i].id);
        }
        console.log('selectedQuotsId1>>>>>>>'+selectedQuotsId);
        component.set("v.selectedQuotsId",selectedQuotsId);
        var selectedQuotsId2 = component.get("v.selectedQuotsId")
        console.log('selectedQuotsId2>>>>>>>'+selectedQuotsId2);
    }, 
    handleAssociationEvent : function(component, event, helper) {
        console.log('handleAssociationEvent>>>>>>>>>>>>');
        helper.associateQuots(component,event, helper);
    }
})