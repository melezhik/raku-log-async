use v6;
use Test;
use lib 'lib';
use Log::Async;

plan 1;

exit 0 & skip-rest('coverage interferes with line numbers') if ?%*ENV<MVM_COVERAGE_LOG>; # interferes with line numbers

my @lines;
my $out = $*OUT but role { method say($arg) { @lines.push: $arg } };
logger.add-context;
logger.send-to($out,
  formatter => -> $m, :$fh {
    $fh.say: "file { $m<ctx>.file}, line { $m<ctx>.line }, message { $m<msg> }"
    }
  );
my $msg = "yàsu";
trace $msg;
my $line = $?LINE - 1;
logger.done;

my $file = $?FILE.subst(/^^ "{ $*CWD }/" /,'');
is-deeply @lines, [ "file $file, line $line, message $msg" ], "Got context";

# vim: syn=perl6
