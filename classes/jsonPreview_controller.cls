public class jsonPreview { 

    public string result {get; set;} 

    public jsonPreview() { 

        Id id = ApexPages.currentPage().getParameters().get('id'); 
        string sObj = id.getSObjectType().getDescribe().getName(); 
        string field = ApexPages.currentPage().getParameters().get('field'); 
        string query = 'SELECT Id, '+field+' FROM '+sObj+' WHERE Id = \''+id+'\''; 
        
        SObject obj = Database.query(query); 
        string tempStr = String.valueOf(obj.get(field)); 
        return tempStr != null ? tempStr : null;
        // use JSON.serialize if you're saving as on object to conver as string
    }
}