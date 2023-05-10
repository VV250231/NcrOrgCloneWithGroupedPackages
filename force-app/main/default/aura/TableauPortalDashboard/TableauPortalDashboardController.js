({
    doInit : function(component, event, helper) {
        component.set("v.showdashboard",false);
        component.set("v.showNoRecordMessage",false);
        component.set("v.header","");
        
        
    },
    showWFR : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Weekly Funnel Report/WFR - Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('WFR'), 'active');
        helper.showReports(component, event, helper, 'WFR');
    },
    
    showIndustry : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Industry Dashboards");        
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('Industry'), 'active');
        helper.showReports(component, event, helper, 'Industry');
    },
    
    showRegional : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Regional Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('Regional'), 'active');
        helper.showReports(component, event, helper, 'Regional');
    },
    
    showCountry : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Country Model Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('Country'), 'active');
        helper.showReports(component, event, helper, 'Country');
    }
    ,   
    showIsg : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Product Base Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('ISG'), 'active');
        helper.showReports(component, event, helper, 'Product Base');
    },
       
    showHC : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Headcount/ Compensation Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('HC'), 'active');
        helper.showReports(component, event, helper, 'Compensation');
    }
    ,   
    showOther : function(component, event, helper) {
        component.set("v.showdashboard",true);
        component.set("v.header","Other Dashboards");
        helper.removeActiveClass(component, event, helper);
        $A.util.addClass(component.find('OT'), 'active');
        helper.showReports(component, event, helper, 'Other');
    }
    ,   
    handleSubmit : function(component, event, helper) {
        helper.submit(component, event, helper);
    }
})