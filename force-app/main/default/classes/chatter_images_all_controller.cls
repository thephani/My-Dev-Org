public class chatter_images_all_controller {
    public Map<Integer, String> map_img_src {get; set;} 
    public Map<Integer, String> map_img_text {get; set;} 
    
    public chatter_images_all_controller() {
        map_img_src = new Map<Integer, String>();       
        map_img_text = new Map<Integer, String>(); 

        Integer i = 0;
        String conType;

        for (FeedItem f : [SELECT ContentType,RelatedRecordId,Title FROM FeedItem ORDER By CreatedDate DESC]) {
             conType = f.ContentType;
             if(conType != null && conTYpe.contains('image')){
                 map_img_src.put(i, '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+f.RelatedRecordId);        
                 map_img_text.put(i, f.Title);
                 i++;
            }
        }
    }
}