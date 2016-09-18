#!/usr/bin/perl

# Creates stats from the active Lugdunon server
#
# Change These Settings:
$SERVER_NAME="LugdunonCity";	# The name of your server
$GAMELINK="http://client.lugdunon.net/?server=lugdunoncity.org:41977"; # Link to your live server
$OUTDIR="/var/www/lugstats";	# The file path to your web root
$WEBDIR="/lugstats/";		# The absolute web directory of the above

# Probobly don't change below here
$LOGO="logoSmall.png";
$REVVER="1.0";
$MAX_FILE="maxfile.txt";

# Load our dependancies
use File::Copy qw(copy);

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

$first_row = 1;

$MAX_USERS = 0;
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
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
$year = substr($year, 1);
#printf("Time Format - HH:MM:SS\n");
$LAST_SEEN = sprintf("%02d/%02d/20%02d %02d:%02d:%02d", $mon, $mday, $year, $hour, $min, $sec);

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
<tr><td colspan = 2><center><h1><a href="$GAMELINK">$SERVER_NAME Server Stats</a></h1></center></td></tr>
<tr><td><b>User Name</b></td><td><b>Connect Time</b></td></tr>
END_MESSAGE
open(my $fh, '>', "index.html") or die "Could not open file 'index.html' $!";
print $fh $message;
my $NumUsers = 0;
@foo = ("User A", "User B", "User C", "User D", "User E");
foreach $curline (@foo)
{
	$NumUsers += 1;
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year = substr($year, 1);
	$LAST_SEEN = sprintf("%02d/%02d/20%02d %02d:%02d:%02d", $mon, $mday, $year, $hour, $min, $sec);
	print $fh "<tr><td width=250>$curline</td><td>$LAST_SEEN</td></tr>";
}
# Check for max users seen
$MAXIT = 0;
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
Version $REVVER - <b>Get This Utility At <a href=\"https://lugdunoncity.org/index.php/downloads-new/category/13-server\">Lugdunon City</a></b>
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

