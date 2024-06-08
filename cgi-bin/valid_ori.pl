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
$svm_th = $query->param('svm_fpr');

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
#$dir="/webservers/cgi-bin/palmpred/temp/palm$ran";
$dir = "/webservers/cgidocs/mkumar/temp/vandana/palmpred/palm$ran";
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
#open(FG,"/usr/local/bin/readseq -a -C /$dir/$nam -f8 -o$dir/readseq.out|");
#close FG;

open(FH_FINAL,">$dir/seq.final") or die "$!";
open(FH_SEQ,"$dir/seq.input") or die "$!";
while($line_seq=<FH_SEQ>)
{
    chomp($line_seq);
    $line_seq=~ s/[^_>a-zA-Z0-9]//g;
    print FH_FINAL "$line_seq\n";
}
close FH_SEQ;
close FH_FINAL;




#system "/usr/local/bin/readseq -i1 -C /$dir/seq.final -f8 > $dir/readseq.out";
#system "cp $dir/$nam $dir/seq.final";

open(FP9,">>/webservers/cgidocs/mkumar/temp/vandana/palmpred/palm.que"); # BUILD LIST OF PENDING JOBS
#open(FP9,">>/webservers/cgi-bin/palmpred/temp/palm.que");
print FP9 "$dir:$svm_th:";

if($name ne '')
{
    print FP9 "$name\n";
}
else
{
        print FP9 "-\n";
}


close(FP9);


if(!defined($pid = fork)){
    die;
}
elsif(!$pid){
    close(STDIN);close(STDOUT);close(STDERR);
    sleep(30);
    system "/usr/bin/perl /webservers/cgi-bin/palmpred/run.pl $ran";
    exit;
}
else{


#    print  "<TITLE>PPRInt: A Server for Prediction of RNA-interacting residues</TITLE>\n";
#    print  "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html\; charset=koi8-r\">\n";

    print  "</head><body>\n";
    print  "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" class=\"tbl1\" width=\"100%\"><tr><td colspan=\"4\"></td></tr>\n";
    print  "<td width=\"92%\"><br><h2 ALIGN = \"CENTER\"> Sequence Submitted for Prediction</h2><HR ALIGN =\"CENTER\"> </HR>\n";

    print  "<font size=3 color=black ><b><center>Thanks for using PalmPred Web-server</center></b></font>";
    print  "<p>";
    print  "<font size=3 color=black><b><center>Your request is being processed. Please wait for a few minutes till the process completes. ";
    print  "If you have any problem or suggestions please contact Dr. Manish Kumar <a href='mailto:manish\@south.du.ac.in'><font size=4 color=red><b>[manish\@south.du.ac.in\]</b></font></a>.<p>Your job number is <font color=red>$ran</font>.<br></p></b>";
    print  "<p>";
#    print  "<meta http-equiv=\"refresh\" content=\"20;url=14.139.227.92/cgi-bin/palmpred/chkres?c=$ran\"></center>\n";
    print  "<meta http-equiv=\"refresh\" content=\"20;url=/cgi-bin/palmpred/chkres?c=$ran\"></center>\n";
    print  "</table><h2>&nbsp;</h2></td></tr></table>\n";
    print  "</body>";

}
