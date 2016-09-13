({
	/**
     * Controls the visibility of a component by checking to first see
     * if the "toggle" CSS class is applied and then either applies or 
     * removes this class based on the supplied action.
     */
	setVisibility : function( cmp, evt, hlp, targetCmp, action) {
        var HIDE_ACTION = 'HIDE';
        var SHOW_ACTION = 'SHOW';
        var TOGGLE_CLASS = 'toggle_radar';
        
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
    },
    
    /**
     * Retreives the session Id cookie value if present based on
     * supplied cookieName
     */ 
    getCookieValue : function( cmp, evt, hlp, cookieName) {
        var cookieVal;
        
        if ( cookieName !== '') {
            // get current cookies & split, find session cookie if present
            // if cookie doesn't exist, null or empty value will initiate 
            // creation of new session ID value in Apex controller
            var cookie = document.cookie;
            var splitArr = cookie.split( ';');
            
            for ( var i = 0; i < splitArr.length; i++) {
                
                var c = splitArr[i];
                while ( c.charAt(0) == ' ') c = c.substring( 1);
                if ( c.indexOf( cookieName) == 0) {
                    
                    cookieVal = c.substring( name.length, c.length);
                    cookieVal = cookieVal.substring( cookieVal.indexOf( '=') + 1);
                }
            }  
        }
        
        return cookieVal;
    }
})