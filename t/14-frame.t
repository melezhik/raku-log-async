use v6;
use Test;
use lib 'lib';
use Log::Async;
plan 6;          # NB: line numbers are hard coded below, modify with care
exit 0 & skip-rest('coverage interferes with line numbers') if ?%*ENV<MVM_COVERAGE_LOG>; # interferes with line numbers

my @all;
my $out = $*OUT but role { method say($str) { @all.push: $str }; method flush { } };

logger.send-to($out,
  formatter => -> $m, :$fh {
    $fh.say: "{ $m<frame>.file } { $m<frame>.line } { $m<frame>.code.name }: $m<msg>"
  });

sub foo {
  trace "hello";
  trace "hello 1";
  trace "hello 2";
}

class Foo {
  method bar {
    trace "very";
    trace "nice";
  }
}

foo();
Foo.bar();
trace "world";

logger.done;
@all .= sort;

my $file = callframe.file;
is @all[0], "$file 17 foo: hello", 'right frame output in sub';
is @all[1], "$file 18 foo: hello 1", 'right frame output in sub';
is @all[2], "$file 19 foo: hello 2", 'right frame output in sub';
is @all[3], "$file 24 bar: very", 'right frame output in method';
is @all[4], "$file 25 bar: nice", 'right frame output in method';
is @all[5], "$file 31 <unit>: world", 'right frame output in main';

