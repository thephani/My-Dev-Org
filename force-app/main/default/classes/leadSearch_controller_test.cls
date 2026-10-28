@isTest
private class leadSearch_controller_test {
    
    static testMethod void unitTest(){
        leadSearch_controller ls = new leadSearch_controller();
        ls.Lead.LastName = 'test';
        ls.Lead.Company = 'test';        
        ls.getLeadList();
        ls.dummyAction();
        ls.insertLead();
    }

}