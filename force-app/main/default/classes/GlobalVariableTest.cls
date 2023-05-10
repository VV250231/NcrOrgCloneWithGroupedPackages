@isTest
public class GlobalVariableTest {
      static testMethod void testGlobalVariable() {
        String spricebookId = GlobalVariable.pricebookId;
        System.assert(spricebookId != null);
        String sno = GlobalVariable.no;
        System.assert(sno != null);
        String syes = GlobalVariable.yes;
        System.assert(syes != null);
        String scatHW = GlobalVariable.catHW;
        System.assert(scatHW != null);
        String scatSW = GlobalVariable.catSW;
        System.assert(scatSW != null);
        String scatPS = GlobalVariable.catPS;
        System.assert(scatPS != null);
        String scatCS = GlobalVariable.catCS;
        System.assert(scatCS != null);
        String scatTS = GlobalVariable.catTS;
        System.assert(scatTS != null);

        Integer inoOfYears = GlobalVariable.noOfYears;
        System.assert(inoOfYears >0);
        Integer imaxDisplay = GlobalVariable.maxDisplay;
        System.assert(imaxDisplay >0);

        Date dunhandledQtyDate = GlobalVariable.unhandledQtyDate;
        System.assert(dunhandledQtyDate != null);
        
        
    }

}