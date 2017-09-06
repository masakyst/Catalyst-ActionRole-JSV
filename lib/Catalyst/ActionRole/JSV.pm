package Catalyst::ActionRole::JSV;

use strict;
use Moose::Role;
use namespace::autoclean;
use JSV::Validator;
use Path::Class ();
use JSON::MaybeXS ();

our $VERSION = '0.01';

our $JSV;


after BUILD => sub {
    my $class = shift;
    my ($args) = @_;
    my $attr = $args->{attributes};
    $JSV = JSV::Validator->new;
};


around execute => sub {
    my $orig = shift;
    my $self = shift;
    my ($controller, $c) = @_;

    my $params = $c->req->parameters;

    my $load_schema_json = Path::Class::file($c->config->{home}, $self->attributes->{JSONSchema}->[0]);
    $c->log->debug("load file json schema file: ".$load_schema_json->stringify);

    my $request_schema = JSON::MaybeXS::decode_json(Path::Class::file($c->config->{home}, $self->attributes->{JSONSchema}->[0])->slurp);

    # find url capture args
    if (scalar @{ $c->req->arguments}) {
        # json property "captureargs" : "number"
        for my $key (keys %{ $request_schema->{properties} }) {
            if ($request_schema->{properties}->{$key}->{captureargs}) {
                my $captureval = $c->req->arguments->[$request_schema->{properties}->{$key}->{captureargs} - 1];
                if (defined $captureval) {
                    $params->{$key} = $captureval;
                }
            }
        }
    }
 
    my $request_result = $JSV->validate($request_schema, $params);

    if ($request_result->get_error) {
        $c->log->debug("json schema validation failed: ".$request_result->errors->[0]->{message});
        # todo: return response
        $c->response->status(400);
        $c->stash->{json} = {message => sprintf("%s: %s", $request_result->errors->[0]->{pointer}, $request_result->errors->[0]->{message})};
        return;
    }
    $c->log->debug("json schema validation success.");

    my $orig_response = $self->$orig(@_);

    # todo: validate response schema ..

    return $orig_response;
};

1;

__END__

=encoding utf-8

=head1 NAME

Catalyst::ActionRole::JSV - Validate data against a JSON schema for Catalyst actions

=head1 SYNOPSIS

  use Catalyst::ActionRole::JSV;

=head1 DESCRIPTION

Catalyst::ActionRole::JSV is

=head1 AUTHOR

Masaaki Saito E<lt>masakyst.public@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Masaaki Saito

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
