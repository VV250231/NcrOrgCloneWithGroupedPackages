({
    handleTabClick: function (cmp, event, helper, tab) {
        this.removeActiveClass(cmp, event, helper);
        var tabSet = cmp.find(tab);
        $A.util.addClass(tabSet, 'slds-is-active');
    },
    removeActiveClass: function (cmp, event, helper) {
        $A.util.removeClass(cmp.find('tab_team'), 'slds-is-active');  
        $A.util.removeClass(cmp.find('tab_home'), 'slds-is-active');  
        $A.util.removeClass(cmp.find('tab_faq'), 'slds-is-active');  
        $A.util.removeClass(cmp.find('tab_news'), 'slds-is-active'); 
    }
})