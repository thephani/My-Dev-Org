public class RecordTypeUtils {

    Map < String, Schema.SObjectType > gd = null;
    Schema.DescribeSObjectResult d = null;
    static Map < String, Schema.RecordTypeInfo > rtMapByName = null;

    public RecordTypeUtils(String ObjectName) {
        gd = Schema.getGlobalDescribe();
        d = gd.get(objectName).getDescribe();
        rtMapByName = d.getRecordTypeInfosByName();
    }

    // returns Record Type Id of specified Object along with its Name.
    // How to Call?
    // Id payerRecordTypeID = RecordTypeUtils.getRecordTypeId('Opportunity', 'Payer');

    public static Id getRecordTypeId(String recordTypeName) {
        return rtMapByName.get(recordTypeName).getRecordTypeId();
    }

    // returns Map of all Record Type Name & Id's of specified Object
    // How to Call?
    // Map<String, Id> oppRecordTypes = RecordTypeUtils.getRecordTypeByObjectName('Opportunity');
    // to get specific recordTypeId, Id payerRecordTpeid = oppRecordTypes.get('Payer');

    public static Map < String, Id > getRecordTypeList() {

        Map < String, Id > recordTypeNameIdList = new Map < String, Id > ();
        for (String rName: rtMapByName.keySet()) {
            recordTypeNameIdList.put(rName, rtMapByName.get(rName).getRecordTypeId());
        }
        return recordTypeNameIdList;
    }
}