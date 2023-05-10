({
    myAction : function(component, event, helper) {
        
    },
    
    searchsaleorg : function(component,event,helper){
       
        /* **************************************************** */
         helper.searchkeysalesorgser(component, event, helper);
        /* **************************************************** */
        component.set("v.spin",false);
    },
    
    SG_Errorpop : function(component,event,helper){
        /* **************************************************** */
        component.set("v.spin",true);
        helper.checkaccess(component, event, helper);
        component.set("v.spin",false);
        
        /* **************************************************** */
    },
    editmode: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.editmode",true);
        component.set("v.readonlymode",false);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    readonly: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.editmode",false);
        component.set("v.readonlymode",true);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    createnew: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.createsection",true);
        component.set("v.updatesection",false);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    updateexist: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.createsection",false);
        component.set("v.updatesection",true);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    searchtabusername: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        helper.searchkeytabuser(component, event, helper);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    searchkeyrolename: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        var searchvaluee =  event.getSource().get("v.value");
        var searchvalue = component.find(searchvaluee).get("v.value");
        helper.searchkeyrolename(component, event, helper);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    updatethisuser: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.spin",true);
        var searchvalue =  event.getSource().get("v.value");
        helper.getuserrecord(component, event, helper);
        component.set("v.spin",false);
        /* **************************************************** */
        
    },
    
    updaterolescreate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        document.getElementById('searchcreaterole').style.display="Block";
        component.set("v.spin",false);
        /* **************************************************** */
    },
    hideupdaterolescreate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        document.getElementById('searchcreaterole').style.display="None";
        component.set("v.spin",false);
    },
    updaterolesupdate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        document.getElementById('searchupdaterole').style.display="Block";
        component.set("v.spin",false);
        /* **************************************************** */
    },
    hideupdaterolesupdate: function(component,event,helper){
        
        component.set("v.spin",true);
        /* **************************************************** */
        document.getElementById('searchupdaterole').style.display="None";
        component.set("v.spin",false);
        /* **************************************************** */
    },
    removerolestringupdate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        var roleid =  event.getSource().get("v.value");
        var numbers = [];
        var existingdata = component.get("v.rolesassigned");
        for (var i = 0; i < existingdata.length; i++) {
            if(existingdata[i].roleid == roleid){
                existingdata.splice(i,1);
            }
        }
        component.set("v.rolesassigned", existingdata);
        helper.evaluateupdatecheckboxnumbers(component, event, helper);
        component.set("v.spin",false);
        /* **************************************************** */ 
    },
    removerolefromcreate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        component.set("v.spin",true);
        var roleid =  event.getSource().get("v.value");
        var numbers = [];
        var existingdata = component.get("v.rolesassignedcreate");
        for (var i = 0; i < existingdata.length; i++) {
            if(existingdata[i].roleid == roleid){
                existingdata.splice(i,1);
            }
        }
        component.set("v.rolesassignedcreate", existingdata);
        helper.evaluateupdatecheckboxnumbers(component, event, helper);
        component.set("v.spin",false);
        /* **************************************************** */
    },
    checkboxSelectupdate: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        var roleid =  event.getSource().get("v.text");
        var rolename = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        if(checked == true){
            var rolestring = [];
            rolestring = component.get("v.rolesassigned");
            rolestring.push({"roleid": roleid, "rolename": rolename});
            component.set("v.rolesassigned",rolestring);
            helper.evaluateupdatecheckboxnumbers(component, event, helper);
        }
        if(checked == false){
            var numbers = [];
            var existingdata = component.get("v.rolesassigned");
            for (var i = 0; i < existingdata.length; i++) {
                if(existingdata[i].roleid == roleid){
                    existingdata.splice(i,1);
                }
            }
            component.set("v.rolesassigned", existingdata);
            helper.evaluateupdatecheckboxnumbers(component, event, helper);
        }
        
        component.set("v.spin",false);
        /* **************************************************** */
        
    },
    checkboxSelectcreate: function(component,event,helper){
        var spinner = component.find("spinnnnspinner");
        $A.util.toggleClass(spinner, "slds-show");
        /* **************************************************** */
        var roleid =  event.getSource().get("v.text");
        var rolename = event.getSource().get("v.name");
        var checked = event.getSource().get("v.value");
        if(checked == true){
            var rolestring = [];
            rolestring = component.get("v.rolesassignedcreate");
            rolestring.push({"roleid": roleid, "rolename": rolename});
            component.set("v.rolesassignedcreate",rolestring);
            helper.evaluateupdatecheckboxnumbers(component, event, helper);
        }
        if(checked == false){
            var numbers = [];
            var existingdata = component.get("v.rolesassignedcreate");
            for (var i = 0; i < existingdata.length; i++) {
                if(existingdata[i].roleid == roleid){
                    existingdata.splice(i,1);
                }
            }
            component.set("v.rolesassignedcreate", existingdata);
            helper.evaluateupdatecheckboxnumbers(component, event, helper);
        }
        component.set("v.spin",false);
        /* **************************************************** */
    },
    validateupdaterecord: function(component,event,helper){
        component.set("v.spin",true);
        /* **************************************************** */
        var rollevelaccess = component.get("v.tableauuserobjectupdate.RoleLevelAccess__c");
        var salesorgaccess = component.get("v.tableauuserobjectupdate.SalesOrgAccess__c");
        var qlookid= component.get("v.tableauuserobjectupdate.UserQlookID__c");
        if(qlookid != null){
            if(rollevelaccess==true){
                var rolestring = [];
                rolestring = component.get("v.rolesassigned");
                if(rolestring.length == 1){component.set("v.tableauuserobjectupdate.TRole1__c",rolestring[0].roleid);
                                           component.set("v.tableauuserobjectupdate.TRole2__c",'');
                                           component.set("v.tableauuserobjectupdate.TRole3__c",'');
                                          }
                if(rolestring.length == 2){component.set("v.tableauuserobjectupdate.TRole1__c",rolestring[0].roleid);
                                           component.set("v.tableauuserobjectupdate.TRole2__c",rolestring[1].roleid);
                                           component.set("v.tableauuserobjectupdate.TRole3__c",'');
                                          }
                if(rolestring.length == 3){component.set("v.tableauuserobjectupdate.TRole1__c",rolestring[0].roleid);
                                           component.set("v.tableauuserobjectupdate.TRole2__c",rolestring[1].roleid);
                                           component.set("v.tableauuserobjectupdate.TRole3__c",rolestring[2].roleid);
                                          }
                if(salesorgaccess==true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'User access can either be based on Role Hiererchy OR on Sales Org Hiererchy !',
                    });
                    toastEvent.fire();
                    if(rolestring.length == 0){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            type:"error",
                            title: "Error !",
                            message: 'Please assign user atleast one role',
                        });
                        toastEvent.fire();
                    }
                    else{
                        helper.updatetabrecordd(component, event, helper);
                    }
                }
                if(rolestring.length == 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type:"error",
                        title: "Error !",
                        message: 'Please assign user atleast one role',
                    });
                    toastEvent.fire();
                }
                if(rolestring.length > 0 && salesorgaccess==false){
                    helper.updatetabrecordd(component, event, helper);
                }
                
                
            }
            if(rollevelaccess==false){
                var rolestring = [];
                rolestring = component.get("v.rolesassigned");
                component.set("v.tableauuserobjectupdate.TRole1__c",'');
                component.set("v.tableauuserobjectupdate.TRole2__c",'');
                component.set("v.tableauuserobjectupdate.TRole3__c",'');
                if(rolestring.length == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User doesnt have access based on Role Hiererchy !',
                    });
                    toastEvent.fire();
                }
                
            }
            if(salesorgaccess==true){
                var rolestring = [];
                rolestring = component.get("v.rolesassigned");
                if(rolestring.length == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User access can either be based on Role Hiererchy OR on Sales Org Hiererchy !',
                    });
                    toastEvent.fire();
                }
                if(rolestring.length == 0){
                    helper.updatetabrecordd(component, event, helper);
                }
                
            }
            if(salesorgaccess==false && rollevelaccess==false){
                var rolestring = [];
                rolestring = component.get("v.rolesassigned");
                if(rolestring.length > 0){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User doesnt have access based on Role Hiererchy !',
                    });
                    toastEvent.fire();
                }
                else{
                    helper.updatetabrecordd(component, event, helper);
                }
            }
        }
        else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                title: "Error !",
                type:"error",
                message: 'Qlook is mandatory field !',
            });
            toastEvent.fire();
        } 
        component.set("v.spin",false);
        /* **************************************************** */
        
    },
    validatecreaterecord: function(component,event,helper){
        component.set("v.spin",true);
        
        /*####################################################################### */
        
        var UserName = component.get("v.UserName__c");
        var UserQlookID= component.get("v.UserQlookID__c");
        var IfSFDCUser=component.get("v.IfSFDCUser__c");
        var IsActive= component.get("v.IsActive__c");
        var OwnershipAccess=component.get("v.OwnershipAccess__c");
        var RoleLevelAccess= component.get("v.RoleLevelAccess__c");
        var SalesOrgAccess= component.get("v.SalesOrgAccess__c");
        var InteractorPublisher=component.get("v.InteractorPublisher__c");
        var rolestring = [];
        rolestring = component.get("v.rolesassignedcreate");
        var TRole1 ;
        if(rolestring.length == 1){ TRole1= rolestring[0].roleid };
        var TRole2 ;
        if(rolestring.length == 2){ TRole1= rolestring[1].roleid };
        var TRole3 ;
        if(rolestring.length == 3){ TRole1= rolestring[2].roleid };
        
        /* ######################################################################  */
        if(UserQlookID != null){
            if(RoleLevelAccess==true){
                if(SalesOrgAccess==true){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'User access can either be based on Role Hiererchy OR on Sales Org Hiererchy !',
                    });
                    toastEvent.fire();
                }
                
                if(rolestring.length == 0 ){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type:"error",
                        title: "Error !",
                        message: 'Please assign user atleast one role',
                    });
                    toastEvent.fire();
                }
                
                if(SalesOrgAccess==false &&  rolestring.length != 0){
                    helper.createrecords(component, event, helper); 
                }
            }
            
            if(RoleLevelAccess==false){
                if(rolestring.length == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User doesnt have access based on Role Hiererchy !',
                    });
                    toastEvent.fire();
                }
            }
            if(SalesOrgAccess==true){
                if(rolestring.length == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User access can either be based on Role Hiererchy OR on Sales Org Hiererchy !',
                    });
                    toastEvent.fire();
                }
                if(rolestring.length == 0){
                    helper.createrecords(component, event, helper);
                }
                
            }
            if(SalesOrgAccess==false && RoleLevelAccess==false){
                if(rolestring.length == 1){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        title: "Error !",
                        type:"error",
                        message: 'Please remove all roles assinged to user ! User doesnt have access based on Role Hiererchy !',
                    });
                    toastEvent.fire();
                }
                else{
                    helper.createrecords(component, event, helper);
                }
            }
        }
        
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                mode: 'sticky',
                title: "Error !",
                type:"error",
                message: 'Qlook is mandatory field !',
            });
            toastEvent.fire();
        }
        component.set("v.spin",false);
        /* **************************************************** */
    },
    reloadpage: function(component,event,helper){
        component.set("v.spin",true);
        
        $A.get('e.force:refreshView').fire();
        
        component.set("v.spin",false);
        /* **************************************************** */
    },
    togglereportpage: function(component,event,helper){
        var value = component.get("v.reportpage");
        if(value==true){
            component.set("v.reportpage",false);
        }
        if(value==false){
            component.set("v.reportpage",true);
        }
        /* **************************************************** */
    },
    toggleallrefresh: function(component,event,helper){
        component.set("v.reportpage",false);
        /* **************************************************** */
    },
    scriptroleupdate: function(component,event,helper){
        helper.scriptroleupdatehelper(component, event, helper); 
        /* **************************************************** */
    },
    scriptrolename: function(component,event,helper){
        helper.scriptrolenamehelper(component, event, helper); 
        /* **************************************************** */
    },
    updatescript: function(component,event,helper){
        helper. updatescriptupdatehelper(component, event, helper); 
        /* **************************************************** */
    },
     showbatchmodal : function(component,event,helper){
        document.getElementById('batchmodal').style.display="Block";
        component.set("v.reportpage",false);
    },
    hidebatchmodal : function(component,event,helper){
        document.getElementById('batchmodal').style.display="None";
        component.set("v.reportpage",false);
    }
})