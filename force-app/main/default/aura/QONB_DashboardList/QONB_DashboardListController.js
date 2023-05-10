({
	myAction : function(component, event, helper) {
		
	},
    expand : function(component, event, helper) {
        helper.expandHelper(component, event, helper);
    },
    collapse : function(component, event, helper) {
        helper.collapseHelper(component, event, helper);
    },
    QuoteRedirect :function(component, event, helper) {
        var quoteNo = event.currentTarget.id;
        var url1="/apex/qb_landing_page?qno="+quoteNo;
        window.open(url1,'_blank'); 
    },
    downloadCsv : function(component,event,helper){
        var FileName = event.getSource().get("v.name");
        var stockData;
        var keys;
        if(FileName == 'QuotesInProcess'){
            // get the Records [contact] list from 'ListOfContact' attribute 
            stockData = component.get("v.QuoteInProcess");
            // in the keys variable store fields API Names as a key 
           // this labels use in CSV file header  
           keys = ['QuoteNo','Owner','OpportunityNumber','OpportunityValue','QuoteTotal','DateModified','HW_SW_Status','Main_SupportStatus','FinancialCallOff' ];
        }else if(FileName == 'OrderSubmittedBOC'){
            stockData = component.get("v.OrderSubmittedBOC");
             keys = ['QuoteNo','Owner','OpportunityNumber','OpportunityValue','QuoteTotal','DateModified','ActionOwner','Status','PendingReason','FinancialCallOff' ];
        }else if(FileName == 'OrdersReturned'){
            stockData = component.get("v.OrdersReturned");
             keys = ['QuoteNo','Owner','OpportunityNumber','OpportunityValue','QuoteTotal','DateModified','ReturnReason','ReturnComment','FinancialCallOff' ];
        }
        
        // call the helper function which "return" the CSV data as a String   
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData,keys);   
         if (csv == null){return;} 
        
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
	     var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self'; // 
          hiddenElement.download = FileName+'.csv';  // CSV file Name* you can change it.[only name not .csv] 
          document.body.appendChild(hiddenElement); // Required for FireFox browser
    	  hiddenElement.click(); // using click() js function to download csv file
        }
})