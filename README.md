# NAME

Catalyst::ActionRole::JSV - Validate data against a JSON schema for Catalyst actions

# SYNOPSIS

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

# DESCRIPTION

Catalyst::ActionRole::JSV is Validate data against a JSON schema for Catalyst actions.
Internally use the json schema draft4 validator called JSV. 

# SEE ALSO

- [Catalyst::Controller](https://metacpan.org/pod/Catalyst::Controller)
- [JSV::Validator](https://metacpan.org/pod/JSV::Validator)

    Catalyst Advent Calendar 2013 / How to implement a super-simple REST API with Catalyst

    http://www.catalystframework.org/calendar/2013/26
    

# AUTHOR

Masaaki Saito <masakyst.public@gmail.com>

# COPYRIGHT

Copyright 2017- Masaaki Saito

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO
