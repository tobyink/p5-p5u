package P5U::Command::Version;

use 5.010;
use strict;
use utf8;
use P5U-command;

use PerlX::Maybe 0 'maybe';

BEGIN {
	$P5U::Command::Version::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Command::Version::VERSION   = '0.001';
};

use constant {
	abstract    => q[show version number],
	usage_desc  => q[%c version %o Module],
};

sub command_names
{
	qw(
		version
		v
	);
}

sub opt_spec
{
	return;
}

sub execute
{
	require Module::Info;
	
	my ($self, $opt, $args) = @_;

	$self->usage_error("You must provide a module name.")
		unless @$args;
	
	while (my $m = shift @$args)
	{
		say $m;
		
		my @mods = Module::Info->all_installed($m);
		if (@mods)
		{
			printf("\t%s: %s\n", $_->file, $_->version) foreach @mods;
		}
		else
		{
			say "\tNot found";
		}
		
		say q() if @$args; 
	}
}

1;
