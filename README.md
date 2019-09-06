# Lugstats (2.0)


***

The server stats utility for Lugdunon. Creates a HTML file showing the users currently online and the maximum number of players at one time.

Project based here: https://lugdunoncity.org/index.php/forum/lugstats

# Instructions:

1) Run "**lugstats.pl**" - This will create the default configuration file.
2) Edit **~/.lugstatsrc** and make following changes:


server_Name='**NewServer**' - The name of your server
gamelink='**DefaultURL**' - Link to your live server. Replace newserver with your server host name
outdir="**/var/www/html/lugstats**" - The file path to your web root - should not need to be changed if you have your webserver at the standard location.
webdir="**/lugstats/**" - The absolute web directory of the above
server_addr='**DefaultUrl**' - The REST interface for your server. Replace newserver with your server host name

3) Execute the following commands:

    cpan -i CPAN
    cpan -i File::Copy
    cpan -i HTTP::Tiny
    cpan -i Data::Dumper
    cpan -i LWP::Simple
    cpan -i JSON
    cpan -i String::Scanf

4) Create a crontab like this:

    */5 * * * * cd ~/lugstats;./lugstats.pl

This will poll every 5 minutes
