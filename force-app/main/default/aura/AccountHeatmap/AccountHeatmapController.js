({
	doInit : function(component, event, helper) {
        helper.getLabels1(component);
        helper.loadFinancialAccountDetail(component, helper); 
        helper.loadOppProductsYellowData(component, helper) ; 
               
    },
    generatePDF :function(component, event, helper){
        var win = window.open("/apex/HeatMapExport?id="+component.get("v.recordId"),'_blank');
        win.focus();
    }  
})