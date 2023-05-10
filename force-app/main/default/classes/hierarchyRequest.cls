global class hierarchyRequest{
		global class valueSetType{
		webservice String name{get;set;}
		webservice String code{get;set;}
		}
		webservice valueSetType Division {get; set;}
		webservice valueSetType offer_Portfolio {get; set;}
		webservice valueSetType	offer_Group{get; set;}
		webservice valueSetType	advocated_Solution{get; set;}	
		public  String getName(valueSetType v)	{
			return v.name;
		}
		public  String getCode(valueSetType v)	{
			return v.code;
		}
	}