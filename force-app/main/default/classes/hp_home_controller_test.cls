@isTest(seeAllData=true)
public class hp_home_controller_test {
    static testmethod void onetest(){
        hp_home_controller c = new hp_home_controller();
        c.getDocList();
    }
}