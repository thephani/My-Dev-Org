@isTest
public class floorWalkExt_test {
    
    // Test method for both trigger & Apex Class
    
    static testMethod void testMethods() {
        
        Account a = new Account();
        a.Name = 'Test';
        insert a;
        
        Floor_Walk__c f = new Floor_Walk__c();     
        f.Account_Floor_Walk__c = a.Id;
        insert f;
        
        PageReference pageRef = Page.floorWalk; 
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', f.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(f);
        floorWalkExt fe = new floorWalkExt(sc);
        fe.saveMainRecord();
        fe.saveRecords();
        fe.deleteRecord();
        fe.cancel();
    }
    
}