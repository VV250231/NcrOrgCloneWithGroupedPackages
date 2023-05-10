public with sharing class PaginateIdeaTheme {
    public Integer index {get;set;}
    public Integer pageNum {get;set;}
    public Integer totalPage {get;set;}
    public Integer totalResults {get;set;}
    public List<Pager> pageList {get;set;}
    public Boolean showPrevious {get;set;}
    public Boolean showNext {get;set;}
    public Boolean isAll {get;set;}
         
    public PaginateIdeaTheme(Integer listSize, Integer pageSize){
        this.totalResults = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPage = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNum = 1;
        this.index = 0;
        this.isAll = (listSize == pageSize)?true:false;
        updateNumbers();
    }
    
    public Boolean ellipsisBefore {get;set;}
    public Boolean ellipsisAfter {get;set;}
    public Integer lastPage {get;set;}
    public Integer currentNum {get;set;}
    
    public void updateNumbers(){
        this.pageList = new List<Pager>();
            lastPage = this.totalPage;
            currentNum = pageNum;
            
            if(this.totalPage <= 5) {
                system.debug('***totalPage less than or equal to 5***');
                ellipsisBefore = false;
                ellipsisAfter = false;
                for(Integer i = 2; i <= (this.totalPage - 1); i++) {
                    Boolean b = (i == pageNum)?true:false;
                    this.pageList.add(new Pager(i, b));
                }
                this.showPrevious = (this.pageNum == 1)?false:true;
                this.showNext = (this.pageNum == this.totalPage)?false:true;
                this.index = this.pageNum - 1;
            } else if(this.totalPage > 5 && this.totalPage <= 6) {
                system.debug('***totalPage > 5 && <= 6***');
                ellipsisBefore = false;
                ellipsisAfter = false;
                for(Integer i = 2; i <= (this.totalPage - 1); i++) {
                    Boolean b = (i == pageNum)?true:false;
                    this.pageList.add(new Pager(i, b));
                }
                this.showPrevious = (this.pageNum == 1)?false:true;
                this.showNext = (this.pageNum == this.totalPage)?false:true;
                this.index = this.pageNum - 1;
            } else if(this.totalPage == 7) {
                system.debug('***totalPage == 7***');
                if(pageNum >= 1 && pageNum <= 3) {
                    ellipsisBefore = false;
                    ellipsisAfter = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNum)?true:false;
                        this.pageList.add(new Pager(i, b));
                    }
                    this.showPrevious = (this.pageNum == 1)?false:true;
                    this.showNext = (this.pageNum == this.totalPage)?false:true;
                    this.index = this.pageNum - 1;
                } else if(pageNum >= 4 && pageNum <= 7) {
                    ellipsisBefore = true;
                    ellipsisAfter = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNum)?true:false;
                        this.pageList.add(new Pager(i, b));
                    }
                    this.showPrevious = (this.pageNum == 1)?false:true;
                    this.showNext = (this.pageNum == this.totalPage)?false:true;
                    this.index = this.pageNum - 1;
                }
            } else if(this.totalPage >= 8) {
                system.debug('***totalPage >= 8***');
                if(pageNum >= 1 && pageNum <= 3) {
                    ellipsisBefore = false;
                    ellipsisAfter = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNum)?true:false;
                        this.pageList.add(new Pager(i, b));
                    }
                    this.showPrevious = (this.pageNum == 1)?false:true;
                    this.showNext = (this.pageNum == this.totalPage)?false:true;
                    this.index = this.pageNum - 1;
                } else if(pageNum >= 4 && pageNum <= (this.totalPage - 3)) {
                    system.debug('***pageNum : >=4 && <=tp-3***');
                    ellipsisBefore = true;
                    if(pageNum == 5) {
                        ellipsisAfter = false;
                    } else {
                        ellipsisAfter = true;
                    }
                    
                    for(Integer i = (pageNum - 1); i <= (pageNum + 2); i++) {
                        Boolean b = (i == pageNum)?true:false;
                        this.pageList.add(new Pager(i, b));
                    }
                    this.showPrevious = (this.pageNum == 1)?false:true;
                    this.showNext = (this.pageNum == this.totalPage)?false:true;
                    this.index = this.pageNum - 1;
                } else if(pageNum > (this.totalPage - 3) && pageNum <= this.totalPage) {
                    system.debug('***pageNum : >tp-3 && <=tp***');
                    ellipsisBefore = true;
                    ellipsisAfter = false;
                    if((this.totalPage - pageNum) >= 4) {
                        system.debug('***(this.totalPage - pageNum) >= 4***');
                        for(Integer i = (this.totalPage - pageNum); i <= (this.totalPage - 1); i++) {
                            Boolean b = (i == pageNum)?true:false;
                            this.pageList.add(new Pager(i, b));
                        }
                        this.showPrevious = (this.pageNum == 1)?false:true;
                        this.showNext = (this.pageNum == this.totalPage)?false:true;
                        this.index = this.pageNum - 1;
                    } else {
                        system.debug('***(this.totalPage - pageNumFavorites) < 4***');
                        for(Integer i = (this.totalPage - 4); i <= (this.totalPage - 1); i++) {
                            Boolean b = (i == pageNum)?true:false;
                            this.pageList.add(new Pager(i, b));
                        }
                        this.showPrevious = (this.pageNum == 1)?false:true;
                        this.showNext = (this.pageNum == this.totalPage)?false:true;
                        this.index = this.pageNum - 1;
                    }
                }
            } //end of condition for totalPageFavorites number
    }
         
    public void decrement(){
        this.pageNum = this.pageNum - 1;
        updateNumbers();
    }
     
    public void increment(){
        this.pageNum++;
        updateNumbers();
    }
 
    public class Pager{
        public Integer pageNum {get;set;}
        public Boolean isActive {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNum = num;
            this.isActive = active;
        }
    }
}