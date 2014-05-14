#!/bin/perl
use strict;
use IO::Socket;

my ($host, $port, $kidpid, $handle, $line, $file);

unless (@ARGV == 2) { die "Usage: $0 <host> <port> < <file>\n" }
($host, $port) = @ARGV;


#--- create a tcp connection to the specified host and port ---#
$handle = IO::Socket::INET->new(Proto => "tcp", PeerAddr  => $host, PeerPort  => $port)
or die "Can't connect to port $port on $host: $!";

$handle->autoflush(1);   #--- so output gets there right away 
print STDERR "[Connected to $host:$port]\n";

#--- split the program into two processes, identical twins ---#
die "Can't fork: $!" unless defined($kidpid = fork());

if ($kidpid) 
{
	#--- in the parent process ---#
    while (defined ($line = <$handle>)) 
	{
		print STDOUT "$line";
    }
    kill("TERM", $kidpid);   #--- send SIGTERM to child
}
else 
{
	#--- in the child process ---#
    while (defined ($line = <STDIN>)) 
	{
		chomp $line;
		#print STDERR "sending <s> $line </s>\n";
		print $handle "<s> $line </s>\n";
    }
    print $handle "END_OF_FILE\n";
}

