public class JSONRoundTripSample {
  
    public class InvoiceStatement {
        Long invoiceNumber;
        Datetime statementDate;
        Decimal totalPrice;
        
        public InvoiceStatement(Long i, Datetime dt, Decimal price)
        {
            invoiceNumber = i;
            statementDate = dt;
            totalPrice = price;
        }
    }
    
    public static void SerializeRoundtrip() {
        Datetime dt = Datetime.now(); 
        // Create a few invoices. 
    
        InvoiceStatement inv1 = new InvoiceStatement(1,Datetime.valueOf(dt),1000);
        InvoiceStatement inv2 = new InvoiceStatement(2,Datetime.valueOf(dt),500);
        // Add the invoices to a list. 
    
        List<InvoiceStatement> invoices = new List<InvoiceStatement>();
        invoices.add(inv1);
        invoices.add(inv2);
              
        // Serialize the list of InvoiceStatement objects. 
    
        String JSONString = JSON.serialize(invoices);
        System.debug('Serialized list of invoices into JSON format: ' + JSONString);
        
        // Deserialize the list of invoices from the JSON string. 
    
        List<InvoiceStatement> deserializedInvoices = 
          (List<InvoiceStatement>)JSON.deserialize(JSONString, List<InvoiceStatement>.class);
        System.assertEquals(invoices.size(), deserializedInvoices.size());
        Integer i=0;
        for (InvoiceStatement deserializedInvoice :deserializedInvoices) {
            system.debug('Deserialized:' + deserializedInvoice.invoiceNumber + ',' 
            + deserializedInvoice.statementDate.formatGmt('MM/dd/yyyy  HH:mm:ss.SSS')
            + ', ' + deserializedInvoice.totalPrice); 
            system.debug('Original:' + invoices[i].invoiceNumber + ',' 
            + invoices[i].statementDate.formatGmt('MM/dd/yyyy  HH:mm:ss.SSS') 
            + ', ' + invoices[i].totalPrice); 
            i++;
        }
    }
}