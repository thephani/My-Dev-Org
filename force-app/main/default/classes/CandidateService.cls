global class CandidateService {
	
	global class Candidate{
        webservice String firstName {get; set;}
        webservice String lastName  {get; set;}
        webservice String email  {get; set;}

    }

    webservice static String createCandidate(Candidate c){
       
       // Inserting a new Candidate in Salesforce
       
       try{
       	Candidate__c candidate = new Candidate__c();
		candidate.First_Name__c = c.firstName;
		candidate.Last_Name__c = c.lastName;
		candidate.Email__c =  c.email;
		insert candidate;
		return 'Candidate: '+candidate.Name+' Has been Created.';       	
       } catch(Exception Ex) {
       	return 'Error in Inserting Candidate.ERROR:'+Ex;
       }
    }
}