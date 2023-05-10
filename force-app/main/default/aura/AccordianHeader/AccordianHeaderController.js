({
	doInit: function(component){
        

        var obj = [{
		"label": "", 
		"width": "5%",
        "class" : "",
        "DataType": "checkbox", 
         "value" : true,   
		"cars": [{
				"name": "Ford",
				"models": ["Fiesta", "Focus", "Mustang"]
			},
			{
				"name": "BMW",
				"models": ["320", "X3", "X5"]
			},
			{
				"name": "Fiat",
				"models": ["500", "Panda", "550"]
			}
		]
	},
	{
		"label": "Product Name",
		"width": "65%",
        "class" : "",
        "DataType": "",
        "readonly" :true,
        "value" : "My Test Product",
		"cars": [{
				"name": "Ford",
				"models": ["Fiesta", "Focus", "Mustang"]
			},
			{
				"name": "BMW",
				"models": ["320", "X3", "X5"]
			},
			{
				"name": "Fiat",
				"models": ["500", "Panda", "550"]
			}
		]
	},
    {
		"label": "Quantity",
		"width": "15%",
        "class" : "Input_Custom",
        "DataType": "text", 
		"cars": [{
				"name": "Ford",
				"models": ["Fiesta", "Focus", "Mustang"]
			},
			{
				"name": "BMW",
				"models": ["320", "X3", "X5"]
			},
			{
				"name": "Fiat",
				"models": ["500", "Panda", "550"]
			}
		]
	},
    {
		"label": "UnitPrice",
		"width": "15%",
        "class" : "",
         "DataType": "text",  
		"cars": [{
				"name": "Ford",
				"models": ["Fiesta", "Focus", "Mustang"]
			},
			{
				"name": "BMW",
				"models": ["320", "X3", "X5"]
			},
			{
				"name": "Fiat",
				"models": ["500", "Panda", "550"]
			}
		]
	}                            
    ];  
    component.set('v.TableHeader', obj);
    },
    
    ToggelSection:function(component,event,helper){
       var toggleText = component.get("v.ToggleTableBody");
        if(toggleText == 'slds-show'){
            component.set("v.ToggleTableBody",'slds-hide');
            component.set("v.CollapseIcon",'right');
            
        } 
        else{
            component.set("v.ToggleTableBody",'slds-show');
            component.set("v.CollapseIcon",'down');
        }
      },
    CollectBundleValue:function(component,event,helper){
       
        component.set("v.SelectAll",component.get("v.IsBundleSelected"));
        var tempv=component.get("v.BasrParent") ;
        
        
            var myEvent = $A.get("e.c:RightComponentEvent");
            myEvent.setParams({
                "SelectedBundle": component.get("v.BundleId"),
                "Status" : component.get("v.IsBundleSelected")
            });
            myEvent.fire();
           
        

    },
    Update_BundleName:function(component,event,helper){
            
            var timer = component.get('v.timer');
            clearTimeout(timer);
           
            var timer = setTimeout(function(){
                
               helper.Update_BundleName(component,event);
               
                clearTimeout(timer);
                component.set('v.timer', null);
            }, 400);
    
            component.set('v.timer', timer);   

    },
    AddBundleToFav : function(cmp,event,helper){
         if(cmp.get("v.IsFav")){
          
            var action = cmp.get("c.RemoveFavouriteBundle");
            action.setStorable();
            action.setParams({ "bundleId": cmp.get("v.BundleId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                       
                         var appEvent1 = $A.get("e.c:RefreshFavBundle");
                         appEvent1.fire(); 
                          
                    }
                
                  
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
            
        } 
        else{
            
            var action = cmp.get("c.addFavouriteBundle");
            action.setStorable();
            action.setParams({ "bundleId": cmp.get("v.BundleId") });
            action.setCallback(this, function (response) {
                var state = response.getState();
                    if(cmp.isValid() && state === "SUCCESS") {
                       
                         var appEvent1 = $A.get("e.c:RefreshFavBundle");
                         appEvent1.fire(); 
                                                  
                    }   
           });
           $A.getCallback(function() {
               $A.enqueueAction(action);
           })(); 
            
        }
    }
    
})