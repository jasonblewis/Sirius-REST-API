package Sirius::REST::API::Utils;

use Exporter('import');
our @EXPORT_OK = qw(zz_next_number ltrim rtrim trim);


sub zz_next_number {
  my $schema = shift;
  my $sql = 'exec zz_next_number';
  my $dbh = $schema->storage->dbh;
  my $sth = $dbh->prepare($sql) or die "cant prepare\n";
  $sth->execute() or die $sth->errstr;
  my $number = $sth->fetch()->[0];
  $sth->finish;
  return $number;
}

sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s };
sub rtrim { my $s = shift; $s =~ s/\s+$//;       return $s };
sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };


1;
