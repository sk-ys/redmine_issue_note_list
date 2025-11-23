module AddOptionsToQueryForm
  Deface::Override.new(
    virtual_path: 'queries/_query_form',
    name: 'add_options_to_query_form',
    insert_bottom: '#list-definition',
    text: "<% if controller_name == 'issue_note_list' %><%= render partial: 'issue_note_list/query_form_options' %><% end %>"
  )
end
