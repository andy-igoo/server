# 2020-05-11
# Magento: «VCL version 5.0 is not supported so it should be 4.0 even though actually used Varnish version is 6»
# 2020-05-11
# «Starting with Varnish 4.0, each VCL file must start by declaring its version with vcl <major>.<minor>; marker
# at the top of the file.» https://varnish-cache.org/docs/6.1/reference/vcl.html#description
vcl 4.0;
# 2020-05-11 https://varnish-cache.org/docs/6.1/reference/vcl.html#include-statement
include "magento.vcl";