({
        doInit : function(component, event, helper) {
          
            helper.getPiclkistvalues(component);
            helper.getDivisionvalues(component);
            //helper.getUserFavBundle(component);//Added by pankaj for bundle component
            
        },
        searchProducts:function(component,event,helper){ 
            //component.set("v.ModalControll", true);
             //document.getElementById("spinnerdiv").style.display = "block";
            //console.log(component.get("v.ScreenName"));
            helper.searchProducts(component);             
        },
        CancelProductSearch:function(component,event,helper){   
            helper.CancelProductSearch(component);
        },        
        
        allFilterbox:function(component,event,helper){  
            helper.allFilterbox(component);
        },       
        
        fireCheckAllCheckboxes : function(component, event, helper){
            var FireSelectAll = event.getSource();            
            if(FireSelectAll.get("v.value")){
                helper.fireCheckAllCheckboxes(component, event, helper);
            }else{
                helper.fireUncheckAllCheckboxes(component, event, helper);
            }
            
        },
        passRecordId: function(component, event){        		
            component.set("v.passId", event.getParam("passRecordId"));  
        },
        searchKeyChange: function(component, event,helper) {
            if(component.find("GetSearchtext").get("v.value")){
               component.set("v.ShowSpinner",true);            
            var getFilterName = component.get("v.filterArray");
            var prodnametemp=[];        
            var searchKey = component.find("GetSearchtext").get("v.value");	
            var fltMsg = component.find( "clearbutton" );            
                $A.util.removeClass( fltMsg, "slds-hide" );
                $A.util.addClass( fltMsg, "slds-show" );		
            component.set("v.srchKey", searchKey);            
              if(getFilterName!=null && getFilterName.length>0){
                var i;
                for (i = 0; i < component.get("v.prodnameFltr").length; i++) {
                  var  str = JSON.stringify(component.get("v.prodnameFltr")[i].prd.Name);
                    if(searchKey){
                       if(str.toUpperCase().includes(searchKey.toUpperCase())){
                        prodnametemp.push(component.get("v.prodnameFltr")[i]);
                       }  
                    }  
                }
            }
            else{
                var i;
                for (i = 0; i < component.get("v.prodname2").length; i++) {
                  var  str = JSON.stringify(component.get("v.prodname2")[i].prd.Name);
                    if(searchKey){
                        if(str.toUpperCase().includes(searchKey.toUpperCase())){
                            console.log('--'+component.get("v.prodname2")[i]);
                            prodnametemp.push(component.get("v.prodname2")[i]);
                       }
                    }
                    
                }
                
            }
            component.set("v.prodname", prodnametemp); 
            
            
            var msgarray=[];
            if(component.get("v.srchKey")){
                 msgarray.push(component.get("v.srchKey").toUpperCase());
            }
           
               if(component.get("v.prodname").length==0){
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                    FloatMsgEvent.setParams({
                        "Msg" : "No Product Found With Name " + msgarray+ " .Please Change your Search Criteria.",
                        "Category" : "Warning",
                        "isShow" : "True"
                    });
                    FloatMsgEvent.fire();
               } else{
                  helper.sortProdList(component, event, helper); 
               }
            var action = component.get("c.dummyCall");            
            action.setCallback(this, function(a) {
                component.set("v.ShowSpinner",false);
                
            });
            $A.enqueueAction(action); 
            } 
        },    
        RemovePill:function(component, event, helper) {
            helper.RemovePill(component, event, helper);
            //this is to render the searchresult based on the selected filter
            var getFilterName = component.get("v.filterArray");
            component.set("v.tempfilterArray",getFilterName);
            document.getElementById("spinnerdiv").style.display = "block";
            //if(getFilterName.length>0){
            var action = component.get("c.SearchFilteredProducts");
            action.setParams({
                "filterSelected":getFilterName,
                "searchKey": component.get("v.srchKey"),
                 "recordId" :component.get("v.passId")
                
            });
            action.setCallback(this, function(a) {
                component.set("v.prodname", a.getReturnValue());
                 component.set("v.prodname2",a.getReturnValue());
                 helper.sortProdList(component, event, helper);
                                 document.getElementById("spinnerdiv").style.display = "none";

                
                 
            });
            $A.enqueueAction(action);
           // }
            /*else{
            // Dummy call to show spinner, this is work around as spinner is not showing up for non server call    
            var action = component.get("c.dummyCall");            
            action.setCallback(this, function(a) {
                 document.getElementById("spinnerdiv").style.display = "none";
                            component.set("v.prodname",component.get("v.prodname2"));
                             helper.sortProdList(component, event, helper);
            });
            $A.enqueueAction(action);
            }*/
            
        },
        
        ClearAllFilters:function(component,event,helper){        
            helper.ClearAllFilters(component,event,helper);
        },
    GetFilterId:function(component, event, helper){
        var id = event.getSource().get("v.text");
        if (event.getSource().get("v.value")) {
            // Checkbox is checked - add id to checkedContacts
            if (component.get("v.tempfilterArray").indexOf(id)< 0) {        
                component.get("v.tempfilterArray").push(id);
                component.set("v.tempfilterArray", component.get("v.tempfilterArray")); 
            } 
        }
        else {
            // removing pills based on unchecking the checkboxes
            var ArraySize = component.get("v.tempfilterArray");
            for(var i=0; i<(ArraySize.length); i++)               
                if( ArraySize[i] === id) {
                    ArraySize.splice(i,1);               
                }
            component.set("v.tempfilterArray", ArraySize);      
        } 
    },
    ApplyFilter : function(component, event, helper){
        var item = new Array();                  
        item = component.get("v.tempfilterArray");                 
        if(item.length>0){                    
            var fltMsg = component.find( "clearbutton" );
            $A.util.addClass( fltMsg, "slds-show" );
            component.set("v.body", ""); 
            component.set("v.filter", true);                    
        }
        component.set("v.filterArray",component.get("v.tempfilterArray"));
        var getFilterName = component.get("v.filterArray");
        //alert('Filter Name'+getFilterName);
        var action = component.get("c.SearchFilteredProducts");
        
        action.setParams({
            "filterSelected":getFilterName,
            "searchKey": component.find("GetSearchtext").get("v.value"),
            "recordId" :component.get("v.passId")
        });
        action.setCallback(this, function(a) {
            
            component.set("v.prodname", a.getReturnValue());
            component.set("v.prodnameFltr", component.get("v.prodname"));
            helper.sortProdList(component, event, helper);
            document.getElementById("spinnerdiv").style.display = "none";
        });
        document.getElementById("spinnerdiv").style.display = "block";
        $A.enqueueAction(action);
    },
        
        SingleFavProduct: function(component, event, helper){ 	
            
            helper.SingleFavProduct(component,event,helper);  

        },        
         SingleUnFavProduct: function(component, event, helper){            
            helper.SingleUnFavProduct(component,event,helper); 
         },
        
         SingleScheduleProduct: function(component, event, helper){
                
                helper.SingleScheduleProduct(component,event,helper);    
          },
       
         SingleUnScheduleProduct: function(component, event, helper){
                      
                helper.SingleUnScheduleProduct(component,event,helper);    
         }, 
            bulkfavourite: function(component, event, helper){
             if(component.get( "v.prodname").length ==0){
               return;
             }
              if(component.find("SelectAllCheckBox").get("v.value") &&((component.get("v.filterArray")!=null && component.get("v.filterArray").length>0)) || (component.get("v.srchKey")!=null && component.get("v.srchKey").length>0)){
				helper.bulkfavourite(component,event,helper); 
            }
            else if(component.find("SelectAllCheckBox").get("v.value")==false){
                               

                   helper.bulkfavourite(component,event,helper); 
            }else{
                
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "Bulk Favourite Works only for Filtered/Search Products.",
                                "Category" : "Warning",
                                "isShow" : "True"
                            });
                            FloatMsgEvent.fire();  
            }
              
        },
     
     bulkSchedule: function(component, event, helper){ 
         if(component.get( "v.prodname").length ==0){
             return;
         }
        if(component.find("SelectAllCheckBox").get("v.value") &&((component.get("v.filterArray")!=null && component.get("v.filterArray").length>0)) || (component.get("v.srchKey")!=null && component.get("v.srchKey").length>0)){
			       helper.bulkSchedule(component,event,helper); 
           }else if(component.find("SelectAllCheckBox").get("v.value")==false){
               helper.bulkSchedule(component,event,helper);
           }else{
                var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                            FloatMsgEvent.setParams({
                                "Msg" : "Bulk Scheduling Works only for Filtered/Search Products.",
                                "Category" : "Warning",
                                "isShow" : "True"
                            });
                            FloatMsgEvent.fire();  
            }
        },
    addSchedule:function(component,event,helper){           
            helper.addSchedule(component);             
        },
   showAlertMessage:function(component, event, helper){
        var idUnschedule = event.currentTarget;
        var iddx = idUnschedule.dataset.ids;
        component.set("v.unScheduleId", iddx);
        /*Commented by saritha most of the lines below to disbale Multiple Instances found for Product  " +multiplescheProducts+". 
        Use Item to Schedule Section/Scheduler Page error .*/
        //var ismultiple=false;
       // var  multiplescheProducts=[];
        //var  multiplescheProducts1=[]; 
        //var idx = event.currentTarget;
        //var idd=idx.dataset.ids;
        var idd = component.get("v.unScheduleId") ; 
        //alert('id' +idd);
       /* for (var i = 0; i < component.get("v.prodname").length; i++) {
            var str = component.get("v.prodname")[i].prd.Id;
            if(str.toUpperCase()==(idd.toUpperCase())){
                if(component.get("v.prodname")[i].HasMultiple==true){     
                    component.get("v.prodname")[i].HasSchedule=true; 
                    multiplescheProducts.push(component.get("v.prodname")[i].ProductName);
                    
                                ismultiple=true;
                                
                                
                            }
                        }
                } */
         /*if(ismultiple==true){  
             var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
             FloatMsgEvent.setParams({
                 "Msg" : "Multiple Instances found for Product  " +multiplescheProducts+". Use Item to Schedule Section/Scheduler Page to Unschedule this Product",
                 "Category" : "Error",
                 "isShow" : "True"
             });
             FloatMsgEvent.fire(); 
         }*/
        // else{
             for (var i = 0; i < component.get("v.prodname2").length; i++) {
                 //console.log(JSON.stringify(component.get("v.prodname2")[i]));
                 var  str = component.get("v.prodname2")[i].prd.Id;
                 if(str.toString()==iddx.toString()){                
                     component.set("v.unScheduleName", component.get("v.prodname2")[i].prd.Name);
                     break;
                 }
             }
             document.getElementById('Modal').style.display='block';
             document.getElementById('greyBackground').style.display='block';
             document.getElementById('searchwindow').style.zIndex="9000";
             
        // }
     },
    closeAlertWindow:function(component, event, helper){
        document.getElementById('Modal').style.display='none';
        document.getElementById('greyBackground').style.display='none';
        document.getElementById('searchwindow').style.zIndex="9001";
         document.getElementById('BulkModal').style.display='none';
        var checkedProds = component.find( "TheCheckBox" );
        var selectedprod = [];
        for (var i = 0; i < checkedProds.length ; i++){  
            if(checkedProds[i].get("v.value") == true){  
                selectedprod.push(checkedProds[i].get("v.text")); 
                
            }
        }
        for (var j = 0; j < component.get("v.prodname").length; j++) {
            for (var k = 0; k < selectedprod.length ; k++){  
                if(selectedprod[k] == component.get("v.prodname")[j].prd.Id){  
                    component.get("v.prodname")[j].HasSchedule=true;  
                }
            }                
        }
        
    },
    BulkunScheduleProduct:function(component,event,helper){
        helper.BulkunScheduleProduct(component,event,helper);
        
    },
     AddToBundle : function(component,event,helper){
         helper.AddToBundle(component,event,helper);
    },
    refreshBundle:function(component,event,helper){
        var message = event.getParam("CallFromBundleforRefresh");
        
        if(message == 'call_from_child'){
            helper.getUserFavBundle(component);
            
        }
         
        else{
           
			var ToggelBundleComponent = component.get("v.ToggelBundleComponent");
        	component.set("v.ToggelBundleComponent", ToggelBundleComponent == false ? true : false);            
        }

    }
    })