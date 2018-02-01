@isTest(SeeAllData=true)
private class TestProjectCreateScreenController {
    
    @isTest static void test_method_one() {
        Map<ID, RecordType> ProjRecTypeMap = new Map<ID, RecordType>();
        List<RecordType> MSSubTaskList = [select id, name from RecordType where sobjectType='Milestone_Task_Setup__c' and IsActive = true];
        ID ActivityRecType;
        ID DocumentRecType;
        ID SiteRecType;
        ID ProgramRecType;

        for(RecordType r : MSSubTaskList){
            if(r.name == 'Activity')
                ActivityRecType = r.id;
            else
                DocumentRecType = r.id;
        }

        ProjRecTypeMap.putAll([select id, name from RecordType WHERE sobjectType = 'AcctSeed__Project__c' and IsActive =True]);
        for(RecordType r : ProjRecTypeMap.values()){
            if(r.name == 'Site')
                SiteRecType = r.id;
            else
                ProgramRecType = r.id;
        } 
        Account a = new Account(name='test');
        insert a;
        AcctSeed__GL_Account__c GLA = new AcctSeed__GL_Account__c(name='123', AcctSeed__Type__c='Expense', AcctSeed__Sub_Type_1__c = 'Labor' );
        insert GLA;
        AcctSeed__Project__c Prog = new AcctSeed__Project__c(name='ProgramTest', RecordTypeID = ProgramRecType, AcctSeed__Account__c = a.id );
        insert Prog;

        AcctSeed__Project__c Clone = new AcctSeed__Project__c(name='ProgramTest', RecordTypeID = SiteRecType, AcctSeed__Account__c = a.id, Template_Project__c = true );
        insert Clone;
        Milestone_Project_Phase__c MPP = new Milestone_Project_Phase__c(name='Feasability');
        insert MPP;
        Milestone_Setup__c MS = new Milestone_Setup__c(name ='test', Account__c = a.id, Duration_Days__c = 1, Milestone_Project_Phase__c = MPP.ID);
        insert MS;
        Milestone_Task_Setup__c MST = new Milestone_Task_Setup__c(name = 'test1', Milestone_Setup__c = MS.id, RecordTypeID=ActivityRecType);
        insert MST;
        Test.setCurrentPage(Page.ProjectEntryScreen);
        System.currentPageReference().getParameters().put('CF00N6A000004X5IQ_lkid', SiteRecType);

        AcctSeed__Project__c Prog1 = new AcctSeed__Project__c(name='ProgramTest', 
            RecordTypeID = SiteRecType, AcctSeed__Account__c = a.id );

        ApexPages.StandardController stdController = new ApexPages.StandardController(Prog1);
        ProjectCreateScreenController PES = new ProjectCreateScreenController(stdController);
        PES.mysObject.AcctSeed__Account__c = a.id;
        PES.mysObject.Program__c = Prog.ID;
        PES.mysObject.GL_Labor_Account__c = Prog.GL_Labor_Account__c;
        PES.getMilestonesForAccount();
        PES.mysObject.AcctSeed__Account__c = a.id;
        PES.mysObject.Program__c = Prog.ID;
        PES.mysObject.GL_Labor_Account__c = GLA.id;
        PES.mysObject.Name = 'testSite';    
        PES.SelectedStartDate = system.Today(); 
        PES.Save();
        //PES.CloneProject = Clone.id;
        //PES.CloneProject();
        
        //PES.Save();
        //PES.
    }   
    @IsTest 
    public static void test_method_two(){
        Map<ID, RecordType> ProjRecTypeMap = new Map<ID, RecordType>();
        List<RecordType> MSSubTaskList = [select id, name from RecordType where sobjectType='Milestone_Task_Setup__c' and IsActive = true];
        ID ActivityRecType;
        ID DocumentRecType;
        ID SiteRecType;
        ID ProgramRecType;

        for(RecordType r : MSSubTaskList){
            if(r.name == 'Activity')
                ActivityRecType = r.id;
            else
                DocumentRecType = r.id;
        }

        ProjRecTypeMap.putAll([select id, name from RecordType WHERE sobjectType = 'AcctSeed__Project__c' and IsActive =True]);
        for(RecordType r : ProjRecTypeMap.values()){
            if(r.name == 'Site')
                SiteRecType = r.id;
            else
                ProgramRecType = r.id;
        } 
        Account a = new Account(name='test');
        insert a;
        AcctSeed__GL_Account__c GLA = new AcctSeed__GL_Account__c(name='123', AcctSeed__Type__c='Expense', AcctSeed__Sub_Type_1__c = 'Labor' );
        insert GLA;
        AcctSeed__Project__c Prog = new AcctSeed__Project__c(name='ProgramTest', RecordTypeID = ProgramRecType, AcctSeed__Account__c = a.id );
        insert Prog;

        AcctSeed__Project__c Clone = new AcctSeed__Project__c(name='ProgramTest', RecordTypeID = SiteRecType, AcctSeed__Account__c = a.id, Template_Project__c = true );
        insert Clone;

        Project_Phase__c PP = new Project_Phase__c(name='Feasability', Project__c = Clone.id);
        insert PP;

        AcctSeed__Project_Task__c CloneTask = new AcctSeed__Project_Task__c(name='test1', AcctSeed__Project__c=Clone.id, AcctSeed__Labor_GL_Account__c = GLA.id,Forecasted_Start_Date__c = System.today(), 
            Forecasted_End_Date__c = System.today(), Duration_Days__c=1, Project_Phase__c = PP.ID );
        insert CloneTask;

        Milestone_Setup__c MS = new Milestone_Setup__c(name ='test', Account__c = a.id, Duration_Days__c=1);
        insert MS;
        Milestone_Task_Setup__c MST = new Milestone_Task_Setup__c(name = 'test1', Milestone_Setup__c = MS.id, RecordTypeID=ActivityRecType);
        insert MST;
        Test.setCurrentPage(Page.ProjectEntryScreen);
        System.currentPageReference().getParameters().put('CF00N6A000004X5IQ_lkid', SiteRecType);

        AcctSeed__Project__c Prog1 = new AcctSeed__Project__c(name='ProgramTest', 
            RecordTypeID = SiteRecType, AcctSeed__Account__c = a.id );

        ApexPages.StandardController stdController = new ApexPages.StandardController(Prog1);
        ProjectCreateScreenController PES = new ProjectCreateScreenController(stdController);
        PES.mysObject.AcctSeed__Account__c = a.id;
        PES.mysObject.Program__c = Prog.ID;
        PES.mysObject.GL_Labor_Account__c = GLA.id;
        PES.mysObject.Name = 'testSite';
        PES.CloneProject = clone.id;
        PES.SelectedStartDate = system.Today();
        PES.CloneProject();
    }
}