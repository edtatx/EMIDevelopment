@isTest(seealldata = true)

private class CloneOpportunityProductsTest {
    @isTest static void TestCloneOpportunity() {
        // Test data setup
        // Create one account with one opportunity by calling a utility method
    	Opportunity newopp = new Opportunity(name='Test Opp', closedate=system.today(), stagename='Qualification');
    	//system.debug('newopp: '+newopp);
        insert newopp;
        
        Id pricebookId = Test.getStandardPricebookId();

        //Create your product
        Product2 prod = new Product2(
             Name = 'Product X',
             ProductCode = 'Pro-X',
             isActive = true
        );
        insert prod;
        
        //Create your pricebook entry
        PricebookEntry pbEntry = new PricebookEntry(
             Pricebook2Id = pricebookId,
             Product2Id = prod.Id,
             UnitPrice = 100.00,
             IsActive = true
        );
        insert pbEntry;
        
        //create your opportunity line item.  This assumes you already have an opportunity created, called opp
        OpportunityLineItem oli = new OpportunityLineItem(
             OpportunityId = newopp.Id,
             Quantity = 5,
             PricebookEntryId = pbEntry.Id,
             TotalPrice = 10 * pbEntry.UnitPrice
        );
        insert oli;
       
        Opportunity opp = [Select id, name from opportunity where name = 'Test Opp'];
        //system.debug('retrieved opp: '+opp);
        Id oppid = opp.id;
        //system.debug('Id of creatd opp: '+oppid);
        
        // Perform test
        Test.startTest();
        CloneOpportunityProducts.getCloneOpp(oppid);
        //Opportunity veropp = [Select id, name from opportunity where name = 'Test Opp - CLONED'];
        //system.debug('cloned opp: '+veropp);
        //Database.DeleteResult result = Database.delete(accts[0], false);
        Test.stopTest();

        // Verify that the deletion should have been stopped by the trigger,
        // so check that we got back an error.
        //System.assert(!result.isSuccess());
        //System.assert(result.getErrors().size() > 0);
        //System.assertEquals('Cannot delete account with related opportunities.',
                             //result.getErrors()[0].getMessage());
    }
  
}