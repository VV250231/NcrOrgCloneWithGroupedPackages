public class appTest {
Public PageReference test()
{
        PageReference pageref=new PageReference('http://www.google.com/');
        //pageref.getParameters().put('HiddenName','Sunny');
        pageref.setRedirect(true);
        return pageref;
}
}