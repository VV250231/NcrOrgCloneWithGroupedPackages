({
    
    init : function(component, event, helper) {
         $A.util.toggleClass(component.find("mySpinner"), "slds-hide");
        component.set('v.columns', [
            {label: 'Site Name', fieldName: 'Name', type: 'text'},
            {label: 'Site Number', fieldName: 'Site_Number__c', type: 'text'},
            {label: 'Corporate Address', fieldName: 'SiteAddress', type: 'text'},
            {label: 'Primary Bill To', fieldName: 'Primary_Bill_To__c',type: 'text', cellAttributes: {class : 'sitetypecol', iconName: { fieldName: 'PrmryBillTCheck' }}	},
            {label: 'Primary Ship To', fieldName: 'Primary_Ship_To__c', type: 'text', cellAttributes: {class : 'sitetypecol', iconName: { fieldName: 'PrmryShipToCheck' }}},
            {label: 'Primary Deliver To', fieldName: 'Primary_Deliver_To__c', type: 'text',cellAttributes: {class : 'sitetypecol', iconName: { fieldName: 'PrmryDlvryToCheck' }}}
            //{label: 'Bill To', fieldName: 'Bill_To__c', type: 'Text'},
           // {label: 'Ship To', fieldName: 'Ship_To__c', type: 'Text'},
            //{label: 'Deliver To', fieldName: 'Deliver_To__c', type: 'Text'},
        ]);
        
        component.set("v.searchValue", "");
        helper.fetchAccounts(component, event, 0);
        
    },
    loadMoreData : function(component, event, helper) {        
        event.getSource().set("v.isLoading", true);        
        component.set('v.loadMoreStatus', 'Loading');
        helper.fetchAccounts(component, event, component.get('v.accountList').length);
    },
     
    
    searchTextChange : function(cmp, event, helper) {
         var spinner = cmp.find("mySpinner");
         $A.util.toggleClass(spinner, "slds-hide");
        var searchFilter;
    	if (!$A.util.isEmpty(cmp.get("v.searchValue"))){
        	searchFilter = cmp.get("v.searchValue").toUpperCase();  
        }
        var allRecords = cmp.get("v.allAccountList");
        var filteredRecords = cmp.get("v.accountList");
        var resultArray = []; 
        
         //if search text exist
        if(!$A.util.isEmpty(searchFilter) && searchFilter.trim().length > 0) {
            allRecords.forEach(function(item) {
                if((item.Name && item.Name.toUpperCase().indexOf(searchFilter) != -1) ||
                   (item.Site_Number__c && item.Site_Number__c.toUpperCase().indexOf(searchFilter) != -1) ||
                   (item.SiteAddress && item.SiteAddress.toUpperCase().indexOf(searchFilter) != -1)) {
					resultArray.push(item);                    
                }
            });
            cmp.set("v.accountList",resultArray); 
        
        } else {
            if (filteredRecords && allRecords && filteredRecords.length < allRecords.length) {
            	cmp.set("v.accountList",allRecords);     
            }
        }
        $A.util.toggleClass(cmp.find("mySpinner"), "slds-hide");
    }

})