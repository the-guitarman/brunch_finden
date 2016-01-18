#encoding: utf-8

module Mobile::BootstrapHelper
  def bs_panel(options = {}, &block)
    if options[:with_collapse_ct_id] == true
      @collapse_ct_id = @collapse_ct_id ? (@collapse_ct_id += 1) : 1
    end
    content = yield(block)
    return content_tag(:div, content, {:class => 'panel panel-default'})
  end
  
  def bs_collapsible_panel_heading(id, parent_id, &block)
    id = "#{id}#{@collapse_ct_id}" if @collapse_ct_id
    content = yield(block)
    link = link_to(content, "##{id}", {:'data-parent' => "##{parent_id}", :'data-toggle' => :collapse, :rel => :nofollow})
    return content_tag(:div, link, {:class => 'panel-heading'})
  end
  
  def bs_collapsible_panel_body(css_id, css_class, collapsed = true, &block)
    css_id = "#{css_id}#{@collapse_ct_id}" if @collapse_ct_id
    css_class += ' in' unless collapsed
    content = content_tag(:div, yield(block), {:class => 'panel-body'})
    return content_tag(:div, content, {:id => css_id, :class => css_class})
  end
  
  def bs_single_glyphicon(css_class, type = :span)
    return content_tag(type, nil, {:class => "glyphicon #{css_class}"})
  end
end