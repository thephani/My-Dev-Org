public with sharing class Graph 
{  
    public List<PieWedgeData> getPieData() 
    {  
        List<PieWedgeData> data = new List<PieWedgeData>();
        List<Opportunity> memb = new List<Opportunity>();  
        
        String sql = 'SELECT Name, Amount FROM Opportunity where Amount != null LIMIT 5';
        memb = Database.Query(sql);
        for(Opportunity temp:memb)
        {           
            data.add(new PieWedgeData(temp.Name,temp.Amount));
        }
        return data;  
    }  
    
    // Wrapper class  
    public class PieWedgeData 
    {  
        public String name { get; set; }  
        public Decimal data { get; set; }  
        
        public PieWedgeData(String name, Decimal data) 
        {  
            this.name = name;  
            this.data = data;  
        }  
    }  
}