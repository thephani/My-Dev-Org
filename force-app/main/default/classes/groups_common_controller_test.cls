@isTest(SeeAllData=true)
private class groups_common_controller_test {
    
    static testMethod void unitTest(){
        groups_common_controller c = new groups_common_controller();              
        c.getGroups();
    }
    
}