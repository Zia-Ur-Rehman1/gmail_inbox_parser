Rails.application.routes.draw do
  get 'emails', to: 'emails#index'
  get '/oauth2callback', to: 'oauth#callback'
end