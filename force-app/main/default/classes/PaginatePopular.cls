/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginatePopular {
    public Integer indexPopular {get;set;}
    public Integer pageNumPopular {get;set;}
    public Integer totalPagePopular {get;set;}
    public Integer totalResultsPopular {get;set;}
    public List<Pager> pageListPopular {get;set;}
    public Boolean showPreviousPopular {get;set;}
    public Boolean showNextPopular {get;set;}
    public Boolean isAllPopular {get;set;}
         
    public PaginatePopular(Integer listSize, Integer pageSize){
        this.totalResultsPopular = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPagePopular = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumPopular = 1;
        this.indexPopular = 0;
        this.isAllPopular = (listSize == pageSize)?true:false;
        updateNumbersPopular();
    }
    
    public Boolean ellipsisBeforePopular {get;set;}
    public Boolean ellipsisAfterPopular {get;set;}
    public Integer lastPagePopular {get;set;}
    public Integer currentNumPopular {get;set;}
    public void updateNumbersPopular(){
        this.pageListPopular = new List<Pager>();
            lastPagePopular = this.totalPagePopular;
            currentNumPopular = pageNumPopular;
            
            if(this.totalPagePopular <= 5) {
                system.debug('***totalPagePopular less than or equal to 5***');
                ellipsisBeforePopular = false;
                ellipsisAfterPopular = false;
                for(Integer i = 2; i <= (this.totalPagePopular - 1); i++) {
                    Boolean b = (i == pageNumPopular)?true:false;
                    this.pageListPopular.add(new Pager(i, b));
                }
                this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                this.indexPopular = this.pageNumPopular - 1;
            } else if(this.totalPagePopular > 5 && this.totalPagePopular <= 6) {
                system.debug('***totalPagePopular > 5 && <= 6***');
                ellipsisBeforePopular = false;
                ellipsisAfterPopular = false;
                for(Integer i = 2; i <= (this.totalPagePopular - 1); i++) {
                    Boolean b = (i == pageNumPopular)?true:false;
                    this.pageListPopular.add(new Pager(i, b));
                }
                this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                this.indexPopular = this.pageNumPopular - 1;
            } else if(this.totalPagePopular == 7) {
                system.debug('***totalPagePopular == 7***');
                if(pageNumPopular >= 1 && pageNumPopular <= 3) {
                    ellipsisBeforePopular = false;
                    ellipsisAfterPopular = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumPopular)?true:false;
                        this.pageListPopular.add(new Pager(i, b));
                    }
                    this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                    this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                    this.indexPopular = this.pageNumPopular - 1;
                } else if(pageNumPopular >= 4 && pageNumPopular <= 7) {
                    ellipsisBeforePopular = true;
                    ellipsisAfterPopular = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumPopular)?true:false;
                        this.pageListPopular.add(new Pager(i, b));
                    }
                    this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                    this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                    this.indexPopular = this.pageNumPopular - 1;
                }
            } else if(this.totalPagePopular >= 8) {
                system.debug('***totalPagePopular >= 8***');
                if(pageNumPopular >= 1 && pageNumPopular <= 3) {
                    ellipsisBeforePopular = false;
                    ellipsisAfterPopular = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumPopular)?true:false;
                        this.pageListPopular.add(new Pager(i, b));
                    }
                    this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                    this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                    this.indexPopular = this.pageNumPopular - 1;
                } else if(pageNumPopular >= 4 && pageNumPopular <= (this.totalPagePopular - 3)) {
                    system.debug('***pageNumPopular : >=4 && <=tp-3***');
                    ellipsisBeforePopular = true;
                    if(pageNumPopular == 5) {
                        ellipsisAfterPopular = false;
                    } else {
                        ellipsisAfterPopular = true;
                    }
                    
                    for(Integer i = (pageNumPopular - 1); i <= (pageNumPopular + 2); i++) {
                        Boolean b = (i == pageNumPopular)?true:false;
                        this.pageListPopular.add(new Pager(i, b));
                    }
                    this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                    this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                    this.indexPopular = this.pageNumPopular - 1;
                } else if(pageNumPopular > (this.totalPagePopular - 3) && pageNumPopular <= this.totalPagePopular) {
                    system.debug('***pageNumPopular : >tp-3 && <=tp***');
                    ellipsisBeforePopular = true;
                    ellipsisAfterPopular = false;
                    if((this.totalPagePopular - pageNumPopular) >= 4) {
                        system.debug('***(this.totalPagePopular - pageNumPopular) >= 4***');
                        for(Integer i = (this.totalPagePopular - pageNumPopular); i <= (this.totalPagePopular - 1); i++) {
                            Boolean b = (i == pageNumPopular)?true:false;
                            this.pageListPopular.add(new Pager(i, b));
                        }
                        this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                        this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                        this.indexPopular = this.pageNumPopular - 1;
                    } else {
                        system.debug('***(this.totalPagePopular - pageNumPopular) < 4***');
                        for(Integer i = (this.totalPagePopular - 4); i <= (this.totalPagePopular - 1); i++) {
                            Boolean b = (i == pageNumPopular)?true:false;
                            this.pageListPopular.add(new Pager(i, b));
                        }
                        this.showPreviousPopular = (this.pageNumPopular == 1)?false:true;
                        this.showNextPopular = (this.pageNumPopular == this.totalPagePopular)?false:true;
                        this.indexPopular = this.pageNumPopular - 1;
                    }
                }
            } //end of condition for totalPagePopular number
    }
         
    public void decrementPopular(){
        this.pageNumPopular = this.pageNumPopular - 1;
        updateNumbersPopular();
    }
     
    public void incrementPopular(){
        this.pageNumPopular++;
        updateNumbersPopular();
    }
 
    public class Pager{
        public Integer pageNumPopular {get;set;}
        public Boolean isActivePopular {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumPopular = num;
            this.isActivePopular = active;
        }
    }
}