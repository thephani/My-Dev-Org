public class chatterController{
    
    public string msg {get; set;}
    
    public chatterController(){
        
    }
    
    public List<EntitySubscription> getFollowers(){
        return [select id, subscriberid, subscriber.name from EntitySubscription where parentid =: userinfo.getUserId()];
    }
    
    public void send(){
        
    }

}