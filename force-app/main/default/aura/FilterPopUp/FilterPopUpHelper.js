({
    getFieldsInfo : function(component, event) {
        var fieldLabelArr = [], i = 0;
        var fieldsDescResult =  component.get("v.fieldsInfoMap");
        if(!$A.util.isUndefinedOrNull(fieldsDescResult)) {
            for(var key in fieldsDescResult) {
                if(i == 0) {
                    fieldLabelArr.push({"class": "optionClass", label: fieldsDescResult[key].fieldLabel, value: key, selected: "true"});	
                } else {
                    fieldLabelArr.push({"class": "optionClass", label: fieldsDescResult[key].fieldLabel, value: key});	    
                } i++;
            }
            component.find("fieldLblpcklst").set("v.options", fieldLabelArr);
        }
        
        var currFilter = component.get("v.filter");
        
        if(!$A.util.isUndefinedOrNull(currFilter.fieldName)) {
            component.set("v.selectFieldName", currFilter.fieldName);
        }
        this.getOptrAndOprdList(component, component.get("v.selectFieldName"), currFilter);  
    },
    
    getOptrAndOprdList : function(component, selFieldName, currFilter) {
        // get opeartor and oprenad info for selected single field
        var operatorArr = [];
        var pklstArr = [];
        var selOptions = [];
        var fieldInfo = component.get("v.fieldsInfoMap")[selFieldName]; 
        var operatorOptions = fieldInfo.operatorOptions;
        var pklstOptions = fieldInfo.pklstOptions;
        var datatype = fieldInfo.fieldType;
        
        component.set("v.oprndFieldType", datatype);
        
        // get available operator options
        for(var i=0 ; i < operatorOptions.length; i++) {
            operatorArr.push({"class": "optionClass", label: operatorOptions[i], value: operatorOptions[i]});   
        }
        component.find("oprtpcklst").set("v.options", operatorArr);
        
        if(!$A.util.isUndefinedOrNull(currFilter.selectedOPR)) {
            component.set("v.selectOperator", currFilter.selectedOPR);
        }
        
        // get available picklist options
        if(datatype.toUpperCase() == "PICKLIST") {
            selOptions = (!$A.util.isUndefinedOrNull(currFilter.selectedOptions)) ? currFilter.selectedOptions : [];
            component.set("v.selectOptions", selOptions);
            
            for(var i=0 ; i < pklstOptions.length; i++) {
                pklstArr.push({label: pklstOptions[i], value: pklstOptions[i], selected : (selOptions.indexOf(pklstOptions[i]) > -1)});	       
            }
            component.set("v.avlPicklstOptions", pklstArr);
        }
        else {
            component.set("v.selectOperand", currFilter.selectedValue);
        }
        
        
        //component.find("oprndpcklst").set("v.options", pklstArr); 
    },
    
   
    
    trimString : function(inputVal) {
    	return (inputVal.replace(/^\s+|\s+$/g,''));    
	},
 
 
 })