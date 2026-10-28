public with sharing class EnhancedListViewController{   
    
    public String objectName {get; set;}    
    public String listName { get; set;}
    
    public String getlistId(){  
        try{
        ListView lv = [SELECT Id, Name, SobjectType FROM ListView where Name =: listName AND sObjectType =: objectName];
        string s = lv.Id;
        return s.substring(0, 15);
        } Catch(Exception Ex){
            return null;
        }
    }
    
}