public class multiselect {
   
    List<SelectOption> options1;    

    public String getSelectedValues1() {
        return null;
    }     
    public String rightselected1 { get; set; }
    
    public PageReference unselectclick1() {
        return null;
    }
    public PageReference selectclick1() {
        return null;
    }


    public String unselectedvalues1 { get; set; }
    public String leftselected1 { get; set; }

    Set<String> originalvalues = new Set<String>{'A','B','C','D','E','F','G'};
    Public List<string> leftselected{get;set;}
    Public List<string> rightselected{get;set;}
    Set<string> leftvalues = new Set<string>();
    Set<string> rightvalues = new Set<string>();
    
    public multiselect(){
        leftselected = new List<String>();
        rightselected = new List<String>();
        leftvalues.addAll(originalValues);
    }
    
    public PageReference selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }
        return null;
    }
    
    public PageReference unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }
        return null;
    }

    public List<SelectOption> getunSelectedValues(){
        List<SelectOption> options = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            options.add(new SelectOption(s,s));
        return options;
    }

    public List<SelectOption> getSelectedValues(){
        options1 = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            options1.add(new SelectOption(s,s));
        return options1;
    }
}