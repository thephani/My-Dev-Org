global class MortgageCalculator implements Process.Plugin {
    global Process.PluginResult invoke(Process.PluginRequest request) {
        Double amount = (Double) request.inputParameters.get('Amount');
        Double term = (Double) request.inputParameters.get('Term');
        // in addition to to adding the calculation below, to use this in the Visual Workflow Workbook, tutorial # 
        // a third input called "Rate" will need to be defined for the calculate quote step: the screen input field " 
        Double rate = (Double) request.inputParameters.get('Rate');
        Double monthlyrate = rate / (12 * 100);
        Double cMonthlyPayment = amount * (monthlyrate / (1 - Math.pow(1 + monthlyrate, - term)));
        Map < String, Object > result = new Map < String, Object > ();
        result.put('MonthlyPayment', cMonthlyPayment);
        return new Process.PluginResult(result);
    }
  
    global Process.PluginDescribeResult describe() {
        Process.PluginDescribeResult result = new Process.PluginDescribeResult();
        result.description = 'This plug-in generates a monthly payment quote given the term and amount.';
        result.tag = 'Mortgage Quote';
        result.inputParameters = new List < Process.PluginDescribeResult.InputParameter > {
            new Process.PluginDescribeResult.InputParameter('Amount', Process.PluginDescribeResult.ParameterType.DOUBLE, true), new Process.PluginDescribeResult.InputParameter('Term', Process.PluginDescribeResult.ParameterType.DOUBLE, true), new Process.PluginDescribeResult.InputParameter('Rate', Process.PluginDescribeResult.ParameterType.DOUBLE, true)
        };
        result.outputParameters = new List < Process.PluginDescribeResult.OutputParameter > {
            new Process.PluginDescribeResult.OutputParameter('MonthlyPayment', Process.PluginDescribeResult.ParameterType.DOUBLE)
        };
        return result;
    }
  
    public static testmethod void testAll() {
        MortgageCalculator plugin = new MortgageCalculator();
        Map < String, Object > inputParams = new Map < String, Object > ();
        Double amount = 500000;
        Double term = 360;
        Double rate = 5;
        inputParams.put('Amount', amount);
        inputParams.put('Term', term);
        inputParams.put('Rate', rate);
        Process.PluginRequest request = new Process.PluginRequest(inputParams);
        Process.PluginResult aresult = Plugin.invoke(request);
        Double monthlyAmount = (Double) aresult.outputParameters.get('MonthlyPayment');
        System.assertEquals(Math.roundToLong(monthlyAmount), 2684);
        Process.PluginDescribeResult describe = plugin.describe();
        System.assertEquals(describe.InputParameters.size(), 3);
        System.assertEquals(describe.InputParameters[0].name, 'Amount');
        System.assertEquals(describe.InputParameters[1].name, 'Term');
        System.assertEquals(describe.InputParameters[2].name, 'Rate');
        System.assertEquals(describe.OutputParameters.size(), 1);
        System.assertEquals(describe.OutputParameters[0].name, 'MonthlyPayment');
    }
}