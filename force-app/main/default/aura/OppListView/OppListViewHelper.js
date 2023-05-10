({
    getFieldsInfo : function(component, event) {
        var action = component.get("c.getFieldsInfo"); 
        
        action.setCallback(this, function(a) {
            if (a.getState() == "SUCCESS") {
                if(a.getReturnValue() != null) {
                    var fieldsDescResult = a.getReturnValue();
                    console.log(fieldsDescResult); 
                    component.set("v.fieldsInfoMap", fieldsDescResult);
                }
            } else if (a.getState() == "ERROR") {
                alert('error');
                console.log(a.getError());
            } 
        });
        
        $A.enqueueAction(action);
    },
    
    
    getOptrAndOprdList : function(component, fieldName) {
        // get opeartor and oprenad info for selected single field
        var operatorArr = [];
        var pklstArr = [];
        var fieldInfo = component.get("v.fieldsInfoMap")[fieldName]; 
        var operatorOptions = fieldInfo.operatorOptions;
        var pklstOptions = fieldInfo.pklstOptions;
        var datatype = fieldInfo.fieldType;
        
        for(var i=0 ; i < operatorOptions.length; i++) {
            operatorArr.push({"class": "optionClass", label: operatorOptions[i], value: operatorOptions[i]});	    
        }
        
        for(var i=0 ; i < pklstOptions.length; i++) {
            pklstArr.push({"class": "optionClass", label: pklstOptions[i], value: pklstOptions[i]});	       
        }
        
        if(datatype.toUpperCase() == "PICKLIST") 
            component.set("v.isPicklistField", true);
        else 
            component.set("v.isPicklistField", false);    
        
        component.find("oprtpcklst").set("v.options", operatorArr);
        //component.find("oprndpcklst").set("v.options", pklstArr); 
        component.set("v.avlPicklstOptions", pklstArr);
    },
    
    loadAcctOpps : function(component, event) {
        this.showSpinner(component);
        var action = component.get("c.getAcctOpps"); 
        action.setParams({ 
            "accId" : component.get("v.accId"),
            "pklstFltr" : component.get("v.selectFltr"),
            "searchVal" : component.get("v.searchValue"),
            "fieldFilters" : JSON.stringify(component.get("v.filterList"))
        }); 
        action.setCallback(this, function(a) {
            this.hideSpinner(component);
            
            if (a.getState() == "SUCCESS") {
                if(a.getReturnValue() != null) {
                    var resp = a.getReturnValue();
                    component.set("v.accName", resp.AccountName);
                    component.set("v.oppList", resp.oppList); 
                }
            } else if (a.getState() == "ERROR") {  
                console.log(a.getError());
            } 
            
        });
        
        $A.enqueueAction(action);
    },
    
    addNewFilter : function(cmp, event) {
        var fltrList = cmp.get("v.filterList"); 
        fltrList.push({fieldLabel : "", fieldName : "", fieldType: "", selectedOPR : "", selectedValue :"", mode : "edit"});
        cmp.set("v.selectFltrIndex", fltrList.length -1);
        cmp.set("v.filterList", fltrList);
    },
    
    removefilter : function(cmp, event, index) {
        var fltrList = cmp.get("v.filterList"); 
        fltrList.splice(index, 1);
        cmp.set("v.filterList", fltrList);   
        this.loadAcctOpps(cmp, event);
    },
    
    getFltrPcklst : function(cmp, event) {
        var opts = [
            { "class": "optionClass", label: "Current Quarter Opportunities", value: "THIS_QUARTER", selected: "true" },
            { "class": "optionClass", label: "Next Quarter Opportunities", value: "NEXT_QUARTER" },
            { "class": "optionClass", label: "Current Year Opportunities", value: "THIS_YEAR" },
            { "class": "optionClass", label: "Previous Year Closed Opportunities", value: "Previous_Year_Closed_Opportunity"},
            { "class": "optionClass", label: "Total Closed Opportunities", value: "Total_Closed_Opportunity" },
            { "class": "optionClass", label: "Lost Opportunities", value: "All_Lost_Opportunity" }
        ];
        cmp.find("fltrpcklst").set("v.options", opts);  
        
    },
    
    getCurrencyInfo : function(component,event) {
        var action = component.get("c.getAllCurrency"); 
        action.setCallback(this, function(a) {
            if (a.getState() == "SUCCESS") {
                if(a.getReturnValue() != null) { 
                    component.set("v.currencyList", a.getReturnValue()); 
                }  
            } else if (a.getState() == "ERROR") {
                console.log(a.getError());
            } 
        }); $A.enqueueAction(action);   
    },
    
    showSpinner : function(component) {
        $A.util.removeClass(component.find("spinnerDiv"),'slds-hide');     
    }, 
    
    hideSpinner : function(component) {
        $A.util.addClass(component.find("spinnerDiv"),'slds-hide');
    }, 
    
    sortBy: function(component, field) {
        var records = component.get("v.oppList");
        var sortAsc = component.get("v.sortfield") != field || !component.get("v.sortasc") ;
        records.sort(function(a,b){
            var t1 = a[field] == b[field],
                t2 = (!a[field] && b[field]) || (a[field] < b[field]);
            return t1? 0: (sortAsc?-1:1)*(t2?1:-1);
        });
        component.set("v.sortasc", sortAsc);
        component.set("v.sortfield", field);
        component.set("v.oppList", records);
    },
})