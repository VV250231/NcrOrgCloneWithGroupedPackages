({
	doInit : function(component, event, helper) {
        helper.getFltrPcklst(component, event);
    	helper.loadAcctOpps(component, event); 
        helper.getFieldsInfo(component, event);
        helper.getCurrencyInfo(component, event)
    },
    
    onFltrPcklstChange : function(component, event, helper) {
        helper.loadAcctOpps(component, event); 
    },
    
    toggleFltrPnl : function(component, event, helper) {
    	$A.util.toggleClass(component.find('filterPanel'), 'slds-is-open'); 
    },
    
    addFilter :  function(component, event, helper) {
    	helper.addNewFilter(component, event); 
    },
    
    removeFltr : function(component, event, helper) {
       var fltrboxindex = event.getParam("selFilterIndex");
       helper.removefilter(component, event, fltrboxindex);
    },
    
    removeAllFltr : function(component, event, helper) {
        component.set("v.filterList", []); 
        helper.loadAcctOpps(component, event);
    },
    
    editfilter : function(component, event, helper) {
        var srcelem = event.currentTarget;
        var slctdFltrIndex = ((srcelem.id).split('-'))[1];
        var fltrboxdivId = 'fltrboxdiv-' + ((srcelem.id).split('-'))[1];
        var fltrboxdiv = document.querySelector('#' + fltrboxdivId);
        var fltrPopup = component.find("fltrPopup").getElement();
        
        component.set("v.selectFltrIndex", slctdFltrIndex);
        var xpos = event.pageX - event.offsetX- fltrPopup.scrollWidth - parseFloat(window.getComputedStyle(fltrboxdiv, null).getPropertyValue('padding-left')) ;
        var ypos = event.pageY - event.offsetY - (fltrPopup.scrollHeight/2) + 18;
        if(fltrPopup.classList.contains('slds-hidden')) {
        	fltrPopup.classList.remove('slds-hidden')
        }
        
        // vertical scrollbar available
        var scrollbarwidth = 17;
        if((ypos + fltrPopup.scrollHeight >= window.innerHeight) && (window.innerWidth <= document.documentElement.clientWidth)) {
            xpos = xpos - scrollbarwidth; // more filter adding scrollbar
        } else if ((ypos + fltrPopup.scrollHeight < window.innerHeight) && (window.innerWidth > document.documentElement.clientWidth)) {
        	xpos = xpos + scrollbarwidth; // less filter removing scrollbar
        }
       
        fltrPopup.style.left = xpos + "px"; 
        fltrPopup.style.top = ypos + "px"; 
    }, 
    
    onFieldChange : function(component, event, helper) {
    	helper.getOptrAndOprdList(component, component.get('v.selectFieldName')); 
    },
    
    saveFilter : function(component, event, helper) {
       var updatedFltrIndex = parseInt(event.getParam("selFilterIndex"));
       var updatedFltr = event.getParam("newFilter");
       var fltrList  = component.get("v.filterList");
       var currentFltr = fltrList[updatedFltrIndex];
       
       currentFltr.fieldName = updatedFltr.fieldName;
       currentFltr.fieldLabel = updatedFltr.fieldLabel;
       currentFltr.fieldType = updatedFltr.fieldType;
       currentFltr.mode = updatedFltr.mode;
       currentFltr.selectedOPR = updatedFltr.selectedOPR;
       currentFltr.selectedValue = updatedFltr.selectedValue;
       currentFltr.selectedOptions = updatedFltr.selectedOptions;
 
       component.set("v.filterList", fltrList);
       console.log(JSON.stringify(component.get("v.filterList")));
        
       helper.loadAcctOpps(component, event);
       event.stopPropagation();
    },
    
    searchTextChange : function(component, event, helper) {
        helper.loadAcctOpps(component, event);
    },
    sortoopname : function(component, event, helper) {
        helper.sortBy(component, "Name");
    },
    sortaccname: function(component, event, helper) {
        helper.sortBy(component, "Account.Name");
    },
    sortclosedate: function(component, event, helper) {
        helper.sortBy(component, "CloseDate");
    },
    sortstage: function(component, event, helper) {
        helper.sortBy(component, "StageName");
    },
    sortamount: function(component, event, helper) {
        helper.sortBy(component, "Amount");
    },
    sortforecategory: function(component, event, helper) {
        helper.sortBy(component, "ForecastCategoryName");
    },
    
   
})