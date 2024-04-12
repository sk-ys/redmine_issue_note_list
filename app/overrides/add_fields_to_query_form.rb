module AddFieldsToQueryForm
  Deface::Override.new(
    virtual_path: 'queries/_form',
    name: 'add_fields_to_query_form',
    insert_bottom: '#options',
  ) do
    <<-HTML
    <% if params[:issue_note_list] %>
      <p><label><%= l(:label_redmine_issue_note_list) %></label>
        <%= hidden_field_tag 'issue_note_list', '1' %>
        <%= hidden_field_tag 'query[enable_compact_mode]', '0' %>
        <%= hidden_field_tag 'query[enable_variable_height]', '0' %>
        <%= hidden_field_tag 'query[enable_simple_editor]', '0' %>
        <%= hidden_field_tag 'query[inline_block_elements]', '1' %>
        <label class="inline" style="white-space: nowrap">
          <%= l(:label_number_of_notes, scope: :issue_note_list) %>:&thinsp;
          <%= number_field_tag "query[number_of_notes]", @query.number_of_notes, min: 1, max: 10, autocomplete: false %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= check_box_tag "query[enable_compact_mode]", "1", @query.enable_compact_mode %>&thinsp;
          <%= l(:label_enable_compact_mode, scope: :issue_note_list) %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= check_box_tag "query[enable_variable_height]", "1", @query.enable_variable_height %>&thinsp;
          <%= l(:label_variable_height, scope: :issue_note_list) %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= l(:label_notes_field_height, scope: :issue_note_list) %>:&thinsp;
          <%= number_field_tag "query[notes_field_height]", @query.notes_field_height, min: 100, max: 1000, step: 10, autocomplete: false %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= check_box_tag "query[enable_simple_editor]", "1", @query.enable_simple_editor %>&thinsp;
          <%= l(:label_simple_editor, scope: :issue_note_list) %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= l(:field_private_notes) %>:&thinsp;
          <%= select_tag "query[private_notes_filter]", options_for_select([
            [l(:label_contains), 'contains'],
            [l(:label_only, scope: :issue_note_list), 'only'],
            [l(:label_not_contains), 'not_contains']],
            selected: @query.private_notes_filter) %>
        </label>
        <label class="inline" style="white-space: nowrap">
          <%= check_box_tag "query[inline_block_elements]", "1", @query.inline_block_elements %>
          <%= l(:label_inline_block_elements, scope: :issue_note_list) %>
        </label>
      </p>
    <% end %>
    HTML
  end
end
