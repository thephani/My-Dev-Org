public class CaseAccount_relatedCases_Ext {
    
    Id accountId, caseId;
    
    public CaseAccount_relatedCases_Ext(ApexPages.StandardController sc){
        caseId = sc.getId();
        //accountId = [SELECT Id, AccountId FROM Case WHERE Id =: caseId].AccountId;
    }
    
    public List<Case> getCases(){
        return [SELECT Id, CaseNumber, Subject FROM Case LIMIT 5];
    }

}