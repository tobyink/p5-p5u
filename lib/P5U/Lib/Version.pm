package P5U::Lib::Version;

use 5.010;
use utf8;

BEGIN {
	$P5U::Lib::Version::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Lib::Version::VERSION   = '0.001';
};

use JSON qw< from_json >;
use LWP::Simple qw< get >;
use Module::Info;
use Module::Runtime qw< module_notional_filename >;
use Object::AUTHORITY;

sub local_module_info
{
	my $self = shift;	
	return
		map { sprintf "%s: %s", $_->file, $_->version }
		Module::Info->all_installed(@_);
}

sub cpan_module_info
{
	my $self = shift;
	my $mod  = shift;

	my $data = from_json get(
		sprintf
			'http://api.metacpan.org/v0/module/_search?q=status:cpan+AND+path:lib/%s&fields=version,release,author,path,date&size=1000',
			module_notional_filename($mod),
	);
	return $self->format_hits(cpan => $data);
}

sub backpan_module_info
{
	my $self = shift;
	my $mod  = shift;

	my $data = from_json get(
		sprintf
			'http://api.metacpan.org/v0/module/_search?q=status:backpan+AND+path:lib/%s&fields=version,release,author,path,date&size=1000',
			module_notional_filename($mod),
	);
	return $self->format_hits(backpan => $data);
}

sub format_hits
{
	my ($self, $label, $data) = @_;
	die "MetaCPAN API timed out" if $data->{timed_out};
	
	return
		map {
			sprintf
				'%s:%s/%s.tar.gz#%s: %s (%s)',
				$label,
				@{$_}{qw<author release path version date>}
		}
		sort { $a->{version} cmp $b->{version} }
		map  { $_->{fields} }
		@{ $data->{hits}{hits} };
}

1;
