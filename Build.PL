#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'DCI::Cast',
    license     => 'perl',
    dist_author => 'Chad Granum <exodist7@gmail.com>',
    create_readme => 1,
    requires => {
        'Carp'              => 0,
        'Exporter::Declare' => 0,
    },
    build_requires => {
        'Fennec'     => '1.011',
    },
    meta_merge => {
        resources => {
            repository  => 'http://github.com/exodist/DCI-Cast',
            bugtracker  => 'http://github.com/exodist/DCI-Cast/issues',
        },
    }
);

$build->create_build_script;
