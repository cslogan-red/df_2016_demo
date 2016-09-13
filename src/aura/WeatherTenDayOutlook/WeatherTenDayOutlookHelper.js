({
	/**
     * Controls the visibility of a component by checking to first see
     * if the "toggle" CSS class is applied and then either applies or 
     * removes this class based on the supplied action.
     */
	setVisibility : function( cmp, evt, hlp, targetCmp, action) {
        var HIDE_ACTION = 'HIDE';
        var SHOW_ACTION = 'SHOW';
        var TOGGLE_CLASS = 'toggle';
        
        // show
        if ( targetCmp !== null && targetCmp !== '' 
            	&& action === SHOW_ACTION) {
            
            var toggle = cmp.find( targetCmp);
            if ( $A.util.hasClass( toggle, TOGGLE_CLASS)) {
                
                $A.util.toggleClass( toggle, TOGGLE_CLASS);
            }
        // hide
        } else if ( targetCmp !== null && targetCmp !== '' 
                   && action === HIDE_ACTION) {
            
            var toggle = cmp.find( targetCmp);
            if ( $A.util.hasClass( toggle, TOGGLE_CLASS) === false) {
                
                $A.util.toggleClass( toggle, TOGGLE_CLASS);
            }
        }
    }
})