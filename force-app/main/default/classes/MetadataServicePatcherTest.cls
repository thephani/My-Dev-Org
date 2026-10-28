@IsTest
private class MetadataServicePatcherTest {
    @IsTest static void lineReaderPreservesEmptyRowsAndFinalLine() {
        MetadataServicePatcher.LineReader reader = new MetadataServicePatcher.LineReader('first\n\nlast');
        System.assertEquals(true, reader.hasNext());
        System.assertEquals('first', reader.next());
        System.assertEquals('', reader.next());
        System.assertEquals(true, reader.hasNext());
        System.assertEquals('last', reader.next());
        System.assertEquals(false, reader.hasNext());
        MetadataServicePatcher.LineReader empty = new MetadataServicePatcher.LineReader('');
        System.assertEquals(false, empty.hasNext());
        MetadataServicePatcher.LineReader trailing = new MetadataServicePatcher.LineReader('line\n');
        List<String> rows = new List<String>();
        for (String row : trailing) { rows.add(row); }
        System.assertEquals(new String[]{'line'}, rows);
    }
    @IsTest static void patchSourcePreservesSerializationAndPolymorphicContracts() {
        String source = String.join(new String[]{
            'public class MetadataServiceImported {',
            'public String endpoint_x = \'https://old.example.test\';',
            'public class Metadata {',
            'public String fullName;',
            '}',
            'public class MetadataWithContent {',
            '}',
            'public class Folder {',
            '}',
            'public class WorkflowAction {',
            '}',
            'public class CustomObject {',
            'public MetadataServiceImported.CustomField[] fields;',
            'private String[] field_order_type_info = new String[]{\'fields\'};',
            '}',
            'public class CustomLabel {',
            'private String[] field_order_type_info = new String[]{};',
            '}',
            'public class ApexClass {',
            'public Double apiVersion;',
            'private String[] field_order_type_info = new String[]{\'apiVersion\'};',
            '}',
            'public class Unrelated {',
            'public String keepMe;',
            '}',
            'public void update_x() {}',
            'public void delete_x() {}',
            'public void retrieve_x() {}',
            'public class ReadResult {',
            '}',
            'public MetadataServiceImported.ReadResult readMetadata(String type_x,String[] fullNames) {',
            '    return obsoleteReadImplementation;',
            '}',
            '// preserved-after-read',
            '}'
        }, '\n');
        String patched = MetadataServicePatcher.patchSource(source);
        System.assert(patched.startsWith('/**\n * Copyright (c) 2012, FinancialForce.com, inc'));
        System.assert(patched.contains('//Patched by MetadataServicePatcher v30.0 ' + System.today()));
        System.assertEquals(false, patched.contains('MetadataServiceImported'));
        System.assertEquals(false, patched.contains('https://old.example.test'));
        System.assert(patched.contains('public class MetadataService {'));
        System.assert(patched.contains('URL.getSalesforceBaseUrl().toExternalForm()'));
        System.assert(patched.contains('/services/Soap/m/30.0'));
        System.assert(patched.contains('public virtual class Metadata {'));
        System.assert(patched.contains('public virtual class MetadataWithContent extends Metadata {'));
        System.assert(patched.contains('public virtual class Folder extends Metadata{'));
        System.assert(patched.contains('public virtual class WorkflowAction extends Metadata{'));
        System.assert(patched.contains('public class CustomObject extends Metadata {'));
        System.assert(patched.contains('public MetadataService.CustomField[] fields;'));
        System.assert(patched.contains('public class ApexClass extends MetadataWithContent {'));
        System.assert(patched.contains('public String content;'));
        System.assert(patched.contains('public String fullName;'));
        System.assert(patched.contains('public String type = \'CustomObject\';'));
        System.assert(patched.contains('private String[] type_att_info = new String[]{\'xsi:type\'};'));
        System.assert(patched.contains('private String[] content_type_info = new String[]{\'content\','));
        System.assert(patched.contains('new String[]{\'fullName\', \'content\', \'apiVersion\'}'));
        System.assert(patched.contains('new String[]{\'fullName\', \'fields\'}'));
        System.assert(patched.contains('new String[]{\'fullName\'}'));
        System.assert(patched.contains('public class Unrelated {\npublic String keepMe;\n}'));
        System.assert(patched.contains('public void updateMetadata() {}'));
        System.assert(patched.contains('public void deleteMetadata() {}'));
        System.assert(patched.contains('public void retrieve() {}'));
        System.assertEquals(false, patched.contains('obsoleteReadImplementation'));
        System.assert(patched.contains('public interface IReadResult'));
        System.assert(patched.contains('public interface IReadResponseElement'));
        System.assert(patched.contains('public class ReadGroupResult implements IReadResult'));
        System.assert(patched.contains('public class ReadPackageResult implements IReadResult'));
        System.assert(patched.contains('public MetadataService.IReadResult readMetadata(String type_x,String[] fullNames)'));
        System.assert(patched.contains('return response_x.getResult();'));
        System.assert(patched.contains('\'MetadataService.read\' + type_x + \'Response_element\''));
        System.assert(patched.contains('// preserved-after-read'));
    }
}
