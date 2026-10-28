public class social_handlers_controller {
    /*
    public string linkedIn {get; set;}
    public string twitter {get; set;}
    public List < wrapper > wList {get; set;}
    public string msg {get; set;}
    public boolean isOwned {get; set;}
    public Lead l {get; set;}
    public boolean leadFound {get; set;}

    string t_handle, l_handle;
    boolean updateClicked = false;

    String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
    Set < string > contactIds = new Set < string > ();

    public social_handlers_controller() {
        wList = new List < wrapper > ();
        l = new Lead();
        leadFound = false;
    }

    public void Search() {
        updateClicked = false;
        wList = new List < wrapper > ();
        getSocialResults(linkedIn, null, UserInfo.getSessionId());
    }

    public void updateClicked() {
        updateClicked = true;
    }

    public PageReference add() {
        updateClicked = true;
        for (wrapper d: wList) {
            try {
                l = [SELECT id, email, Name from Lead where email = : d.email];
            }
            Catch(Exception Ex) {}
            if (l.Id != null) {
                l.Twitter__c = t_handle;
                l.LinkedIn__c = l_handle;
                if (t_handle != null || l_handle != null) {
                    update l;
                }
            } else {
                system.debug('Lead Not Found');
                l = new Lead();
                l.FirstName = d.firstName;
                l.LastName = d.lastName;
                l.Company = d.companyName;
                //l.contac = d.contactId;
                l.State = d.state;
                l.City = d.city;
                l.Country = d.country;
                l.Email = d.email;
                if (updateClicked) {
                    l.Twitter__c = t_handle;
                    l.LinkedIn__c = l_handle;
                    if (t_handle != null || l_handle != null) {
                        insert l;
                    }
                }
            }
        }
        return new PageReference('/' + l.Id);
    }

    public void getSocialResults(String linkedId, Id UserId, String sesId) {

        contactIds = new Set < string > ();
        t_handle = null;
        l_handle = null;

        string lInStr = 'http://linkedin.com/in/' + linkedId;
        String url = salesforceHost + '/services/data/v32.0/match/DcSocialProfileMatchEngine/DcSocialProfile/DcSocialProfileMatchRule';
        system.debug('Url generated: ' + url);

        HttpRequest req = new HttpRequest();

        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + sesId);

        //req.setBody('{ "body" : { "messageSegments" : [ { "type": "mention", "id" : "' + UserId + '" }, { "type": "text",  "text" : "' + ' ' + ChatterPostText + '" } ] },"visibility": "AllUsers" }');
        req.setBody('{"entities":[{"attributes":{"type":"DcSocialProfile"}, "SocialHandles":{"records":[{"attributes":{"type":"DcSocialProfileHandle"}, "Handle": "' + ' ' + lInStr + '", "ProviderName":"Linkedin"} ] } } ], "matchOptions":{"fields":"SocialHandles, FirstName, LastName, CompanyName, City, State, Country, ContactId", "rule":"DcSocialProfileMatchRule", "matchEngine":"DcSocialProfileMatchEngine", "sObjectType":"DcSocialProfile"} }');
        Http http = new Http();

        HTTPResponse res = http.send(req);
        system.debug('Response: ' + res.getBody());
        JSONParser parser;
        if (Test.isRunningTest()) {
            parser = JSON.createParser('{"errors": null, "matchEngine": "DcSocialProfileMatchEngine", "matchRecords": [{"additionalInformation": [], "fieldDiffs": [{"difference": "DIFFERENT", "name": "SocialHandles"} ], "matchConfidence": -1, "record": {"attributes": {"type": "DcSocialProfile"}, "State": "CA", "FirstName": "Sidney", "SocialHandles": {"totalSize": 2, "done": true, "records": [{"attributes": {"type": "DcSocialProfileHandle"}, "Handle": "http://twitter.com/sidtao", "ProviderName": "Twitter"}, {"attributes": {"type": "DcSocialProfileHandle"}, "Handle": "http://linkedin.com/in/sidtao", "ProviderName": "LinkedIn"} ] }, "ContactId": "47104287", "CompanyName": "Salesforce.com, Inc.", "Country": "United States", "LastName": "Tao", "City": "San Francisco"} } ], "rule": "DcSocialProfileMatchRule", "size": 1, "success": true }');
        } else {
            parser = JSON.createParser(res.getBody());
        }
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if (fieldName == 'ContactId') {
                    system.debug('contactId Text() => ' + parser.getText());
                    if (parser.getText() != null && parser.getText() != '') {
                        contactIds.add(parser.getText());
                    }
                } else if (fieldName == 'handle') {
                    system.debug('COmpany Text() => ' + parser.getText());
                    if (parser.getText() != null && parser.getText() != '') {
                        string u7 = parser.getText();
                        if (u7.contains('twitter')) {
                            t_handle = parser.getText();
                        } else if (u7.contains('linkedin')) {
                            l_handle = parser.getText();
                        }
                    }
                }                
                else if (fieldName == 'size') {
                    msg = 'Found ' + parser.getText() + ' Records';
                }
            }
        }
    }

    public List < string > getContactIdDetails(string conId, string sesId) {

        String url = salesforceHost + '/services/data/v32.0/connect/datacloud/contacts/' + conId;
        system.debug('Url generated: ' + url);

        HttpRequest req = new HttpRequest();

        req.setMethod('GET');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + sesId);

        Http http = new Http();
        HTTPResponse res = http.send(req);
        system.debug('Response: ' + res.getBody());

        // parsing JSON
        string fn, ln, cn, cId, st, city, country, email;
        JSONParser parser;
        if (Test.isRunningTest()) {
            parser = JSON.createParser('{"errors": null, "matchEngine": "DcSocialProfileMatchEngine", "matchRecords": [{"additionalInformation": [], "fieldDiffs": [{"difference": "DIFFERENT", "name": "SocialHandles"} ], "matchConfidence": -1, "record": {"attributes": {"type": "DcSocialProfile"}, "State": "CA", "FirstName": "Sidney", "SocialHandles": {"totalSize": 2, "done": true, "records": [{"attributes": {"type": "DcSocialProfileHandle"}, "Handle": "http://twitter.com/sidtao", "ProviderName": "Twitter"}, {"attributes": {"type": "DcSocialProfileHandle"}, "Handle": "http://linkedin.com/in/sidtao", "ProviderName": "LinkedIn"} ] }, "ContactId": "47104287", "CompanyName": "Salesforce.com, Inc.", "Country": "United States", "LastName": "Tao", "City": "San Francisco"} } ], "rule": "DcSocialProfileMatchRule", "size": 1, "success": true }');
        } else {
            parser = JSON.createParser(res.getBody());
        }
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String fieldName = parser.getText();
                parser.nextToken();
                if (fieldName == 'email') {
                    if (parser.getText() != null && parser.getText() != '') {
                        email = parser.getText();
                    }
                } else if (fieldName == 'companyName') {
                    if (parser.getText() != null && parser.getText() != '') {
                        cn = parser.getText();
                    }
                } else if (fieldName == 'Country') {
                    if (parser.getText() != null && parser.getText() != '') {
                        country = parser.getText();
                    }
                } else if (fieldName == 'LastName') {
                    if (parser.getText() != null && parser.getText() != '') {
                        ln = parser.getText();
                    }
                } else if (fieldName == 'City') {
                    if (parser.getText() != null && parser.getText() != '') {
                        city = parser.getText();
                    }
                } else if (fieldName == 'State') {
                    if (parser.getText() != null && parser.getText() != '') {
                        st = parser.getText();
                    }
                } else if (fieldName == 'FirstName') {
                    if (parser.getText() != null && parser.getText() != '') {
                        fn = parser.getText();
                    }
                }
            }
        }


        return new List < string > {
            fn, ln, cn, cId, st, city, country, email
        };
    }

    public List < wrapper > getRecords() {
        wList = new List < wrapper > ();
        wrapper w = new wrapper();
        string conId;
        l = new Lead();
        if (contactIds.size() > 0) {
            for (DatacloudContact d: [SELECT City, CompanyId, CompanyName, ContactId, Country, Department, Email, FirstName, IsInactive, IsOwned, LastName, Level, Phone, State, Street, Title, UpdatedDate, Zip
                    FROM DatacloudContact WHERE ContactId IN: contactIds LIMIT 50
                ]) {
                if (!d.isOwned) {
                    isOwned = false;
                }

                // call purchase API
                if (updateClicked && !d.isOwned) {
                    List < string > s = getContactIdDetails(d.contactId, userinfo.getSessionId());
                    w = new wrapper();
                    try {l = [SELECT id, email, Name from Lead where email = : d.email];}Catch(Exception Ex) {}                    
                    if (l != null) { w.leadId = l.Id;w.leadName = l.Name;}
                    w.firstName = s[0]; w.lastName = s[1]; w.companyname = s[2]; w.contactId = d.contactId; w.state = s[4]; w.country = s[6]; w.email = s[7]; w.twitter = t_handle; w.linkedIn = l_handle;
                    wList.add(w);
                } else {
                    isOwned = true;
                    w = new wrapper();
                    try {l = [SELECT id, email, Name from Lead where email = : d.email];}Catch(Exception Ex) {}
                    if (l != null) { w.leadId = l.Id;w.leadName = l.Name;}
                    w.firstName = d.firstName; w.lastName = d.lastName; w.companyname = d.companyName; w.contactId = d.contactId; w.state = d.state; w.city = d.city; w.country = d.country; w.email = d.email;
                    if (updateClicked) { w.twitter = t_handle; w.linkedIn = l_handle;}
                    wList.add(w);
                }
            }
            return wList;
        } else {
            return null;
        }
    }

    public class wrapper {
        public string leadId {get; set;}
        public string leadName {get; set;}
        public string firstName {get; set;}
        public string lastName {get; set;}
        public string companyName {get; set;}
        public string contactId {get; set;}
        public string state {get; set;}
        public string city {get; set;}
        public string country {get; set;}
        public string email {get; set;}
        public string linkedIn {get; set;}
        public string twitter {get; set;}
    }*/
}