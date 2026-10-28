public class table_new_ext {
    public List<Account> accList {get; set;}
    
    public table_new_ext(ApexPages.StandardController controller) {
        accList = new List<Account>();
    }
    
    public void addRow(){
        accList.add(new Account());
    }
    
    public void deleteRow(){
        Integer row = Integer.valueOf(ApexPages.currentPage().getParameters().get('rowId'));
        accList.remove(row);
    }
    
    public void saveRows(){
        if(accList.size() > 0){
            upsert accList;
        }
    }
    
}