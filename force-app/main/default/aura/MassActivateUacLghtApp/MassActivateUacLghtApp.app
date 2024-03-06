<aura:application access="GLOBAL" extends="ltng:outApp" implements="forceCommunity:availableForAllPageTypes">
  <aura:dependency resource="c:ChangeLeadLghtCmp"/>  
  <div class="slds-modal__content slds-var-p-around_medium" id="modal-content-id-1">
    <div class="slds-col--padded slds-var-p-top_large">
      <c:MassActivateUacLghtCmp />
    </div>
  </div>
</aura:application>