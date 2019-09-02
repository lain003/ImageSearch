Rails.application.routes.draw do
  get 'meta_frames/index'
  get 'meta_frames/:id', to: 'meta_frames#show',as: :meta_frame
  get 'meta_frames/:id/select', to: 'meta_frames#select'
  get 'meta_frames/:id/gif', to: 'meta_frames#gif', as: :meta_frame_gif
  get 'meta_frames/:id/edited_gif/new', to: 'edited_gifs#new', as: :edited_gif_new
  post 'meta_frames/:id/edited_gif/create', to: 'edited_gifs#create', as: :edited_gif_create
  get 'meta_frames/:id/edited_gif/:edited_gif_id', to: 'edited_gifs#show', as: :edited_gif_show
  root to: 'meta_frames#index'
end
