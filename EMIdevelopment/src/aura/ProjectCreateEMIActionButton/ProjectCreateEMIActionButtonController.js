({
	openVisualForcePage : function(component, event, helper) {
    var recordId = component.get("v.recordId");
	//window.open('/apex/ProjectCreateEMI?id=' + recordId);
	window.open('/apex/ProjectCreateEMI','Popup','height=400,width=1200,left=100,top=100,scrollbars=yes,toolbar=no,status=no');
	}
    
    /* doInit : function (component, event) {
    action.setParams({
            "opptyId": component.get("v.recordId")
        });
        action.setCallback(this,function (a){
            var stat = a.getReturnValue();

            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/apex/ProjectCreateEMI",
              "isredirect": "true"
            });
            urlEvent.fire();

        });
        $A.enqueueAction(action);
    } */
})