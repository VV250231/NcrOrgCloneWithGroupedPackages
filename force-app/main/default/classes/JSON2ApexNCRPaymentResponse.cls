public class JSON2ApexNCRPaymentResponse {
	public String merchantClaimURL;
	public String administratorURL;
	public String merchantApplicationId;
	public String externalMerchantApplicationId;
	public String infiniceptApplicationId;
	public Integer status;
	public String statusMessage;
	public String organizationId;
	public String siteId;
	public String externalMerchantId;
	public String externalStoreId;
	public static List<JSON2ApexNCRPaymentResponse> parse(String json) {
		return (List<JSON2ApexNCRPaymentResponse>) System.JSON.deserialize(json, List<JSON2ApexNCRPaymentResponse>.class);
	}
}