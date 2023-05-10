({
	hideMsgAuto : function(component, event, helper) { 
        var time=setInterval(function(){
            var element = document.getElementById("containerCollapsable");            
            if(element!=null){
              element.style.display = 'block'; 
              helper.MSGfade(element,component);
              clearInterval(time);
            }
            
        }, 100);      

    },
    MSGfade : function(element,component) {
        //alert('hi');
        //var element = document.getElementById("containerCollapsable");
        var op = 1;  // initial opacity
        //element.style.display = 'block';
        var delay=3000;
        if(component.get("v.Error")){
            delay=10000;
            //console.log('@@#'+delay);
        }
         else if(component.get("v.Warning")){
             delay=10000;
        }
         //console.log('@@'+delay);
        /*var timer = setInterval(function () {
            if (op <= 0.1){                
                clearInterval(timer);
                element.style.display = 'none';
                //document.getElementById("containerCollapsable").innerHTML='';
            }
            element.style.opacity = op;
            element.style.filter = 'alpha(opacity=' + op * 100 + ")";
            op -= op * 0.5;
        }, delay); */  
        var timer = setTimeout(function () {            
                element.style.display = 'none';              
        }, delay);
    }   
    
    
    
})