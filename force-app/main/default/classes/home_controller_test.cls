@isTest(seealldata=true)
public class home_controller_test {
    static testMethod void uTest(){
        home_controller hc = new home_controller();
        hc.getApps();
        
        Id appId = [SELECT Id FROM AppMenuItem LIMIT 1].Id;
        home_controller.getUrlString(appId);
        
    }
}