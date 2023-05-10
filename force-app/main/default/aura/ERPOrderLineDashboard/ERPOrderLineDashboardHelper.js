({
	pagination:function(component,event){
        var sObjectList = component.get("v.data");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        var currPage=component.get("v.currentPage");
        // check if whichBtn value is 'next' then call 'next' helper method
       //alert(component.get("v.currentPage") );
        if (whichBtn == 'next') {
            component.set("v.currentPage", parseInt(currPage) + 1);
            //alert(component.get("v.currentPage") );
            this.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage",parseInt(currPage) - 1);
            //alert(component.get("v.currentPage") );
            this.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
	next : function(component,event,sObjectList,end,start,pageSize){
    	var Paginationlist = [];
        var counter = 0;
        console.log(sObjectList)
        for(var i = end + 1; i < end + pageSize + 1; i++){
        	if(sObjectList.length > i){ 
            	Paginationlist.push(sObjectList[i]);  
            }
            counter ++ ;
        }
        console.log(Paginationlist);
       	start = start + counter;
        end = end + counter;
        //alert(start);
        //alert(end);
        component.set("v.startPage",start);
       	component.set("v.endPage",end);
        component.set('v.paginationList', Paginationlist);
   },            
   // navigate to previous pagination record set   
    previous : function(component,event,sObjectList,end,start,pageSize){
    	var Paginationlist = [];
        var counter = 0;
        for(var i= start-pageSize; i < start ; i++){
        	if(i > -1){
                Paginationlist.push(sObjectList[i]); 
                counter ++;
            }else{
            	start++;
            }
        }
        start = start - counter;
        end = end - counter;
        //alert(start);
        //alert(end);
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        component.set('v.paginationList', Paginationlist);
 	}, 
    jumpToPage:function(component){
       var pageNum = component.find("inp1").get("v.value");
        //component.set("v.currentPage",1);
        if(pageNum===''||pageNum===null){
        	alert("Please enter page number first");
            component.find("inp1").focus();
        } 
        else{
            var totalRecord = component.get("v.totalRecordsCount");
       		var conList=component.get("v.data");
        	var pageSize = component.get("v.pageSize");
        	var totalPage=component.get("v.totalPagesCount");
            var regex = /^[0-9]+$/;
            var isValid = regex.test(pageNum);
            if(pageNum==0||pageNum<0||!isValid){
                alert("Please enter valid page number");
                pageNum=component.get("v.currentPage");;
            }
            if(totalPage<pageNum){
                alert("There are only "+totalPage+" pages, enter page in limit");
                component.find("inp1").set("v.value",null);
                component.find("inp1").focus();
                pageNum=component.get("v.currentPage");
            }
            else{
                //var counter = 0;
            	var paginationList = [];
                var currPage = component.get("v.currentPage");
                if(pageNum>currPage){
                    var start = component.get("v.startPage");
                    var end = component.get("v.endPage");
                    component.set("v.currentPage",pageNum);
                    for(var i= currPage;i<pageNum-1;i++){
                        var start = start+pageSize;
                    	var end = end+pageSize;     	
                    }
                    this.next(component, event, conList, end, start, pageSize);
                }
                if(pageNum<currPage){
                    //var diff = pageNum - currPage;
                    var start = component.get("v.startPage");
                    var end = component.get("v.endPage");
                    component.set("v.currentPage",pageNum);
                    for(var i= currPage-1;i>pageNum;i--){
                        var start = start-pageSize;
                    	var end = end-pageSize;
                    }
                   	this.previous(component, event, conList, end, start, pageSize);
                }
                component.find("inp1").set("v.value",null);
            }
        }
    },
     setPaginationList:function(component){
       	var pageSize = component.get("v.pageSize");
         //alert(pageSize);
    	var conList=component.get("v.data");
        console.log(conList);
            //component.set("v.totalSize", component.get("v.contactList").length);
        if(conList.length< pageSize){
        	pageSize = conList.length;
        }
        var paginationList = [];
        for(var i=0; i< pageSize; i++){
            paginationList.push(conList[i]);
        }
        component.set("v.paginationList", paginationList);
        var totalRecordsList = component.get("v.data");
        var totalLength = totalRecordsList.length ;
         //alert(totalLength);
        component.set("v.totalRecordsCount", totalLength);
        component.set("v.startPage",0);
        component.set("v.endPage",pageSize-1);
        component.set("v.pageSize",pageSize);
        component.set("v.currentPage",1);
        console.log(paginationList);
        component.set("v.totalPagesCount", Math.ceil(totalLength / pageSize));
         //alert(component.get("v.totalPagesCount"));
         component.set("v.pageSize",20);  
    },
})