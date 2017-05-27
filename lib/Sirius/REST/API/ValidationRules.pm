package Sirius::REST::API::ValidationRules;

sub so_order {
  +{
    options => {
      stripwhite => 1,
    },
    prepare => {
      notes => {
        validator => sub {
          my $value = shift;
          if (length($value) >= 2) {
            return 1;
          } else {
            return (undef, "Notes must be at least 2 characters long");
          }
        },
      },
      customer_code => {
        validator => sub {
          my $customer_code = trim(shift);
          # string with no internal spaces
          if ($customer_code =~ /\s/) {
            return (undef, "Customer Code cannot contain spaces");
          } elsif (length($customer_code) < 1)  {
            return (undef,"Customer Code must be at least 1 character long");
          } elsif (length($customer_code) > 10) {
            return (undef,"Customer Code must be less than 10 characters long");
          }
        }
      },
    }
  }
}

1;
