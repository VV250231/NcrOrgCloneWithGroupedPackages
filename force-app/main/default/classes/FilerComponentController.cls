public class FilerComponentController {
	@AuraEnabled 
    Public Static List<Product2> getFilterResult(String FilterString){
        return [Select Id,name from product2];
    }
}