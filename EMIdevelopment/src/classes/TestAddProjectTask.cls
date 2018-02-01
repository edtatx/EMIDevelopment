@isTest(SeeAllData=true)
private class TestAddProjectTask {
	
	@isTest static void test_method_one() {
		Account a = new Account(name='test');
		insert a;

		AcctSeed__GL_Account__c GL= new AcctSeed__GL_Account__c(name='123', AcctSeed__Type__c='Expense', AcctSeed__Sub_Type_1__c='Labor');
		insert GL;
		RecordType ProgramRecType = [select id, name from RecordType where sobjecttype = 'AcctSeed__Project__c' and name='Program'];
		RecordType SiteRecType = [select id, name from RecordType where sobjecttype = 'AcctSeed__Project__c' and name='Site'];
		AcctSeed__Project__c Program = new AcctSeed__Project__c(name='Marina', RecordTypeID=ProgramRecType.ID, AcctSeed__Account__c = a.id);
		insert Program;
		AcctSeed__Project__c Site = new AcctSeed__Project__c(name='Site1', Program__c = Program.id, RecordTypeID=SiteRecType.ID);
		insert Site;

		Project_Phase__c PP = new Project_Phase__c(name='Leasing', Project__c=Site.ID, Forecasted_Start_Date__c = System.today(), Forecasted_End_Date__c = System.Today()+1);
		insert PP;
		List<Milestone_Setup__c> MSList = new List<Milestone_Setup__c>();
		Milestone_Project_Phase__c MSPP = new Milestone_Project_Phase__c(name='Leasing');
		insert MSPP;
		MSList.add(new Milestone_Setup__c(name='test1', Milestone_Project_Phase__c = MSPP.ID, Duration_Days__c=1));
		MSList.add(new Milestone_Setup__c(name='test2', Milestone_Project_Phase__c = MSPP.ID, Duration_Days__c=1));
		insert MSList;


		List<AcctSeed__Project_Task__c> PTListToInsert = new List<AcctSeed__Project_Task__c>();
		PTListToInsert.add(new AcctSeed__Project_Task__c(name='1000', description__c= 'site walk', AcctSeed__Project__c=Site.ID, Forecasted_Start_Date__c = System.today(), 
			Forecasted_End_Date__c = System.Today().AddDays(2), AcctSeed__Labor_GL_Account__c=GL.ID, Duration_Days__c=1, Project_Phase__c=PP.ID ));
		insert PTListToInsert;
		Test.startTest();
		Test.setCurrentPage(Page.AddProjectTaskPage);
		System.currentPageReference().getParameters().put('CF00N6A000004X59P_lkid', Site.ID);

		ApexPages.StandardController stdController = new ApexPages.StandardController(PTListToInsert[0]);
		AddProjecTaskController APTC = new AddProjecTaskController(stdController);
		APTC.WrapperSelectList[0].Selected=true;
		APTC.Save();

		Test.stopTest();
	}
	
	
}