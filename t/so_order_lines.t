use strict;
use warnings;

use Sirius::REST::API;
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw/DELETE POST GET PATCH/;
use JSON;
use Data::Random::String;
use Data::Dumper;

my $app = Sirius::REST::API->to_app;
is( ref $app, 'CODE', 'Got app' );

# test GET all order lines for a particular order
my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/so/orders/LOUISE/163328/line_items' );

ok( $res->is_success, 'get all /so/orders successful')
  || diag "Status code: " . $res->code ;

# check how many order lines get returned
my $order_lines = from_json($res->content);
my $ct = scalar(@$order_lines);
ok($ct == 18, "correct number of order lines returned");

# test GET lines from non existant order
$res  = $test->request( GET '/so/orders/XYZ/9999999/line_items' );

ok( $res->code == 404, 'return 404 for non existant order')
  || diag "Status code: " . $res->code ;



done_testing;
