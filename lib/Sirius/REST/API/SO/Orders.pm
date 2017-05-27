package Sirius::REST::API::SO::Orders;

use Dancer2 appname => 'Sirius::REST::API';
use Dancer2::Plugin::DBIC;
use Data::Dumper;

prefix '/so/orders' => sub {
  get '' => \&get_so_orders;
  get '/:order_source/:record_no' => \&get_so_order;
  post '' => \&post_so_orders;
  del '' => sub { status 405 };
  del '/:order_source/:record_no' => \&delete_so_order;
};

sub zz_next_number {
  my $sql = 'exec zz_next_number';
  my $dbh = schema->storage->dbh;
  my $sth = $dbh->prepare($sql) or die "cant prepare\n";
  $sth->execute() or die $sth->errstr;
  my $number = $sth->fetch()->[0];
  $sth->finish;
  return $number;
};

sub get_so_orders() {
  my $rs = [schema->resultset('ZzSoEpsOrderStaging')->search()->hri->all];
  return $rs;
};

sub get_so_order() {
  # this returns a single order
  my $order_source = route_parameters->get('order_source');
  my $record_no = route_parameters->get('record_no');
  my $order = schema->resultset('ZzSoEpsOrderStaging')->search(
    {'order_source' => $order_source,
     'record_no' => $record_no,
   }
  )->hri->first;
  if ($order) {
    $order->{order_source} =~ s/\s+$//;
    return  $order;
  } else {
    status 404;
    return {};
  }
}

sub post_so_orders() {
  my $zz_next_number = zz_next_number;
  debug "zz_next_number:", $zz_next_number;
  my $code = 'ABCXYZ';
  my $customer_name = 'Jason Lewis';
  # insert into the zz_order table:
  my $order = schema->resultset('ZzSoEpsOrderStaging')->create({
    order_source       => 'jason',
    record_no          => $zz_next_number,
    u_version          => '!',
    customer_code      => $code,
    our_cust_code      => $code,
    cust_order_date    => \'getdate()',
    customer_name      => $customer_name,
    branch_code        => 'A',    # always A according to Jason Lewis
    cust_order_nr      => 'eps order',
    urgent_flag        => 'N',
    number_of_lines    => 0,
    order_created_flag => 'N',
  });
  debug "order->id: ",$order->id, ref($order->id);
  status 201;
  my $location = uri_for('/so/orders/' . $order->order_source . '/' . $order->record_no);
  response_header 'Location' => $location;

  return {};
};

sub delete_so_order() {
  my $order_source = route_parameters->get('order_source');
  my $record_no = route_parameters->get('record_no');

  # check if order exists:
  
  my $result = schema->resultset('ZzSoEpsOrderStaging')->search(
    'record_no' => $record_no,
    'order_source' => $order_source,
  )->first;
  if ($result) {
    $result->delete;
    return;
  } else {
    status 404;
  }
};

true;
