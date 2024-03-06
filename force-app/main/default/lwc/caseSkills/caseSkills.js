import { LightningElement, api, wire } from 'lwc';

import getSkilsFromServer from '@salesforce/apex/CaseSkillsCtrl.getSkills';
import noSkillsFoundMessage from '@salesforce/label/c.NoSkillsFound';

const TABLE_COLUMNS = [
    { label: "Name", fieldName: "SkillMasterName", type: "text", sortable: true },
    { label: "Required", fieldName: "RequiredSkill", type: "boolean", sortable: true },
    { label: "Priority", fieldName: "SkillPriority", type: "number", sortable: true }
];

export default class caseSkills extends LightningElement {
    @api recordId;

    label = { noSkillsFoundMessage };

    skills = [];
    columns = TABLE_COLUMNS;
    loading = true;
    skillsFound;
    errorMsg;
    
    @wire(getSkilsFromServer, { caseId: "$recordId" })
    wiredSkills({ error, data }) {
        if (data) {
            this.skills = data.map((item) => {
                return {
                    SkillMasterName: item.Skill.MasterLabel,
                    RequiredSkill: !item.IsAdditionalSkill,
                    SkillPriority: item.SkillPriority
                };
            });

            this.skillsFound = (this.skills.length > 0);
            this.loading = false;
        } else if (error) {
            this.errorMsg = error;
            this.loading = false;
        }
    }

}