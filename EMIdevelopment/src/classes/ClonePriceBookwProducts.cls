public class ClonePriceBookwProducts {
    
    @AuraEnabled
    public static String getClonePB(String oldId) {
        system.debug('oldId ' + oldId);
        
        // Initialize setup variables
        String objectName = 'PriceBook2';  // modify as needed
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
           //System.debug('field: '+s);
        }
        
        // Manually add related object's fields that are needed.
        //query += 'Account.Name '; // modify as needed    'Account.Name';
        
        // Strip off the last comma if it exists.
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }
        
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id =  \''+ oldId +'\'  LIMIT 1'; // modify as needed   WHERE Id = \'test\' AND HasOpportunityLineItem = true LIMIT 1'; 
       	system.debug(query);    
        Pricebook2 p1 = database.query(query);
       	system.debug(p1);
        //Pricebook2 p1 = [select id, Name, IsStandard, IsActive, Description from Pricebook2 where id='<specify some Price book id>'];
        p1.Name=p1.Name + ' - CLONED';    
        Pricebook2 p2 = p1.clone(false, true);
        //insert p2;
            
        PricebookEntry[] pb1 = [Select UseStandardPrice, UnitPrice, ProductCode, Product2Id, Pricebook2Id, Name, IsActive From PricebookEntry where Pricebook2Id = :oldid]; 
            
        PricebookEntry[] pb2 = pb1.deepClone(false);
            
        for (PricebookEntry x : pb2)
        	{
               x.Pricebook2Id = p2.Id;
            }
        //insert pb2;
        //system.debug('newProdList ' + x);           
        //
        return p2.id;
        
   }

}