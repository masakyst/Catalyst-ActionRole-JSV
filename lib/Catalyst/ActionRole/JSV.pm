package Catalyst::ActionRole::JSV;

use strict;
use Moose::Role;
use namespace::autoclean;
use JSV::Validator;
use Path::Class ();
use JSON::MaybeXS ();

our $VERSION = '0.01';

sub BUILD { }

after BUILD => sub {
    my $class = shift;
    my ($args) = @_;
    my $attr = $args->{attributes};
};


around execute => sub {
    my $orig = shift;
    my $self = shift;
    my ($controller, $c) = @_;

    my $jsv = JSV::Validator->new;

    my $params = $c->req->body_data;
    my $request_schema = JSON::MaybeXS::decode_json(Path::Class::file($c->config->{home}, $self->attributes->{Request}->[0])->slurp);

    my $request_result = $jsv->validate($request_schema, $params);

    if ($request_result->get_error) {
        $c->response->status(400);
        $c->stash->{json} = {message => sprintf("%s: %s", $request_result->errors->[0]->{pointer}, $request_result->errors->[0]->{message})};
        return;
    }

    my $orig_response = $self->$orig(@_);

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
