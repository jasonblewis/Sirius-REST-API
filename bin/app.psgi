#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";


# use this block if you don't need middleware, and only have a single target Dancer app to run here
use Sirius::REST::API;

Sirius::REST::API->to_app;

use Plack::Builder;

builder {
    enable 'Deflater';
    Sirius::REST::API->to_app;
}



=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Sirius::REST::API;
use Plack::Builder;

builder {
    enable 'Deflater';
    Sirius::REST::API->to_app;
}

=end comment

=cut

=begin comment
# use this block if you want to include middleware such as Plack::Middleware::Deflater

use Sirius::REST::API;
use Sirius::REST::API_admin;

builder {
    mount '/'      => Sirius::REST::API->to_app;
    mount '/admin'      => Sirius::REST::API_admin->to_app;
}

=end comment

=cut

