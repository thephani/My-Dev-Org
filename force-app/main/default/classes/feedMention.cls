public class feedMention {  
    @future(callout = true)
    public static void addMention(String RecordId , String ChatterPostText , String UserId, String sesId ){
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        
        String url = salesforceHost + '/services/data/v33.0/chatter/feed-elements';
        system.debug('Url generated: '+url);
        
        HttpRequest req = new HttpRequest();
        
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + sesId);
        
        req.setBody('{"body": {"messageSegments": [{"type": "mention", "id": "' + UserId + '"}, {"type": "text", "text": "' + ' ' + ChatterPostText + '"} ] }, "feedElementType": "FeedItem", "subjectId": "' + RecordId + '", "visibility": "AllUsers"}');
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        system.debug('Response: '+res.getBody());
    }
}