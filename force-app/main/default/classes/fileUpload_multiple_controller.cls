public class fileUpload_multiple_controller {

    public List<Attachment> attList {get; set;}
    
    public fileUpload_multiple_controller(){
        attList = new List<Attachment>();
        attList.add(new Attachment());
    }
    
    public void addNew(){
        attList.add(new Attachment());
    }
    
    public void Save(){
    List<Attachment> newList = new List<Attachment>();
        for(Attachment a: attList)
        { a.ParentId = '0019000000WPyWZ'; newList.add(a); } insert newList;
    }
    
}