public class QuickCandidates {

    public String objName { get; set; }

    public List<SelectOption> getDataTypes() {
    return null;
        
    }
    
    public List<SelectOption> getObjNameList(){   
     
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('---None---','---None---'));
        for(Schema.SObjectType f : gd){
           options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
        }
        options.sort();
        return options;
    }


    public QuickCandidates() {
    }

    List<Candidate__c> candList = new List<Candidate__c>();

    public QuickCandidates(ApexPages.StandardController controller) {

    }

    public void addNewCandidate() {
        candList.add(new Candidate__c());
    }

    public List<Candidate__c> getRequests() {
        return candList ;
    }
    
    public PageReference Save() {
        insert candList;
        return new PageReference('/a03/o');
    }

}