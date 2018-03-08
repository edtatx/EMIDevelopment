({
    doInit : function(component, event, helper) {        
        // Get a reference to the getInfo function defined in the Apex controller
		var action = component.get("c.getInfo");
         action.setParams({
            "recordId": component.get("v.recordId")}); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log("Opportunity, Quote and Account Information Successfully Retrieved!");
                var o1 = response.getReturnValue();
                component.set("v.info",o1);
                component.set("v.opname", o1.oppinfo.Name);
                component.set("v.startDate",o1.oppinfo.Expected_Start_Date__c);
                component.set("v.quoteId",o1.quoteinfo.Id);
                component.set("v.projObj.Name",o1.quoteinfo.QuoteNumber+' '+o1.quoteinfo.Name);
				component.set("v.acctName",o1.accountinfo.Name);
                component.set("v.projObj.AcctSeed__Account__c",o1.accountinfo.Id);
                component.set("v.projObj.Expected_Project_Start__c",o1.oppinfo.Expected_Start_Date__c);
                component.set("v.projObj.Expected_Duration__c",o1.oppinfo.Expected_Duration__c);
                component.set("v.projObj.AcctSeed__Opportunity__c",o1.oppinfo.Id);
                component.set("v.projObj.AcctSeed__Status__c",'Active');
                component.set("v.projObj.Images__c",o1.quoteinfo.Images__c);
                component.set("v.projObj.OHP__c",o1.oppinfo.OH_P__c);
                component.set("v.projObj.Clarifications__c",o1.quoteinfo.Clarifications__c);
                component.set("v.projObj.Delivery__c",o1.quoteinfo.Delivery__c);
                component.set("v.projObj.Features__c",o1.quoteinfo.Features__c);
                component.set("v.projObj.Equipment_Description__c",o1.quoteinfo.Equipment_Description__c);
				component.set("v.projObj.Features_and_Benefits_of_Recommendation__c",o1.quoteinfo.Features_and_Benefits_of_Recommendation__c);
 				component.set("v.projObj.Load_Operation_Specification__c",o1.quoteinfo.Load_Operation_Specification__c);
                component.set("v.projObj.Objectives__c",o1.quoteinfo.Objectives__c);
                component.set("v.projObj.Recommendation__c",o1.quoteinfo.Recommendation__c);
                component.set("v.projObj.Terms_Conditions__c",o1.quoteinfo.Terms_Conditions__c);
                component.set("v.projObj.Installation__c",o1.quoteinfo.Installation__c);
           }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        // Invoke the service
        $A.enqueueAction(action);
    },

 	handleSaveRecord : function(component, event, helper) {     
        var action = component.get("c.createProjRecord");
            action.setParams({"projObj":component.get("v.projObj")});
            action.setCallback(this,function(result){
                var state1 = result.getState();
                if (state1 === "SUCCESS"){
                    console.log("SUCCESS: Project Created!");
                }
                else {
                    console.log("ERROR: Project NOT Created!")
                            var resultsToast = $A.get("e.force:showToast");
            					resultsToast.setParams({
                                    "title": "Error",
                                    "message": "Something went wrong, Project was not created",
                                    "type":"error"});
            				resultsToast.fire();
 
            				// Navigate back to the record view
            				var navigateEvent = $A.get("e.force:navigateToSObject");
            				navigateEvent.setParams({ "recordId": component.get('v.recordId') });
           					navigateEvent.fire();
                }
            	var projId = result.getReturnValue();
                var action = component.get("c.createPhasesandTasks");     
                action.setParams({"rId" : projId, qId : component.get("v.quoteId")});
        			action.setCallback(this,function(result){
                        var state2 = result.getState();
                        if (state2 === "SUCCESS"){
                            $A.get("e.force:closeQuickAction").fire();
                            var resultsToast = $A.get("e.force:showToast");
            					resultsToast.setParams({
                				"title": "Success",
                				"message": "Project was Created",
                                "type":"success"});
            				resultsToast.fire();
 
            				// Navigate back to the record view
            				var navigateEvent = $A.get("e.force:navigateToSObject");
            				navigateEvent.setParams({ "recordId": component.get('v.recordId') });
           					navigateEvent.fire();
                        }
                        else {
                    		console.log("ERROR: Phases and Tasks NOT Created!")
                                                        var resultsToast = $A.get("e.force:showToast");
            					resultsToast.setParams({
                                    "title": "Error",
                                    "message": "Something went wrong, Project Phases and Tasks were not created",
                                    "type":"error"});
            				resultsToast.fire();
 
            				// Navigate back to the record view
            				var navigateEvent = $A.get("e.force:navigateToSObject");
            				navigateEvent.setParams({ "recordId": component.get('v.recordId') });
           					navigateEvent.fire();
                		}
        		});
         		$A.enqueueAction(action);
        });
         $A.enqueueAction(action);
 },
        
    handleCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    }
})