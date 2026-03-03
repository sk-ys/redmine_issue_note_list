# Plugin's routes

Rails.application.routes.draw do
  resources :issue_note_list, only: [:index]

  resources :projects do
    resources :issue_note_list, only: [:index]
  end

  post '/issue_note_list/:issue_id/add_note', to: 'issue_note_list#add_note'
  get '/issue_note_list/:issue_id/refresh_notes', to: 'issue_note_list#refresh_notes', as: 'issue_note_list_refresh_notes'

  resources :issue_note_list, param: :journal_id do
    member do
      delete 'delete_note'
    end
  end
end
