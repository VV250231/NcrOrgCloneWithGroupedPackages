/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateComment {
    public Integer indexComment {get;set;}
    public Integer pageNumComment {get;set;}
    public Integer totalPageComment {get;set;}
    public Integer totalResultsComment {get;set;}
    public List<Pager> pageListComment {get;set;}
    public Boolean showPreviousComment {get;set;}
    public Boolean showNextComment {get;set;}
    public Boolean isAllComment {get;set;}
         
    public PaginateComment(Integer listSize, Integer pageSize){
        this.totalResultsComment = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageComment = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumComment = 1;
        this.indexComment = 0;
        this.isAllComment = (listSize == pageSize)?true:false;
        updateNumbersComment();
    }
    
    public Boolean ellipsisBeforeComment {get;set;}
    public Boolean ellipsisAfterComment {get;set;}
    public Integer lastPageComment {get;set;}
    public Integer currentNumComment {get;set;}
    public void updateNumbersComment(){
        this.pageListComment = new List<Pager>();
            lastPageComment = this.totalPageComment;
            currentNumComment = pageNumComment;
            
            if(this.totalPageComment <= 5) {
                system.debug('***totalPageComment less than or equal to 5***');
                ellipsisBeforeComment = false;
                ellipsisAfterComment = false;
                for(Integer i = 2; i <= (this.totalPageComment - 1); i++) {
                    Boolean b = (i == pageNumComment)?true:false;
                    this.pageListComment.add(new Pager(i, b));
                }
                this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                this.indexComment = this.pageNumComment - 1;
            } else if(this.totalPageComment > 5 && this.totalPageComment <= 6) {
                system.debug('***totalPageComment > 5 && <= 6***');
                ellipsisBeforeComment = false;
                ellipsisAfterComment = false;
                for(Integer i = 2; i <= (this.totalPageComment - 1); i++) {
                    Boolean b = (i == pageNumComment)?true:false;
                    this.pageListComment.add(new Pager(i, b));
                }
                this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                this.indexComment = this.pageNumComment - 1;
            } else if(this.totalPageComment == 7) {
                system.debug('***totalPageComment == 7***');
                if(pageNumComment >= 1 && pageNumComment <= 3) {
                    ellipsisBeforeComment = false;
                    ellipsisAfterComment = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumComment)?true:false;
                        this.pageListComment.add(new Pager(i, b));
                    }
                    this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                    this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                    this.indexComment = this.pageNumComment - 1;
                } else if(pageNumComment >= 4 && pageNumComment <= 7) {
                    ellipsisBeforeComment = true;
                    ellipsisAfterComment = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumComment)?true:false;
                        this.pageListComment.add(new Pager(i, b));
                    }
                    this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                    this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                    this.indexComment = this.pageNumComment - 1;
                }
            } else if(this.totalPageComment >= 8) {
                system.debug('***totalPageComment >= 8***');
                if(pageNumComment >= 1 && pageNumComment <= 3) {
                    ellipsisBeforeComment = false;
                    ellipsisAfterComment = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumComment)?true:false;
                        this.pageListComment.add(new Pager(i, b));
                    }
                    this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                    this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                    this.indexComment = this.pageNumComment - 1;
                } else if(pageNumComment >= 4 && pageNumComment <= (this.totalPageComment - 3)) {
                    system.debug('***pageNumComment : >=4 && <=tp-3***');
                    ellipsisBeforeComment = true;
                    if(pageNumComment == 5) {
                        ellipsisAfterComment = false;
                    } else {
                        ellipsisAfterComment = true;
                    }
                    
                    for(Integer i = (pageNumComment - 1); i <= (pageNumComment + 2); i++) {
                        Boolean b = (i == pageNumComment)?true:false;
                        this.pageListComment.add(new Pager(i, b));
                    }
                    this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                    this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                    this.indexComment = this.pageNumComment - 1;
                } else if(pageNumComment > (this.totalPageComment - 3) && pageNumComment <= this.totalPageComment) {
                    system.debug('***pageNumComment : >tp-3 && <=tp***');
                    ellipsisBeforeComment = true;
                    ellipsisAfterComment = false;
                    if((this.totalPageComment - pageNumComment) >= 4) {
                        system.debug('***(this.totalPageComment - pageNumComment) >= 4***');
                        for(Integer i = (this.totalPageComment - pageNumComment); i <= (this.totalPageComment - 1); i++) {
                            Boolean b = (i == pageNumComment)?true:false;
                            this.pageListComment.add(new Pager(i, b));
                        }
                        this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                        this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                        this.indexComment = this.pageNumComment - 1;
                    } else {
                        system.debug('***(this.totalPageComment - pageNumComment) < 4***');
                        for(Integer i = (this.totalPageComment - 4); i <= (this.totalPageComment - 1); i++) {
                            Boolean b = (i == pageNumComment)?true:false;
                            this.pageListComment.add(new Pager(i, b));
                        }
                        this.showPreviousComment = (this.pageNumComment == 1)?false:true;
                        this.showNextComment = (this.pageNumComment == this.totalPageComment)?false:true;
                        this.indexComment = this.pageNumComment - 1;
                    }
                }
            } //end of condition for totalPageComment number
    }
         
    public void decrementComment(){
        this.pageNumComment = this.pageNumComment - 1;
        updateNumbersComment();
    }
     
    public void incrementComment(){
        this.pageNumComment++;
        updateNumbersComment();
    }
 
    public class Pager{
        public Integer pageNumComment {get;set;}
        public Boolean isActiveComment {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumComment = num;
            this.isActiveComment = active;
        }
    }
}