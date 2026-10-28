// Contains commonly used operations that are performed on strings or on objects to build strings.
global class StringUtilities
{
    // Tries to convert the passed in string to a state code.
    // If not found, just returns the value that was passed in.
     public static string FindStateCode(string inputState)
    {
        if(string.IsBlank(inputState) || !USStateCodes.containsKey(inputState.toLowerCase().trim()))
            return inputState;
        else
             return USStateCodes.get(inputState.toLowerCase().trim());
    }
    public static string FindStateName(string inputCode)
    {
        if(string.IsBlank(inputCode) )
            return inputCode;
         for(string nm : USStateCodes.Keyset())
        {
            string code = USStateCodes.get(nm);
            if (code == inputCode)
                return CapitalizeAllWords(nm);
        }
        return null;
     }

    public static final Map<string,string> USStateCodes = new Map<string,string>
    {
        null=>'',
        ''=>'',
        'alabama'=>'AL',
         'alaska'=>'AK',
        'arizona'=>'AZ',
        'arkansas'=>'AR',
        'california'=>'CA',
        'colorado'=>'CO',
         'connecticut'=>'CT',
        'delaware'=>'DE',
        'district of columbia'=>'DC',
        'florida'=>'FL',
        'georgia'=>'GA',
         'hawaii'=>'HI',
        'idaho'=>'ID',
        'illinois'=>'IL',
        'indiana'=>'IN',
        'iowa'=>'IA',
         'kansas'=>'KS',
        'kentucky'=>'KY',
        'louisiana'=>'LA',
        'maine'=>'ME',
        'maryland'=>'MD',
         'massachusetts'=>'MA',
        'michigan'=>'MI',
        'minnesota'=>'MN',
        'mississippi'=>'MS',
        'missouri'=>'MO',
         'montana'=>'MT',
        'nebraska'=>'NE',
        'nevada'=>'NV',
        'new hampshire'=>'NH',
        'new jersey'=>'NJ',
         'new mexico'=>'NM',
        'new york'=>'NY',
        'north carolina'=>'NC',
        'north Dakota'=>'ND',
        'ohio'=>'OH',
         'oklahoma'=>'OK',
        'oregon'=>'OR',
        'pennsylvania'=>'PA',
        'rhode island'=>'RI',
        'south carolina'=>'SC',
         'south dakota'=>'SD',
        'tennessee'=>'TN',
        'texas'=>'TX',
        'utah'=>'UT',
        'vermont'=>'VT',
         'virginia'=>'VA',
        'washington'=>'WA',
        'west Virginia'=>'WV',
        'wisconsin'=>'WI',
        'wyoming'=>'WY',
         'alberta'=>'AB',
        'british Columbia'=>'BC',
        'manitoba'=>'MB',
        'new brunswick'=>'NB',
        'newfoundland and labrador'=>'NL',
         'northwest territories'=>'NT',
        'nova scotia'=>'NS',
        'nunavut'=>'NU',
        'ontario'=>'ON',
        'prince edward island'=>'PE',
         'quebec'=>'QC',
        'saskatchewan'=>'SK',
        'yukon'=>'YT'
        }
    ;
    public static string FormatZipCode(string zip)
    {
         // exit immediately if null
        if(zip == null) return null;

        string newZip = zip.trim();
        newZip = RemoveNonAlphaNumerics(newZip);
        newZip = newZip.toUpperCase();

        // We don't do any validation here - just formatting. If it's not 5,6, or 9 characters
         // we're not doing anything with it.  If it's 5 characters we're assuming it's a valid 5 digit
        // US zip and we're also done with it.  If it's length 9 we're going to assume it's valid
         // 9 digit US zip and format for that.  If it's length 6 we're going to assume it's Canadian
        // and format for that.
        if(newZip.length() == 9)
            newZip = newZip.substring(0,5) + '-' + newZip.substring(5,9);

        if(newZip.length() == 6)
            newZip = newZip.substring(0,3) + ' ' + newZip.Substring(3,6);

        return newZip;
    }
    private static final Map<String,Integer> hexMap = new Map<String,Integer>();
     static
    {
        hexMap.put('0',0);
        hexMap.put('1',1);
        hexMap.put('2',2);
        hexMap.put('3',3);
        hexMap.put('4',4);
        hexMap.put('5',5);
         hexMap.put('6',6);
        hexMap.put('7',7);
        hexMap.put('8',8);
        hexMap.put('9',9);
        hexMap.put('A',10);
        hexMap.put('B',11);
         hexMap.put('C',12);
        hexMap.put('D',13);
        hexMap.put('E',14);
        hexMap.put('F',15);
        hexMap.put('a',10);
        hexMap.put('b',11);
         hexMap.put('c',12);
        hexMap.put('d',13);
        hexMap.put('e',14);
        hexMap.put('f',15);
    }

    // Given an RGB hex code like 'FFFFFF' will return three integer values like 255,255,255
     public static List<Integer> hexToInt(String hex)
    {
        List<Integer> retVal = new List<Integer>();
        for(Integer i=0;i<hex.length();i+=2)
        {
            retVal.add( (hexMap.get(hex.substring(i,i+1)) * 16) + (hexMap.get(hex.substring(i+1,i+2))) );
         }
        return retVal;
    }

    public static boolean ValidZipCode(string InputZip)
    {
        if(InputZip == null || InputZip == '')
            return true;

        String USZipRegex = '(^\\d{5}(-\\d{4})?$)|(^[ABCEGHJKLMNPRSTVXY]{1}\\d{1}[A-Z]{1} *\\d{1}[A-Z]{1}\\d{1}$)';
         Pattern MyPattern = Pattern.compile(USZipRegex);

        // Then instantiate a new Matcher object "MyMatcher"
        Matcher MyMatcher = MyPattern.matcher(InputZip);

        return MyMatcher.matches();
     }

    public static string FormatBytes( long bytes)
    {
        // 1024 is the bibyte standard, but windows still uses it
        double scale = 1024;

        List<string> orders = new List<string>{ 'GB', 'MB', 'KB', 'Bytes'};
         double orderSize = orders.size()-1;
        double max = (double) Math.Pow(scale, orderSize);

        for(string orderName : orders)
        {
            if ( bytes >= max )
            {
                 integer rounding = 2;
                if(orderName == 'KB')
                    rounding = 0;
                decimal sizeRaw = (bytes/max);
                string size = sizeRaw.setScale(rounding).stripTrailingZeros().toPlainString();
                 List<string> args = new List<string>{size, orderName};
                return string.Format( '{0} {1}', args);
            }

            max /= scale;
        }
        return '0 Bytes';
     }

    // The Missing 'Join' Method
    // Takes a list of strings, and joins them together with the given
    // Divider string
    // JH 3/19/2013 - Salesforce now has support for this!
    global static string JoinStr(List<String> inList, string divider)
     {
        if (inList == null || divider == null)
            return '';
        return string.join(inList, divider);
        
    }

    // Pass in a value like #FFFFFF and this will give the luminance on a scale of 0 to 1.
     // Useful to figure out if the color is 'dark' (0) or 'light' (1)
    public static decimal CalculateLuminanceFromRGB(string RGBHexValue)
    {
        try
        {
            // Calculate the luminance.  If >.5, show dark text.
             List<integer> IntValues = stringUtilities.hexToInt(RGBHexValue.replace('#',''));

            decimal RedVal = ((decimal)IntValues[0]) / 255;
            decimal GreenVal = ((decimal)IntValues[1]) / 255;
             decimal BlueVal = ((decimal)IntValues[2]) / 255;
            return  0.3 * RedVal + 0.59 * GreenVal + 0.11 * BlueVal;
            } catch (exception ex)
            {
                return 1;
            }
         }

        // The Missing 'Join' Method
        // Takes a list of strings, and joins them together with the given
        // Devider string
        global static string JoinStr(Set<String> inList, string divider)
         {
            return JoinStr(new list<string>( inList ),divider);
        }
        global static string JoinStr(Set<ID> inList, string divider)
        {
            string outstring = '';
             if (inList == null || inList.Size() == 0) return outstring;
            for (ID item : inList)
            {
                if (item != null)
                    outstring += item + divider;
            }
             if (outstring.length() > 0)
            {
                outstring = outstring.substring(0, outstring.length() - divider.length());
            }
            return outstring;
        }
        global static string MakeIDList(set<ID> objectIDs)
         {
            string joined = JoinStr(objectIDs, '\',\'');
            return '(\'' + joined + '\')';
        }

        //This function takes a whole set of Field Names and places them in a list
         // To later add to a query string
        global static string BuildFieldNameList(set<string> FieldList)
        {
            string FieldNames = string.Join(new list<string>(FieldList), ',');
             //Special case for Releatedlists
            integer startpoint = FieldNames.indexOf('__r[');
            integer stoppoint = FieldNames.indexOf('].');
            if(startpoint < stoppoint)
             {
                FieldNames = '';
                map<string, set<string>> RelatedLists = new map<string, set<string>>();
                for (string field : FieldList)
                 {
                    startpoint = field.indexOf('__r[');
                    stoppoint = field.indexOf('].');
                    if(startpoint < stoppoint)
                    {
                         string RelatedObj = field.SubString(0, startpoint + 3);
                        string RelatedField = field.SubString(stoppoint + 2);
                        if (RelatedLists.ContainsKey(RelatedObj))
                             RelatedLists.get(RelatedObj).Add(RelatedField);
                        else
                            RelatedLists.put(RelatedObj, new set<string> { RelatedField });
                    }
                     else
                    {
                        FieldNames += field + ',';
                    }
                }

                for (string RelatedObj : RelatedLists.KeySet())
                 {
                    set<string> flds = RelatedLists.get(RelatedObj);
                    string fldList = string.Join(new list<string>(flds), ',');
                    FieldNames += '(Select ' + fldList + ' FROM ' + RelatedObj + '),';
                 }
                FieldNames = FieldNames.SubString(0, FieldNames.length() - 1);
                system.debug('@@@Combination FieldNames: ' + FieldNames);
            }
            return FieldNames;
         }

        // This method us used to build a section of a where clause
        // Not much but a handy little bugger
        global static string QEquals(string field, string target)
        {
            if (target == null) return null;
             return field + ' = \'' + target + '\'';
        }
        // This method us used to build a section of a where clause
        // Not much but a handy little bugger
        global static string QLike(string field, string target)
         {
            if (target == null) return null;
            String percent = target.replace('*', '%');
            return field + ' Like \'' + percent + '\'';
        }

        // Private method that does the real work
        global static string LongString(string Name, string Home_Address, string Home_City,
        string Home_State, string Home_Zip, string Phone_1,
        string Primary_Email, string Flag)
         {
            string pData = Name
                            + ' || ' + Home_Address
                            + ', ' + Home_City
                            + ', ' + Home_State
                             + ' ' + Home_Zip;

            string val = 'none';
            if (Phone_1 != null) val = Phone_1;
            pData += ' || Phone: ' + val;

            val = 'none';
             if (Primary_Email != null) val = Primary_Email;
            pData += ' || Email: ' + val;

            val = 'none';
            if (Flag != null) val = Flag;
            pData += ' || Flags: ' + val;

            return pdata;
        }

        global static string CapitalizeWord(string incoming)
        {
            if (incoming == null || incoming.length() == 0)
                return null;
             return incoming.capitalize();
        }

        global static string CapitalizeAllWords(string incoming)
        {
            if (incoming == null) return null;
            list<String> Words = incoming.split(' ');
             if (Words.size() <= 1) return CapitalizeWord(incoming);
            list<String> Fixed = new List<String>();
            for (String word : Words)
            {
                Fixed.add(CapitalizeWord(word));
             }
            return JoinStr(Fixed, ' ');
        }

        global static string RemoveNonAlphaNumerics(string InputString)
        {
            string uName = InputString.ReplaceAll('[^\\w]','');
             //White spaces
            uName = uName.ReplaceAll('\\s', '');
            return uName;
        }

        // Given a string from a multi-picklist, will return a List of the items in the picklist
         global static List<string> ParseMultiPicklist(string InputPicklist)
        {
            List<string> broken = InputPicklist.split(';');
            List<string>retVals = new List<string>();
             for(string item : broken)
            {
                item = item.trim();
                retVals.add(item);
            }
            retVals.sort();
            return retVals;
        }

        global static boolean StringCompare(string Existing, string NewOne)
        {
            boolean LeftEmpty = string.IsBlank(Existing);
            boolean RightEmpty = string.IsBlank(NewOne);
            boolean BothEmpty = (LeftEmpty && RightEmpty);
             if (BothEmpty) return true;
            boolean OneEmpty = (LeftEmpty != RightEmpty);
            if (OneEmpty) return false;
            return Existing.toUpperCase().Trim() == NewOne.toUpperCase().Trim();
         }

        global static string ExcapeApostrphe(string input)
        {
            // This now does more than escape apostrophes, so it has been renamed and redone.
            return SOQLEncode(input);
         }

        public static string SOQLEncode(string unencodedString)
        {
            if(unencodedString == null) return unencodedString;
            return string.escapeSingleQuotes(unencodedString.replace('\\','\\'));
         }

        // JH - just trying this out.  Not sure how effective it is yet.
        // http://salesforcesource.blogspot.com/2010/01/utilizing-apex-pattern-and-matcher.html
         public static string RemoveHTMLTags(string html)
        {
            if(html == null) return null;
            //first replace all <BR> tags with \n to support new lines and replace &nbsp; with normal spaces.
             string result = html.replaceAll('\n','').replaceAll('</tr>','</tr><br>').replaceAll('<br/>', '\n').replaceAll('<br />', '\n').replaceAll('<br>', '\n').replaceAll('&nbsp;',' ').replaceAll('\t','').replaceAll('&amp;','&');
             //result = result.replaceAll('\r','');

            // Remove excessive newlines.
            result = removeMultipleLines(result);

            //regular expression to match all HTML/XML tags
             string HTML_TAG_PATTERN = '<.*?>';

            // compile the pattern
            pattern myPattern = pattern.compile(HTML_TAG_PATTERN);

            // get your matcher instance
             matcher myMatcher = myPattern.matcher(result);

            //remove the tags
            result = myMatcher.replaceAll('');
            system.debug('RemovedHtmlTags:' + result);
             return result;
        }

        private static string removeMultipleLines(string input)
        {
            string MULTIPLE_NEWLINES_PATTERN = '(\\n){2,}';
            pattern multNewlinesPattern = pattern.compile(MULTIPLE_NEWLINES_PATTERN);
             matcher multNewLinesMatcher = multNewlinesPattern.matcher(input);
            return multNewLinesMatcher.replaceAll('\n\n');
        }

        public class StringUtilitiesException extends Exception {
     }
}