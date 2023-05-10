/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateMyIdeas {
    public Integer indexMyIdeas {get;set;}
    public Integer pageNumMyIdeas {get;set;}
    public Integer totalPageMyIdeas {get;set;}
    public Integer totalResultsMyIdeas {get;set;}
    public List<Pager> pageListMyIdeas {get;set;}
    public Boolean showPreviousMyIdeas {get;set;}
    public Boolean showNextMyIdeas {get;set;}
    public Boolean isAllMyIdeas {get;set;}
         
    public PaginateMyIdeas(Integer listSize, Integer pageSize){
        this.totalResultsMyIdeas = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageMyIdeas = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumMyIdeas = 1;
        this.indexMyIdeas = 0;
        this.isAllMyIdeas = (listSize == pageSize)?true:false;
        updateNumbersMyIdeas();
    }
    
    public Boolean ellipsisBeforeMyIdeas {get;set;}
    public Boolean ellipsisAfterMyIdeas {get;set;}
    public Integer lastPageMyIdeas {get;set;}
    public Integer currentNumMyIdeas {get;set;}
    public void updateNumbersMyIdeas(){
        this.pageListMyIdeas = new List<Pager>();
            lastPageMyIdeas = this.totalPageMyIdeas;
            currentNumMyIdeas = pageNumMyIdeas;
            
            if(this.totalPageMyIdeas <= 5) {
                system.debug('***totalPageMyIdeas less than or equal to 5***');
                ellipsisBeforeMyIdeas = false;
                ellipsisAfterMyIdeas = false;
                for(Integer i = 2; i <= (this.totalPageMyIdeas - 1); i++) {
                    Boolean b = (i == pageNumMyIdeas)?true:false;
                    this.pageListMyIdeas.add(new Pager(i, b));
                }
                this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                this.indexMyIdeas = this.pageNumMyIdeas - 1;
            } else if(this.totalPageMyIdeas > 5 && this.totalPageMyIdeas <= 6) {
                system.debug('***totalPageMyIdeas > 5 && <= 6***');
                ellipsisBeforeMyIdeas = false;
                ellipsisAfterMyIdeas = false;
                for(Integer i = 2; i <= (this.totalPageMyIdeas - 1); i++) {
                    Boolean b = (i == pageNumMyIdeas)?true:false;
                    this.pageListMyIdeas.add(new Pager(i, b));
                }
                this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                this.indexMyIdeas = this.pageNumMyIdeas - 1;
            } else if(this.totalPageMyIdeas == 7) {
                system.debug('***totalPageMyIdeas == 7***');
                if(pageNumMyIdeas >= 1 && pageNumMyIdeas <= 3) {
                    ellipsisBeforeMyIdeas = false;
                    ellipsisAfterMyIdeas = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumMyIdeas)?true:false;
                        this.pageListMyIdeas.add(new Pager(i, b));
                    }
                    this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                    this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                    this.indexMyIdeas = this.pageNumMyIdeas - 1;
                } else if(pageNumMyIdeas >= 4 && pageNumMyIdeas <= 7) {
                    ellipsisBeforeMyIdeas = true;
                    ellipsisAfterMyIdeas = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumMyIdeas)?true:false;
                        this.pageListMyIdeas.add(new Pager(i, b));
                    }
                    this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                    this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                    this.indexMyIdeas = this.pageNumMyIdeas - 1;
                }
            } else if(this.totalPageMyIdeas >= 8) {
                system.debug('***totalPageMyIdeas >= 8***');
                if(pageNumMyIdeas >= 1 && pageNumMyIdeas <= 3) {
                    ellipsisBeforeMyIdeas = false;
                    ellipsisAfterMyIdeas = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumMyIdeas)?true:false;
                        this.pageListMyIdeas.add(new Pager(i, b));
                    }
                    this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                    this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                    this.indexMyIdeas = this.pageNumMyIdeas - 1;
                } else if(pageNumMyIdeas >= 4 && pageNumMyIdeas <= (this.totalPageMyIdeas - 3)) {
                    system.debug('***pageNumMyIdeas : >=4 && <=tp-3***');
                    ellipsisBeforeMyIdeas = true;
                    if(pageNumMyIdeas == 5) {
                        ellipsisAfterMyIdeas = false;
                    } else {
                        ellipsisAfterMyIdeas = true;
                    }
                    
                    for(Integer i = (pageNumMyIdeas - 1); i <= (pageNumMyIdeas + 2); i++) {
                        Boolean b = (i == pageNumMyIdeas)?true:false;
                        this.pageListMyIdeas.add(new Pager(i, b));
                    }
                    this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                    this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                    this.indexMyIdeas = this.pageNumMyIdeas - 1;
                } else if(pageNumMyIdeas > (this.totalPageMyIdeas - 3) && pageNumMyIdeas <= this.totalPageMyIdeas) {
                    system.debug('***pageNumMyIdeas : >tp-3 && <=tp***');
                    ellipsisBeforeMyIdeas = true;
                    ellipsisAfterMyIdeas = false;
                    if((this.totalPageMyIdeas - pageNumMyIdeas) >= 4) {
                        system.debug('***(this.totalPageMyIdeas - pageNumMyIdeas) >= 4***');
                        for(Integer i = (this.totalPageMyIdeas - pageNumMyIdeas); i <= (this.totalPageMyIdeas - 1); i++) {
                            Boolean b = (i == pageNumMyIdeas)?true:false;
                            this.pageListMyIdeas.add(new Pager(i, b));
                        }
                        this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                        this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                        this.indexMyIdeas = this.pageNumMyIdeas - 1;
                    } else {
                        system.debug('***(this.totalPageMyIdeas - pageNumMyIdeas) < 4***');
                        for(Integer i = (this.totalPageMyIdeas - 4); i <= (this.totalPageMyIdeas - 1); i++) {
                            Boolean b = (i == pageNumMyIdeas)?true:false;
                            this.pageListMyIdeas.add(new Pager(i, b));
                        }
                        this.showPreviousMyIdeas = (this.pageNumMyIdeas == 1)?false:true;
                        this.showNextMyIdeas = (this.pageNumMyIdeas == this.totalPageMyIdeas)?false:true;
                        this.indexMyIdeas = this.pageNumMyIdeas - 1;
                    }
                }
            } //end of condition for totalPageMyIdeas number
    }
         
    public void decrementMyIdeas(){
        this.pageNumMyIdeas = this.pageNumMyIdeas - 1;
        updateNumbersMyIdeas();
    }
     
    public void incrementMyIdeas(){
        this.pageNumMyIdeas++;
        updateNumbersMyIdeas();
    }
 
    public class Pager{
        public Integer pageNumMyIdeas {get;set;}
        public Boolean isActiveMyIdeas {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumMyIdeas = num;
            this.isActiveMyIdeas = active;
        }
    }
}