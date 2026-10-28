@isTest(SeeAllData=true)
private class NewPurchase_Ext_Test {
    private static testMethod void unitTest() {

        PageReference pageRef = Page.NewPurchase;
        Test.setCurrentPage(pageRef);

        Account acc = new Account();
        acc.Name = 'Test';
        insert acc;

        ApexPages.StandardController sc = New ApexPages.StandardController(acc);
        NewPurchase_Ext ext = new NewPurchase_Ext(sc);
        ext.saveRecord();
    }

}