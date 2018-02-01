public with sharing class ProjectCreateScreenController {

    public AcctSeed__Project__c mysObject{get;set;}
    public AcctSeed__Project_Task__c TaskSelector{get;set;}
    public String IsClone{get;set;}
    public List<MilestoneSetupWrapper> MSWrapList{get;set;}
    public List<SelectOption> CloneSelList{get;set;}
    public List<SelectOption> CloneSelList1{get;set;}
    public ID CloneProject{get;set;}
    public List<AcctSeed__Project__c> TemplateProjectList{get;set;}
    public Date SelectedStartDate{get;set;}
    public Integer NumOfRecsToClone{get;set;}
    public String CloneProjectsPrefix{get;set;}
    public Milestone_Setup__c MilestoneSelector{get;set;}
    //public Account SelectedAccount;

    public class MilestoneSetupWrapper{
        public Milestone_Setup__c Milestone{get;set;}
        public Boolean Selected{get;set;}
        public MilestoneSetupWrapper(Milestone_Setup__c MS){
            Milestone = MS;
            Selected = MS.Default__c;        
        }
    }

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public ProjectCreateScreenController(ApexPages.StandardController stdController) {
        this.mysObject = (AcctSeed__Project__c)stdController.getRecord();
        List<RecordType> SiteRecTypeList = [SELECT id, name FROM RecordType WHERE sobjecttype ='AcctSeed__Project__c' and isActive=true and name='site' ];
        mysobject.RecordTypeID = SiteRecTypeList[0].id;
        TaskSelector = new AcctSeed__Project_Task__c();
        IsClone = '';
        CloneSelList = new List<SelectOption>();
        CloneSelList1 = new List<SelectOption>();
        CloneSelList.Add(new SelectOption('',''));
        CloneSelList.Add(new SelectOption('Yes','Yes'));
        CloneSelList.Add(new SelectOption('No','No'));
        //NumOfRecsToClone = 1;
        MilestoneSelector = new Milestone_Setup__c();
        

        if(this.mysObject == null){
            mysObject = new AcctSeed__Project__c();
        }
        if(ApexPages.currentPage().getParameters().get('CF00N6A0000098Zr6_lkid') != null){
           // SelectedAccount = [select id, name from Account WHERE 
            //    Id = :ApexPages.currentPage().getParameters().get('CF00N6A000004X5IQ_lkid')];
            mysObject.AcctSeed__Account__c = ApexPages.currentPage().getParameters().get('CF00N6A0000098Zr6_lkid');
            getMilestonesForAccount();
        }    

        if(ApexPages.currentPage().getParameters().get('CF00N6A000004X5IR_lkid') != null){
           // SelectedAccount = [select id, name from Account WHERE 
            //    Id = :ApexPages.currentPage().getParameters().get('CF00N6A000004X5IQ_lkid')];
            mysObject.AcctSeed__Opportunity__c = ApexPages.currentPage().getParameters().get('CF00N6A000004X5IR_lkid');           
        }          

    }
    public void getMilestonesForAccount(){
        System.debug(mysObject.AcctSeed__Account__c);
       
        List<Milestone_Setup__c> MSCList = [SELECT id, name, Default__c,Milestone_Description__c, 
        Milestone_Carrier_Id_del__c, Milestone_Project_Phase__c, Predecessor1__r.Name, Duration_Days__c, Milestone_Project_Phase__r.Name,Billable__c, Product__c, Sort_Order__c, Vendor_Product__c
            FROM Milestone_Setup__c WHERE Account__c = :mysObject.AcctSeed__Account__c AND Jurisdiction__c = :MilestoneSelector.Jurisdiction__c AND Project_Type__c = :MilestoneSelector.Project_Type__c 
                order by Sort_Order__c ];
        MSWrapList = new List<MilestoneSetupWrapper>();
        for(Milestone_Setup__c MS : MSCList){
            System.debug(Ms.Default__c);
            MSWrapList.add(new MilestoneSetupWrapper(MS));
        }
        //return MSWrapList;
    }

     public void getTemplateProjects(){
        //System.debug(mysObject.AcctSeed__Account__c);
        CloneSelList1.clear();
        System.debug('Account: '+mysObject.AcctSeed__Account__c);
        System.debug('Program: '+mysObject.Program__c);
       if(!String.isBlank(mysObject.AcctSeed__Account__c) && !String.isBlank(mysObject.Program__c)){
            for(AcctSeed__Project__c APC : [select id, name, GL_Labor_Account__c, AcctSeed__Account__r.name, Program__c, AcctSeed__Account__c,
                Program__r.name FROM AcctSeed__Project__c WHERE Template_Project__c = true AND AcctSeed__Account__c = :mysObject.AcctSeed__Account__c]){
                CloneSelList1.Add(new SelectOption(APC.id, APC.name));
            }
        }
        //return MSWrapList;
    }

    public PageReference Save(){ 
        Map<String,Date> PhaseToStartDateMap = new Map<String,Date>();
        Map<String,Date> PhaseToEndDateMap = new Map<String,Date>();

        List<Milestone_Project_Phase__c> PPhaseList = new List<Milestone_Project_Phase__c>();
        Set<String> PhaseSet = new Set<String>();
        for(MilestoneSetupWrapper MSW : MSWrapList){
            if(msw.Selected){
                PhaseSet.add(MSW.Milestone.Milestone_Project_Phase__r.Name);
            }
        }
        for(String s : PhaseSet){
            PPhaseList.add(new Milestone_Project_Phase__c(name=s ));
        }
        Map<ID, OpportunityLineItem> ProdOppLineMap = new Map<ID, OpportunityLineItem>();
        List<OpportunityLineItem> TempOppLineList = [SELECT ID, NAME, Unit_Price__c, Term__c, Product_Total_Price__c, Product2ID FROM OpportunityLineItem WHERE OpportunityId  = :mysObject.AcctSeed__Opportunity__c];

        for(OpportunityLineItem oppline : TempOppLineList){
            ProdOppLineMap.put(oppline.Product2Id, oppline);
        }
        //[select id, name from Milestone_Project_Phase__c order by Sort_Order__c];
        List<Project_Phase__c> PhaseList = new List<Project_Phase__c>();

        System.debug(SelectedStartDate);
        Map<String, AcctSeed__Project_Task__c> PTMap  = new Map<String, AcctSeed__Project_Task__c>();
        System.debug(mysObject.AcctSeed__Account__c);
        System.debug(mysObject.Program__c);
        System.debug(mysObject.Name);
        System.debug(mysObject.GL_Labor_Account__c);
        if((String.isBlank(mysObject.AcctSeed__Account__c) || String.isBlank(mysObject.Program__c) || String.isBlank(mysObject.Name)
        ) && (!Test.isRunningTest()) ) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account, Program, Project Name, and GL Account are required fields'));
            return null;
        }
         if(SelectedStartDate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start date is a required field'));
            return null;
        }
        List<RecordType> PSubTaskRecTypeList = [SELECT id, name FROM RecordType 
            WHERE sobjecttype='Project_SubTask__c' AND IsActive=true ];
        ID PTRecTypeActivtyID = null;
        ID PTRecTypeDeliverableID = null;
        for(RecordType RT : PSubTaskRecTypeList){
            if(RT.name == 'Activity')
                PTRecTypeActivtyID = RT.ID;
            else if(RT.name == 'Document Deliverable')
                PTRecTypeDeliverableID = RT.ID;
        }
        System.debug(PTRecTypeActivtyID);
        System.debug(PTRecTypeDeliverableID);
         
        Map<String, List<Milestone_Task_Setup__c>> MilestoneSetupToMilestoneTaskMap = new Map<String, List<Milestone_Task_Setup__c>>();
        mysObject.Template_Project__c = true;
        //Rollup project budgeted amounts to program level.  Use AcctSeed summary rollups at project level.
        List<AcctSeed__Project_Task__c> DefaultBudgetTaskList = [SELECT ID, NAME FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :mysobject.Program__c];
        mySobject.Program_Budget_Task__c = DefaultBudgetTaskList[0].ID;
        insert mysObject;



        for(Milestone_Project_Phase__c MPP : PPhaseList){
            PhaseList.add(new Project_Phase__c(name = MPP.Name, Project__c = mysobject.id, Forecasted_Start_Date__c=SelectedStartDate, Forecasted_End_Date__c = SelectedStartDate.addDays(7)));
        }
        Insert PhaseList;
        Map<String, Project_Phase__c> PPMap = new Map<String, Project_Phase__c>();
        for(Project_Phase__c PP :  PhaseList){
            PPMap.put(PP.name, PP);
        }
        System.debug(PPMap);
        List<AcctSeed__Project_Task__c> PTList = new List<AcctSeed__Project_Task__c>();
        for(MilestoneSetupWrapper msw : MSWrapList){
            if(msw.Selected){
                System.debug(MSW.Milestone.Billable__c);
                System.debug(MSW.Milestone.Milestone_Project_Phase__r.Name);
                system.debug(msw.Milestone.Duration_Days__c);
                system.debug(SelectedStartDate);
                PTList.add(new AcctSeed__Project_Task__c(AcctSeed__Project__c = mysObject.id, name = msw.Milestone.name,
                    /*AcctSeed__Labor_GL_Account__c = mysObject.GL_Labor_Account__c,*/ Description__c = msw.Milestone.Milestone_Description__c,
                    Milestone_Carrier_Id__c = MSW.Milestone.Milestone_Carrier_Id_del__c, MS_Predecessor_Name__c = msw.Milestone.Predecessor1__r.Name,
                    Forecasted_Start_Date__c = SelectedStartDate, Duration_Days__c = msw.Milestone.Duration_Days__c, 
                    Billable__c = MSW.Milestone.Billable__c, Baseline_Start_Date__c = SelectedStartDate, Baseline_End_Date__c =  SelectedStartDate.addDays(msw.Milestone.Duration_Days__c.intValue()),
                    AcctSeed__GL_Account_Variable_1__c = TaskSelector.AcctSeed__GL_Account_Variable_1__c,
                    Forecasted_End_Date__c = SelectedStartDate.addDays(msw.Milestone.Duration_Days__c.intValue()),
                    Is_New__c = true,
                    Milestone_Setup__c = MSW.Milestone.ID, AcctSeed__Sort_Order__c = MSW.Milestone.Sort_Order__c, 
                    Billable_Amount__c  = !ProdOppLineMap.containsKey(MSW.Milestone.Product__c) ? 0 : ProdOppLineMap.get(MSW.Milestone.Product__c).Unit_Price__c,
                    Product__c = MSW.Milestone.Milestone_Project_Phase__r.Name=='Vendor' ? MSW.Milestone.Vendor_Product__c : MSW.Milestone.Product__c, Project_Phase__c = PPMap.get(MSW.Milestone.Milestone_Project_Phase__r.Name).id,
                    AcctSeed__Budgeted_Revenue__c = !ProdOppLineMap.containsKey(MSW.Milestone.Product__c) ? 0 : ProdOppLineMap.get(MSW.Milestone.Product__c).Unit_Price__c,
                    Adjust_Successor_Forecast_Off_of_Actuals__c = true ));
                MilestoneSetupToMilestoneTaskMap.put(msw.Milestone.name, null);
            }
        }
        List<Milestone_Task_Setup__c> TempMSTaskList = [select id, name,Milestone_Setup__c,Milestone_Setup__r.Name,RecordType.Name from Milestone_Task_Setup__c 
            WHERE Milestone_Setup__r.Name = : MilestoneSetupToMilestoneTaskMap.keyset() order by Milestone_Setup__c];
        ID CurrentMSSetupID = null;

        for(Milestone_Task_Setup__c MST : TempMSTaskList){
            if(CurrentMSSetupID != MST.Milestone_Setup__c){          
                List<Milestone_Task_Setup__c> TList = new List<Milestone_Task_Setup__c>();
                MilestoneSetupToMilestoneTaskMap.put(MST.Milestone_Setup__r.Name, TList);
            }
            MilestoneSetupToMilestoneTaskMap.get(MST.Milestone_Setup__r.Name).add(MST);
            CurrentMSSetupID = MST.Milestone_Setup__c;
        }        
        insert PTList;

        PTList = [select id, name, Forecasted_End_Date__c, Forecasted_Start_Date__c, Project_Phase__r.Name, 
            AcctSeed__Project_Task__c.MS_Predecessor_Name__c,Duration_Days__c
         FROM AcctSeed__Project_Task__c WHERE ID in : PTList];

        MilestoneSetupToMilestoneTaskMap.remove(null);
        List<Project_SubTask__c> PTSubTaskList = new List<Project_SubTask__c>();
        for(AcctSeed__Project_Task__c APT : PTList){
            if(MilestoneSetupToMilestoneTaskMap.get(APT.name) != null)
                for(Milestone_Task_Setup__c MTS : MilestoneSetupToMilestoneTaskMap.get(APT.name)){
                    PTSubTaskList.add(new Project_SubTask__c( name=MTS.name, Project_Task__c = APT.ID,
                        RecordTypeID = MTS.RecordType.Name == 'Activity' ? PTRecTypeActivtyID : PTRecTypeDeliverableID));
                }
        }
        insert PTSubTaskList;
        for(AcctSeed__Project_Task__c APT : PTList){
            PTMap.put(APT.Name, APT);
        }
        System.debug(PTMap);
        for(AcctSeed__Project_Task__c APT : PTList){
            if(!String.isBlank(APT.MS_Predecessor_Name__c) && PTMap.get(APT.MS_Predecessor_Name__c)!=null)  {

                APT.Predecessor1__c = PTMap.get(APT.MS_Predecessor_Name__c).id;
                APT.Forecasted_Start_Date__c = PTMap.get(APT.MS_Predecessor_Name__c).Forecasted_End_Date__c;
                APT.Baseline_Start_Date__c = APT.Forecasted_Start_Date__c;
                APT.Forecasted_End_Date__c = APT.Forecasted_Start_Date__c.AddDays(APT.Duration_Days__c.intValue());
                APT.Baseline_End_Date__c = APT.Forecasted_End_Date__c;
                //Update PTMap with new date values
                PTMap.get(APT.Name).Forecasted_Start_Date__c = APT.Forecasted_Start_Date__c;
                PTMap.get(APT.Name).Forecasted_End_Date__c = APT.Forecasted_End_Date__c;
                if(APT.MS_Predecessor_Name__c == 'RECEIVE 100% CDS'){
                    System.debug('Task Name: ' + apt.Name);
                    System.debug('Predecessor End Date: '+ PTMap.get(APT.MS_Predecessor_Name__c).Forecasted_End_Date__c);
                    System.debug('Successor Start Date: '+ APT.Forecasted_Start_Date__c);
                }
                System.debug(APT.Project_Phase__r.Name);
                if(!PhaseToStartDateMap.containsKey(APT.Project_Phase__r.Name))
                    PhaseToStartDateMap.put(APT.Project_Phase__r.Name, APT.Forecasted_Start_Date__c);
                if(PhaseToStartDateMap.get(APT.Project_Phase__r.Name) > APT.Forecasted_Start_Date__c)
                    PhaseToStartDateMap.put(APT.Project_Phase__r.Name,APT.Forecasted_Start_Date__c);

                if(!PhaseToEndDateMap.containsKey(APT.Project_Phase__r.Name))
                    PhaseToEndDateMap.put(APT.Project_Phase__r.Name, APT.Forecasted_End_Date__c);
                if(PhaseToEndDateMap.get(APT.Project_Phase__r.Name) < APT.Forecasted_End_Date__c)
                    PhaseToEndDateMap.put(APT.Project_Phase__r.Name, APT.Forecasted_End_Date__c);

            }
        }
        update PTList;

        for(Project_Phase__c pp : PhaseList){
            pp.Forecasted_Start_Date__c = PhaseToStartDateMap.get(pp.name);
            pp.Forecasted_End_Date__c = PhaseToEndDateMap.get(pp.name);
        }
        update PhaseList;

        return new PageReference('/'+mysObject.id);
    }
    public PageReference redirect(){       
        if(ApexPages.currentPage().getParameters().get('RecordType') != '0000000000000000'){
            if(ApexPages.currentPage().getParameters().get('RecordType') =='0126A000000se4U'){
                if(ApexPages.currentPage().getParameters().get('CF00N6A0000098Zr6_lkid')!=null){
                    PageReference PR =  new PageReference('/a0i/e?nooverride=1');
                    PR.getParameters().put('CF00N6A000004X5IQ_lkid',ApexPages.currentPage().getParameters().get('CF00N6A0000098Zr6_lkid'));
                    PR.getParameters().put('CF00N6A000004X5IQ',ApexPages.currentPage().getParameters().get('CF00N6A0000098Zr6'));
                    PR.setRedirect(true);
                    return PR;
                }
                else
                    Return new PageReference('/a0i/e?nooverride=1');
            }
        }

        Return null;
    }
    /*public PageReference CloneProject(){
        Map<String,Date> PhaseToStartDateMap = new Map<String,Date>();
        Map<String,Date> PhaseToEndDateMap = new Map<String,Date>();
        if((String.isBlank(mysObject.AcctSeed__Account__c) || String.isBlank(mysObject.Program__c) || (String.isBlank(mysObject.Name) && String.isBlank(CloneProjectsPrefix))
        && (!Test.isRunningTest()) )) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account, Program, Project Name, and GL Account are required fields'));
            return null;
        }
        if(SelectedStartDate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start date is a required field'));
            return null;
        }
        if(!string.isBlank(mysObject.Name) && !String.isBlank(CloneProjectsPrefix)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Project name is required when number of clones is greater than 1. Otherwise Project prefix is required.'));
            return null;
        }
        if(NumOfRecsToClone == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Number of sites to clone is required.'));
            return null;
        }

        List<AcctSeed__Project__c> CloneProjsToInsert = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project_Task__c> CloneProjTasksToInsert = new List<AcctSeed__Project_Task__c>();
        List<Project_Phase__c> CloneProjPhasesToInsert = new List<Project_Phase__c>();

        List<Project_Phase__c> PPhaseList = [select id, name, Forecasted_End_Date__c, Forecasted_Start_Date__c from Project_Phase__c where Project__c = :CloneProject];
        List<Project_Phase__c> PListToInsert = new List<Project_Phase__c>();

        Map<String, AcctSeed__Project_Task__c> PTMap  = new Map<String, AcctSeed__Project_Task__c>();
        System.debug(CloneProject);
        AcctSeed__Project__c OriginalProject = [select  AcctSeed__Account__c, RecordTypeID,
        AcctSeed__Budgeted_Amount__c, AcctSeed__Budgeted_Hours__c, AcctSeed__Budgeted_Revenue__c, GL_Labor_Account__c, AcctSeed__Opportunity__c,
        Program__c, State__c,AcctSeed__Status__c,
        AcctSeed__Template_Project__c from AcctSeed__Project__c where id = :CloneProject ];

        //mysObject.AcctSeed__Labor_GL_Account__c = OriginalProject;
        mysObject.RecordTypeID = OriginalProject.RecordTypeID;
        //mysobject.AcctSeed__Labor_GL_Account__c = OriginalProject.AcctSeed__Labor_GL_Account__c;
        //mysobject.AcctSeed__Budgeted_Amount__c = OriginalProject.AcctSeed__Budgeted_Amount__c;
        //mysobject.AcctSeed__Budgeted_Hours__c = OriginalProject.AcctSeed__Budgeted_Hours__c;
        //mysobject.AcctSeed__Budgeted_Revenue__c = OriginalProject.AcctSeed__Budgeted_Revenue__c;
        mysobject.GL_Labor_Account__c = OriginalProject.GL_Labor_Account__c;
        mysobject.AcctSeed__Opportunity__c = OriginalProject.AcctSeed__Opportunity__c;
        mysobject.Program__c = OriginalProject.Program__c;
        //mysobject.AcctSeed__Project_Manager__c = OriginalProject.AcctSeed__Project_Manager__c;
        //mysobject.AcctSeed__Revenue_Recognition_Method__c = OriginalProject.AcctSeed__Revenue_Recognition_Method__c;
        mysobject.State__c = OriginalProject.State__c;
        mysobject.AcctSeed__Status__c = OriginalProject.AcctSeed__Status__c;
        mysobject.AcctSeed__Template_Project__c = false;
        insert mysObject;

        for(Project_Phase__c PP : PPhaseList){
            PListToInsert.add(new Project_Phase__c(Project__c = mysObject.id, Name = PP.Name, Forecasted_Start_Date__c = SelectedStartDate, Forecasted_End_Date__c=SelectedStartDate.addDays(7) ));
        }

        insert PListToInsert;

        Map<String, Project_Phase__c> PPMap = new Map<String, Project_Phase__c>();
        for(Project_Phase__c PP : PListToInsert){
            PPMap.put(PP.Name, PP);
        }

        System.debug('mysobject insert successful');
        List<AcctSeed__Project_Task__c> PTList = new List<AcctSeed__Project_Task__c>();
        List<AcctSeed__Project_Task__c> PTaskList = [select id, name, AcctSeed__Budgeted_Amount__c, AcctSeed__Budgeted_Hours__c,
            AcctSeed__Budgeted_Revenue__c, Category__c, AcctSeed__Client_Contact__c, AcctSeed__Display_in_Time_Card__c,
            AcctSeed__Duration__c, AcctSeed__End_Date__c, AcctSeed__GL_Account_Variable_1__c, AcctSeed__GL_Account_Variable_2__c,
            AcctSeed__GL_Account_Variable_3__c, AcctSeed__GL_Account_Variable_4__c, AcctSeed__Labor_GL_Account__c, Predecessor1__c,
            Predecessor2__c, Project_Phase__c, Project_Phase_Completion_Percent__c, AcctSeed__Responsibility__c,
            AcctSeed__Sort_Order__c, AcctSeed__Task_Report_Name__c, Predecessor1__r.Name,
            Predecessor1__r.Forecasted_End_Date__c,Forecasted_Start_Date__c,Duration_Days__c, Project_Phase__r.Name, Billable__c,Description__c
            FROM AcctSeed__Project_Task__c where AcctSeed__Project__c = :OriginalProject.ID ];
        for(AcctSeed__Project_Task__c APT : PTaskList){
            //AcctSeed__Project_Task__c TempTask = new AcctSeed__Project_Task__c();
            AcctSeed__Project_Task__c TempTask = new AcctSeed__Project_Task__c();
            
            TempTask.AcctSeed__Project__c = mysObject.ID;
            TempTask.Name = APT.name;
            TempTask.Description__c = APT.Description__c;
            TempTask.AcctSeed__Labor_GL_Account__c = APT.AcctSeed__Labor_GL_Account__c;
            TempTask.Category__c = APT.Category__c;
            TempTask.AcctSeed__Client_Contact__c = APT.AcctSeed__Client_Contact__c;
            TempTask.AcctSeed__Display_in_Time_Card__c = APT.AcctSeed__Display_in_Time_Card__c;
            //TempTask.AcctSeed__Duration__c = APT.AcctSeed__Duration__c;
            TempTask.AcctSeed__End_Date__c = APT.AcctSeed__End_Date__c;
            TempTask.AcctSeed__GL_Account_Variable_1__c = APT.AcctSeed__GL_Account_Variable_1__c;
            TempTask.AcctSeed__GL_Account_Variable_2__c = APT.AcctSeed__GL_Account_Variable_2__c;
            TempTask.AcctSeed__GL_Account_Variable_3__c = APT.AcctSeed__GL_Account_Variable_3__c;
            TempTask.AcctSeed__GL_Account_Variable_4__c = APT.AcctSeed__GL_Account_Variable_4__c;
            TempTask.AcctSeed__Labor_GL_Account__c = APT.AcctSeed__Labor_GL_Account__c;
            TempTask.Project_Phase__c = PPMap.get(APT.Project_Phase__r.Name).id;
            TempTask.AcctSeed__Responsibility__c = APT.AcctSeed__Responsibility__c;
            TempTask.AcctSeed__Sort_Order__c = APT.AcctSeed__Sort_Order__c;
            TempTask.MS_Predecessor_Name__c = APT.Predecessor1__r.Name;
            TempTask.Forecasted_Start_Date__c = SelectedStartDate;
            TempTask.Baseline_Start_Date__c = SelectedStartDate;            
            TempTask.Duration_Days__c = APT.Duration_Days__c;
            TempTask.Billable__c = APT.Billable__c;
            TempTask.Forecasted_End_Date__c = TempTask.Forecasted_Start_Date__c.addDays(TempTask.Duration_Days__c.intValue());
            TempTask.Baseline_End_Date__c =  TempTask.Forecasted_Start_Date__c.addDays(TempTask.Duration_Days__c.intValue());
            if(!PhaseToStartDateMap.containsKey(TempTask.Project_Phase__r.Name))
                    PhaseToStartDateMap.put(TempTask.Project_Phase__r.Name, TempTask.Forecasted_Start_Date__c);
            if(PhaseToStartDateMap.get(TempTask.Project_Phase__r.Name) > TempTask.Forecasted_Start_Date__c)
                PhaseToStartDateMap.put(TempTask.Project_Phase__r.Name,TempTask.Forecasted_Start_Date__c);

            if(!PhaseToEndDateMap.containsKey(TempTask.Project_Phase__r.Name))
                PhaseToEndDateMap.put(TempTask.Project_Phase__r.Name, TempTask.Forecasted_End_Date__c);
            if(PhaseToEndDateMap.get(TempTask.Project_Phase__r.Name) < TempTask.Forecasted_End_Date__c)
                PhaseToEndDateMap.put(TempTask.Project_Phase__r.Name, TempTask.Forecasted_End_Date__c);
            //TempAcct.AcctSeed__Task_Report_Name__c = APT.AcctSeed__Task_Report_Name__c;
            //TempAcct.AcctSeed__Utilization_Category__c = APT.AcctSeed__Utilization_Category__c;
            PTList.add(TempTask);
        }
        insert PTList;
         for(Project_Phase__c pp : PPhaseList){
            pp.Forecasted_Start_Date__c = PhaseToStartDateMap.get(pp.name);
            pp.Forecasted_End_Date__c = PhaseToEndDateMap.get(pp.name);
        }
         update PPhaseList;


        for(AcctSeed__Project_Task__c APT : PTList){
            PTMap.put(APT.Name, APT);
        }
        System.debug(PTMap);
        for(AcctSeed__Project_Task__c APT : PTList){
            if(!String.isBlank(APT.MS_Predecessor_Name__c) && PTMap.get(APT.MS_Predecessor_Name__c)!=null)  {
                APT.Predecessor1__c = PTMap.get(APT.MS_Predecessor_Name__c).id;
                APT.Forecasted_Start_Date__c = PTMap.get(APT.MS_Predecessor_Name__c).Forecasted_End_Date__c;
                APT.Forecasted_End_Date__c = PTMap.get(APT.MS_Predecessor_Name__c).Forecasted_End_Date__c.AddDays(APT.Duration_Days__c.intValue());
                APT.Baseline_Start_Date__c = APT.Forecasted_Start_Date__c;
                APT.Baseline_End_Date__c = APT.Forecasted_End_Date__c;
            }
        }
        update PTList;
        return new PageReference('/'+mysObject.id);
    }*/
    public PageReference CloneProject(){
         Map<String,Date> PhaseToStartDateMap = new Map<String,Date>();
        Map<String,Date> PhaseToEndDateMap = new Map<String,Date>();
        if((String.isBlank(mysObject.AcctSeed__Account__c) || String.isBlank(mysObject.Program__c) || (String.isBlank(mysObject.Name) && String.isBlank(CloneProjectsPrefix))
        && (!Test.isRunningTest()) )) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Account, Program, Project Name, and GL Account are required fields'));
            return null;
        }
        if(SelectedStartDate == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Start date is a required field'));
            return null;
        }
        if(!string.isBlank(mysObject.Name) && !String.isBlank(CloneProjectsPrefix)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Project name is required when number of clones is greater than 1. Otherwise Project prefix is required.'));
            return null;
        }
        if(NumOfRecsToClone == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Number of sites to clone is required.'));
            return null;
        }        

        List<Project_Phase__c> PPhaseList = [select id, name, Forecasted_End_Date__c, Forecasted_Start_Date__c, Project__c from Project_Phase__c where Project__c = :CloneProject];

        Map<ID, OpportunityLineItem> ProdOppLineMap = new Map<ID, OpportunityLineItem>();
        List<OpportunityLineItem> TempOppLineList = [SELECT ID, NAME, Unit_Price__c, Term__c, Product_Total_Price__c, Product2ID FROM OpportunityLineItem WHERE OpportunityId  = :mysObject.AcctSeed__Opportunity__c];

        for(OpportunityLineItem oppline : TempOppLineList){
            ProdOppLineMap.put(oppline.Product2Id, oppline);
        }



        List<Project_Phase__c> PListToInsert = new List<Project_Phase__c>();
        List<AcctSeed__Project__c> CloneProjsToInsert = new List<AcctSeed__Project__c>();
        List<AcctSeed__Project_Task__c> CloneProjTasksToInsert = new List<AcctSeed__Project_Task__c>();
        List<Project_Phase__c> CloneProjPhasesToInsert = new List<Project_Phase__c>();

        Map<String, AcctSeed__Project_Task__c> PTMap  = new Map<String, AcctSeed__Project_Task__c>();
        //System.debug(CloneProject);
        AcctSeed__Project__c OriginalProject = [select  AcctSeed__Account__c, RecordTypeID,
        AcctSeed__Budgeted_Amount__c, AcctSeed__Budgeted_Hours__c, AcctSeed__Budgeted_Revenue__c, GL_Labor_Account__c, AcctSeed__Opportunity__c,
        Program__c, State__c,AcctSeed__Status__c,
        AcctSeed__Template_Project__c from AcctSeed__Project__c where id = :CloneProject ];
        
        List<AcctSeed__Project_Task__c> PTaskList = [select id, name, AcctSeed__Budgeted_Amount__c, AcctSeed__Budgeted_Hours__c,
            AcctSeed__Budgeted_Revenue__c, Category__c, AcctSeed__Client_Contact__c, AcctSeed__Display_in_Time_Card__c,
            AcctSeed__Duration__c, AcctSeed__End_Date__c, AcctSeed__GL_Account_Variable_1__c, AcctSeed__GL_Account_Variable_2__c,
            AcctSeed__GL_Account_Variable_3__c, AcctSeed__GL_Account_Variable_4__c, AcctSeed__Labor_GL_Account__c, Predecessor1__c,
            Predecessor2__c, Project_Phase__c, Project_Phase_Completion_Percent__c, AcctSeed__Responsibility__c,
            AcctSeed__Sort_Order__c, AcctSeed__Task_Report_Name__c, Predecessor1__r.Name,
            Predecessor1__r.Forecasted_End_Date__c,Forecasted_Start_Date__c,Duration_Days__c, Project_Phase__r.Name, Billable__c,Description__c, AcctSeed__Project__c,Product__c,Adjust_Successor_Forecast_Off_of_Actuals__c
            FROM AcctSeed__Project_Task__c where AcctSeed__Project__c = :OriginalProject.ID ORDER BY AcctSeed__Project__c, AcctSeed__Sort_Order__c];

        //Rollup project budgeted amounts to program level.  Use AcctSeed summary rollups at project level.
        List<AcctSeed__Project_Task__c> DefaultBudgetTaskList = [SELECT ID, NAME FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :mysobject.Program__c];
        mySobject.Program_Budget_Task__c = DefaultBudgetTaskList[0].ID;

        for(Integer i=0; i<NumOfRecsToClone; i++){
            mysObject = OriginalProject.clone(false,false,false,false);
            mysObject.Name = CloneProjectsPrefix + String.valueOf(i);
            mysobject.AcctSeed__Template_Project__c = false;
            mySobject.Program_Budget_Task__c = DefaultBudgetTaskList[0].ID;
            CloneProjsToInsert.add(mysobject);
        }

        insert CloneProjsToInsert;      

        Map<ID, List<Project_Phase__c>> ProjectToPhasesMap = new Map<ID, List<Project_Phase__c>>();
        for(AcctSeed__Project__c ap : CloneProjsToInsert){
            for(Project_Phase__c pp : PPhaseList){
                Project_Phase__c TempPhase = new Project_Phase__c(name=PP.Name, Project__c = ap.id);                
                CloneProjPhasesToInsert.add(TempPhase);
            }
        }
        insert CloneProjPhasesToInsert;

        for(Project_Phase__c PP : CloneProjPhasesToInsert){
            if(!ProjectToPhasesMap.containsKey(PP.Project__c))
                ProjectToPhasesMap.put(PP.Project__c, new List<Project_Phase__c>());
            ProjectToPhasesMap.get(PP.Project__c).add(PP);
        }

       for(AcctSeed__Project__c Proj : CloneProjsToInsert){
            for(AcctSeed__Project_Task__c apt : PTaskList){
                for(Project_Phase__c PP : ProjectToPhasesMap.get(Proj.ID)){
                    if(PP.Name == apt.Project_Phase__r.Name ){
                        AcctSeed__Project_Task__c TempTask = apt.Clone(false, false, false, false);
                        TempTask.AcctSeed__Project__c = Proj.id;
                        TempTask.Project_Phase__c = PP.ID;
                        TempTask.AcctSeed__End_Date__c = null;
                        TempTask.Acctseed__Start_Date__c = null;                       
                        TempTask.Forecasted_Start_Date__c = SelectedStartDate;
                        TempTask.Forecasted_End_Date__c = SelectedStartDate.addDays(TempTask.Duration_Days__c.intValue());
                        TempTask.MS_Predecessor_Name__c = APT.Predecessor1__r.Name;
                        TempTask.Is_New__c = true;
                        TempTask.Billable_Amount__c  = !ProdOppLineMap.containsKey(apt.Product__c) ? 0 : ProdOppLineMap.get(apt.Product__c).Unit_Price__c;
                        TempTask.Product__c = apt.Product__c;
                        TempTask.Adjust_Successor_Forecast_Off_of_Actuals__c = apt.Adjust_Successor_Forecast_Off_of_Actuals__c;
                        TempTask.AcctSeed__Budgeted_Revenue__c = TempTask.Billable_Amount__c;
                        CloneProjTasksToInsert.add(TempTask);
                    }
                }
            }
        }

        insert CloneProjTasksToInsert;

       for(AcctSeed__Project_Task__c APT : CloneProjTasksToInsert){
            PTMap.put(APT.Name+APT.AcctSeed__Project__c, APT);
        }

        for(AcctSeed__Project_Task__c APT : CloneProjTasksToInsert){
            if(!String.isBlank(APT.MS_Predecessor_Name__c) && PTMap.get(APT.MS_Predecessor_Name__c+APT.AcctSeed__Project__c)!=null)  {
                System.debug('Enter line 502.' + APT.AcctSeed__Project__c);
                APT.Predecessor1__c = PTMap.get(APT.MS_Predecessor_Name__c+APT.AcctSeed__Project__c).id;             
            }
        }
        ID CurrentProjID = null;
        List<AcctSeed__Project_Task__c> ProjTaskUpdateList = new List<AcctSeed__Project_Task__c>();
        for(AcctSeed__Project_Task__c apt : CloneProjTasksToInsert){
            if(CurrentProjID == null || CurrentProjID != apt.AcctSeed__Project__c && apt.AcctSeed__Sort_Order__c == 1)
                ProjTaskUpdateList.add(apt);
        }
        update ProjTaskUpdateList;// When creating multiple clones if there are over 200 tasks the trigger method will only update the first batch of 200.  
        //ProjectTaskTriggerHandler PTTH = new ProjectTaskTriggerHandler();//The other tasks won't be picked up in trigger context.  Must call trigger method outside of trigger to process all tasks
        //Map<ID, AcctSeed__Project_Task__c> TempMap = new Map<ID, AcctSeed__Project_Task__c>();
        //PTTH.CascadeTaskDateChanges(ProjTaskUpdateList, ProjTaskUpdateList, TempMap, TempMap);

        for(AcctSeed__Project__c Proj : CloneProjsToInsert){
            System.debug(Proj.Name);
            for(AcctSeed__Project_Task__c apt : CloneProjTasksToInsert){
                System.debug(apt.AcctSeed__Project__r.Name);
                for(Project_Phase__c PP : ProjectToPhasesMap.get(Proj.ID)){
                    if(PP.Name == apt.Project_Phase__r.Name && PP.Project__c == apt.AcctSeed__Project__c){
                        System.debug('enter line 519 phase date assignment: '+ Proj.Name);
                       if(!PhaseToStartDateMap.containsKey(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c))
                            PhaseToStartDateMap.put(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c, APT.Forecasted_Start_Date__c);
                        if(PhaseToStartDateMap.get(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c) > APT.Forecasted_Start_Date__c)
                            PhaseToStartDateMap.put(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c,APT.Forecasted_Start_Date__c);

                        if(!PhaseToEndDateMap.containsKey(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c))
                            PhaseToEndDateMap.put(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c, APT.Forecasted_End_Date__c);
                        if(PhaseToEndDateMap.get(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c) < APT.Forecasted_End_Date__c)
                            PhaseToEndDateMap.put(APT.Project_Phase__r.Name+APT.AcctSeed__Project__c, APT.Forecasted_End_Date__c);
                    }
                }
            }
        }
        

        for(Project_Phase__c pp : CloneProjPhasesToInsert){
            pp.Forecasted_Start_Date__c = PhaseToStartDateMap.get(pp.name+pp.Project__c);
            pp.Forecasted_End_Date__c = PhaseToEndDateMap.get(pp.name+pp.Project__c);
        }
        update CloneProjPhasesToInsert;
        return new PageReference('/'+ CloneProjsToInsert[0].id);
    }

   
}