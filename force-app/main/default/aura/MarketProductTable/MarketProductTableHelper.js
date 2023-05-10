({
	fetchAllRelatedOliHelper : function(cmp,event) {
        
        if(cmp.get("v.isCpqOpp")){ 
                cmp.set('v.mycolumns', [
                {label: 'MarketProduct Name', fieldName: 'MarketProductId', type: 'text'},
                {label: 'Quantity', fieldName: 'Quantity', type: 'Decimal'},
                ]);
        }
          
       else{
              cmp.set('v.mycolumns', [
                    {label: 'MarketProduct Name', fieldName: 'MarketProductId', type: 'text'},
                    {label: 'UnitPrice', fieldName: 'UnitPrice', type: 'text'},
                    {label: 'Quantity', fieldName: 'Quantity', type: 'Decimal'},
                    {label: 'TotalPrice', fieldName: 'TotalPrice', type: 'text'}
                    
                ]);      
         }            
            var action = cmp.get("c.getConsolatedData");
            action.setParams({ recId : cmp.get("v.OppId") ,
                               NoOfRec : '50000' 
                             });
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    cmp.set("v.prdList",response.getReturnValue());
                    //console.log(JSON.stringify(response.getReturnValue()));
                }
            });
            $A.enqueueAction(action);
	}
})