({
    searchHelper : function(component,event,getInputkeyWord) {
        // call the apex class method 
        console.log('filterValue>>' + component.get("v.filterValue"));
        var action = component.get("c.fetchLookUpValues");
        // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord,
            'ObjectName' : component.get("v.objectAPIName"),
            'ExcludeitemsList' : component.get("v.lstSelectedRecords"),
            'filerName' : component.get("v.filterField"),
            'filerValue' : component.get("v.filterValue"),     
        });
        
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            console.log('state>>' + state);
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('storeResponse>>' + storeResponse.length);
                // if storeResponse size is equal 0 ,display No Records Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Records Found...');
                } else {
                    component.set("v.Message", '');
                    // set searchResult list with return value from server.
                }
                component.set("v.listOfSearchRecords", storeResponse); 
            }
        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    findClosedOpp : function(component) {
    	var selectedOppList = component.get("v.lstSelectedRecords");
        var selectedClosedOppList = [];
        var selectedOpenOppList = [];
        for(var opp in selectedOppList){
            if(!(typeof selectedOppList[opp].StageName === "undefined")){
        		if((selectedOppList[opp].StageName).includes('Closed')){
            		selectedClosedOppList.push(selectedOppList[opp]);
                    //alert(selectedOppList[opp].StageName);
           		}
                else{
                    selectedOpenOppList.push(selectedOppList[opp]);
                }
            }
        }
        if(selectedClosedOppList.length>0){
          // alert("is closed");
            component.set("v.isOppsClosed",true);
            
        }
        else{
            component.set("v.isOppsClosed",false);
        }
        component.set("v.lstSelectedRecordsClosed",selectedClosedOppList);
        component.set("v.lstSelectedRecordsOpen",selectedOpenOppList);

	}
})