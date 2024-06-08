#!/usr/bin/perl
#CALCULATE THE DIPEPTIDE COMPOSITION OF A PROTEIN SEQUENCE
#DIVIDE BY (LENGTH -1) OF SEQUENCE
#Data format for input

#-----------------
#>KNIR_DROVI:+1:MNQTCKVCGEPAAGF
#>KNIR_DROME:+1:MNQTC
#>KNRL_DROME:+1:MMNQDNPYAMNQTCKVCGEPA
#-----------------

$f_name=$ARGV[0];
$temp_name=$ARGV[1];
if($f_name eq '')#CHECK FOR INPUT AND OUTPUT FILES
{
    print "ERROR!\ndipeptide.pl input\n";
    exit;
}

open(FH,"$f_name") or die "$!";
while($line=<FH>)
{
    chomp($line);
   # @temp=split/\s+/,$line;
    @temp1=split(':',$line);
    open(FH2,">$temp_name") or die "$!";
    print FH2 "$temp1[0]\n$temp1[2]\n";
    close FH2;

    &dipep("$temp_name","$temp1[1]","$temp1[0]");
#    $r=<STDIN>;
}
close FH;


sub dipep
{

    my $in_name=$_[0];
    my $annotation=$_[1];
    my $name=$_[2];

    my $c=0;my $e=0; my $g=0;


    open(FH1,"$in_name") or die "!";
    $header=<FH1>;chomp($header);
    $body=<FH1>;chomp($body);
    close FH1;

    
    print "$name#$annotation#";
    my $len=length($body);
    #print "$len ";
    my @seq=split//,$body;
    
    my @amino=('A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y');
    
#GENERATE ALL 400 POSSIBLE DIPEPTIDES COMPOSITION


    for($a=0;$a<=$#amino;$a++)
    {
	for($b=0;$b<=$#amino;$b++)
	{
	    $dipep[$c]=$amino[$a].$amino[$b];
	    $c++;
	}
    }
#GENERATE ALL POSSIBLE DIPEPTIDES OF INPUT SEQUENCE
    for($d=0;$d<$#seq;$d++)
    {
	$seq_dipep[$e]=$seq[$d].$seq[$d+1];
	$e++;
    }
    
    for($g=0;$g<400;$g++)
    {
	$count[$g]=0;
    }
    
#CALCULATE FREQUENCEY OF EACH OF 400 DIPEPTIDES
    for($f=0;$f<=$#dipep;$f++)
    {
	#print "$dipep[$f]:";
	for($g=0;$g<=$#seq_dipep;$g++)
	{
	    if($seq_dipep[$g] eq $dipep[$f])
	    {

		$count[$f]++;
		#print "$seq_dipep[$g]:$dipep[$f]:$count[$f] ";
	    }
	}
	#print "$count[$f] ";
    }
    
#print "$len:";
    for($i=0,$j=1;$i<=$#count;$i++,$j++)
    {
	$normalized=($count[$i]/($len-1))*100;
	#print "$dipep[$i]:$count[$i]:";
	print "$j:";
	printf "%-5.2f ",$normalized;
	#$r=<STDIN>;
    }
    print "\n";
    @count=();
    @dipep=();
    @seq_dipep=();
    @amino=();

}
