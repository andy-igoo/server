# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
vcl 4.1;
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Varnish has a concept of "backend" or "origin" servers.
# A backend server is the server providing the content Varnish will accelerate.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-backends.html
backend default {
	.host = "127.0.0.1";
	.port = "8080";
}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Called after the response headers have been successfully retrieved from the backend.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-backend-response
sub vcl_backend_response {}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Called before any object except a `vcl_synth` result is delivered to the client.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-deliver
sub vcl_deliver {}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Called:
#	*) at the beginning of a request,
#	*) after the complete request has been received and parsed,
# 	*) after a restart
#	*) as the result of an ESI include.
# Its purpose is:
# 	*) to decide whether or not to serve the request,
#	*) possibly modify it
#	*) and decide on how to process it further.
# A backend hint may be set as a default for the backend processing side.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-recv
sub vcl_recv {}
