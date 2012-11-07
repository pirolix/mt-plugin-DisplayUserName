package MT::Plgin::Admin::OMV::DisplayUserName;
# $Id$

use strict;
use MT 4;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = 'v0.10'. ($revision ? ".$revision" : '');

use constant {
    FORMAT_NAME_NICKNAME => 1,
    FORMAT_NICKNAME_NAME => 2,
    FORMAT_NICKNAME =>      3,
};
use constant FORMAT_DEFAULT => FORMAT_NICKNAME_NAME;

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $MYNAME,
    key => $MYNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2012/04261828/', # blog
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/DisplayUserName', # trac
    description => <<HTMLHEREDOC,
<__trans phrase="Display the nickname and username">
HTMLHEREDOC
    system_config_template => "$MYNAME/config.tmpl",
    settings => new MT::PluginSettings ([
        [ 'format', { Default => FORMAT_DEFAULT, scope => 'system' } ],
    ]),
    l10n_class => "${MYNAME}::L10N",
});
MT->add_plugin ($plugin);

sub instance { $plugin; }

sub init_registry {
    my ($self) = @_;
    $self->registry ({
        callbacks => {
            'MT::App::CMS::template_source.header' => sub {
                5.0 <= $MT::VERSION
                    ? return _source_header_v5 (@_) : 0;
                4.0 <= $MT::VERSION
                    ? return _source_header_v4 (@_) : 0;
            },
        },
    });
}



###
sub _source_header_v5 { _source_header_v4 (@_); }

sub _source_header_v4 {
    my ($cb, $app, $tmpl) = @_;

    my $format = $plugin->get_config_value ('format')
        || FORMAT_DEFAULT;

    my $old = <<'MTMLHEREDOC';
mt:var name="author_name" escape="html" escape="html"
MTMLHEREDOC
    chomp $old;
    $old = quotemeta $old;

    # 表示名のみ
    my $new = <<'MTMLHEREDOC';
<mt:var name="author_display_name" escape="html" escape="html">
MTMLHEREDOC
    # ユーザ名 (表示名)
    if ($format == FORMAT_NAME_NICKNAME) {
        $new = <<'MTMLHEREDOC';
<mt:var name="author_name" escape="html" escape="html"> (<mt:var name="author_display_name" escape="html" escape="html">)
MTMLHEREDOC
    }
    # 表示名 (ユーザ名)
    if ($format == FORMAT_NICKNAME_NAME) {
        $new = <<'MTMLHEREDOC';
<mt:var name="author_display_name" escape="html" escape="html"> (<mt:var name="author_name" escape="html" escape="html">)
MTMLHEREDOC
    }
    chomp $new;
    $$tmpl =~ s/<\$?$old\$?>/$new/g;
}

1;