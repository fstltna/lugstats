# Lugstats
===================

The server stats utility for Lugdunon. Creates a HTML file showing the users currently online and the maximum number of players at one time.

Project based here: https://lugdunoncity.org/index.php/downloads-new/category/13-server

# Instructions:

1) Edit lugstats.pl and make following changes:
	$SERVER_NAME="LugdunonCity";    # The name of your server
	$GAMELINK="http://client.lugdunon.net/?server=lugdunoncity.org:41977"; # Link to your live server
	$OUTDIR="/var/www/lugstats";    # The file path to your web root - may be /var/www/html/lugstats
	$WEBDIR="/lugstats/";           # The absolute web directory of the above

2) Create a crontab like this:
   >>>
	*/5 * * * * cd ~/lugstats;./lugstats.pl
   <<<
   This will poll every 5 minutes
