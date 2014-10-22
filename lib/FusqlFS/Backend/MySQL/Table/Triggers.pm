use strict;
use 5.010;

package FusqlFS::Backend::MySQL::Table::Triggers;
use FusqlFS::Version;
our $VERSION = $FusqlFS::Version::VERSION;
use parent 'FusqlFS::Artifact::Table::Lazy';

=head1 NAME

FusqlFS::Backend::MySQL::Table::Triggers - 

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 EXPOSED STRUCTURE

=over

=item F<./create.sql>

C<CREATE TRIGGER> clause to create this trigger.

=item F<./struct>

Additional trigger info with following fields:

=over

=item C<when>

I<one of before or after> defines if trigger is triggered before or after event(s).

=item C<event>

I<one of insert, delete, update> an event trigger will be triggered on.

=back

=item F<./code>

Trigger body code.

=item F<./definer>

Symlink to user who defined the trigger.

=back

=cut

sub init
{
    my $self = shift;

    $self->{get_expr} = $self->expr('SHOW TRIGGERS WHERE `Table` = ? AND `Trigger` = ?');
    $self->{get_create_expr} = 'SHOW CREATE TRIGGER `%s`';
    $self->{list_expr} = $self->expr('SHOW TRIGGERS WHERE `Table` = ?');

    $self->{store_expr} = 'CREATE TRIGGER `%(name)$s` %(when)$s %(event)$s ON `%(table)$s` FOR EACH ROW %(code)$s';
    $self->{drop_expr} = 'DROP TRIGGER `%s`';

    $self->{template} = {
        'struct' => '---
event: insert
when: after
',
    };
}

sub get
{
    my $self = shift;
    my ($table, $name) = @_;

    unless ($self->SUPER::get($table, $name))
    {
        my $data = $self->one_row($self->{get_expr}, $table, $name);
        return unless $data;

        my $result = {
            struct => $self->dump({
                'event' => $data->{Event},
                'when'  => $data->{Timing},
            }),
            definer => \"users/$data->{Definer}",
            code => $data->{Statement},
            'create.sql' => $self->one_row($self->{get_create_expr}, [$name])->{'SQL Original Statement'},
        };

    }
}

sub list
{
    my $self = shift;
    my ($table) = @_;
    return [ @{$self->all_col($self->{list_expr}, $table)}, @{$self->SUPER::list($table)} ];
}

sub drop
{
    my $self = shift;
    my ($table, $name) = @_;
    $self->SUPER::drop($table, $name) or $self->do($self->{drop_expr}, [$name]);
}

sub store
{
    my $self = shift;
    my ($table, $name, $data) = @_;
    return unless $data;

    my $struct = $self->validate($data, {
        struct => {
            when  => qr/^(before|after)$/i,
            event => qr/^(insert|delete|update)$/i,
        },
        code    => undef,
        definer => ['SCALAR', sub{ $$_ =~ m{^users/} }],
    }) or return;

    my $definition = {
        name  => $name,
        table => $table,
        event => uc($struct->{struct}->{event}),
        when  => uc($struct->{struct}->{when}),
        code  => $struct->{code},
    };

    $self->drop($table, $name) and $self->do($self->{store_expr}, $definition);
}

sub rename
{
    my $self = shift;
    my ($table, $name, $newname) = @_;
    unless ($self->SUPER::rename($table, $name, $newname)) {
        my $data = $self->get($table, $name);
        $self->drop($table, $name) and $self->store($table, $newname, $data);
    }
}

1;

