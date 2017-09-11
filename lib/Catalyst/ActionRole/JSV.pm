package Catalyst::ActionRole::JSV;

use strict;
use Moose::Role;
use namespace::autoclean;
use JSV::Validator;
use Path::Class ();
use JSON::MaybeXS ();


our $VERSION = '0.01';
our $JSV;
our %SCHEMA = ();


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

    my $request_schema; 
    my $json_file = $self->attributes->{JSONSchema}->[0];

    if (exists $SCHEMA{ $json_file } ) {
        $request_schema = $SCHEMA{ $json_file };
        $c->log->debug("load memory json schema: ".$json_file);
    }
    # first load
    else {
        my $load_schema_json = Path::Class::file($c->config->{home}, $json_file);
        $request_schema = JSON::MaybeXS::decode_json($load_schema_json->slurp);
        $SCHEMA{ $json_file } = $request_schema; 
        $c->log->debug("load file json schema: ".$json_file);
    }

    # find captureargs and convert integer parameter
    for my $key (keys %{ $request_schema->{properties} }) {
        my $prop = $request_schema->{properties}->{$key};

        if ($prop->{captureargs}) {
            $params->{$key} = $c->req->arguments->[$prop->{captureargs} - 1];
        }
        if (defined $params->{$key} && $prop->{type} eq 'integer' && $params->{$key} =~ /^[0-9]+$/) {
                $params->{$key} = int $params->{$key};
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

    # todo: not implemented response schema

    return $orig_response;
};

1;

__END__

=encoding utf-8

=head1 NAME

Catalyst::ActionRole::JSV - Validate data against a JSON schema for Catalyst actions

=head1 SYNOPSIS

  package MyApp::Controller::Course;
  use Moose;
  use namespace::autoclean;

  BEGIN { extends 'Catalyst::Controller'; }

  # RESTful API (Consumes type action) support by Catalyst::Runtime 5.90050 higher
  __PACKAGE__->config(
      action => {
          '*' => {
              Consumes => 'JSON',
              Path => '', 
          }   
      }   
  );


  # Get info on a specific item
  # GET /item/:item_id
  sub lookup :GET Args(1) :Does(JSV) :JSONSchema(root/schema/lookup.json) {
      my ( $self, $c, $item_id ) = @_;
      ...
  }


  # lookup.json (json schema draft4 validation)
  { 
      "title": "Lookup item",
      "type": "object",
      "properties": {
          "item_id": { 
              "type": "integer",
              "minLength": 1,
              "maxLength": 9, 
              "captureargs": 1  # In the case of URL CaptureArgs number 
          }   
      },  
      "required": ["item_id"]
  } 


=head1 DESCRIPTION

Catalyst::ActionRole::JSV is Validate data against a JSON schema for Catalyst actions.
Internally use the json schema draft4 validator called JSV. 


=head1 SEE ALSO


=over 2

=item L<Catalyst::Controller>

=item L<JSV::Validator>

=back

  Catalyst Advent Calendar 2013 / How to implement a super-simple REST API with Catalyst

  http://www.catalystframework.org/calendar/2013/26
  

=head1 AUTHOR

Masaaki Saito E<lt>masakyst.public@gmail.comE<gt>

=head1 COPYRIGHT

Copyright 2017- Masaaki Saito

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
