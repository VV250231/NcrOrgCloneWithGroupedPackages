/**This Paginate Class is the class that keeps track of all the pagination information */
public class PaginateFavorites {
    public Integer indexFavorites {get;set;}
    public Integer pageNumFavorites {get;set;}
    public Integer totalPageFavorites {get;set;}
    public Integer totalResultsFavorites {get;set;}
    public List<Pager> pageListFavorites {get;set;}
    public Boolean showPreviousFavorites {get;set;}
    public Boolean showNextFavorites {get;set;}
    public Boolean isAllFavorites {get;set;}
         
    public PaginateFavorites(Integer listSize, Integer pageSize){
        this.totalResultsFavorites = listSize;
        pageSize = (pageSize > 0)?pageSize:10;
        this.totalPageFavorites = (Integer)Math.ceil((Double)listSize / (Double)pageSize);
        this.pageNumFavorites = 1;
        this.indexFavorites = 0;
        this.isAllFavorites = (listSize == pageSize)?true:false;
        updateNumbersFavorites();
    }
    
    public Boolean ellipsisBeforeFavorites {get;set;}
    public Boolean ellipsisAfterFavorites {get;set;}
    public Integer lastPageFavorites {get;set;}
    public Integer currentNumFavorites {get;set;}
    public void updateNumbersFavorites(){
        this.pageListFavorites = new List<Pager>();
            lastPageFavorites = this.totalPageFavorites;
            currentNumFavorites = pageNumFavorites;
            
            if(this.totalPageFavorites <= 5) {
                system.debug('***totalPageFavorites less than or equal to 5***');
                ellipsisBeforeFavorites = false;
                ellipsisAfterFavorites = false;
                for(Integer i = 2; i <= (this.totalPageFavorites - 1); i++) {
                    Boolean b = (i == pageNumFavorites)?true:false;
                    this.pageListFavorites.add(new Pager(i, b));
                }
                this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                this.indexFavorites = this.pageNumFavorites - 1;
            } else if(this.totalPageFavorites > 5 && this.totalPageFavorites <= 6) {
                system.debug('***totalPageFavorites > 5 && <= 6***');
                ellipsisBeforeFavorites = false;
                ellipsisAfterFavorites = false;
                for(Integer i = 2; i <= (this.totalPageFavorites - 1); i++) {
                    Boolean b = (i == pageNumFavorites)?true:false;
                    this.pageListFavorites.add(new Pager(i, b));
                }
                this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                this.indexFavorites = this.pageNumFavorites - 1;
            } else if(this.totalPageFavorites == 7) {
                system.debug('***totalPageFavorites == 7***');
                if(pageNumFavorites >= 1 && pageNumFavorites <= 3) {
                    ellipsisBeforeFavorites = false;
                    ellipsisAfterFavorites = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumFavorites)?true:false;
                        this.pageListFavorites.add(new Pager(i, b));
                    }
                    this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                    this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                    this.indexFavorites = this.pageNumFavorites - 1;
                } else if(pageNumFavorites >= 4 && pageNumFavorites <= 7) {
                    ellipsisBeforeFavorites = true;
                    ellipsisAfterFavorites = false;
                    for(Integer i = 3; i <= 6; i++) {
                        Boolean b = (i == pageNumFavorites)?true:false;
                        this.pageListFavorites.add(new Pager(i, b));
                    }
                    this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                    this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                    this.indexFavorites = this.pageNumFavorites - 1;
                }
            } else if(this.totalPageFavorites >= 8) {
                system.debug('***totalPageFavorites >= 8***');
                if(pageNumFavorites >= 1 && pageNumFavorites <= 3) {
                    ellipsisBeforeFavorites = false;
                    ellipsisAfterFavorites = true;
                    for(Integer i = 2; i <= 5; i++) {
                        Boolean b = (i == pageNumFavorites)?true:false;
                        this.pageListFavorites.add(new Pager(i, b));
                    }
                    this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                    this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                    this.indexFavorites = this.pageNumFavorites - 1;
                } else if(pageNumFavorites >= 4 && pageNumFavorites <= (this.totalPageFavorites - 3)) {
                    system.debug('***pageNumFavorites : >=4 && <=tp-3***');
                    ellipsisBeforeFavorites = true;
                    if(pageNumFavorites == 5) {
                        ellipsisAfterFavorites = false;
                    } else {
                        ellipsisAfterFavorites = true;
                    }
                    
                    for(Integer i = (pageNumFavorites - 1); i <= (pageNumFavorites + 2); i++) {
                        Boolean b = (i == pageNumFavorites)?true:false;
                        this.pageListFavorites.add(new Pager(i, b));
                    }
                    this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                    this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                    this.indexFavorites = this.pageNumFavorites - 1;
                } else if(pageNumFavorites > (this.totalPageFavorites - 3) && pageNumFavorites <= this.totalPageFavorites) {
                    system.debug('***pageNumFavorites : >tp-3 && <=tp***');
                    ellipsisBeforeFavorites = true;
                    ellipsisAfterFavorites = false;
                    if((this.totalPageFavorites - pageNumFavorites) >= 4) {
                        system.debug('***(this.totalPageFavorites - pageNumFavorites) >= 4***');
                        for(Integer i = (this.totalPageFavorites - pageNumFavorites); i <= (this.totalPageFavorites - 1); i++) {
                            Boolean b = (i == pageNumFavorites)?true:false;
                            this.pageListFavorites.add(new Pager(i, b));
                        }
                        this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                        this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                        this.indexFavorites = this.pageNumFavorites - 1;
                    } else {
                        system.debug('***(this.totalPageFavorites - pageNumFavorites) < 4***');
                        for(Integer i = (this.totalPageFavorites - 4); i <= (this.totalPageFavorites - 1); i++) {
                            Boolean b = (i == pageNumFavorites)?true:false;
                            this.pageListFavorites.add(new Pager(i, b));
                        }
                        this.showPreviousFavorites = (this.pageNumFavorites == 1)?false:true;
                        this.showNextFavorites = (this.pageNumFavorites == this.totalPageFavorites)?false:true;
                        this.indexFavorites = this.pageNumFavorites - 1;
                    }
                }
            } //end of condition for totalPageFavorites number
    }
         
    public void decrementFavorites(){
        this.pageNumFavorites = this.pageNumFavorites - 1;
        updateNumbersFavorites();
    }
     
    public void incrementFavorites(){
        this.pageNumFavorites++;
        updateNumbersFavorites();
    }
 
    public class Pager{
        public Integer pageNumFavorites {get;set;}
        public Boolean isActiveFavorites {get;set;}
         
        public Pager(Integer num, Boolean active){
            this.pageNumFavorites = num;
            this.isActiveFavorites = active;
        }
    }
}