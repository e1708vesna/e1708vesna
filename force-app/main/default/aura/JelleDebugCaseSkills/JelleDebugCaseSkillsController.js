({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [
            {label: 'Skill Name', fieldName: 'SkillLabel', type: 'text'},
            {label: 'SkillLevel', fieldName: 'SkillLevel', type: 'number'},
            {label: 'Optional Skill', fieldName: 'IsAdditionalSkill', type: 'boolean'},
            {label: 'SkillPriority', fieldName: 'SkillPriority', type: 'number'}
        ]);
		helper.getSkills(cmp);
        
    },

    invokeFlow: function (cmp, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/flow/JTALOmniChannelFlow?recordId=' + cmp.get("v.recordId")
        });
        urlEvent.fire();
    }    
});