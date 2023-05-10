({
	afterRender: function (cmp,helper) {
        this.superAfterRender();

        helper.windowClick = $A.getCallback(function(event) {
            console.log('doc click for comp' + cmp.get("v.fltrIndex"));
            if(cmp.isValid()) {
            	helper.clearExistPopup(cmp, event);  
            }
        });
        document.addEventListener('click',helper.windowClick);      

    },
    
    rerender : function(cmp, helper){
        this.superRerender();
        if(($A.util.isUndefinedOrNull(cmp)) || (!cmp.isValid())) {
        	document.removeEventListener('click',helper.windowClick);   
        }
    },
    
    unrender: function (cmp,helper) {
        this.superUnrender();
        document.removeEventListener('click',helper.windowClick);        
    }
})