public class myCoolTypeAheadCont {

  public String objAPIName {get; set;}
  public String fieldAPIName {get; set;}
  
  public myCoolTypeAheadCont(){
   // accs = new List<Account>();
  }
@remoteAction
  public static List<String> querySuggestions(String objName, String fieldName, String input){
    
    String inp = '%'+input+'%';
    String query = '';
    List<String> results = new List<String>();
   
    query = 'select id, '+fieldName+' from '+objName+ ' where '+fieldName+' LIKE'+'\''+inp+'\'';
    system.debug('-----------query-----------'+query);
    List<sObject> res = Database.query(query);
    
    for(sObject obj : res){
          String suggestion = '';
          suggestion = String.valueOf(obj.get(''+fieldName));
          results.add(suggestion);
          }
          
    return results;
  
  }

}