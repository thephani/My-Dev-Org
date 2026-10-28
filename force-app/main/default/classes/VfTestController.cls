public class VfTestController 
{
    List<ContentDocument> topContent;
    public List<ContentDocument> getTopContent()
    {
        return topContent;
    }

    public PageReference loadDocuments()
    {           
        if (topContent == null)
        {
            topContent = [select Id,Title from ContentDocument limit 10];
        }
                Component.Apex.PageBlock pageBlk = new Component.Apex.PageBlock();
                Component.Apex.inputfield cs = new Component.Apex.inputfield();         
                Component.Apex.PageBlockSection pageBlkSection = new Component.Apex.PageBlockSection(title = 'dummy header');
                pageBlk.childComponents.add(pageBlkSection);
        return null;
        
    }
}