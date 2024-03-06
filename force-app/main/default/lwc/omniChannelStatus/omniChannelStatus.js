import { LightningElement, api } from 'lwc';
import getCaseOmniChannelStatus from '@salesforce/apex/OmniChannelStatusCtrl.getCaseOmniChannelStatus';
import caseNotInOmniChannel from '@salesforce/label/c.CaseNotInOmniChannel';

export default class OmniChannelStatus extends LightningElement {
    @api recordId;
    agentWorks = [];
    label = { caseNotInOmniChannel };
    loading = true;

    columns = [
        { label: 'User', fieldName: 'UserName', type: 'text' },
        { label: 'Status', fieldName: 'Status', type: 'text' },
        { label: 'Assign Date', fieldName: 'AssignedDate', type: 'text' },
        { label: 'Accept Date', fieldName: 'AcceptDate', type: 'text' },
        { label: 'Decline Date', fieldName: 'DeclineDate', type: 'text' },
        { label: 'Decline Reason', fieldName: 'DeclineReason', type: 'text' }
    ];

    connectedCallback() {
        getCaseOmniChannelStatus({ caseId: this.recordId })
            .then(result => {
                this.agentWorks = result.map(work => ({
                    ...work,
                    UserName: work.User.Name
                }));
                this.loading = false;
            })
            .catch(error => {
                console.error('Error fetching agent work:', error);
                this.agentWorks = [];
                this.loading = false;
            });
    }   
}