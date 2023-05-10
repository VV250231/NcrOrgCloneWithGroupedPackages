/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateRecent {
    public Integer indexRecent {get;set;}
    public Integer pageNumRecent {get;set;}
    public Integer totalPageRecent {get;set;}
    public Integer totalResultsRecent {get;set;}
    public List<Pager> pageListRecent {get;set;}
    public Boolean showPreviousRecent {get;set;}
    public Boolean showNextRecent {get;set;}
    public Boolean isAllRecent {get;set;}
         
    public PaginateRecent(Integer listSize, Integer pageSize){
        this.totalResultsRecent = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageRecent = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumRecent = 1;
        this.indexRecent = 0;
        this.isAllRecent = (listSize == pageSize)?true:false;
        updateNumbersRecent();
    }
    
    public Boolean ellipsisBeforeRecent {get;set;}
    public Boolean ellipsisAfterRecent {get;set;}
    public Integer lastPageRecent {get;set;}
    public Integer currentNumRecent {get;set;}
    public void updateNumbersRecent(){
        this.pageListRecent = new List<Pager>();
            lastPageRecent = this.totalPageRecent;
            currentNumRecent = pageNumRecent;
            
            if(this.totalPageRecent <= 5) {
                system.debug('***totalPageRecent less than or equal to 5***');
                ellipsisBeforeRecent = false;
                ellipsisAfterRecent = false;
                for(Integer i = 2; i <= (this.totalPageRecent - 1); i++) {
                    Boolean b = (i == pageNumRecent)?true:false;
                    this.pageListRecent.add(new Pager(i, b));
                }
                this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                this.indexRecent = this.pageNumRecent - 1;
            } else if(this.totalPageRecent > 5 && this.totalPageRecent <= 6) {
                system.debug('***totalPageRecent > 5 && <= 6***');
                ellipsisBeforeRecent = false;
                ellipsisAfterRecent = false;
                for(Integer i = 2; i <= (this.totalPageRecent - 1); i++) {
                    Boolean b = (i == pageNumRecent)?true:false;
                    this.pageListRecent.add(new Pager(i, b));
                }
                this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                this.indexRecent = this.pageNumRecent - 1;
            } else if(this.totalPageRecent == 7) {
                system.debug('***totalPageRecent == 7***');
                if(pageNumRecent >= 1 && pageNumRecent <= 3) {
                    ellipsisBeforeRecent = false;
                    ellipsisAfterRecent = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumRecent)?true:false;
                        this.pageListRecent.add(new Pager(i, b));
                    }
                    this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                    this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                    this.indexRecent = this.pageNumRecent - 1;
                } else if(pageNumRecent >= 4 && pageNumRecent <= 7) {
                    ellipsisBeforeRecent = true;
                    ellipsisAfterRecent = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumRecent)?true:false;
                        this.pageListRecent.add(new Pager(i, b));
                    }
                    this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                    this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                    this.indexRecent = this.pageNumRecent - 1;
                }
            } else if(this.totalPageRecent >= 8) {
                system.debug('***totalPageRecent >= 8***');
                if(pageNumRecent >= 1 && pageNumRecent <= 3) {
                    ellipsisBeforeRecent = false;
                    ellipsisAfterRecent = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumRecent)?true:false;
                        this.pageListRecent.add(new Pager(i, b));
                    }
                    this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                    this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                    this.indexRecent = this.pageNumRecent - 1;
                } else if(pageNumRecent >= 4 && pageNumRecent <= (this.totalPageRecent - 3)) {
                    system.debug('***pageNumRecent : >=4 && <=tp-3***');
                    ellipsisBeforeRecent = true;
                    if(pageNumRecent == 5) {
                        ellipsisAfterRecent = false;
                    } else {
                        ellipsisAfterRecent = true;
                    }
                    
                    for(Integer i = (pageNumRecent - 1); i <= (pageNumRecent + 2); i++) {
                        Boolean b = (i == pageNumRecent)?true:false;
                        this.pageListRecent.add(new Pager(i, b));
                    }
                    this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                    this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                    this.indexRecent = this.pageNumRecent - 1;
                } else if(pageNumRecent > (this.totalPageRecent - 3) && pageNumRecent <= this.totalPageRecent) {
                    system.debug('***pageNumRecent : >tp-3 && <=tp***');
                    ellipsisBeforeRecent = true;
                    ellipsisAfterRecent = false;
                    if((this.totalPageRecent - pageNumRecent) >= 4) {
                        system.debug('***(this.totalPageRecent - pageNumRecent) >= 4***');
                        for(Integer i = (this.totalPageRecent - pageNumRecent); i <= (this.totalPageRecent - 1); i++) {
                            Boolean b = (i == pageNumRecent)?true:false;
                            this.pageListRecent.add(new Pager(i, b));
                        }
                        this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                        this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                        this.indexRecent = this.pageNumRecent - 1;
                    } else {
                        system.debug('***(this.totalPageRecent - pageNumRecent) < 4***');
                        for(Integer i = (this.totalPageRecent - 4); i <= (this.totalPageRecent - 1); i++) {
                            Boolean b = (i == pageNumRecent)?true:false;
                            this.pageListRecent.add(new Pager(i, b));
                        }
                        this.showPreviousRecent = (this.pageNumRecent == 1)?false:true;
                        this.showNextRecent = (this.pageNumRecent == this.totalPageRecent)?false:true;
                        this.indexRecent = this.pageNumRecent - 1;
                    }
                }
            } //end of condition for totalPageRecent number
    }
         
    public void decrementRecent(){
        this.pageNumRecent = this.pageNumRecent - 1;
        updateNumbersRecent();
    }
     
    public void incrementRecent(){
        this.pageNumRecent++;
        updateNumbersRecent();
    }
 
    public class Pager{
        public Integer pageNumRecent {get;set;}
        public Boolean isActiveRecent {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumRecent = num;
            this.isActiveRecent = active;
        }
    }
}