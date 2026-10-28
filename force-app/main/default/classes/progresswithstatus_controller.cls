public class progresswithstatus_controller {
    
    public Integer count {get; set;}
    
    public progresswithstatus_controller(){
        count = 0;
    }
    
    public PageReference incrementCounter() {
        count++;
        return null;
    }
    
    public Integer getCount() {
        return count;
    }
    
    public void myActionInController(){
        count++;        
    }
}