public class createPageController {

    @future(callout=true)
    public static void createPage1(string sId) {
            
    	  MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = sId;
        
        /*MetadataService.ApexPage apexPage = new MetadataService.ApexPage();
        apexPage.apiVersion = 25;
        apexPage.fullName = 'asdf';
        apexPage.label = 'Test Page';
        apexPage.content = EncodingUtil.base64Encode(Blob.valueOf('<apex:page/>'));
        MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { apexPage });*/

        MetadataService.ApexTrigger customTrigger = new MetadataService.ApexTrigger();
        customTrigger.fullName = 'TestDevConsole';
        customTrigger.Content = EncodingUtil.base64Encode(Blob.valueOf('trigger TestDevConsole on Candidate__c (before insert, before update){}'));
        customTrigger.apiVersion = 30;
        customTrigger.status = 'Active';
        MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { customTrigger });
    }
    
    public static MetadataService.MetadataPort createService(){
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }


}