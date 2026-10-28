public class vfPageGenerator { 

    public String pbsName { get; set; }
    public string objName { get; set; } 
    public String getVfTags {get; set;}
    public String conStr = '';

    public Set<string> leftvalues = new Set<string>();
    public Set<string> rightvalues = new Set<string>();
    public Set<String> originalvalues = new Set<String>();    

    Public List<string> leftselected {get; set;}
    Public List<string> rightselected {get; set;}
    public List<SelectOption> selectedObjectFieldList;
    public List<SelectOption> SelectedOptions;
    public List<SelectOption> unSelectedOptions;

    public Map<string, string> filedAPINameMap;    
    public Map<String, List<String>> pagePBSections;
    
    public Set<string> objFields = new Set<String>();
    
    public void doPostback(){
    }  
    
    public List<SelectOption> getObjNameList(){   
     
        List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     
        List<SelectOption> options = new List<SelectOption>();
        
        for(Schema.SObjectType f : gd){
           options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getLabel()));
        }
        options.sort();
        return options;
    }
    
    public PageReference getFieldList() {
                    
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();            
        filedAPINameMap = new Map<string, string>();
        selectedObjectFieldList = new List<SelectOption>();
        for(Schema.SObjectField sfield : fieldMap.Values()){
            selectedObjectFieldList.add(new SelectOption(sfield.getDescribe().getName(),sfield.getDescribe().getLabel()));
            filedAPINameMap.put(sfield.getDescribe().getLabel(),sfield.getDescribe().getName());          
        }
        selectedObjectFieldList.sort();
        originalvalues = new Set<String>();
        for( SelectOption s : selectedObjectFieldList){
                originalvalues.add(s.getLabel());
        }
        leftvalues.addAll(originalValues);
        objFields = leftvalues;
        return null;
    }
    
    public void selectclick(){
        rightselected.clear();
        for(String s : leftselected){
            leftvalues.remove(s);
            rightvalues.add(s);
        }        
    }
    
    public void unselectclick(){
        leftselected.clear();
        for(String s : rightselected){
            rightvalues.remove(s);
            leftvalues.add(s);
        }      
    }

    public List<SelectOption> getunSelectedValues(){
        unSelectedOptions = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(leftvalues);
        tempList.sort();
        for(string s : tempList)
            unSelectedOptions.add(new SelectOption(s,s));
        return unSelectedOptions ;
    }

    public List<SelectOption> getSelectedValues(){
        SelectedOptions = new List<SelectOption>();
        List<string> tempList = new List<String>();
        tempList.addAll(rightvalues);
        tempList.sort();
        for(String s : tempList)
            SelectedOptions .add(new SelectOption(s,s));                
        return SelectedOptions;
    }
    
    public PageReference previewVf(){               
           
        getVfTags = '<apex:page standardController=\''+objName+'\'><apex:form><apex:PageBlock>' ;
        getVfTags += conStr;
        getVfTags += '</apex:pageBlock></apex:form></apex:page>'; 
        
        return null;
    }
    
    public void clearRightSelectionAddToMap(){  
        for(SelectOption s : SelectedOptions)
            rightselected.add(s.getLabel());
        conStr += '<apex:pageblockSection title=\''+pbsName+' Details\'>';
        for(SelectOption s : SelectedOptions)
            conStr += '<apex:outputField value=\'{!'+objName+'.'+filedAPINameMap.get(s.getLabel())+'}\' />';     
        conStr += '</apex:pageblockSection>';        

        for(String s : rightselected)
            rightvalues.remove(s);
              
    }
    
}