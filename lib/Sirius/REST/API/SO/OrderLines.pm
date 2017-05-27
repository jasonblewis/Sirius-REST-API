package Sirius::REST::API::SO::OrderLines;

use Dancer2 appname => 'Sirius::REST::API';
use Dancer2::Plugin::DBIC;
use Dancer2::Plugin::DataTransposeValidator;
use Data::Dumper;

prefix '/so/orders/:order_source/:record_no/line_items' => sub {
  post '' => \&post_so_order_lines;
  get '' => \&get_so_order_lines;
  get '/:line_no' => \&get_so_order_line;
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

sub get_so_order_line() {
  # this returns a single order line
  my $order_source = route_parameters->get('order_source');
  my $record_no = route_parameters->get('record_no');
  my $line_no = route_parameters->get('line_no');
  my $order = schema->resultset('ZzSoEpsOrderStaging')->search(
    {'order_source' => $order_source,
     'record_no' => $record_no,
   }
  )->first;
  if ($order) {
    my $order_line = $order->order_lines->search({
      'line_no' => $line_no,
    })->hri->first;
    if ($order_line) {
      return  $order_line;
    } else {
      status 404;
      return;
      # should return order line number that was not found
    }
  } else {
    status 404;
    return {};
  }
}

sub post_so_order_lines() {

  my $order_line_params = body_parameters->as_hashref;
  my $order_line_data = validator($order_line_params,'so_order_line');
  # insert into the zz_eps_order line_staging table:
  my $order = schema->resultset('ZzSoEpsOrderStaging')->search({
    order_source => $order_line_data->{'order_source'},
    record_no    => $order_line_data->{'record_no'},
  })->first;
  my $order_line  = $order->order_line->create({
    our_product_code => $product_code,
    cust_prod_desc   => trim( $product->{description} ),
    unit             => $product->{unit},
    cust_ordered_qty => $qty,
    ordered_qty      => $qty,
    notes            => substr( param('notes_'.$product_code) || '', 0, 7745 ),
    
    # Im guessing these are the same
    cust_unit_price => $product->{UnitPrice},
    unit_price      => $product->{UnitPrice},
  });
  status 201;
  my $location = uri_for('/so/orders/' . $order->order_source . '/' . $order->record_no);
  response_header 'Location' => $location;

  return {};
};

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
