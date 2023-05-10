({
	loadOpportunity : function(component,event) {
		var action = component.get("c.getOpportunity");    
        action.setParams({  
        rdId : component.get("v.OppId")     
    });
           
        action.setCallback(this, function(a) {
        if (a.getState() === "SUCCESS") {            
             //Added for greyout
            if(a.getReturnValue()['Non Admin']){
                 component.set("v.oppo", a.getReturnValue()['Non Admin']);
                 component.set("v.GreyOutPS", '<div class="slds-backdrop slds-backdrop_open" id="greyOutBackgroundPS" style="display:none;opacity: 0.4;"></div>');
                 if(a.getReturnValue()['Non Admin'].IsClosed === true){
                     component.set("v.GreyOutPS", '<div class="slds-backdrop slds-backdrop_open" id="greyOutBackgroundPS" style="display:block;opacity: 0.4;"></div>');
                       var FloatMsgEvent = $A.get("e.c:FloatMsgEvent");
                        FloatMsgEvent.setParams({
                            "Msg" : "Opportunity changes are not allowed after an opportunity has been closed. Please contact NSC Administrator using the Need Help button if you need to re-open or to make changes to this opportunity.",
                            "Category" : "Warning",
                            "isShow" : "True"
                        });
                        FloatMsgEvent.fire();
                 }  
            }
            if(a.getReturnValue()['Admin'] ){
                 component.set("v.oppo", a.getReturnValue()['Admin']);
                 //component.set("v.isAdminProfile",true);
                
               
            } 
            if(a.getReturnValue()['Other Admin'] ){
                 component.set("v.oppo", a.getReturnValue()['Other Admin']);
                 
                
            }        
          //End greyout
        } else if (a.getState() === "ERROR") { 
            $A.log("Errors", a.getError());
           
        }     
    });
    $A.enqueueAction(action);
	},
    setParam:function(component, event){ 
         //component.set("v.oppo", component.get("v.recordId"));
        $A.get("e.c:PassRecordIdEvent").setParams({
            "passRecordId" : component.get("v.OppId"),
            "callFromSelectPage":true
          }).fire();
    },
    
    aasFunctionalityAccess : function(component,event) {
         var action = component.get("c.aasFunctionalityAccess"); 
      action.setCallback(this, function(a) {
          if (a.getState() === "SUCCESS") {               
              var response=a.getReturnValue();
              var responselist=response.length;
              if(responselist > 0){
                  component.set("v.isAdminProfile",true);
              } 
              //alert(component.get("v.isAdminProfile"));
          }
          
          
          else if (a.getState() === "ERROR") {              
              $A.log("Errors", a.getError());
          }     
      });
      $A.enqueueAction(action);
    },
    ReInitiate:function(component,event){
        var IPT_PartnerCentral = $A.get("$Label.c.IPT_PartnerCentral"); //Partner Community URL Label
        component.set("v.IPTPartnerCommunityUrl", IPT_PartnerCentral);
         var action = component.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            component.set("v.isCommunityUser",isCommunity);
        });
        $A.enqueueAction(action);       
        var url = window.location.href;
        var urlVar = url.split('?');
        //console.log('urlVar =='+urlVar);
        var strParams = urlVar[1].split("&");
        var Opportuntyid = strParams[0].split("=")[1];
        var ScreenName = strParams[1].split("=")[1];
        
        //console.log('OppId@@: '+ Opportuntyid);
        //console.log('ScreenName@@: '+ScreenName);
        
        if(Opportuntyid !=null && ScreenName!=null){
            component.set("v.ScreenName", ScreenName);
            component.set("v.OppId", Opportuntyid);    
        }

        this.setParam(component, event);       
        this.loadOpportunity(component, event);         
       //this.aasFunctionalityAccess(component, event);        
    }
})