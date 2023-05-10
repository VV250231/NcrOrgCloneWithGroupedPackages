({
afterRender : function( component, helper,event ) { 
   
            this.superAfterRender();
            var didScrolled;
            var div = document.getElementById("_scrollResult");
            if(!$A.util.isEmpty(div)){
                
                div.onscroll = function(){
                    didScrolled = true; 
                };
                //Interval function to check if the user scrolled or if there is a scrollbar
                var intervalId = setInterval($A.getCallback(function(){
                    if(didScrolled){
                        didScrolled = false;
					    console.log(Math.round(parseInt(div.scrollTop + div.clientHeight)));
                        console.log(parseInt(div.scrollHeight));
                        
                        
					    if(parseInt(div.scrollHeight) <= parseInt(Math.round((div.scrollTop + div.clientHeight)))){

                            if(component.get("v.searchKey").length > parseInt(0) && component.get("v.PillsArray").length == 0){
                                //alert('Search Key');
                                helper.getNextPageForQueryString(component,event,component.get("v.AllreadyQueryDataSet"),component.get("v.searchKey"));
                            }
                            
                            else if(component.get("v.PillsArray").length > 0 && component.get("v.searchKey").length == 0){
                                //alert('pills condition' + component.get("v.PillsArray").length);
                                helper.getNextPageForFilter(component,event,component.get("v.AllreadyQueryDataSet"),component.get("v.PillsArray"));
                            	
                            }
                            
                            else if(component.get("v.PillsArray").length == 0 && component.get("v.searchKey").length == 0 && component.get("v.PillsArray").length == 0){
                                //alert('Scrool Condition 3');
                                helper.getNextPage(component,event); 
                            }
                               
                        }
                    }
                }), 450);
                component.set('v.intervalId', intervalId);
            }
            
             
        },
        unrender: function( component) {
           
            this.superUnrender();
            var intervalId = component.get( 'v.intervalId' );
            if ( !$A.util.isUndefinedOrNull( intervalId ) ) {
                window.clearInterval( intervalId );
            }
        }
    })