package P5U::Command::Commands;

use 5.010;
use strict;
use utf8;
use P5U-command;

require App::Cmd::Command::commands;
our @ISA = 'App::Cmd::Command::commands';

BEGIN {
	$P5U::Command::Commands::AUTHORITY = 'cpan:TOBYINK';
	$P5U::Command::Commands::VERSION   = '0.001';
};

use constant {
	abstract    => q[list installed p5u commands],
};

sub sort_commands
{
	my ($self, @commands) = @_;
	my $float = qr/^(?:help|commands|aliases)$/;
	my @head = sort grep { $_ =~ $float } @commands;
	my @tail = sort grep { $_ !~ $float } @commands;
	return (\@head, \@tail);
}
1;