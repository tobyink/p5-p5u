use Test::More skip_all => "don't care so much about this";
use Test::Pod::Coverage;

my @modules = qw(P5U);
pod_coverage_ok($_, "$_ is covered")
	foreach @modules;
done_testing(scalar @modules);

