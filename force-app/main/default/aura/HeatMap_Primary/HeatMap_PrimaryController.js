({
    doInit : function(component, event, helper) {
        helper.getLabels1(component);
        //helper.reset(component);
        helper.loadFinancialAccountDetail(component, helper); 
        helper.loadOppProductsYellowData(component, helper) ;
        
    },
    scriptloaded : function(component,event,helper){
       alert('script loaded');
    },
    genreatepdf : function(component,event,helper){
         alert(12);
       // $.noConflict();
           
        html2canvas($("#capture_screen"), {
            onrendered: function(canvas) {
                alert('1');
                console.log(canvas.toDataURL()); 
            }
        });
     },
    
})