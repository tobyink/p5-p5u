package P5U::Lib::TestPod;

use 5.010;
use strict;
use utf8;

BEGIN {
	$P5U::Command::TestPod::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Command::TestPod::VERSION   = '0.001';
};

use Object::AUTHORITY;
use Path::Class;
use Path::Class::Rule;
use Test::More;
use Test::Pod;

sub uniq
{
	my %already;
	grep { not $already{"$_"}++ } @_;
}

sub test_pod
{
	my $self = shift;
	
	my @files = 
		uniq
		map {
			(-d $_)
				? Path::Class::Rule::->new->or(
					Path::Class::Rule::->new->perl_module,
					Path::Class::Rule::->new->perl_pod,
					Path::Class::Rule::->new->perl_script,
					)->all($_)
				: Path::Class::File::->new($_)
		} @_;
	
	plan tests => scalar @files;
	pod_file_ok("$_", $_) for @files;
}

1;
