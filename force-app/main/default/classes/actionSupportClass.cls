public class actionSupportClass {

    public String username { get; set; }

    public PageReference sayHello() {
        username = UserInfo.getName();
        return null;
    }

}