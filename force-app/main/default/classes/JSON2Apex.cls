public class JSON2Apex {

	public UserObj userObj {get;set;} 
	public SelItem selItem {get;set;} 
	public String RoleName {get;set;} 

	public JSON2Apex(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'userObj') {
						userObj = new UserObj(parser);
					} else if (text == 'selItem') {
						selItem = new SelItem(parser);
					} else if (text == 'RoleName') {
						RoleName = parser.getText();
					} else {
						System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	public class Attributes {
		public String type_Z {get;set;} // in json: type
		public String url {get;set;} 

		public Attributes(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'type') {
							type_Z = parser.getText();
						} else if (text == 'url') {
							url = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Attributes consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class SelItem {
		public Object val {get;set;} 
		public String text {get;set;} 
		public UserObj ObjRecord {get;set;} 
		public String objName {get;set;} 

		public SelItem(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'val') {
							val = parser.readValueAs(Object.class);
						} else if (text == 'text') {
							text = parser.getText();
						} else if (text == 'ObjRecord') {
							ObjRecord = new UserObj(parser);
						} else if (text == 'objName') {
							objName = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'SelItem consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public class UserObj {
		public Attributes attributes {get;set;} 
		public String Name {get;set;} 
		public String Id {get;set;} 
		public String Quicklook_ID {get;set;} 
		public String Email {get;set;}
        public String Phone {get;set;}

		public UserObj(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'attributes') {
							attributes = new Attributes(parser);
						} else if (text == 'Name') {
							Name = parser.getText();
						} else if (text == 'Id') {
							Id = parser.getText();
						} else if (text == 'Quicklook_ID__c') {
							Quicklook_ID = parser.getText();
						} else if (text == 'Email') {
							Email = parser.getText();
                        }else if (text == 'Phone') {
							Phone = parser.getText();
						}else {
							System.debug(LoggingLevel.WARN, 'UserObj consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	
	public static List<JSON2Apex> parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return arrayOfJSON2Apex(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    private static List<JSON2Apex> arrayOfJSON2Apex(System.JSONParser p) {
        List<JSON2Apex> res = new List<JSON2Apex>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new JSON2Apex(p));
        }
        return res;
    }


}