({
    MAX_FILE_SIZE: 750 000, /* 1 000 000 * 3/4 to account for base64 */
    
    uploadFile : function(component, event, helper) {
    // console.log(checkbox.get("v.value"));
    var fileInput = component.find("file").getElement();
    var file = fileInput.files[0];
    var fr = new FileReader();
    
    var self = this;
    fr.onload = function() {    
    var fileContents = fr.result;
    var base64Mark = 'base64,';
    var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
    fileContents = fileContents.substring(dataStart);
    self.upload(component, file, fileContents);
    var fileName = file.name;
    
    component.set("v.uploadedFileName",fileName);
    
    
    
    
    
    
};
 fr.readAsDataURL(file);
},
    
    upload: function(component, file, fileContents) {
        var Base64={_keyStr:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",
                    encode:function(e){var t="";var n,r,i,s,o,u,a;var f=0;e=Base64._utf8_encode(e);while(f<e.length){n=e.charCodeAt(f++);
                                                                                                                     r=e.charCodeAt(f++);i=e.charCodeAt(f++);s=n>>2;o=(n&3)<<4|r>>4;u=(r&15)<<2|i>>6;a=i&63;
                                                                                                                     if(isNaN(r)){u=a=64}else if(isNaN(i)){a=64}t=t+this._keyStr.charAt(s)+this._keyStr.charAt(o)+this._keyStr.charAt(u)+this._keyStr.charAt(a)}return t},
                    decode:function(e){
                        var t="";var n,r,i;var s,o,u,a;var f=0; e=e.replace(/[^A-Za-z0-9+/=]/g,"");while(f<e.length)
                        {s=this._keyStr.indexOf(e.charAt(f++));o=this._keyStr.indexOf(e.charAt(f++));u=this._keyStr.indexOf(e.charAt(f++));
                         a=this._keyStr.indexOf(e.charAt(f++));n=s<<2|o>>4;r=(o&15)<<4|u>>2;i=(u&3)<<6|a;t=t+String.fromCharCode(n);if(u!=64)
                         {t=t+String.fromCharCode(r)}if(a!=64){t=t+String.fromCharCode(i)}
                        }
                        
                        t=Base64._utf8_decode(t);return t},_utf8_encode:function(e)
                    {
                        e=e.replace(/rn/g,"n");var t="";for(var n=0;n<e.length;n++){var r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r)}else if(r>127&&r<2048)
                        {t+=String.fromCharCode(r>>6|192);t+=String.fromCharCode(r&63|128)}else{t+=String.fromCharCode(r>>12|224);
                                                                                                t+=String.fromCharCode(r>>6&63|128);t+=String.fromCharCode(r&63|128)}}return t},
                    _utf8_decode:function(e)
                    {var t="";var n=0;var r=c1=c2=0;
                     while(n<e.length){r=e.charCodeAt(n);if(r<128){t+=String.fromCharCode(r);
                                                                   n++}else if(r>191&&r<224)
                                                                   {c2=e.charCodeAt(n+1);t+=String.fromCharCode((r&31)<<6|c2&63);n+=2}
                                                                       else
                                                                       {c2=e.charCodeAt(n+1);c3=e.charCodeAt(n+2);t+=String.fromCharCode((r&15)<<12|(c2&63)<<6|c3&63);n+=3}}
                     return t;
                    }
                    
                   };  
        
        var dataMS = Papa.parse(Base64.decode(fileContents), {
            complete: function(results) {
                console.log("Finished:", results.data);
            }
        });
        component.set("v.showSpinner", 'Y');
        if(component.get("v.RTname")== 'ServicesBidLog'){
            var CSVSerBL1=[];
            for(var i=1;i < dataMS.data.length; i++){
                if(dataMS.data[i].length>1){
                    var CSVSerBL = { };
                    CSVSerBL.Date_dt=dataMS.data[i][0];
                    CSVSerBL.ServiceNow_Opportunity_Number=dataMS.data[i][1];
                    CSVSerBL.Region=dataMS.data[i][2];
                    CSVSerBL.SSC_Salesperson=dataMS.data[i][3];
                    CSVSerBL.Solution_Architect=dataMS.data[i][4];
                    CSVSerBL.Controllable_OI=dataMS.data[i][5];
                    CSVSerBL.Duration_of_Contract=dataMS.data[i][6];
                    CSVSerBL.BU_Warranty=dataMS.data[i][7];
                    CSVSerBL.BU_Warranty_Term=dataMS.data[i][8];
                    CSVSerBL.BU_Warranty_SLA=dataMS.data[i][9];
                    CSVSerBL.SLA=dataMS.data[i][10];
                    CSVSerBL.SLA_Description=dataMS.data[i][11];
                    CSVSerBL.SID=dataMS.data[i][12];
                    CSVSerBL.PID=dataMS.data[i][13];
                    CSVSerBL.Product_Description=dataMS.data[i][14];
                    CSVSerBL.Total_Quantity_Labor_Hours=dataMS.data[i][15];
                    CSVSerBL.CAF_List_Price=dataMS.data[i][16];
                    CSVSerBL.Upgrade_Unit_Discount=dataMS.data[i][17];
                    CSVSerBL.Upgrade_Unit_Total_Discount=dataMS.data[i][18];
                    CSVSerBL.Upgrade_Unit_Extended_Net=dataMS.data[i][19];
                    CSVSerBL.Regular_Charge_Unit_Discount=dataMS.data[i][20];
                    CSVSerBL.Regular_Charge_Unit_Total_Discount=dataMS.data[i][21];
                    CSVSerBL.Regular_Charge_Unit_Extended_Net=dataMS.data[i][22];
                    CSVSerBL.Exchange_Rate=dataMS.data[i][23];
                    CSVSerBL.SAMY_rate=dataMS.data[i][24];
                    CSVSerBL.SAMY_Type=dataMS.data[i][25];
                    CSVSerBL.FLMY_Rate=dataMS.data[i][26];
                    CSVSerBL.SGM_dollar=dataMS.data[i][27];
                    CSVSerBL.SGM=dataMS.data[i][28];
                    CSVSerBL.GM_dollar=dataMS.data[i][29];
                    CSVSerBL.GM=dataMS.data[i][30];
                    CSVSerBL.Installation_Total_Qty=dataMS.data[i][31];
                    CSVSerBL.Installation_Unit_Cost=dataMS.data[i][32];
                    CSVSerBL.Managed_Services=dataMS.data[i][33];
                    CSVSerBL1.push(CSVSerBL); 
                }
            }
            component.set("v.WrapFileSerBL",CSVSerBL1);
        }else if(component.get("v.RTname")== 'SolutionBidLog'){
            console.log("dataMS", dataMS.data[2][2]);
            console.log("LENGTH", dataMS.data.length);
            var CSVSolBL1=[];
            for(var i=1;i < dataMS.data.length; i++){
                if(dataMS.data[i].length>1){                  
                    var CSVSolBL = {};
                    CSVSolBL.Wot = dataMS.data[i][0];
                    CSVSolBL.PID = dataMS.data[i][1];
                    CSVSolBL.Description = dataMS.data[i][2];                
                    CSVSolBL.Product_Category = dataMS.data[i][3]; 
                    CSVSolBL.Local_Currency = dataMS.data[i][4];
                    CSVSolBL.Exchange_Rate = dataMS.data[i][5];                
                    CSVSolBL.Extended_List_Price = dataMS.data[i][6];                
                    CSVSolBL.Extended_MRP = dataMS.data[i][7];                
                    CSVSolBL.MRP_Discount = dataMS.data[i][8];                
                    CSVSolBL.Net_Price = dataMS.data[i][9];                
                    CSVSolBL.Qty = dataMS.data[i][10];                
                    CSVSolBL.Product_Revenue = dataMS.data[i][11];                
                    CSVSolBL.Controllable_GM = dataMS.data[i][12];                
                    CSVSolBL.Standard_GM = dataMS.data[i][13];                
                    CSVSolBL1.push(CSVSolBL); 
                }
            }  
            
            
            component.set("v.WrapFile",CSVSolBL1);
        }
        component.set("v.showTable", 'Y');
        component.set("v.showSpinner", 'N');
    },
        saveSolutionBL: function(component, file, fileContents) {
            var action = component.get("c.saveTheFileSolBL");
            action.setParams({
                "recordId": component.get("v.recordId"),
                "jsonCSVWrapperList": JSON.stringify(component.get("v.WrapFile")),
                "versionUpgrade":false
            });   
            
            action.setCallback(this, function(a) {
                var typ;
                //if(a.getReturnValue().includes('Error')){
                if( a.getReturnValue().indexOf('Error') != -1 ){
                    typ='Error';  
                }else{
                    typ='Success';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title:typ+'!!',
                    type:typ,
                    "message": a.getReturnValue()+' File uploaded was: ' +component.get("v.uploadedFileName")
                });
                toastEvent.fire(); 
            });
            component.set("v.showTable", 'N');
            $A.enqueueAction(action);
            $A.get('e.force:refreshView').fire();
            
        },
            saveSolutionBLwithNewVersion: function(component, file, fileContents) {
                var action = component.get("c.saveTheFileSolBL"); 
                action.setParams({
                    "recordId": component.get("v.recordId"),
                    "jsonCSVWrapperList": JSON.stringify(component.get("v.WrapFile")),
                    "versionUpgrade":true
                });   
                action.setCallback(this, function(a) {
                    var typ;
                    //if(a.getReturnValue().includes('Error')){
                    if( a.getReturnValue().indexOf('Error') != -1 ){
                        typ='Error';  
                    }else{
                        typ='Success';
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title:typ+'!!',
                        type:typ,
                        "message": a.getReturnValue()+' File uploaded was: ' +component.get("v.uploadedFileName")
                    });
                    toastEvent.fire(); 
                });
                component.set("v.showTable", 'N');	
                $A.enqueueAction(action); 
                $A.get('e.force:refreshView').fire();
                
            }, 
                saveServicesBL: function(component, file, fileContents) {
                    var action = component.get("c.saveTheFileSerBL");
                    action.setParams({
                        "recordId": component.get("v.recordId"),
                        "jsonCSVWrapList": JSON.stringify(component.get("v.WrapFileSerBL")),
                        "versionUpgrade":false
                    });   
                    action.setCallback(this, function(a) {
                        var typ;
                        //if(a.getReturnValue()==null || a.getReturnValue().includes('Error')){
                        if( a.getReturnValue()==null || a.getReturnValue().indexOf('Error') != -1 ){
                            typ='Error';  
                        }else{
                            typ='Success';
                        }
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title:typ+'!!',
                            type:typ,
                            "message": a.getReturnValue()+' File uploaded was: ' +component.get("v.uploadedFileName")
                        });
                        toastEvent.fire(); 
                    });
                    component.set("v.showTable", 'N');
                    $A.enqueueAction(action); 
                    $A.get('e.force:refreshView').fire();
                },
                    saveServicesBLwithNewVersion: function(component, file, fileContents) {
                        var action = component.get("c.saveTheFileSerBL"); 
                        action.setParams({
                            "recordId": component.get("v.recordId"),
                            "jsonCSVWrapList": JSON.stringify(component.get("v.WrapFileSerBL")),
                            "versionUpgrade":true
                        }); 
                        action.setCallback(this, function(a) {
                            var typ;
                            //if(a.getReturnValue()==null || a.getReturnValue().includes('Error')){
                            if(a.getReturnValue()==null || a.getReturnValue().indexOf('Error') != -1 ){
                                typ='Error';  
                            }else{
                                typ='Success';
                            }
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title:typ+'!!',
                                type:typ,
                                "message": a.getReturnValue()+' File uploaded was: ' +component.get("v.uploadedFileName")
                            });
                            toastEvent.fire();
                        });
                        component.set("v.showTable", 'N');
                        $A.enqueueAction(action); 
                        $A.get('e.force:refreshView').fire();
                    },
                        getRecordTypeName: function(component, event, helper){
                            var action = component.get("c.getRecordTypeName");
                            action.setParams({ 
                                recordId : component.get("v.parentId")      
                            });
                            action.setCallback(this, function(a){
                                var rTName=a.getReturnValue(); 
                                component.set("v.RTname", a.getReturnValue());    
                            });
                            $A.enqueueAction(action);
                        },
                            Cancel:function(component, event, helper){
                                component.set("v.showTable", 'N');
                                //$A.get('e.force:refreshView').fire();
                            }


})