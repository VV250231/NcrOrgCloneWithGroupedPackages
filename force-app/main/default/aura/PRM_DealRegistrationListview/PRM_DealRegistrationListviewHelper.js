({
    pagination : function(component, event) 
    {
        var sObjectList = component.get("v.ObjectData");
        var start = 0;
        var end = 0;
        var pageSize = component.get("v.pageSize");
        var Paginationlist = [];
        var counter = 0;
        var pages = parseInt(sObjectList.length/pageSize);
        var paginationTable = [];
        
        if (sObjectList.length === 0) {
            component.set("v.PaginationList", null);
        }
        for (counter=0; counter < pages; counter++) {
            end = start + (pageSize-1);
            paginationTable.push({
                pageNo: counter+1,
                startIndex: start,
                endIndex: end
            });
            start = end + 1;
        }
        
        console.log(paginationTable);
        if ((sObjectList.length%pageSize) != 0) {
            pages++;
            end = start + ((sObjectList.length%pageSize)-1);
            paginationTable.push({
                pageNo: counter+1,
                startIndex: start,
                endIndex: end
            });
        }
        
        component.set("v.totalPages",pages);
        // Set first page
        
        start = paginationTable[0].startIndex;
        end = paginationTable[0].endIndex;
        component.set("v.startPage",start);
        component.set("v.endPage",end);
        //alert(start);
        //alert(end);
        
        Paginationlist = sObjectList.slice(start,end+1);
        console.log(sObjectList[0]);
        //alert(Paginationlist[0].Name);
        component.set("v.PaginationList", Paginationlist);
        component.set("v.currentPage",1);
        component.set("v.paginationTable",paginationTable);
    },
    
    hNext: function (component, event) 
    {
        var sObjectList = component.get("v.ObjectData");
        var currentPage = component.get("v.currentPage");
        var pages = component.get("v.totalPages");
        var paginationTable = component.get("v.paginationTable");
        if (currentPage < pages) {
            currentPage++;
            var start = paginationTable[currentPage-1].startIndex;
            var end = paginationTable[currentPage-1].endIndex;
            component.set("v.start",start);
            component.set("v.end",end);
            var Paginationlist = sObjectList.slice(start,end+1);
            component.set('v.PaginationList', Paginationlist);
            component.set('v.currentPage',currentPage);
        }
    },
    
    hPrevious: function (component, event) 
    {
        var sObjectList = component.get("v.ObjectData");
        var currentPage = component.get("v.currentPage");
        var pages = component.get("v.totalPages");
        var paginationTable = component.get("v.paginationTable");
        if (currentPage >=1 ) {
            if (currentPage > 1) {
                currentPage--;
            }           
            var start = paginationTable[currentPage-1].startIndex;
            var end = paginationTable[currentPage-1].endIndex;
            component.set("v.start",start);
            component.set("v.end",end);
            var Paginationlist = sObjectList.slice(start,end+1);
            component.set('v.PaginationList', Paginationlist);
            component.set('v.currentPage',currentPage);
        }
    },   
})