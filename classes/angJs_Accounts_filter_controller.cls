public class angJs_Accounts_filter_controller { 
    public static String getlstAccount() { 
        return JSON.serialize([SELECT Id, Name, Type, Phone FROM Account limit 10]); 
    }
}