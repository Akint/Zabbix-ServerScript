use strict;
use warnings;

use Test::More tests => 3;
use Test::Fatal;
use Test::Output;
use Test::MockObject;
use File::Temp;
use Data::Dumper;
use Storable;

use Zabbix::ServerScript;

require_ok(q(ZabbixAPI));

Zabbix::ServerScript::_set_binmode();
$ENV{BASENAME} = q(zabbix_server_script_test);
$ENV{ID} = q(zabbix_server_script_test);
Zabbix::ServerScript::_set_logger({ log_filename => q(/tmp/zabbix_server_script_test.log) });

sub read_file_contents {
	my ($fh) = @_;
	return do { local $/; <$fh> };
}

subtest q(Check config) => sub {
	my $res;
	my $api;
	my $old_api_config = $Zabbix::ServerScript::Config->{api};

	$Zabbix::ServerScript::Config->{api} = undef;
	ok(exception { Zabbix::ServerScript::_set_api(q(rw)) }, q(Throws exception if 'api' section is not defined in global config));

	$Zabbix::ServerScript::Config->{api} = {};
	ok(exception { Zabbix::ServerScript::_set_api(q(rw)) }, q(Throws exception if 'url' is not present in 'api' section in global config));

	$Zabbix::ServerScript::Config->{api} = { url => q(https://zabbix.example.com) };
	ok(exception { Zabbix::ServerScript::_set_api(q(rw)) }, q(Throws exception if requested API credentials are not defined));

	$Zabbix::ServerScript::Config->{api} = {
		url => q(https://zabbix.example.com),
		rw => {
			login => q(user),
			password => undef,
		},
	};
	ok(exception { Zabbix::ServerScript::_set_api(q(rw)) }, q(Throws exception if password is not defined for requested API credentials));

	$Zabbix::ServerScript::Config->{api} = {
		url => q(https://zabbix.example.com),
		rw => {
			login => undef,
			password => q(password),
		},
	};
	ok(exception { Zabbix::ServerScript::_set_api(q(rw)) }, q(Throws exception if login is not defined for requested API credentials));

#	$Zabbix::ServerScript::Config->{api} = $old_api_config;
#	if (defined ($api = $Zabbix::ServerScript::Config->{api}) && defined $api->{url}){
#		foreach my $key (keys %$api){
#			$res = 1 if (ref($api->{$key}) eq q(HASH) and defined $api->{$key}->{login} and defined $api->{$key}->{password});
#		}
#	}
#	ok($res, q(Credentials for Zabbix API are defined in global config));
};

subtest q(Mock Zabbix API) => sub {
	$Zabbix::ServerScript::Config->{api} = {
		url => q(https://zabbix.example.com),
		rw => {
			login => q(user),
			password => q(password),
		},
	};
	Test::MockObject->fake_module(
		q(ZabbixAPI),
		login => sub { die(q(Cannot login via Zabbix API)); },
	);
	like(exception { Zabbix::ServerScript::_set_api(q(rw)) }, qr(Cannot login via Zabbix API), q(Die at login failure));
};

unlink(q(/tmp/zabbix_server_script_test.log));
done_testing;
