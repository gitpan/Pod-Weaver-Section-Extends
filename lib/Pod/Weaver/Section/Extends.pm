package Pod::Weaver::Section::Extends;
{
  $Pod::Weaver::Section::Extends::VERSION = '0.002';
}

use strict;
use warnings;


# ABSTRACT: Add a list of parent classes to your POD.

use Moose;
with 'Pod::Weaver::Role::Section';

use aliased 'Pod::Elemental::Element::Nested';
use aliased 'Pod::Elemental::Element::Pod5::Verbatim';
use aliased 'Pod::Elemental::Element::Pod5::Command';

sub weave_section { 
    my ( $self, $doc, $input ) = @_;

    my $file = $input->{filename};

    # yeah, this is a stupid way to do it. it's only for generating
    # docs though. shut up.
    my $success = do $file;

    die "Could not compile $file to find parent class data: $@ $!"
      unless $success;

    my $module = $file;
    $module =~ s{^lib/}{};    # assume modules live under lib
    $module =~ s{/}{::};
    $module =~ s/\.pm//;

    print "module = [$module]";

    my @parents = $self->_get_parents( $module );        

    print "parents = " . Dumper \@parents;

    return unless @parents;

    my @pod = (
        Command->new( { 
            command   => 'over',
            content   => 4
        } ),

        map { 
            Command->new( {
                command    => 'item',
                content    => sprintf 'L<%s>', $_
            } ),
        } @parents
    );        

    push @{ $doc->children },
        Nested->new( { 
            type      => 'command',
            command   => 'head1',
            content   => 'EXTENDS',
            children  => \@pod
        } );

}

sub _get_parents { 
    my ( $self, $module ) = @_;

    no strict 'refs';
    return @{ $module . '::ISA' };
}


1;



__END__
=pod

=head1 NAME

Pod::Weaver::Section::Extends - Add a list of parent classes to your POD.

=head1 VERSION

version 0.002

=head1 SYNOPSIS

In your C<weaver.ini>:

    [Extends]

=head1 DESCRIPTION

This L<Pod::Weaver> section plugin creates an "EXTENDS" section in your POD
which will contain a list of your class's parent classes. It accomplishes
this by attempting to compile your class and inspecting its C<@ISA>. 

=head1 AUTHOR

Mike Friedman <friedo@friedo.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Mike Friedman.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

