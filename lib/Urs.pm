package Urs;
use strict;
use warnings;
use feature 'say';
use Encode qw/encode decode find_encoding/;
use Encode::Guess qw/cp932 euc-jp/;
use LWP::UserAgent;
use LWP::Protocol::https;
use Try::Tiny;

my @data    = ();
my @urls    = ();

sub main {
    my ( $get, $param )    = @_;

    if ($param eq 'i') {
        @data = $get;
    }
    elsif ($param eq 'r') {
        @data = @$get;
    }

    for my $e (@data) {
        $e =~ s/\A(.*)\n/$1/ms;
        extr($e) if ($e =~ /(.*)(http[:s][^\s,;>]+)(.*)/);
    }

    my $agent = LWP::UserAgent->new;

    my @char;
    my @result;

    for my $url (@urls) {
        my $res   = $agent->get($url);
        my $title = $res->title();

        my $content = $res->header('Content-Type');
        my @encode = qw/utf-8 cp932 euc-jp/;
        my $char;
        for my $encode (@encode) {
            $char = $1 if ($content =~ /charset=['"]?($encode)/i);
        }

        my $decoder;
        if ($char) {
            my $enc = find_encoding $char;
            $title = $enc->decode($title);
        } else {
            $decoder = Encode::Guess->guess($title);
            try {
                ref($decoder) || die "Can't guess: $decoder";
                $title = $decoder->decode($title);
            } catch {
                $title = 'No Title';
            };
        }
        $title = encode('UTF-8', $title);
        push @result, "[$title]($url)";
    }

    my %unique = ();
    map {$unique{$_} = 1;} @result;

    for my $result (keys %unique) {
        if ($result =~ /(http[:s][^\s\)]+)/g) {
            my $replace = $1;
            $replace =~ s/\?/\\?/;
            for my $data (@data) {
                $data =~ s/$replace/$result/;
            }
        }
    }
    return join "\n", @data;
}

my $rest    = '';

sub extr {
    my $e = shift;
    my ($x, $y);
    if ($e =~ /(.*)(\(http[:s][^\s,;>]+\))(.*)/g) {
        $x = $1 if $1;
        $y = $4 if $4;
        if ($x && $y) { $rest = $1.$4;
        } elsif ($x) { $rest = $x;
        } elsif ($y) { $rest = $y;
        }
    } elsif ($e =~ /(.*)(http[:s][^\s,;>]+)(.*)/g) {
        push @urls, $2;
        $x = $1 if $1;
        $y = $3 if $3;
        if ($x && $y) { $rest = $1.$3;
        } elsif ($x) { $rest = $x;
        } elsif ($y) { $rest = $y;
        }
    }
    extr($rest) if ($rest =~ /(.*)(http[:s][^\s,;>]+)(.*)/);
}

1;
