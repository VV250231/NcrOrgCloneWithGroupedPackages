({
	 doInit: function(cmp) {
       
         var action  = cmp.get("c.methodToReturnWrapper");
         action.setParams({ 
             Quoteid : cmp.get("v.recordId") 
         });
         action.setCallback(this, function(response){
             var state = response.getState();
             
             if (state === "SUCCESS"){
                  var res = response.getReturnValue();
                  var resparse = JSON.parse(JSON.stringify(res));
                  var proflename = resparse.profilename;
                  var trackAppStep = resparse.QuoteObj.Track_Approval_Steps__c;
                  var subType = resparse.QuoteObj.zqu__SubscriptionType__c;
                  var Quoteid= cmp.get("v.recordId");
                 if(proflename === "55 Hosted Solutions Sales" && trackAppStep === "Step1"){
                     alert( "Products cannot be edited after QA Approval. Please contact sales operations."); 
                 }
                 else{
                     
                     var urlEvent = $A.get("e.force:navigateToURL");
                     urlEvent.setParams({
                          "url": "/apex/diselectproducts?id="+Quoteid,
                          "isredirect": "true"
                      });
                      urlEvent.fire();
                 }
             }
             
         });
         $A.enqueueAction(action);
	}
})