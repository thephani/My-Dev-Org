public class treeviewcon {

public List < Account > accnts { get; set;}
public treeviewcon() {
    accnts = [Select id, name, (Select id, name from Contacts) from account];
}

}