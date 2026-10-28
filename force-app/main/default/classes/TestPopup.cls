public with sharing class TestPopup {

    public Boolean displayPopup {get;set;}

    public TestPopup(ApexPages.StandardController controller){

    }
    
    public void showPopup()
    {
        
    displayPopup = true;

    
    }
    
    public void closePopup() {
        displayPopup = false;
        
    }
    


}