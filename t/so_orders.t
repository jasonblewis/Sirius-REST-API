use strict;
use warnings;

use Sirius::REST::API;
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw/DELETE POST GET PATCH/;
use JSON;
use Data::Random::String;

my $app = Sirius::REST::API->to_app;
is( ref $app, 'CODE', 'Got app' );

my $test = Plack::Test->create($app);
my $res  = $test->request( GET '/so/orders' );

ok( $res->is_success, 'get all /so/orders successful')
  || diag "Status code: " . $res->code ;


# test posting - create new order
my $order_params = {order_source => 'jason'};
$res = $test->request(POST '/so/orders',
                       'Content-Type' => 'application/json',
                       'Content'      => to_json($order_params),
);

ok( $res->is_success, 'post to /so/orders to create an order' )
  || BAIL_OUT("could not create an order");
my $content = from_json($res->content);
diag ("res->content:", $content);
diag ("res->as_string:", $res->as_string);


ok( $res->header('Location'), "test location header exists after post" );

# now get location to see if new order was added
my $location = $res->header('Location');
$res = $test->request(GET $location);
ok( $res->is_success, 'GET order we just created')
  || BAIL_OUT("could not retreive order we just created");
my $order = from_json($res->content);
diag("res->content:", $order);
diag('order->{order_source}',$order->{order_source},'|');
ok($order->{order_source} eq $order_params->{order_source}, "order_source is what we created");
ok($order->{record_no} =~ /^[0-9]+$/, "order number is a number");

# try updating notes in order we just created
my $random_string = Data::Random::String->create_random_string(length=>'32', contains=>'alpha');
my $patch_params = {
  notes =>  $random_string,
};
$res = $test->request(PATCH $location,
                      'Content-Type' => 'application/json',
                       'Content'      => to_json($patch_params),
);
ok($res->is_success,'patch/update order')
  || diag("patch/update failed: ", $res->code);
# check notes were updated to what we think they should be updated to
$res = $test->request(GET $location);
ok( $res->is_success, 'get order we just updated');
#diag("content",$res->content);
$order = from_json($res->content);
ok( $order->{notes} eq $random_string, 'notes stored in order matches random string');

# ensure we can't update notes to 1 character. validation rule should prevent this
$patch_params = {
  notes =>  '1',
};
$res = $test->request(PATCH $location,
                      'Content-Type' => 'application/json',
                      'Content'      => to_json($patch_params),
);
ok($res->code == 422,'patch/update order with invalid note')
 || diag("wrong resonse code from failed patch:",$res->code);
diag("content",$res->content);
my $error = from_json($res->content);
ok($error->{notes} eq 'Notes must be at least 2 characters long', "check patch/update validation message")
  || diag("got wrong validation message");

# now try and delete the added order
$res = $test->request(DELETE $location);
ok($res->is_success, 'can delete order we just created');

# check order was deleted
$res = $test->request(GET $location);
ok( $res->code == 404, 'order we just deleted does not exist any more');
diag("resp>content:", from_json($res->content));

# test deleting whole collection - should return 405 Method not Allowed
$res = $test->request(DELETE '/so/orders');
ok( $res->code == 405, 'try deleting whole collection of so orders');
        

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
