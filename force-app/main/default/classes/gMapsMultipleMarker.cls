public class gMapsMultipleMarker {

    public List<Account> accList {get; set;}
    public List<Contact> conList = new List<Contact>();
    public List<Lead> leadList = new List<Lead>(); 
    public String JSONString{get;set;}
    
    public gMapsMultipleMarker(){
        accList = [SELECT Id, BillingPostalCode, BillingCountry FROM Account where BillingPostalCode != null LIMIT 5];
        conList = [SELECT Id, MailingPostalCode, MailingCountry FROM Contact where MailingPostalCode != null  LIMIT 5];
        leadList = [SELECT Id, PostalCode, Country FROM Lead WHERE PostalCode != null LIMIT 5];
        JSONString = JSON.serialize(accList);
    }       
}