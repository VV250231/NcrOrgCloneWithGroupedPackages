({
    init : function(component, event, helper) {
        var IPT_PartnerCentral = $A.get("$Label.c.IPT_PartnerCentral"); //Partner Community URL Label
        component.set("v.IPTPartnerCommunityUrl", IPT_PartnerCentral);
        var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunityUser",isCommunity);
        });
        $A.enqueueAction(action);
        
          var action1 = component.get("c.getOppDetails");   
        action1.setParams({
            oppId : component.get("v.Opportuntyid")
        });
        action1.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS' && response.getReturnValue().length>0){                
                var retResponse = response.getReturnValue();
                component.set("v.isCPQOpp",retResponse[0].CPQ__c);
                
            }
        });
            $A.enqueueAction(action1);
    },
    
    ps : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:PS_Scheduler_New",
          
            componentAttributes: {
                recordId: component.get("v.Opportuntyid"),
                ScreenName:'PS'
            }
        });
        evt.fire();
        
    },
    LaunchAddProductScreen : function(component,event,helper){
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:SelectProductComponent",
            componentAttributes: {
                recordId: component.get("v.Opportuntyid"),
                ScreenName: 'AddProduct'
            }
        });
        evt.fire();
    },
    showToastHandle : function(component, event, helper) {
        console.log('### came');
    },
    
    LaunchAddProductScreenByCommunity : function(component,event,helper){
        //event.preventDefault();  
        var navService = component.find( "navService" ); 
        
        if(component.get("v.isCommunityUser")){
            var pageReference = {  
                type: "comm__namedPage",  
                attributes: {  
                    pageName: "selectproductcomponentpage"  
                },  
                state: {  
                    Opportuntyid:  component.get("v.Opportuntyid"),
                    ScreenName: 'AddProduct',
                    IsCommunityUser: true
                }  
            };  
            component.set("v.pageReference", pageReference);
            event.preventDefault();
            navService.navigate(pageReference);
        }
        
        else{
           
            var pageReference = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__SelectProductComponent',   
                },
                state: {
                    "c__Opportuntyid":  component.get("v.Opportuntyid"),
                    "c__ScreenName": 'AddProduct',
                    "c__IsCommunityUser": false
                }
            };  
            component.set("v.pageReference", pageReference);
            event.preventDefault();
            navService.navigate(pageReference);
        }
        
       
    },
    
     psByCommunity : function(component,event,helper){
        event.preventDefault();  
        var navService = component.find( "navServicePS" ); 
        
        if(component.get("v.isCommunityUser")){
            var pageReferenceps = {  
                type: "comm__namedPage",  
                attributes: {  
                    pageName: "productschedulernewpage"  
                },  
                state: {  
                    Opportuntyid:  component.get("v.Opportuntyid"),
                    ScreenName: 'PS',
                    IsCommunityUser: true
                }  
            };  
            sessionStorage.clear();
            console.log( 'State is ' + JSON.stringify( pageReferenceps.state ) );  
        }
        
        else{
            var pageReferenceps = {
                type: 'standard__component',
                attributes: {
                    componentName: 'c__PS_Scheduler_New',   
                },
                state: {
                    "c__Opportuntyid":  component.get("v.Opportuntyid"),
                    "c__ScreenName": 'PS',
                    "c__IsCommunityUser": false
                }
            };  
        }
        
        navService.navigate( pageReferenceps );  
    },
})