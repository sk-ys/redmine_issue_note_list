module ReplaceHrefForEditQueryButton
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'replace_href_for_edit_query_button',
    replace: 'erb[loud]:contains("link_to l(:button_edit_object, object_name: l(:label_query).downcase)")',
  ) do
    <<-HTML
    <% if controller_name == 'issue_note_list' %>
      <%= link_to l(:button_edit_object, object_name: l(:label_query).downcase), edit_query_path(@query, issue_note_list: 1), :class => 'icon icon-edit aaa' %>
    <% else %>
      <%= link_to l(:button_edit_object, object_name: l(:label_query).downcase), edit_query_path(@query, redirect_params), :class => 'icon icon-edit bbb' %>
    <% end %>
    HTML
  end
end
