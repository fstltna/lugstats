#!/usr/bin/perl
use strict;
use warnings;

#
# Creates stats from the active Lugdunon server
#

# Load our dependancies
use File::Copy qw(copy);
use HTTP::Tiny;
use Data::Dumper qw(Dumper);
use LWP::Simple;
use JSON qw( decode_json );
use String::Scanf;

my $LOGO="logoSmall.png";
my $REVVER="2.0";
my $MAX_FILE="maxfile.txt";
my $MySettings = "$ENV{'HOME'}/.lugstatsrc";
my $SERVER_NAME="Default Server Name";	# The name of your server
my $GAMELINK="http://client.lugdunon.net/?server=newserver.lugdunoncity.org:41976"; # Link to your live server
my $OUTDIR="/var/www/html/lugstats";	# The file path to your web root
my $WEBDIR="/lugstats/";		# The absolute web directory of the above
my $SERVER_ADDR="http://newserver.lugdunoncity.org:41976/rest/net/lugdunon/players";
my $MAX_DATE = "";
my $decoded_json = "";
my $usertype="";

# Check for config file
if (-f $MySettings)
{
	# Read in settings
	open (my $FH, "<", $MySettings) or die "Could not read default file '$MySettings' $!";
	while (<$FH>)
	{
		chop();
		my ($Command, $Setting) = split(/=/, $_);
		if ($Command eq "server_name")
		{
			$SERVER_NAME = $Setting;
		}
		if ($Command eq "gamelink")
		{
			$GAMELINK = $Setting;
		}
		if ($Command eq "outdir")
		{
			$OUTDIR = $Setting;
		}
		if ($Command eq "webdir")
		{
			$WEBDIR = $Setting;
		}
		if ($Command eq "server_addr")
		{
			$SERVER_ADDR = $Setting;
		}
	}
	close($FH);
}
else
{
	# Store defaults
	open (my $FH, ">", $MySettings) or die "Could not create default file '$MySettings' $!";

	print $FH "server_name='$SERVER_NAME'\n";
	print $FH "gamelink='$GAMELINK'\n";
	print $FH "outdir=$OUTDIR\n";
	print $FH "webdir=$WEBDIR\n";
	print $FH "server_addr=$SERVER_ADDR\n";
	close($FH);
	print "Settings file created - please run the script again after editing the settings at '$MySettings'.\n";
	exit 0;
}

# Code below here
if (-e $OUTDIR and -d $OUTDIR)
{
	#print("$OUTDIR exists\n");
}
else
{
	#print("Creating $OUTDIR\n");
	mkdir $OUTDIR;
}

# Copy in logo
copy $LOGO, $OUTDIR;

my $first_row = 1;

my $MAX_USERS = 0;
if (-f $MAX_FILE)
{
	open(my $maxfh, '<', "$MAX_FILE") or die "Could not open file '$MAX_FILE' $!";
	while (my $row = <$maxfh>) {
		chomp $row;
		if ($first_row == 1)
		{
			$MAX_USERS = $row;
			$first_row = 2;
		}
		else
		{
			$MAX_DATE = $row;
		}
	}
	close($maxfh);
}
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year = substr($year, 1);
my $LAST_SEEN = localtime();

# Write out HTML
my $message = <<"END_MESSAGE";
<html>
<head>
<title>Lugdunon Stats For Server $SERVER_NAME</title>
<style>
body {
	background-color: #FCD757
}
</style>
<meta name="description" 
      content="Displays the users currently logged into the server">
<meta name="author" content="Marisa Giancarla">
<meta charset="UTF-8">
<meta name="keywords" content="lugdunon, utility, script, server">
<meta property="og:title" content="Lugdunon Stats">
<meta property="og:image" content="$WEBDIR$LOGO">
<meta property="og:description" content="Displays the users currently logged into the server">
<meta http-equiv="refresh" content="600">
<link rel="copyright" href="https://LugdunonCity.org/copyright.html">
</head>
<body>
<img src="$WEBDIR$LOGO"><br>
Last Scanned: $LAST_SEEN
<table border=1>
<tr><td colspan = 3><center><h1><a href="$GAMELINK">$SERVER_NAME Server Stats</a></h1></center></td></tr>
<tr><td><b>User Name</b></td><td><b>Connect Time</b></td><td><b>Time Played</b></td></tr>
END_MESSAGE

# Pull in server data
#my $client = REST::Client->new();
#$client->GET($SERVER_ADDR);
#print $client->responseContent();
###
my $response = HTTP::Tiny->new->get($SERVER_ADDR);
if ($response->{success})
{
    my $html = $response->{content};
    my @LINES = split /\n/, $html;
    chomp(@LINES);
    #print("Lines: '@LINES'\n");
    #($a, $b) = sscanf("'{\"players\":%s", @LINES);
    $decoded_json = decode_json($html);
    #print Dumper $decoded_json;
}
else
{
    print "Failed: $response->{status} $response->{reasons}";
}

open(my $fh, '>', "index.html") or die "Could not open file 'index.html' $!";
print $fh $message;
my $NumUsers = 0;
foreach (@{ $decoded_json->{players} })
{
    if ($_->{currentlyOnline} != 0)
    {
	my $user = $_->{name};
	my $time = scalar localtime($_->{lastPlayed}/1000); # ZZZ
	my $timePlayed = sprintf("%02.2d minutes", $_->{timePlayed} / 60000);
	$NumUsers += 1;
	if ($usertype eq "admin")
	{
		print $fh "<tr><td width=250><font color=\"green\">*$user</font></td><td>$time</td><td>$timePlayed</td></tr>";
	}
	else
	{
		print $fh "<tr><td width=250>$user</td><td>$time</td><td>$timePlayed</td></tr>";
	}
    }
}
# Check for max users seen
my $MAXIT = 0;
if ($NumUsers > $MAX_USERS)
{
	$MAX_USERS = $NumUsers;
	$MAX_DATE = localtime();
	$MAXIT = 1;
}

print $fh "</table>
<hr>
Max Users: $MAX_USERS - $MAX_DATE<br>
<font color=\"green\">* Game Operators</font>
<hr>
Version $REVVER - Get This Utility At <a href=\"https://lugdunoncity.org/index.php/downloads-new/category/13-server\">Lugdunon City</a>
</body>
</html>";
close $fh;
copy "index.html", $OUTDIR;
if ($MAXIT > 0)
{
	open(my $maxfh, '>', "$MAX_FILE") or die "Could not open file '$MAX_FILE' $!";
	print $maxfh "$MAX_USERS\n";
	print $maxfh "$MAX_DATE\n";
	close $maxfh;
}
exit(0);

