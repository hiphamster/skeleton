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
use DBI;
use DBD::SQLite;


my $options = {};

&main;

sub main {

  &init;

  # my $logger_file = Log::Log4perl->get_logger ('SomeLogger');
  # my $logger_screen = Log::Log4perl->get_logger ('screenLogger');
  # $logger_screen->info (Dumper ($options));
  # $logger_screen->info ("foo");

  &sql_lite;


}

sub init {

  # logging
  Log::Log4perl::init ("log4perl.conf");

  # config file (simple usage, for more flexibility see perldoc)
  $options = {new Config::General ('config')->getall}; 

  # command line options
  # will overwrite whatever came from the config file

  #TODO this should be replaced with POD::Usage
  my $usage=<<EOF;
  usage: $0 [options]

  --help|h ........ help, prints this message
  --db_name|db .....name - REQUIRED 

  example:

  $0 --name Alex --db_name my_db

EOF

  # list of options must be provided iether through config file or
  # command line options
  my @required = qw/db_name/; 
  my @errors;

  GetOptions ( "help|h"     => \$options->{help}, 
               "db_name|db=s" => \$options->{db_name},);  

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

sub sql_lite {

  # connect to db
  # create a table
  # load data
  # query data
  
  my $create_table = " 
CREATE TABLE IF NOT EXISTS DEPARTMENT (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  NAME VARCHAR (20) NOT NULL,
  NOTES VARCHAR (100);
)";

  my $dbh_options = {
    # turns off automatic error output (on stderr)
    PrintError => 0,
    # cause errors to be raised as exceptions (via die)
    RaiseError => 1,
  };

  my $db = $options->{db_name};
  my $dbh = DBI->connect ("dbi:SQLite:dbname=$db", "","", $dbh_options ); 
  eval {
    $dbh->do ($create_table);
  };
  if ($@) {
    chomp $@;
    warn "Warning: $@\n";
  }

  $dbh->disconnect;
 
   






}
__DATA__

/* department table */
CREATE TABLE IF NOT EXISTS DEPARTMENT (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  NAME VARCHAR (20) NOT NULL,
  NOTES VARCHAR (100)
);

/* department table */
CREATE TABLE IF NOT EXISTS EMPLOYEE (
  ID INTEGER PRIMARY KEY AUTOINCREMENT,
  /* FK */
  DEPARTMENT_ID INTEGER NOT NULL,
  FNAME VARCHAR (20) NOT NULL,
  LNAME VARCHAR (20) NOT NULL,
  IS_MANAGER TINYINT, 
  SSN INTEGER, 
  NOTES VARCHAR (100),

  /* FK CONSTRAINT */
  FOREIGN KEY (DEPARTMENT_ID) REFERENCES DEPARTMENT (ID)
);
