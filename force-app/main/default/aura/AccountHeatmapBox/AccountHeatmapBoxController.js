({
	doColorAssignment : function(component, event, helper) {
        if(component.get("v.boxLabel") == 'Cash Management')
		debugger ;
        if(component.get("v.boxLabel") == 'Transaction Fraud')
            debugger ;
        var fieldValue = component.get("v.boxValue") ;
        var finalColor = 'darkslategrey' ;
        if(fieldValue) {
            /* var contentHeight = $('#child'+fieldValue ).height();
            var containerHeight = $('#parent'+ fieldValue).height();
            if(contentHeight > containerHeight) {
                alert("Content larger than container");
                var showMore = $('<button id="showMore" value="Show More">Show More</button>');
                showMore.prependTo('#child' + fieldValue);
            }
            */
            var valueArray = fieldValue.split(';') ;
            var tempBoolean = false;
            
            component.set("v.valueList" ,valueArray) ;
             /* this teller logic has been added by Varsha w.r.t story EBA_SF- 1474 and it is added because 
             * we want to show yellow color if there is NCR value is selected along with Unknown solutions
             * but earlier it used to be darkslategrey only and just to avoid changes in existing color coding
             new logics are written differently from line 26-61*/
            if(component.get("v.boxLabel") === 'Teller'){
                var tellerValue = valueArray;
                
                for(var i=0; i<tellerValue.sort().length; i++) {
                    
                    if(tellerValue[i].includes('NCR') || tellerValue[i].includes('Authentic')||tellerValue[i].includes('Channel Services-Teller')) {
                        finalColor = 'green' ;
                        tempBoolean = true ;
                        if(tellerValue.includes('Argo')){
                            if(tempBoolean)
                            	finalColor = 'yellow' ;
                            else
                                finalColor = 'red' ;
                        }
                        if(tellerValue[i].includes('Partial')) {
                            finalColor = 'yellow' ;
                            tempBoolean = false ;
                        }
                        if(tellerValue[i].includes('MX')) {
                            finalColor = 'yellow' ;
                            tempBoolean = false ;
                        }
                        
                    } else if( !( tellerValue[i].includes('No Solution') || tellerValue[i].includes('N/A') || tellerValue[i].includes('Unknown') ) ) {
                        if(tempBoolean)
                            finalColor = 'yellow' ;
                        else
                            finalColor = 'red' ;
                    } else {
                        if(tempBoolean)
                            finalColor = 'yellow' ;
                        else
                            finalColor = 'darkslategrey' ;
                    }
                }	   
            }
            else{
                for(var i=0; i<valueArray.length; i++) {
                    if(valueArray[i].includes('NCR') || valueArray[i].includes('Authentic')) {
                        finalColor = 'green' ;
                        tempBoolean = true ;
                        if(valueArray[i].includes('Partial')) {
                            finalColor = 'yellow' ;
                            tempBoolean = false ;
                        }
                        if(valueArray[i].includes('MX')) {
                            finalColor = 'yellow' ;
                            tempBoolean = false ;
                        }
                        
                    } else if( !( valueArray[i].includes('No Solution') || valueArray[i].includes('N/A') || valueArray[i].includes('Unknown') ) ) {
                        if(tempBoolean)
                             finalColor = 'yellow' ;
                        else
                             finalColor = 'red' ;
                    } else {
                        finalColor = 'darkslategrey' ;
                    }
            }
            }
        } 
        component.set("v.boxColor" , finalColor) ;
        if(finalColor == 'yellow') {
            component.set("v.textColor" , 'black') ;
        }else {
            component.set("v.textColor" , 'white') ;
        }
        
	} ,
    
    showPopOver: function(component, event, helper) {
        debugger ;
        component.set("v.hoverOnSmallBox" , true) ;
       helper.showHideBigBox(component, event, helper) ;
    } , 
    
    hidePopOver : function(component, event, helper) {
        debugger ;
         component.set("v.hoverOnSmallBox" , false) ;
        helper.showHideBigBox(component, event, helper) ;
        
    } ,
    
    hoverBox2 : function(component, event, helper) {
        component.set("v.hoverOnBigBox"  , true) ;
        helper.showHideBigBox(component, event, helper) ;
    } ,
    
    mouseOutBox2 : function(component, event, helper) {
        component.set("v.hoverOnBigBox"  , false) ;
        helper.showHideBigBox(component, event, helper) ;
    }
    
    
})