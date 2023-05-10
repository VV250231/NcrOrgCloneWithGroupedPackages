({
	doInit : function(component, event, helper)  {  
        this.createSlideJSON(component.get("v.body"), component); 
        var isAutoTimer = component.get("v.isAutoTimer");
         
        if(isAutoTimer){ 
            var delay = component.get("v.delay");
            window.setInterval(function(){
                helper.nextSlideTimer(component);
            },delay*1000);
        }
	},
    createSlideJSON : function(slidefacet, component){ 
        var autoColor = component.get("v.autoBgColor");
        var autoColorCounter = 0;
        var bgColors = ["#00bcd7","#0070d2","#009788","#faac58","#304a62","#660099"];
        var titleColors = ["#000","#fff","#fff","#000","#fff","#fff"];
    	var slides = []; 
        var currentBGColor,currentColor;
        
        for (var i = 0; i < slidefacet.length; i++) { var isFocused = slidefacet[i].get("v.isFocused") ; if(i === 0){ isFocused=true; } currentBGColor = slidefacet[i].get("v.bgColor") ; currentColor = slidefacet[i].get("v.titleColor"); if(autoColor){ currentBGColor = bgColors[autoColorCounter]; currentColor = titleColors[autoColorCounter]; autoColorCounter++; if(autoColorCounter >= bgColors.length){
                    autoColorCounter = 0;
                }
            }
            var singleSlide = {
                title : slidefacet[i].get("v.title") , 
                content : decodeURI(slidefacet[i].get("v.content")), 
                bgColor : currentBGColor, 
                contentColor: currentColor,
                isFocused: isFocused
            };      
    		slides.push(singleSlide);
        }
        component.set("v.slidersList",slides);
    } ,
    nextSlideTimer : function(component){ 
        var slideInfo = component.get("v.slidersList");
        if(slideInfo){
            for (var i = 0; i < slideInfo.length; i++) { //its last slide and focused, so move to first again 
if(slideInfo[i].isFocused && i >= slideInfo.length-1){
                    slideInfo[i].isFocused = false;
                    slideInfo[0].isFocused = true;
                    break;
                }else if(slideInfo[i].isFocused){
                    slideInfo[i].isFocused = false;
                    slideInfo[i+1].isFocused = true;
                    break;
                }
            }
        }
        component.set("v.slidersList",slideInfo); 
    },
    changePageNumber : function(component, event, helper){
        var target = event.target; 
        var selecIndex = target.getAttribute("data-selected-Index"); 
		var slideInfo = component.get("v.slidersList");
        if(slideInfo){
			for (var i = 0; i < slideInfo.length; i++) {   
                slideInfo[i].isFocused = false;
            }
            slideInfo[selecIndex].isFocused = true;
        }
        component.set("v.slidersList",slideInfo);
    }
})