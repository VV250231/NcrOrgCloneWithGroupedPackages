({
	showHideBigBox : function(component, event, helper) {
        if(component.get("v.hoverOnSmallBox")  || component.get("v.hoverOnBigBox")) {
            try {
                document.getElementById(component.get("v.boxLabel")).style.display = 'block' ; 
            } catch(error) {
                console.log('Error - '+ error) ;
            }
        } else {
            try {
                document.getElementById(component.get("v.boxLabel")).style.display = 'none' ; 
            } catch(error) {
                console.log('Error - '+ error) ;
            }
        }
	}
})