public class home_controller {   
        
    @RemoteAction
    public static string getUrlString(string appId){
        AppMenuItem app =  [SELECT Id, Name, StartUrl FROM AppMenuItem WHERE Id =: appId];
        return app.StartUrl;
    }
    
    public List<AppMenuItem> getApps(){
        return [SELECT IconUrl, InfoUrl, LogoUrl, Description, StartUrl, Label, Name, SortOrder, Id FROM AppMenuItem ];//WHERE Name LIKE 'ABI%'
    }
    
}