({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId")
		console.log('recordId = ' + recordId);
        var action = component.get("c.getClonePB");
       action.setParams({"oldId": recordId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === "SUCCESS") {
                var returned =response.getReturnValue();
                console.log("SUCCESS returned: " + JSON.stringify(returned));
                
                var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                      "recordId": returned,
                     // "slideDevName": "related"
                    });
                    navEvt.fire();                
 
            }
        });
        $A.enqueueAction(action);             
		
	} // end doInit function
    

})