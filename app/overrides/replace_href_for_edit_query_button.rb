module ReplaceHrefForEditQueryButton
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'replace_href_for_edit_query_button',
    insert_before: 'erb[loud]:contains("link_to l(:button_edit_object, object_name: l(:label_query)")',
  ) do
    '<% redirect_params["issue_note_list"] = 1 if controller_name == "issue_note_list" %>'
  end
end
