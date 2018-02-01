public class CloneOpportunityProducts {
    
    @AuraEnabled
    public static String getCloneOpp(String oldId) {
        //system.debug('oldId ' + oldId);
        
        // Initialize setup variables
        String objectName = 'Opportunity';  // modify as needed
        String query = 'SELECT';
        Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        
        // Grab the fields from the describe method and append them to the queryString one by one.
        for(String s : objectFields.keySet()) {
           query += ' ' + s + ', ';
           //System.debug('field: '+s);
        }
        
        // Manually add related object's fields that are needed.
        query += 'Account.Name '; // modify as needed    'Account.Name';
        
        // Strip off the last comma if it exists.
        if (query.subString(query.Length()-1,query.Length()) == ','){
            query = query.subString(0,query.Length()-1);
        }
        
        // Add FROM statement
        query += ' FROM ' + objectName;
        
        // Add on a WHERE/ORDER/LIMIT statement as needed
        query += ' WHERE Id =  \''+ oldId +'\'  LIMIT 1'; // modify as needed   WHERE Id = \'test\' AND HasOpportunityLineItem = true LIMIT 1'; 
        //system.debug(query);    
          
        Opportunity opp = database.query(query);
        //system.debug(opp);
        
        Opportunity newOpp = opp.clone(false, false, false, false);
        newOpp.Name=newOpp.Name+' - CLONED';
        insert newOpp;   
        if (opp.HasOpportunityLineItem == true) {
             List<OpportunityLineItem> products = [SELECT Id,
                                                  Quantity,
                                                  ListPrice,
                                                  Description,
                                                  Cost__c, 
                                                  Product2Id, 
                                                  ProductCode, 
                                                  UnitPrice
                                                  FROM OpportunityLineITem WHERE OpportunityId = :opp.Id];
/*            List<OpportunityLineItem> products = [SELECT Id,
                                                  Quantity,
                                                  Description,
                                                  Cost__c, 
                                                  Product2Id, 
                                                  ProductCode, 
                                                  UnitPrice
                                                  FROM OpportunityLineITem WHERE OpportunityId = :opp.Id]; */
            
            //system.debug('product List = ' +products);
    
            //system.debug('newOpp Id = ' + newOpp.Id);
            List<OpportunityLineItem> newProdList = new List<OpportunityLineItem>();
            for (OpportunityLineItem prod:products) {
                OpportunityLineItem newProd = prod.clone(false, false, false, false);
                newProd.OpportunityId = newOpp.id;
                //newProd.UnitPrice=0;
                newProdList.add(newProd);
            }
            insert(newProdList);
            //system.debug('newProdList ' + newProdList);           
        } // end if
        
        return newOpp.id;
        

   }

}