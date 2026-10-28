public class replaceAllImplementation{

    public void replacer(){        
        String s = '<Apex>null</apex><Apex> null</apex><Apex>null </apex><phani>null</fklsj>';
        Pattern p = Pattern.compile('[null]');
        s = p.matcher(s).replaceAll('');
        system.debug(s);
    }
}