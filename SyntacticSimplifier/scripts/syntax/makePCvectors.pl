use English;
use strict;
use PotentialCoordinatorVectors;
binmode STDIN, ':encoding(UTF-8)'; 
binmode STDOUT, ':encoding(UTF-8)';

my $input_file = @ARGV[0];
my $file_label;
my $output_file;
my $output_dir="./";

#open my $info, $input_file or die "Could not open $input_file: $!";
#open(my $info,'<:encoding(iso-8859-1)',$input_file);
#open(my $info,$input_file);
#while( my $line = <$info>)  {
while( my $line = <STDIN>)  {      
    chomp($line);
    if ($line =~ /^\{(.+)(\[[^\]]+\])(.+)\} [0-9]+ ([0-9A-Za-z]+)$/){
        my $sent="$1$2$3";
        my $marker=$2;
        my $tag=$4;
        my $fv=PotentialCoordinatorVectors::potential_coordinator_vector($sent);
        print "$marker $fv $tag\n";
	#print "$marker $tag $sent\n"
    }
    #print "$line";
    #last if $. == 20;
}
#close $info;
