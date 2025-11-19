module ReplaceHrefForEditQueryButton
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'replace_href_for_edit_query_button',
    insert_before: 'erb[loud]:contains("link_to l(:button_edit_object, object_name: l(:label_query)")',
  ) do
    if defined?(redirect_params)
      # Redmine <= 5.1.6, <= 6.0.3
      '<% redirect_params["issue_note_list"] = 1 if controller_name == "issue_note_list" %>'
    else
      # Redmine >= 5.1.7, >= 6.0.4
      '<% redirect_params = controller_name == "issue_note_list" ? { :issue_note_list => 1 } : {} %>'
    end
  end
  
  # Redmine >= 5.1.7, >= 6.0.4
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'replace_edit_query_path',
    replace: 'erb[loud]:contains("edit_query_path(@query)"):contains("link_to l(:button_edit_object")',
    text: '<%= link_to l(:button_edit_object, object_name: l(:label_query)).capitalize, edit_query_path(@query, redirect_params), :class => "icon icon-edit" %>'
  )
  
  # Redmine >= 5.1.7, >= 6.0.4
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'replace_delete_query_path',
    replace: 'erb[loud]:contains("query_path(@query)"):contains("delete_link")',
    text: '<%= delete_link query_path(@query, redirect_params), {}, l(:button_delete_object, object_name: l(:label_query)).capitalize %>'
  )
end
