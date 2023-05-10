({
	doInit: function(component,event,helper){
    	helper.doInit(component,event,helper);
    },
    creatBundle:function(component,event,helper){
       var bndl = component.get("v.NewBundleName"); 
        if(bndl == null || bndl== ''){
            
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please Enter Name",
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
        else{
           
        var action = component.get("c.InsertBundle");    
        action.setParams({  
        BundleName : component.get("v.NewBundleName")
    	});
           
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {            

                	helper.doInit(component,event,helper);       
            } 
            component.set("v.NewBundleName",'');
    	});
    	$A.enqueueAction(action);

        }
    },
    Toggle_Bundle_Create:function(component,event,helper){
		var togglevale = component.get("v.toogleBundleCreate");
        if(togglevale==false){
            component.set("v.toogleBundleCreate",true);  
        }
        else{
            component.set("v.toogleBundleCreate",false);
        }  
        
    },
    Delete_Bundel_Selected:function(component,event,helper){
        
        var BundleObjToDelete=[];
        var BundleProductObjectToDelete=[];
        var item = component.get("v.HeaderValue");
        for(var i=0;i<item.length;i++){
            if(item[i].IsSelected){
                BundleObjToDelete.push({Id:item[i].Id});
            }
            else{ 

                for(var j=0 ; j<item[i].ProductList.length ; j++){
                    if(item[i].ProductList[j].IsProductSelected){
                     
                     BundleProductObjectToDelete.push({Id:item[i].ProductList[j].ProductId});
                    }
                    
                }
            }
        }
        
       
        
        if(BundleObjToDelete.length > 0 || BundleProductObjectToDelete.length > 0){
            helper.CallDeletemethod(component,event,helper,BundleObjToDelete,BundleProductObjectToDelete);        
        }
       
        else{
                
            /*var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                FloatMsgEvent.setParams({
                    "Msg" : "Select an Item to Delete",
                    "Category" : "Warning",
                    "isShow" : "True"
                });
                FloatMsgEvent.fire();*/
            //Ajay-jul2021
             var toastEvent = $A.get("e.force:showToast");
    			toastEvent.setParams({
       		 		"title": "Warning!",
       		 		"message": "Select an Item to Delete",
        			"type":"warning"
   			 	});
    		toastEvent.fire();

        }
        
    },
    AddBundel_to_ItemtoSchedule:function(component,event,helper){
        var OppId = component.get("v.OppId");
        var BundleObjToDelete=[];
        var BundleSpecificProduct=[];
        var item = component.get("v.HeaderValue");
        console.log(item);   
        for(var i=0;i<item.length;i++){ 
            
                    if(item[i].IsSelected){
                        BundleObjToDelete.push({Id:item[i].Id});   
                    }
                    
                    else{   
                        for(var j=0;j<item[i].ProductList.length;j++){
                            if(item[i].ProductList[j].IsProductSelected && item[i].ProductList[j].IsActive == true){
                                
                                BundleSpecificProduct.push({Id:item[i].ProductList[j].ProductId});
                               
                            }
                        }
                               
                    } 
             
             
        }     
        
       if(BundleObjToDelete.length > 0 || BundleSpecificProduct.length > 0){
           
            helper.AddBundel_to_ItemtoSchedule(component,event,helper,BundleObjToDelete,BundleSpecificProduct,OppId);
        } 
        else{
            var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
            FloatMsgEvent.setParams({
                "Msg" : "Please select Bundle/Product to add", 
                "Category" : "Warning",
                "isShow" : "True"
            });
            FloatMsgEvent.fire();
        }
    },
    RefreshCustomAccordian:function(component,event,helper){
       helper.doInit(component,event,helper);
    },
})