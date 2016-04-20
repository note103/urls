#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use Encode::Guess qw/cp932 euc-jp/;
use Encode;
use LWP::Protocol::https;
use LWP::UserAgent;
use Try::Tiny;
use lib 'lib';
use Urls;

print "url >>> ";

my $data = <STDIN>;
say Urls::main($data, 'i');
