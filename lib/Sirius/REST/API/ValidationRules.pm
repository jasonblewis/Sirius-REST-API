package Sirius::REST::API::ValidationRules;

sub order {
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
      }
    }
  }
}

1;
