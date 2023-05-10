<aura:application extends="force:slds">
    
    <aura:attribute name="recordId" type="String" />
    <aura:handler name="notifyEvent" event="c:Event_Notify" action="{!c.print}"/>
    <div>
        <div>
            <c:Financial_Account_Detail recordId="{!v.recordId}" showButtons="false"/>
        </div>
    </div>
    
</aura:application>