# Plugin's routes

Rails.application.routes.draw do
  resources :issue_notes, only: [:index]

  resources :projects do
    resources :issue_notes, only: [:index]
  end

  post '/issue_notes/:issue_id/add_note', to: 'issue_notes#add_note'

  resources :issue_notes, param: :journal_id do
    member do
      delete 'delete_note'
    end
  end
end
