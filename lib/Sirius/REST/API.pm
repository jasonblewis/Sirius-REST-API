package Sirius::REST::API;
use Dancer2;
use Sirius::REST::API::SO::Orders;
use Sirius::REST::API::SO::OrderLines;
use Sirius::REST::API::Utils;

our $VERSION = '0.1';

set serializer => 'JSON';

get '/' => sub {
    return { 'title' => 'Sirius::REST::API' };
};

true;
