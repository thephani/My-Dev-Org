public class feedMentionUtil{

    public static Map < Id, List < String > > aTopics = new Map < Id, List < String >> ();

    @future(callout = true)
    public static void mentions(List < String > wrapSer) {

        feedUtilWrapper currWrap = null;
        List < feedUtilWrapper > reqList = new List < feedUtilWrapper > ();

        Set < Id > noDups = new Set < Id > ();

        for (String ser: wrapSer) {
            currWrap = (feedUtilWrapper) JSON.deserialize(ser, feedUtilWrapper.class);
            reqList.add(currWrap);
            noDups.add(currWrap.recordId);

        }

        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String recId = null;
        Integer i = 0;
        for (feedUtilWrapper f: reqList) {

            if (i < 10) {

                string rId = f.recordId;
                system.debug('Record ID: '+rId);
                if (rId.startsWith('a0V') || rId.startsWith('a0D')) {

                    // for @mentions

                    String url = salesforceHost + '/services/data/v29.0/chatter/feeds/record/' + f.recordId + '/feed-items';

                    HttpRequest req = new HttpRequest();
                    req.setMethod('POST');
                    req.setEndpoint(url);
                    req.setHeader('Content-type', 'application/json');
                    req.setHeader('Authorization', 'OAuth ' + f.sessionId);

                    req.setBody('{ "body" : { "messageSegments" : [ { "type": "mention", "id" : "' + f.userId + '" }, { "type": "text",  "text" : "' + ' ' + f.text + '" } ] }, "visibility": "AllUsers" }');
                    Http http = new Http();

                    HTTPResponse res = http.send(req);                                      
                    i++;
                    system.debug('Entered@!#');

                    Id fId = [SELECT Id, CreatedDate FROM FeedItem where parentID = : f.recordId order by CreatedDate DESC LIMIT 1].Id;                                       

                    if (f.reasonsList != null) {
                        aTopics.put(fId, f.reasonsList);
                    }
                }
            }
        }

        //addTopics(aTopics);
    }

    @future(callout=true)
    public static void addMention(Id RecordId , String ChatterPostText , Id UserId, String sesId ){
         String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();

         String url = salesforceHost + '/services/data/v29.0/chatter/feeds/record/' + RecordId + '/feed-items';
         system.debug('Url generated: '+url);
        
         HttpRequest req = new HttpRequest();
        
         req.setMethod('POST');
         req.setEndpoint(url);
         req.setHeader('Content-type', 'application/json');
         req.setHeader('Authorization', 'OAuth ' + sesId);
        
         req.setBody('{ "body" : { "messageSegments" : [ { "type": "mention", "id" : "' + UserId + '" }, { "type": "text",  "text" : "' + ' ' + ChatterPostText + '" } ] },"visibility": "AllUsers" }');
         Http http = new Http();
        
         HTTPResponse res = http.send(req);
         system.debug('Response: '+res.getBody());
    }
    
    @future(callout = true)
    public static void newAddMention(string text, string recId, string userOrGroup, string sessId){
         String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
         if(userOrGroup == null){
             userOrGroup = 'user'; // valid input user or group
         }

         String url = salesforceHost + '/services/data/v32.0/actions/standard/chatterPost';
         //system.debug('Url generated: '+url);
        
         HttpRequest req = new HttpRequest();
        
         req.setMethod('POST');
         req.setEndpoint(url);
         req.setHeader('Content-type', 'application/json');
         req.setHeader('Authorization', 'OAuth ' + sessId);
        
         req.setBody('{"inputs": [{"text": "'+text+'", "SubjectNameOrId": "'+recId+'", "type": "'+userOrGroup+'"}] }');
         Http http = new Http();
        
         HTTPResponse res = http.send(req);
         system.debug('Response: '+res.getBody()); 
    }
    
    public class feedUtilWrapper {

        public Id recordId;
        public string text;
        public Id userId;
        public string sessionId;
        public List < string > reasonsList;
        public boolean topicsNeeded;

        public feedUtilWrapper(Id recordId, string text, Id userId, string sessionId, List < string > reasonsList, boolean topicsNeeded) {
            this.recordId = recordId;
            this.text = text;
            this.userId = userId;
            this.sessionId = sessionId;
            this.reasonsList = reasonsList;
            this.topicsNeeded = topicsNeeded;
        }
    }

}