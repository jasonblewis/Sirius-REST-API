package Sirius::REST::API::SO::OrderLines;

use Dancer2 appname => 'Sirius::REST::API';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::DataTransposeValidator;
use Data::Dumper;

prefix '/so/orders/:order_source/:record_no/line_items' => sub {
#  post '' => \&post_so_orders;
  get '' => \&get_so_order_lines;
#  get '/:order_source/:record_no' => \&get_so_order;
#  patch '' => sub { status 405; return };
#  patch '/:order_source/:record_no' => \&patch_so_order;
#  del '' => sub { status 405 ; return};
#  del '/:order_source/:record_no' => \&delete_so_order;
};

# sub zz_next_number {
#   my $sql = 'exec zz_next_number';
#   my $dbh = schema->storage->dbh;
#   my $sth = $dbh->prepare($sql) or die "cant prepare\n";
#   $sth->execute() or die $sth->errstr;
#   my $number = $sth->fetch()->[0];
#   $sth->finish;
#   return $number;
# };

sub get_so_order_lines {
  my $order_source = route_parameters->get('order_source');
  my $record_no = route_parameters->get('record_no');

  my $rs = schema->resultset('ZzSoEpsOrderStaging')->search({
    'record_no' => $record_no,
    'order_source' => $order_source,
  })->first;
  if ($rs) {
    return [$rs->order_lines->hri->all];
  } else {
    status 404;
    return;
  }
}

# sub get_so_order() {
#   # this returns a single order
#   my $order_source = route_parameters->get('order_source');
#   my $record_no = route_parameters->get('record_no');
#   my $order = schema->resultset('ZzSoEpsOrderStaging')->search(
#     {'order_source' => $order_source,
#      'record_no' => $record_no,
#    }
#   )->hri->first;
#   if ($order) {
#     $order->{order_source} =~ s/\s+$//;
#     return  $order;
#   } else {
#     status 404;
#     return {};
#   }
# }

# sub post_so_orders() {
#   my $zz_next_number = zz_next_number;
#   my $code = 'ABCXYZ';
#   my $customer_name = 'Jason Lewis';
#   # insert into the zz_order table:
#   my $order = schema->resultset('ZzSoEpsOrderStaging')->create({
#     order_source       => 'jason',
#     record_no          => $zz_next_number,
#     u_version          => '!',
#     customer_code      => $code,
#     our_cust_code      => $code,
#     cust_order_date    => \'getdate()',
#     customer_name      => $customer_name,
#     branch_code        => 'A',    # always A according to Jason Lewis
#     cust_order_nr      => 'eps order',
#     urgent_flag        => 'N',
#     number_of_lines    => 0,
#     order_created_flag => 'N',
#   });
#   status 201;
#   my $location = uri_for('/so/orders/' . $order->order_source . '/' . $order->record_no);
#   response_header 'Location' => $location;

#   return {};
# };

# sub delete_so_order() {
#   my $order_source = route_parameters->get('order_source');
#   my $record_no = route_parameters->get('record_no');

#   # check if order exists:
  
#   my $result = schema->resultset('ZzSoEpsOrderStaging')->search({
#     'record_no' => $record_no,
#     'order_source' => $order_source,}
#   )->first;
#   if ($result) {
#     $result->delete;
#     return;
#   } else {
#     status 404;
#     return;
#   }
# };

# sub patch_so_order() {
#   my $order_source = route_parameters->get('order_source');
#   my $record_no = route_parameters->get('record_no');
#   my $params = body_parameters->as_hashref;

#   my $rs = schema->resultset('ZzSoEpsOrderStaging')->search({
#     'record_no' => $record_no,
#     'order_source' => $order_source,} )->first;
#   unless ($rs) {
#     status 404;
#     return;
#   } else {
#     my $data = validator($params,'order');
#     if ($data->{valid}) {
#       # we have valid data - ok to update
#       $rs->update( {
#         notes => $data->{values}->{notes},
#       });
#       return;
#     } else {
#       status 422;
#       return $data->{errors};
#     } 
#   }

# }

true;