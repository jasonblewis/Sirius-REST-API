use strict;
use warnings;

use Sirius::REST::API;
use Test::More;
use Plack::Test;
use HTTP::Request::Common;
use JSON;

my $app = Sirius::REST::API->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/so/orders' );

ok( $res->is_success, 'get all /so/orders successful')
  || diag "Status code: " . $res->code ;


my $order_params = {order_source => 'jason'};
# test posting - create new order
$res = $test->request(POST '/so/orders',
                       'Content-Type' => 'application/json',
                       'Content'      => to_json($order_params),
);

ok( $res->is_success, 'post to /so/orders to create an order' );
my $content = from_json($res->content);
diag ("res->content:", $content);
diag ("res->as_string:", $res->as_string);


ok( $res->header('Location'), "test location header after post" );

my $location = $res->header('Location');
$res = $test->request(GET $location);
ok( $res->is_success, 'GET order we just created');
my $order = from_json($res->content);
diag("res->content:", $order);
diag('order->{order_source}',$order->{order_source},'|');
ok($order->{order_source} eq $order_params->{order_source}, "order_source is what we created");
#ok($order->{record_no} eq '148135', "record_no is 148135");



        

# test re can retreive an order
$res = $test->request(GET '/so/orders/CHARMA/148135');
ok( $res->is_success, 'GET a single order /so/orders/CHARMA/148135');
$order = from_json($res->content);
diag("res->content:", $order);
ok($order->{order_source} eq 'CHARMA', "order_source is CHARMA");
ok($order->{record_no} eq '148135', "record_no is 148135");

# test we get 404 if not found
$res = $test->request(GET '/so/orders/XYZABC/148135');
ok( $res->code == 404, 'try to get invalid order');
diag("resp>content:", from_json($res->content));



done_testing;
