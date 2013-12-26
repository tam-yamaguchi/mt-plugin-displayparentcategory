package MT::Plugin::DisplayParentCategory;
use strict;
use MT;
use MT::Plugin;

our $VERSION = '0.2';

use base qw( MT::Plugin );

@MT::Plugin::DisplayParentCategory::ISA = qw(MT::Plugin);

my $plugin = new MT::Plugin::DisplayParentCategory({
    id  => 'DisplayParentCategory',
    key => __PACKAGE__,
    name => 'DisplayParentCategory',
    description => '<MT_TRANS phrase=\'_PLUGIN_DESCRIPTION\'>',
    author_name => 'TAM Inc.',
    author_link => 'http://tam-tam.co.jp/',
    version     => $VERSION,
    blog_config_template => 'DisplayParentCategory_config.tmpl',
    settings => new MT::PluginSettings ([
        ['plugin_active', { Default => 0 }],
    ]),
    l10n_class => 'DisplayParentCategory::L10N',
});

MT->add_plugin($plugin);

sub init_registry {
    my $plugin = shift;
    $plugin->registry( {
        callbacks => {
            'MT::App::CMS::pre_run' => '$displayparentcategory::DisplayParentCategory::Callbacks::pre_run',
            'MT::App::CMS::template_source.entry_table' => '$displayparentcategory::DisplayParentCategory::Callbacks::add_field',
        },
   } );
}
1;