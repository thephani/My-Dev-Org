global Class ManagePicklistsForFlow implements Process.Plugin {

    global Process.PluginResult invoke(Process.PluginRequest request) {    

        String ObjectAPIName = (String) request.inputParameters.get('ObjectAPIName');
        String FieldAPIName = (String) request.inputParameters.get('FieldAPIName');
        
        Map<String,Object> result = new Map<String,Object>();
    
        ManagePicklist(ObjectAPIName, FieldAPIName);
 
        return new Process.PluginResult(result); 
    }

    private void ManagePicklist(String ObjectAPIName, String FieldAPIName) {
 
    Schema.SObjectType sot = Schema.getGlobalDescribe().get(ObjectAPIName);
    Schema.DescribeSOBjectResult sotDesc = sot.getDescribe();
    Schema.DescribeFieldResult F = sotDesc.fields.getMap().get(FieldAPIName).getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();   

    Set<String> existingValues = new Set<String>();
    for (PicklistForFlow__c existing : [
        SELECT PickListValue__c FROM PicklistForFlow__c
        WHERE ObjectName__c = :ObjectAPIName AND PicklistFieldName__c = :FieldAPIName
    ]) {
        if (existing.PickListValue__c != null) {
            existingValues.add(existing.PickListValue__c.toLowerCase());
        }
    }

    List<PicklistForFlow__c> missingValues = new List<PicklistForFlow__c>();
    for (PicklistEntry entry : P) {
        if (!existingValues.contains(entry.getValue().toLowerCase())) {
            missingValues.add(new PicklistForFlow__c(
                ObjectName__c = ObjectAPIName,
                PickListValue__c = entry.getValue(),
                PicklistFieldName__c = FieldAPIName,
                PickListLabel__c = entry.getLabel()
            ));
        }
    }
    if (!missingValues.isEmpty()) {
        insert missingValues;
    }
    
    }

    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'This Flow Plug-in can be used to manage picklist values of any Field outside of the object definition to be used by Flow.';
        result.tag = 'Picklist Utils';
        
        result.inputParameters = new List<Process.PluginDescribeResult.InputParameter>{
            new Process.PluginDescribeResult.InputParameter('ObjectAPIName', 
                Process.PluginDescribeResult.ParameterType.STRING, true),
            new Process.PluginDescribeResult.InputParameter('FieldAPIName',                                                   
                Process.PluginDescribeResult.ParameterType.STRING, true)
                };

        result.outputParameters = new List<Process.PluginDescribeResult.OutputParameter>{};   
        
        return result;
    }


    static testMethod void basicTest() {

    // Create dummy lead
    Account testAccount = new Account(Name='acme');
    insert testAccount;

    ManagePicklistsForFlow aPicklistPlugin = new ManagePicklistsForFlow();
    Map<String,Object> inputParams = new Map<String,Object>();
    Map<String,Object> outputParams = new Map<String,Object>();

    inputParams.put('ObjectAPIName','Account');
    inputParams.put('FieldAPIName','Industry');
    
    Process.PluginRequest request = new Process.PluginRequest(inputParams);
    Process.PluginResult result;
    result = aPicklistPlugin.invoke(request);
        
        
    Schema.DescribeFieldResult F = Account.Industry.getDescribe();
    List<Schema.PicklistEntry> P = F.getPicklistValues();
    
    PicklistForFlow__c[] fpv = [select PicklistFieldName__c from PicklistForFlow__c where ObjectName__c = 'Account' and PicklistFieldName__c = 'Industry'];
    
    System.AssertEquals(P.size(), fpv.size());
        
        
    //Make sure another call to the plugin does not result in duplicate entries
    Integer queriesBeforeRepeat = Limits.getQueries();
    Integer dmlBeforeRepeat = Limits.getDmlStatements();
    result = aPicklistPlugin.invoke(request);
    System.assertEquals(1, Limits.getQueries() - queriesBeforeRepeat, 'Existing values must be fetched in one query');
    System.assertEquals(0, Limits.getDmlStatements() - dmlBeforeRepeat, 'A repeat call must not insert duplicates');
    fpv = [select PicklistFieldName__c from PicklistForFlow__c where ObjectName__c = 'Account' and PicklistFieldName__c = 'Industry'];
    
    System.AssertEquals(P.size(), fpv.size());
                
    }

    static testMethod void existingValuesAreMatchedRegardlessOfCase() {
        List<Schema.PicklistEntry> entries = Account.Industry.getDescribe().getPicklistValues();
        String value = entries[0].getValue();
        String caseVariant = value.toUpperCase();
        if (value.equals(caseVariant)) {
            caseVariant = value.toLowerCase();
        }
        System.assert(!value.equals(caseVariant), 'The fixture must exercise a different letter case');
        PicklistForFlow__c cached = new PicklistForFlow__c(
            ObjectName__c = 'Account', PicklistFieldName__c = 'Industry',
            PickListValue__c = caseVariant, PickListLabel__c = 'Existing label'
        );
        insert cached;
        // Verify the original SOQL comparison treats this cached spelling as a match.
        System.assertEquals(1, [SELECT count() FROM PicklistForFlow__c
            WHERE ObjectName__c = 'Account' AND PicklistFieldName__c = 'Industry'
            AND PickListValue__c = :value]);

        Test.startTest();
        new ManagePicklistsForFlow().invoke(new Process.PluginRequest(new Map<String, Object>{
            'ObjectAPIName' => 'Account', 'FieldAPIName' => 'Industry'
        }));
        Test.stopTest();
        System.assertEquals(entries.size(), [SELECT count() FROM PicklistForFlow__c
            WHERE ObjectName__c = 'Account' AND PicklistFieldName__c = 'Industry'],
            'A differently cased cached value must not be inserted again');
        PicklistForFlow__c unchanged = [SELECT PickListValue__c, PickListLabel__c FROM PicklistForFlow__c WHERE Id = :cached.Id];
        System.assertEquals(caseVariant, unchanged.PickListValue__c);
        System.assertEquals('Existing label', unchanged.PickListLabel__c);
    }

	static testMethod void describeTest() {

        ManagePicklistsForFlow aPicklistPlugin = new ManagePicklistsForFlow();
        Process.PluginDescribeResult result = aPicklistPlugin.describe();
            
        System.AssertEquals(result.inputParameters.size(), 2);
        System.AssertEquals(result.OutputParameters.size(), 0);
	}        
        
}