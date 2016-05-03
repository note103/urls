package Urls;
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
my $regexp = qr{http[:s][^\s,;>]+};

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

    for my $replace (keys %unique) {
        if ($replace =~ /(http[:s][^\s\)]+)/g) {
            my $target = $1;
            $target =~ s/\?/\\?/;
            for my $data (@data) {
                next if ($data =~ /(\($regexp\))/g);
                $data =~ s/$target/$replace/;
            }
        }
    }
    return join "\n", @data;
}

my $rest    = '';
sub extr {
    my $e = shift;
    my ($x, $y);

    if ($e =~ /(?<prematch>.*)(\($regexp\))(?<postmatch>.*)/g) {
    } elsif ($e =~ /(?<prematch>.*)(?<match>$regexp)(?<postmatch>.*)/g) {
        push @urls, $+{match};
    } else {
        next;
    }

    $x = $+{prematch} if $+{prematch};
    $y = $+{postmatch} if $+{postmatch};
    if ($x && $y) { $rest = $x.$y;
    } elsif ($x) { $rest = $x;
    } elsif ($y) { $rest = $y;
    }
    extr($rest) if ($rest =~ /(.*)($regexp)(.*)/);
}

1;
