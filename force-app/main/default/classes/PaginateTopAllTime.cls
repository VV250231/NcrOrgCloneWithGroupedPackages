/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateTopAllTime {
    public Integer indexTopAllTime {get;set;}
    public Integer pageNumTopAllTime {get;set;}
    public Integer totalPageTopAllTime {get;set;}
    public Integer totalResultsTopAllTime {get;set;}
    public List<Pager> pageListTopAllTime {get;set;}
    public Boolean showPreviousTopAllTime {get;set;}
    public Boolean showNextTopAllTime {get;set;}
    public Boolean isAllTopAllTime {get;set;}
         
    public PaginateTopAllTime(Integer listSize, Integer pageSize){
        this.totalResultsTopAllTime = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageTopAllTime = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumTopAllTime = 1;
        this.indexTopAllTime = 0;
        this.isAllTopAllTime = (listSize == pageSize)?true:false;
        updateNumbersTopAllTime();
    }
    
    public Boolean ellipsisBeforeTopAllTime {get;set;}
    public Boolean ellipsisAfterTopAllTime {get;set;}
    public Integer lastPageTopAllTime {get;set;}
    public Integer currentNumTopAllTime {get;set;}
    public void updateNumbersTopAllTime(){
        this.pageListTopAllTime = new List<Pager>();
            lastPageTopAllTime = this.totalPageTopAllTime;
            currentNumTopAllTime = pageNumTopAllTime;
            
            if(this.totalPageTopAllTime <= 5) {
                system.debug('***totalPageTopAllTime less than or equal to 5***');
                ellipsisBeforeTopAllTime = false;
                ellipsisAfterTopAllTime = false;
                for(Integer i = 2; i <= (this.totalPageTopAllTime - 1); i++) {
                    Boolean b = (i == pageNumTopAllTime)?true:false;
                    this.pageListTopAllTime.add(new Pager(i, b));
                }
                this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                this.indexTopAllTime = this.pageNumTopAllTime - 1;
            } else if(this.totalPageTopAllTime > 5 && this.totalPageTopAllTime <= 6) {
                system.debug('***totalPageTopAllTime > 5 && <= 6***');
                ellipsisBeforeTopAllTime = false;
                ellipsisAfterTopAllTime = false;
                for(Integer i = 2; i <= (this.totalPageTopAllTime - 1); i++) {
                    Boolean b = (i == pageNumTopAllTime)?true:false;
                    this.pageListTopAllTime.add(new Pager(i, b));
                }
                this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                this.indexTopAllTime = this.pageNumTopAllTime - 1;
            } else if(this.totalPageTopAllTime == 7) {
                system.debug('***totalPageTopAllTime == 7***');
                if(pageNumTopAllTime >= 1 && pageNumTopAllTime <= 3) {
                    ellipsisBeforeTopAllTime = false;
                    ellipsisAfterTopAllTime = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumTopAllTime)?true:false;
                        this.pageListTopAllTime.add(new Pager(i, b));
                    }
                    this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                    this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                    this.indexTopAllTime = this.pageNumTopAllTime - 1;
                } else if(pageNumTopAllTime >= 4 && pageNumTopAllTime <= 7) {
                    ellipsisBeforeTopAllTime = true;
                    ellipsisAfterTopAllTime = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumTopAllTime)?true:false;
                        this.pageListTopAllTime.add(new Pager(i, b));
                    }
                    this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                    this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                    this.indexTopAllTime = this.pageNumTopAllTime - 1;
                }
            } else if(this.totalPageTopAllTime >= 8) {
                system.debug('***totalPageTopAllTime >= 8***');
                if(pageNumTopAllTime >= 1 && pageNumTopAllTime <= 3) {
                    ellipsisBeforeTopAllTime = false;
                    ellipsisAfterTopAllTime = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumTopAllTime)?true:false;
                        this.pageListTopAllTime.add(new Pager(i, b));
                    }
                    this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                    this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                    this.indexTopAllTime = this.pageNumTopAllTime - 1;
                } else if(pageNumTopAllTime >= 4 && pageNumTopAllTime <= (this.totalPageTopAllTime - 3)) {
                    system.debug('***pageNumTopAllTime : >=4 && <=tp-3***');
                    ellipsisBeforeTopAllTime = true;
                    if(pageNumTopAllTime == 5) {
                        ellipsisAfterTopAllTime = false;
                    } else {
                        ellipsisAfterTopAllTime = true;
                    }
                    
                    for(Integer i = (pageNumTopAllTime - 1); i <= (pageNumTopAllTime + 2); i++) {
                        Boolean b = (i == pageNumTopAllTime)?true:false;
                        this.pageListTopAllTime.add(new Pager(i, b));
                    }
                    this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                    this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                    this.indexTopAllTime = this.pageNumTopAllTime - 1;
                } else if(pageNumTopAllTime > (this.totalPageTopAllTime - 3) && pageNumTopAllTime <= this.totalPageTopAllTime) {
                    system.debug('***pageNumTopAllTime : >tp-3 && <=tp***');
                    ellipsisBeforeTopAllTime = true;
                    ellipsisAfterTopAllTime = false;
                    if((this.totalPageTopAllTime - pageNumTopAllTime) >= 4) {
                        system.debug('***(this.totalPageTopAllTime - pageNumTopAllTime) >= 4***');
                        for(Integer i = (this.totalPageTopAllTime - pageNumTopAllTime); i <= (this.totalPageTopAllTime - 1); i++) {
                            Boolean b = (i == pageNumTopAllTime)?true:false;
                            this.pageListTopAllTime.add(new Pager(i, b));
                        }
                        this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                        this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                        this.indexTopAllTime = this.pageNumTopAllTime - 1;
                    } else {
                        system.debug('***(this.totalPageTopAllTime - pageNumTopAllTime) < 4***');
                        for(Integer i = (this.totalPageTopAllTime - 4); i <= (this.totalPageTopAllTime - 1); i++) {
                            Boolean b = (i == pageNumTopAllTime)?true:false;
                            this.pageListTopAllTime.add(new Pager(i, b));
                        }
                        this.showPreviousTopAllTime = (this.pageNumTopAllTime == 1)?false:true;
                        this.showNextTopAllTime = (this.pageNumTopAllTime == this.totalPageTopAllTime)?false:true;
                        this.indexTopAllTime = this.pageNumTopAllTime - 1;
                    }
                }
            } //end of condition for totalPageTopAllTime number
    }
         
    public void decrementTopAllTime(){
        this.pageNumTopAllTime = this.pageNumTopAllTime - 1;
        updateNumbersTopAllTime();
    }
     
    public void incrementTopAllTime(){
        this.pageNumTopAllTime++;
        updateNumbersTopAllTime();
    }
 
    public class Pager{
        public Integer pageNumTopAllTime {get;set;}
        public Boolean isActiveTopAllTime {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumTopAllTime = num;
            this.isActiveTopAllTime = active;
        }
    }
}