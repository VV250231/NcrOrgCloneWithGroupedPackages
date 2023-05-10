/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateMyTeam {
    public Integer indexMyTeam {get;set;}
    public Integer pageNumMyTeam {get;set;}
    public Integer totalPageMyTeam {get;set;}
    public Integer totalResultsMyTeam {get;set;}
    public List<Pager> pageListMyTeam {get;set;}
    public Boolean showPreviousMyTeam {get;set;}
    public Boolean showNextMyTeam {get;set;}
    public Boolean isAllMyTeam {get;set;}
         
    public PaginateMyTeam(Integer listSize, Integer pageSize){
        this.totalResultsMyTeam = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageMyTeam = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumMyTeam = 1;
        this.indexMyTeam = 0;
        this.isAllMyTeam = (listSize == pageSize)?true:false;
        updateNumbersMyTeam();
    }
    
    public Boolean ellipsisBeforeMyTeam {get;set;}
    public Boolean ellipsisAfterMyTeam {get;set;}
    public Integer lastPageMyTeam {get;set;}
    public Integer currentNumMyTeam {get;set;}
    public void updateNumbersMyTeam(){
        this.pageListMyTeam = new List<Pager>();
            lastPageMyTeam = this.totalPageMyTeam;
            currentNumMyTeam = pageNumMyTeam;
            
            if(this.totalPageMyTeam <= 5) {
                system.debug('***totalPageMyTeam less than or equal to 5***');
                ellipsisBeforeMyTeam = false;
                ellipsisAfterMyTeam = false;
                for(Integer i = 2; i <= (this.totalPageMyTeam - 1); i++) {
                    Boolean b = (i == pageNumMyTeam)?true:false;
                    this.pageListMyTeam.add(new Pager(i, b));
                }
                this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                this.indexMyTeam = this.pageNumMyTeam - 1;
            } else if(this.totalPageMyTeam > 5 && this.totalPageMyTeam <= 6) {
                system.debug('***totalPageMyTeam > 5 && <= 6***');
                ellipsisBeforeMyTeam = false;
                ellipsisAfterMyTeam = false;
                for(Integer i = 2; i <= (this.totalPageMyTeam - 1); i++) {
                    Boolean b = (i == pageNumMyTeam)?true:false;
                    this.pageListMyTeam.add(new Pager(i, b));
                }
                this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                this.indexMyTeam = this.pageNumMyTeam - 1;
            } else if(this.totalPageMyTeam == 7) {
                system.debug('***totalPageMyTeam == 7***');
                if(pageNumMyTeam >= 1 && pageNumMyTeam <= 3) {
                    ellipsisBeforeMyTeam = false;
                    ellipsisAfterMyTeam = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumMyTeam)?true:false;
                        this.pageListMyTeam.add(new Pager(i, b));
                    }
                    this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                    this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                    this.indexMyTeam = this.pageNumMyTeam - 1;
                } else if(pageNumMyTeam >= 4 && pageNumMyTeam <= 7) {
                    ellipsisBeforeMyTeam = true;
                    ellipsisAfterMyTeam = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumMyTeam)?true:false;
                        this.pageListMyTeam.add(new Pager(i, b));
                    }
                    this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                    this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                    this.indexMyTeam = this.pageNumMyTeam - 1;
                }
            } else if(this.totalPageMyTeam >= 8) {
                system.debug('***totalPageMyTeam >= 8***');
                if(pageNumMyTeam >= 1 && pageNumMyTeam <= 3) {
                    ellipsisBeforeMyTeam = false;
                    ellipsisAfterMyTeam = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumMyTeam)?true:false;
                        this.pageListMyTeam.add(new Pager(i, b));
                    }
                    this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                    this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                    this.indexMyTeam = this.pageNumMyTeam - 1;
                } else if(pageNumMyTeam >= 4 && pageNumMyTeam <= (this.totalPageMyTeam - 3)) {
                    system.debug('***pageNumMyTeam : >=4 && <=tp-3***');
                    ellipsisBeforeMyTeam = true;
                    if(pageNumMyTeam == 5) {
                        ellipsisAfterMyTeam = false;
                    } else {
                        ellipsisAfterMyTeam = true;
                    }
                    
                    for(Integer i = (pageNumMyTeam - 1); i <= (pageNumMyTeam + 2); i++) {
                        Boolean b = (i == pageNumMyTeam)?true:false;
                        this.pageListMyTeam.add(new Pager(i, b));
                    }
                    this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                    this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                    this.indexMyTeam = this.pageNumMyTeam - 1;
                } else if(pageNumMyTeam > (this.totalPageMyTeam - 3) && pageNumMyTeam <= this.totalPageMyTeam) {
                    system.debug('***pageNumMyTeam : >tp-3 && <=tp***');
                    ellipsisBeforeMyTeam = true;
                    ellipsisAfterMyTeam = false;
                    if((this.totalPageMyTeam - pageNumMyTeam) >= 4) {
                        system.debug('***(this.totalPageMyTeam - pageNumMyTeam) >= 4***');
                        for(Integer i = (this.totalPageMyTeam - pageNumMyTeam); i <= (this.totalPageMyTeam - 1); i++) {
                            Boolean b = (i == pageNumMyTeam)?true:false;
                            this.pageListMyTeam.add(new Pager(i, b));
                        }
                        this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                        this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                        this.indexMyTeam = this.pageNumMyTeam - 1;
                    } else {
                        system.debug('***(this.totalPageMyTeam - pageNumMyTeam) < 4***');
                        for(Integer i = (this.totalPageMyTeam - 4); i <= (this.totalPageMyTeam - 1); i++) {
                            Boolean b = (i == pageNumMyTeam)?true:false;
                            this.pageListMyTeam.add(new Pager(i, b));
                        }
                        this.showPreviousMyTeam = (this.pageNumMyTeam == 1)?false:true;
                        this.showNextMyTeam = (this.pageNumMyTeam == this.totalPageMyTeam)?false:true;
                        this.indexMyTeam = this.pageNumMyTeam - 1;
                    }
                }
            } //end of condition for totalPageMyTeam number
    }
         
    public void decrementMyTeam(){
        this.pageNumMyTeam = this.pageNumMyTeam - 1;
        updateNumbersMyTeam();
    }
     
    public void incrementMyTeam(){
        this.pageNumMyTeam++;
        updateNumbersMyTeam();
    }
 
    public class Pager{
        public Integer pageNumMyTeam {get;set;}
        public Boolean isActiveMyTeam {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumMyTeam = num;
            this.isActiveMyTeam = active;
        }
    }
}