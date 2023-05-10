({
	fetchAllRelatedOli : function(cmp, event, helper) {
      var action = cmp.get("c.isCommunity");
        action.setCallback(this, function(response) {
            var isCommunity = response.getReturnValue(); 
            //component.set("v.isCommunityUser",isCommunity);
            //alert(isCommunity); 
            if(isCommunity){
                var url = window.location.href;
                var urlVar = url.split('?');
                var strParams = urlVar[1].split("&");
                var Opportuntyid = strParams[0].split("=")[1];
                var ScreenName = strParams[1].split("=")[1];
                var OppName = strParams[2].split("=")[1];
                //alert(OppName);
                cmp.set("v.OppId",Opportuntyid);
                cmp.set("v.isCpqOpp",strParams[1].split("=")[1]);
                cmp.set("v.OpportunityName",OppName);
			    helper.fetchAllRelatedOliHelper(cmp,event) ;           
            }
            else{
                helper.fetchAllRelatedOliHelper(cmp,event) ; 
            }
        });
        $A.enqueueAction(action);
	},
    RedirectToRecord:function(cmp,event,helper){
        //alert();
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": cmp.get("v.OppId")
        });
          navEvt.fire();
    }
    
    
})