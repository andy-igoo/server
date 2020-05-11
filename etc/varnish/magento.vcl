# 2020-05-11
# Magento: «VCL version 5.0 is not supported so it should be 4.0 even though actually used Varnish version is 6»
# 2020-05-11
# «Starting with Varnish 4.0, each VCL file must start by declaring its version with vcl <major>.<minor>; marker
# at the top of the file.» https://varnish-cache.org/docs/6.1/reference/vcl.html#description
vcl 4.0;
# 2020-05-11
# The `import` statement is used to load Varnish Modules (VMODs.)
# https://varnish-cache.org/docs/6.1/reference/vcl.html#import-statement
import std;
# 2020-05-11
# «An Access Control List (ACL) declaration creates and initialises a named access control list
# which can later be used to match client addresses.»
# https://varnish-cache.org/docs/6.1/reference/vcl.html#access-control-list-acl
acl purge {
	"localhost";
}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Varnish has a concept of "backend" or "origin" servers.
# A backend server is the server providing the content Varnish will accelerate.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-backends.html
# 2020-05-11
# «A backend declaration creates and initialises a named backend object.
# A declaration start with the keyword backend followed by the name of the backend.
# The actual declaration is in curly brackets, in a key/value fashion.»
# https://varnish-cache.org/docs/6.1/reference/vcl.html#backend-definition
backend default {
	# 2020-05-11
	# 1) «`first_byte_timeout` (default: 60s) limits how long the processing time of the backend may be.
	# The first byte of the response must come down the TCP connection within this timeout.»
	# https://info.varnish-software.com/blog/understanding-timeouts-varnish-cache
	# 2) «Timeout for first byte.
	# Default: `first_byte_timeout` parameter, see `varnishd`:
	# https://varnish-cache.org/docs/6.1/reference/varnishd.html#varnishd-1»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#backend-definition
	# 3) https://book.varnish-software.com/4.0/chapters/Tuning.html#system-parameters
	.first_byte_timeout = 600s;
	# 2020-05-11
	# «The host to be used.
	# IP address or a hostname that resolves to a single IP address.
	# This attribute is mandatory, unless .path is declared.»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#backend-definition
	.host = "localhost";
	# 2020-05-11
	# «The port on the backend that Varnish should connect to.
	# Ignored if a Unix domain socket is declared in `.path`.»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#backend-definition
	.port = "8080";
	# 2020-05-11
	# 1) «Attach a probe to the backend.
	# See Probes: https://varnish-cache.org/docs/6.1/reference/vcl.html#probes»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#backend-definition
	# 2) «Probes will query the backend for status on a regular basis and mark the backend as down it they fail.»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
	.probe = {
		# 2020-05-11
		# «The expected HTTP response code. Defaults to 200.»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.expected_response = 200;
		# 2020-05-11
		# «How many of the polls in .window are considered good when Varnish starts.
		# Defaults to the value of `.threshold` - 1.
		# In this case, the backend starts as sick and requires one single poll to be considered healthy.»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.initial = 4;
		# 2020-05-11
		# «How often the probe is run. Default is `5s`.»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.interval = 5s;
		# 2020-05-11
		# How many of the polls in `.window` must have succeeded to consider the backend to be healthy.
		# Defaults to `3`.
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.threshold = 5;
		# 2020-05-11
		# «The timeout for the probe. Default is `2s`.»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.timeout = 2s;
		# 2020-05-11
		# «The URL to query. Defaults to `/`. Mutually exclusive with `.request`»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.url = "/shop/health_check.php";
		# 2020-05-11
		# «How many of the latest polls we examine to determine backend health. Defaults to 8.»
		# https://varnish-cache.org/docs/6.1/reference/vcl.html#probes
		.window = 10;
   }
}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Called after the response headers have been successfully retrieved from the backend.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-backend-response
sub vcl_backend_response {
	# 2020-05-11
	# 1) «The response received from the backend, one cache misses, the store object is built from `beresp`.
	# beresp
	# 		Type: HTTP
	#		Readable from: `vcl_backend_response`, `vcl_backend_error`.
	# The entire backend response HTTP data structure, useful as argument to VMOD functions.»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#beresp
	# 2) «beresp.grace
	# Set to a period to enable grace.
	# Type: DURATION
	# Readable from: `vcl_backend_response`, `vcl_backend_error`.
	# Writable from: `vcl_backend_response`, `vcl_backend_error`.»
	# https://varnish-cache.org/docs/6.1/reference/vcl.html#beresp
	set beresp.grace = 3d;
	if (beresp.http.content-type ~ "text") {
		set beresp.do_esi = true;
	}
	if (bereq.url ~ "\.js$" || beresp.http.content-type ~ "text") {
		set beresp.do_gzip = true;
	}
	if (beresp.http.X-Magento-Debug) {
		set beresp.http.X-Magento-Cache-Control = beresp.http.Cache-Control;
	}
	# cache only successfully responses and 404s
	if (beresp.status != 200 && beresp.status != 404) {
		set beresp.ttl = 0s;
		set beresp.uncacheable = true;
		return (deliver);
	}
	elsif (beresp.http.Cache-Control ~ "private") {
		set beresp.uncacheable = true;
		set beresp.ttl = 86400s;
		return (deliver);
	}
	# validate if we need to cache it and prevent from setting cookie
	if (beresp.ttl > 0s && (bereq.method == "GET" || bereq.method == "HEAD")) {
		unset beresp.http.set-cookie;
	}
   # If page is not cacheable then bypass varnish for 2 minutes as Hit-For-Pass
   if (beresp.ttl <= 0s ||
	   beresp.http.Surrogate-control ~ "no-store" ||
	   (!beresp.http.Surrogate-Control &&
	   beresp.http.Cache-Control ~ "no-cache|no-store") ||
	   beresp.http.Vary == "*") {
		# Mark as Hit-For-Pass for the next 2 minutes
		set beresp.ttl = 120s;
		set beresp.uncacheable = true;
	}
	return (deliver);
}
# 2020-04-19 Dmitry Fedyuk https://www.upwork.com/fl/mage2pro
# «Called before any object except a `vcl_synth` result is delivered to the client.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-deliver
sub vcl_deliver {
	if (resp.http.X-Magento-Debug) {
		if (resp.http.x-varnish ~ " ") {
			set resp.http.X-Magento-Cache-Debug = "HIT";
			set resp.http.Grace = req.http.grace;
		}
		else {
			set resp.http.X-Magento-Cache-Debug = "MISS";
		}
	}
	else {
		unset resp.http.Age;
	}
	# Not letting browser to cache non-static files.
	if (resp.http.Cache-Control !~ "private" && req.url !~ "^/(pub/)?(media|static)/") {
		set resp.http.Pragma = "no-cache";
		set resp.http.Expires = "-1";
		set resp.http.Cache-Control = "no-store, no-cache, must-revalidate, max-age=0";
	}
	unset resp.http.X-Magento-Debug;
	unset resp.http.X-Magento-Tags;
	unset resp.http.X-Powered-By;
	unset resp.http.Server;
	unset resp.http.X-Varnish;
	unset resp.http.Via;
	unset resp.http.Link;
}
# 2020-05-11
# «Called after `vcl_recv` to create a hash value for the request.
# This is used as a key to look up the object in Varnish.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-hash
sub vcl_hash {
	if (req.http.cookie ~ "X-Magento-Vary=") {
		hash_data(regsub(req.http.cookie, "^.*?X-Magento-Vary=([^;]+);*.*$", "\1"));
	}
	# For multi site configurations to not cache each other's content
	if (req.http.host) {
		hash_data(req.http.host);
	}
	else {
		hash_data(server.ip);
	}
	# To make sure http users don't see ssl warning
	if (req.http.X-Forwarded-Proto) {
		hash_data(req.http.X-Forwarded-Proto);
	}
	if (req.url ~ "/graphql") {
		call process_graphql_headers;
	}
}
# 2020-05-11
# «Called when a cache lookup is successful.
# The object being hit may be stale: It can have a zero or negative `ttl` with only `grace` or `keep` time left.»
# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-hit
sub vcl_hit {
	if (obj.ttl >= 0s) {
		# Hit within TTL period
		return (deliver);
	}
	if (std.healthy(req.backend_hint)) {
		if (obj.ttl + 300s > 0s) {
			# Hit after TTL expiration, but within grace period
			set req.http.grace = "normal (healthy server)";
			return (deliver);
		}
		else {
			# 2020-05-11
			# «Restart the transaction.
			# Increases the `req.restarts` counter.
			# If the number of restarts is higher than the `max_restarts` parameter,
			# control is passed to `vcl_synth` as for `return(synth(503, "Too many restarts"))`
			# https://varnish-cache.org/docs/6.4/users-guide/vcl-built-in-subs.html#vcl-synth
			# For a restart, all modifications to `req` attributes are preserved
			# except for `req.restarts` and `req.xid`, which need to change by design.»
			# https://varnish-cache.org/docs/6.4/users-guide/vcl-actions.html#restart
			return (restart);
		}
	}
	else {
		# server is not healthy, retrieve from cache
		set req.http.grace = "unlimited (unhealthy server)";
		return (deliver);
	}
}
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
sub vcl_recv {
	if (req.method == "PURGE") {
		if (client.ip !~ purge) {
			return (synth(405, "Method not allowed"));
		}
		# To use the X-Pool header for purging varnish during automated deployments, make sure the X-Pool header
		# has been added to the response in your backend server config. This is used, for example, by the
		# capistrano-magento2 gem for purging old content from varnish during it's deploy routine.
		if (!req.http.X-Magento-Tags-Pattern && !req.http.X-Pool) {
			return (synth(400, "X-Magento-Tags-Pattern or X-Pool header required"));
		}
		if (req.http.X-Magento-Tags-Pattern) {
		  ban("obj.http.X-Magento-Tags ~ " + req.http.X-Magento-Tags-Pattern);
		}
		if (req.http.X-Pool) {
		  ban("obj.http.X-Pool ~ " + req.http.X-Pool);
		}
		return (synth(200, "Purged"));
	}
	if (req.method != "GET" &&
		req.method != "HEAD" &&
		req.method != "PUT" &&
		req.method != "POST" &&
		req.method != "TRACE" &&
		req.method != "OPTIONS" &&
		req.method != "DELETE") {
		  /* Non-RFC2616 or CONNECT which is weird. */
		  return (pipe);
	}
	# We only deal with GET and HEAD by default
	if (req.method != "GET" && req.method != "HEAD") {
		return (pass);
	}
	# Bypass shopping cart, checkout and search requests
	if (req.url ~ "/checkout" || req.url ~ "/catalogsearch") {
		return (pass);
	}
	# Bypass health check requests
	if (req.url ~ "/shop/health_check.php") {
		return (pass);
	}
	# Set initial grace period usage status
	set req.http.grace = "none";
	# normalize url in case of leading HTTP scheme and domain
	set req.url = regsub(req.url, "^http[s]?://", "");
	# collect all cookies
	std.collect(req.http.Cookie);
	# Compression filter. See https://www.varnish-cache.org/trac/wiki/FAQ/Compression
	if (req.http.Accept-Encoding) {
		if (req.url ~ "\.(jpg|jpeg|png|gif|gz|tgz|bz2|tbz|mp3|ogg|swf|flv)$") {
			# No point in compressing these
			unset req.http.Accept-Encoding;
		}
		elsif (req.http.Accept-Encoding ~ "gzip") {
			set req.http.Accept-Encoding = "gzip";
		}
		elsif (req.http.Accept-Encoding ~ "deflate" && req.http.user-agent !~ "MSIE") {
			set req.http.Accept-Encoding = "deflate";
		}
		else {
			# unknown algorithm
			unset req.http.Accept-Encoding;
		}
	}
	# Remove all marketing get parameters to minimize the cache objects
	if (req.url ~ "(\?|&)(gclid|cx|ie|cof|siteurl|zanpid|origin|fbclid|mc_[a-z]+|utm_[a-z]+|_bta_[a-z]+)=") {
		set req.url = regsuball(req.url, "(gclid|cx|ie|cof|siteurl|zanpid|origin|fbclid|mc_[a-z]+|utm_[a-z]+|_bta_[a-z]+)=[-_A-z0-9+()%.]+&?", "");
		set req.url = regsub(req.url, "[?|&]+$", "");
	}
	# Static files caching
	if (req.url ~ "^/(pub/)?(media|static)/") {
		# Static files should not be cached by default
		return (pass);
		# But if you use a few locales and don't use CDN you can enable caching static files by commenting previous line (#return (pass);) and uncommenting next 3 lines
		#unset req.http.Https;
		#unset req.http.X-Forwarded-Proto;
		#unset req.http.Cookie;
	}
	return (hash);
}
sub process_graphql_headers {
	if (req.http.Store) {
		hash_data(req.http.Store);
	}
	if (req.http.Content-Currency) {
		hash_data(req.http.Content-Currency);
	}
}