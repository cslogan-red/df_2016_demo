({
    /**
     * Function is called via the init handler in the CurrentWeatherRadar component.
     * Handles the initialization of the component, for devices that have visited page in 
     * the past week, a cookie storing a session Id can be used to pull previously
     * requested location data.
     */ 
    initComponent : function( cmp, evt, hlp) {
        var SESSION_ID_COOKIE = 'WEATHER_SESSION_ID=';
        
        // hide data body & show spinner, check for pre-existing cookie and init component
        hlp.setVisibility( cmp, evt, hlp, 'mainDataRadar', 'HIDE');
        hlp.setVisibility( cmp, evt, hlp, 'loadingSpinnerRadar', 'SHOW');
        
        // reset zoom level
        var zoomLevel = cmp.get( 'v.zoomLevel');
        zoomLevel = 1;
        cmp.set( 'v.zoomLevel', zoomLevel);
        
        // get current cookies & split, find session cookie if present
        var cookieVal = hlp.getCookieValue( cmp, evt, hlp, SESSION_ID_COOKIE);   
        var action = cmp.get( 'c.serverInitWeatherRadar');
        action.setParams({
            'sessionId' : cookieVal
		});
        
        action.setCallback( this, function( response) {
            
            var state = response.getState();
            if ( state === 'SUCCESS') {
                
                cmp.set( 'v.record', response.getReturnValue());
                var respObj = response.getReturnValue();
                
                if ( respObj.currentLocation === 'NO_DATA') {
                    
                    // no data already cached, don't render anything
                	hlp.setVisibility( cmp, evt, hlp, 'loadingSpinnerRadar', 'HIDE');
                } else {
                    
                    cmp.set( 'v.weatherLocZip', respObj.currentZip);
                    // fire completed event for radar component
                	cmp.getEvent( 'RadarLoadingFinished').fire();
                }
            }
        });
        
        $A.enqueueAction( action);
    },
    
    /**
     * Function requests new radar data every time a new location zip
     * is entered.
     */ 
	getRadarData : function( cmp, evt, hlp) {
		
        // hide data body while requesting image data
        hlp.setVisibility( cmp, evt, hlp, 'mainDataRadar', 'HIDE');
        hlp.setVisibility( cmp, evt, hlp, 'loadingSpinnerRadar', 'SHOW');
        
        var locZip = cmp.get( 'v.inputZip');
        cmp.set( 'v.weatherLocZip', locZip);
        var action = cmp.get( 'c.serverGetCurrentRadarDataByZip');
        action.setParams({
            'inputZip' : locZip
        });
        
        action.setCallback( this, function( response) {
            
            var state = response.getState();
            if ( state === 'SUCCESS') {
                
                cmp.set( 'v.record', response.getReturnValue());
                var respObj = response.getReturnValue();
                
               	// fire completed event for radar component
               	cmp.getEvent( 'RadarLoadingFinished').fire();
            } 
        });
        
        $A.enqueueAction( action);
	},
    
    /**
     * RadarLoadingFinished event handler
     */ 
    loadingDone : function( cmp, evt, hlp) {

        // hide the spinner & show the data body
        hlp.setVisibility( cmp, evt, hlp, 'loadingSpinnerRadar', 'HIDE');
        hlp.setVisibility( cmp, evt, hlp, 'mainDataRadar', 'SHOW');
    },
    
    radarZoomOut : function( cmp, evt, hlp) {
        var MAX_ZOOM_OUT = 5;
        
        // get current zoom level, if below max allow zoom
        var zoomLevel = cmp.get( 'v.zoomLevel');
        if ( zoomLevel <= MAX_ZOOM_OUT) {
            
            zoomLevel++;
            var action = cmp.get( 'c.serverRadarZoomOut');
            var currentZip = cmp.get( 'v.weatherLocZip');
            action.setParams({
                
                'zoomLevel' : zoomLevel.toString(),
                'inputZip' : currentZip
            });
            
            action.setCallback( this, function( response) {
            	
                var state = response.getState();
                if ( state === 'SUCCESS') {
                    
                    cmp.set( 'v.record', response.getReturnValue());
                    cmp.set( 'v.zoomLevel', zoomLevel);
                    var respObj = response.getReturnValue();
                    console.log( respObj.currentWeatherRadarImageURL);
                    
                    // fire completed event for radar component
                    cmp.getEvent( 'RadarLoadingFinished').fire();
                }
            });
            
            $A.enqueueAction( action);
        }
    },
    
    radarZoomIn : function( cmp, evt, hlp) {
        var MIN_ZOOM_IN = 0;
        
        // get current zoom level, if below max allow zoom
        var zoomLevel = cmp.get( 'v.zoomLevel');
        if ( zoomLevel > MIN_ZOOM_IN) {
            
            zoomLevel--;
            var action = cmp.get( 'c.serverRadarZoomIn');
            var currentZip = cmp.get( 'v.weatherLocZip');
            action.setParams({
                
                'zoomLevel' : zoomLevel.toString(),
                'inputZip' : currentZip
            });
            
            action.setCallback( this, function( response) {
            	
                var state = response.getState();
                if ( state === 'SUCCESS') {
                    
                    cmp.set( 'v.record', response.getReturnValue());
                    cmp.set( 'v.zoomLevel', zoomLevel);
                    var respObj = response.getReturnValue();
                    console.log( respObj.currentWeatherRadarImageURL);
                    
                    // fire completed event for radar component
                    cmp.getEvent( 'RadarLoadingFinished').fire();
                }
            });
            
            $A.enqueueAction( action);
        }
    }
})