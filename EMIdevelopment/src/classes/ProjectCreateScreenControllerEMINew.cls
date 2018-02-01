public with sharing class ProjectCreateScreenControllerEMINew {
    @AuraEnabled
    public Opportunity oppinfo {get; set;}
     
    @AuraEnabled
    public Quote quoteinfo {get; set;}
    
    @AuraEnabled
    public List<QuoteLineItem> quotelineiteminfo {get; set;}
    
    @AuraEnabled
    public Account accountinfo {get; set;}
   
    @AuraEnabled
    public static ProjectCreateScreenControllerEMINew getInfo(Id recordId)
    {
        ProjectCreateScreenControllerEMINew result=new ProjectCreateScreenControllerEMINew();
        result.oppinfo=[select Id, Name, AccountId, Expected_Start_Date__c, SyncedQuoteId, OH_P__c from Opportunity WHERE Id=:recordId];
        result.quoteinfo=[select Id, Name, QuoteNumber, Expected_Project_Start_Date__c, Expected_Project_End_Date__c, Images__c, Installation__c, Features__c, Clarifications__c, Delivery__c, Equipment_Description__c, Features_and_Benefits_of_Recommendation__c, Load_Operation_Specification__c, Objectives__c, Recommendation__c, Terms_Conditions__c from Quote WHERE Id=:result.oppinfo.SyncedQuoteId];
        result.quotelineiteminfo=[select Id, QuoteId, Description, Product_Unit_Cost__c, Start_Date__c, Total_Cost__c, TotalPrice, Quantity, UnitPrice, Product_Detail_Category__c, End_Date__c from QuoteLineItem WHERE QuoteId=:result.oppinfo.SyncedQuoteId];
        result.accountinfo=[select Id, Name from Account WHERE Id=:result.oppinfo.AccountId];
        //system.debug('oppinfo: '+result.oppinfo);
        //system.debug('quoteinfo: '+result.quoteinfo);
        //system.debug('accountinfo:'+result.accountinfo);
        //system.debug('quotelineitem: '+result.quotelineiteminfo);
        return result;
    }
    
    @auraenabled
    public static Id createProjRecord(AcctSeed__Project__c projObj){
        insert projObj;
    return projObj.id;
    }
    
    @auraenabled
    public static Id createPhasesandTasks(Id rId, Id qId){ //rId = Project Record ID, qId = Quote Record ID
        //system.debug('I am about to create phases and tasks -- rId:'+rId);
        AcctSeed__Project__c projInfo = [ select Id, AcctSeed__Account__c,AcctSeed__Opportunity__c, Name, OHP__c, OH_P__c from AcctSeed__Project__c where id = :rId];
        AcctSeed__Project__c projInfoUpd = new AcctSeed__Project__c();
        Double projBudgetRev = 0.0;
        quote quoteinfo = [select Id, Name, Expected_Project_Start_Date__c, Expected_Project_End_Date__c, Clarifications__c, Delivery__c, Equipment_Description__c, Features__c, Features_and_Benefits_of_Recommendation__c, Installation__c, Load_Operation_Specification__c, Objectives__c, Recommendation__c, Terms_Conditions__c  from Quote WHERE Id=:qId];
        //system.debug('Quote Information: '+quoteinfo);
        List <quotelineitem> quotelineiteminfo = [select Id, QuoteId, Description, Product2Id, Product_Unit_Cost__c, Start_Date__c, Total_Cost__c, TotalPrice, Quantity, UnitPrice, Product_Detail_Category__c, End_Date__c from QuoteLineItem WHERE QuoteId=:qId];
        //system.debug('Quote Information: '+quotelineiteminfo);
        List <Project_Phase__c> phaseList = new List <Project_Phase__c>();
        Map <String, String> phasenametoname= new Map<String,String>();
        Set <String> foundPhases = new Set <String>();
        
        for(quotelineitem qli : quotelineiteminfo){ //build list of phases
            if (qli.Product_Detail_Category__c == null) {
                foundPhases.add('Other');
                phasenametoname.put('other','Other');
                //Phase fields: Start_Date__c,Sort_Order__c,Forecasted_Start_Date__c,Forecasted_End_Date__c,Percent_Complete__c,Project__c,Name
                system.debug('Added Other Phase');
            }
            else {
                if (foundPhases.size() == 0 ) {
                    foundPhases.add(qli.Product_Detail_Category__c.tolowercase());
                    phasenametoname.put(qli.Product_Detail_Category__c.tolowercase(),qli.Product_Detail_Category__c);
                }
                else if (!foundPhases.contains(qli.Product_Detail_Category__c.tolowercase())){
                	foundPhases.add(qli.Product_Detail_Category__c.tolowercase());
                    phasenametoname.put(qli.Product_Detail_Category__c.tolowercase(),qli.Product_Detail_Category__c);
                }
            	else {
                	system.debug('Phase already in List: did not add anything to the Phases List');
            	}
            }

    	} 
        //system.debug('phase set: '+foundPhases); 
        
        integer phaseSortOrder = 0;
        for (string s : foundPhases) {
            
            Project_Phase__c TempPhase = new Project_Phase__c (Name=s);
            Date minStartDate = date.today() + 3650;
        	Date maxEndDate = date.today() - 3650;
            
            phaseSortOrder = phaseSortOrder + 10;
            
            for(quotelineitem qli : quotelineiteminfo){
                if (qli.Product_Detail_Category__c.tolowercase() == s) {
                    if (qli.Start_Date__c != null)  
                        if (minStartDate > qli.Start_Date__c) {
                            minStartDate = qli.Start_Date__c;
                    }
                    if (qli.End_Date__c != null) {
                        if (maxEndDate < qli.End_Date__c){
                            maxEndDate = qli.End_Date__c;
                        }
                    }
                }
            } 
            if (minStartDate == date.today() + 3650){
                minStartDate = quoteinfo.Expected_Project_Start_Date__c;
            }
            if (maxEndDate == date.today() - 3650) {
                maxEndDate = quoteinfo.Expected_Project_End_Date__c;
            }
            TempPhase.Start_Date__c = minStartDate;
            TempPhase.End_Date__c = maxEndDate;
            String N = phasenametoname.get(s);
            //system.debug('name: '+N);
            phaseList.add(new Project_Phase__c(name = N, Project__c = rId, Forecasted_Start_Date__c=minStartDate, Forecasted_End_Date__c = maxEndDate, Percent_Complete__c = 0.0, Sort_Order__c = phaseSortOrder));
        }
        //system.debug('phaseList: '+phaseList);
        insert phaseList;
        
        //List <Project_Phase__c> projPhases = [select Id, Project__c from Project_Phase__c where Project__c=:rId];
        List <Project_Phase__c> phaseList1 = [select Id, Name, Start_Date__c, End_Date__c,Sort_Order__c,Forecasted_Start_Date__c,Forecasted_End_Date__c  from Project_Phase__c WHERE Project__c=:rId];
        //system.debug('phase1 list: '+phaseList1);
        Map<String, Project_Phase__c> ProjectToPhasesMap = new Map<String,Project_Phase__c>();
      
        for (Project_Phase__c phas1 : phaseList1){
            ProjectToPhasesMap.put(phas1.Name, phas1);
        }
        //system.debug('Phase Map: '+ProjectToPhasesMap);
        //

        List <AcctSeed__Project_Task__c> TaskList = new List<AcctSeed__Project_Task__c>();
        
        for(quotelineitem qli1 : quotelineiteminfo){
            AcctSeed__Project_Task__c TempTask = new AcctSeed__Project_Task__c();
            Product2 TempProd = [select Id, Description, ProductCode, Name, AcctSeed__GL_Account_Variable_1__c, AcctSeed__GL_Account_Variable_2__c, AcctSeed__GL_Account_Variable_3__c, AcctSeed__GL_Account_Variable_4__c  from Product2 WHERE Id=:qli1.Product2Id];
            
            TempTask.Billable__c = True;
            TempTask.Billable_Amount__c = qli1.TotalPrice;
            TempTask.AcctSeed__Budgeted_Amount__c = qli1.Total_Cost__c;
            projBudgetRev = projBudgetRev + qli1.TotalPrice;
			TempTask.AcctSeed__Project__c = rId;
            TempTask.Project_Phase_Completion_Percent__c = 0;
            TempTask.AcctSeed__Status__c = 'Not Started';
            TempTask.AcctSeed__Budgeted_Revenue__c = qli1.TotalPrice;
            TempTask.Product__c = qli1.Product2Id;
            TempTask.AcctSeed__GL_Account_Variable_1__c = TempProd.AcctSeed__GL_Account_Variable_1__c;
            TempTask.AcctSeed__GL_Account_Variable_2__c = TempProd.AcctSeed__GL_Account_Variable_2__c;
            TempTask.AcctSeed__GL_Account_Variable_3__c = TempProd.AcctSeed__GL_Account_Variable_3__c;
            TempTask.AcctSeed__GL_Account_Variable_4__c = TempProd.AcctSeed__GL_Account_Variable_4__c;
            //TempTask.AcctSeed__Labor_GL_Account__c = TempProd.AcctSeed__Expense_GL_Account__c;
            
            if (qli1.Start_Date__c != null){
                TempTask.Baseline_Start_Date__c = qli1.Start_Date__c;
                //TempTask.AcctSeed__Start_Date__c = qli1.Start_Date__c;
            	TempTask.Forecasted_Start_Date__c = qli1.Start_Date__c;
            }
            else {
                TempTask.Baseline_Start_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_Start_Date__c;
           	 	//TempTask.AcctSeed__Start_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_Start_Date__c;
            	TempTask.Forecasted_Start_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_Start_Date__c;
            }
            
            if (qli1.End_Date__c != null){
                TempTask.Baseline_End_Date__c = qli1.End_Date__c;
                //TempTask.AcctSeed__End_Date__c = qli1.End_Date__c;
                TempTask.Forecasted_End_Date__c = qli1.End_Date__c;
        	}
            else {
                //system.debug('End Date: '+ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_End_Date__c);
                TempTask.Baseline_End_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_End_Date__c;
                //TempTask.AcctSeed__End_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_End_Date__c;
                TempTask.Forecasted_End_Date__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Forecasted_End_Date__c;
            } 
             
            //system.debug('prod category: '+qli1.Product_Detail_Category__c+' Map Info: '+ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Id+' '+ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Name);
            if (ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Id != null) {
            	TempTask.Project_Phase__c = ProjectToPhasesMap.get(qli1.Product_Detail_Category__c).Id;
            }
            else {
                TempTask.Project_Phase__c = TempTask.Project_Phase__c = ProjectToPhasesMap.get('Other').Id;
            }
            
  
            if (qli1.Product_Detail_Category__c == 'Labor'){ //only push quantity as hours if its a Labor Phase
            	TempTask.AcctSeed__Budgeted_Hours__c = qli1.Quantity;
            }
            else {
                TempTask.AcctSeed__Budgeted_Hours__c = 0;
            }
            
            if (qli1.Description == null) {
                TempTask.Description__c = TempProd.Name;
                TempTask.Name = TempProd.Name;
            }
            else {
                TempTask.Description__c = qli1.Description;
                TempTask.Name = qli1.Description;
            }
            if (qli1.Start_Date__c != null && qli1.End_Date__c != null){
                TempTask.Duration_Days__c = qli1.Start_Date__c.daysBetween(qli1.End_Date__c);
            }
        	//system.debug('Task being inserted: '+TempTask);
            //insert TempTask;
            TaskList.add(TempTask);
            }
        
        insert TaskList; 
        
        List <opportunitylineitem> oliList = [select id, ProductCode, Description, Product2Id, TotalPrice, AcctSeed__Project__c, AcctSeed__Project_Task__c from opportunitylineitem where OpportunityId = :projInfo.AcctSeed__Opportunity__c]; 
        //system.debug('oliList.size: '+oliList.size()+' TaskList size: '+TaskList.size());
        List <opportunitylineitem> oliToUpd = new List <opportunitylineitem>();
        
        for (AcctSeed__Project_Task__c ptask : TaskList){
            //opportunitylineitem oplintoupd = new opportunitylineitem();
            for (opportunitylineitem oplin1 : oliList){
                //system.debug('ptask.AcctSeed__Budgeted_Revenue__c: '+ptask.AcctSeed__Budgeted_Revenue__c+' oplin1.TotalPrice: '+oplin1.TotalPrice+' oplin1.Product2Id: '+oplin1.Product2Id+' ptask.Product__c: '+ptask.Product__c);
                if (ptask.AcctSeed__Budgeted_Revenue__c == oplin1.TotalPrice && ptask.Product__c == oplin1.Product2Id) {
                    oplin1.AcctSeed__Project__c = rId;
                    oplin1.AcctSeed__Project_Task__c = ptask.Id;
                    oliToUpd.add(oplin1);
                }
            }
        }
        
        //system.debug('oliToUpd: '+oliToUpd);
        //update oliToUpd;
        
        projInfoUpd.id = projInfo.Id;
        
        if (projInfo.OHP__c != null) {
            system.debug('ohp: '+projInfo.OHP__c);
            projInfoUpd.Budgeted_Project_Revenue__c = projBudgetRev + (projBudgetRev * (projInfo.OHP__c / 100));
        }
        else {
            projInfoUpd.Budgeted_Project_Revenue__c = projBudgetRev;
        }
        
        update projInfoUpd;
        
        system.debug('Id: '+projInfoUpd.id+'Budget: '+projInfoUpd.Budgeted_Project_Revenue__c);
              
	return null;
    }
}