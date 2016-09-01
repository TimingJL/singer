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

