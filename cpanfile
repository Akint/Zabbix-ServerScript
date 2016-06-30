requires 'perl', '5.008001';
requires 'Log::Log4perl', '>= 1.30';
requires 'Proc::PID::File', '>= 1.27';
requires 'YAML', '>= 0.70';
requires 'ZabbixAPI';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'Test::Fatal';
    requires 'Test::MockObject';
    requires 'Test::MockModule';
};

