@isTest
private class EnhancedListViewController_Test {          
    private testMethod static void unitTest() {
        
        // Success Case
        EnhancedListViewController con = new EnhancedListViewController();
        con.objectName = 'Contact';  
        con.listName = 'All Contacts';
        con.getListId();
        
        // Failure Case        
        con.listName = 'bad Name';
        con.getListId();
    }    
}