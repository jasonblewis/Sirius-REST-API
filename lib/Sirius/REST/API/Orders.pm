package Sirius::REST::API::Orders;

use Dancer2 appname => 'Sirius::REST::API';


prefix '/orders' => sub {
  get '' => sub {
    return {data => "hi"};
  };
};

true;
