public class SearchObjectController {    
    
    @AuraEnabled
    public static List<sObject> getRecords(string sObject_Name) {
        string query = 'SELECT Id, Name, Owner.Name FROM '+sObject_Name+' LIMIT 100';
        return database.query(query);
    }

    @AuraEnabled
    public static List<sObject> getSearchRecords(String searchKey, string sObject_Name) {
        string query = 'SELECT  Name, Owner.Name FROM '+sObject_Name+' WHERE Name like \'' + searchKey + '%\''; 
        return database.query(query);
    }
        
}