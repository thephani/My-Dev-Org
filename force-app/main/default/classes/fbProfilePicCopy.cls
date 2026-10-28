global class fbProfilePicCopy {
    
    @future(callout=true)
    global static void updateChatterProfilePic(string fbId, Id userId){
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        string firstImageURL = 'http://graph.facebook.com/'+fbId+'picture?redirect=false&height=200&type=normal&width=200';
        //Replace any spaces with %20
        //firstImageURL = firstImageURL.replace(' ', '%20');
        req.setEndpoint(firstImageURL);
        req.setMethod('GET');
        //If you want to get a PDF file the Content Type would be 'application/pdf'
        req.setHeader('Content-Type', 'image/jpg');
        req.setCompressed(true);
        req.setTimeout(60000);
                         
        HttpResponse res = null;
        res = h.send(req);
        //These next three lines can show you the actual response for dealing with error situations
        string responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        //This is the line that does the magic.  We can get the blob of our file.  This getBodyAsBlob method was added in the Spring 2012 release and version 24 of the API.
        //blob image = res.getBodyAsBlob();
        //system.debug(image);
        
        JSONParser parser = JSON.createParser(responseValue);
        
        Double grandTotal = 0.0;
        string fbPicUrl;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && 
                (parser.getText() == 'url')) {
                    // Get the value.
                    parser.nextToken();
                    // Compute the grand total price for all invoices.
                    //grandTotal += parser.getDoubleValue();
                    fbPicUrl = parser.getText();
                }
        }
        system.debug('Grand total=' + fbPicUrl);
        
        h = new Http();
        req = new HttpRequest();
        firstImageURL = fbPicUrl;
        //Replace any spaces with %20
        //firstImageURL = firstImageURL.replace(' ', '%20');
        req.setEndpoint(firstImageURL);
        req.setMethod('GET');
        //If you want to get a PDF file the Content Type would be 'application/pdf'
        req.setHeader('Content-Type', 'image/jpg');
        req.setCompressed(true);
        req.setTimeout(60000);
                         
        res = null;
        res = h.send(req);
        //These next three lines can show you the actual response for dealing with error situations
        responseValue = '';
        responseValue = res.getBody();
        system.debug('Response Body for File: ' + responseValue);
        //This is the line that does the magic.  We can get the blob of our file.  This getBodyAsBlob method was added in the Spring 2012 release and version 24 of the API.
        blob image = res.getBodyAsBlob();
        //system.debug(image);
        ConnectApi.BinaryInput fileUpload = new ConnectApi.BinaryInput(image, 'image/jpg', 'profileImage');
        ConnectApi.Photo photoProfile = ConnectApi.ChatterUsers.setPhoto('0DB900000002w03GAA', userId, fileUpload);
                
    }
    
    // Get fb profile pic from here
    // string fbId = data.link;
    // u.CommunityNickname = fbId.substringAfter('https://www.facebook.com/app_scoped_user_id/');

}