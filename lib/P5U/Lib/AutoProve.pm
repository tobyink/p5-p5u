package P5U::Lib::AutoProve;

BEGIN {
	$P5U::Lib::AutoProve::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Lib::AutoProve::VERSION   = '0.001';
};

use 5.010;
use strict;
use utf8;

use App::Prove;
use Cwd 'cwd';
use Object::AUTHORITY;

sub change_to_suitable_directory
{
	my ($self) = @_;
	
	while (-d '..' and not -d 't')
	{
		chdir '..';
	}

	unless (-d 't')
	{
		die "No suitable test suite found.\n";
	}

	return cwd;
}

sub opts
{
	qw(
		recurse|r timer verbose|v color|c dry|D failures|f comments|o fork
		ignore-exit merge|m shuffle|s reverse normalize T t W w jobs|j=i
	);
}

sub build_option_args
{
	my ($self, %opt) = @_;
	my $jobs = delete $opt{jobs};
	
	my @args =
		map { "--$_" }
		sort keys %opt;
	
	push @args, "--jobs=$jobs" if $jobs;
	
	return @args;
}

sub build_lib_args
{
	map { "-I$_" } grep { -d $_ } qw( blib/lib inc lib t/lib xt/lib );
}

sub get_app
{
	my ($self, %opt) = @_;

	my $do_author_tests = delete $opt{xt};

	my $origwd = cwd;
	my $cwd    = $self->change_to_suitable_directory;
	print "Found suitable test suite within directory '$cwd'.\n";

	my @args = $self->build_option_args(%opt);
	push @args, $self->build_lib_args;
	
	push @args, 't'  if -d 't';
	push @args, 'xt' if -d 'xt' && $do_author_tests;
	
	chdir $origwd;	

	print join(q{ }, prove => @args), "\n"
		if $opt{verbose};
	
	my $app = App::Prove->new;
	$app->process_args(@args);
	return ($cwd, $app);
}

1;
