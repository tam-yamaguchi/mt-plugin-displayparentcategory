package DisplayParentCategory::Callbacks;
use strict;

sub pre_run {
    my $app = MT->instance;
    my $blog_id = $app->param('blog_id') || 0;
    my $plugin = MT->component('DisplayParentCategory');
    my $active = $plugin->get_config_value('plugin_active', 'blog:'. $blog_id);
    
    if ( $active ) {
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
}
1;