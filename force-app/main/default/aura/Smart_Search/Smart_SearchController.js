({
    myAction : function(component, event, helper) {
        
    },
    
    SG_Errorpop : function(component, event, helper) {
        var $j = jQuery.noConflict();
        component.set("v.toggleloader", "true");
        helper.checkprofile(component,event,helper);
        var t = $j(location).attr('host');
        var id=component.get("v.recordId");
        component.set("v.url",t);
        var opts = [
            { value: "--None--", label: "--None--",selected:"True"},
            { value: "Report", label: "Report"},
            { value: "Users", label: "Users"},
            { value: "Profile", label: "Profile"},
            { value: "VisualforcePage", label: "VisualforcePage"},
            { value: "Class", label: "Class"},
            { value: "EmailTemplate", label: "EmailTemplate"},
            { value: "LightningComponent", label: "LightningComponent" },
            { value: "PermissionSets", label: "PermissionSets" }
        ];
        component.set("v.adminlist", opts);
     //   component.set("v.url",url2);
    },
    
    
    adminsearch : function(component, event, helper)
    {
        component.set("v.togglesearchkeyerror","false");
        component.set("v.toggleselecterror","false");
        component.set("v.toggleloader", "true");
        component.set("v.toggletable","false");
        component.set("v.toggleusertable","false");
        component.set("v.togglereporttable","false");
        component.set("v.toggleLTNGtable","false");
        component.set("v.toggleprofiletable","false");
        component.set("v.toggleerrorfromserver","false");
        component.set("v.togglesearchcriteria","false");
        component.set("v.toggletablePermissionset","false");
        var t;
        component.set("v.objectresult",t);
        component.set("v.objectresultreport",t);
        component.set("v.objectresultuser",t);
        var adminselectvalue = component.find("adminselect").get("v.value");
        if(adminselectvalue == "Record")
        {	 
            component.set("v.togglerecordsearch","true");
        }
        
    },
    searchnow : function(component,event, helper)
    {
        component.set("v.togglesearchkeyerror","false");
        component.set("v.toggleselecterror","false");
        component.set("v.toggletable","false");
        component.set("v.toggleusertable","false");
        component.set("v.togglereporttable","false");
        component.set("v.toggleLTNGtable","false");
        component.set("v.toggleprofiletable","false");
        component.set("v.toggleerrorfromserver","false");
        component.set("v.toggletablePermissionset","false");
        component.set("v.togglesearchcriteria","false");
        var v = component.find("searchkey").get("v.value");
        var adminselectvalue = component.find("adminselect").get("v.value");
        var t;
        component.set("v.objectresult",t);
        var tnn = Boolean(v);
        if(tnn == false)
        {
            component.set("v.togglesearchkeyerror","true");
        }
        else
        {
            if(adminselectvalue == "Users")
            {
                component.set("v.objectname",adminselectvalue);
                helper.searchusers(component,event,helper);
                component.set("v.toggleusertable","true");
            }
            else
                if(adminselectvalue == "Report")
                {	 
                    component.set("v.objectname",adminselectvalue);
                    helper.searchreport(component,event,helper);
                    component.set("v.togglereporttable","true");
                }
                else
                    if(adminselectvalue == "Class")
                    {	 
                        component.set("v.objectname",adminselectvalue);
                        helper.searchclass(component,event,helper);
                        component.set("v.toggletable","true");
                    }
                    else
                        if(adminselectvalue == "LightningComponent")
                        {	 
                            component.set("v.objectname",adminselectvalue);
                            helper.searchltng(component,event,helper);
                            component.set("v.toggleLTNGtable","true");
                        }
                        else
                            if(adminselectvalue == "VisualforcePage")
                            {	 
                                component.set("v.objectname",adminselectvalue);
                                helper.searchpage(component,event,helper);
                                component.set("v.toggletable","true");
                            }
                            else
                                if(adminselectvalue == "Profile")
                                {	 
                                    component.set("v.objectname",adminselectvalue);
                                    helper.searchprofile(component,event,helper);
                                    component.set("v.toggletable","true");
                                }
                                else
                                    if(adminselectvalue == "EmailTemplate")
                                    {	 
                                        component.set("v.objectname",adminselectvalue);
                                        helper.searchtemplate(component,event,helper);
                                        component.set("v.toggletable","true");
                                    }
                                    else
                                        if(adminselectvalue == "PermissionSets")
                                        {	 
                                            component.set("v.objectname",adminselectvalue);
                                           // alert('Under Development : searchpermissionset');
                                            helper.searchpermissionset(component,event,helper);
                                            component.set("v.toggletable","true");
                                        }
                                        else
                                         
                                            {
                                                component.set("v.toggleselecterror","true");
                                            }
        }
        console.log(v);
    },
    
})