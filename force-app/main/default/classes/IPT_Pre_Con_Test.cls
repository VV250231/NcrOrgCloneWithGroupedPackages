@isTest
public class IPT_Pre_Con_Test {
	@isTest
    public static void testPreCon(){
       IPT_Pre_Con.UserDetail userObj =  IPT_Pre_Con.getUserDetail();
       System.assert(userObj.Email!=null);
    }
}