public class chiru_page_Ext {
    Id accId;
    public List<Contact> contactList {get; set;}
    public chiru_page_Ext(ApexPages.StandardController sc){
        accId = sc.getId();        
        contactList = new List<Contact>();
    }
    
    public void addContact(){
        contactList.add(new Contact(AccountId = accId));
    }
    
    public void saveContact(){
        upsert contactList;        
    }
}