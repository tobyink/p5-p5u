package P5U::Command;

use 5.010;
use strict;
use App::Cmd::Setup-command;

use File::HomeDir qw<>;
use File::Temp qw<>;
use JSON qw<>;
use Path::Class qw<>;

my %config;

sub get_tempdir
{
	Path::Class::Dir::->new(File::Temp::->newdir);
}

sub _get_distdatadir
{
	File::HomeDir::->my_dist_data('P5U') //
	Path::Class::Dir::->new(File::HomeDir::->my_home => qw(perl5 utils data))->stringify
}

sub _get_distconfigdir
{
	File::HomeDir::->my_dist_data('P5U') //
	Path::Class::Dir::->new(File::HomeDir::->my_home => qw(perl5 utils etc))->stringify
}

sub get_cachedir
{
	my $self = shift;
	my $d = Path::Class::Dir::->new(
		$self->_get_distdatadir,
		(($self->command_names)[0]),
		'cache',
	);
	$d->mkpath;
	return $d;
}

sub get_datadir
{
	my $self = shift;
	my $d = Path::Class::Dir::->new(
		$self->_get_distdatadir,
		(($self->command_names)[0]),
		'store',
	);
	$d->mkpath;
	return $d;
}

sub get_configfile
{
	my $self = shift;
	my $f = Path::Class::File::->new(
		$self->_get_distconfigdir,
		(($self->command_names)[0]),
		'config.json',
	);
}

sub get_config
{
	my $proto = shift;
	my $class = ref($proto) || $proto;
	
	unless ($config{$class})
	{
		$config{$class} =
			eval { JSON::->new->decode(scalar $proto->get_configfile->slurp) }
			|| +{};
	}
	
	$config{$class};
}

sub save_config
{
	my $proto  = shift;
	my $class  = ref($proto) || $proto;
	my $config = $config{$class} || +{};
	
	my $fh = $proto->get_configfile->openw;
	print $fh $config;
}

1;

