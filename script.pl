#!/opt/local/bin/perl 

#TODO
# logging - done
# db connectivity
# state management

package MyPackageName;
$MyPackageName::VERSION = '0.01';  #see POD for history

# Author            : Alex Yelluas
# Created On        : 
# Last Modified By  : 
# Last Modified On  : 
# Update Count      : 
# Status            : 
# Purpose           :

use strict;
use warnings;

use Sys::Hostname;
# $host=hostname;

use Cwd;
use FindBin;
use Data::Dumper;
use Config::General;
use Getopt::Long;
use Log::Log4perl;
use File::Find;


# optional
# allows to get away from explicity 'do or die' 
# use autodie qw/open close/;

# bunldes all of IO modules into one, handles files, 
# sockets, DBM, etc., see perldoc
# use IO::All;

# use XML::Simple;                                                 
# use Date::Manip;                                                 
# use JSON::XS
# use Digest::MD5::File qw/file_md5_hex/;

# other
# unbuffered output,
# fyi - select sets default handle 
select(STDERR); $| = 1; 
select(STDOUT); $| = 1; 

my $options = {};

&main;

sub main {

  &init;

  print Dumper ($options);

  # this will 'fall through' to the default logger,
  # and will go to the file
  my $logger_file = Log::Log4perl->get_logger ('SomeLogger');
  # this will go to the 'someOtherLogger' since it's defined in the config
  my $logger_screen = Log::Log4perl->get_logger ('someOtherLogger');

  $logger_file->error ("root_logger: This is an info");

  $logger_screen->error ("screen_logger: This is an info");

}

sub init {

  # logging
  Log::Log4perl::init ("log4perl.conf");

  #Define custom 'warn' and 'die' handlers
  #local $SIG{__WARN__} = sub {
  #  #my $logger = Log::Log4perl->get_logger ('someOtherLogger');
  #  #$logger->warn ("OH NO! Look what happened:\n@_");
  #};

  # this will conflict with explicity die (exceptions)
  # use only if needed
  #local $SIG{__DIE__}  #= sub {
  #  ## good place to disconnect from the db
  #  ## $dbh-disconnect if $dbh;
  #  #my $logger = Log::Log4perl->get_logger ('someOtherLogger');
  #  #$logger->fatal ("I'm Dead, Jim!\n@_");
  #};

  # config file (simple usage, for more flexibility see perldoc)
  $options = {new Config::General ('config')->getall}; 

  # command line options
  # will overwrite whatever came from the config file

  #TODO this should be replaced with POD::Usage
  my $usage=<<EOF;
  usage: $0 [options]

  --help|h ........ help, prints this message
  --name|n ........ name (required) !!!
  --gender|g ...... gender
  --phone|p ....... phone
  --food|f ........ multiple values of food

  example:

  $0 --name Alex --gender male --phone 6505551212 --food pizza --food sushi  

EOF

  # list of options must be provided iether through config file or
  # command line options
  my @required = qw/weight height/; 
  my @errors;

  GetOptions ( "help|h"     => \$options->{help}, 
               "name|n=s"   => \$options->{name},
               "gender|g=s" => \$options->{gender}, 
               "phone|p=i"  => \$options->{phone},
               "food|f=s@"  => \$options->{food},
               "weight|w=s" => \$options->{weight},  
               "height|w=s" => \$options->{height},);  

  die $usage if ($options->{help});

  # make sure all required options are provided 
  foreach my $r_option (@required) {
    if (!defined $options->{$r_option}) {
      push @errors, "  \"$r_option\" is a required parameter\n";      
    }
  }
  if (scalar @errors > 0) {
    die "\n  Errors:\n@errors\n$usage";
  }


}



