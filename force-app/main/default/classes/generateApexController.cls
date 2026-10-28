public class generateApexController {

    public String Generate { get; set; }
    
    public void Generate(){
        
    }

    public String ObjName { get; set; }    
    
    public String VfCode;
    

     
    public String getVfPage() {
        List<String> list1 = new List<String>{'Name','CreatedDate'};
        string fieldList = '';
        ObjName = 'Account';
        for(String str : list1){
            fieldList += '<apex:inputField value=\''+'{!'+ObjName+'.'+ str+'}'+'\' />';
        }
            
        VfCode = '<apex:page standardController=\'Account\'>\n\t<apex:form><apex:PageBlock><apex:pageblockSection >'+fieldList+'</apex:pageBlockSection></apex:pageBlock></apex:form></apex:page>';
        return VfCode;
    }
}