use strict;
use utf8;

use List::Util 'shuffle';
#use List::Util qw[min max];
use String::Util ':all';
use Set::IntSpan;

Xchat::register("Choose", "1.1-lae");
Xchat::print("Choose script loaded\n");

my $choices = { CHOOSE => 0, ORDER => 1, OTHER => 2 };
my @channels = ( '#commie-subs', '#SAGE', '#baot', '#noko', '#vodka-subs', '#arnavion', '#Gundam', '#bytesized', '#lae' );
my @wordfilter = ( 'XD', 'attention attention', 'scion', 'eva', 'touhou', 'erep', 'esim', 'republik', 'cereal cereal', '!sw', '!loli' );
my $matchfilter = '(' . join('|', @wordfilter) . ')';
$matchfilter = qr/$matchfilter/i;

sub chooseHandler {
        my $result = Xchat::EAT_NONE;
        my $channel = Xchat::get_info('channel');

        if (grep(/^$channel$/, @channels)) {
                my $choice = $choices->{OTHER};
                my $user;
                my $input;
                if ($_[0][1] =~ /^\.(?:(?:c(?:hoose)?)|(?:erande)) (.+)$/) {
                        $choice = $choices->{CHOOSE};
                        $user = $_[0][0];
                        $input = $1;
                }
                elsif ($_[0][0] eq 'CS|Minecraft' && $_[0][1] =~ /^<([^>]*)> .choose (.+)$/) {
                        $choice = $choices->{CHOOSE};
                        $user = $1;
                        $input = $2;
                }
                elsif ($_[0][1] =~ /^[.!]o(?:rder)? (.+)$/) {
                        $choice = $choices->{ORDER};
                        $user = $_[0][0];
                        $input = $1;
                }
                if (($choice == $choices->{CHOOSE}) || ($choice == $choices->{ORDER})) {
                        Xchat::emit_print($_[1], $_[0][0], $_[0][1], $_[0][2], $_[0][3]);
                        my @choices = grep { length $_ } map { trim($_) } split(/,/, $input);
                        if ($#choices > -1) {
                                if ($#choices == 0) {
                                        @choices = grep { length $_ } map { trim($_) } split(/ /, $choices[0]);
                                }

                                my @filteredchoices;
                                foreach my $item ( @choices ) {
                                        if($item =~ m/^(-?\d+\.?\d*)-(-?\d+\.?\d*)$/) {
                                                if($item =~ m/^(-?\d+)-(-?\d+)$/) {
                                                        if($1 > $2) {
                                                                push @filteredchoices, Set::IntSpan->new( "$2-$1" )->elements;
                                                        } else {
                                                                push @filteredchoices, Set::IntSpan->new( $item )->elements;
                                                        }
                                                } else {
                                                        my $cr = $1 > $2 ? rand($1-$2)+$2 : rand($2-$1)+$1;
                                                        push @filteredchoices, $cr;
                                                }
                                        } elsif($item =~ $matchfilter) {
                                                push @filteredchoices, 'nope';
                                        } else {
                                                push @filteredchoices, $item;
                                        }
                                }
                                my @shuf = shuffle @filteredchoices;
                                if($choice == $choices->{ORDER}) {
                                        if(scalar @filteredchoices > 42) {
                                                @shuf = @shuf[0..41];
                                                push @shuf, '...nope.';
                                        }
                                        Xchat::command("say $user:\x0F " . join(", ", @shuf));
                                } else {
                                        my $pick = shift @shuf;
                                        $pick =~ s/^\s+//;
                                        return if $pick =~ /^\s+$/ || $pick =~ /^$/;
                                        Xchat::command("say $user:\x0F $pick");
                                }
                        }
                        $result = Xchat::EAT_ALL;
                }
        }

        return $result;
}

Xchat::hook_print('Channel Message', \&chooseHandler, { data => 'Channel Message' });
Xchat::hook_print('Channel Msg Hilight', \&chooseHandler, { data => 'Channel Msg Hilight' });
Xchat::hook_print('Your Message', \&chooseHandler, { data => 'Your Message' });
