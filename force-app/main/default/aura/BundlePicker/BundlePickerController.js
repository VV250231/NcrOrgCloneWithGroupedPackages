({
	SelectTab1: function(cmp, event, helper) {
		var cmpTarget1 = cmp.find('Tab1');
        var cmpTarget2 = cmp.find('Tab2');
        $A.util.addClass(cmpTarget1, 'slds-active');
        $A.util.removeClass(cmpTarget2, 'slds-active');
        
        var subtab1=cmp.find('subtab-tabpanel-01');
        var subtab2=cmp.find('subtab-tabpanel-02');
        $A.util.addClass(subtab1, 'slds-show');
        $A.util.removeClass(subtab2, 'slds-show');
        $A.util.addClass(subtab2, 'slds-hide');
		
        
		        
	},
    SelectTab2:function(cmp, event, helper){
        var cmpTarget1 = cmp.find('Tab1');
        var cmpTarget2 = cmp.find('Tab2');
        $A.util.addClass(cmpTarget2, 'slds-active');
        $A.util.removeClass(cmpTarget1, 'slds-active');
        
        var subtab1=cmp.find('subtab-tabpanel-01');
        var subtab2=cmp.find('subtab-tabpanel-02');
        $A.util.addClass(subtab2, 'slds-show');
        $A.util.removeClass(subtab1, 'slds-show');
        $A.util.addClass(subtab1, 'slds-hide');    
    }
})