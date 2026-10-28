public class DynamicPicklist {

    public DynamicPicklist(ApexPages.StandardController controller) {

    }
    
    public List<SelectOption> getLeadSourceNames()
    {
        List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult fieldResult = Contact.LeadSource.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }

}