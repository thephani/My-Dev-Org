public class leadSearch_controller {
    
    public string searchOrg {get; set;} 
    public string searchAbn {get; set;} 
    public Lead lead {get; set;}
    
    public leadSearch_controller(){
        lead = new Lead();
    }
    
    public List<Lead> getLeadList(){
        return database.query('SELECT Id, Name, Email FROM Lead WHERE Name LIKE \'' + searchOrg + '%\'');
    }
    
    public void dummyAction(){
        
    }
    
    public PageReference insertLead(){
        insert lead;        
        return new PageReference('/'+lead.Id);
    }

}