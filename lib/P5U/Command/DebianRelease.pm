package P5U::Command::DebianRelease;

use 5.010;
use strict;
use P5U-command;

use constant {
	abstract    => q[show distribution version in Debian unstable],
	description => q[],
	usage_desc  => q[%c debian-release %o Distribution|CPANID],
};

sub command_names
{
	qw(
		debian-release
		debian
	);
}

sub opt_spec
{
	return (
		["author|a",       "query is an author"],
		["distribution|d", "query is a distribution (default)"],
	)
}

sub execute
{
	require P5U::Lib::DebianRelease;
	
	my ($self, $opt, $args) = @_;
	
	$self->usage_error("You must provide a distribution or author name.")
		unless @$args;
	$self->usage_error("Cannot request both author and distribution report.")
		if $opt->{author} && $opt->{distribution};
	
	my $helper = P5U::Lib::DebianRelease::->new;
	
	if ($opt->{author})
		{ print $helper->author_report($_) for @$args }
	else
		{ print $helper->distribution_report($_) for @$args }
}

1;
