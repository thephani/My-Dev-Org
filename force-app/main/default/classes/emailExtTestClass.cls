@isTest(SeeAllData=true)
private class emailExtTestClass{
    static Case thisCase{get;set;}
    
    static testMethod void testSearch(){
        thisCase = new Case();
        PageReference pageRef = Page.emailPage; 
        Test.setCurrentPage(pageRef);  
        thisCase = [SELECT Id, Subject FROM Case LIMIT 1]; 
        ApexPages.currentPage().getParameters().put('id', thisCase.Id);
        ApexPages.StandardController ctrl = new ApexPages.StandardController(thisCase); // set standard controller
        emailExt controller = new emailExt(ctrl); // create new instance of controller to be tested
        controller.search(); 
        controller.reset(); 
        controller.sMails(); 
        controller.rMails();     
    }
}