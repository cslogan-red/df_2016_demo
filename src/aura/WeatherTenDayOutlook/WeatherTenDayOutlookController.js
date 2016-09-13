({
	/**
     * Function is responsible for parsing last 5 days of 10 day list and displaying
     */
    getNextFiveDays : function( cmp, evt, hlp) {
        
       	var weatherList = cmp.get( 'v.weatherListAll');
        if ( weatherList != null && weatherList.length > 0) {
            
            var nextFiveDays = [];
            var j = 0;
            for ( var i = 5; i < 10; i++) {
                
                nextFiveDays[j] = weatherList[i];
                j++;
            }
            cmp.set( 'v.weatherList', null);
            cmp.set( 'v.weatherList', nextFiveDays);
            hlp.setVisibility( cmp, evt, hlp, 'nextFiveButton', 'HIDE');
            hlp.setVisibility( cmp, evt, hlp, 'prevFiveButton', 'SHOW');
        }
    },
    
    /**
     * Function is responsible for parsing first 5 days of 10 day list and displaying
     */
    getPrevFiveDays : function( cmp, evt, hlp) {
        
       	var weatherList = cmp.get( 'v.weatherListAll');
        if ( weatherList != null && weatherList.length > 0) {
            
            var prevFiveDays = [];
            for ( var i = 0; i < 5; i++) {
                
                prevFiveDays[i] = weatherList[i];
            }
            cmp.set( 'v.weatherList', null);
            cmp.set( 'v.weatherList', prevFiveDays);
            hlp.setVisibility( cmp, evt, hlp, 'nextFiveButton', 'SHOW');
            hlp.setVisibility( cmp, evt, hlp, 'prevFiveButton', 'HIDE');
        }
    }
})