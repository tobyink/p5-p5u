package P5U::Lib::Testers;

use 5.010;
use utf8;

BEGIN {
	$P5U::Lib::Testers::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Lib::Testers::VERSION   = '0.001';
};

use Any::Moose       0;
use File::Spec       0 qw< >;
use JSON             0 qw< from_json >;
use LWP::Simple      0 qw< mirror is_success >;
use List::Util       0 qw< maxstr >;
use Object::AUTHORITY qw/AUTHORITY/;
use Path::Class      0 qw< dir file >;
use namespace::clean;

has cache_dir => (
	is       => 'ro',
	isa      => 'Str',
	lazy     => 1,
	builder  => '_build_cache_dir',
);

has distro => (
	is       => 'ro',
	isa      => 'Str',
	required => 1,
);

has results => (
	is       => 'ro',
	isa      => 'ArrayRef',
	lazy     => 1,
	builder  => '_build_results',
);

has version => (
	is       => 'ro',
	isa      => 'Str',
	lazy     => 1,
	builder  => '_build_version',
);

has os_data => (
	is       => 'ro',
	isa      => 'Bool',
	default  => 0,
);

has stable => (
	is       => 'ro',
	isa      => 'Bool',
	default  => 0,
);

sub version_data
{
	my ($self) = @_;
	my %data;
	foreach (@{$self->results})
	{
		next unless $_->{version} eq $self->version;
		my ($pv) = ($_->{perl} =~ /^5\.(\d+)/) or next;
		next if $pv ~~ [9, 11, 13, 15];
		my $key = $self->os_data
			? sprintf("Perl 5.%03d, %s", $pv, $_->{ostext})
			: sprintf("Perl 5.%03d", $pv);
		my $num  = { PASS => 0, FAIL => 1 }->{$_->{status}} // 2;
		$data{$key}[$num]++;
	}
	return \%data;
}

sub summary_data
{
	my ($self) = @_;
	my %data;
	foreach (@{$self->results})
	{
		my $key  = $_->{version};
		my $num  = { PASS => 0, FAIL => 1 }->{$_->{status}} // 2;
		$data{$key}[$num]++;
	}
	return \%data;
}

sub format_report
{
	my ($self, $title, $data) = @_;
	no warnings;
	join "\n" => (
		$title,
		q(),
		sprintf("%-32s%6s%6s%6s", q(), qw(PASS FAIL ETC)),
		(
			map { sprintf "%-32s% 6d% 6d% 6d", $_, @{$data->{$_}} }
			sort keys %$data
		),
		q(),
	);
}

sub version_report
{
	my ($self) = @_;
	
	$self->format_report(
		sprintf("CPAN Testers results for %s version %s", $self->distro, $self->version),
		$self->version_data,
	);
}

sub summary_report
{
	my ($self, $os_data) = @_;
	
	$self->format_report(
		sprintf("CPAN Testers results for %s", $self->distro),
		$self->summary_data,
	);
}

sub _build_version
{
	maxstr
		map { $_->{version} }
		@{ shift->results }
}

sub _build_results
{
	my $self = shift;
	
	my $results_uri = sprintf(
		'http://www.cpantesters.org/distro/%s/%s.json',
		substr($self->distro, 0, 1),
		$self->distro,
	);
	my $results_file = file(
		$self->cache_dir,
		sprintf('%s.json', $self->distro),
	);
	
	is_success mirror($results_uri => $results_file)
		or do {
			unlink $results_file;
			die "Failed to retrieve URI $results_uri\n";
		};
		
	my $results = from_json scalar $results_file->slurp;
	die "Unexpected non-ARRAY content from $results_uri\n"
		unless ref $results eq 'ARRAY';
	
	$self->stable
		? [ grep { $_->{version} !~ /_/ } @$results ]
		: $results;
}

sub _build_cache_dir
{
	my $dir = dir(
		File::Spec::->tmpdir,
		'CpanTesters',
	);
	dir($dir)->mktree unless -d $dir;
	return $dir;
}

1;
