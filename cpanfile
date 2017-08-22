
requires 'Catalyst::Runtime' => '5.90050';
requires 'Moose';
requires 'Catalyst::Controller::ActionRole';
requires 'namespace::autoclean';
requires 'JSV';
requires 'Path::Tiny';
requires 'JSON::MaybeXS';

on test => sub {
    requires 'Test::More', '0.96';
};
