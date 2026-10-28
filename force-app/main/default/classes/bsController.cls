public with sharing class bsController {
	public List<Case> lCases {get;set;}
	public List<Task> lTasks {get;set;}
	public List<Event> lEvents {get;set;}	
	public List<Note> lNotes {get;set;}
	public List<IntegratedNotes> intgerated_notes {get;set;}
	public Event dataRange {get;set;}	
	public Account acct {get;set;}

	public Boolean bCase {get;set;}
	public Boolean bTask {get;set;}
	public Boolean bEvent {get;set;}
	public Boolean bCNote {get;set;}
	public Boolean bNote {get;set;}
		

	public bsController() {		
		String theId = ApexPages.currentPage().getParameters().get('id');
		if(theId != null){
			acct = [Select Id from Account where Id=:theId];
		}
		try{
			initializeVariables();
			fetchIntegratedNotes();
		} catch (Exception e){
			System.debug('initialize?' + e.getMessage());
		}
	}

	public bsController(ApexPages.StandardController stdController){		
		acct = (Account)stdController.getRecord();
		try{
			initializeVariables();
			fetchIntegratedNotes();
		} catch (Exception e){
			System.debug('initialize?' + e.getMessage());
		}
	}

	public void initializeVariables(){
		dataRange = new Event();
		bCase = true;
		bNote = true;
		bTask = true;
		bEvent = true;
		bCNote = true;		
	}

	public void fetchCases(){
		lCases = new List<Case>();
		if(dataRange.StartDateTime != null && dataRange.EndDateTime != null && acct != null){
			Date startDateTime = Date.valueOf(dataRange.StartDateTime);
			Date endDateTime = Date.valueOf(dataRange.EndDateTime);
			lCases = [Select Id, Subject, CreatedDate, OwnerId, Owner.Name FROM Case where AccountId = :acct.Id and CreatedDate >= :startDateTime and CreatedDate <= :endDateTime];
		} else if(acct != null){
			lCases = [Select Id, Subject, CreatedDate, OwnerId, Owner.Name FROM Case where AccountId = :acct.Id];	
		}
		if(lCases.size()>0){
			for(Case c : lCases){				
				intgerated_notes.add(new IntegratedNotes(String.valueOf(c.Id),c.Subject, Date.valueOf(c.CreatedDate).format(), String.valueOf(c.OwnerId), c.Owner.Name, String.valueOf(RecordType.Name),''));	
			}			
		}		
	}

	public void fetchTasks(){
		lTasks = new List<Task>();
		if(dataRange.StartDateTime != null && dataRange.EndDateTime != null && acct != null){
			Date startDateTime = Date.valueOf(dataRange.StartDateTime);
			Date endDateTime = Date.valueOf(dataRange.EndDateTime);
			lTasks = [Select Id, Subject, ActivityDate, OwnerId, Owner.Name, Type from Task where AccountId = :acct.Id and CreatedDate >= :startDateTime and CreatedDate <= :endDateTime];			
		} else if(acct != null){
			lTasks = [Select Id, Subject, ActivityDate, OwnerId, Owner.Name, Type from Task where AccountId = :acct.Id];
		}
		if(lTasks.size()>0){
			for(Task t : lTasks){
				intgerated_notes.add(new IntegratedNotes(String.valueOf(t.Id),t.Subject,Date.valueOf(t.ActivityDate).format(), String.valueOf(t.OwnerId), t.Owner.Name, t.Type,''));	
			}			
		}
	}

	public void fetchEvents(){
		lEvents = new List<Event>();
		if(dataRange.StartDateTime != null && dataRange.EndDateTime != null && acct != null){
			Date startDateTime = Date.valueOf(dataRange.StartDateTime);
			Date endDateTime = Date.valueOf(dataRange.EndDateTime);
			lEvents = [Select Id, Subject, ActivityDate, OwnerId, Owner.Name, Type from Event where AccountId = :acct.Id and CreatedDate >= :startDateTime and CreatedDate <= :endDateTime];
		} else if(acct != null){
			lEvents = [Select Id, Subject, ActivityDate, OwnerId, Owner.Name, Type from Event where AccountId = :acct.Id];
		}
		if(lEvents.size()>0){
			for(Event t : lEvents){
				intgerated_notes.add(new IntegratedNotes(String.valueOf(t.Id),t.Subject,Date.valueOf(t.ActivityDate).format(), String.valueOf(t.OwnerId), t.Owner.Name, t.Type,''));	
			}			
		}
	}

	public void fetchNotes(){
		lNotes = new List<Note>();
		if(dataRange.StartDateTime != null && dataRange.EndDateTime != null && acct != null){
			Date startDateTime = Date.valueOf(dataRange.StartDateTime);
			Date endDateTime = Date.valueOf(dataRange.EndDateTime);
			lNotes = [Select Id, Title, CreatedDate, OwnerId, Owner.Name, Body from Note where ParentId = :acct.Id and CreatedDate >= :startDateTime and CreatedDate <= :endDateTime];
		} else if(acct != null){
			lNotes = [Select Id, Title, CreatedDate, OwnerId, Owner.Name, Body from Note where ParentId = :acct.Id];
		}
		if(lNotes.size()>0){
			for(Note n : lNotes){
				intgerated_notes.add(new IntegratedNotes(String.valueOf(n.Id),n.Title , Date.valueOf(n.CreatedDate).format(), String.valueOf(n.OwnerId), n.Owner.Name, String.valueOf(n.Body),''));	
			}			
		}
	}

	public void fetchIntegratedNotes(){
		intgerated_notes = new List<IntegratedNotes>();
		try{
			if(bCase) fetchCases();		
			if(bTask) fetchTasks();
			if(bEvent) fetchEvents();
			if(bNote) fetchNotes();
		} catch (Exception e){
			System.debug('fetchIntegratedNotes?' + e.getMessage());
		}		
	}

	//adding a datetime filter
	//adding an object filter
	//adding a link to create new objects
	//need to add a refresh button



	public Class IntegratedNotes{
		public String in_object {get;set;}
		public String in_subject {get;set;}
		public String in_Date {get;set;}
		public String in_user_id {get;set;}
		public String in_user_name {get;set;}
		public String in_type_code {get;set;}
		public String in_icon_url {get;set;}

		public IntegratedNotes(){

		}

		public IntegratedNotes(String oid, String sub, String d, String uid, String uname, String tc, String icon){
			in_object = oid;
			in_subject = sub;
			in_Date = d;
			in_user_id = uid;
			in_user_name = uname;
			in_type_code = tc;
			in_icon_url = icon;
		}
	}
}