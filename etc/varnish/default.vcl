# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
vcl 4.1;
backend default {
	.host = "127.0.0.1";
	.port = "8080";
}
sub vcl_backend_response {}
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
