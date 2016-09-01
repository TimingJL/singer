# Learning by Doing

![Ubuntu version](https://img.shields.io/badge/Ubuntu-16.04%20LTS-orange.svg)
![Rails version](https://img.shields.io/badge/Rails-v5.0.0-blue.svg)
![Ruby version](https://img.shields.io/badge/Ruby-v2.3.1p112-red.svg)


# Singer
A rails web app that can integrate the songs on the youtube and the songs on the soundcloud with the lyrics.


# Create a App
```console
$ rails new singer
```

# Add some rubygems we're going to use
In Gemfile
```console
gem 'therubyracer'
gem 'haml', '~>4.0.5'
gem 'bootstrap-sass', '~> 3.2.0.2'
gem 'simple_form', github: 'kesha-antonov/simple_form', branch: 'rails-5-0'
gem 'link_thumbnailer'
gem 'cocoon', '~> 1.2.6'
```
Note: 
Because there is no Javascript interpreter for Rails on Ubuntu Operation System, we have to install `Node.js` or `therubyracer` to get the Javascript interpreter.


# CRUD
A song has many links and has many lyrics.          
To get start it, let's go ahead and create a song controller.
```console
$ rails g controller songs
```

In addition to our controller, we're gonna to need some routes. Under `app/config/routes.rb`
```ruby
Rails.application.routes.draw do
	resources :songs

	root "songs#index"
end
```

Create a new song

Let's go ahead and create the ability to add our new songs and show our songs.

Under `app/controllers/songs_controller.rb`
```ruby
class SongsController < ApplicationController
	before_action :find_song, only: [:show, :edit, :update, :destroy]

    def index
    	@song = Song.all.order("created_at DESC")
    end

    def show
    end

    def new
    	@song = Song.new
    end

    def create
    	@song = Song.new(song_params)
    	if @song.save
    		redirect_to @song, notice: "Successfully created new song"
    	else
    		render 'new'
    	end
    end

    def edit
    end

    def update
        if @song.update(song_params)
            redirect_to @song
        else
            render 'edit'
        end
    end

    def destroy
        @song.destroy
        redirect_to root_path, notice: "Successfully delted song"
    end     

    private

    def song_params
        params.require(:song).permit(:title, :description, links_attributes: [:id, :link, :embed, :_destroy])
    end    

    def find_song
        @song = Song.find(params[:id])
    end

    def find_link
        @link = Link.find(params[:id])
    end
    
    def link_params
        params.require(:link).permit(:link)
    end    
end
```

Then we need to create our song model.
```console
$ rails g model Song title:string description:text user_id:integer
$ rake db:migrate
```


In `app/views/songs`, let's create some file
1. _form.html.haml
2. new.html.haml
3. edit.html.haml
4. show.html.haml

In `app/views/songs/_form.html.haml`
```haml
= simple_form_for @song, html: { multipart: true } do |f|
	= f.input :title, input_html: { class: 'form-control' }
	= f.button :submit, class: "btn btn-primary"
```

In `app/views/songs/new.html.haml`
```haml
%h1 New Song

= render 'form'

%br/

=link_to "Back", root_path, class: "btn btn-default"
```

In `app/views/songs/edit.html.haml`
```haml
%h1 Edit Song

= render 'form'

%br/

=link_to "Back", root_path, class: "btn btn-default"
```

In `app/views/songs/show.html.haml`
```haml
%h1= @song.title

=link_to "Back", root_path, class: "btn btn-default"
=link_to "Edit", edit_song_path, class: "btn btn-default"
=link_to "Delete", song_path, method: :delete, data: {confirm: "Are you sure?"}, class: "btn btn-default"
```

In `app/views/songs/index.html.haml`
```haml
- @song.each do |song|
	%h2= link_to song.title, song
=link_to "New", new_song_path, class: "btn btn-default"
```

# Cacoon

Then, let's add cacoon         
So in `app/assets/application.js`, we add `//= require cocoon` so it compiles to the asset pipeline.
```js
//= require jquery
//= require jquery_ujs
//= require cocoon
//= require turbolinks
//= require_tree 
```
















