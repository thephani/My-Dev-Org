public class testMethodGenerator { 
    
    public Id recordId {get; set;}
    public string classContent {get; set;}
    
    public void processRecord(){        
        List<String> fieldsNeeded = new List<String>();
        
        Map <String, Schema.SObjectField> fieldMap = recordId.getSObjectType().getDescribe().fields.getMap();
        for(Schema.SObjectField sfield : fieldMap.Values()){    
            schema.describefieldresult f = sfield.getDescribe();
            // getting standard fields
            if(!f.isCustom() && f.isCreateable() && !f.isAutoNumber()){           
                fieldsNeeded.add(f.getName() ); 
            }
            // getting custom fields
            if(f.isCustom() && f.isCreateable() && !f.isIdLookup()){
                //system.debug('field api ' + f.getSObjectField() );    
                //system.debug('is writable ' + f.isCreateable() );    
                //system.debug('is Lookup ' + f.isIdLookup() );  
                fieldsNeeded.add(f.getName() ); 
            }
        }
        
        string query = 'SELECT ';
        
        Integer count = 0;
        for(string ft: fieldsNeeded){
            if(count == 0){
                query += ft ;
            } else {
                query += ', '+ft;
            }
            count++;
        }
        
        query += ' FROM '+recordId.getSObjectType()+' WHERE Id = \''+recordId+'\'';
        
        sObject obj = Database.query(query);
        
        String method = ''+recordId.getSObjectType() +' rec = new '+recordId.getSObjectType()+'();\n';
        for(String f: fieldsNeeded){
            method += 'rec.'+f+' = \''+obj.get(f)+'\';\n';
        }
        method += 'insert rec;';
        classContent = method;
        system.debug(method);
        //return method;        
    }
}