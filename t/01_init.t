use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use Test::Output;
use File::Temp;
use Data::Dumper;

use Zabbix::ServerScript;

subtest q(check _set_binmode) => sub {
	Zabbix::ServerScript::_set_binmode();
	like(PerlIO::get_layers(STDOUT), qr(utf8), q(STDOUT is in "utf8" binmode));
	like(PerlIO::get_layers(STDERR), qr(utf8), q(STDERR is in "utf8" binmode));
};

subtest q(check _set_basename) => sub {
	Zabbix::ServerScript::_set_basename(q(),q(test.pl));
	is($ENV{BASENAME}, q(test), q(Set environment variable BASENAME));
};

subtest q(check _set_id) => sub {
	Zabbix::ServerScript::_set_id(q());
	is($ENV{ID}, q(), q(Empty environment variable ID));
	Zabbix::ServerScript::_set_id();
	is($ENV{ID}, q(test), q(Default environment variable ID is the same as BASENAME));
	Zabbix::ServerScript::_set_id(q(lala));
	is($ENV{ID}, q(lala), q(Custom environment variable ID));
};

done_testing;
