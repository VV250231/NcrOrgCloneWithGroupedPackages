public class SortingUtils {
    /** A wrapper class to make employee sortable */
    public class SortingWrapper implements Comparable {

        /** Account*/
        public Account objAcc ;

        public integer QuoteCount;
        
        public SortingWrapper(Account acc) {
            this.objAcc = acc;
            system.debug('>>>>' + acc.All_QuBy_Quotes_Acc__r.size());
           
            this.QuoteCount = acc.All_QuBy_Quotes_Acc__r.size();
        }

        
        public Integer compareTo(Object obj) {
            SortingWrapper accsort = (SortingWrapper)(obj);

            if (this.QuoteCount > accsort.QuoteCount) {
                return -1;
            }

            if (this.QuoteCount == accsort.QuoteCount) {
                return 0;
            }

            return 1;
        }
    }
    
    
}