package Sirius::REST::API;
use Dancer2;
use Sirius::REST::API::Orders;

our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    return { 'title' => 'Sirius::REST::API' };
};

true;
