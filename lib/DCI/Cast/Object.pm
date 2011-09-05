package DCI::Cast::Object;
use strict;
use warnings;

use Carp qw/croak confess/;
use Scalar::Util qw/blessed/;
use List::Util qw/first/;

our $AUTOLOAD;

sub CORE { shift->{CORE} }

sub new {
    my $class = shift;
    my ( $core, %params ) = @_;

    croak "You must provide a core object for the cast" unless $core;

    my $core_class = blessed( $core );
    croak "Core object must be a blessed reference not '$core'" unless $core_class;

    my %need;
    for my $dep ( @{$class->CAST_META->{depends}} ) {
        $need{$dep}++ unless $core->can( $dep );
    }

    croak "Core object for cast '$class' missing these methods: " . join ', ', keys %need
        if keys %need;

    if ( my $restricts = $class->CAST_META->{restrict}) {
        croak "Core class must be one of (" . join( ', ', @$restricts) . ") not '$core_class'"
            unless first { $core->isa( $_ ) } @$restricts;
    }

    my $self = bless( { CORE => $core }, $class );
    $self->init( %params ) if $self->can( 'init' );

    return $self;
}

sub can {
    my $self = shift;
    return $self->SUPER::can( @_ ) || $self->CORE->can( @_ );
}

sub isa {
    my $self = shift;
    return $self->SUPER::isa( @_ ) || $self->CORE->isa( @_ );
}

sub DESTROY { delete shift->{core} };

sub AUTOLOAD {
    # Do not shift this, we need it when we use goto &$method
    my ($self) = @_;
    my ( $package, $sub ) = ( $AUTOLOAD =~ m/^(.+)::([^:]+)$/ );
    $AUTOLOAD = undef;

    my $class = blessed $self;
    my $core_class = blessed $self->CORE;

    my $method = $self->CORE->can( $sub );

    croak "Neither cast '$class', nor core class '$core_class' implement method '$sub'"
        unless $method;

    goto &$method;
};

1;

__END__

=pod

=head1 NAME

DCI::Cast::Object - The object from which all Casts inherit.

=head1 METHODS

=over 4

=item my $cast = $class->new( $core, %params )

Create a new instance of the cast around the core object $core. Anything in
%params will be passed to init() if a method of that name exists.

=item my $core = $cast->CORE()

Get the core object around which the cast instance is built.

=item my $subref = $cast->can( $method_name )

Implementation of can() which will check the cast first, then the core.

=item my $bool = $cast->isa( $package_name )

Implementation of isa which will check the cast first, then the core.

=item AUTOLOAD()

Documented for completeness, do not override.

=back

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2011 Chad Granum

DCI-Cast is free software; Standard perl licence.

DCI-Cast is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the license for more details.




