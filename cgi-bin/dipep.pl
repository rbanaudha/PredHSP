#!/usr/bin/perl
                                                              
#Extract dipeptide sequence and its composition from FASTA FORMAT
#USAGE: perl dipep.pl <file name> |less

@dipep=('A','C','D','E','F','G','H','I','K','L','M','N','P','Q','R','S','T','V','W','Y');
#print "-----@dipep\n";

open(FH,"$ARGV[0]") or die "$!";
while($line=<FH>)
{
    chomp($line);
    $count = 0;
    #print "$line\n";                                                    

    $array[$a]=$line;
    $a++;
}
#print "=====@array\n";                                                  

for($b=0;$b<=$#array;$b++)
{
    if($array[$b]=~ m/^>/)
    {
	#print "$array[$b]\n";
        #$b++;
	@array_seq1=split(/\|/,$array[$b]);                                    
        #print ">$array_seq1[1]\n";  
	$seq=();
	while(($array[$b+1] !~ m/^>/)&&($b<=$#array))
	{
	    $seq="$seq"."$array[$b+1]";
            #print "===$seq\n";                                          
	    $b++;
	}
        #print "\n$b\n";                                                 
        #print "++++++++$seq\n";                                         
	
	@array_seq=split(//,$seq);
	#print "------@array_seq\n";
	
	for($d=0;$d<=$#dipep;$d++)
	{
	    for($e=0;$e<=$#dipep;$e++)
	    {
		$dipep_seq="$dipep[$d]"."$dipep[$e]";
		#print "$dipep_seq\n";
		
		for($c=0;$c<$#array_seq;$c++)
		{
		    $dipep_protein="$array_seq[$c]"."$array_seq[$c+1]";
		    #print "-$dipep_protein\t";
		    
		    if("$dipep_protein" eq "$dipep_seq")
		    {
			$dipep_count++;
			#print "++++++++=====$dipep_seq\t$dipep_protein\n";
		    }
		}
		$per=($dipep_count*100)/($#array_seq);
		#print "$per=($dipep_count*100)/($#array_seq)";
		#print "$dipep_count\t$per\n";
		$m++;
		print "$m:";
		printf "%4.2f ",$per;
		$dipep_count=0;
		#$R=<STDIN>;
	    }
	    #print "\t";
	}
	$m=0;
    }
    print "\n";
}
