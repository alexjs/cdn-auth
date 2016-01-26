# Fetch the X-PSK-Auth header
# If it matches our PSK, allow through
# Otherwise, issue a 403

# Current PSK - as configured in your CDN 
$curKey="<preshared key>";

# For use if you are currently cycling your keys
$oldKey="<old preshared key>";

if( (http.getHeader( "X-PSK-Auth" ) != $curKey) && (http.getHeader( "X-PSK-Auth" ) != $oldKey) ) { 

	http.sendResponse( "403 Forbidden", 
		"text/html", "Access denied\n", "" ); 
} 
