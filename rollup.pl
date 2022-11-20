#!/usr/bin/env perl
# SPDX-License-Identifier: MIT

use 5.03000;
use strict;
use DBI;

my $driver = 'mysql';
my $database = 'INVENTORY_USAGE';
my $dsn = "DBI:$driver:database=$database;mysql_client_found_rows=1;mysql_server_prepare=1";
my $user = 'inventory';
my $pass = 'viasat';

my $dbh = DBI->connect( $dsn, $user, $pass, {RaiseError => 1} )
    || die "Error connecting to DB: ".$DBI::errstr;

my @usage_data = do{local(@ARGV) = shift; <>};
chomp @usage_data;
my $main_table;
my $field_list;
my $headers = shift @usage_data;
if ( ( split /½/, $headers )[0] =~ /InstallDate/ )
{
    $main_table = 'InventoryIssue_Serialized';
    $field_list = join ',', qw{date techId itemId serial};
}
elsif ( ( split /½/, $headers )[0] =~ /TransactionDate/ )
{
    $main_table = 'InventoryIssue_Callout';
    $field_list = join ',', qw{date techId itemId quantity};
}
else {
    die "Unknown input file type";
}

my %sth = (
    find_tech         => $dbh->prepare( q{UPDATE Technician SET code=? WHERE code=?;} ),
    insert_tech       => $dbh->prepare( q{INSERT INTO Technician (name, code) VALUES (?,?);} ),
    find_item_class   => $dbh->prepare( q{SELECT id FROM ItemClass WHERE name=? LIMIT 1;} ),
    insert_item_class => $dbh->prepare( q{INSERT INTO ItemClass (name) VALUES (?);} ),
    find_item         => $dbh->prepare( q{SELECT id FROM Item WHERE name=? AND classId=? LIMIT 1;} ),
    insert_item       => $dbh->prepare( q{INSERT INTO Item (name, classId) VALUES (?,?);} ),
    insert_event      => $dbh->prepare( qq{INSERT IGNORE INTO $main_table ($field_list) VALUES (?,?,?,?);} ),
);

sub date_to_ISO8601
{
    return sprintf q{%3$4u-%1$02u-%2$02u}, (split '/', shift);
}

sub get_tech_id
{
    my ( $tech_name, $tech_code ) = @_;
    my $found = $sth{'find_tech'}->execute( $tech_code, $tech_code);
    return $tech_code if ( $found and 1 == $found);
    $found = $sth{'insert_tech'}->execute( $tech_name, $tech_code );
    return $tech_code if ($found);
}

sub get_class_id
{
    my $class_name = shift;
    my $row = $sth{'find_item_class'}->execute( $class_name );
    return $sth{'find_item_class'}->fetchrow_hashref('NAME_lc')->{'id'} if ( $row and 1 == $row );
    $row = $sth{'insert_item_class'}->execute( $class_name );
    return $sth{'insert_item_class'}->{'mysql_insertid'};
}

sub get_item_id
{
    my ( $item_name, $class_name ) = @_;
    my $class_id = get_class_id( $class_name );
    my $row = $sth{'find_item'}->execute( $item_name, $class_id );
    return $sth{'find_item'}->fetchrow_hashref('NAME_lc')->{'id'} if ( $row and 1 == $row );
    $row = $sth{'insert_item'}->execute( $item_name, $class_id );
    return $sth{'insert_item'}->{'mysql_insertid'};
}


    foreach my $event_line (@usage_data)
    {
        my @event_data = (split /þ/, $event_line)[0,3,4,5,7,8];
        say sprintf(q{Tech: %s, Date: %s Item: %s}, @event_data[1,0,3]);
        $sth{'insert_event'}->execute(
            date_to_ISO8601( $event_data[0] ),
            get_tech_id( @event_data[1,2] ),
            get_item_id( @event_data[3,4] ),
            $event_data[5],
        );
    }

%sth = ();

$dbh->disconnect();
