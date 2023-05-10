({
    //Fetch the accounts from the Apex controller
    search: function(component) {
        var searchkey = component.find('searchKey').get('v.value');
        var ofset=component.get("v.ofset");
        var action = component.get("c.AccountSearched");
        component.set("v.spin",true);
        action.setParams({
            "searchkey":searchkey,
            "ofset":ofset
        });
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            if(ofset>=25){
                var prev=component.get("v.accounts1");
                component.set("v.inf",true);

                if(response.getReturnValue()!=null){
                for(var i=0; i<response.getReturnValue().length; i++){
                   prev.push(response.getReturnValue()[i]) ;
                    
                }
                if(prev.length<component.get("v.count")){
                        component.set("v.inf",true);
                } else{
                    component.set("v.inf",false);
                }   
                }
                
                component.set("v.accounts1", prev);
            }else{
               component.set("v.accounts1", response.getReturnValue()); 
                console.log(response.getReturnValue()+'---'+component.get("v.count"));
                if(response.getReturnValue().length<component.get("v.count")){
                        component.set("v.inf",true);
                }else{
                   component.set("v.inf",false); 
                }
            }
            component.set("v.spin",false);            
        }); 
        $A.enqueueAction(action);
    },
    getcount: function(component) {
        var searchkey = component.find('searchKey').get('v.value');
                component.set("v.spin",true);

        var action = component.get("c.count");
        
        action.setParams({
            "searchkey":searchkey,
        });
        action.setCallback(this, function(response) {
            component.set("v.count", response.getReturnValue());
            this.search(component);
                    component.set("v.spin",false);

        }); 
        $A.enqueueAction(action);
    }
    
})