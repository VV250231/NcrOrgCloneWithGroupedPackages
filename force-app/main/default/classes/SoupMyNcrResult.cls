public class SoupMyNcrResult {
    
public cls_responseHeader responseHeader;
	public myNCRUserProfileResp myNCRUserProfileResp;
	public class cls_responseHeader {
		public String status;	//SUCCESS
		public Integer statusCode;	//0
		public String statusMessage;	//User attributes returned.
		public String timestamp;	//2021-06-03T11:15:59.635+00:00
		public String transactionId;	//22222222222222
	}
	public class myNCRUserProfileResp {
		public address address;
		public String federatedUser;	//NO
		public String lastname;	//Corp again
		public String myNCRUser;	//YES
		public String userStatus;	//ENABLED
		public String lastLoginTime;	//
		public String officePhone;	//
		public String admin;	//YES
		public String userCreationDateTime;	//19 Jun 2020 05:02:12 GMT
		public String username;	//gopal38MARS
		public String login;	//gopal38MARS
		public String firstName;	//NCR
		//public String lastName1;	//Corp again
		public String email;	//GK185062@corp.ncr.com
		public memberOf[] memberOf;
		public String jobTitle;	//Information Technology
	}
	public class address {
		public String address1;	//
		public String address2;	//
		public String address3;	//
		public String city;	//
		public String postalCode;	//
		public String county;	//
		public String state;	//
		public String country;	//IN
	}
	public class memberOf {
		public String accountNumber;	//7435671
		public String accountName;	//FOREMOST BUSINESS
	}
	public static SoupMyNcrResult parseResponse(String json){
		return (SoupMyNcrResult) System.JSON.deserialize(json, SoupMyNcrResult.class);
	}    
}