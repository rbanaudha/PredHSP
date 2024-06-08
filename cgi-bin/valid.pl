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
$prog_dir = "/webservers/cgi-bin/predhsp";
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


system "/usr/bin/tr -d '\r' <$dir/seq.input >$dir/seq_meta.fasta";#Remove meta-character
system "/usr/bin/perl $prog_dir/fasta.pl $dir/seq_meta.fasta |/usr/bin/head -50 >$dir/input.fasta";#Convert two line fasta file and select only 25 sequence
system "/bin/grep -c '>' $dir/input.fasta >$dir/total_seq";
system "/bin/grep '>' $dir/input.fasta |/usr/bin/cut -d '|' -f3 |/usr/bin/cut -d ' ' -f1 >$dir/protein_id"; #Grep protein id
system "/usr/local/bin/hmmscan --domtblout $dir/hmm_out -E 1e-5 $prog_dir/Pfam/Pfam-A.hmm $dir/input.fasta >/dev/null";##
system "/usr/bin/perl $prog_dir/hmm.pl $dir/hmm_out |/bin/grep -v '#' >$dir/hmm_out_domain";##
system "/usr/bin/perl $prog_dir/evalue.pl $dir/hmm_out_domain |/usr/bin/cut -d ' ' -f1,2,3 |/usr/bin/tr '|' '#' >$dir/hmm_out_domain_evalue";##
system "/usr/bin/perl $prog_dir/id_compare.pl $dir/hmm_out_domain_evalue $dir/protein_id |/usr/bin/cut -d ' ' -f1,2 |/usr/bin/sort -u >$dir/domain_id";##
system "/usr/bin/perl $prog_dir/dipep.pl $dir/input.fasta >$dir/dipep_comp";
system "/bin/sed -e 's/^/+1 /' $dir/dipep_comp >$dir/final";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp_dipep_1st_level_model $dir/svm_score_leve1_hsp >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp20_dipep_model $dir/svm_score_leve2_hsp20 >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp40_dipep_model $dir/svm_score_leve2_hsp40 >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp60_dipep_model $dir/svm_score_leve2_hsp60 >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp70_dipep_model $dir/svm_score_leve2_hsp70 >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp90_dipep_model $dir/svm_score_leve2_hsp90 >/dev/null";
system "/usr/local/bin/svm_classify $dir/final $prog_dir/hsp100_dipep_model $dir/svm_score_leve2_hsp100 >/dev/null";
system "/usr/bin/paste $dir/protein_id $dir/final $dir/svm_score_leve1_hsp $dir/svm_score_leve2_hsp20 $dir/svm_score_leve2_hsp40 $dir/svm_score_leve2_hsp60 $dir/svm_score_leve2_hsp70 $dir/svm_score_leve2_hsp90 $dir/svm_score_leve2_hsp100 >$dir/final_svm";
system "/usr/bin/tr '\t' '#' <$dir/final_svm >$dir/final_file";
system "/usr/bin/perl $prog_dir/domain.pl $dir/final_file $dir/domain_id >$dir/final_pred";

open(FINAL_PRED,"$dir/final_pred") or die "$!";
while($pred=<FINAL_PRED>)
{
    chomp($pred);
    @svm=split(/#/,$pred);
    #print "$svm[2]\n";
    if($svm[2] < $svm_th)
    {
	open(RESULT,">>$dir/Result") or die "$!";
	print RESULT "$svm[0]\tNon-HSP\n";
	#print RESULT "$svm[0]\tNon-HSP\t$svm[9]\n";
	close RESULT;
    }
    else
    {
	if(($svm[3] > $svm[4])&&($svm[3] > $svm[5])&&($svm[3] > $svm[6])&&($svm[3] > $svm[7])&&($svm[3] > $svm[8]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP20 sub-family\t$svm[9]\n";
	    close RESULT;
	}
	if(($svm[4] > $svm[3])&&($svm[4] > $svm[5])&&($svm[4] > $svm[6])&&($svm[4] > $svm[7])&&($svm[4] > $svm[8]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP40 sub-family\t$svm[9]\n";
	    close RESULT;
	}
	if(($svm[5] > $svm[3])&&($svm[5] > $svm[4])&&($svm[5] > $svm[6])&&($svm[5] > $svm[7])&&($svm[5] > $svm[8]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP60 sub-family\t$svm[9]\n";
	    close RESULT;
	}
	if(($svm[6] > $svm[3])&&($svm[6] > $svm[4])&&($svm[6] > $svm[5])&&($svm[6] > $svm[7])&&($svm[6] > $svm[8]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP70 sub-family\t$svm[9]\n";
	    close RESULT;
	}
	if(($svm[7] > $svm[3])&&($svm[7] > $svm[4])&&($svm[7] > $svm[5])&&($svm[7] > $svm[6])&&($svm[7] > $svm[8]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP90 sub-family\t$svm[9]\n";
	    close RESULT;
	}
	if(($svm[8] > $svm[3])&&($svm[8] > $svm[4])&&($svm[8] > $svm[5])&&($svm[8] > $svm[6])&&($svm[8] > $svm[7]))
	{
	    open(RESULT,">>$dir/Result") or die "$!";
	    print RESULT "$svm[0]\tHSP100 sub-family\t$svm[9]\n";
	    close RESULT;
	}
    }
}
print  "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n";
print  "<html><HEAD>\n";
print  "<TITLE>PredHSP::Prediction Result</TITLE>\n";
print  "<META NAME=\"description\" CONTENT=\"PredHSP, University of Delhi South Campus, INDIA\">\n";
print  "</HEAD><body bgcolor=\"\#FFFFE0\">\n";
print  "<h2 ALIGN = \"CENTER\"> PredHSP Prediction Result</h2>\n";
print  "<HR ALIGN =\"CENTER\"> </HR>\n";
print  "<p align=\"center\"><font size=4 color=black><b>The submitted protein/proteins belongs to <font color='red'></p>";
print "<table border='1' width='400' align='center'><tr><th>Protein ID</th><th>Prediction</th><th>Pfam Domain</th></tr>";
open(PREDICTION,"$dir/Result") or die "$!";
while($pre=<PREDICTION>)
{
    chomp($pre);
    @pred=split(/\t/,$pre);
    print "<tr align='center'><td>$pred[0]</td><td>$pred[1]</td><td>$pred[2]</td></tr>";
}
print "</table>";
print "</font></b></font></p>\n";
print  "<p align=\"center\"><font size=3 color=black><b>Thanks for using PredHSP Prediction Server</b></font></p>\n";
print  "<p align=\"center\"><font size=3 color=black><b>If you have any problem or suggestions please contact <a href='mailto:manish@south.du.ac.in'>Dr. Manish Kumar</a></b></font>. Please mention your job number in any communication.</p></br>\n";
print  "<p ALIGN=\"CENTER\"><b>Your job number is <font color=\"red\">$ran</b></font></p>\n";
print  "</body>\n";
print  "</html>\n";
