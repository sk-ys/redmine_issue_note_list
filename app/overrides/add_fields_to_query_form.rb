module AddFieldsToQueryForm
  Deface::Override.new(
    virtual_path: 'queries/_form',
    name: 'add_fields_to_query_form',
    insert_bottom: '#options',
    partial: 'queries/query_form_options'
  )
end
