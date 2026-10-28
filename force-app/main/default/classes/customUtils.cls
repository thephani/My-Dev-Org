public class customUtils{

    public static Map<string, String> rtMap = new Map<String, String>();
    
    // call as follows customUtils.getAllRType('Position__c')
    
    // syntax customUtils.getAllRType(<objectName>); returns record tyep Name and Type
    public static Map<String, String> getAllRType(string ObjectName){
        for( Record_Type_Settings__c rc: Record_Type_Settings__c.getall().values()){
            if(rc.Object__c == objectName){
                rtMap.put(rc.Name, rc.Type__c);   
            }
        }
        return rtMap;
    }
}