public class leadConverter {

    public leadConverter(ApexPages.StandardController controller) {

    }
    
    public PageReference convert(){
    
        Id leadId = apexpages.currentpage().getparameters().get('id');
        
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(leadId);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
        lc.setConvertedStatus(convertStatus.MasterLabel);
        lc.setDoNotCreateOpportunity(true); // comment this if you want to Create Opportunity
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
         return new PageReference('/p/lead/ViewConvertedLead/d?id='+lcr.getLeadID());
    }
    

}