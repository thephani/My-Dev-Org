public class Report_CasesArticles{

    Map<Id, Case> casesWithoutArticles = new Map<Id, Case>([SELECT Id,CaseNumber FROM Case]);
    Map<Id, Case> casesWithArticles = new Map<Id,case>();            
            
    public Report_CasesArticles(){

        List<Id> caseIds = new List<Id>(); 

        for(CaseArticle art: [SELECT Id,CaseId FROM CaseArticle])    
            caseIds.add(art.CaseId);
            
        casesWithArticles = new Map<Id,Case>([SELECT Id,CaseNumber FROM Case WHERE Id IN :caseIds]);
    }
    public List<Data> getPieData() {
        return getChartData();
    }
    
    
    public List<Data> getChartData() {
        List<Data> data = new List<Data>();      

        data.add(new Data('Cases With Articles', casesWithArticles.size()));
        data.add(new Data('Cases With Out Articles', CasesWithoutArticles.size() - casesWithArticles.size()));

        return data;
    }
    
    public List<Case> getWithArticles(){
        return [SELECT Id, CaseNumber FROM Case WHERE Id IN :casesWithArticles.KeySet()];
    }
    
    public List<Case> getWithoutArticles(){
        return [SELECT Id, CaseNumber FROM Case WHERE Id IN :CasesWithoutArticles.KeySet()];    
    }
    
    // Wrapper class
    public class Data {
        public String name { get; set; }
        public Integer data1 { get; set; }

        public Data(String name, Integer data1) {
            this.name = name;
            this.data1 = data1;

        }
    }
}