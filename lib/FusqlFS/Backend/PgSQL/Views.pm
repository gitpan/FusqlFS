use strict;
use v5.10.0;
use FusqlFS::Interface;

package FusqlFS::Backend::PgSQL::Views;
use base 'FusqlFS::Interface';
use FusqlFS::Backend::PgSQL::Roles;

sub new
{
    my $class = shift;
    my $self = {};

    $self->{drop_expr} = 'DROP VIEW "%s"';
    $self->{create_expr} = 'CREATE VIEW "%s" AS SELECT 1';
    $self->{store_expr} = 'CREATE OR REPLACE VIEW "%s" AS %s';
    $self->{rename_expr} = 'ALTER VIEW "%s" RENAME TO "%s"';

    $self->{get_expr} = $class->expr("SELECT definition FROM pg_catalog.pg_views WHERE viewname = ?");
    $self->{list_expr} = $class->expr("SELECT viewname FROM pg_catalog.pg_views WHERE schemaname = 'public'");

    $self->{owner} = new FusqlFS::Backend::PgSQL::Role::Owner('v', 2);

    bless $self, $class;
}

sub list
{
    my $self = shift;
    return $self->all_col($self->{list_expr});
}

sub get
{
    my $self = shift;
    my ($name) = @_;
    my $result = $self->all_col($self->{get_expr}, $name);
    return {
        'query.sql' => $result->[0],
        owner => $self->{owner},
    };
}

sub rename
{
    my $self = shift;
    my ($name, $newname) = @_;
    $self->do($self->{'rename_expr'}, [$name, $newname]);
}

sub drop
{
    my $self = shift;
    my ($name) = @_;
    $self->do($self->{'drop_expr'}, [$name]);
}

sub create
{
    my $self = shift;
    my ($name) = @_;
    $self->do($self->{'create_expr'}, [$name]);
}

sub store
{
    my $self = shift;
    my ($name, $data) = @_;
    $self->do($self->{'store_expr'}, [$name, $data->{'query.sql'}]);
}

1;

