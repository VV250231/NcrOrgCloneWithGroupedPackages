({
    fetchData: function (cmp,helper) {
        cmp.set("v.showSpinner",true);
        var action = cmp.get("c.initData")
        var relatedFieldApiName = cmp.get("v.relatedFieldApiName")
        var numberOfRecords = cmp.get("v.numberOfRecords")
        var jsonData = JSON.stringify({fields:cmp.get("v.fields"),
                                       relatedFieldApiName:cmp.get("v.relatedFieldApiName"),
                                       recordId:cmp.get("v.recordId"),
                                       numberOfRecords:numberOfRecords,
                                       sobjectApiName: cmp.get("v.sobjectApiName"),
                                       sortedBy: cmp.get("v.sortedBy"),
                                       sortedDirection: cmp.get("v.sortedDirection"),
                                       isViewAll: cmp.get("v.isViewAll")
                                      });
        action.setParams({jsonData : jsonData});
        action.setCallback(this, function(response) {
            cmp.set("v.showSpinner",false);
            var state = response.getState();
            if (state === "SUCCESS") {
                var jsonData = JSON.parse(response.getReturnValue())
                var records = jsonData.records
                console.log('@@'+JSON.stringify(jsonData));
                /*if(records.length > numberOfRecords){
                    records.pop()
                    cmp.set('v.numberOfRecordsForTitle', numberOfRecords + "+")
                }else{
                    cmp.set('v.numberOfRecordsForTitle', Math.min(numberOfRecords,records.length))
                }*/
                cmp.set('v.numberOfRecordsForTitle', Math.min(records.length))
                records.forEach(record => {
                    record.LinkName = '/'+record.Id
                    for (const col in record) {
                    	const curCol = record[col];
                    
                    	if (typeof curCol === 'object') {
                    		console.log(col+'!!'+curCol.Type);
                    		if(col==='Account'){
                    			const newVal1 = curCol.Name ? curCol.Name : null;
                    			console.log(col+'!!@'+newVal1);
                    			if (newVal1 !== null) {
                    				record.AccountName = newVal1;
                    				//record[AccountName] = newVal1;
                				}
                        	}
                        	if(col==='Owner'){
                    			const newVal2 = curCol.LastName ? curCol.LastName : null;
                    			console.log(col+'!!@'+newVal2);
                    			if (newVal2 !== null) {
                        			record.OwnerName = newVal2;
                        			//record[AccountName] = newVal1;
                    			}
                			}
                			const newVal = curCol.Id ? ('/' + curCol.Id) : null;
                			this.flattenStructure(helper,record, col + '_', curCol);
                			if (newVal !== null) {
                    			record[col+ '_LinkName'] = newVal;
                			}
            			}
       		 		}
               });
        	//const recs = records.slice(0, 4);
        if(cmp.get("v.isViewAll")!=true){
            cmp.set('v.records', records.slice(0,cmp.get("v.numberOfRecords")));
        }else{
        	cmp.set('v.records', records);
        }
            cmp.set("v.UnfilteredData",records);
            cmp.set('v.iconName', jsonData.iconName);
            cmp.set('v.sobjectLabel', jsonData.sobjectLabel);
            cmp.set('v.sobjectLabelPlural', jsonData.sobjectLabelPlural);
            cmp.set('v.parentRelationshipApiName', jsonData.parentRelationshipApiName);
    	}
    		else if (state === "ERROR") {
    			var errors = response.getError();
    			if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
 				} else {
 					console.log("Unknown error");
				}
			}
		});
		$A.enqueueAction(action);        
	},
    flattenStructure : function (helper,topObject, prefix, toBeFlattened) {
        for (const prop in toBeFlattened) {
            const curVal = toBeFlattened[prop];
            if (typeof curVal === 'object') {
                helper.flattenStructure(helper, topObject, prefix + prop + '_', curVal);
            } else {
                topObject[prefix + prop] = curVal;
            }
        }
    },    
    initColumnsWithActions: function (cmp, event, helper) {
    	var customActions = cmp.get('v.customActions')
        if( !customActions.length){
        	customActions = [
            	{ label: 'Edit', name: 'edit' },
                { label: 'Delete', name: 'delete' }
            ] 
        }
        var columns = cmp.get('v.columns'); 
        var columnsWithActions = [];
        columnsWithActions.push(...columns);
        if(cmp.get("v.sobjectApiName")!='Credit_Detail__c'){
            columnsWithActions.push({ type: 'action', typeAttributes: { rowActions: customActions } });
        }
        cmp.set('v.columnsWithActions',  columnsWithActions);
	},    
            
	removeRecord: function (cmp, row) {
        //debugger;
    	/*var modalBody;
        var modalFooter;
        var sobjectLabel = cmp.get('v.sobjectLabel');
        alert(sobjectLabel);
        alert(JSON.stringify(row));
        $A.createComponents([
        	["c:deleteRecordContent",{sobjectLabel:sobjectLabel}],
       		["c:deleteRecordFooter",{record: row, sobjectLabel:sobjectLabel}]
       	],
        function(components, status,errorMessage){
            alert(status);
            alert(JSON.stringify(errorMessage));
            if (status === "ERROR"){
                modalBody = components[0];
                modalFooter = components[1];
                cmp.find('overlayLib').showCustomModal({
                    header: "Delete " + sobjectLabel,
                    body: modalBody, 
                    footer: modalFooter,
                    showCloseButton: true
                })
            }
      	}
        );*/
        var action = cmp.get('c.deleteRecord');
        //alert(row.Id);
       // alert(JSON.stringify(roles));
        action.setParams({
            recordId : row.Id,
        });
        
         action.setCallback(this,function(response){
            
            //alert('this is state '+response.getState());
             if(response.getState() =='SUCCESS'){
                 var toastEvent = $A.get("e.force:showToast");
               	toastEvent.setParams({
             	 "title": "SUCCESS!",
              	 "message": "Record is deleted.",
             	 "type": "success"
              	 }); 
                 toastEvent.fire();
             }else{
                 var toastEvent = $A.get("e.force:showToast");
                 var errors = response.getError();
    			if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                        toastEvent.setParams({
                            "title": "ERROR!",
                            "message": errors[0].message,
                            "type": "ERROR"
                        }); 
                        toastEvent.fire();
                    }
 				}
               	
             }
         });
        $A.enqueueAction(action);
            
	},
                
    editRecord : function (cmp, row,helper) {
    	var createRecordEvent = $A.get("e.force:editRecord");
        createRecordEvent.setParams({
        	"recordId": row.Id});
       	createRecordEvent.fire();
       // this.fetchData(cmp,helper);
    },    
                    
    CreateOpp: function (cmp, event, helper) {
    	var action = cmp.get("c.getAccountBasics");
        console.log('CALLED');
        action.setParams({
        	accId:cmp.get("v.recordId")          
        });
        action.setCallback(this, function(response) {
        	var state = response.getState();
            if (state === "SUCCESS") {
            	var records = response.getReturnValue();  
                if((records.CDM_Account_Type__c=='Enterprise' || records.CDM_Account_Type__c=='' || $A.util.isEmpty(records.CDM_Account_Type__c)) && cmp.get("v.sobjectApiName")==='Opportunity'){
                    cmp.set("v.showNew",false);
                }else if(cmp.get("v.sobjectApiName")=='Credit_Detail__c'){
                    cmp.set("v.showNew",false);
                }else{
                    cmp.set("v.showNew",true);  
                }
                console.log('4'+'co-'+cmp.get("v.canCreateOpp")+'sa-'+cmp.get("v.sobjectApiName")+'sn-'+cmp.get("v.showNew"));
                
            }
      	});
                        
        $A.enqueueAction(action);
    },
    sortData : function(component,fieldName,sortDirection,fieldTyp){
            var data = component.get("v.records");
            //function to return the value stored in the field
            if ( fieldName === 'LinkName' ) { 
                fieldName = 'Name';
            }
            var key = function(a) { 
                return a[fieldName]; }
            
            var reverse = sortDirection == 'asc' ? 1: -1;
            var columns = component.get("v.columnsWithActions");
            
            
            // to handel number/currency type fields 
            if(fieldTyp==="CURRENCY"||fieldTyp==="DOUBLE"){ 
                data.sort(function(a,b){
                    var a = key(a) ? key(a) : '';
                    var b = key(b) ? key(b) : '';
                    return reverse * ((a>b) - (b>a));
                }); 
            }
        else if(fieldTyp==="BOOLEAN"){
            data.sort(function(a,b){
                var a =	key(a) ? 'true' : 'false'; 
                var b = key(b) ? 'true' : 'false' ;
                    return reverse * ((a>b) - (b>a));
                });
        }
            else{// to handel text type fields 
                data.sort(function(a,b){ 
                    var a = key(a) ? key(a).toLowerCase() : '';//To handle null values , uppercase records during sorting
                    var b = key(b) ? key(b).toLowerCase() : '';
                    return reverse * ((a>b) - (b>a));
                });    
            }
            //set sorted data to accountData attribute
            component.set("v.records",data);
        },
     findInValues: function(arr, value) {
  			value = String(value).toLowerCase();
  			return arr.filter(o =>
    		Object.entries(o).some(entry =>String(entry[1]).toLowerCase().includes(value)));
     }
})