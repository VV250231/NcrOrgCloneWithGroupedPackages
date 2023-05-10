({
    doInit : function(component, event, helper) {
    	helper.getFieldsInfo(component, event);
    },
    onFieldChange : function(component, event, helper) {
    	helper.getOptrAndOprdList(component, component.get('v.selectFieldName'), component.get("v.filter")); 
    },
    
	popupclick : function(component, event, helper) {
        event.stopPropagation();
    },
    
    saveFilter : function(component, event, helper) {
        var isPicklistfield = component.get("v.isPicklistField");
        var fltr = component.get("v.filter");
        var oprndType = component.get("v.oprndFieldType");
        var oprndVal = component.get('v.selectOperand');
        var inputOprnd = component.find("inputOprnd");
        
        if(oprndType == "CURRENCY") { 
            oprndVal = helper.trimString(oprndVal);
			          
            if((!$A.util.isUndefinedOrNull(oprndVal)) && (!$A.util.isEmpty(oprndVal))) {
                if(!isNaN(oprndVal)) {  
                	oprndVal = $A.get("$Locale.currencyCode") + oprndVal;
                    component.set('v.selectOperand', oprndVal);
                } else {
                    var oprdCurr = oprndVal.slice(0,3);
                    var oprndNum = helper.trimString(oprndVal.slice(3));
                    
                    if(isNaN(oprdCurr) && (!isNaN(oprndNum))) {
                    	var currList = [];
                        currList = component.get("v.currencyList");
                        
                        if(currList.indexOf(oprdCurr.toUpperCase()) == -1) {
                            inputOprnd.setCustomValidity("Invalid Currency");
							inputOprnd.reportValidity(); 
                            return;
                        }
                        component.set('v.selectOperand', oprdCurr.toUpperCase() + oprndNum);
                        // need to check currency further;
                    } else {
                        inputOprnd.setCustomValidity("Not a valid number");
						inputOprnd.reportValidity(); 
                        return;
                    }
                	// get first three character and check if rest of number is number or not
                	// also need to validate currency    
                }
            }
        }
     
        fltr.fieldName = component.get('v.selectFieldName');
        fltr.selectedOPR = component.get('v.selectOperator');
        fltr.selectedValue = component.get('v.selectOperand'); 
        fltr.selectedOptions = component.get('v.selectOptions'); 
        fltr.fieldLabel = component.get("v.fieldsInfoMap")[component.get('v.selectFieldName')].fieldLabel;
        fltr.fieldType = component.get("v.fieldsInfoMap")[component.get('v.selectFieldName')].fieldType;
        fltr.mode = 'commit';
        component.set("v.filter", fltr);
        
        component.getEvent("saveFilter").setParams({"newFilter" : component.get("v.filter"), "selFilterIndex" : component.get("v.fltrIndex")}).fire();
        component.destroy();
        
    },
    
    handlePcklstSelectChange : function(component, event, helper) {
    	var seloptions = event.getParams("values");
        console.log('>>>>>>');
        console.log(JSON.stringify(seloptions.values));
        component.set("v.selectOptions", seloptions.values);
    }
})