# Plugin's routes

Rails.application.routes.draw do
  resources :issue_notes, only: [:index]

  resources :projects do
    resources :issue_notes, only: [:index]
  end
end