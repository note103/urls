#!/usr/bin/env perl
use strict;
use warnings;
use feature 'say';
use lib 'lib';
use Urls;

my @data    = <DATA>;
say Urls::main(\@data, 'r');

__DATA__
- Perl: http://blog.geekuni.com/2016/04/interview-perls-pumpking-ricardo-signes.html; http://perl-users.jp/articles/advent-calendar/2009/casual/10.html, http://naoya.dyndns.org/~naoya/mt/archives/000657.html
- Ruby: http://itpro.nikkeibp.co.jp/article/COLUMN/20090210/324516/; http://itpro.nikkeibp.co.jp/article/COLUMN/20070621/275509/

