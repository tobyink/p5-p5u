package P5U::Lib::DebianRelease;

# This is largely based on a script by SHARYANTO

use 5.010;
use utf8;

BEGIN {
	$P5U::Lib::DebianRelease::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Lib::DebianRelease::VERSION   = '0.001';
};

use Any::Moose       0;
use IO::Uncompress::Gunzip qw< gunzip $GunzipError >;
use JSON             2.00  qw< from_json >;
use LWP::Simple      0     qw< get >;
use Object::AUTHORITY qw/AUTHORITY/;

my $json   = JSON::->new->allow_nonref;

sub dist2deb
{
	my ($dist) = @_;
	"lib".lc($dist)."-perl";
}

use namespace::clean;

has debian => (
	is         => 'ro',
	isa        => 'HashRef',
	lazy_build => 1,
);

has cache_file => (
	is         => 'ro',
	required   => 1,
);

sub _build_debian
{
	my $self = shift;
	my %pkgs;
	unless ((-f $self->cache_file) && (-M _) < 7)
	{
		my $res = get "http://packages.debian.org/unstable/allpackages?format=txt.gz";
		gunzip(\$res => $self->cache_file->stringify)
			or die "gunzip failed: $GunzipError\n";
	}
	for ($self->cache_file->slurp)
	{
		next unless /^(lib\S+-perl) \((\S+?)\)/;
		$pkgs{$1} = $2;
	}
	\%pkgs
}

sub author_report
{
	my $self = shift;
	$self->format_report(
		$self->author_data(@_)
	)
}

sub distribution_report
{
	my $self = shift;
	$self->format_report(
		$self->distribution_data(@_)
	)
}

sub format_report
{
	my ($self, $data) = @_;
	join q(),
		sprintf(
			"%-40s%15s%15s  %s\n",
			qw(PACKAGE CPAN DEBIAN WARNING)
		),
		map {
			my ($dist, $cpan, $deb) = @$_;
			(my $debx = $deb) =~ s/[-].+//;
			sprintf(
				"%-40s%15s%15s  %s\n",
				  $dist,
				  $cpan,
				  $deb,
				  ($debx eq $cpan ? q[  ] : q[!!]),
			);
		}
		@$data;
}

sub author_data
{
	my ($self, $author) = @_;

	my $res = get "http://api.metacpan.org/v0/release/_search?q=author:".
		uc($author)."%20AND%20status:latest&fields=name&size=1000";
	$res = $json->decode($res);
	die "MetaCPAN timed out" if $res->{timed_out};

	my $pkgs = $self->debian;

	my %dists;
	for my $hit (@{ $res->{hits}{hits} })
	{
		my $dist = $hit->{fields}{name};
		$dist =~ s/-(\d.+)//;
		$dists{$dist} = $1;
	}

	my @data;
	for my $dist (sort keys %dists)
	{
		my $pkg = dist2deb($dist);
		next unless $pkg ~~ $pkgs;
		
		push @data => [
			$dist,
			$dists{$dist},
			$pkgs->{$pkg},
		];
	}
	\@data;
}

sub distribution_data
{
	my $self = shift;
	my $dist = from_json get sprintf('http://api.metacpan.org/v0/release/%s', @_);
	my $pkg  = dist2deb $dist->{distribution};
	
	[[
		$dist->{distribution},
		$dist->{version},
		($self->debian->{$pkg} // '(none)'),
	]]
}

1;
