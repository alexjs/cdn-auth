# This is for Varnish 3.x
# Authentication is handled within the 'vcl_recv' sub-section.
# This method also allows fallback to 401 (u/p) auth for users who need to access the origin directly.
# For production deployments, we recommend the use of https://www.varnish-cache.org/vmod/authentication
# However, this should suffice for a simple development environment
# (Based on http://blog.tenya.me/blog/2011/12/14/varnish-http-authentication/)

sub vcl_recv {
	# Authentication is done with the X-PSK-Auth header
	# Fetch it, and validate it. 
	# If it doesn't match, pass on to U/P auth.
	#
	# NB: we allow matching of two keys - the current, and the previous, before erroring
	# This is to allow for key cycling.

	# Generate this using a standard Base64 Password Hasher. For example:
	# echo -n "user:pass" | base64


    # Uncomment the next line, and comment the line below, if currently cycling the key
	#if (req.http.X-PSK-Auth != "<preshared key>" && req.http.X-PSK-Auth != "<previous preshared key>" && ! req.http.Authorization ~ "Basic <base64 hash>" ) {
	if (req.http.X-PSK-Auth != "<preshared key>" && ! req.http.Authorization ~ "Basic <base64 hash>" ) {
		error 401 "Restricted";
	}
}

sub vcl_error {
	if (obj.status == 401) {
	  set obj.http.Content-Type = "text/html; charset=utf-8";
	  set obj.http.WWW-Authenticate = "Basic realm=Secured";
	  synthetic {" 
	
	 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" 
	 "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd">
	
	 <HTML>
	 <HEAD>
	 <TITLE>Error</TITLE>
	 <META HTTP-EQUIV='Content-Type' CONTENT='text/html;'>
	 </HEAD>
	 <BODY><H1>401 Unauthorised</H1></BODY>
	 </HTML>
	 "};
	  return (deliver);
	}
}
