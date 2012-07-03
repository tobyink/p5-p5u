package P5U::Command::DebianRelease;

use 5.010;
use strict;
use utf8;
use P5U-command;

BEGIN {
	$P5U::Command::DebianRelease::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Command::DebianRelease::VERSION   = '0.003';
};

use constant {
	abstract    => q[show distribution version in Debian unstable],
	usage_desc  => q[%c debian-release %o Distribution|CPANID],
};

sub command_names
{
	qw(
		debian-release
		debian
		dr
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
	
	my $helper = P5U::Lib::DebianRelease::->new(
		cache_file  => $self->get_cachedir->file('allpackages.cache'),
	);
	
	if ($opt->{author})
		{ print $helper->author_report($_) for @$args }
	else
		{ print $helper->distribution_report($_) for @$args }
}

1;
