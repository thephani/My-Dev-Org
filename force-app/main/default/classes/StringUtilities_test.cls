@isTest
private with sharing class StringUtilities_test
{
    private static testMethod void testBuildFieldNameList() 
    {
        set<string> TestFields = new set<string> { 'Sales_Rep_1__c', 'Appointment__r[0].Name', 'OwnerId' };
         string ReturnString = StringUtilities.BuildFieldNameList(TestFields);
        for(string val : TestFields){}
            //system.Assert(ReturnString.contains(val));
    }

    private static testMethod void testMakeIDList()
     {
        set<ID> TestIDs = new set<ID> { '00BA0000007CMB7', 'a0GA000000FFcTy', 'a0CA000000G3UvzMAF', 'a08A000000Em865IAB' };
        string ReturnString = StringUtilities.MakeIDList(TestIDs);
         for(string val : TestIDs)
            system.Assert(ReturnString.contains(val));
        system.Assert(ReturnString.Startswith('(\''));
        system.Assert(ReturnString.Endswith('\')'));
     }

    private static testMethod void testRemoveHTMLTags()
    {
        string HTMLString = 'Test\n<br/><br/><br/><br/>\nDone';
        string result = stringUtilities.RemoveHTMLTags(HtmlSTring);
         //system.assertEquals('Test\n\nDone',result);
    }

    private static testMethod void testFormatZipCode()
    {
        string testZip = ' 55066.4309  ';
        system.assertEquals('55066-4309', StringUtilities.FormatZipCode(testZip));

        testZip = '55066';
        system.assertEquals('55066', StringUtilities.FormatZipCode(testZip));

        testZip = '550664309';
        system.assertEquals('55066-4309', StringUtilities.FormatZipCode(testZip));

        testZip = 'H0H 0H0';
        system.assertEquals('H0H 0H0', StringUtilities.FormatZipCode(testZip));

        testZip = 'H0H0H0';
        system.assertEquals('H0H 0H0', StringUtilities.FormatZipCode(testZip));

        testZip = 'H0h0h0';
        system.assertEquals('H0H 0H0', StringUtilities.FormatZipCode(testZip));

        system.assertEquals(null, StringUtilities.FormatZipCode(null));

    }

    private static testMethod void testValidZip()
    {
        string testZip = null;
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = '';
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = '55066';
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = '55066-4309';
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = '550664309';
        system.assertEquals(false, StringUtilities.ValidZipCode(testZip));

        testZip = '55066.4309';
        system.assertEquals(false, StringUtilities.ValidZipCode(testZip));

        testZip = '5506';
        system.assertEquals(false, StringUtilities.ValidZipCode(testZip));

        testZip = 'H0H 0H0';
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = 'H0H0H0';
        system.assertEquals(true, StringUtilities.ValidZipCode(testZip));

        testZip = 'H0h0h0';
        system.assertEquals(false, StringUtilities.ValidZipCode(testZip));

    }
    
    private static testMethod void testHextoInt()
    {
        StringUtilities.hexToInt('FFFFFF');
        StringUtilities.CalculateLuminanceFromRGB('FFFFFF');
        
        // Teja Edited
        
        StringUtilities.FindStateName('');
    }
    
     private static testMethod void testJoinstr()
    {
        StringUtilities.JoinStr(new set<String>{'string1','string2'}, '$');
    }

    private static testMethod void runSU_JoinStr()
     {
        string tString1 = 'string1;string2;string3;string4;string5';
        string tString2 = 'string1,string2,string3,string4,string5';

        List<string> split1 = tString1.Split(';');
         string RetVal = StringUtilities.JoinStr(split1, ',');
        //System.Debug(RetVal);
        System.AssertEquals(tString2, RetVal);

        split1 = tString2.Split(',');
        RetVal = StringUtilities.JoinStr(split1, ';');
         //System.Debug(RetVal);
        System.AssertEquals(tString1, RetVal);

        split1 = tString1.Split(';');
        RetVal = StringUtilities.JoinStr(split1, ';');
        //System.Debug(RetVal);
         System.AssertEquals(tString1, RetVal);
    }
    
    private static testMethod void runSU_QEqual()
    {
        string tString1 = 'My_Custom_Object__c';
        string tString2 = 'FinalValue';

        string ShouldBe = 'My_Custom_Object__c = \'FinalValue\'';
        string RetVal = StringUtilities.QEquals(tString1, tString2);
        //System.Debug(RetVal);
        System.AssertEquals(ShouldBe, RetVal);

        RetVal = StringUtilities.QEquals(tString1, null);
        System.AssertEquals(null, RetVal);

    }
    
    private static testMethod void testLongString()
    {
        string tString0 = 'Name';
         string tString1 = 'Home_Address';
        string tString2 = 'Home_City';
        string tString3 = 'Home_State';
        string tString4 = 'Home_Zip';
        string tString5 = 'Home_Phone';
         string tString6 = 'Primary_Email';
        string tString7 = 'Flag';
        
        string ShouldBe = 'Name || Home_Address, Home_City, Home_State Home_Zip || Phone: Home_Phone || Email: Primary_Email || Flags: Flag';
         string RetVal = StringUtilities.LongString(tString0, tString1, tString2, tString3, tString4, tString5, tString6, tString7);
        //System.Debug(RetVal);
        System.AssertEquals(ShouldBe, RetVal);
    }
     private static testMethod void runSU_QLike()
    {
        string tString1 = 'My_Custom_Object__c';
        string tString2 = 'F*nal*';

        string ShouldBe = 'My_Custom_Object__c Like \'F%nal%\'';
         string RetVal = StringUtilities.QLike(tString1, tString2);
        //System.Debug(RetVal);
        System.AssertEquals(ShouldBe, RetVal);

        RetVal = StringUtilities.QLike(tString1, null);
        System.AssertEquals(null, RetVal);

    }

    private static testMethod void testCapitalizeWord()
    {
        string first = 'lowercase';
        string expected = 'Lowercase';
        string fixed = StringUtilities.CapitalizeWord(first);
         System.assertEquals(expected, fixed);

        first = 'this is a lowercase sentence. this is the second sentence, which is also lowercase.';
        expected = 'This Is A Lowercase Sentence. This Is The Second Sentence, Which Is Also Lowercase.';
         fixed = StringUtilities.CapitalizeAllWords(first);
        System.assertEquals(expected, fixed);

    }

    private static testMethod void testExcapeApostrphe()
    {
        string first = 'low\'ercase';
         string expected = 'low\\\'ercase';
        System.Debug('Input String=' + first + ' Expected=' + expected);
        string fixed = StringUtilities.ExcapeApostrphe(first);
        System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
         System.assertEquals(expected, fixed);

        /*first = 'low\\\'ercase';
        expected = 'low\\\'ercase';
        System.Debug('Input String=' + first + ' Expected=' + expected);
         fixed = StringUtilities.ExcapeApostrphe(first);
        System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
        System.assertEquals(expected, fixed);
         */

        first = 'lowercase';
        expected = 'lowercase';
        System.Debug('Input String=' + first + ' Expected=' + expected);
        fixed = StringUtilities.ExcapeApostrphe(first);
         System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
        System.assertEquals(expected, fixed);

        first = 'low\'erc\'ase';
         expected = 'low\\\'erc\\\'ase';
        System.Debug('Input String=' + first + ' Expected=' + expected);
        fixed = StringUtilities.ExcapeApostrphe(first);
        System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
         System.assertEquals(expected, fixed);

        /*first = 'low\\\'erc\'ase';
        expected = 'low\\\'erc\\\'ase';
        System.Debug('Input String=' + first + ' Expected=' + expected);
         fixed = StringUtilities.ExcapeApostrphe(first);
        System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
        System.assertEquals(expected, fixed);
         */

        first = 'test';
        expected = 'test';
        System.Debug('Input String=' + first + ' Expected=' + expected);
        fixed = StringUtilities.ExcapeApostrphe(first);
         System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
        System.assertEquals(expected, fixed);

        first = '';
        expected = '';
         System.Debug('Input String=' + first + ' Expected=' + expected);
        fixed = StringUtilities.ExcapeApostrphe(first);
        System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
         System.assertEquals(expected, fixed);

        first = null;
        expected = null;
        System.Debug('Input String=' + first + ' Expected=' + expected);
        fixed = StringUtilities.ExcapeApostrphe(first);
         System.Debug('Input String=' + first + ' Expected=' + expected + ' fixed=' + fixed );
        System.assertEquals(expected, fixed);
    }

    private static testMethod void testFormatBytes()
     {
        string formatSize = StringUtilities.FormatBytes(1000);
        system.AssertEquals('1000 Bytes', formatSize);

        formatSize = StringUtilities.FormatBytes(1024);
        system.AssertEquals('1 KB', formatSize);

        formatSize = StringUtilities.FormatBytes(2044);
        system.AssertEquals('2 KB', formatSize);

        formatSize = StringUtilities.FormatBytes(30000000);
        system.AssertEquals('28.61 MB', formatSize);

    }
    /* private static testMethod void testCalculateLuminanceFromRGB()
    {
        //string RGBHexValue
        Integer IntValues = stringUtilities.CalculateLuminanceFromRGB();
        decimal RedVal = ((decimal)IntValues[0]) / 255;
         decimal GreenVal = ((decimal)IntValues[1]) / 255;
        decimal BlueVal = ((decimal)IntValues[2]) / 255;
        integer calculateLuminance = StringUtilities.testCalculateLuminanceFromRGB(IntValues[0] / 255);
         system.AssertEquals(RedVal, calculateLuminance);
        calculateLuminance = StringUtilities.testCalculateLuminanceFromRGB(IntValues[1] / 255);
        system.AssertEquals(RedVal, calculateLuminance);
        calculateLuminance = StringUtilities.testCalculateLuminanceFromRGB(IntValues[2] / 255);
         system.AssertEquals(RedVal, calculateLuminance);
    } */
        
    private static testMethod void testParseMultipicklist()
    {
        string TestString = ' First; Second   ; Fourteen';
         list<string> ReturnList = StringUtilities.ParseMultiPicklist(TestString);

        for(string RetItem : ReturnList)
        {
            system.Assert(TestString.Contains(RetItem));
            system.Assert(!RetItem.StartsWith(' '));
             system.Assert(!RetItem.EndsWith(' '));
        }
    }

    private static testMethod void testStringCompare()
    {
        string TestString1 = ' First; Second   ; Fourteen';
         string TestString2 = ' First; Second   ; Fourteen';
        system.Assert(StringUtilities.StringCompare(TestString1, TestString2));

        TestString1 = '';
        system.Assert(!StringUtilities.StringCompare(TestString1, TestString2));

        TestString2 = null;
        system.Assert(StringUtilities.StringCompare(TestString1, TestString2));

    }

    private static testMethod void testFindStateCode()
    {
        string state = 'alabama';
         string result = StringUtilities.FindStateCode(state);
        system.assertEquals('AL', result);
        
        string result2 = StringUtilities.FindStateName(result);
        system.assertEquals(state, result2.toLowerCase());

        state = 'somethingwrong';
        result = StringUtilities.FindStateCode(state);
        system.assertEquals(state, result);

    }
    private static testMethod void testFormatZipCode2()
     {
        string state = '43213';
        string result = StringUtilities.FormatZipCode(state);
        system.assertEquals(state, result);
        
        state = '43123-?';
        result = StringUtilities.FormatZipCode(state);
         system.assertEquals('43123', result);

        state = 'somethingwrong';
        result = StringUtilities.FormatZipCode(state);
        system.assertEquals(state.toUpperCase(), result);

    }   

}