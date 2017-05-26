use strict;
use warnings;

use Sirius::REST::API;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;

my $app = Sirius::REST::API->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/orders' );

ok( $res->is_success, '[GET /orders] successful' )
  || diag "Status code: " . $res->code ;

done_testing;
