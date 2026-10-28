public class sftreecomponentcontroller{
	
    public List<TreeModel> nodeList {get;set;}
    public List<TreeModel> nodeList1;
    public TreeModel tm = new TreeModel();
    public TreeModel tmChild = new TreeModel();
    public static List<Id> contactsId;
    
    public Pagereference test(){
    	String cid = System.currentPageReference().getParameters().get('contactId');
    	system.debug('!!!Contact Id '+cid);
    	return null;
    }
        
    public sftreecomponentcontroller() {
	    nodeList = new List < TreeModel > ();
	    for (Account acc: [SELECT Id, Name, (Select Id, Name from Contacts) from Account LIMIT 100]) {
	        if (acc.Contacts.size() > 0) {
	            TreeModel tm1 = new TreeModel();
	            tm1.id = acc.Id;
	            tm1.name = acc.name;
	            for (Contact cnt: acc.Contacts) {
	                TreeModel tmChild1 = new TreeModel();
	                tmChild1.id = cnt.Id;
	                tmChild1.name = cnt.name;
	                tm1.children.add(tmChild1);
	            }
	            nodeList.add(tm1);
	        }
	    }
	}

	public List < TreeModel > getnodeList1() {
	
	    String pid = System.currentPageReference().getParameters().get('pId');
	    String cid = apexpages.currentpage().getparameters().get('cId');
	    nodeList1 = new List < TreeModel > ();
	    system.debug('Account Id ' + pid + 'Contact Id ' + cid);
	
	    if (pid != null || cid != null) {
	
	        Contact contact = [SELECT Id, Name, AccountId From Contact WHERE Id = : cid LIMIT 1];
	
	       
	        tm.id = contact.AccountId;
	        tm.name = 'Am Header';	
	      
	        tmChild.id = contact.Id;
	        tmChild.name = contact.name;
	        tm.children.add(tmChild);
	
	        nodeList1.add(tm);
	
	        return nodeList1;
	    }
	    return null;
	}

	public class TreeModel {
	    public string id {
	        get;
	        set;
	    }
	    public string name {
	        get;
	        set;
	    }
	    public List < TreeModel > children {
	        get;
	        set;
	    }
	
	    public TreeModel() {
	        children = new List < TreeModel > ();
	    }
	
	}
    
   
    /*
    public void addNode(String parentNodeId, String childId) {
    Integer index = getIndex(parentNodeId);
    if (index > -1) {
        //Already data exists
        TreeModel tm = nodeRightList.get(index);
        Contact contact = [SELECT Id, Name From Contact WHERE Contact.AccountId = : parentNodeId AND Id = : childId LIMIT 1];
        TreeModel tmChild = new TreeModel();
        tmChild.id = contact.Id;
        tmChild.name = contact.name;
        tm.children.add(tmChild);

    } else {
        //New Node
        for (Account acc: [SELECT Id, Name, (Select Id, Name from Contacts) from Account where Account.Id = : parentNodeId]) {
            if (acc.Contacts.size() > 0) {
                TreeModel tm = new TreeModel();
                tm.id = acc.Id;
                tm.name = acc.name;
                for (Contact cnt: acc.Contacts) {
                    if (childId == cnt.Id) {
                        TreeModel tmChild = new TreeModel();
                        tmChild.id = cnt.Id;
                        tmChild.name = cnt.name;
                        tm.children.add(tmChild);
                    }
                }
                nodeRightList.add(tm);
            }
        }
    }
    }

	private Integer getIndex(String nodeId) {
	    Integer index = 0;
	    for (TreeModel tm: nodeRightList) {
	        if (tm.id == nodeId) {
	            return index;
	        }
	        index++;
	    }
	    index = -1;
	    return index;
	}*/
    
    
    
}