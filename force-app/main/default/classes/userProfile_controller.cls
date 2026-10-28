public class userProfile_controller {
    
    public userProfile_controller(){
        
    }
    
    public List< wrapper > getRecords(){
        List< wrapper > wList = new List< wrapper >();        
        for (AggregateResult ar : [SELECT Parent.Name name, ParentId id, COUNT(Id) idCount FROM AccountFeed where LikeCount = 0 GROUP By Parent.Name, ParentId ORDER BY Parent.Name])  {            
            wList.add(new wrapper(string.valueOf(ar.get('name')), string.valueOf(ar.get('id')), Integer.valueOf(ar.get('idCount'))));
        }
        return wList;
    }
    
    public class wrapper{
        public string accountName {get; set;}
        public string accountId {get; set;}
        public Integer count {get; set;}
        
        public wrapper(string name, string id, Integer count){
            accountName = name;
            accountId = id;
            this.count = count;
        }
    }

}