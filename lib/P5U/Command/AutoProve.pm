package P5U::Command::AutoProve;

use 5.010;
use strict;
use utf8;
use P5U-command;

BEGIN {
	$P5U::Command::AutoProve::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Command::AutoProve::VERSION   = '0.001';
};

use Cwd 'cwd';

use constant {
	abstract    => q[show CPAN testers statistics for a distribution],
	usage_desc  => q[%c auto-prove %o],
};

sub command_names
{
	qw(
		auto-prove
		ap
	);
}

sub opt_spec
{
	require P5U::Lib::AutoProve;
	return (
		[ xt => 'run "xt" tests too' ],
		map { [ $_ => 'passed through to "prove"' ] } P5U::Lib::AutoProve->opts
	);
}

sub execute
{
	require P5U::Lib::AutoProve;
	my ($self, $opt, $args) = @_;
	$self->usage_error("This command takes no non-option arguments.")
		if @$args;
	my ($wd, $app) = P5U::Lib::AutoProve::->get_app(%$opt);
	my $orig = cwd;
	
	chdir $wd;
	$app->run;
	chdir $orig;
}

1;
