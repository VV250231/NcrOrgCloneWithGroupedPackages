({
    init: function (cmp, event, helper) {
        helper.CreateOpp(cmp, event, helper);
        helper.fetchData(cmp,helper);
        helper.initColumnsWithActions(cmp, event, helper);
    },
    
    handleColumnsChange: function (cmp, event, helper) {
    	helper.initColumnsWithActions(cmp, event, helper);
    },
    
    handleRowAction: function (cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var onRowActionHandler = cmp.get('v.onRowActionHandler');

        if(onRowActionHandler){
            $A.enqueueAction(onRowActionHandler)                       
        }else{            
            switch (action.name) {
                case 'edit':
                    helper.editRecord(cmp, row,helper)
                    break;
                case 'delete':
                    helper.removeRecord(cmp, row)
                    break;
            }
        }
    },
    
    handleGotoRelatedList : function (cmp, event, helper) {
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": cmp.get("v.parentRelationshipApiName"),
            "parentRecordId": cmp.get("v.recordId")
        });
        relatedListEvent.fire();
    },
       
	handleCreateRecord : function (cmp, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": cmp.get("v.sobjectApiName"),
            "defaultFieldValues": {
                [cmp.get("v.relatedFieldApiName")] : cmp.get("v.recordId")
            },
            "navigationLocation": "RELATED_LIST"
        });
        createRecordEvent.fire();
        //helper.fetchData(cmp,helper);
	},   
        
	handleToastEvent  : function (cmp, event, helper) {
        var eventType = event.getParam('type');
        var eventMessage= event.getParam('message');
        if(eventType == 'success' /*&& eventMessage.includes(cmp.get('v.sobjectLabel'))*/){
            helper.fetchData(cmp, helper)
        	event.stopPropagation();            
        }        
	},   
    searchFunc : function(cmp, event, helper){
        var searchKey = cmp.get("v.srchKey").toLowerCase();
        var data = cmp.get("v.records");  
        var allData = cmp.get("v.UnfilteredData");  
        if(data!=undefined || data.length>0){  
            //var filtereddata = allData.filter(word => (!searchKey) || word.Name.toLowerCase().indexOf(searchKey.toLowerCase()) > -1);
            var filtereddata = helper.findInValues(allData,searchKey);
        }  
        if(cmp.get("v.isViewAll")!=true){
        	cmp.set("v.records", filtereddata.slice(0,cmp.get("v.numberOfRecords")));  
        }else{
            cmp.set("v.records", filtereddata); 
        }
        if(searchKey==''){  
            cmp.set("v.data",cmp.get("v.UnfilteredData"));  
        }  
    },
    redirectToViewAll : function(component, event, helper) {
	    var navService = component.find("navService");
        // Uses the pageReference definition in the init handler
        /*var pageReference = component.get("v.pageReference");
        event.preventDefault();
        navService.navigate(pageReference); */
        //alert( JSON.stringify(component.get("v.allfields")));
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:Common_relatedList",
            componentAttributes: {
                "recordId":component.get("v.recordId"),
                "sobjectApiName": component.get("v.sobjectApiName"),
                "relatedFieldApiName": component.get("v.relatedFieldApiName"),
                "fields": component.get("v.allfields"),
                "columns": component.get("v.ViewAllColumns"),
                "sortedBy":component.get("v.sortedBy"),
                "sortedDirection": component.get("v.sortedDirection"),
                "isViewAll" : true
            }
        });
        evt.fire();
	},
    //Method gets called by onsort action,
    handleSort : function(component,event,helper){
        //alert(JSON.stringify(event));
        //Returns the field which has to be sorted
        var columns = component.get("v.columns")
        var sortBy = event.getParam("fieldName");
         var sortByCol = columns.find(column => sortBy === column.fieldName);
  		 var fieldTyp = sortByCol.type;
        //alert(fieldLabel);
        //returns the direction of sorting like asc or desc
        var sortDirection = event.getParam("sortDirection");
        //Set the sortBy and SortDirection attributes
        component.set("v.sortedBy",sortBy);
        component.set("v.sortedDirection",sortDirection);
        // call sortData helper function
        helper.sortData(component,sortBy,sortDirection,fieldTyp);
    },
    goBack: function (component){
		var navService = component.find("navService");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:CustomerHierarchy",
            componentAttributes: {
                "showHierarchy" : "true",
                "recordId" :  component.get("v.recordId"),
                 "Seltab" : "one",
            }
        });
        evt.fire();
    }
    
})