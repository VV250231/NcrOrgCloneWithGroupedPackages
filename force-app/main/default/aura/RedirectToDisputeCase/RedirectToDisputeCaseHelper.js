({
	  serverSideCall : function( cmp, apexAction, params) {
                var p = new Promise( $A.getCallback( function( resolve , reject ) { 
                var action = cmp.get("c."+apexAction+"");
                action.setParams( params );
                action.setCallback( this , function(callbackResult) {
                    if(callbackResult.getState()=='SUCCESS') {
                        //alert(callbackResult.getReturnValue());
                        resolve( callbackResult.getReturnValue());
                    }
                    if(callbackResult.getState()=='ERROR') {
                        console.log('ERROR', callbackResult.getError());                             
                        reject( callbackResult.getError() ); 
                    }
                });
                $A.enqueueAction( action );
            }));
           
            return p;

	}
})