public class RestAPITest{
    
    public void TestAPI(){
        
        string username = 'sivakishore@salesforce.com';        
        string password = 'siva@0505'; 
        
        //Password along with the SecurityToken of the Organization which contains the REST 
        
        string ConsumerKey =  '3MVG9ZL0ppGP5UrDICrMfnYWNiHRBqd4JSJYXAs6oStjfXtjY3JJKb9EdexBljWNqVYSQd0tZzvFZ6cAiQ.eh';
        
        string clientId = '3205627187611860028';
        
        string URI = 'https://ap2.salesforce.com/services/oauth2/token?grant_type=password&' + 
            
            'client_id=' + ConsumerKey + '&' + 'client_secret=' + clientId + '&' + 'username=' + username 
            
            + '&' + 'password=' + password;
        system.debug(''+uri);
        
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(URI);        
        req.setMethod('POST');        
        Http http = new Http();        
        HTTPResponse res = http.send(req);
        
        System.debug('*** After Authentication...'+res.getBody());
        
        /* Here we need to Get the AccessToken form the Response for that we are Parsing the 

Response using JSONParser */
        
        string accsToken = '';
        
        JSONParser parser1 = JSON.createParser(res.getBody());
        
        while (parser1.nextToken() != null) {
            
            if ((parser1.getCurrentToken() == JSONToken.FIELD_NAME) && (parser1.getText() == 
                                                                        
                                                                        'access_token')) {
                                                                            
                                                                            // Get the value.
                                                                            
                                                                            parser1.nextToken();
                                                                            
                                                                            accsToken = parser1.getText();
                                                                            
                                                                        }
            
        }
        
        system.debug('accsToken===========>'+accsToken);
        
        //Calling Rest Service 
        
        URI = 'https://ap2.salesforce.com/services/apexrest/MappingDataService/MappingData';
        
        req = new HttpRequest();
        
        req.setEndpoint(URI);
        
        req.setMethod('POST');
        
        req.setHeader('content-type','application/json');
                
        
        string postData = '{ \"MapId\": \"0012800000p6AiD\"}'; 
        //Sending the Data i.e Arguments of the Methods of the RestAPI class
            
            req.setBody(postData);
        
        req.setHeader('Authorization', 'OAuth ' + accsToken);
        
        res = http.send(req);
        
        System.debug('**** After Service Call.....'+res.getBody());
        
        /* After Getting the Response from the Another Org We need to parse the Result Using 

JSON Parser. */
        
        string mapname = '';
        
        string mapid = '';
        
        JSONParser parser = JSON.createParser(res.getBody());
        
        while (parser.nextToken() != null) {
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 
                                                                       
                                                                       'Name')) {
                                                                           
                                                                           // Get the value.
                                                                           
                                                                           parser.nextToken();
                                                                           
                                                                           mapname = parser.getText();
                                                                           
                                                                       }
            
            if((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 
                                                                      
                                                                      'Id')){
                                                                          
                                                                          parser.nextToken();
                                                                          
                                                                          mapid = parser.getText();
                                                                          
                                                                      }
            
            
            
        }                      
    }    
}