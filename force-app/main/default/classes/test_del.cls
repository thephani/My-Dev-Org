public class test_del {
    public string tTest = null;
    public test_del(){
        
            tTest = 'in Controller';
            system.debug('Step 1: in controller');
    }
    public String getTTest() {
        system.debug('step 2: in methods');
        return tTest ;
    }


}