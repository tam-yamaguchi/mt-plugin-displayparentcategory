package DisplayParentCategory::Callbacks;
use strict;

sub pre_run {
    my $app = MT->instance;
    my $blog_id = $app->param('blog_id') || 0;
    my $plugin = MT->component('DisplayParentCategory');
   
    if (!$plugin->get_config_value('plugin_active', 'blog:'. $blog_id)) {
        return;
    }
    require MT::Placement;
    require MT::Category;

    my %parentHash;
    for my $category (MT::Category->load( {blog_id => $blog_id} ) ){
    	if($category->parent_category == undef){
            $parentHash{$category->id} = "";
    	}else{
            $parentHash{$category->id} = $category->parent_category->label;
    	}
    }
    
    $plugin->registry({
        list_properties => {
            entry => {
                parentname => {
                    label => 'ParentCategory',
                    display => 'default',
                    order => 500,
                    raw => sub {
                        my $prop = shift;
                        my ($objs, $app, $opts) = @_;
                        my $parent_name;
                        my @placements = MT::Placement->load({ entry_id => $objs->id, is_primary => 1 });
                        for my $placement ( @placements ){
                            $parent_name = $parentHash{$placement->category_id};
                        }
                        return $parent_name;
                    },
                    bulk_sort => sub {
                        my $prop = shift;
                        my ($objs) = @_;
                        return sort { $prop->raw($a) cmp $prop->raw($b) } @$objs;
                    },
                },
            },
        }
    });
}


sub add_field {
    my $app = MT->instance;
    my $blog_id = $app->param('blog_id') || 0;
    my $plugin = MT->component('DisplayParentCategory');
    
    if (!$plugin->get_config_value('plugin_active', 'blog:'. $blog_id)) {
        return;
    }

	my ($cb, $app, $template) = @_;
    
	my $th = qq{<th class="col head parentcategory"><span class="col-label first-child last-child">ParentCategory</span></th>};
	my $td = '<td class="col"><mt:Categories><MTSetvarBlock name="cid"><$MTCategoryID$></MTSetvarBlock><mt:If name="cid" eq="$category_id"><MTParentCategory><$MTCategoryLabel$></MTParentCategory></mt:If></mt:Categories></td>';

#テンプレート差し替え1 -- タイトル幅調整
    my $old = <<HTML;
<mtapp:listing  hide_pager="1">
HTML
    $old = quotemeta($old);

    my $new = <<HTML;
<style>
.col.title {
    width: 80px!important;
}
</style>
<mtapp:listing  hide_pager="1">
HTML
    $$template =~ s/$old/$new/;

#テンプレート差し替え2 -- colspan調整
    $old = <<HTML;
      <td class="col title" colspan="<mt:if name="is_blog">5<mt:else>6</mt:if>">
HTML
    $old = quotemeta($old);
    
    my $entry_blog = 6;
    my $entry_website = 7;

    $new = <<HTML;
      <td class="col title" colspan="<mt:if name="is_blog">${entry_blog}<mt:else>${entry_website}</mt:if>">
HTML
    $$template =~ s/$old/$new/;

#テンプレート差し替え3 -- th差し込み
    $old = <<HTML;
      <th class="col head category"><span class="col-label"><mt:if name="object_type" eq="page"><__trans phrase="Folder"><mt:else><__trans phrase="Category"></mt:if></span></th>
HTML
    $old = quotemeta($old);

    $new = <<HTML;
      <th class="col head category"><span class="col-label"><mt:if name="object_type" eq="page"><__trans phrase="Folder"><mt:else><__trans phrase="Category"></mt:if></span></th>
$th
HTML
    $$template =~ s/$old/$new/;

#テンプレート差し替え4 -- td差し込み
    $old = <<HTML;
      </td>
      <td class="col author">
HTML
    $old = quotemeta($old);

    $new = <<HTML;
      </td>
$td
      <td class="col author">
HTML
    $$template =~ s/$old/$new/;
}
1;
