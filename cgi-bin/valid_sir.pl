#!/usr/bin/perl

############################### Header Information ##############################
require 'cgi.perl';
use CGI;;
$query = new CGI;
&ReadParse;
print &PrintHeader;
################################ Reads Input Data ##############################
$name = $query->param('name');
#$email = $query->param('email');
$seq = $query->param('seq');
$file = $query->param('file');
$svm_th = $query->param('svm_th');

#################Validation Of Input Sequence Data (file upload) ###################################
if($file ne '' && $seq eq '')
{
    $file=~m/^.*(\\|\/)(.*)/; 
    while(<$file>) 
    {
	$seqfi .= $_;
    }
}
elsif($seq ne '' && $file eq ''){

    $seqfi="$seq";
}

##############ACTUAL PROCESS BEGINS FROM HERE#######################
$ran= int(rand 10000);
#$dir = "/webservers/cgidocs/mkumar/temp/manish/predhsp/hsp$ran";
$dir = "/webservers/cgidocs/mkumar/temp/Ravindra/PredHSP/hsp$ran";
system "mkdir $dir";
system "chmod 777 $dir";

$nam = "seq".".input";
open(FP1,">$dir/$nam");
if($seqfi !~ m/\>/)
{
    print FP1 ">seq\n";
}
print FP1 "$seqfi\n";
close FP1;


#system "/usr/bin/seqret -sequence $dir/seq.input -outseq $dir/seq.seqret";

#system "cat $dir/seq.seqret|cut -d ' ' -f1 |tr '\n' '#' |tr '>' '\n' |sed -e 's/#/:+1:/' -e 's/#//g' |tail -n +2 > $dir/seq.final";
system "cat $dir/seq.input|cut -d ' ' -f1 |tr '\n' '#' |tr '>' '\n' |sed -e 's/#/:+1:/' -e 's/#//g' |tail -n +2 > $dir/seq.final";

if(!defined($pid = fork))
{
    die;
}
elsif(!$pid)
{
    close(STDIN);close(STDOUT);close(STDERR);
    sleep(30);
    &prediction();
    exit;
}
else
{
    print  "</head><body>\n";
    print  "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"tbl1\" width=\"100%\"><tr><td colspan=\"4\"></td></tr>\n";
    print  "<td width=\"92%\"><br><h2 ALIGN = \"CENTER\"> Sequence Submitted for Prediction</h2><HR AIGN =\"CENTER\"> </HR>\n";
    
    print  "<font size=3 color=black ><b><center>Thanks for using PredHSP Web-server</center></b></font>";
    print  "<p>";
    print  "<font size=3 color=black><b><center>Your request is being processed. Please wait for a few moments till the process completes. ";
    print  "If you have any problem or suggestions please contact Dr. Manish Kumar <a href='mailto:manish\@south.du.ac.in'><font size=4 color=red><b>[manish\@south.du.ac.in\]</b></font></a>.<p>Your job number is <font color=red>$ran</font>.<br></p></b>";
    print  "<p>";
    print  "<meta http-equiv=\"refresh\" content=\"20;url=/cgi-bin/predhsp/chkres?c=$ran\"></center>\n";
    print  "</table><h2>&nbsp;</h2></td></tr></table>\n";
    print  "</body>";
}

sub prediction
{
    $count=0;
    open(OUTPUT,">$dir/result_temp") or die "$!";
    print OUTPUT "<html><title>prediction result</title><body><p>Thanks for using PredHSP. Followings are the result of prediction:</p><table border='2'><tr><th1>Sr. No.</th1><th2>Name</th2><th3>SVM score</th3><th4>Prediction</th3></tr>";

    system "/usr/bin/perl dipeptide.pl $dir/seq.final $dir/temp> $dir/seq.dipep";
    
    @models=('hsp100_dipep_model','hsp20_dipep_model','hsp40_dipep_model','hsp60_dipep_model','hsp70_dipep_model','hsp90_dipep_model');
    @model_name=('HSP100','HSP20','HSP40','HSP60','HSP70','HSP90');

    

    open(INPUT,"$dir/seq.dipep") or die "$!";
    while($line=<INPUT>)
    {
	$count++;
	print OUTPUT "<tr><td>$count</td>";
	print "<tr><td>$count</td>";
	chomp($line);
	@temp_dp=split('#',$line);
	print OUTPUT "<td>$temp_dp[0]<td>";
	print "<td>$temp_dp[0]<td>";
	open(DIPEP_TEMP,">$dir/temp_dipep") or die "$!";
	print DIPEP_TEMP "$temp_dp[1] $temp_dp[2]\n";
	close DIPEP_TEMP;
	
	system "/usr/local/bin/svm_classify $dir/temp_dipep /webservers/cgi-bin/predhsp/hsp_dipep_1st_level_model $dir/1st_level_prediction > /dev/null";
	$first_level_svm_score= `/usr/bin/head -1 $dir/1st_level_prediction` ;
	chomp($first_level_svm_score);
	print "$first_level_svm_score";
	
	open(FH,">$dir/svm.out") or die "$!";
	if($first_level_svm_score < $svm_th)
	{
	    print OUTPUT "<td>$svm_th</td><td> Not HSP<td></tr>";
	    print "<td>$svm_th Not HSP<td></tr>";
	}
	elsif($first_level_svm_score >= $svm_th)
	{
	    print "==> $svm_th HSP";
	    for($a=0;$a<=$#models;$a++)
	    {
		system "/usr/local/bin/svm_classify $dir/temp_dipep /webservers/cgi-bin/predhsp/$models[$a] $dir/prediction > /dev/null";
		$second_level_svm_score= `/usr/bin/head -1 $dir/prediction` ;
		chomp($second_level_svm_score);
		print FH "$second_level_svm_score:$model_name[$a]\n";
	    }
	    $max_score=`/usr/bin/sort -nrk 1 -t ':' $dir/svm.out|head -1`;
	    chomp($max_score);
	    print "<br> $max_score <br>";
	    @temp_score=split(':',$max_score);
	    print OUTPUT "<td>$temp_score[0]</td><td>$temp_score[1]</td></tr>";
	    #print OUTPUT "<td> $max_score</td></tr>";
	}
	
    }
    close INPUT;
    print OUTPUT "</table></body></html>";
    close OUTPUT;
    close FH;
    #system "mv $dir/result_temp $dir/result.html";
    system "mv $dir/result_temp $dir/final_result";
}
#system "chmod 000 $dir";
