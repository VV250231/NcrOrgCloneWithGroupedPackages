/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateSearchResult {
    public Integer indexSearchResult {get;set;}
    public Integer pageNumSearchResult {get;set;}
    public Integer totalPageSearchResult {get;set;}
    public Integer totalResultsSearchResult {get;set;}
    public List<Pager> pageListSearchResult {get;set;}
    public Boolean showPreviousSearchResult {get;set;}
    public Boolean showNextSearchResult {get;set;}
    public Boolean isAllSearchResult {get;set;}
         
    public PaginateSearchResult(Integer listSize, Integer pageSize){
        this.totalResultsSearchResult = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageSearchResult = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumSearchResult = 1;
        this.indexSearchResult = 0;
        this.isAllSearchResult = (listSize == pageSize)?true:false;
        updateNumbersSearchResult();
    }
    
    public Boolean ellipsisBeforeSearchResult {get;set;}
    public Boolean ellipsisAfterSearchResult {get;set;}
    public Integer lastPageSearchResult {get;set;}
    public Integer currentNumSearchResult {get;set;}
    public void updateNumbersSearchResult(){
        this.pageListSearchResult = new List<Pager>();
            lastPageSearchResult = this.totalPageSearchResult;
            currentNumSearchResult = pageNumSearchResult;
            
            if(this.totalPageSearchResult <= 5) {
                system.debug('***totalPageSearchResult less than or equal to 5***');
                ellipsisBeforeSearchResult = false;
                ellipsisAfterSearchResult = false;
                for(Integer i = 2; i <= (this.totalPageSearchResult - 1); i++) {
                    Boolean b = (i == pageNumSearchResult)?true:false;
                    this.pageListSearchResult.add(new Pager(i, b));
                }
                this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                this.indexSearchResult = this.pageNumSearchResult - 1;
            } else if(this.totalPageSearchResult > 5 && this.totalPageSearchResult <= 6) {
                system.debug('***totalPageSearchResult > 5 && <= 6***');
                ellipsisBeforeSearchResult = false;
                ellipsisAfterSearchResult = false;
                for(Integer i = 2; i <= (this.totalPageSearchResult - 1); i++) {
                    Boolean b = (i == pageNumSearchResult)?true:false;
                    this.pageListSearchResult.add(new Pager(i, b));
                }
                this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                this.indexSearchResult = this.pageNumSearchResult - 1;
            } else if(this.totalPageSearchResult == 7) {
                system.debug('***totalPageSearchResult == 7***');
                if(pageNumSearchResult >= 1 && pageNumSearchResult <= 3) {
                    ellipsisBeforeSearchResult = false;
                    ellipsisAfterSearchResult = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumSearchResult)?true:false;
                        this.pageListSearchResult.add(new Pager(i, b));
                    }
                    this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                    this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                    this.indexSearchResult = this.pageNumSearchResult - 1;
                } else if(pageNumSearchResult >= 4 && pageNumSearchResult <= 7) {
                    ellipsisBeforeSearchResult = true;
                    ellipsisAfterSearchResult = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumSearchResult)?true:false;
                        this.pageListSearchResult.add(new Pager(i, b));
                    }
                    this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                    this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                    this.indexSearchResult = this.pageNumSearchResult - 1;
                }
            } else if(this.totalPageSearchResult >= 8) {
                system.debug('***totalPageSearchResult >= 8***');
                if(pageNumSearchResult >= 1 && pageNumSearchResult <= 3) {
                    ellipsisBeforeSearchResult = false;
                    ellipsisAfterSearchResult = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumSearchResult)?true:false;
                        this.pageListSearchResult.add(new Pager(i, b));
                    }
                    this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                    this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                    this.indexSearchResult = this.pageNumSearchResult - 1;
                } else if(pageNumSearchResult >= 4 && pageNumSearchResult <= (this.totalPageSearchResult - 3)) {
                    system.debug('***pageNumSearchResult : >=4 && <=tp-3***');
                    ellipsisBeforeSearchResult = true;
                    if(pageNumSearchResult == 5) {
                        ellipsisAfterSearchResult = false;
                    } else {
                        ellipsisAfterSearchResult = true;
                    }
                    
                    for(Integer i = (pageNumSearchResult - 1); i <= (pageNumSearchResult + 2); i++) {
                        Boolean b = (i == pageNumSearchResult)?true:false;
                        this.pageListSearchResult.add(new Pager(i, b));
                    }
                    this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                    this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                    this.indexSearchResult = this.pageNumSearchResult - 1;
                } else if(pageNumSearchResult > (this.totalPageSearchResult - 3) && pageNumSearchResult <= this.totalPageSearchResult) {
                    system.debug('***pageNumSearchResult : >tp-3 && <=tp***');
                    ellipsisBeforeSearchResult = true;
                    ellipsisAfterSearchResult = false;
                    if((this.totalPageSearchResult - pageNumSearchResult) >= 4) {
                        system.debug('***(this.totalPageSearchResult - pageNumSearchResult) >= 4***');
                        for(Integer i = (this.totalPageSearchResult - pageNumSearchResult); i <= (this.totalPageSearchResult - 1); i++) {
                            Boolean b = (i == pageNumSearchResult)?true:false;
                            this.pageListSearchResult.add(new Pager(i, b));
                        }
                        this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                        this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                        this.indexSearchResult = this.pageNumSearchResult - 1;
                    } else {
                        system.debug('***(this.totalPageSearchResult - pageNumSearchResult) < 4***');
                        for(Integer i = (this.totalPageSearchResult - 4); i <= (this.totalPageSearchResult - 1); i++) {
                            Boolean b = (i == pageNumSearchResult)?true:false;
                            this.pageListSearchResult.add(new Pager(i, b));
                        }
                        this.showPreviousSearchResult = (this.pageNumSearchResult == 1)?false:true;
                        this.showNextSearchResult = (this.pageNumSearchResult == this.totalPageSearchResult)?false:true;
                        this.indexSearchResult = this.pageNumSearchResult - 1;
                    }
                }
            } //end of condition for totalPageSearchResult number
    }
         
    public void decrementSearchResult(){
        this.pageNumSearchResult = this.pageNumSearchResult - 1;
        updateNumbersSearchResult();
    }
     
    public void incrementSearchResult(){
        this.pageNumSearchResult++;
        updateNumbersSearchResult();
    }
 
    public class Pager{
        public Integer pageNumSearchResult {get;set;}
        public Boolean isActiveSearchResult {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumSearchResult = num;
            this.isActiveSearchResult = active;
        }
    }
}