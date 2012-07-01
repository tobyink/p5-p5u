use Test::More;
use Test::Pod::Coverage;

my @modules = 
	map { "P5U::Lib::$_" }
	qw( AutoProve DebianRelease Reprove Testers TestPod Version Whois );
pod_coverage_ok($_, "$_ is covered")
	foreach @modules;
done_testing(scalar @modules);

