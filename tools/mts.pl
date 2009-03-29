#!/usr/bin/perl

use strict;
use warnings;
use Data::Dumper;

# get phone number into consistent shape
sub normalise_phone($) {
	my $phn = shift;
	return $phn			if ($phn =~ m/[^\d\+]/);	# not digits or plus -- return string as is
	return $phn			if (length($phn) < 7);		# too short for real number -- either a service or error
	return $phn			if ($phn =~ m/^\+\d{10}/);	# starts with '+' and at least 10 digits
	return '+7495'.$phn	if ($phn =~ m/^\d{7}$/);	# 7 straight digits is  Moscow 495
	return '+7'.$1		if ($phn =~ m/^8(\d{10})/);	# starts with 8 and 11 digits is dialed thru '8'
	return '+'.$phn		if ($phn =~ m/^7\d{10}/);	# missing prefix
	return '+7'.$1		if ($phn =~ m/^0008(\d{10})/);	# called abroad with '00' or '000' prefix
	return $1			if ($phn =~ m/^000(\+\d+)$/);	# same, with a variety
	return '+'.$phn;								# if nothing else helps...
}


sub read_file ($) {
	my $fh;
	open($fh, '<', shift) or die "Spooky: $!\n";
	local $/ = '';
	my $data = <$fh>;
	close $fh;
	return \$data;
}

my $data = read_file ('Detail_for_277340894206.html');
#$$data =~ s{<table[^>]*>(.)</table>}{
#	print $1;
#}egmx;


#exit;

my $dt = 0;
my $tr = 0;
my $td = 0;
my %db;
my %row;
my $fh;
while (split(/\n/, $data)) {
	$dt = 1 if (/^<table width="770" border="2" cellspacing="0" align="center"/);
	$dt = 0 if (/<\/table>/);
	if ($dt) {
		$tr = 1 if (/^<tr style="font-weight: normal; font-size: 7pt;">/ && $dt);
		
		if (/^<\/tr>/) {
			$db{$row{'phone'}} = () unless defined($db{$row{'phone'}});
			push @{$db{$row{'phone'}}}, [%row];
			if (0) {
			$db{$row{'phone'}}{$row{'service'}}{$row{'dir'}}{'num_calls'}++;
			$db{$row{'phone'}}{$row{'service'}}{$row{'dir'}}{'total_cost'} += $row{'cost'};
			$db{$row{'phone'}}{$row{'service'}}{$row{'dir'}}{'total_vol'} += $row{'volume'};
			$db{$row{'phone'}}{$row{'year'}}{$row{'service'}}{$row{'dir'}}{'num_calls'}++;
			$db{$row{'phone'}}{$row{'year'}}{$row{'service'}}{$row{'dir'}}{'total_cost'} += $row{'cost'};
			$db{$row{'phone'}}{$row{'year'}}{$row{'service'}}{$row{'dir'}}{'total_vol'} += $row{'volume'};
			$db{$row{'phone'}}{$row{'year'}.'-'.$row{'month'}}{$row{'service'}}{$row{'dir'}}{'num_calls'}++;
			$db{$row{'phone'}}{$row{'year'}.'-'.$row{'month'}}{$row{'service'}}{$row{'dir'}}{'total_cost'} += $row{'cost'};
			$db{$row{'phone'}}{$row{'year'}.'-'.$row{'month'}}{$row{'service'}}{$row{'dir'}}{'total_vol'} += $row{'volume'};
			}
			#print "\n";
			$td = $tr = 0;
			%row = undef;
		}
		
		if ($tr) {
			if (/^<td[^<]*>(.*)</) {
				my $f = $1;
				if ($td == 0) {
					$f =~ m{(\d+)\.(\d+)\.(\d+)};
					#print "$3-$2-$1";
					$row{'date'} = "$3-$2-$1";
					$row{'year'} = $3;
					$row{'month'} = $2;
					$row{'day'} = $1;
				} elsif ($td == 1) {
					$row{'time'} = $1;
				} elsif ($td == 2) {
					my $dir = 'OUT';
					$dir = 'IN' if ($f =~ m/^&lt;--(.+)$/);
					#print "$dir\t" . normalise_phone( ($1 ? $1 : $f) );
					$row{'dir'} = $dir;
					$row{'phone'} = normalise_phone( ($1 ? $1 : $f) );
				} elsif ($td == 5) {
					#print "$f\t";
					$row{'service'} = $1;
				} elsif ($td == 7) {
					my $vol;
					if ($f =~ m/(\d+):(\d+)/) {
						$vol = $1 * 60 + $2 * 1;
					} elsif ($f =~ m/(\d+)Kb$/) {
						$vol = $1 * 1024;
					} else {
						$vol = $f;
					}
					#print "$vol\t";
					$row{'volume'} = $vol;
				} elsif ($td == 8) {
					$row{'cost'} = $f;
				} else {
					#print $1;
				}
				#print "\t";
				$td++;
			}
		}
	}
}

print Dumper($db{'+442074772477'});

sub bla {
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2008'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2008-09'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2008-10'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2008-11'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2008-12'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print "---\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2009'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2009-01'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2009-02'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'2009-03'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	
	print '+442074772477: '.  $db{'+442074772477'}{'2009-02'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
	print '+79857692793: '.   $db{'+79857692793'}{'2009-02'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
	
	print '+442074772477: '.  $db{'+442074772477'}{'2009'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
	print '+79857692793: '.   $db{'+79857692793'}{'2009'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
	
	print 'internet.mts.ru: '.$db{'internet.mts.ru'}{'gprs'}{'OUT'}{'total_cost'}."\n";
	print '+442074772477: '.  $db{'+442074772477'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
	print '+79857692793: '.   $db{'+79857692793'}{'Телеф.'}{'OUT'}{'total_cost'}."\n";
}