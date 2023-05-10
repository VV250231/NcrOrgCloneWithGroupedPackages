/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateReplies {
    public Integer indexReplies {get;set;}
    public Integer pageNumReplies {get;set;}
    public Integer totalPageReplies {get;set;}
    public Integer totalResultsReplies {get;set;}
    public List<Pager> pageListReplies {get;set;}
    public Boolean showPreviousReplies {get;set;}
    public Boolean showNextReplies {get;set;}
    public Boolean isAllReplies {get;set;}
         
    public PaginateReplies(Integer listSize, Integer pageSize){
        this.totalResultsReplies = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageReplies = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumReplies = 1;
        this.indexReplies = 0;
        this.isAllReplies = (listSize == pageSize)?true:false;
        updateNumbersReplies();
    }
    
    public Boolean ellipsisBeforeReplies {get;set;}
    public Boolean ellipsisAfterReplies {get;set;}
    public Integer lastPageReplies {get;set;}
    public Integer currentNumReplies {get;set;}
    public void updateNumbersReplies(){
        this.pageListReplies = new List<Pager>();
            lastPageReplies = this.totalPageReplies;
            currentNumReplies = pageNumReplies;
            
            if(this.totalPageReplies <= 5) {
                system.debug('***totalPageReplies less than or equal to 5***');
                ellipsisBeforeReplies = false;
                ellipsisAfterReplies = false;
                for(Integer i = 2; i <= (this.totalPageReplies - 1); i++) {
                    Boolean b = (i == pageNumReplies)?true:false;
                    this.pageListReplies.add(new Pager(i, b));
                }
                this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                this.indexReplies = this.pageNumReplies - 1;
            } else if(this.totalPageReplies > 5 && this.totalPageReplies <= 6) {
                system.debug('***totalPageReplies > 5 && <= 6***');
                ellipsisBeforeReplies = false;
                ellipsisAfterReplies = false;
                for(Integer i = 2; i <= (this.totalPageReplies - 1); i++) {
                    Boolean b = (i == pageNumReplies)?true:false;
                    this.pageListReplies.add(new Pager(i, b));
                }
                this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                this.indexReplies = this.pageNumReplies - 1;
            } else if(this.totalPageReplies == 7) {
                system.debug('***totalPageReplies == 7***');
                if(pageNumReplies >= 1 && pageNumReplies <= 3) {
                    ellipsisBeforeReplies = false;
                    ellipsisAfterReplies = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumReplies)?true:false;
                        this.pageListReplies.add(new Pager(i, b));
                    }
                    this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                    this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                    this.indexReplies = this.pageNumReplies - 1;
                } else if(pageNumReplies >= 4 && pageNumReplies <= 7) {
                    ellipsisBeforeReplies = true;
                    ellipsisAfterReplies = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumReplies)?true:false;
                        this.pageListReplies.add(new Pager(i, b));
                    }
                    this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                    this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                    this.indexReplies = this.pageNumReplies - 1;
                }
            } else if(this.totalPageReplies >= 8) {
                system.debug('***totalPageReplies >= 8***');
                if(pageNumReplies >= 1 && pageNumReplies <= 3) {
                    ellipsisBeforeReplies = false;
                    ellipsisAfterReplies = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumReplies)?true:false;
                        this.pageListReplies.add(new Pager(i, b));
                    }
                    this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                    this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                    this.indexReplies = this.pageNumReplies - 1;
                } else if(pageNumReplies >= 4 && pageNumReplies <= (this.totalPageReplies - 3)) {
                    system.debug('***pageNumReplies : >=4 && <=tp-3***');
                    ellipsisBeforeReplies = true;
                    if(pageNumReplies == 5) {
                        ellipsisAfterReplies = false;
                    } else {
                        ellipsisAfterReplies = true;
                    }
                    
                    for(Integer i = (pageNumReplies - 1); i <= (pageNumReplies + 2); i++) {
                        Boolean b = (i == pageNumReplies)?true:false;
                        this.pageListReplies.add(new Pager(i, b));
                    }
                    this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                    this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                    this.indexReplies = this.pageNumReplies - 1;
                } else if(pageNumReplies > (this.totalPageReplies - 3) && pageNumReplies <= this.totalPageReplies) {
                    system.debug('***pageNumReplies : >tp-3 && <=tp***');
                    ellipsisBeforeReplies = true;
                    ellipsisAfterReplies = false;
                    if((this.totalPageReplies - pageNumReplies) >= 4) {
                        system.debug('***(this.totalPageReplies - pageNumReplies) >= 4***');
                        for(Integer i = (this.totalPageReplies - pageNumReplies); i <= (this.totalPageReplies - 1); i++) {
                            Boolean b = (i == pageNumReplies)?true:false;
                            this.pageListReplies.add(new Pager(i, b));
                        }
                        this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                        this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                        this.indexReplies = this.pageNumReplies - 1;
                    } else {
                        system.debug('***(this.totalPageReplies - pageNumReplies) < 4***');
                        for(Integer i = (this.totalPageReplies - 4); i <= (this.totalPageReplies - 1); i++) {
                            Boolean b = (i == pageNumReplies)?true:false;
                            this.pageListReplies.add(new Pager(i, b));
                        }
                        this.showPreviousReplies = (this.pageNumReplies == 1)?false:true;
                        this.showNextReplies = (this.pageNumReplies == this.totalPageReplies)?false:true;
                        this.indexReplies = this.pageNumReplies - 1;
                    }
                }
            } //end of condition for totalPageReplies number
    }
         
    public void decrementReplies(){
        this.pageNumReplies = this.pageNumReplies - 1;
        updateNumbersReplies();
    }
     
    public void incrementReplies(){
        this.pageNumReplies++;
        updateNumbersReplies();
    }
 
    public class Pager{
        public Integer pageNumReplies {get;set;}
        public Boolean isActiveReplies {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumReplies = num;
            this.isActiveReplies = active;
        }
    }
}